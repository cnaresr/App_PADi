import 'package:flutter/material.dart';
import 'package:platform_absensi_digital/pages/splash_screen.dart'; // Import splash screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Padi App',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF006D5B),
      ),
      // Halaman pertama adalah Splash Screen
      home: const SplashScreen(), 
    );
  }
}