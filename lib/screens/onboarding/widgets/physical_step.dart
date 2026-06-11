import 'package:flutter/material.dart';

class PhysicalStep extends StatelessWidget {
  final int age;
  final double height;
  final double weight;
  final ValueChanged<int> onAgeChanged;
  final ValueChanged<double> onHeightChanged;
  final ValueChanged<double> onWeightChanged;

  const PhysicalStep({
    super.key,
    required this.age,
    required this.height,
    required this.weight,
    required this.onAgeChanged,
    required this.onHeightChanged,
    required this.onWeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Fiziksel Özellikler',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Metabolik hızını hesaplamak ve doğru antrenman yoğunluğunu belirlemek için vücut yapını tanımla.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.blueGrey[200],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 40),

          // AGE CARD
          _buildPhysicalCard(
            title: 'Yaş',
            valueText: '$age',
            unit: 'yıl',
            child: SliderTheme(
              data: _getSliderTheme(context),
              child: Slider(
                value: age.toDouble(),
                min: 12,
                max: 100,
                divisions: 88,
                onChanged: (val) => onAgeChanged(val.round()),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // HEIGHT CARD
          _buildPhysicalCard(
            title: 'Boy',
            valueText: height.toStringAsFixed(0),
            unit: 'cm',
            child: SliderTheme(
              data: _getSliderTheme(context),
              child: Slider(
                value: height,
                min: 100,
                max: 250,
                divisions: 150,
                onChanged: onHeightChanged,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // WEIGHT CARD
          _buildPhysicalCard(
            title: 'Kilo',
            valueText: weight.toStringAsFixed(0),
            unit: 'kg',
            child: SliderTheme(
              data: _getSliderTheme(context),
              child: Slider(
                value: weight,
                min: 30,
                max: 200,
                divisions: 170,
                onChanged: onWeightChanged,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPhysicalCard({
    required String title,
    required String valueText,
    required String unit,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161F30),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.03),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    valueText,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00FF87), // Neon green active color
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  SliderThemeData _getSliderTheme(BuildContext context) {
    return SliderTheme.of(context).copyWith(
      activeTrackColor: const Color(0xFF00FF87),
      inactiveTrackColor: Colors.white.withOpacity(0.08),
      trackHeight: 6,
      thumbColor: const Color(0xFF00FF87),
      thumbShape: const RoundSliderThumbShape(
        enabledThumbRadius: 10,
      ),
      overlayColor: const Color(0xFF00FF87).withOpacity(0.15),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 22),
    );
  }
}
