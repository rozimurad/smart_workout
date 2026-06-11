import 'package:flutter/material.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/main_screen.dart';
import 'services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  runApp(const AkilliAntrenmanApp());
}

class AkilliAntrenmanApp extends StatelessWidget {
  const AkilliAntrenmanApp({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isUserLoggedIn = LocalStorageService.getSavedUserId() != null;

    return MaterialApp(
      title: 'Akıllı Antrenman Asistanı',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0F19), // Deep Obsidian background
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FF87), // Sporty Neon Green primary
          secondary: Color(0xFF6366F1), // Indigo secondary
          surface: Color(0xFF161F30), // Obsidian card surface
          background: Color(0xFF0B0F19),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B0F19),
          elevation: 0,
        ),
      ),
      initialRoute: isUserLoggedIn ? '/main' : '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}
