import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/workout_program.dart';
import '../services/workout_generator_service.dart';
import '../services/local_storage_service.dart';
import 'main_screen.dart';

class ProgramResultScreen extends StatefulWidget {
  final UserProfile profile;

  const ProgramResultScreen({
    super.key,
    required this.profile,
  });

  @override
  State<ProgramResultScreen> createState() => _ProgramResultScreenState();
}

class _ProgramResultScreenState extends State<ProgramResultScreen> {
  bool _isSaving = false;

  Future<void> _confirmAndSave(WorkoutProgram program) async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Yerel hafızaya profil ve antrenman bilgilerini kaydediyoruz
      await LocalStorageService.saveUserProfile(widget.profile);
      await LocalStorageService.saveWorkoutProgram(program);

      if (!mounted) return;

      // Kayıt başarılı popup dialogu göster
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
                      Icons.check_circle_rounded,
                      size: 64,
                      color: Color(0xFF00FF87),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Program Kaydedildi!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${program.programAdi} başarıyla kaydedildi. Ana panele yönlendiriliyorsunuz.',
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
                        // Geriye dönülemez şekilde Ana Ekrana git
                        Navigator.of(context).pushAndRemoveUntil(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            transitionDuration: const Duration(milliseconds: 500),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'Ana Paneli Aç',
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kayıt sırasında hata oluştu: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double bmi = WorkoutGeneratorService.calculateBMI(widget.profile.height, widget.profile.weight);
    final BMIEvaluation bmiEval = WorkoutGeneratorService.evaluateBMI(bmi);
    final WorkoutProgram program = WorkoutGeneratorService.generateProgram(widget.profile);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    // BACK BUTTON & HEADER
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Antrenman Raporun',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // BMI METRIC CARD
                    _buildBMICard(context, bmi, bmiEval),
                    const SizedBox(height: 24),

                    // WORKOUT PROGRAM Glowing Card
                    _buildProgramCard(context, program),
                    const SizedBox(height: 24),

                    // WEEKLY WORKOUT SCHEDULE VISUALIZER
                    _buildScheduleVisualizer(context, program.haftalikGunSayisi),
                    const SizedBox(height: 48),

                    // CONFIRM AND SAVE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00FF87), // Neon Green
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 12,
                          shadowColor: const Color(0xFF00FF87).withValues(alpha: 0.4),
                        ),
                        onPressed: _isSaving ? null : () => _confirmAndSave(program),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isSaving)
                              const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                ),
                              )
                            else ...[
                              const Icon(Icons.check_rounded, size: 24, color: Colors.black),
                              const SizedBox(width: 8),
                              const Text(
                                'Programı Onayla ve Kaydet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            // Loading Overlay when saving
            if (_isSaving)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FF87)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBMICard(BuildContext context, double bmi, BMIEvaluation eval) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161F30),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.03),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vücut Analizi',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eval.category,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: eval.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Vücut Kitle İndeksi (BMI)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: eval.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: eval.color.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  bmi.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: eval.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Custom slider/bar indicator
          _buildBMIScale(bmi, eval.color),
          const SizedBox(height: 20),
          Text(
            eval.description,
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.blueGrey[200],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBMIScale(double bmi, Color pointerColor) {
    double rangeMin = 15.0;
    double rangeMax = 35.0;
    double percentage = (bmi - rangeMin) / (rangeMax - rangeMin);
    percentage = percentage.clamp(0.0, 1.0);

    return Column(
      children: [
        Stack(
          children: [
            // Colored segments
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF00E5FF), // Cyan
                    Color(0xFF00FF87), // Green
                    Color(0xFFFFD700), // Gold
                    Color(0xFFFF3366), // Red
                  ],
                  stops: [0.15, 0.45, 0.75, 1.0],
                ),
              ),
            ),
            // Floating cursor
            LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                final double leftOffset = (width * percentage) - 6;

                return Positioned(
                  left: leftOffset.clamp(0.0, width - 12),
                  top: -2,
                  child: Container(
                    height: 12,
                    width: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: pointerColor,
                          blurRadius: 8,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('15.0', style: TextStyle(fontSize: 10, color: Colors.white24)),
            Text('18.5', style: TextStyle(fontSize: 10, color: Colors.white24)),
            Text('25.0', style: TextStyle(fontSize: 10, color: Colors.white24)),
            Text('30.0', style: TextStyle(fontSize: 10, color: Colors.white24)),
            Text('35.0+', style: TextStyle(fontSize: 10, color: Colors.white24)),
          ],
        ),
      ],
    );
  }

  Widget _buildProgramCard(BuildContext context, WorkoutProgram program) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E293B),
            const Color(0xFF161F30),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.15),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.08),
            blurRadius: 24,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              program.hedefKategori,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF818CF8),
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            program.programAdi,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            program.aciklama,
            style: TextStyle(
              fontSize: 14,
              color: Colors.blueGrey[100],
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatIcon(Icons.calendar_month_rounded, '${program.haftalikGunSayisi} Gün', 'Haftalık Sıklık'),
              const SizedBox(width: 32),
              _buildStatIcon(Icons.timer_rounded, '45-60 dk', 'Seans Süresi'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatIcon(IconData icon, String value, String label) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 22, color: const Color(0xFF00FF87)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScheduleVisualizer(BuildContext context, int daysPerWeek) {
    final List<String> days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    final Set<int> activeDaysIndices = {};
    if (daysPerWeek == 3) {
      activeDaysIndices.addAll([0, 2, 4]);
    } else if (daysPerWeek == 4) {
      activeDaysIndices.addAll([0, 1, 3, 4]);
    } else if (daysPerWeek == 5) {
      activeDaysIndices.addAll([0, 1, 2, 4, 5]);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161F30),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.03),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Haftalık Antrenman Takvimi',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final isWorkoutDay = activeDaysIndices.contains(index);

              return Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: isWorkoutDay ? const Color(0xFF00FF87).withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.02),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isWorkoutDay ? const Color(0xFF00FF87) : Colors.white10,
                        width: isWorkoutDay ? 2 : 1,
                      ),
                      boxShadow: isWorkoutDay
                          ? [
                              BoxShadow(
                                color: const Color(0xFF00FF87).withValues(alpha: 0.2),
                                blurRadius: 8,
                              )
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Icon(
                        isWorkoutDay ? Icons.fitness_center_rounded : Icons.check_box_outline_blank_rounded,
                        size: isWorkoutDay ? 18 : 14,
                        color: isWorkoutDay ? const Color(0xFF00FF87) : Colors.white24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    days[index],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isWorkoutDay ? FontWeight.bold : FontWeight.normal,
                      color: isWorkoutDay ? Colors.white : Colors.white38,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
