import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:platform_absensi_digital/pages/home_page.dart';
import 'package:platform_absensi_digital/pages/absensi_page.dart';
import 'package:platform_absensi_digital/pages/izin_page.dart';
import 'package:platform_absensi_digital/pages/profil_page.dart';
import 'package:platform_absensi_digital/providers/user_provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Index untuk melacak menu mana yang sedang dipilih (0 = Beranda)
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Ambil data user sekali saja saat inisialisasi, tanpa "mendengarkan" perubahan
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Inisialisasi daftar halaman di initState agar tidak dibuat ulang setiap saat
    _pages = [
      const HomePage(),
      AbsensiPage(siswaId: userProvider.userId), // Halaman absensi
      const IzinPage(openRiwayatTab: true), // Halaman riwayat
      const ProfilPage(), // Halaman profil
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      
      // [PERBAIKAN SIBER]: IndexedStack dihapus! 
      // Sekarang halaman hanya akan dibangun (dan kamera dinyalakan) 
      // JIKA index-nya benar-benar sedang aktif dipilih.
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