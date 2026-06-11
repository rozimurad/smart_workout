import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/user_profile.dart';
import '../../services/local_storage_service.dart';
import '../../services/workout_generator_service.dart';
import '../main_screen.dart';
import 'widgets/gender_step.dart';
import 'widgets/physical_step.dart';
import 'widgets/goal_step.dart';
import 'widgets/level_step.dart';
import 'widgets/environment_step.dart';
import 'widgets/nickname_step.dart';
import 'widgets/workout_days_step.dart';
import 'widgets/target_muscles_step.dart';
import 'widgets/target_weight_step.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  UserProfile _profile = UserProfile();
  bool _isLoading = false;
  List<String> _workoutDays = const ['Pazartesi', 'Çarşamba', 'Cuma'];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _getMaxWorkoutDaysForLevel(String? level) {
    if (level == 'Yeni Başlayan') return 3;
    if (level == 'Orta') return 4;
    if (level == 'İleri') return 5;
    return 3;
  }

  int _getMaxWorkoutDays() {
    return _getMaxWorkoutDaysForLevel(_profile.level);
  }

  bool _isStepValid() {
    switch (_currentIndex) {
      case 0:
        return _profile.nickname != null && _profile.nickname!.trim().isNotEmpty;
      case 1:
        return _profile.gender != null;
      case 2:
        return true; // Physical data is prefilled with defaults
      case 3:
        return _profile.goal != null;
      case 4:
        return true; // Target weight has a valid default
      case 5:
        return _profile.targetMuscles != null && _profile.targetMuscles!.isNotEmpty;
      case 6:
        return _profile.level != null;
      case 7:
        return _workoutDays.isNotEmpty;
      case 8:
        return _profile.environment != null;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_currentIndex < 8) {
      setState(() {
        _currentIndex++;
      });
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _submitProfile();
    }
  }

  String _mapGender(String? gender) {
    if (gender == null) return '';
    final g = gender.trim().toLowerCase();
    if (g == 'erkek') return 'erkek';
    if (g == 'kadın' || g == 'kadin') return 'kadin';
    return 'erkek';
  }

  String _mapGoal(String? goal) {
    if (goal == null) return '';
    switch (goal) {
      case 'Kilo Ver':
        return 'kilo_ver';
      case 'Kas Kütlesi Kazan':
        return 'kas_kazan';
      case 'Formda Kal':
        return 'formda_kal';
      default:
        return 'formda_kal';
    }
  }

  String _mapEnvironment(String? env) {
    if (env == null) return '';
    switch (env) {
      case 'Ev':
        return 'ev';
      case 'Spor Salonu':
        return 'salon';
      default:
        return 'ev';
    }
  }

  String _mapLevel(String? level) {
    if (level == null) return '';
    switch (level) {
      case 'Yeni Başlayan':
        return 'baslangic';
      case 'Orta':
        return 'orta';
      case 'İleri':
        return 'ileri';
      default:
        return 'baslangic';
    }
  }

  String _mapTargetMuscles(List<String>? muscles) {
    if (muscles == null || muscles.isEmpty) return 'full_body';
    if (muscles.contains('Full Body')) return 'full_body';
    
    final mapped = muscles.map((m) {
      switch (m) {
        case 'Göğüs': return 'gogus';
        case 'Sırt': return 'sirt';
        case 'Kollar': return 'kol';
        case 'Bacak': return 'bacak';
        case 'Karın': return 'karin';
        default: return 'full_body';
      }
    }).toList();
    
    return mapped.join(',');
  }

  Future<void> _submitProfile() async {
    if (_profile.environment == null) return;

    setState(() {
      _isLoading = true;
    });

    final mappedPayload = {
      'nickname': _profile.nickname,
      'gender': _mapGender(_profile.gender),
      'age': _profile.age,
      'height': _profile.height,
      'weight': _profile.weight,
      'goal': _mapGoal(_profile.goal),
      'target_weight': _profile.targetWeight ?? _profile.weight,
      'environment': _mapEnvironment(_profile.environment),
      'level': _mapLevel(_profile.level),
      'workout_days': _workoutDays.join(','),
      'target_muscles': _mapTargetMuscles(_profile.targetMuscles),
    };

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.23/api/save_profile.php'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(mappedPayload),
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          // Sunucudan dönen user_id değerini hafızaya kaydet
          final userId = responseData['user_id'];
          await LocalStorageService.saveUserId(userId);

          // Yerel hafızayı orijinal kullanıcı profili ile güncelle (arüz terimleriyle)
          await LocalStorageService.saveUserProfile(_profile);
          
          // Profil verilerine uygun antrenman programını oluştur ve yerel hafızaya kaydet
          final program = WorkoutGeneratorService.generateProgram(_profile);
          await LocalStorageService.saveWorkoutProgram(program);

          if (!mounted) return;

          // Ana Ekran (MainScreen)'a yönlendir
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
        } else {
          final errorMessage = responseData['message'] ?? 'Sunucu tarafında bilinmeyen bir hata oluştu.';
          _showErrorSnackBar(errorMessage);
        }
      } else {
        _showErrorSnackBar('Sunucu hatası: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Bağlantı hatası: Sunucuya erişilemedi. Lütfen ağınızı kontrol edin.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _previousStep() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isValid = _isStepValid();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // PROGRESS BAR & BACK BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  // Back button
                  Opacity(
                    opacity: _currentIndex > 0 ? 1.0 : 0.0,
                    child: IgnorePointer(
                      ignoring: _currentIndex == 0,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
                        onPressed: _previousStep,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Progress indicator
                  Expanded(
                    child: Row(
                      children: List.generate(9, (index) {
                        final isCompleted = index <= _currentIndex;
                        return Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            height: 6,
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? const Color(0xFF00FF87)
                                  : Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: isCompleted && index == _currentIndex
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF00FF87).withOpacity(0.4),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : [],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Step ratio text
                  Text(
                    '${_currentIndex + 1}/9',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
            // PAGE VIEW BODY
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: [
                  NicknameStep(
                    nickname: _profile.nickname,
                    onNicknameChanged: (name) {
                      setState(() {
                        _profile = _profile.copyWith(nickname: name);
                      });
                    },
                  ),
                  GenderStep(
                    selectedGender: _profile.gender,
                    onGenderSelected: (gender) {
                      setState(() {
                        _profile = _profile.copyWith(gender: gender);
                      });
                    },
                  ),
                  PhysicalStep(
                    age: _profile.age,
                    height: _profile.height,
                    weight: _profile.weight,
                    onAgeChanged: (age) {
                      setState(() {
                        _profile = _profile.copyWith(age: age);
                      });
                    },
                    onHeightChanged: (height) {
                      setState(() {
                        _profile = _profile.copyWith(height: height);
                      });
                    },
                    onWeightChanged: (weight) {
                      setState(() {
                        _profile = _profile.copyWith(weight: weight);
                      });
                    },
                  ),
                  GoalStep(
                    selectedGoal: _profile.goal,
                    onGoalSelected: (goal) {
                      setState(() {
                        // Reset target weight when goal changes, unless it's the same goal
                        if (_profile.goal != goal) {
                           _profile = _profile.copyWith(goal: goal, targetWeight: _profile.weight);
                        } else {
                           _profile = _profile.copyWith(goal: goal);
                        }
                      });
                    },
                  ),
                  TargetWeightStep(
                    selectedGoal: _profile.goal,
                    currentWeight: _profile.weight,
                    targetWeight: _profile.targetWeight,
                    onTargetWeightChanged: (weight) {
                      setState(() {
                        _profile = _profile.copyWith(targetWeight: weight);
                      });
                    },
                  ),
                  TargetMusclesStep(
                    selectedMuscles: _profile.targetMuscles ?? [],
                    onMusclesChanged: (muscles) {
                      setState(() {
                        _profile = _profile.copyWith(targetMuscles: muscles);
                      });
                    },
                  ),
                  LevelStep(
                    selectedLevel: _profile.level,
                    onLevelSelected: (level) {
                      setState(() {
                        _profile = _profile.copyWith(level: level);
                        // Seviyeye göre antrenman günlerini sınırla/kırp
                        final maxDays = _getMaxWorkoutDaysForLevel(level);
                        if (_workoutDays.length > maxDays) {
                          _workoutDays = _workoutDays.sublist(0, maxDays);
                        }
                      });
                    },
                  ),
                  WorkoutDaysStep(
                    selectedDays: _workoutDays,
                    onDaysChanged: (days) {
                      setState(() {
                        _workoutDays = days;
                      });
                    },
                    level: _profile.level ?? 'Yeni Başlayan',
                    maxDays: _getMaxWorkoutDays(),
                  ),
                  EnvironmentStep(
                    selectedEnvironment: _profile.environment,
                    onEnvironmentSelected: (env) {
                      setState(() {
                        _profile = _profile.copyWith(environment: env);
                      });
                    },
                  ),
                ],
              ),
            ),
            // BOTTOM CONTROLS
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isValid ? const Color(0xFF00FF87) : const Color(0xFF1E293B),
                    foregroundColor: isValid ? Colors.black : Colors.white24,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: isValid ? 8 : 0,
                    shadowColor: isValid ? const Color(0xFF00FF87).withOpacity(0.3) : Colors.transparent,
                  ),
                  onPressed: (isValid && !_isLoading) ? _nextStep : null,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          )
                        : Text(
                            _currentIndex == 8 ? 'Profilimi Oluştur' : 'Devam Et',
                            key: ValueKey<int>(_currentIndex),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
