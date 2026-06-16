import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:platform_absensi_digital/providers/user_provider.dart';
import 'package:platform_absensi_digital/services/api_service.dart';

class RekapAbsensiPage extends StatefulWidget {
  const RekapAbsensiPage({super.key});

  @override
  State<RekapAbsensiPage> createState() => _RekapAbsensiPageState();
}

class _RekapAbsensiPageState extends State<RekapAbsensiPage> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ["Semua", "Hadir", "Izin", "Alpa"];
  String searchQuery = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Otomatis tarik data saat halaman dibuka
    _refreshData();
  }

  // --- Fungsi Tarik Data dari Database ---
  Future<void> _refreshData() async {
    setState(() => isLoading = true);
    final user = context.read<UserProvider>();
    
    final result = await ApiService.getDashboardGuru(user.userId);
    if (result['status'] == 'success') {
      user.setDashboardGuruData(
        result['data']['jumlahIzinPending'] ?? 0,
        result['data']['persentaseKehadiranKelas'] ?? 0,
        result['data']['rekapAbsensiKelas'] ?? [],
        result['data']['jadwalMengajar'] ?? []
      );
    }
    setState(() => isLoading = false);
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
    const hari = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
    return "${hari[now.weekday % 7]}, ${now.day} ${bulan[now.month - 1]} ${now.year}";
  }

  @override
  Widget build(BuildContext context) {
    final rawData = context.watch<UserProvider>().rekapAbsensiKelas;

    List<dynamic> filteredData = rawData.where((item) {
      String statusDb = item['status'] ?? 'Alpa';
      String namaSiswa = (item['nama'] ?? '').toString().toLowerCase();

      if (searchQuery.isNotEmpty && !namaSiswa.contains(searchQuery.toLowerCase())) return false;

      String filterLabel = _filters[_selectedFilterIndex];
      if (filterLabel == "Semua") return true;
      if (filterLabel == "Hadir" && (statusDb == "Hadir" || statusDb == "Telat")) return true;
      if (filterLabel == "Izin" && (statusDb == "Izin" || statusDb == "Sakit")) return true;
      if (filterLabel == "Alpa" && (statusDb == "Alpha" || statusDb == "Alpa")) return true;

      return false;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0, automaticallyImplyLeading: false,
        title: const Text("Rekap Kelas", style: TextStyle(color: Color(0xFF1E1E1E), fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: -0.5)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded, color: Color(0xFF1E1E1E)), onPressed: _refreshData),
          IconButton(icon: const Icon(Icons.file_download_outlined, color: Color(0xFF1E1E1E)), onPressed: () {}),
        ],
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF006D5B)))
        : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Container(
              decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 5))]),
              child: TextField(
                onChanged: (value) => setState(() => searchQuery = value),
                decoration: InputDecoration(
                  filled: true, fillColor: Colors.white, hintText: "Cari nama atau NIS siswa...", 
                  hintStyle: const TextStyle(color: Colors.black26, fontSize: 14), prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),
          ),
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: List.generate(_filters.length, (index) {
                bool isSelected = _selectedFilterIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilterIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200), margin: const EdgeInsets.only(right: 12), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF151B2B) : Colors.white, borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? const Color(0xFF151B2B) : Colors.grey.withOpacity(0.2)),
                      boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF151B2B).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                    ),
                    child: Text(_filters[index], style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_getTodayDate(), style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                Text("Ditampilkan: ${filteredData.length} Siswa", style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          Expanded(
            child: filteredData.isEmpty
              ? const Center(child: Text("Tidak ada data siswa", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) {
                    var dataSiswa = filteredData[index];
                    String namaSiswa = dataSiswa['nama'] ?? 'Tanpa Nama';
                    String status = dataSiswa['status'] ?? 'Alpa';
                    String waktuMasuk = _formatIsoTime(dataSiswa['jamMasuk']);
                    
                    String subtitle = "$status • $waktuMasuk";
                    if (status == 'Izin' || status == 'Sakit' || status == 'Alpha' || status == 'Alpa') {
                      subtitle = dataSiswa['keterangan'] ?? "Tidak ada keterangan";
                    } else if (status == 'Telat') {
                      status = 'Terlambat'; 
                    }

                    Color statusBg; Color statusCol;
                    if (status == 'Hadir') { statusBg = const Color(0xFFD3EADD); statusCol = const Color(0xFF006D5B); } 
                    else if (status == 'Terlambat' || status == 'Izin' || status == 'Sakit') { statusBg = const Color(0xFFFFF3E0); statusCol = const Color(0xFFEBC15B); } 
                    else { statusBg = const Color(0xFFFDE8E8); statusCol = Colors.redAccent; }

                    return _buildStudentRow(_getInitials(namaSiswa), namaSiswa, subtitle, status, statusBg, statusCol);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentRow(String initial, String name, String subtitle, String status, Color statusBg, Color statusCol) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Row(
        children: [
          Container(
            width: 50, height: 50, decoration: BoxDecoration(color: const Color(0xFFFAFAFA), shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200)),
            child: Center(child: Text(initial, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF151B2B), fontSize: 16))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E1E1E), letterSpacing: -0.3)), const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            )
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(12)),
            child: Text(status, style: TextStyle(color: statusCol, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}