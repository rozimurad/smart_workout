import 'package:flutter/material.dart';

class EnvironmentStep extends StatelessWidget {
  final String? selectedEnvironment;
  final ValueChanged<String> onEnvironmentSelected;

  const EnvironmentStep({
    super.key,
    required this.selectedEnvironment,
    required this.onEnvironmentSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<_EnvironmentItem> environments = [
      _EnvironmentItem(
        title: 'Ev',
        description: 'Vücut ağırlığı ve temel ekipmanlar',
        icon: Icons.home_rounded,
      ),
      _EnvironmentItem(
        title: 'Spor Salonu',
        description: 'Tam donanımlı makineler',
        icon: Icons.fitness_center_rounded,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Nerede Antrenman Yapacaksın?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sana en uygun antrenman planını ve egzersizleri seçtiğin ortama göre hazırlayacağız.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.blueGrey[200],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              itemCount: environments.length,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = environments[index];
                final isSelected = selectedEnvironment == item.title;

                return GestureDetector(
                  onTap: () => onEnvironmentSelected(item.title),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF161F30),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF00FF87) : Colors.white.withValues(alpha: 0.04),
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF00FF87).withValues(alpha: 0.15),
                                blurRadius: 16,
                                spreadRadius: 1,
                              )
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF00FF87).withValues(alpha: 0.1)
                                : Colors.white.withValues(alpha: 0.02),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            item.icon,
                            size: 36,
                            color: isSelected ? const Color(0xFF00FF87) : Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isSelected ? Colors.blueGrey[100] : Colors.blueGrey[300],
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

class _EnvironmentItem {
  final String title;
  final String description;
  final IconData icon;

  _EnvironmentItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}
