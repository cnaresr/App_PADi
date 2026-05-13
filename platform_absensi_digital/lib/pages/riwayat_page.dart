import 'package:flutter/material.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Icon(Icons.arrow_back, color: Color(0xFF006D5B)),
            const SizedBox(width: 15),
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFE87B21),
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text("Riwayat", style: TextStyle(color: Color(0xFF006D5B), fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text("OVERVIEW", style: TextStyle(color: Color(0xFFC06B3E), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Riwayat\nPresensi", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0D1B2A), height: 1.2)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFFF1F4FF), borderRadius: BorderRadius.circular(10)),
                  child: const Row(
                    children: [
                      Text("Mei 2024", style: TextStyle(fontSize: 12, color: Color(0xFF0D1B2A))),
                      Icon(Icons.keyboard_arrow_down, size: 16),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tab Bulanan / Tahunan
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: const Color(0xFFF1F4FF), borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      alignment: Alignment.center,
                      child: const Text("Bulanan", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006D5B), fontSize: 13)),
                    ),
                  ),
                  const Expanded(
                    child: Center(child: Text("Tahunan", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Card Total Hadir
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF006D5B), borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Total Hadir Bulan Ini", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 5),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text("22", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                      SizedBox(width: 5),
                      Text("Hari", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.trending_up, color: Colors.white, size: 14),
                        SizedBox(width: 5),
                        Text("98% KEHADIRAN", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Row Terlambat & Alpa
            Row(
              children: [
                Expanded(child: _buildStatCard(Icons.access_time, const Color(0xFFC06B3E), "02", "TERLAMBAT")),
                const SizedBox(width: 15),
                Expanded(child: _buildStatCard(Icons.close, Colors.red, "00", "ALPA")),
              ],
            ),
            const SizedBox(height: 30),

            // Aktivitas Harian
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Aktivitas Harian", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D1B2A))),
                Text("LIHAT SEMUA", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF006D5B))),
              ],
            ),
            const SizedBox(height: 15),

            _buildDailyItem("MEI", "20", "Senin, 20 Mei", "07:15 WIB", "HADIR", const Color(0xFFE6F4F1), const Color(0xFF006D5B)),
            _buildDailyItem("MEI", "19", "Minggu, 19 Mei", "Hari Libur", "LIBUR", const Color(0xFFE8EAF6), const Color(0xFF5C6BC0), icon: Icons.calendar_today),
            _buildDailyItem("MEI", "18", "Sabtu, 18 Mei", "07:42 WIB", "TERLAMBAT", const Color(0xFFFFF3E0), const Color(0xFFC06B3E)),
            _buildDailyItem("MEI", "17", "Jumat, 17 Mei", "07:10 WIB", "HADIR", const Color(0xFFE6F4F1), const Color(0xFF006D5B)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, Color iconColor, String count, String label) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 16)),
              Icon(Icons.warning_amber_rounded, color: Colors.grey.shade300, size: 24),
            ],
          ),
          const SizedBox(height: 10),
          Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D1B2A))),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0D1B2A))),
        ],
      ),
    );
  }

  Widget _buildDailyItem(String month, String date, String dayDesc, String timeDesc, String status, Color statusBg, Color statusColor, {IconData icon = Icons.login}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)]),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFFF1F4FF), borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Text(month, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                Text(date, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D1B2A))),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dayDesc, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0D1B2A))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(icon, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(timeDesc, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}