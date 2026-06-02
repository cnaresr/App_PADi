import 'package:flutter/material.dart';
import 'package:platform_absensi_digital/pages/home_page.dart';
import 'package:platform_absensi_digital/pages/absensi_page.dart';
import 'package:platform_absensi_digital/pages/izin_page.dart';
import 'package:platform_absensi_digital/pages/profil_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Index untuk melacak menu mana yang sedang dipilih (0 = Beranda)
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditampilkan sesuai urutan navbar
  final List<Widget> _pages = [
    const HomePage(),
    const AbsensiPage(),
    const IzinPage(openRiwayatTab: true),
    const ProfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      // Body akan berubah sesuai index yang dipilih
      body: _pages[_selectedIndex],
      
      // Menggunakan NavigationBar Material 3 agar mirip dengan desain Anda
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: Color(0xFF006D5B), fontSize: 12, fontWeight: FontWeight.bold);
            }
            return const TextStyle(color: Colors.grey, fontSize: 12);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Color(0xFF006D5B));
            }
            return const IconThemeData(color: Colors.grey);
          }),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFC8F6E6), // Warna hijau muda untuk highlight menu aktif
          destinations: const [
            NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: "Beranda"),
            NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: "Absensi"),
            NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: "Riwayat"),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}