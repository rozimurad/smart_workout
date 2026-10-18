import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';
import '../services/workout_generator_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _profileData;
  String? _assignedProgram;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
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

    final row = await DatabaseService.instance.getUser(userId);
    if (!mounted) return;

    if (row == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Profil bilgileri bulunamadı.';
      });
      return;
    }

    final profile = UserProfile(
      nickname: row['nickname'] as String?,
      gender: row['gender'] as String?,
      age: row['age'] as int? ?? 25,
      height: (row['height'] as num?)?.toDouble() ?? 175.0,
      weight: (row['weight'] as num?)?.toDouble() ?? 70.0,
      goal: row['goal'] as String?,
      level: row['level'] as String?,
      environment: row['environment'] as String?,
      targetMuscles: (row['target_muscles'] as String?)
          ?.split(',')
          .where((s) => s.isNotEmpty)
          .toList(),
      targetWeight: (row['target_weight'] as num?)?.toDouble(),
    );

    setState(() {
      _profileData = row;
      _assignedProgram = WorkoutGeneratorService.generateProgram(profile).programAdi;
      _isLoading = false;
    });
  }

  String _translateGoal(String? goal) {
    if (goal == null) return '-';
    final g = goal.trim().toLowerCase();
    if (g == 'kilo_ver' || g == 'kilo ver' || g.contains('kilo ver')) return 'Kilo Vermek';
    if (g == 'kas_kazan' || g.contains('kas')) return 'Kas Kütlesi Kazanmak';
    if (g == 'formda_kal' || g.contains('formda')) return 'Formda Kalmak';
    return goal;
  }

  String _translateEnvironment(String? env) {
    if (env == null) return '-';
    final e = env.trim().toLowerCase();
    if (e == 'ev' || e.contains('ev')) return 'Evde Egzersiz';
    if (e == 'salon' || e.contains('salon')) return 'Spor Salonu';
    return env;
  }

  String _translateLevel(String? level) {
    if (level == null) return '-';
    final l = level.trim().toLowerCase();
    if (l.contains('yeni') || l.contains('başlayan')) return 'Yeni Başlayan';
    if (l == 'orta') return 'Orta Seviye';
    if (l == 'ileri') return 'İleri Seviye';
    return level;
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
                'Profil Bilgilerin Yükleniyor...',
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
                const Text(
                  'Profil Yüklenemedi',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
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
                    onPressed: _fetchProfile,
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

    final profile = _profileData ?? {};
    final String name = profile['nickname'] as String? ?? 'Atlet';
    final int age = profile['age'] as int? ?? 25;
    final double weight = (profile['weight'] as num?)?.toDouble() ?? 70.0;
    final double height = (profile['height'] as num?)?.toDouble() ?? 175.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    height: 54,
                    width: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF00FF87)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                          blurRadius: 10,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        name.substring(0, name.length > 1 ? 2 : 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Premium Atlet',
                        style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF00FF87),
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),

              const Text(
                'Aktif Programın',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                    letterSpacing: 0.5),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF161F30)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.15), width: 2.0),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                        blurRadius: 20,
                        spreadRadius: 2)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.fitness_center_rounded,
                              color: Color(0xFF818CF8), size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Kişisel Antrenman Planın',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF818CF8),
                              letterSpacing: 0.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _assignedProgram ?? 'Kişiselleştirilmiş Program',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Bu program, fiziksel ölçümlerinize ve kişisel antrenman hedeflerinize en uygun şekilde optimize edilmiştir.',
                      style: TextStyle(
                          fontSize: 13, color: Colors.blueGrey[200], height: 1.45),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Fiziksel Ölçümlerin ve Hedefin',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                    letterSpacing: 0.5),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.25,
                children: [
                  _buildMetricTile(
                    icon: Icons.straighten_rounded,
                    iconColor: const Color(0xFF00FF87),
                    label: 'Boy',
                    value: '${height.toStringAsFixed(0)} cm',
                  ),
                  _buildMetricTile(
                    icon: Icons.fitness_center_rounded,
                    iconColor: const Color(0xFF6366F1),
                    label: 'Kilo',
                    value: '${weight.toStringAsFixed(0)} kg',
                  ),
                  _buildMetricTile(
                    icon: Icons.cake_rounded,
                    iconColor: const Color(0xFF00E5FF),
                    label: 'Yaş',
                    value: '$age Yaş',
                  ),
                  _buildMetricTile(
                    icon: Icons.emoji_events_rounded,
                    iconColor: const Color(0xFFFFD700),
                    label: 'Amacı',
                    value: _translateGoal(profile['goal']?.toString()),
                  ),
                  _buildMetricTile(
                    icon: Icons.leaderboard_rounded,
                    iconColor: const Color(0xFFFF9800),
                    label: 'Seviyesi',
                    value: _translateLevel(profile['level']?.toString()),
                  ),
                  _buildMetricTile(
                    icon: Icons.roofing_rounded,
                    iconColor: const Color(0xFF4CAF50),
                    label: 'Seçtiği Ortam',
                    value: _translateEnvironment(profile['environment']?.toString()),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF00FF87)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFF00FF87).withValues(alpha: 0.15),
                          blurRadius: 12,
                          spreadRadius: 1)
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => _showEditWorkoutDaysBottomSheet(context, profile),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_month_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Antrenman Günlerimi Değiştir',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00FF87), Color(0xFF6366F1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFF00FF87).withValues(alpha: 0.15),
                          blurRadius: 12,
                          spreadRadius: 1)
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => _showUpdateWeightBottomSheet(context, profile),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.monitor_weight_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Güncel Kilo Gir',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditWorkoutDaysBottomSheet(BuildContext context, Map<String, dynamic> profile) {
    final String rawLevel = (profile['level'] ?? '').toString().trim().toLowerCase();
    final int maxDays;
    final String levelName;

    if (rawLevel == 'orta') {
      maxDays = 4;
      levelName = 'Orta Seviye';
    } else if (rawLevel == 'ileri') {
      maxDays = 5;
      levelName = 'İleri Seviye';
    } else {
      maxDays = 3;
      levelName = 'Yeni Başlayan';
    }

    final String daysStr = profile['workout_days'] as String? ?? '';
    List<String> currentSelectedDays = daysStr.isNotEmpty
        ? daysStr.split(',').map((d) => d.trim()).where((d) => d.isNotEmpty).toList()
        : [];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B0F19),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (BuildContext bottomSheetContext) {
        List<String> tempSelectedDays = List<String>.from(currentSelectedDays);
        bool isSaving = false;

        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setModalState) {
            final bool isLimitReached = tempSelectedDays.length >= maxDays;

            void toggleDay(String day) {
              setModalState(() {
                if (tempSelectedDays.contains(day)) {
                  tempSelectedDays.remove(day);
                } else {
                  if (tempSelectedDays.length >= maxDays) {
                    ScaffoldMessenger.of(ctx).clearSnackBars();
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: Colors.black, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '$levelName: en fazla $maxDays gün seçebilirsin',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: const Color(0xFF00FF87),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.all(16),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                    return;
                  }
                  tempSelectedDays.add(day);
                }
              });
            }

            Future<void> saveDays() async {
              if (tempSelectedDays.isEmpty) return;
              setModalState(() => isSaving = true);

              final userId = DatabaseService.savedUserId;
              if (userId == null) {
                setModalState(() => isSaving = false);
                return;
              }

              await DatabaseService.instance.updateWorkoutDays(userId, tempSelectedDays);

              if (!ctx.mounted) return;
              Navigator.pop(bottomSheetContext);
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle_outline_rounded, color: Colors.black, size: 22),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Antrenman günleri başarıyla güncellendi.',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFF00FF87),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ),
              );
              _fetchProfile();
            }

            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Antrenman Günlerini Düzenle',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Seviyen: $levelName (En fazla $maxDays gün seçebilirsin)',
                    style: TextStyle(
                        fontSize: 14, color: Colors.blueGrey[200], fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(ctx).size.height * 0.45),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: 7,
                      itemBuilder: (BuildContext listContext, int index) {
                        final String day = [
                          'Pazartesi',
                          'Salı',
                          'Çarşamba',
                          'Perşembe',
                          'Cuma',
                          'Cumartesi',
                          'Pazar'
                        ][index];
                        final bool isSelected = tempSelectedDays.contains(day);
                        final bool isDisabled = isLimitReached && !isSelected;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => toggleDay(day),
                              borderRadius: BorderRadius.circular(14),
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: isDisabled ? 0.45 : 1.0,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 12.0),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF00FF87).withValues(alpha: 0.05)
                                        : const Color(0xFF161F30),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF00FF87)
                                          : Colors.white.withValues(alpha: 0.05),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        height: 22,
                                        width: 22,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFF00FF87)
                                              : Colors.white.withValues(alpha: 0.03),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? const Color(0xFF00FF87)
                                                : Colors.white24,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: isSelected
                                            ? const Icon(Icons.check_rounded,
                                                color: Colors.black, size: 14)
                                            : null,
                                      ),
                                      const SizedBox(width: 14),
                                      Text(
                                        day,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color:
                                              isSelected ? Colors.white : Colors.white70,
                                        ),
                                      ),
                                      const Spacer(),
                                      if (isSelected)
                                        const Text(
                                          'Seçili',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF00FF87),
                                              fontWeight: FontWeight.bold),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white70,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () => Navigator.pop(bottomSheetContext),
                            child: const Text('Vazgeç',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: tempSelectedDays.isNotEmpty
                                  ? const Color(0xFF00FF87)
                                  : const Color(0xFF1E293B),
                              foregroundColor: tempSelectedDays.isNotEmpty
                                  ? Colors.black
                                  : Colors.white24,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              elevation: tempSelectedDays.isNotEmpty ? 4 : 0,
                              shadowColor: tempSelectedDays.isNotEmpty
                                  ? const Color(0xFF00FF87).withValues(alpha: 0.3)
                                  : Colors.transparent,
                            ),
                            onPressed: (tempSelectedDays.isNotEmpty && !isSaving)
                                ? saveDays
                                : null,
                            child: isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.black)),
                                  )
                                : const Text('Kaydet',
                                    style: TextStyle(
                                        fontSize: 15, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161F30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              Text(
                label,
                style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white38,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateWeightBottomSheet(BuildContext context, Map<String, dynamic> profile) {
    double currentWeight = (profile['weight'] as num?)?.toDouble() ?? 70.0;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B0F19),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (BuildContext bottomSheetContext) {
        bool isSaving = false;
        double tempWeight = currentWeight;

        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setModalState) {
            Future<void> saveWeight() async {
              setModalState(() => isSaving = true);

              final userId = DatabaseService.savedUserId;
              if (userId == null) {
                setModalState(() => isSaving = false);
                return;
              }

              await DatabaseService.instance.updateWeight(userId, tempWeight);

              if (!ctx.mounted) return;
              Navigator.pop(bottomSheetContext);
              _checkGoalSuccess(ctx, profile, tempWeight);
              _fetchProfile();
            }

            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Güncel Kilonu Gir',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Kilo',
                          style: TextStyle(fontSize: 16, color: Colors.white70)),
                      Text(
                        '${tempWeight.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00FF87)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SliderTheme(
                    data: SliderTheme.of(ctx).copyWith(
                      activeTrackColor: const Color(0xFF00FF87),
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
                      thumbColor: const Color(0xFF00FF87),
                    ),
                    child: Slider(
                      value: tempWeight,
                      min: 30,
                      max: 200,
                      divisions: 1700,
                      onChanged: (val) => setModalState(() => tempWeight = val),
                    ),
                  ),
                  const SizedBox(height: 24),
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
                      onPressed: isSaving ? null : saveWeight,
                      child: isSaving
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text('Kaydet',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _checkGoalSuccess(BuildContext context, Map<String, dynamic> profile, double newWeight) {
    final goal = profile['goal']?.toString().trim().toLowerCase() ?? '';
    final targetWeight = (profile['target_weight'] as num?)?.toDouble();
    if (targetWeight == null) return;

    bool isSuccess = false;
    if (goal.contains('kilo ver')) {
      if (newWeight <= targetWeight) isSuccess = true;
    } else if (goal.contains('kas')) {
      if (newWeight >= targetWeight) isSuccess = true;
    }

    if (isSuccess) {
      _showSuccessBottomSheet(context, newWeight);
    }
  }

  void _showSuccessBottomSheet(BuildContext parentContext, double newWeight) {
    showModalBottomSheet(
      context: parentContext,
      backgroundColor: const Color(0xFF0B0F19),
      isScrollControlled: true,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (BuildContext bottomSheetContext) {
        bool isProcessing = false;

        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setModalState) {
            Future<void> maintainForm() async {
              setModalState(() => isProcessing = true);

              final userId = DatabaseService.savedUserId;
              if (userId != null) {
                await DatabaseService.instance
                    .updateGoalAndWeight(userId, 'Formda Kal', newWeight);
              }

              if (!ctx.mounted) return;
              Navigator.pop(bottomSheetContext);
              _fetchProfile();
            }

            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 200,
                    child: Lottie.asset(
                      'assets/animations/celebration.json',
                      repeat: true,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.emoji_events_rounded,
                        size: 100,
                        color: Color(0xFFFFD700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Tebrikler!',
                    style: TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Biyolojik hedefine ulaştın. İstediğin vücut kitle indeksine başarıyla ulaştın.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
                  ),
                  const SizedBox(height: 40),
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
                      onPressed: isProcessing
                          ? null
                          : () {
                              Navigator.pop(bottomSheetContext);
                              Navigator.pushReplacementNamed(ctx, '/');
                            },
                      child: const Text('Yeni Hedef Belirle',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF818CF8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: Color(0xFF818CF8), width: 1.5),
                        ),
                      ),
                      onPressed: isProcessing ? null : maintainForm,
                      child: isProcessing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Bu Formu Koru',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
