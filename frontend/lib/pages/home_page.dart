import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:platform_absensi_digital/providers/user_provider.dart';
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hai ${context.watch<UserProvider>().namaLengkap.split(' ').first}",
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 10),
                        // MENGAMBIL DATA HADIR BULAN INI DARI PROVIDER
                        Text(
                          "Kamu telah hadir\n${context.watch<UserProvider>().hadirBulanIni} hari bulan ini.",
                          style: const TextStyle(fontSize: 15, color: Colors.grey, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(color: const Color(0xFFE8F3F1), borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.school_rounded, size: 50, color: Color(0xFF006D5B)),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // 3. Menu Utama & Hiasan Dekoratif (Baru)
              Row(
                children: [
                  _buildCategoryIcon(context, Icons.edit_document, "Izin", const IzinPage(openRiwayatTab: false)),
                  const SizedBox(width: 25),
                  _buildCategoryIcon(context, Icons.schedule_rounded, "Jadwal", const JadwalPage()),
                  const SizedBox(width: 25),
                  Expanded(
                    child: Container(
                      height: 90, 
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF006D5B), Color(0xFF004D3E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF006D5B).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Tetap", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                                Text("Semangat!", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // 4. Tombol Absen Sekarang
              const Text(
                "Aktivitas hari ini",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () {
                   // Ambil ID siswa dari provider saat tombol ditekan
                   final int siswaId = context.read<UserProvider>().userId;
                   Navigator.push(context, MaterialPageRoute(
                     builder: (context) => AbsensiPage(siswaId: siswaId)
                   ));
                },
                child: Container(
                  width: double.infinity,
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD3EADD), 
                    borderRadius: BorderRadius.circular(28),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 20, left: -20, 
                        child: Container(
                          width: 100, height: 120, 
                          decoration: BoxDecoration(color: const Color(0xFFB9DBC8), borderRadius: BorderRadius.circular(50))
                        )
                      ),
                      Positioned(
                        bottom: -30, right: -10, 
                        child: Container(
                          width: 120, height: 120, 
                          decoration: BoxDecoration(color: const Color(0xFF151B2B).withOpacity(0.05), shape: BoxShape.circle)
                        )
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Absen\nSekarang", 
                                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), height: 1.1, letterSpacing: -0.5)
                                ),
                              ],
                            ),
                            Container(
                               padding: const EdgeInsets.all(12),
                               decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                               child: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF006D5B), size: 24),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // MENGAMBIL PERSENTASE DARI PROVIDER
                          Text("Kehadiran ${context.watch<UserProvider>().persentaseKehadiran}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 5),
                          const Text("Bulan ini", style: TextStyle(color: Colors.grey, fontSize: 13)),
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
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const IzinPage(openRiwayatTab: true)));
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
}