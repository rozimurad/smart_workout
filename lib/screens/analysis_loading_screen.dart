import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import 'program_result_screen.dart';

class AnalysisLoadingScreen extends StatefulWidget {
  final UserProfile profile;

  const AnalysisLoadingScreen({
    super.key,
    required this.profile,
  });

  @override
  State<AnalysisLoadingScreen> createState() => _AnalysisLoadingScreenState();
}

class _AnalysisLoadingScreenState extends State<AnalysisLoadingScreen> {
  void _navigateToResult() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ProgramResultScreen(profile: widget.profile),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 650),
      ),
    );
  }

  String _getLoadingText(double progress) {
    if (progress < 0.35) {
      return 'Fiziksel verileriniz analiz ediliyor...';
    } else if (progress >= 0.35 && progress < 0.70) {
      return 'BMI ve metabolizma hızı hesaplanıyor...';
    } else {
      return 'Hedefinize en uygun şablon oluşturuluyor...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 4),
            onEnd: _navigateToResult,
            builder: (context, value, child) {
              final int percentage = (value * 100).round();
              final String currentText = _getLoadingText(value);

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Circular Progress with Glow
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 180,
                        width: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00FF87).withValues(alpha: 0.06),
                              blurRadius: 32,
                              spreadRadius: 6,
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 150,
                        width: 150,
                        child: CircularProgressIndicator(
                          value: value,
                          strokeWidth: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.04),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00FF87)),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$percentage%',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'ANALİZ',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white38,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  // Flowing Text with Smooth Fade and Slide
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: SizedBox(
                      height: 48,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.0, 0.4),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          currentText,
                          key: ValueKey<String>(currentText),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
