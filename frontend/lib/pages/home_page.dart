import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:platform_absensi_digital/services/api_service.dart';
import 'package:platform_absensi_digital/providers/user_provider.dart';
import 'package:platform_absensi_digital/pages/absensi_page.dart';
import 'package:platform_absensi_digital/pages/profil_page.dart';
import 'package:platform_absensi_digital/pages/izin_page.dart';
import 'package:platform_absensi_digital/pages/notifikasi_page.dart';
import 'package:platform_absensi_digital/widgets/custom_popup.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _refreshDashboardData() async {
    final userProvider = context.read<UserProvider>();
    try {
      final response = await ApiService.getDashboardData(userProvider.userId);
      if (response['status'] == 'success' && mounted) {
        userProvider.setDashboardData(
          response['data']['hadirBulanIni'],
          response['data']['persentaseKehadiran'],
          response['data']['riwayatAbsensi'],
          response['data']['riwayatPerizinan'],
          jadwal: response['data']['jadwalAktif'] ?? [],
        );
      }
    } catch (e) {
      if (mounted) {
        CustomPopup.show(context, message: 'Gagal memperbarui data: ${e.toString()}', type: PopupType.error);
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 10) return "Selamat Pagi";
    if (hour < 15) return "Selamat Siang";
    if (hour < 18) return "Selamat Sore";
    return "Selamat Malam";
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final firstName = userProvider.namaLengkap.split(' ').first;
    final tanggal = DateFormat('EEEE, d MMMM', 'id_ID').format(DateTime.now());

    // Hitung langsung dari list lokal (sama seperti izin_page.dart)
    final List<dynamic> riwayat = userProvider.riwayatAbsensi;
    final int hadirCount =
        riwayat.where((a) => a['status'] == 'Hadir').length;
    final int telatCount = riwayat
        .where((a) => a['status'] == 'Telat' || a['status'] == 'Terlambat')
        .length;
    final int totalCount = riwayat.length;
    final int persenHadir = totalCount > 0
        ? (((hadirCount + telatCount) / totalCount) * 100).round()
        : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: _refreshDashboardData,
        color: const Color(0xFF006D5B),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ===== HERO HEADER =====
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF006D5B), Color(0xFF004D40)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Logo + App Name
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.school_rounded, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "PADI",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            // Action buttons
                            Row(
                              children: [
                                _buildHeaderBtn(
                                  Icons.notifications_none_rounded,
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotifikasiPage())),
                                ),
                                const SizedBox(width: 10),
                                _buildHeaderBtn(
                                  Icons.person_outline_rounded,
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilPage())),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Greeting
                        Text(
                          tanggal,
                          style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${_getGreeting()},",
                          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 15),
                        ),
                        Text(
                          firstName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Stats mini cards row
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatMiniCard(
                                icon: Icons.calendar_today_rounded,
                                value: "$hadirCount",
                                label: "Hadir Bulan Ini",
                                iconColor: const Color(0xFF80CBC4),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatMiniCard(
                                icon: Icons.trending_up_rounded,
                                value: "$persenHadir%",
                                label: "Persentase",
                                iconColor: const Color(0xFFA5D6A7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ===== BODY CONTENT =====
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Actions
                    _buildSectionTitle("Aksi Cepat"),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickAction(
                            context,
                            icon: Icons.edit_document,
                            label: "Ajukan Izin",
                            color: const Color(0xFF1565C0),
                            bgColor: const Color(0xFFE3F2FD),
                            destination: const IzinPage(openRiwayatTab: false),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickAction(
                            context,
                            icon: Icons.receipt_long_rounded,
                            label: "Riwayat",
                            color: const Color(0xFFE65100),
                            bgColor: const Color(0xFFFFF3E0),
                            destination: const IzinPage(openRiwayatTab: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Absen Sekarang Hero Card
                    _buildSectionTitle("Aktivitas Hari Ini"),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () {
                        final int siswaId = context.read<UserProvider>().userId;
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AbsensiPage(siswaId: siswaId)));
                      },
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF00897B), Color(0xFF004D40)],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF006D5B).withOpacity(0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            // Decorative circles
                            Positioned(
                              top: -20,
                              right: -20,
                              child: Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.07),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -40,
                              left: 60,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            // Content
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.18),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Text(
                                            "Tap untuk mulai",
                                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        const Text(
                                          "Absen\nSekarang",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: -0.5,
                                            height: 1.1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4)),
                                      ],
                                    ),
                                    child: const Icon(Icons.fingerprint_rounded, color: Color(0xFF006D5B), size: 30),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Statistik Kehadiran card (clickable, tanpa progress bar)
                    _buildSectionTitle("Statistik Kehadiran"),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const IzinPage(openRiwayatTab: true))),
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 5)),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.bar_chart_rounded,
                                  color: Color(0xFF006D5B), size: 26),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "$hadirCount Hari Hadir",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        color: Color(0xFF1E1E1E)),
                                  ),
                                  const Text("Bulan ini — Ketuk untuk riwayat",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF006D5B).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.arrow_forward_ios_rounded,
                                  color: Color(0xFF006D5B), size: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Motivasi mini banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C2B2A),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF006D5B),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Tetap Semangat! 💪",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "Kehadiran yang baik adalah kunci kesuksesan.",
                                  style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBtn(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildStatMiniCard({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  label,
                  style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 10, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E1E1E),
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required Widget destination,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => destination)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}