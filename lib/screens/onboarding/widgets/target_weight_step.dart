import 'package:flutter/material.dart';

class TargetWeightStep extends StatelessWidget {
  final String? selectedGoal;
  final double currentWeight;
  final double? targetWeight;
  final ValueChanged<double> onTargetWeightChanged;

  const TargetWeightStep({
    super.key,
    required this.selectedGoal,
    required this.currentWeight,
    required this.targetWeight,
    required this.onTargetWeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedGoal == 'Formda Kal') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Hedef Kilo',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Formda kalmayı seçtiğiniz için hedef kilonuz mevcut kilonuzla aynı tutulmuştur.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.blueGrey[200],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00FF87).withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 80,
                  color: Color(0xFF00FF87),
                ),
              ),
            ),
          ],
        ),
      );
    }

    double minVal = currentWeight;
    double maxVal = currentWeight;

    if (selectedGoal == 'Kilo Ver') {
      minVal = (currentWeight - 30).clamp(30.0, currentWeight);
      maxVal = currentWeight;
    } else if (selectedGoal == 'Kas Kütlesi Kazan') {
      minVal = currentWeight;
      maxVal = currentWeight + 30;
    }

    double currentTarget = targetWeight ?? currentWeight;
    if (currentTarget < minVal) currentTarget = minVal;
    if (currentTarget > maxVal) currentTarget = maxVal;

    double diff = (currentTarget - currentWeight).abs();
    double daysNeeded = 0;

    if (selectedGoal == 'Kilo Ver') {
      daysNeeded = (diff / 0.75) * 7;
    } else {
      daysNeeded = (diff / 0.35) * 7;
    }

    DateTime targetDate = DateTime.now().add(Duration(days: daysNeeded.ceil()));
    String percentage = ((diff / currentWeight) * 100).toStringAsFixed(1) + "%";
    String formattedDate = "${targetDate.day.toString().padLeft(2, '0')}.${targetDate.month.toString().padLeft(2, '0')}.${targetDate.year}";

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Hedef Kilo',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Biyolojik verilere dayanarak hedefine ulaşma süreni optimize ediyoruz. Gerçekçi bir hedef belirle.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.blueGrey[200],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF161F30),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.03),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${currentTarget.toStringAsFixed(1)} kg',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00FF87),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00FF87).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Değişim: $percentage',
                        style: const TextStyle(
                          color: Color(0xFF00FF87),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF00FF87),
                    inactiveTrackColor: Colors.white.withOpacity(0.08),
                    trackHeight: 6,
                    thumbColor: const Color(0xFF00FF87),
                    overlayColor: const Color(0xFF00FF87).withOpacity(0.15),
                  ),
                  child: Slider(
                    value: currentTarget,
                    min: minVal,
                    max: maxVal,
                    divisions: ((maxVal - minVal) * 10).toInt() > 0 ? ((maxVal - minVal) * 10).toInt() : 1,
                    onChanged: onTargetWeightChanged,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (diff > 0)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                        children: [
                          const TextSpan(text: 'Tahmini varış tarihi: '),
                          TextSpan(
                            text: formattedDate,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const TextSpan(text: '\n(Sağlıklı biyolojik hıza göre hesaplanmıştır)'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
