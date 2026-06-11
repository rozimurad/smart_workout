import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/workout_exercise.dart';
import '../services/local_storage_service.dart';
import 'main_screen.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final List<dynamic> exercisesRaw;
  final int programId;

  const WorkoutSessionScreen({
    super.key,
    required this.exercisesRaw,
    required this.programId,
  });

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  List<WorkoutExercise> _exercises = [];

  // Antrenman Durumu
  bool _isWorkoutPaused = false;
  int _elapsedSeconds = 0;
  Timer? _timer;
  int _currentSet = 1;
  int _currentExerciseIndex = 0;
  bool _isRestActive = false;
  int _restSecondsRemaining = 60;
  bool _isNextStepExerciseTransition = false;
  bool _isPreparing = true;
  int _prepareCountdown = 10;

  // Veri Toplama Değişkenleri
  int sessionTotalTime = 0;
  int _completedSets = 0;

  @override
  void initState() {
    super.initState();
    _exercises = widget.exercisesRaw.map((e) => WorkoutExercise.fromJson(e)).toList();
    _startWorkout();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startWorkout() {
    setState(() {
      _isWorkoutPaused = false;
      _elapsedSeconds = 0;
      _currentExerciseIndex = 0;
      _currentSet = 1;
      _isRestActive = false;
      _restSecondsRemaining = 60;
      _isNextStepExerciseTransition = false;
      _isPreparing = true;
      _prepareCountdown = 10;
      sessionTotalTime = 0;
      _completedSets = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isWorkoutPaused) {
        setState(() {
          if (_isPreparing) {
            if (_prepareCountdown > 1) {
              _prepareCountdown--;
            } else {
              _skipPreparation();
            }
          } else {
            _elapsedSeconds++;
            sessionTotalTime = _elapsedSeconds;
            if (_isRestActive) {
              if (_restSecondsRemaining > 1) {
                _restSecondsRemaining--;
              } else {
                _skipRest();
              }
            }
          }
        });
      }
    });
  }

  void _skipPreparation() {
    setState(() {
      _isPreparing = false;
    });
  }

  void _togglePause() {
    setState(() {
      _isWorkoutPaused = !_isWorkoutPaused;
    });
  }

  // Dinamik özellikleri çeken yardımcılar
  int get _getCurrentMaxSets {
    if (widget.exercisesRaw.isEmpty || _currentExerciseIndex >= widget.exercisesRaw.length) return 4;
    final ex = widget.exercisesRaw[_currentExerciseIndex];
    return int.tryParse(ex['set_count']?.toString() ?? '') ?? 4;
  }

  int get _getCurrentReps {
    if (widget.exercisesRaw.isEmpty || _currentExerciseIndex >= widget.exercisesRaw.length) return 10;
    final ex = widget.exercisesRaw[_currentExerciseIndex];
    return int.tryParse(ex['rep_count']?.toString() ?? '') ?? 10;
  }

  int get _getCurrentRestDuration {
    if (widget.exercisesRaw.isEmpty || _currentExerciseIndex >= widget.exercisesRaw.length) return 60;
    final ex = widget.exercisesRaw[_currentExerciseIndex];
    return int.tryParse(ex['rest_duration']?.toString() ?? '') ?? 60;
  }

  void _nextSet() {
    final maxSets = _getCurrentMaxSets;
    final isLastExercise = _currentExerciseIndex == _exercises.length - 1;
    final isLastSet = _currentSet == maxSets;

    if (isLastExercise && isLastSet) {
      // Antrenmanın en son egzersizinin en son seti bittiyse dinlenme çalıştırma, doğrudan bitir!
      _finishWorkout();
    } else {
      // Her koşulda dinlenme sayacını başlat
      setState(() {
        _isRestActive = true;
        _restSecondsRemaining = _getCurrentRestDuration;
        _isNextStepExerciseTransition = isLastSet;
      });
    }
  }

  void _skipRest() {
    setState(() {
      _isRestActive = false;
      if (_isNextStepExerciseTransition) {
        // Egzersiz geçişi yap
        _currentSet = 1;
        _currentExerciseIndex++;
      } else {
        // Normal set geçişi yap
        _currentSet++;
      }
    });
  }

  Future<void> _finishWorkout() async {
    _timer?.cancel();

    // Kaydediliyor yükleniyor ekranı göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: const Padding(
              padding: EdgeInsets.all(24.0),
              child: Row(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FF87)),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      'Antrenman kaydediliyor...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    final bool success = await _sendCompleteWorkout();

    if (mounted) {
      Navigator.of(context).pop(); // Loading dialogu kapat
    }

    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Antrenman kaydedilirken sunucu hatası oluştu.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0x1F00FF87),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      size: 64,
                      color: Color(0xFF00FF87),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Tebrikler! 💪',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Bugünkü antrenmanı başarıyla tamamladın. Kendine harika bir yatırım yaptın!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey[200],
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
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Dialogu kapat
                        // Ana Ekrana yönlendir ve stack temizle
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const MainScreen()),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'Harika! Devam Et',
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
          );
        },
      );
    }
  }

  Future<bool> _sendCompleteWorkout() async {
    final userId = LocalStorageService.getSavedUserId();
    if (userId == null) return false;

    final payload = {
      'user_id': int.tryParse(userId.toString()) ?? userId,
      'program_id': widget.programId,
      'total_time': sessionTotalTime,
      'total_exercises': _currentExerciseIndex + 1,
      'total_sets': _completedSets,
    };

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.23/api/complete_workout.php'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          return true;
        }
      }
    } catch (e) {
      // Ağ hatası
    }
    return false;
  }

  String _formatDuration(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_exercises.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B0F19),
        appBar: AppBar(backgroundColor: const Color(0xFF0B0F19), elevation: 0),
        body: const Center(
          child: Text('Egzersizler yüklenemedi.', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F19),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 24),
          onPressed: () {
            // Antrenmanı yarıda kesmek istiyor musunuz popup'ı
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: const Color(0xFF1E293B),
                title: const Text('Antrenmandan Çıkılsın mı?', style: TextStyle(color: Colors.white)),
                content: const Text('Mevcut antrenman seansınız sonlandırılacak. İlerlemeniz kaydedilmeyecek.',
                    style: TextStyle(color: Colors.white70)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Devam Et', style: TextStyle(color: Color(0xFF00FF87))),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(); // Geri git
                    },
                    child: const Text('Çıkış Yap', style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            );
          },
        ),
        title: const Text(
          'Antrenman Seansı',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: _isPreparing
                    ? const Color(0xFF00E5FF).withValues(alpha: 0.2)
                    : const Color(0xFF00FF87).withValues(alpha: 0.2),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isPreparing
                      ? const Color(0xFF00E5FF).withValues(alpha: 0.08)
                      : const Color(0xFF00FF87).withValues(alpha: 0.08),
                  blurRadius: 24,
                )
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              switchInCurve: Curves.easeInOutCubic,
              switchOutCurve: Curves.easeInOutCubic,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _isPreparing
                  ? _buildPreparationPanel()
                  : _buildActiveWorkoutPanel(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreparationPanel() {
    final WorkoutExercise nextExercise = _exercises[_currentExerciseIndex];

    return Column(
      key: const ValueKey('preparation_panel'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'HAZIRLAN!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Color(0xFF00E5FF), // Electric cyan
            letterSpacing: 2.0,
            shadows: [
              Shadow(
                color: Color(0xFF00E5FF),
                blurRadius: 15,
              )
            ],
          ),
        ),
        const SizedBox(height: 36),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 140,
              width: 140,
              child: CircularProgressIndicator(
                value: _prepareCountdown / 10.0,
                strokeWidth: 6,
                backgroundColor: Colors.white.withValues(alpha: 0.03),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
              ),
            ),
            Text(
              '$_prepareCountdown',
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'monospace',
                shadows: [
                  Shadow(
                    color: Colors.black38,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  )
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),
        const Text(
          'SIRADAKİ EGZERSİZ',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white38,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          nextExercise.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00FF87), // Volt neon green
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Ekipmanlarını hazırla ve pozisyonunu al.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5FF).withValues(alpha: 0.1),
              foregroundColor: const Color(0xFF00E5FF),
              side: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            onPressed: _skipPreparation,
            child: const Text(
              'Atla',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveWorkoutPanel() {
    final WorkoutExercise currentExercise = _exercises[_currentExerciseIndex];
    final int maxSets = _getCurrentMaxSets;
    final int reps = _getCurrentReps;

    return Column(
      key: const ValueKey('active_workout_panel'),
      children: [
        // ACTIVE TOP TIMER ROW
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: 8,
                  width: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF3366), // Red blinking dot
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'CANLI SEANS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF3366),
                  ),
                ),
              ],
            ),
            Text(
              _formatDuration(_elapsedSeconds),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // EXERCISE VIDEO TUTORIAL AREA
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: const Color(0xFF0B0F19), // Match background obsidian
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                spreadRadius: 1,
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              currentExercise.gifUrl,
              headers: const {
                'User-Agent': 'AkilliAntremanAsistani/1.0 (contact@akilliantreman.com)',
              },
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FF87)), // Neon green spinner
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported_rounded,
                        size: 40,
                        color: Colors.white24,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Görsel Yüklenemedi',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),

        // CURRENT EXERCISE & PROGRESS
        Text(
          'EGZERSİZ ${_currentExerciseIndex + 1} / ${_exercises.length}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00FF87),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          currentExercise.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),

        if (_isRestActive) ...[
          // REST COUNTDOWN DISPLAY
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                const Text(
                  'DİNLENME SÜRESİ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6366F1), // Indigo accent
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 90,
                      width: 90,
                      child: CircularProgressIndicator(
                        value: _restSecondsRemaining / 60.0,
                        strokeWidth: 5,
                        backgroundColor: Colors.white.withValues(alpha: 0.03),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                      ),
                    ),
                    Text(
                      '$_restSecondsRemaining',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _isNextStepExerciseTransition
                      ? 'Sıradaki Hareket: ${_exercises[_currentExerciseIndex + 1].name}'
                      : 'Sonraki Set: Set ${_currentSet + 1}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00FF87), // Glowing neon green
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Derin nefes al ve vücudunu hazırla.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ] else ...[
          // SET COUNTER
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(maxSets, (index) {
              final setNum = index + 1;
              final isCompleted = setNum < _currentSet;
              final isActive = setNum == _currentSet;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6.0),
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF00FF87).withValues(alpha: 0.15)
                      : isActive
                          ? const Color(0xFF6366F1).withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.02),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted
                        ? const Color(0xFF00FF87)
                        : isActive
                            ? const Color(0xFF6366F1)
                            : Colors.white10,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$setNum',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCompleted
                          ? const Color(0xFF00FF87)
                          : isActive
                              ? const Color(0xFF818CF8)
                              : Colors.white30,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            'SET $_currentSet / $maxSets ($reps Tekrar)',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white38,
            ),
          ),
          const SizedBox(height: 40),
        ],

        // INTERACTIVE CONTROL BUTTONS
        Row(
          children: [
            // PAUSE BUTTON
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _togglePause,
                  child: Icon(
                    _isWorkoutPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // ACTION BUTTON
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRestActive ? const Color(0xFF6366F1) : const Color(0xFF00FF87),
                    foregroundColor: _isRestActive ? Colors.white : Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _isRestActive
                      ? _skipRest
                      : () {
                          setState(() {
                            _completedSets++;
                          });
                          _nextSet();
                        },
                  child: Text(
                    _isRestActive ? 'Dinlenmeyi Atla' : 'Seti Tamamla',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // FINISH WORKOUT PREMATURELY
        TextButton(
          onPressed: _finishWorkout,
          child: const Text(
            'Antrenmanı Bitir',
            style: TextStyle(
              color: Color(0xFFFF3366),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
