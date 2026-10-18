import 'package:flutter/material.dart';
import '../services/database_service.dart';
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
  String _programTitle = '';
  String? _todayState;
  String? _statusMessage;
  String? _todayDayName;

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

    final userId = DatabaseService.savedUserId;
    if (userId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Kullanıcı kimliği bulunamadı. Lütfen onboarding işlemini tamamlayın.';
      });
      return;
    }

    final data = await DatabaseService.instance.getScheduleData(userId);
    if (!mounted) return;

    setState(() {
      _todayState = data['today_state'] as String?;
      _statusMessage = data['message'] as String?;
      _programTitle = data['program_title'] as String? ?? 'Kişiselleştirilmiş Programım';
      _todayDayName = data['today_day_name'] as String?;
      final raw = data['schedule'];
      if (raw is Map) {
        _schedule = Map<String, dynamic>.from(raw);
      }
      _isLoading = false;
    });
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
                  child: const Icon(Icons.error_outline_rounded,
                      color: Color(0xFFFF3366), size: 48),
                ),
                const SizedBox(height: 24),
                const Text('Hata Oluştu',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.45),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FF87),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _fetchSchedule,
                    child: const Text('Yeniden Dene',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final List<String> sortedDayKeys = _schedule.keys.toList()
      ..sort((a, b) {
        final intNumA = int.tryParse(a.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final intNumB = int.tryParse(b.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return intNumA.compareTo(intNumB);
      });

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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            if (_statusMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: _buildStatusBanner(),
              ),

            // Program title
            if (_programTitle.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161F30),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.stars_rounded,
                            color: Color(0xFF818CF8), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Aktif Programın',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white38,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(
                              _programTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 12),

            Expanded(
              child: sortedDayKeys.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                      itemCount: sortedDayKeys.length,
                      itemBuilder: (context, index) {
                        final String dayKey = sortedDayKeys[index];
                        final List<dynamic> dayExercises =
                            (_schedule[dayKey] as List?) ?? [];

                        // Extract day name from key like "Pazartesi — Gün 1"
                        final String dayName = dayKey.split(' — ').first.trim();
                        final bool isToday = _todayDayName != null && dayName == _todayDayName;
                        final bool canStart = isToday && _todayState == 'workout_time';
                        final bool isDone = isToday && _todayState == 'already_done';

                        return _buildDayTile(
                          dayKey: dayKey,
                          dayExercises: dayExercises,
                          isToday: isToday,
                          canStart: canStart,
                          isDone: isDone,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    Color bannerColor;
    IconData bannerIcon;

    switch (_todayState) {
      case 'workout_time':
        bannerColor = const Color(0xFF00FF87);
        bannerIcon = Icons.fitness_center_rounded;
        break;
      case 'already_done':
        bannerColor = const Color(0xFF00FF87);
        bannerIcon = Icons.check_circle_rounded;
        break;
      case 'rest':
      default:
        bannerColor = const Color(0xFF6366F1);
        bannerIcon = Icons.local_cafe_rounded;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bannerColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(bannerIcon, color: bannerColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _statusMessage ?? '',
              style: TextStyle(color: bannerColor, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayTile({
    required String dayKey,
    required List<dynamic> dayExercises,
    required bool isToday,
    required bool canStart,
    required bool isDone,
  }) {
    final Color accentColor = isToday ? const Color(0xFF00FF87) : Colors.white24;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        boxShadow: isToday
            ? [
                BoxShadow(
                  color: const Color(0xFF00FF87).withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: ExpansionTile(
            collapsedBackgroundColor: const Color(0xFF161F30),
            backgroundColor: const Color(0xFF1E293B),
            iconColor: accentColor,
            collapsedIconColor: isToday ? accentColor : Colors.white38,
            title: Row(
              children: [
                if (isToday)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDone
                          ? const Color(0xFF00FF87).withValues(alpha: 0.15)
                          : const Color(0xFF00FF87).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: const Color(0xFF00FF87).withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      isDone ? 'Tamamlandı' : 'Bugün',
                      style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF00FF87),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                Expanded(
                  child: Text(
                    dayKey,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isToday ? Colors.white : Colors.white60,
                    ),
                  ),
                ),
                if (!isToday)
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(Icons.lock_rounded, color: Colors.white24, size: 16),
                  ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '${dayExercises.length} Egzersiz',
                style: TextStyle(
                    fontSize: 12,
                    color: isToday ? Colors.blueGrey[300] : Colors.white24),
              ),
            ),
            children: [
              Container(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 8),
                color: const Color(0xFF1E293B),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 1,
                      color: Colors.white10,
                      margin: const EdgeInsets.only(bottom: 16),
                    ),
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
                              decoration: BoxDecoration(
                                color: isToday
                                    ? const Color(0xFF00FF87)
                                    : Colors.white24,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                name,
                                style: TextStyle(
                                  color: isToday ? Colors.white70 : Colors.white38,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              '${sets}x$reps',
                              style: TextStyle(
                                color: isToday ? Colors.white30 : Colors.white24,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    if (canStart)
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
                            shadowColor:
                                const Color(0xFF00FF87).withValues(alpha: 0.3),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => WorkoutSessionScreen(
                                  exercisesRaw: dayExercises,
                                  programName: _programTitle,
                                ),
                              ),
                            );
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_circle_fill_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Antrenmanı Başlat',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (isDone)
                      Container(
                        width: double.infinity,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FF87).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFF00FF87).withValues(alpha: 0.2)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_rounded,
                                color: Color(0xFF00FF87), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Bugünkü Antrenman Tamamlandı',
                              style: TextStyle(
                                  color: Color(0xFF00FF87),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_rounded, color: Colors.white24, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Sadece bu gün açılabilir',
                              style: TextStyle(
                                  color: Colors.white24,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
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
              child: const Icon(Icons.calendar_today_rounded,
                  color: Colors.white24, size: 48),
            ),
            const SizedBox(height: 24),
            const Text(
              'Takvim Bulunamadı',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sizin için hazırlanmış herhangi bir takvim bulunamadı.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
