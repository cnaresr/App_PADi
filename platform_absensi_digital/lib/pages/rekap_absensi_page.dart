import 'package:flutter/material.dart';

class RekapAbsensiPage extends StatefulWidget {
  const RekapAbsensiPage({super.key});

  @override
  State<RekapAbsensiPage> createState() => _RekapAbsensiPageState();
}

class _RekapAbsensiPageState extends State<RekapAbsensiPage> {
  // State untuk melacak filter yang sedang dipilih
  int _selectedFilterIndex = 0;
  final List<String> _filters = ["Semua", "Hadir", "Izin", "Alpa"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        automaticallyImplyLeading: false,
        title: const Text("Rekap Kelas", style: TextStyle(color: Color(0xFF1E1E1E), fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: -0.5)),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: Color(0xFF1E1E1E)),
            tooltip: "Unduh Laporan PDF",
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Search Bar Area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 5))],
              ),
              child: TextField(
                decoration: InputDecoration(
                  filled: true, 
                  fillColor: Colors.white, 
                  hintText: "Cari nama atau NIS siswa...", 
                  hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),
          ),
          
          // 2. Filter Chips Area (Semua, Hadir, Izin, Alpa)
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: List.generate(_filters.length, (index) {
                bool isSelected = _selectedFilterIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilterIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF151B2B) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? const Color(0xFF151B2B) : Colors.grey.withOpacity(0.2)),
                      boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF151B2B).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                    ),
                    child: Text(
                      _filters[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 10),

          // 3. Info Tanggal & Total
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Senin, 24 Mei 2026", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                Text("Total: 36 Siswa", style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // 4. Daftar Siswa (ListView)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
              children: [
                _buildStudentRow("CN", "Cezsar N.", "Hadir • 07:12 WIB", "Hadir", const Color(0xFFD3EADD), const Color(0xFF006D5B)),
                _buildStudentRow("AM", "Andi Maulana", "Hadir • 07:15 WIB", "Hadir", const Color(0xFFD3EADD), const Color(0xFF006D5B)),
                _buildStudentRow("SA", "Siti Aisyah", "Izin • Surat Sakit", "Izin", const Color(0xFFFFF3E0), const Color(0xFFEBC15B)),
                _buildStudentRow("BT", "Budi Tabuti", "Tidak ada keterangan", "Alpa", const Color(0xFFFDE8E8), Colors.redAccent),
                _buildStudentRow("DN", "Dian Nugraha", "Hadir • 07:20 WIB", "Hadir", const Color(0xFFD3EADD), const Color(0xFF006D5B)),
                _buildStudentRow("FR", "Fajar Ramadhan", "Terlambat • 07:45 WIB", "Telat", const Color(0xFFFFF3E0), const Color(0xFFEBC15B)),
                const SizedBox(height: 20), // Spasi ekstra di bawah
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentRow(String initial, String name, String subtitle, String status, Color statusBg, Color statusCol) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16), 
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))]
      ),
      child: Row(
        children: [
          // Avatar Inisial
          Container(
            width: 50, height: 50, 
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA), 
              shape: BoxShape.circle, 
              border: Border.all(color: Colors.grey.shade200)
            ),
            child: Center(
              child: Text(
                initial, 
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF151B2B), fontSize: 16)
              )
            ),
          ),
          const SizedBox(width: 16),
          
          // Nama dan Keterangan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E1E1E), letterSpacing: -0.3)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            )
          ),

          // Label Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(12)),
            child: Text(status, style: TextStyle(color: statusCol, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}