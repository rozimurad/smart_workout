import 'package:flutter/material.dart';

class WorkoutDaysStep extends StatelessWidget {
  final List<String> selectedDays;
  final ValueChanged<List<String>> onDaysChanged;
  final String level;
  final int maxDays;

  static const List<String> allDays = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar'
  ];

  const WorkoutDaysStep({
    super.key,
    required this.selectedDays,
    required this.onDaysChanged,
    required this.level,
    required this.maxDays,
  });

  void _toggleDay(String day, BuildContext context) {
    final updatedList = List<String>.from(selectedDays);
    if (updatedList.contains(day)) {
      updatedList.remove(day);
      onDaysChanged(updatedList);
    } else {
      // Limit kontrolü
      if (updatedList.length >= maxDays) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.black, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Maksimum limit! $level seviyesi için en fazla $maxDays spor günü seçebilirsiniz.',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 13),
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
      updatedList.add(day);
      onDaysChanged(updatedList);
    }
  }

  String _getDynamicDesc() {
    switch (level) {
      case 'Yeni Başlayan':
        return 'Başlangıç seviyesinde olduğun için haftada en fazla 3 gün antrenman yapmalısın. Kalan günler kaslarının toparlanması (dinlenme) içindir.';
      case 'Orta':
        return 'Orta seviyede olduğun için haftada en fazla 4 gün antrenman yapmalısın. Kalan günler kaslarının toparlanması (dinlenme) içindir.';
      case 'İleri':
        return 'İleri seviyede olduğun için haftada en fazla 5 gün antrenman yapmalısın. İleri seviyede bile mutlaka dinlenme günleri kalmalıdır.';
      default:
        return 'Antrenman planını organize edebilmemiz için spor yapmak istediğin günleri seç.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLimitReached = selectedDays.length >= maxDays;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Hangi günler spor yapacaksın?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          // Dinamik Seviye Bilgilendirmesi (Glowing banner box)
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
                    _getDynamicDesc(),
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
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: allDays.length,
              itemBuilder: (context, index) {
                final String day = allDays[index];
                final bool isSelected = selectedDays.contains(day);
                final bool isUnselectedAndDisabled = isLimitReached && !isSelected;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _toggleDay(day, context),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isUnselectedAndDisabled ? 0.45 : 1.0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
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
                              const SizedBox(width: 16),
                              Text(
                                day,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? Colors.white : Colors.white70,
                                ),
                              ),
                              const Spacer(),
                              if (isSelected)
                                const Text(
                                  'Seçili',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF00FF87),
                                    fontWeight: FontWeight.bold,
                                  ),
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
