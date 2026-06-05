import 'package:flutter/material.dart';
import 'package:platform_absensi_digital/pages/dashboard_guru_page.dart';
import 'package:platform_absensi_digital/pages/rekap_absensi_page.dart';
import 'package:platform_absensi_digital/pages/izin_guru_page.dart';
import 'package:platform_absensi_digital/pages/profil_guru_page.dart';

class MainGuruPage extends StatefulWidget {
  const MainGuruPage({super.key});
  @override
  State<MainGuruPage> createState() => _MainGuruPageState();
}

class _MainGuruPageState extends State<MainGuruPage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const DashboardGuruPage(),
    const RekapAbsensiPage(),
    const IzinGuruPage(),
    const ProfilGuruPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF151B2B),
            unselectedItemColor: Colors.grey.shade400,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: "Beranda"),
              BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: "Rekap"),
              BottomNavigationBarItem(icon: Icon(Icons.edit_document), label: "Perizinan"),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: "Profil"),
            ],
          ),
        ),
      ),
    );
  }
}