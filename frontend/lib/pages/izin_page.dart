import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:platform_absensi_digital/providers/user_provider.dart';
import 'package:platform_absensi_digital/services/api_service.dart';
import 'package:platform_absensi_digital/widgets/custom_popup.dart';

class IzinPage extends StatefulWidget {
  final bool openRiwayatTab;
  const IzinPage({super.key, this.openRiwayatTab = false});

  @override
  State<IzinPage> createState() => _IzinPageState();
}

class _IzinPageState extends State<IzinPage>
    with SingleTickerProviderStateMixin {
  late bool isRiwayat;

  // --- Variabel Form ---
  DateTime? startDate;
  DateTime? endDate;
  String jenisIzin = 'Sakit';
  TextEditingController alasanController = TextEditingController();

  // --- Variabel File Upload ---
  String? selectedFilePath;
  String? selectedFileName;
  bool isSubmitting = false;

  List<String> activeFilters = ['Semua'];
  final List<String> filterOptions = [
    'Semua',
    'Hadir',
    'Izin',
    'Sakit',
    'Terlambat'
  ];

  @override
  void initState() {
    super.initState();
    isRiwayat = widget.openRiwayatTab;
  }

  @override
  void dispose() {
    alasanController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null) {
      setState(() {
        selectedFilePath = result.files.single.path;
        selectedFileName = result.files.single.name;
      });
    }
  }

  Future<void> _submitIzin() async {
    if (startDate == null ||
        endDate == null ||
        alasanController.text.trim().isEmpty) {
      CustomPopup.show(
        context,
        message: 'Harap lengkapi tanggal dan alasan!',
        type: PopupType.warning,
      );
      return;
    }
    setState(() => isSubmitting = true);
    final user = context.read<UserProvider>();
    final result = await ApiService.ajukanIzin(
      userId: user.userId,
      tanggalMulai: startDate!.toIso8601String(),
      tanggalSelesai: endDate!.toIso8601String(),
      jenisIzin: jenisIzin,
      alasan: alasanController.text,
      filePath: selectedFilePath,
    );
    setState(() => isSubmitting = false);

    if (result['status'] == 'success') {
      CustomPopup.show(
        context,
        message: 'Pengajuan izin berhasil dikirim!',
        type: PopupType.success,
      );
      final dashRes = await ApiService.getDashboardData(user.userId);
      if (dashRes['status'] == 'success') {
        user.setDashboardData(
          dashRes['data']['hadirBulanIni'],
          dashRes['data']['persentaseKehadiran'],
          dashRes['data']['riwayatAbsensi'],
          dashRes['data']['riwayatPerizinan'],
          jadwal: dashRes['data']['jadwalAktif'] ?? [],
          geofence: dashRes['data']['geofence'],
        );
      }
      setState(() {
        startDate = null;
        endDate = null;
        alasanController.clear();
        selectedFilePath = null;
        selectedFileName = null;
        isRiwayat = true;
      });
    } else {
      CustomPopup.show(
        context,
        message: result['message'] ?? 'Gagal mengirim izin',
        type: PopupType.error,
      );
    }
  }

  Future<void> _refreshData() async {
    final user = context.read<UserProvider>();
    try {
      final dashRes = await ApiService.getDashboardData(user.userId);
      if (dashRes['status'] == 'success' && mounted) {
        user.setDashboardData(
          dashRes['data']['hadirBulanIni'],
          dashRes['data']['persentaseKehadiran'],
          dashRes['data']['riwayatAbsensi'],
          dashRes['data']['riwayatPerizinan'],
          jadwal: dashRes['data']['jadwalAktif'] ?? [],
          geofence: dashRes['data']['geofence'],
        );
      } else {
        throw Exception('Gagal memuat data dari server');
      }
    } catch (e) {
      if (mounted) {
        CustomPopup.show(
          context,
          message: 'Gagal memperbarui data: ${e.toString()}',
          type: PopupType.error,
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF006D5B),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E1E1E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) startDate = picked;
        else endDate = picked;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Pilih Tanggal";
    return "${date.day}/${date.month}/${date.year}";
  }

  String _formatIsoDateToID(String isoDate) {
    try {
      DateTime dt = DateTime.parse(isoDate).toLocal();
      List<String> bulan = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return "${dt.day} ${bulan[dt.month - 1]} ${dt.year}";
    } catch (e) {
      return "-";
    }
  }

  String _formatIsoTime(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return "-";
    try {
      DateTime dt = DateTime.parse(isoDate);
      return "${dt.toUtc().hour.toString().padLeft(2, '0')}:${dt.toUtc().minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // ===== HEADER =====
          Container(
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
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button & title
                    Row(
                      children: [
                        if (Navigator.canPop(context))
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        if (Navigator.canPop(context))
                          const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            isRiwayat
                                ? Icons.history_rounded
                                : Icons.edit_note_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isRiwayat ? "Riwayat Absensi" : "Perizinan",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              isRiwayat
                                  ? "Rekap kehadiran Anda"
                                  : "Ajukan permohonan izin",
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Tab Switcher
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isRiwayat = true),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 11),
                                decoration: BoxDecoration(
                                  color: isRiwayat
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Riwayat",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isRiwayat
                                        ? const Color(0xFF006D5B)
                                        : Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isRiwayat = false),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 11),
                                decoration: BoxDecoration(
                                  color: !isRiwayat
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Perizinan",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: !isRiwayat
                                        ? const Color(0xFF006D5B)
                                        : Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ===== CONTENT =====
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              color: const Color(0xFF006D5B),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
                child: isRiwayat
                    ? _buildRiwayatContent(context)
                    : _buildIzinContent(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================================================
  // TAB PERIZINAN
  // ===================================================
  Widget _buildIzinContent(BuildContext context) {
    final List<dynamic> daftarIzin =
        context.watch<UserProvider>().riwayatPerizinan;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Form Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.assignment_rounded,
                      color: Color(0xFF006D5B), size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Formulir Pengajuan Izin",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Tanggal
              const Text("Periode Izin",
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildDatePickerBox(
                        "Mulai", startDate, () => _selectDate(context, true)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text("—",
                        style: TextStyle(color: Colors.grey.shade400)),
                  ),
                  Expanded(
                    child: _buildDatePickerBox(
                        "Selesai", endDate, () => _selectDate(context, false)),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Jenis Izin
              const Text("Jenis Izin",
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: jenisIzin,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF006D5B)),
                    items: <String>['Sakit', 'Kepentingan'].map((String v) {
                      return DropdownMenuItem<String>(
                        value: v,
                        child: Text(v,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() => jenisIzin = newValue!);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Alasan
              const Text("Alasan",
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
              const SizedBox(height: 8),
              TextField(
                controller: alasanController,
                maxLines: 3,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Tuliskan alasan secara lengkap...",
                  hintStyle:
                      const TextStyle(color: Colors.black38, fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFFF5F7FA),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: Color(0xFF006D5B), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Upload
              const Text("Dokumen Pendukung",
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickFile,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 24, horizontal: 20),
                  decoration: BoxDecoration(
                    color: selectedFileName != null
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selectedFileName != null
                          ? const Color(0xFF006D5B).withOpacity(0.4)
                          : Colors.grey.shade200,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: selectedFileName != null
                              ? const Color(0xFF006D5B).withOpacity(0.1)
                              : Colors.grey.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          selectedFileName != null
                              ? Icons.check_circle_rounded
                              : Icons.cloud_upload_rounded,
                          size: 32,
                          color: selectedFileName != null
                              ? const Color(0xFF006D5B)
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        selectedFileName ?? "Ketuk untuk unggah file",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: selectedFileName != null
                              ? const Color(0xFF006D5B)
                              : const Color(0xFF1E1E1E),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      if (selectedFileName == null)
                        const Text("PDF, JPG, atau PNG",
                            style:
                                TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.send_rounded,
                          color: Colors.white, size: 18),
                  label: Text(
                    isSubmitting ? "Mengirim..." : "Kirim Pengajuan",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  onPressed: isSubmitting ? null : _submitIzin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006D5B),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Status Pengajuan
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 14),
          child: Text(
            "STATUS PENGAJUAN",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.5,
            ),
          ),
        ),
        daftarIzin.isEmpty
            ? _buildEmptyState(
                Icons.inbox_rounded, "Belum ada riwayat pengajuan izin")
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: daftarIzin.length,
                itemBuilder: (context, index) {
                  var izin = daftarIzin[index];
                  Color bgWarna = const Color(0xFFFFF3E0);
                  Color textWarna = const Color(0xFFE65100);
                  IconData statusIcon = Icons.hourglass_empty_rounded;

                  if (izin['status'] == 'Disetujui') {
                    bgWarna = const Color(0xFFE8F5E9);
                    textWarna = const Color(0xFF006D5B);
                    statusIcon = Icons.check_circle_rounded;
                  } else if (izin['status'] == 'Ditolak') {
                    bgWarna = const Color(0xFFFFEBEE);
                    textWarna = const Color(0xFFC62828);
                    statusIcon = Icons.cancel_rounded;
                  }

                  String dateRange =
                      "${_formatIsoDateToID(izin['tanggalMulai'])} - ${_formatIsoDateToID(izin['tanggalSelesai'])}";
                  String submissionDate =
                      "Diajukan: ${_formatIsoDateToID(izin['createdAt'])}";

                  return _buildIzinStatusItem(
                    "Izin ${izin['jenisIzin']}",
                    dateRange,
                    submissionDate,
                    izin['status'],
                    bgWarna,
                    textWarna,
                    statusIcon,
                  );
                },
              ),
      ],
    );
  }

  // ===================================================
  // TAB RIWAYAT
  // ===================================================
  Widget _buildRiwayatContent(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final List<dynamic> absensi = userProvider.riwayatAbsensi;
    final List<dynamic> perizinan = userProvider.riwayatPerizinan;

    List<Map<String, dynamic>> combinedRiwayat = [];
    for (var a in absensi) {
      combinedRiwayat.add({
        'tanggal': a['tanggal'],
        'jamMasuk': a['jamMasuk'],
        'status': a['status'],
      });
    }
    for (var p in perizinan) {
      combinedRiwayat.add({
        'tanggal': p['createdAt'],
        'jamMasuk': null,
        'status': p['status'] == 'Pending'
            ? 'Menunggu'
            : (p['status'] == 'Disetujui'
                ? 'Izin (${p['jenisIzin']})'
                : 'Ditolak'),
      });
    }

    combinedRiwayat.sort((a, b) =>
        DateTime.parse(b['tanggal']).compareTo(DateTime.parse(a['tanggal'])));

    final List<Map<String, dynamic>> riwayatTerfilter =
        combinedRiwayat.where((item) {
      if (activeFilters.contains('Semua')) return true;
      String statusDb =
          item['status'] == 'Telat' ? 'Terlambat' : item['status'];
      if (statusDb.contains('Izin') || statusDb == 'Menunggu') {
        return activeFilters.contains('Izin') ||
            activeFilters.contains('Sakit');
      }
      return activeFilters.contains(statusDb);
    }).toList();

    // Hitung stats
    int hadirCount =
        absensi.where((a) => a['status'] == 'Hadir').length;
    int izinCount =
        perizinan.where((p) => p['status'] == 'Disetujui').length;
    int alpaCount = absensi
        .where((a) => a['status'] == 'Alpa' || a['status'] == 'Alpha')
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats row
        Row(
          children: [
            Expanded(
                child: _buildStatCard(
                    "$hadirCount", "Hadir", const Color(0xFF006D5B),
                    const Color(0xFFE8F5E9))),
            const SizedBox(width: 12),
            Expanded(
                child: _buildStatCard(
                    "$izinCount", "Izin", const Color(0xFF1565C0),
                    const Color(0xFFE3F2FD))),
            const SizedBox(width: 12),
            Expanded(
                child: _buildStatCard(
                    "$alpaCount", "Alpa", const Color(0xFFC62828),
                    const Color(0xFFFFEBEE))),
          ],
        ),
        const SizedBox(height: 24),

        // Filter chips
        const Text(
          "FILTER",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filterOptions.map((filter) {
              final isActive = activeFilters.contains(filter);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (filter == 'Semua') {
                        activeFilters = ['Semua'];
                      } else {
                        activeFilters.remove('Semua');
                        if (isActive) {
                          activeFilters.remove(filter);
                        } else {
                          activeFilters.add(filter);
                        }
                        if (activeFilters.isEmpty) activeFilters.add('Semua');
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 9),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF006D5B)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isActive
                            ? const Color(0xFF006D5B)
                            : Colors.grey.shade200,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: const Color(0xFF006D5B)
                                    .withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [],
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color:
                            isActive ? Colors.white : Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),

        // List
        riwayatTerfilter.isEmpty
            ? _buildEmptyState(Icons.inbox_rounded, "Tidak ada riwayat aktivitas")
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: riwayatTerfilter.length,
                itemBuilder: (context, index) {
                  var item = riwayatTerfilter[index];
                  Color bgWarna;
                  Color textWarna;
                  String statusLabel = item['status'];
                  IconData icon;

                  if (statusLabel == 'Hadir') {
                    bgWarna = const Color(0xFFE8F5E9);
                    textWarna = const Color(0xFF006D5B);
                    icon = Icons.check_circle_rounded;
                  } else if (statusLabel == 'Telat' ||
                      statusLabel == 'Terlambat') {
                    statusLabel = 'Terlambat';
                    bgWarna = const Color(0xFFFFF3E0);
                    textWarna = const Color(0xFFE65100);
                    icon = Icons.access_time_filled_rounded;
                  } else if (statusLabel == 'Menunggu') {
                    bgWarna = const Color(0xFFFFF3E0);
                    textWarna = const Color(0xFFE65100);
                    icon = Icons.hourglass_top_rounded;
                  } else if (statusLabel.contains('Izin')) {
                    bgWarna = const Color(0xFFE3F2FD);
                    textWarna = const Color(0xFF1565C0);
                    icon = Icons.medical_services_rounded;
                  } else {
                    bgWarna = const Color(0xFFFFEBEE);
                    textWarna = const Color(0xFFC62828);
                    icon = Icons.cancel_rounded;
                  }

                  return _buildRiwayatCard(
                    _formatIsoDateToID(item['tanggal']),
                    _formatIsoTime(item['jamMasuk']),
                    statusLabel,
                    bgWarna,
                    textWarna,
                    icon,
                  );
                },
              ),
      ],
    );
  }

  Widget _buildStatCard(
      String value, String label, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(color: color.withOpacity(0.7), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(text, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerBox(
      String label, DateTime? date, VoidCallback onTap) {
    final bool hasPicked = date != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: hasPicked
              ? const Color(0xFF006D5B).withOpacity(0.06)
              : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasPicked
                ? const Color(0xFF006D5B).withOpacity(0.3)
                : Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: hasPicked
                        ? const Color(0xFF006D5B)
                        : Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(date),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: hasPicked
                        ? const Color(0xFF1E1E1E)
                        : Colors.grey,
                  ),
                ),
                Icon(Icons.calendar_today_rounded,
                    size: 14,
                    color: hasPicked
                        ? const Color(0xFF006D5B)
                        : Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIzinStatusItem(
    String title,
    String dateRange,
    String submissionDate,
    String statusText,
    Color bgStatus,
    Color textStatus,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
                color: bgStatus, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: textStatus, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1E1E1E))),
                const SizedBox(height: 3),
                Text(dateRange,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(submissionDate,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: bgStatus, borderRadius: BorderRadius.circular(10)),
            child: Text(statusText,
                style: TextStyle(
                    color: textStatus,
                    fontWeight: FontWeight.bold,
                    fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatCard(String date, String time, String status,
      Color bgStatus, Color textStatus, IconData customIcon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgStatus,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(customIcon, color: textStatus, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1E1E1E))),
                const SizedBox(height: 3),
                Text("Jam Masuk: $time",
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: bgStatus,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(status,
                style: TextStyle(
                    color: textStatus,
                    fontWeight: FontWeight.bold,
                    fontSize: 11)),
          ),
        ],
      ),
    );
  }
}