import 'package:flutter/material.dart';

class AbsensiPage extends StatelessWidget {
  const AbsensiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Menghilangkan tombol back bawaan
        title: const Row(
          children: [
            Icon(Icons.arrow_back, color: Color(0xFF006D5B)),
            SizedBox(width: 10),
            Text("Padi", style: TextStyle(color: Color(0xFF006D5B), fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF006D5B)),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Header Presensi & Jam
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Presensi\nMandiri", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF006D5B), height: 1.2)),
                    SizedBox(height: 5),
                    Text("Verify your presence", style: TextStyle(color: Color(0xFF006D5B), fontSize: 13)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("08:42", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w300, color: Color(0xFF006D5B))),
                    Text("Monday, 24\nMay", textAlign: TextAlign.right, style: TextStyle(color: Color(0xFF006D5B), fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Kamera Placeholder
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(25),
                // TODO: Ganti dengan gambar kamera Anda
                // image: DecorationImage(image: AssetImage('assets/camera.png'), fit: BoxFit.cover),
              ),
              child: const Center(child: Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 50)),
            ),
            const SizedBox(height: 15),

            // Tombol Ambil Absensi
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006D5B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                onPressed: () {},
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Ambil Absensi", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(width: 10),
                    Icon(Icons.fingerprint, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Tombol Refresh
            Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.autorenew, color: Color(0xFF006D5B)),
            ),
            const SizedBox(height: 25),

            // Info Lokasi
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1B2A),
                      borderRadius: BorderRadius.circular(15),
                      // TODO: Ganti dengan gambar maps
                    ),
                    child: const Center(child: Icon(Icons.map, color: Colors.white24, size: 40)),
                  ),
                  const SizedBox(height: 15),
                  const Row(
                    children: [
                      Icon(Icons.location_on, color: Color(0xFF006D5B), size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text("SMK Negeri 1\nJakarta", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0D1B2A))),
                      ),
                      Text("Dalam Jangkauan (12m)", style: TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                  const Divider(height: 20, color: Color(0xFFF1F4FF)),
                  const Row(
                    children: [
                      Icon(Icons.wifi, color: Color(0xFFE87B21), size: 20),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("School_Main_5G", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0D1B2A))),
                          Text("Verified Network", style: TextStyle(color: Colors.grey, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Riwayat Hari Ini
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Riwayat Hari Ini", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D1B2A))),
                  const SizedBox(height: 15),
                  _buildHistoryItem(Icons.login, "Absen- Masuk", "07:22 WIB", "SUKSES", const Color(0xFF006D5B)),
                  const SizedBox(height: 15),
                  _buildHistoryItem(Icons.logout, "Absen-Keluar", "--:--", "PENDING", Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(IconData icon, String title, String time, String status, Color statusColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: const Color(0xFF006D5B), size: 18),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0D1B2A))),
              Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ),
        Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10)),
      ],
    );
  }
}