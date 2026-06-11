import 'package:flutter/material.dart';

class NicknameStep extends StatefulWidget {
  final String? nickname;
  final ValueChanged<String> onNicknameChanged;

  const NicknameStep({
    super.key,
    required this.nickname,
    required this.onNicknameChanged,
  });

  @override
  State<NicknameStep> createState() => _NicknameStepState();
}

class _NicknameStepState extends State<NicknameStep> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.nickname);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Sana nasıl hitap edelim?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Profilini özelleştirmek ve seni daha iyi tanımak için bir isim/nickname gir.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.blueGrey[200],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 48),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF161F30),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: TextField(
              controller: _controller,
              autofocus: true,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Rumuzunuz veya adınız',
                hintStyle: TextStyle(color: Colors.white24, fontWeight: FontWeight.normal),
                icon: Icon(Icons.person_outline_rounded, color: Color(0xFF00FF87), size: 24),
              ),
              onChanged: widget.onNicknameChanged,
            ),
          ),
        ],
      ),
    );
  }
}
