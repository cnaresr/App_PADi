import 'package:flutter/material.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text("Riwayat", style: TextStyle(color: Color(0xFF1E1E1E), fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rekap Card - PERBAIKAN: Tinggi (height) diperbesar menjadi 220 agar tidak overflow
            Container(
              width: double.infinity,
              height: 220, 
              decoration: BoxDecoration(
                color: const Color(0xFF151B2B),
                borderRadius: BorderRadius.circular(32),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Positioned(
                    top: -30,
                    right: -20,
                    child: Container(width: 120, height: 120, decoration: const BoxDecoration(color: Color(0xFF8F306A), shape: BoxShape.circle)),
                  ),
                  Positioned(
                    bottom: -40,
                    right: 40,
                    child: Container(width: 100, height: 100, decoration: const BoxDecoration(color: Color(0xFFEBC15B), shape: BoxShape.circle)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Total Kehadiran", style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 5),
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text("22", style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                            SizedBox(width: 5),
                            Text("Hari", style: TextStyle(color: Colors.white, fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                          child: const Text("Mei 2026", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            const Text("Aktivitas Harian", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
            const SizedBox(height: 15),

            // List Riwayat
            _buildHistoryItem("20", "Senin", "07:15 WIB", "Hadir", const Color(0xFFD3EADD), const Color(0xFF006D5B)),
            _buildHistoryItem("19", "Minggu", "Libur", "Libur", const Color(0xFFF1F4FF), const Color(0xFF151B2B)),
            _buildHistoryItem("18", "Sabtu", "07:42 WIB", "Telat", const Color(0xFFFFF3E0), const Color(0xFFEBC15B)),
            _buildHistoryItem("17", "Jumat", "07:10 WIB", "Hadir", const Color(0xFFD3EADD), const Color(0xFF006D5B)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String date, String day, String time, String status, Color statusBg, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E1E1E))),
                Text(day, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E1E1E))),
                const SizedBox(height: 4),
                const Text("Presensi Masuk", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(12)),
            child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}