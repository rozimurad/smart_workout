import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../services/database_service.dart';
import '../analysis_loading_screen.dart';
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

  int _getMaxWorkoutDays() => _getMaxWorkoutDaysForLevel(_profile.level);

  bool _isStepValid() {
    switch (_currentIndex) {
      case 0:
        return _profile.nickname != null && _profile.nickname!.trim().isNotEmpty;
      case 1:
        return _profile.gender != null;
      case 2:
        return true;
      case 3:
        return _profile.goal != null;
      case 4:
        return true;
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
      setState(() => _currentIndex++);
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _submitProfile();
    }
  }

  void _previousStep() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitProfile() async {
    if (_profile.environment == null) return;
    setState(() => _isLoading = true);

    try {
      await DatabaseService.instance.insertUser(_profile, _workoutDays);

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              AnalysisLoadingScreen(profile: _profile),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Kayıt sırasında hata oluştu: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
              child: Text(message,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isValid = _isStepValid();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Opacity(
                    opacity: _currentIndex > 0 ? 1.0 : 0.0,
                    child: IgnorePointer(
                      ignoring: _currentIndex == 0,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white70, size: 20),
                        onPressed: _previousStep,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
                                  : Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: isCompleted && index == _currentIndex
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF00FF87).withValues(alpha: 0.4),
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
                  Text(
                    '${_currentIndex + 1}/9',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white60),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentIndex = index),
                children: [
                  NicknameStep(
                    nickname: _profile.nickname,
                    onNicknameChanged: (name) =>
                        setState(() => _profile = _profile.copyWith(nickname: name)),
                  ),
                  GenderStep(
                    selectedGender: _profile.gender,
                    onGenderSelected: (gender) =>
                        setState(() => _profile = _profile.copyWith(gender: gender)),
                  ),
                  PhysicalStep(
                    age: _profile.age,
                    height: _profile.height,
                    weight: _profile.weight,
                    onAgeChanged: (age) =>
                        setState(() => _profile = _profile.copyWith(age: age)),
                    onHeightChanged: (height) =>
                        setState(() => _profile = _profile.copyWith(height: height)),
                    onWeightChanged: (weight) =>
                        setState(() => _profile = _profile.copyWith(weight: weight)),
                  ),
                  GoalStep(
                    selectedGoal: _profile.goal,
                    onGoalSelected: (goal) {
                      setState(() {
                        _profile = _profile.goal != goal
                            ? _profile.copyWith(goal: goal, targetWeight: _profile.weight)
                            : _profile.copyWith(goal: goal);
                      });
                    },
                  ),
                  TargetWeightStep(
                    selectedGoal: _profile.goal,
                    currentWeight: _profile.weight,
                    targetWeight: _profile.targetWeight,
                    onTargetWeightChanged: (weight) =>
                        setState(() => _profile = _profile.copyWith(targetWeight: weight)),
                  ),
                  TargetMusclesStep(
                    selectedMuscles: _profile.targetMuscles ?? [],
                    onMusclesChanged: (muscles) =>
                        setState(() => _profile = _profile.copyWith(targetMuscles: muscles)),
                  ),
                  LevelStep(
                    selectedLevel: _profile.level,
                    onLevelSelected: (level) {
                      setState(() {
                        _profile = _profile.copyWith(level: level);
                        final maxDays = _getMaxWorkoutDaysForLevel(level);
                        if (_workoutDays.length > maxDays) {
                          _workoutDays = _workoutDays.sublist(0, maxDays);
                        }
                      });
                    },
                  ),
                  WorkoutDaysStep(
                    selectedDays: _workoutDays,
                    onDaysChanged: (days) => setState(() => _workoutDays = days),
                    level: _profile.level ?? 'Yeni Başlayan',
                    maxDays: _getMaxWorkoutDays(),
                  ),
                  EnvironmentStep(
                    selectedEnvironment: _profile.environment,
                    onEnvironmentSelected: (env) =>
                        setState(() => _profile = _profile.copyWith(environment: env)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isValid ? const Color(0xFF00FF87) : const Color(0xFF1E293B),
                    foregroundColor: isValid ? Colors.black : Colors.white24,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: isValid ? 8 : 0,
                    shadowColor: isValid
                        ? const Color(0xFF00FF87).withValues(alpha: 0.3)
                        : Colors.transparent,
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
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          )
                        : Text(
                            _currentIndex == 8 ? 'Profilimi Oluştur' : 'Devam Et',
                            key: ValueKey<int>(_currentIndex),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
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
