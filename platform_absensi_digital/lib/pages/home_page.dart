import 'package:flutter/material.dart';
import 'package:platform_absensi_digital/pages/absensi_page.dart';
import 'package:platform_absensi_digital/pages/riwayat_page.dart';
import 'package:platform_absensi_digital/pages/profil_page.dart';
import 'package:platform_absensi_digital/pages/izin_page.dart';
import 'package:platform_absensi_digital/pages/jadwal_page.dart';
import 'package:platform_absensi_digital/pages/notifikasi_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Bar (Notifikasi & Profil Terkoneksi)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, size: 30, color: Color(0xFF1E1E1E)),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const NotifikasiPage()));
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilPage()));
                    },
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: const Color(0xFF151B2B),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                      ),
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 35),

              // 2. Greeting & Ilustrasi
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hai Cezsar",
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), letterSpacing: -0.5),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Kamu telah hadir\n22 hari bulan ini.",
                          style: TextStyle(fontSize: 15, color: Colors.grey, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(color: const Color(0xFFE8F3F1), borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.directions_run_rounded, size: 50, color: Color(0xFF006D5B)),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // 3. Empat Menu Utama dengan Fungsi Navigasi Aktif
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCategoryIcon(context, Icons.fingerprint, "Absensi", const AbsensiPage()),
                  _buildCategoryIcon(context, Icons.receipt_long_rounded, "Riwayat", const RiwayatPage()),
                  _buildCategoryIcon(context, Icons.edit_document, "Izin", const IzinPage()),
                  _buildCategoryIcon(context, Icons.schedule_rounded, "Jadwal", const JadwalPage()),
                ],
              ),
              const SizedBox(height: 40),

              // 4. Aktivitas Hari Ini
              const Text(
                "Aktivitas hari ini",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
              ),
              const SizedBox(height: 15),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  children: [
                    _buildTodayCard(title: "Presensi\nMasuk", bgColor: const Color(0xFFD3EADD), textColor: const Color(0xFF1E1E1E), isDark: false),
                    const SizedBox(width: 15),
                    _buildTodayCard(title: "Presensi\nPulang", bgColor: const Color(0xFF151B2B), textColor: Colors.white, isDark: true),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 5. Statistik Kehadiran
              const Text(
                "Statistik Anda",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 5))],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: const Color(0xFFE8F3F1), borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.bar_chart_rounded, color: Color(0xFF006D5B), size: 30),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Kehadiran 98%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 5),
                          Text("Sangat baik bulan ini", style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF151B2B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const RiwayatPage()));
                      },
                      child: const Text("Detail", style: TextStyle(fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(BuildContext context, IconData icon, String label, Widget destinationPage) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => destinationPage));
      },
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.withOpacity(0.15)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Icon(icon, color: const Color(0xFF1E1E1E), size: 28),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E)))
        ],
      ),
    );
  }

  Widget _buildTodayCard({required String title, required Color bgColor, required Color textColor, required bool isDark}) {
    return Container(
      width: 160,
      height: 210,
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (isDark) ...[
            Positioned(top: -20, right: -30, child: Container(width: 110, height: 110, decoration: const BoxDecoration(color: Color(0xFFEBC15B), shape: BoxShape.circle))),
            Positioned(bottom: 40, right: -40, child: Container(width: 140, height: 140, decoration: const BoxDecoration(color: Color(0xFF8F306A), shape: BoxShape.circle))),
          ] else ...[
            Positioned(top: 30, left: -30, child: Container(width: 120, height: 140, decoration: BoxDecoration(color: const Color(0xFFB9DBC8), borderRadius: BorderRadius.circular(60)))),
          ],
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor, height: 1.2, letterSpacing: -0.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}