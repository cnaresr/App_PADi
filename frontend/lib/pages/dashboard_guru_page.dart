import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:platform_absensi_digital/providers/user_provider.dart';
import 'package:platform_absensi_digital/services/api_service.dart';
import 'package:platform_absensi_digital/pages/notifikasi_page.dart';
import 'package:platform_absensi_digital/pages/profil_guru_page.dart';
import 'package:intl/intl.dart';

class DashboardGuruPage extends StatefulWidget {
  const DashboardGuruPage({super.key});

  @override
  State<DashboardGuruPage> createState() => _DashboardGuruPageState();
}

class _DashboardGuruPageState extends State<DashboardGuruPage> {
  bool _isLoading = true;
  int _jumlahIzinPending = 0;
  int _persentaseKehadiran = 0;
  List<dynamic> _rekapAbsensi = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final response = await ApiService.getDashboardGuru(userProvider.userId);

    if (response['status'] == 'success' && mounted) {
      final data = response['data'];
      setState(() {
        _jumlahIzinPending = data['jumlahIzinPending'] ?? 0;
        _persentaseKehadiran = data['persentaseKehadiranKelas'] ?? 0;
        _rekapAbsensi = data['rekapAbsensiKelas'] ?? [];
        _isLoading = false;
      });

      userProvider.setGuruDashboardData(
        _jumlahIzinPending,
        _persentaseKehadiran,
        _rekapAbsensi,
        data['jadwalMengajar'] ?? [],
      );
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // Hitung statistik dari rekap
  int get _totalSiswa => _rekapAbsensi.length;
  int get _hadirCount => _rekapAbsensi.where((s) => s['status'] == 'Hadir').length;
  int get _telatCount => _rekapAbsensi.where((s) => s['status'] == 'Telat' || s['status'] == 'Terlambat').length;
  int get _izinCount => _rekapAbsensi.where((s) => s['status'] == 'Izin' || s['status'] == 'Sakit').length;
  int get _alpaCount => _rekapAbsensi.where((s) => s['status'] == 'Alpa').length;
  int get _computedPersentase => _totalSiswa > 0 ? (((_hadirCount + _telatCount) / _totalSiswa) * 100).round() : 0;

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
    final String namaLengkap = userProvider.namaLengkap;
    final String tanggalHariIni = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: const Color(0xFF006D5B),
        child: CustomScrollView(
          slivers: [
            // ===== HEADER AREA =====
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
                        // Top bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Logo & App name
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
                            Row(
                              children: [
                                _buildHeaderIconButton(
                                  Icons.notifications_none_rounded,
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotifikasiPage())),
                                ),
                                const SizedBox(width: 10),
                                _buildHeaderIconButton(
                                  Icons.person_outline_rounded,
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilGuruPage())),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        // Greeting
                        Text(
                          tanggalHariIni,
                          style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${_getGreeting()},",
                          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 15),
                        ),
                        Text(
                          namaLengkap,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Summary cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                icon: Icons.people_alt_rounded,
                                label: "Total Siswa",
                                value: "$_totalSiswa",
                                color: const Color(0xFF80CBC4),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSummaryCard(
                                icon: Icons.pending_actions_rounded,
                                label: "Izin Pending",
                                value: "$_jumlahIzinPending",
                                color: const Color(0xFFFFCC80),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSummaryCard(
                                icon: Icons.trending_up_rounded,
                                label: "Kehadiran",
                                value: "$_computedPersentase%",
                                color: const Color(0xFFA5D6A7),
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

            // ===== BODY =====
            SliverToBoxAdapter(
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: Center(child: CircularProgressIndicator(color: Color(0xFF006D5B))),
                    )
                  : Padding(
                      // Extra bottom padding for floating navbar
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Statistik Kehadiran Hari Ini
                          _buildSectionTitle("Statistik Kehadiran Hari Ini"),
                          const SizedBox(height: 14),
                          _buildAttendanceStats(),
                          const SizedBox(height: 28),

                          // Rekap Siswa Hari Ini
                          _buildSectionTitle("Rekap Absensi Siswa"),
                          const SizedBox(height: 14),
                          _buildStudentList(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== WIDGET BUILDERS =====================

  Widget _buildHeaderIconButton(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
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

  Widget _buildAttendanceStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 10,
                    child: LinearProgressIndicator(
                      value: _totalSiswa > 0 ? (_hadirCount + _telatCount) / _totalSiswa : 0,
                      backgroundColor: const Color(0xFFEEEEEE),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF006D5B)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                "$_computedPersentase%",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006D5B)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Status row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem("Hadir", _hadirCount, const Color(0xFF006D5B)),
              _buildStatItem("Telat", _telatCount, const Color(0xFFFF9800)),
              _buildStatItem("Izin/Sakit", _izinCount, const Color(0xFF2196F3)),
              _buildStatItem("Alpa", _alpaCount, const Color(0xFFF44336)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              "$count",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildStudentList() {
    if (_rekapAbsensi.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            const Text("Belum ada data absensi hari ini", style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          children: List.generate(_rekapAbsensi.length, (index) {
            final siswa = _rekapAbsensi[index];
            final status = siswa['status'] ?? 'Alpa';
            final nama = siswa['nama'] ?? '-';
            final nis = siswa['nis'] ?? '-';

            Color statusColor;
            IconData statusIcon;
            switch (status) {
              case 'Hadir':
                statusColor = const Color(0xFF006D5B);
                statusIcon = Icons.check_circle_rounded;
                break;
              case 'Telat':
                statusColor = const Color(0xFFFF9800);
                statusIcon = Icons.access_time_filled_rounded;
                break;
              case 'Izin':
              case 'Sakit':
                statusColor = const Color(0xFF2196F3);
                statusIcon = Icons.medical_services_rounded;
                break;
              default: // Alpa
                statusColor = const Color(0xFFF44336);
                statusIcon = Icons.cancel_rounded;
            }

            return Container(
              decoration: BoxDecoration(
                border: index < _rekapAbsensi.length - 1
                    ? Border(bottom: BorderSide(color: Colors.grey.shade100))
                    : null,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                leading: CircleAvatar(
                  radius: 22,
                  backgroundColor: statusColor.withOpacity(0.1),
                  child: Text(
                    nama.isNotEmpty ? nama[0].toUpperCase() : "?",
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                title: Text(
                  nama,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                subtitle: Text(
                  "NIS: $nis",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}