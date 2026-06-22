import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Pastikan package provider ter-install
import 'package:platform_absensi_digital/pages/splash_screen.dart';
import 'package:platform_absensi_digital/providers/user_provider.dart'; // Import provider
import 'package:intl/date_symbol_data_local.dart';
import 'package:platform_absensi_digital/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:platform_absensi_digital/services/firebase_messaging_service.dart';

// Variabel global untuk menyimpan daftar kamera yang tersedia
late List<CameraDescription> cameras;

void main() async {
  // Pastikan semua plugin terinisialisasi sebelum menjalankan aplikasi
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi Firebase Core terlebih dahulu
  await Firebase.initializeApp();

  // Inisialisasi Firebase Messaging Service untuk push notification
  await FirebaseMessagingService.init();

  // Inisialisasi Notification Service untuk notifikasi lokal (jika masih digunakan)
  await NotificationService.init();

  // Ambil daftar kamera yang tersedia di perangkat
  cameras = await availableCameras();
  await initializeDateFormatting('id_ID', null);
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
        // Plus Jakarta Sans: font Indonesia buatan, lebih bold & premium dari Poppins
        textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
          // Judul besar - lebih bold & tegas
          displayLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
          displayMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
          displaySmall: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          headlineLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
          headlineMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          headlineSmall: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          titleLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          titleMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          titleSmall: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          // Body text - sedikit lebih bold dari default
          bodyLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
          bodyMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
          bodySmall: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w400),
          // Label (tombol, navigasi)
          labelLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          labelMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          labelSmall: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
      ),
      // Halaman pertama adalah Splash Screen
      home: const SplashScreen(), 
    );
  }
}