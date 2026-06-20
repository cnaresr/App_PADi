import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:platform_absensi_digital/providers/user_provider.dart';
import 'package:platform_absensi_digital/services/api_service.dart';

class DashboardGuruPage extends StatefulWidget {
  const DashboardGuruPage({super.key});

  @override
  State<DashboardGuruPage> createState() => _DashboardGuruPageState();
}

class _DashboardGuruPageState extends State<DashboardGuruPage> {
  // Fungsi untuk memuat ulang data dari server
  Future<void> _refreshDashboardData() async {
    final userProvider = context.read<UserProvider>();
    try {
      final response = await ApiService.getDashboardGuru(userProvider.userId);
      if (response['status'] == 'success' && mounted) {
        // Asumsi UserProvider memiliki method ini untuk update data guru
        userProvider.setGuruDashboardData(
          response['data']['jumlahIzinPending'],
          response['data']['persentaseKehadiranKelas'],
          response['data']['rekapAbsensiKelas'],
          response['data']['jadwalMengajar'],
        );
      } else {
        throw Exception('Gagal memuat data dashboard guru');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal memperbarui data: ${e.toString()}'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    // 1. Ambil data dari Provider
    final userProvider = context.watch<UserProvider>();
    
    // 2. Ambil nama depan saja (misal: "Budi Santoso" jadi "Budi")
    String namaDepan = userProvider.namaLengkap;
    if (namaDepan.contains(' ')) {
      namaDepan = namaDepan.split(' ').first;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: RefreshIndicator(
        onRefresh: _refreshDashboardData,
        color: const Color(0xFF006D5B),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.menu_rounded, size: 30, color: Color(0xFF1E1E1E)),
                    Container(
                      width: 45, height: 45,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBC15B),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                      ),
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 35),

                // 2. Greeting & Ilustrasi (DINAMIS)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Selamat Pagi,\nPak/Bu $namaDepan", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), letterSpacing: -0.5, height: 1.2)),
                          const SizedBox(height: 10),
                          Text("Ada ${userProvider.jumlahIzinPending} pengajuan izin\nyang menunggu konfirmasi.", style: const TextStyle(fontSize: 15, color: Colors.grey, height: 1.4)),
                        ],
                      ),
                    ),
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(20)),
                      child: const Icon(Icons.co_present_rounded, size: 50, color: Color(0xFFEBC15B)),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // 3. Empat Menu Utama
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCategoryIcon(Icons.people_alt_rounded, "Rekap"),
                    _buildCategoryIcon(Icons.edit_document, "Perizinan"),
                    _buildCategoryIcon(Icons.history_edu_rounded, "Log Kelas"),
                    _buildCategoryIcon(Icons.assessment_rounded, "Laporan"),
                  ],
                ),
                const SizedBox(height: 40),

                // 4. Jadwal Mengajar (DINAMIS)
                const Text("Jadwal Mengajar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
                const SizedBox(height: 15),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal, clipBehavior: Clip.none,
                  child: Row(
                    children: userProvider.jadwalMengajar.map((jadwal) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: _buildClassCard(
                          title: "${jadwal['kelas']}\n${jadwal['waktu']}", 
                          subtitle: jadwal['mapel'], 
                          bgColor: jadwal['isDark'] ? const Color(0xFF151B2B) : const Color(0xFFD3EADD), 
                          textColor: jadwal['isDark'] ? Colors.white : const Color(0xFF1E1E1E), 
                          isDark: jadwal['isDark']
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 40),

                // 5. Statistik Kelas (DINAMIS)
                const Text("Kehadiran Kelas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 5))]),
                  child: Row(
                    children: [
                      Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: const Color(0xFFE8F3F1), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.bar_chart_rounded, color: Color(0xFF006D5B), size: 30)),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Hadir ${userProvider.persentaseKehadiranKelas}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 5),
                            const Text("Kehadiran siswa hari ini", style: TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF151B2B), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12), elevation: 0),
                        onPressed: () {}, child: const Text("Detail", style: TextStyle(fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildCategoryIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 65, height: 65,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.grey.withOpacity(0.15)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
          child: Icon(icon, color: const Color(0xFF1E1E1E), size: 28),
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E)))
      ],
    );
  }
  Widget _buildClassCard({required String title, required String subtitle, required Color bgColor, required Color textColor, required bool isDark}) {
    return Container(
      width: 160, height: 210,
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(28)), clipBehavior: Clip.antiAlias,
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
              crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: Text(subtitle, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold))),
                const SizedBox(height: 10),
                Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor, height: 1.2, letterSpacing: -0.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}