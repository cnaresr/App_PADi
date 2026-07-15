import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:platform_absensi_digital/providers/user_provider.dart';
import 'package:platform_absensi_digital/services/api_service.dart';

class RekapAbsensiPage extends StatefulWidget {
  const RekapAbsensiPage({super.key});

  @override
  State<RekapAbsensiPage> createState() => _RekapAbsensiPageState();
}

class _RekapAbsensiPageState extends State<RekapAbsensiPage>
    with SingleTickerProviderStateMixin {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ["Semua", "Hadir", "Izin", "Alpa"];
  String searchQuery = "";
  bool isLoading = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _animController.forward();
    _refreshData();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    final user = context.read<UserProvider>();
    final hasData = user.rekapAbsensiKelas.isNotEmpty;
    if (!hasData) {
      setState(() => isLoading = true);
    }
    final result = await ApiService.getDashboardGuru(user.userId);
    if (result['status'] == 'success') {
      user.setGuruDashboardData(
        result['data']['jumlahIzinPending'] ?? 0,
        result['data']['persentaseKehadiranKelas'] ?? 0,
        result['data']['rekapAbsensiKelas'] ?? [],
        result['data']['jadwalMengajar'] ?? [],
      );
    }
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  String _formatIsoTime(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return "-";
    try {
      DateTime dt = DateTime.parse(isoDate).toLocal();
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} WIB";
    } catch (e) {
      return "-";
    }
  }

  String _getInitials(String name) {
    List<String> names = name.split(" ");
    String initials = "";
    int numWords = names.length > 2 ? 2 : names.length;
    for (int i = 0; i < numWords; i++) {
      if (names[i].isNotEmpty) initials += names[i][0].toUpperCase();
    }
    return initials;
  }

  String _getTodayDate() {
    final now = DateTime.now();
    const hari = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu'
    ];
    const bulan = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return "${hari[now.weekday % 7]}, ${now.day} ${bulan[now.month - 1]} ${now.year}";
  }

  @override
  Widget build(BuildContext context) {
    final rawData = context.watch<UserProvider>().rekapAbsensiKelas;

    List<dynamic> filteredData = rawData.where((item) {
      String statusDb = item['status'] ?? 'Alpa';
      String namaSiswa = (item['nama'] ?? '').toString().toLowerCase();
      if (searchQuery.isNotEmpty &&
          !namaSiswa.contains(searchQuery.toLowerCase())) {
        return false;
      }
      String filterLabel = _filters[_selectedFilterIndex];
      if (filterLabel == "Semua") {
        return true;
      }
      if (filterLabel == "Hadir" &&
          (statusDb == "Hadir" || statusDb == "Telat")) {
        return true;
      }
      if (filterLabel == "Izin" &&
          (statusDb == "Izin" || statusDb == "Sakit")) {
        return true;
      }
      if (filterLabel == "Alpa" &&
          (statusDb == "Alpha" || statusDb == "Alpa")) {
        return true;
      }
      return false;
    }).toList();

    int hadirCount = rawData
        .where((s) => s['status'] == 'Hadir' || s['status'] == 'Telat')
        .length;
    int izinCount = rawData
        .where((s) => s['status'] == 'Izin' || s['status'] == 'Sakit')
        .length;
    int alpaCount = rawData
        .where((s) => s['status'] == 'Alpa' || s['status'] == 'Alpha')
        .length;
    int total = rawData.length;
    int persentase = total > 0 ? ((hadirCount / total) * 100).round() : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        color: const Color(0xFF006D5B),
        onRefresh: _refreshData,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF006D5B)))
            : CustomScrollView(
                slivers: [
                  // ===== HEADER =====
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
                              // Title bar
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                        Icons.bar_chart_rounded,
                                        color: Colors.white,
                                        size: 22),
                                  ),
                                  const SizedBox(width: 14),
                                  const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Rekap Absensi",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      Text(
                                        "Data kehadiran kelas Anda",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Stats summary in header
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.13),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.15)),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            child: SizedBox(
                                              height: 8,
                                              child: LinearProgressIndicator(
                                                value: total > 0
                                                    ? hadirCount / total
                                                    : 0,
                                                backgroundColor: Colors.white
                                                    .withValues(alpha: 0.2),
                                                valueColor:
                                                    const AlwaysStoppedAnimation(
                                                        Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Text(
                                          "$persentase%",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildHeaderStat(
                                            "$total", "Total", Colors.white70),
                                        _buildHeaderStat("$hadirCount",
                                            "Hadir", const Color(0xFFA5D6A7)),
                                        _buildHeaderStat(
                                            "$izinCount",
                                            "Izin/Sakit",
                                            const Color(0xFF80CBC4)),
                                        _buildHeaderStat("$alpaCount", "Alpa",
                                            const Color(0xFFEF9A9A)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Center(
                                child: Text(
                                  _getTodayDate(),
                                  style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.6),
                                      fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ===== SEARCH & FILTER =====
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search bar
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: TextField(
                              onChanged: (v) =>
                                  setState(() => searchQuery = v),
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: "Cari nama siswa...",
                                hintStyle: const TextStyle(
                                    color: Colors.black38, fontSize: 14),
                                prefixIcon: const Icon(
                                    Icons.search_rounded,
                                    color: Color(0xFF006D5B),
                                    size: 22),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Filter chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(_filters.length, (i) {
                                bool sel = _selectedFilterIndex == i;
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedFilterIndex = i),
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.only(right: 10),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: sel
                                          ? const Color(0xFF006D5B)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: sel
                                            ? const Color(0xFF006D5B)
                                            : Colors.grey.shade200,
                                      ),
                                      boxShadow: sel
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF006D5B)
                                                    .withValues(alpha: 0.3),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              )
                                            ]
                                          : [],
                                    ),
                                    child: Text(
                                      _filters[i],
                                      style: TextStyle(
                                        color: sel
                                            ? Colors.white
                                            : Colors.grey.shade600,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Count row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Daftar Siswa",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF1E1E1E),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF006D5B)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "${filteredData.length} Siswa",
                                  style: const TextStyle(
                                    color: Color(0xFF006D5B),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ===== STUDENT LIST =====
                  if (filteredData.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_rounded,
                                size: 56, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            const Text("Tidak ada data siswa",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 15)),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final dataSiswa = filteredData[index];
                            String namaSiswa =
                                dataSiswa['nama'] ?? 'Tanpa Nama';
                            String status = dataSiswa['status'] ?? 'Alpa';
                            String waktuMasuk =
                                _formatIsoTime(dataSiswa['jamMasuk']);
                            String subtitle = "$status • $waktuMasuk";
                            if (status == 'Izin' ||
                                status == 'Sakit' ||
                                status == 'Alpha' ||
                                status == 'Alpa') {
                              subtitle = dataSiswa['keterangan'] ??
                                  "Tidak ada keterangan";
                            } else if (status == 'Telat') {
                              status = 'Terlambat';
                            }

                            Color statusBg, statusCol, avatarBg;
                            IconData statusIcon;
                            if (status == 'Hadir') {
                              statusBg = const Color(0xFFE8F5E9);
                              statusCol = const Color(0xFF006D5B);
                              avatarBg = const Color(0xFF006D5B);
                              statusIcon = Icons.check_circle_rounded;
                            } else if (status == 'Terlambat') {
                              statusBg = const Color(0xFFFFF3E0);
                              statusCol = const Color(0xFFE65100);
                              avatarBg = const Color(0xFFE65100);
                              statusIcon = Icons.access_time_filled_rounded;
                            } else if (status == 'Izin' || status == 'Sakit') {
                              statusBg = const Color(0xFFE3F2FD);
                              statusCol = const Color(0xFF1565C0);
                              avatarBg = const Color(0xFF1565C0);
                              statusIcon = Icons.medical_services_rounded;
                            } else {
                              statusBg = const Color(0xFFFFEBEE);
                              statusCol = const Color(0xFFC62828);
                              avatarBg = const Color(0xFFC62828);
                              statusIcon = Icons.cancel_rounded;
                            }

                            return AnimatedOpacity(
                              opacity: 1,
                              duration: Duration(
                                  milliseconds: 200 + (index * 40)),
                              child: _buildStudentCard(
                                  _getInitials(namaSiswa),
                                  namaSiswa,
                                  subtitle,
                                  status,
                                  statusBg,
                                  statusCol,
                                  avatarBg,
                                  statusIcon,
                                  index),
                            );
                          },
                          childCount: filteredData.length,
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeaderStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65), fontSize: 11)),
      ],
    );
  }

  Widget _buildStudentCard(
    String initial,
    String name,
    String subtitle,
    String status,
    Color statusBg,
    Color statusCol,
    Color avatarBg,
    IconData statusIcon,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with number
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: avatarBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: statusBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Icon(statusIcon, color: statusCol, size: 12),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // Name & subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1E1E1E),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Status badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusCol,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}