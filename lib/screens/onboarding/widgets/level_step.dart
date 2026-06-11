import 'package:flutter/material.dart';

class LevelStep extends StatelessWidget {
  final String? selectedLevel;
  final ValueChanged<String> onLevelSelected;

  const LevelStep({
    super.key,
    required this.selectedLevel,
    required this.onLevelSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<_LevelItem> levels = [
      _LevelItem(
        title: 'Yeni Başlayan',
        description: 'Spora yeni başlıyorum veya uzun süre ara verdim. Temel seviyeden başlamak istiyorum.',
        icon: Icons.star_border_rounded,
        difficulty: 'Seviye 1',
      ),
      _LevelItem(
        title: 'Orta',
        description: 'Düzenli antrenman yapıyorum ve temel hareketlere hakimim. Orta yoğunluk benim için uygun.',
        icon: Icons.star_half_rounded,
        difficulty: 'Seviye 2',
      ),
      _LevelItem(
        title: 'İleri',
        description: 'Yüksek yoğunluklu antrenmanlar yapıyor ve performans sınırlarımı zorlamak istiyorum.',
        icon: Icons.star_rounded,
        difficulty: 'Seviye 3',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Mevcut Seviyen Nedir?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Antrenmanlarının yoğunluğunu ve hareket zorluklarını bu seviyeye göre ayarlayacağız.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.blueGrey[200],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              itemCount: levels.length,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = levels[index];
                final isSelected = selectedLevel == item.title;

                return GestureDetector(
                  onTap: () => onLevelSelected(item.title),
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : Colors.white70,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF00FF87).withOpacity(0.2) : Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      item.difficulty,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? const Color(0xFF00FF87) : Colors.white54,
                                      ),
                                    ),
                                  ),
                                ],
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

class _LevelItem {
  final String title;
  final String description;
  final IconData icon;
  final String difficulty;

  _LevelItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.difficulty,
  });
}
