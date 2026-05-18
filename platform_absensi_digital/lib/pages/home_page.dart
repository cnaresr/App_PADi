import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Padi", style: TextStyle(color: Color(0xFF004D40), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: Color(0xFF004D40))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("SELAMAT PAGI,", style: TextStyle(color: Colors.grey, fontSize: 12)),
            const Text("Cezsar N.", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF004D40))),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("XII Rekayasa Perangkat Lunak 1", style: TextStyle(color: Colors.grey)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFF006D5B), borderRadius: BorderRadius.circular(20)),
                  child: const Text("Senin 21 April 2026", style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Card Status Presensi
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF004D40), Color(0xFF26A69A)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("STATUS SAAT INI", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const Text("Belum Presensi", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF006D5B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {},
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Text("Absen Sekarang"), SizedBox(width: 5), Icon(Icons.arrow_forward, size: 16)],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Card Persentase Kehadiran
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(15)),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("KEHADIRAN", style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
                        Text("98%", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0D1B2A))),
                        Text("Sangat Baik bulan ini", style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(Icons.bar_chart, size: 40, color: Color(0xFF26A69A)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Riwayat Kehadiran", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Lihat Semua", style: TextStyle(color: Color(0xFF26A69A))),
              ],
            ),
            const SizedBox(height: 10),

            // Contoh Item List Riwayat
            _buildHistoryItem("Hadir Tepat Waktu", "Jumat, 11 Okt • 07:12 WIB", Icons.check_circle, Colors.green),
            _buildHistoryItem("Terlambat 15 Menit", "Kamis, 10 Okt • 07:30 WIB", Icons.history, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String title, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }
}