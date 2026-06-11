import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/workout_program.dart';
import '../services/database_service.dart';
import '../services/workout_generator_service.dart';
import 'workout_schedule_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  WorkoutProgram? _program;
  String? _environment;

  double _progressPercentage = 0.0;
  int _monthlyTimeMinutes = 0;
  int _monthlySets = 0;
  int _monthlyExercises = 0;
  int _completedWorkouts = 0;
  int _monthlyTarget = 0;
  String? _userName;
  String? _bmiValue;
  String? _bmiStatus;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = DatabaseService.savedUserId;
    if (userId == null) return;

    final data = await DatabaseService.instance.getDashboardData(userId);
    final userRow = await DatabaseService.instance.getUser(userId);
    if (!mounted) return;

    WorkoutProgram? program;
    if (userRow != null) {
      final profile = UserProfile(
        goal: userRow['goal'] as String?,
        gender: userRow['gender'] as String?,
        height: (userRow['height'] as num?)?.toDouble() ?? 175.0,
        weight: (userRow['weight'] as num?)?.toDouble() ?? 70.0,
      );
      program = WorkoutGeneratorService.generateProgram(profile);
    }

    setState(() {
      _userName = data['user_name'] as String?;
      _bmiValue = data['bmi_value'] as String?;
      _bmiStatus = data['bmi_status'] as String?;
      _progressPercentage = (data['progress_percentage'] as num?)?.toDouble() ?? 0.0;
      _monthlyTimeMinutes = data['monthly_time_minutes'] as int? ?? 0;
      _monthlySets = data['monthly_sets'] as int? ?? 0;
      _monthlyExercises = data['monthly_exercises'] as int? ?? 0;
      _completedWorkouts = data['completed_workouts'] as int? ?? 0;
      _monthlyTarget = data['monthly_target'] as int? ?? 0;
      _environment = userRow?['environment'] as String?;
      _program = program;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: const Color(0xFF00FF87),
          backgroundColor: const Color(0xFF161F30),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hoş Geldin, ${_userName ?? "Atlet"}! 👋',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ter dökmeden zafer kazanılmaz.',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blueGrey[300],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () async {
                        final navigator = Navigator.of(context);
                        await DatabaseService.instance.clearAll();
                        navigator.pushReplacementNamed('/');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.logout_rounded,
                            color: Colors.white54, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildProgressCard(),
                const SizedBox(height: 24),
                _buildBmiCard(),
                const SizedBox(height: 24),
                _buildActiveProgramCard(),
                const SizedBox(height: 24),
                _buildGymStartCard(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161F30),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Aylık İlerleme',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white60)),
                const SizedBox(height: 12),
                Text('Hedef $_completedWorkouts/$_monthlyTarget',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text(
                  'Bu ay: $_monthlyTimeMinutes dk | $_monthlySets set | $_monthlyExercises egzersiz',
                  style: TextStyle(fontSize: 12.5, color: Colors.blueGrey[200], height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 70,
                width: 70,
                child: CircularProgressIndicator(
                  value: _progressPercentage,
                  strokeWidth: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.03),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00FF87)),
                ),
              ),
              Text(
                '${(_progressPercentage * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBmiCard() {
    if (_bmiValue == null || _bmiStatus == null) return const SizedBox.shrink();

    Color statusColor;
    IconData statusIcon;
    final String status = _bmiStatus!.trim();
    if (status == 'Normal') {
      statusColor = const Color(0xFF00FF87);
      statusIcon = Icons.check_circle_outline_rounded;
    } else if (status == 'Zayıf') {
      statusColor = const Color(0xFFFFB300);
      statusIcon = Icons.info_outline_rounded;
    } else if (status == 'Fazla Kilolu') {
      statusColor = const Color(0xFFFF8A65);
      statusIcon = Icons.warning_amber_rounded;
    } else {
      statusColor = const Color(0xFFFF3366);
      statusIcon = Icons.error_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161F30),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Vücut Analizi (VKİ)',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white60)),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(_bmiValue!,
                        style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5)),
                    const SizedBox(width: 8),
                    Text('kg/m²',
                        style: TextStyle(fontSize: 14, color: Colors.blueGrey[300])),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: statusColor.withValues(alpha: 0.25), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: statusColor, size: 18),
                const SizedBox(width: 8),
                Text(status,
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold, color: statusColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveProgramCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161F30),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Aktif Programın',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white60)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_program?.hedefKategori ?? '',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF818CF8))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(_program?.programAdi ?? '',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text(_program?.aciklama ?? '',
              style: TextStyle(fontSize: 13, color: Colors.blueGrey[200], height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildGymStartCard() {
    final String env = (_environment ?? '').trim().toLowerCase();
    final bool isHome = env == 'ev' || env.contains('ev');
    final String title = isHome ? 'Evdesin!' : 'Spor Salonundasın!';
    final String subTitle = isHome
        ? 'Vücut ağırlığınla antrenmana başla.'
        : 'Ağırlıkları hissetme vakti.';
    final IconData icon =
        isHome ? Icons.home_rounded : Icons.fitness_center_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
            color: const Color(0xFF00FF87).withValues(alpha: 0.15), width: 2.0),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF00FF87).withValues(alpha: 0.05), blurRadius: 20)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF00FF87), size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00FF87))),
            ],
          ),
          const SizedBox(height: 12),
          Text(subTitle,
              style: const TextStyle(
                  fontSize: 13.5, color: Colors.white70, height: 1.4)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FF87),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const WorkoutScheduleScreen()),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_rounded, size: 20),
                  SizedBox(width: 8),
                  Text('Antrenman Takvimini Aç',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

