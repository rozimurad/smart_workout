import 'package:flutter/material.dart';

class GoalStep extends StatelessWidget {
  final String? selectedGoal;
  final ValueChanged<String> onGoalSelected;

  const GoalStep({
    super.key,
    required this.selectedGoal,
    required this.onGoalSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<_GoalItem> goals = [
      _GoalItem(
        title: 'Kilo Ver',
        description: 'Vücut yağ oranını düşür ve daha hafif, dinamik hisset.',
        icon: Icons.trending_down_rounded,
      ),
      _GoalItem(
        title: 'Kas Kütlesi Kazan',
        description: 'Güçlen, kas hacmini artır ve dayanıklılığını zirveye taşı.',
        icon: Icons.fitness_center_rounded,
      ),
      _GoalItem(
        title: 'Formda Kal',
        description: 'Mevcut formunu koru, enerjini ve genel yaşam zindeliğini artır.',
        icon: Icons.bolt_rounded,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Ana Hedefin Nedir?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sana özel antrenman programını hedefine odaklanarak tasarlayacağız.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.blueGrey[200],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              itemCount: goals.length,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = goals[index];
                final isSelected = selectedGoal == item.title;

                return GestureDetector(
                  onTap: () => onGoalSelected(item.title),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF161F30),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF00FF87) : Colors.white.withOpacity(0.04),
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF00FF87).withOpacity(0.15),
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
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF00FF87).withOpacity(0.1) : Colors.white.withOpacity(0.02),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            item.icon,
                            size: 32,
                            color: isSelected ? const Color(0xFF00FF87) : Colors.white.withOpacity(0.4),
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.description,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isSelected ? Colors.blueGrey[100] : Colors.blueGrey[300],
                                  height: 1.3,
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

class _GoalItem {
  final String title;
  final String description;
  final IconData icon;

  _GoalItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}
