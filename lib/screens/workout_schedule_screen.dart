import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/local_storage_service.dart';
import 'workout_session_screen.dart';

class WorkoutScheduleScreen extends StatefulWidget {
  const WorkoutScheduleScreen({super.key});

  @override
  State<WorkoutScheduleScreen> createState() => _WorkoutScheduleScreenState();
}

class _WorkoutScheduleScreenState extends State<WorkoutScheduleScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic> _schedule = {};
  int _programId = 1;
  String _programTitle = '';
  String? _todayState;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final userId = LocalStorageService.getSavedUserId();
    if (userId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Kullanıcı kimliği bulunamadı. Lütfen onboarding işlemini tamamlayın.';
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.23/api/get_workout.php?user_id=$userId'),
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] != 'error') {
          setState(() {
            _todayState = data['today_state'];
            _statusMessage = data['message'];
            if (_todayState == 'workout_time') {
              _schedule = Map<String, dynamic>.from(data['schedule'] ?? {});
              _programId = int.tryParse(data['program_id']?.toString() ?? '') ?? 999;
              _programTitle = data['program_title'] ?? 'Kişiselleştirilmiş Programım';
            }
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = data['message'] ?? 'Antrenman takvimi yüklenirken hata oluştu.';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Sunucu hatası: ${response.statusCode}';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Bağlantı hatası: Sunucuya erişilemedi. Lütfen ağınızı kontrol edin.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0F19),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FF87)),
              ),
              SizedBox(height: 20),
              Text(
                'Antrenman Takvimin Hazırlanıyor...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B0F19),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0B0F19),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3366).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFFF3366),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Hata Oluştu',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FF87),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _fetchSchedule,
                    child: const Text(
                      'Yeniden Dene',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Sıralı gün anahtarları
    final List<String> sortedDayKeys = _schedule.keys.toList()
      ..sort((a, b) {
        final intNumA = int.tryParse(a.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final intNumB = int.tryParse(b.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return intNumA.compareTo(intNumB);
      });

    final bool showProgramHeader = _todayState == 'workout_time' && _programTitle.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F19),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Antrenman Takvimi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top program indicator
            if (showProgramHeader)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161F30),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.stars_rounded, color: Color(0xFF818CF8), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Aktif Programın',
                              style: TextStyle(fontSize: 11, color: Colors.white38, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _programTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Scrollable day list OR lockout screens
            Expanded(
              child: _todayState == 'already_done'
                  ? _buildAlreadyDoneState()
                  : _todayState == 'rest'
                      ? _buildRestState()
                      : sortedDayKeys.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                              itemCount: sortedDayKeys.length,
                              itemBuilder: (context, index) {
                                final String dayKey = sortedDayKeys[index];
                                final List<dynamic> dayExercises = _schedule[dayKey] ?? [];

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      dividerColor: Colors.transparent,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: ExpansionTile(
                                        collapsedBackgroundColor: const Color(0xFF161F30),
                                        backgroundColor: const Color(0xFF1E293B),
                                        iconColor: const Color(0xFF00FF87),
                                        collapsedIconColor: Colors.white70,
                                        title: Text(
                                          dayKey,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${dayExercises.length} Egzersiz',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blueGrey[300],
                                          ),
                                        ),
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 8),
                                            color: const Color(0xFF1E293B),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Divider line
                                                Container(
                                                  height: 1,
                                                  color: Colors.white10,
                                                  margin: const EdgeInsets.only(bottom: 16),
                                                ),
                                                // Exercise names column
                                                ...List.generate(dayExercises.length, (idx) {
                                                  final exercise = dayExercises[idx];
                                                  final name = exercise['name'] ?? 'Bilinmeyen Egzersiz';
                                                  final sets = exercise['set_count'] ?? 4;
                                                  final reps = exercise['rep_count'] ?? '10';

                                                  return Padding(
                                                    padding: const EdgeInsets.only(bottom: 12.0),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                          height: 8,
                                                          width: 8,
                                                          decoration: const BoxDecoration(
                                                            color: Color(0xFF00FF87),
                                                            shape: BoxShape.circle,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 12),
                                                        Expanded(
                                                          child: Text(
                                                            name,
                                                            style: const TextStyle(
                                                              color: Colors.white70,
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          '${sets}x$reps',
                                                          style: const TextStyle(
                                                            color: Colors.white30,
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                                const SizedBox(height: 20),
                                                // Action button
                                                SizedBox(
                                                  width: double.infinity,
                                                  height: 48,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: const Color(0xFF00FF87),
                                                      foregroundColor: Colors.black,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      elevation: 6,
                                                      shadowColor: const Color(0xFF00FF87).withValues(alpha: 0.3),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                          builder: (context) => WorkoutSessionScreen(
                                                            exercisesRaw: dayExercises,
                                                            programId: _programId,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        const Icon(Icons.play_circle_fill_rounded, size: 20),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          'Antrenmanı Başlat',
                                                          style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlreadyDoneState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Glowing Green Badge
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF00FF87).withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF00FF87).withValues(alpha: 0.15),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FF87).withValues(alpha: 0.1),
                    blurRadius: 30,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF00FF87),
                size: 64,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Bugünlük Bu Kadar! 🎉',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tebrikler, bugünün idmanını başarıyla tamamladın.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blueGrey[200],
              ),
            ),
            const SizedBox(height: 32),
            // Glass container for the API message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF161F30),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF00FF87).withValues(alpha: 0.1),
                ),
              ),
              child: Text(
                _statusMessage ?? 'Bugün yeterince ter döktün! Yarına kadar antrenman yok.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14.5,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Glowing Coffee Cup Badge
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                    blurRadius: 30,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: const Icon(
                Icons.local_cafe_rounded,
                color: Color(0xFF818CF8),
                size: 64,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Dinlenme Günü ☕',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Bugün vücudunu ve kaslarını toparlama vakti.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blueGrey[200],
              ),
            ),
            const SizedBox(height: 32),
            // Glass container for the API message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF161F30),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                ),
              ),
              child: Text(
                _statusMessage ?? 'Bugün dinlenme günün! Kaslarını toparla, zorlamanın alemi yok.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14.5,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: Colors.white24,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Takvim Bulunamadı',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sizin için hazırlanmış herhangi bir takvim bulunamadı.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
