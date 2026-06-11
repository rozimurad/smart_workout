import 'package:flutter/material.dart';

class TargetMusclesStep extends StatelessWidget {
  final List<String> selectedMuscles;
  final ValueChanged<List<String>> onMusclesChanged;

  static const List<Map<String, dynamic>> allMuscles = [
    {
      'name': 'Göğüs',
      'icon': Icons.fitness_center_rounded,
      'desc': 'Göğüs kaslarını (Pektoral) geliştirmeye ve sıkılaştırmaya odaklan.',
    },
    {
      'name': 'Sırt',
      'icon': Icons.accessibility_new_rounded,
      'desc': 'Sırt kaslarını (Kanat, Trapez) güçlendirerek duruşunu geliştir.',
    },
    {
      'name': 'Kollar',
      'icon': Icons.bolt_rounded,
      'desc': 'Pazı (Biceps) ve Arka Kol (Triceps) kaslarını hacimlendir.',
    },
    {
      'name': 'Bacak',
      'icon': Icons.directions_run_rounded,
      'desc': 'Üst bacak (Quad, Hamstring) ve kalf kaslarını güçlendir.',
    },
    {
      'name': 'Karın',
      'icon': Icons.grid_3x3_rounded,
      'desc': 'Merkez bölgesini (Abs, Core) sıkılaştırıp çelik gibi yap.',
    },
    {
      'name': 'Full Body',
      'icon': Icons.boy_rounded,
      'desc': 'Tüm kas gruplarını dengeli ve bütünsel olarak çalıştır.',
    },
  ];

  const TargetMusclesStep({
    super.key,
    required this.selectedMuscles,
    required this.onMusclesChanged,
  });

  void _toggleMuscle(String muscle, BuildContext context) {
    final updatedList = List<String>.from(selectedMuscles);

    if (muscle == 'Full Body') {
      if (updatedList.contains('Full Body')) {
        updatedList.remove('Full Body');
      } else {
        updatedList.clear();
        updatedList.add('Full Body');
      }
      onMusclesChanged(updatedList);
    } else {
      if (updatedList.contains(muscle)) {
        updatedList.remove(muscle);
        onMusclesChanged(updatedList);
      } else {
        // En fazla 4 bölge seçebilirsin kontrolü
        if (updatedList.length >= 4) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.black, size: 22),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'En fazla 4 bölge seçebilirsin',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 13),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF00FF87), // Volt neon green banner
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 3),
            ),
          );
          return;
        }

        updatedList.remove('Full Body');
        updatedList.add(muscle);
        onMusclesChanged(updatedList);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isFullBodySelected = selectedMuscles.contains('Full Body');
    final bool isAnySpecificSelected = selectedMuscles.any((m) => m != 'Full Body');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Hangi bölgeleri odaklamak istiyorsun?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          // Glowing info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xFF818CF8), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isFullBodySelected
                        ? 'Full Body modu aktif. Tüm vücudunuz dengeli çalışacak şekilde planlanacaktır.'
                        : isAnySpecificSelected
                            ? 'Odaklanmak istediğiniz bölgeleri seçtiniz. Antrenman programınız bu kas gruplarına ağırlık verecektir.'
                            : 'Geliştirmek istediğin bölgeleri seç (en az 1, en fazla 4). Ya da tüm vücut çalışmak için "Full Body" tercih et.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: allMuscles.length,
              itemBuilder: (context, index) {
                final Map<String, dynamic> muscleItem = allMuscles[index];
                final String name = muscleItem['name'];
                final IconData icon = muscleItem['icon'];
                final String desc = muscleItem['desc'];

                final bool isSelected = selectedMuscles.contains(name);
                final bool isDisabled = (name == 'Full Body' && isAnySpecificSelected) ||
                    (name != 'Full Body' && isFullBodySelected);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isDisabled ? null : () => _toggleMuscle(name, context),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isDisabled ? 0.35 : 1.0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF00FF87).withValues(alpha: 0.05)
                                : const Color(0xFF161F30),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF00FF87)
                                  : Colors.white.withValues(alpha: 0.05),
                              width: 1.8,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF00FF87).withValues(alpha: 0.15),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : [],
                          ),
                          child: Row(
                            children: [
                              // Icon container
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF00FF87).withValues(alpha: 0.15)
                                      : Colors.white.withValues(alpha: 0.03),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  icon,
                                  color: isSelected ? const Color(0xFF00FF87) : Colors.white60,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.white : Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      desc,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isSelected
                                            ? Colors.white.withValues(alpha: 0.6)
                                            : Colors.white38,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 24,
                                width: 24,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF00FF87)
                                      : Colors.white.withValues(alpha: 0.03),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF00FF87) : Colors.white24,
                                    width: 1.5,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check_rounded,
                                        color: Colors.black,
                                        size: 16,
                                      )
                                    : null,
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
        ],
      ),
    );
  }
}
