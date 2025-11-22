import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const AgriTechApp());
}

class AgriTechApp extends StatelessWidget {
  const AgriTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriTech - Nông Nghiệp Thông Minh',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0BDA50),
          primary: const Color(0xFF0BDA50),
          background: const Color(0xFFF5F8F6),
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
