import 'package:flutter/material.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/main_screen.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.init();
  runApp(const AkilliAntrenmanApp());
}

class AkilliAntrenmanApp extends StatelessWidget {
  const AkilliAntrenmanApp({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isUserLoggedIn = DatabaseService.savedUserId != null;

    return MaterialApp(
      title: 'Akıllı Antrenman Asistanı',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0F19),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FF87),
          secondary: Color(0xFF6366F1),
          surface: Color(0xFF161F30),
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
