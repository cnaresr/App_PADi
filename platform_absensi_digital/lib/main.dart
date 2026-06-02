import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Pastikan package provider ter-install
import 'package:platform_absensi_digital/pages/splash_screen.dart';
import 'package:platform_absensi_digital/providers/user_provider.dart'; // Import provider

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
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