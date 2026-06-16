import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:platform_absensi_digital/providers/user_provider.dart';
import 'package:platform_absensi_digital/services/api_service.dart'; // Sesuaikan path ini dengan project Anda

class IzinPage extends StatefulWidget {
  final bool openRiwayatTab; 
  const IzinPage({super.key, this.openRiwayatTab = false});

  @override
  State<IzinPage> createState() => _IzinPageState();
}

class _IzinPageState extends State<IzinPage> {
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
  final List<String> filterOptions = ['Semua', 'Hadir', 'Izin', 'Sakit', 'Terlambat'];

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

  // --- Fungsi Pilih File dari HP ---
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

  // --- Fungsi Kirim Form ke Backend ---
  Future<void> _submitIzin() async {
    if (startDate == null || endDate == null || alasanController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap lengkapi tanggal dan alasan!')));
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengajuan izin berhasil dikirim!')));
      
      // Refresh Data Dashboard Siswa
      final dashRes = await ApiService.getDashboardData(user.userId);
      if (dashRes['status'] == 'success') {
        user.setDashboardData(
          dashRes['data']['hadirBulanIni'],
          dashRes['data']['persentaseKehadiran'],
          dashRes['data']['riwayatAbsensi'],
          dashRes['data']['riwayatPerizinan'],
        );
      }

      // Reset Form & Pindah ke tab Riwayat
      setState(() {
        startDate = null; endDate = null;
        alasanController.clear();
        selectedFilePath = null; selectedFileName = null;
        isRiwayat = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Gagal mengirim izin')));
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
              primary: Color(0xFF006D5B), onPrimary: Colors.white, onSurface: Color(0xFF1E1E1E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) startDate = picked; else endDate = picked;
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
      List<String> bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
      return "${dt.day} ${bulan[dt.month - 1]} ${dt.year}";
    } catch (e) { return "-"; }
  }

  String _formatIsoTime(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return "-";
    try {
      DateTime dt = DateTime.parse(isoDate).toLocal();
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) { return "-"; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E1E1E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isRiwayat ? "Riwayat Absensi" : "Perizinan", 
          style: const TextStyle(color: Color(0xFF1E1E1E), fontWeight: FontWeight.bold, fontSize: 22)),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10), padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15)),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isRiwayat = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(color: isRiwayat ? const Color(0xFF006D5B) : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      child: Text("Riwayat", style: TextStyle(fontWeight: FontWeight.bold, color: isRiwayat ? Colors.white : Colors.grey[600])),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isRiwayat = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(color: !isRiwayat ? const Color(0xFF006D5B) : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      child: Text("Perizinan", style: TextStyle(fontWeight: FontWeight.bold, color: !isRiwayat ? Colors.white : Colors.grey[600])),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: isRiwayat ? _buildRiwayatContent(context) : _buildIzinContent(context),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // KONTEN TAB: PERIZINAN (DINAMIS & FORM UPLOAD)
  // ==========================================
  Widget _buildIzinContent(BuildContext context) {
    final List<dynamic> daftarIzin = context.watch<UserProvider>().riwayatPerizinan;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Ajukan Izin Baru", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
        const SizedBox(height: 15),

        // Tanggal
        Row(
          children: [
            Expanded(child: _buildDatePickerBox("Mulai", startDate, () => _selectDate(context, true))),
            const SizedBox(width: 15),
            Expanded(child: _buildDatePickerBox("Selesai", endDate, () => _selectDate(context, false))),
          ],
        ),
        const SizedBox(height: 15),

        // Jenis Izin
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.withOpacity(0.2))),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: jenisIzin,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF006D5B)),
              items: <String>['Sakit', 'Kepentingan'].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)));
              }).toList(),
              onChanged: (String? newValue) { setState(() { jenisIzin = newValue!; }); },
            ),
          ),
        ),
        const SizedBox(height: 15),

        // Alasan
        TextField(
          controller: alasanController, maxLines: 3,
          decoration: InputDecoration(
            hintText: "Tuliskan alasan lengkap...",
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            filled: true, fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF006D5B))),
          ),
        ),
        const SizedBox(height: 15),

        // Unggah Dokumen
        GestureDetector(
          onTap: _pickFile,
          child: Container(
            width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), border: Border.all(color: const Color(0xFF006D5B).withOpacity(0.2), width: 2)),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: selectedFileName == null ? const Color(0xFFE8F3F1) : const Color(0xFFD3EADD), shape: BoxShape.circle),
                  child: Icon(selectedFileName == null ? Icons.cloud_upload_rounded : Icons.check_circle_rounded, size: 36, color: const Color(0xFF006D5B)),
                ),
                const SizedBox(height: 15),
                Text(selectedFileName ?? "Unggah Dokumen Pendukung", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)), textAlign: TextAlign.center),
                const SizedBox(height: 5),
                if (selectedFileName == null) const Text("Ketuk untuk memilih PDF atau Gambar", style: TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Tombol Submit
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: isSubmitting ? null : _submitIzin,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF151B2B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: isSubmitting 
              ? const CircularProgressIndicator(color: Colors.white) 
              : const Text("Kirim Pengajuan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 35),

        const Text("Status Pengajuan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
        const SizedBox(height: 15),

        daftarIzin.isEmpty 
          ? const Center(child: Text("Belum ada riwayat pengajuan izin", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              itemCount: daftarIzin.length,
              itemBuilder: (context, index) {
                var izin = daftarIzin[index];
                Color bgWarna = const Color(0xFFFFF3E0); Color textWarna = const Color(0xFFEBC15B);
                if (izin['status'] == 'Disetujui') { bgWarna = const Color(0xFFD3EADD); textWarna = const Color(0xFF006D5B); } 
                else if (izin['status'] == 'Ditolak') { bgWarna = const Color(0xFFFFEBEE); textWarna = Colors.redAccent; }
                return _buildIzinStatusItem("Izin ${izin['jenisIzin']}", "Dibuat: ${_formatIsoDateToID(izin['createdAt'])}", izin['status'], bgWarna, textWarna);
              },
            ),
      ],
    );
  }

  // ==========================================
  // KONTEN TAB: RIWAYAT (GABUNGAN ABSENSI & IZIN)
  // ==========================================
  Widget _buildRiwayatContent(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final List<dynamic> absensi = userProvider.riwayatAbsensi;
    final List<dynamic> perizinan = userProvider.riwayatPerizinan;

    // 1. Gabungkan Data Absensi & Perizinan
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
        'status': p['status'] == 'Pending' ? 'Menunggu' : (p['status'] == 'Disetujui' ? 'Izin (${p['jenisIzin']})' : 'Ditolak'),
      });
    }

    // 2. Urutkan dari yang terbaru
    combinedRiwayat.sort((a, b) => DateTime.parse(b['tanggal']).compareTo(DateTime.parse(a['tanggal'])));

    // 3. Filter data
    final List<Map<String, dynamic>> riwayatTerfilter = combinedRiwayat.where((item) {
      if (activeFilters.contains('Semua')) return true;
      String statusDb = item['status'] == 'Telat' ? 'Terlambat' : item['status'];
      
      if (statusDb.contains('Izin') || statusDb == 'Menunggu') {
        return activeFilters.contains('Izin') || activeFilters.contains('Sakit');
      }
      return activeFilters.contains(statusDb);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Filter Bulan Ini", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filterOptions.map((filter) {
              final isActive = activeFilters.contains(filter);
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: FilterChip(
                  label: Text(filter, style: TextStyle(color: isActive ? Colors.white : Colors.grey[700], fontWeight: FontWeight.bold, fontSize: 13)),
                  selected: isActive,
                  onSelected: (selected) {
                    setState(() {
                      if (filter == 'Semua') { activeFilters = ['Semua']; } else {
                        activeFilters.remove('Semua');
                        if (selected) activeFilters.add(filter); else activeFilters.remove(filter);
                        if (activeFilters.isEmpty) activeFilters.add('Semua');
                      }
                    });
                  },
                  backgroundColor: Colors.white, selectedColor: const Color(0xFF006D5B), checkmarkColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey.withOpacity(0.2))),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 25),

        riwayatTerfilter.isEmpty 
          ? const Center(child: Text("Tidak ada riwayat aktivitas", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              itemCount: riwayatTerfilter.length,
              itemBuilder: (context, index) {
                var item = riwayatTerfilter[index];
                Color bgWarna; Color textWarna;
                String statusLabel = item['status'];
                IconData icon;

                if (statusLabel == 'Hadir') { 
                  bgWarna = const Color(0xFFD3EADD); textWarna = const Color(0xFF006D5B); icon = Icons.check_rounded;
                } else if (statusLabel == 'Telat' || statusLabel == 'Terlambat') { 
                  statusLabel = 'Terlambat'; bgWarna = const Color(0xFFFFF3E0); textWarna = const Color(0xFFEBC15B); icon = Icons.access_time_filled_rounded;
                } else if (statusLabel == 'Menunggu') {
                  bgWarna = const Color(0xFFFFF3E0); textWarna = const Color(0xFFEBC15B); icon = Icons.hourglass_top_rounded;
                } else if (statusLabel.contains('Izin')) {
                  bgWarna = const Color(0xFFE8F3F1); textWarna = Colors.blue; icon = Icons.info_rounded;
                } else {
                  // Alpha / Ditolak
                  bgWarna = const Color(0xFFFFEBEE); textWarna = Colors.redAccent; icon = Icons.close_rounded;
                }

                return _buildRiwayatCard(_formatIsoDateToID(item['tanggal']), _formatIsoTime(item['jamMasuk']), statusLabel, bgWarna, textWarna, icon);
              },
            ),
      ],
    );
  }

  Widget _buildDatePickerBox(String label, DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.withOpacity(0.2))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDate(date), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E1E1E))),
                const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF006D5B)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIzinStatusItem(String title, String fileName, String statusText, Color bgStatus, Color textStatus) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.description_rounded, color: Colors.blueAccent, size: 24)),
          const SizedBox(width: 15),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E1E1E))), const SizedBox(height: 4), Text(fileName, style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis)])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: bgStatus, borderRadius: BorderRadius.circular(12)), child: Text(statusText, style: TextStyle(color: textStatus, fontWeight: FontWeight.bold, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildRiwayatCard(String date, String time, String status, Color bgStatus, Color textStatus, IconData customIcon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: bgStatus, shape: BoxShape.circle), child: Icon(customIcon, color: textStatus, size: 20)),
              const SizedBox(width: 15),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), const SizedBox(height: 4), Text("Masuk: $time", style: const TextStyle(color: Colors.grey, fontSize: 13))]),
            ],
          ),
          Text(status, style: TextStyle(color: textStatus, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}