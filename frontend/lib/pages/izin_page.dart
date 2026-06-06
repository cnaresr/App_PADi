import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:platform_absensi_digital/providers/user_provider.dart';

class IzinPage extends StatefulWidget {
  final bool openRiwayatTab; 
  const IzinPage({super.key, this.openRiwayatTab = false});

  @override
  State<IzinPage> createState() => _IzinPageState();
}

class _IzinPageState extends State<IzinPage> {
  late bool isRiwayat;
  DateTime? startDate;
  DateTime? endDate;

  List<String> activeFilters = ['Semua'];
  final List<String> filterOptions = ['Semua', 'Hadir', 'Izin', 'Sakit', 'Terlambat'];

  @override
  void initState() {
    super.initState();
    isRiwayat = widget.openRiwayatTab;
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
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  // --- Fungsi Bantuan Pengubah Format Tanggal & Jam ---
  String _formatDate(DateTime? date) {
    if (date == null) return "Pilih Tanggal";
    return "${date.day}/${date.month}/${date.year}";
  }

  String _formatIsoDateToID(String isoDate) {
    try {
      DateTime dt = DateTime.parse(isoDate).toLocal();
      List<String> bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
      return "${dt.day} ${bulan[dt.month - 1]} ${dt.year}";
    } catch (e) {
      return "-";
    }
  }

  String _formatIsoTime(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return "-";
    try {
      DateTime dt = DateTime.parse(isoDate).toLocal();
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "-";
    }
  }
  // ----------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E1E1E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isRiwayat ? "Riwayat Absensi" : "Perizinan", 
          style: const TextStyle(color: Color(0xFF1E1E1E), fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isRiwayat = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isRiwayat ? const Color(0xFF006D5B) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Riwayat",
                        style: TextStyle(fontWeight: FontWeight.bold, color: isRiwayat ? Colors.white : Colors.grey[600]),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isRiwayat = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !isRiwayat ? const Color(0xFF006D5B) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Perizinan",
                        style: TextStyle(fontWeight: FontWeight.bold, color: !isRiwayat ? Colors.white : Colors.grey[600]),
                      ),
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
  // KONTEN TAB: PERIZINAN (DINAMIS)
  // ==========================================
  Widget _buildIzinContent(BuildContext context) {
    // Tarik daftar izin dari Provider
    final List<dynamic> daftarIzin = context.watch<UserProvider>().riwayatPerizinan;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Ajukan Izin Baru", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
        const SizedBox(height: 15),

        Row(
          children: [
            Expanded(
              child: _buildDatePickerBox("Mulai", startDate, () => _selectDate(context, true)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildDatePickerBox("Selesai", endDate, () => _selectDate(context, false)),
            ),
          ],
        ),
        const SizedBox(height: 15),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFF006D5B).withOpacity(0.2), width: 2),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: Color(0xFFE8F3F1), shape: BoxShape.circle),
                child: const Icon(Icons.cloud_upload_rounded, size: 36, color: Color(0xFF006D5B)),
              ),
              const SizedBox(height: 15),
              const Text("Unggah Dokumen Pendukung", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
              const SizedBox(height: 5),
              const Text("Format PDF atau Gambar (Surat Dokter)", style: TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
            ],
          ),
        ),
        const SizedBox(height: 35),

        const Text("Status Pengajuan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
        const SizedBox(height: 15),

        // Pencetak Kartu Izin Otomatis
        daftarIzin.isEmpty 
          ? const Center(child: Text("Belum ada riwayat pengajuan izin", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Scroll mengikuti halaman utama
              itemCount: daftarIzin.length,
              itemBuilder: (context, index) {
                var izin = daftarIzin[index];
                
                // Menentukan warna berdasarkan status di database
                Color bgWarna;
                Color textWarna;
                if (izin['status'] == 'Disetujui') {
                  bgWarna = const Color(0xFFD3EADD); textWarna = const Color(0xFF006D5B);
                } else if (izin['status'] == 'Ditolak') {
                  bgWarna = const Color(0xFFFFEBEE); textWarna = Colors.redAccent;
                } else {
                  bgWarna = const Color(0xFFFFF3E0); textWarna = const Color(0xFFEBC15B); // Pending
                }

                return _buildIzinStatusItem(
                  "Izin ${izin['jenisIzin']}",
                  "Dibuat: ${_formatIsoDateToID(izin['createdAt'])}",
                  izin['status'],
                  bgWarna,
                  textWarna,
                );
              },
            ),
      ],
    );
  }

  // ==========================================
  // KONTEN TAB: RIWAYAT (DINAMIS & TERFILTER)
  // ==========================================
  Widget _buildRiwayatContent(BuildContext context) {
    // Tarik daftar riwayat mentah dari Provider
    final List<dynamic> daftarRiwayat = context.watch<UserProvider>().riwayatAbsensi;

    // Proses Filtering Array Data
    final List<dynamic> riwayatTerfilter = daftarRiwayat.where((item) {
      if (activeFilters.contains('Semua')) return true;
      // Menyamakan kata 'Telat' dari database ke 'Terlambat' di filter UI
      String statusDb = item['status'] == 'Telat' ? 'Terlambat' : item['status'];
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
                      if (filter == 'Semua') {
                        activeFilters = ['Semua'];
                      } else {
                        activeFilters.remove('Semua');
                        if (selected) {
                          activeFilters.add(filter);
                        } else {
                          activeFilters.remove(filter);
                          if (activeFilters.isEmpty) activeFilters.add('Semua');
                        }
                      }
                    });
                  },
                  backgroundColor: Colors.white,
                  selectedColor: const Color(0xFF006D5B),
                  checkmarkColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey.withOpacity(0.2))),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 25),

        // Pencetak Kartu Riwayat Absensi Otomatis
        riwayatTerfilter.isEmpty 
          ? const Center(child: Text("Tidak ada data untuk filter ini", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: riwayatTerfilter.length,
              itemBuilder: (context, index) {
                var absen = riwayatTerfilter[index];

                // Menentukan warna dan teks berdasarkan status
                Color bgWarna;
                Color textWarna;
                String statusLabel = absen['status'];

                if (statusLabel == 'Hadir') {
                  bgWarna = const Color(0xFFD3EADD); textWarna = const Color(0xFF006D5B);
                } else if (statusLabel == 'Telat') {
                  statusLabel = 'Terlambat';
                  bgWarna = const Color(0xFFFFF3E0); textWarna = const Color(0xFFEBC15B);
                } else {
                  bgWarna = const Color(0xFFFFEBEE); textWarna = Colors.redAccent;
                }

                return _buildRiwayatCard(
                  _formatIsoDateToID(absen['tanggal']),
                  _formatIsoTime(absen['jamMasuk']),
                  statusLabel,
                  bgWarna,
                  textWarna,
                );
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
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
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E1E1E))),
                const SizedBox(height: 4),
                Text(fileName, style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: bgStatus, borderRadius: BorderRadius.circular(12)),
            child: Text(
              statusText,
              style: TextStyle(color: textStatus, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatCard(String date, String time, String status, Color bgStatus, Color textStatus) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: bgStatus, shape: BoxShape.circle),
                child: Icon(status == "Hadir" ? Icons.check_rounded : status == "Sakit" ? Icons.local_hospital_rounded : Icons.access_time_filled_rounded, color: textStatus, size: 20),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text("Masuk: $time", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ],
          ),
          Text(status, style: TextStyle(color: textStatus, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}