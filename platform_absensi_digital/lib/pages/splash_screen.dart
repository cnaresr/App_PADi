import 'package:flutter/material.dart';
import 'dart:async';
import 'package:platform_absensi_digital/pages/login_page.dart'; // Pastikan import ini benar

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // State untuk mengontrol tahapan animasi
  bool _logoJatuh = false;
  bool _logoMembesar = false;

  @override
  void initState() {
    super.initState();

    // 1. Logo mulai jatuh setelah 500ms
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _logoJatuh = true);
    });

    // 2. Logo membesar setelah selesai memantul (detik ke 2.2)
    Timer(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _logoMembesar = true);
    });

    // 3. Pindah ke halaman Login saat logo sudah memenuhi layar
    Timer(const Duration(milliseconds: 2900), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, anim, secondaryAnim) => const LoginPage(),
            transitionsBuilder: (context, anim, secondaryAnim, child) {
              // Fade halus saat perpindahan agar menyatu dengan background putih Login
              return FadeTransition(opacity: anim, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil ukuran layar untuk kalkulasi posisi tengah
    final double screenHeight = MediaQuery.of(context).size.height;
    
    // UKURAN AWAL LOGO BARU (Lebih Kecil)
    const double initialLogoWidth = 90.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A), // Warna gelap khas Padi
      body: Stack(
        children: [
          // Widget Animasi Posisi (Untuk efek Jatuh)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 1200),
            curve: Curves.bounceOut, // Efek memantul yang natural
            
            // Perhitungan Posisi Tengah: (Setengah Layar) - (Setengah Tinggi Logo)
            // Asumsi logo proporsional, kita gunakan setengah lebar sebagai offset.
            top: _logoJatuh ? (screenHeight / 2) - (initialLogoWidth / 2) : -200,
            left: 0,
            right: 0,
            child: Center(
              // Widget Animasi Skala (Untuk efek Membesar)
              child: AnimatedScale(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInQuart, // Semakin lama semakin cepat membesarnya
                
                // Ketika membesar, kita perlu skala yang lebih besar (50x)
                // karena ukuran awalnya sekarang lebih kecil.
                scale: _logoMembesar ? 50.0 : 1.0, 
                
                child: Image.asset(
                  'assets/logo_padi.png',
                  width: initialLogoWidth, // Menggunakan ukuran awal yang baru
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}