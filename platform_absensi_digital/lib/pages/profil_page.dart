import 'package:flutter/material.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Icon(Icons.arrow_back, color: Color(0xFF006D5B)),
            SizedBox(width: 15),
            Text("Profil Saya", style: TextStyle(color: Color(0xFF006D5B), fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar & Nama
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF64FFDA), width: 3)),
                        child: const CircleAvatar(
                          radius: 40,
                          backgroundColor: Color(0xFF0D1B2A),
                          child: Icon(Icons.person, color: Colors.white, size: 40), // Ganti dengan image asli
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.verified, color: Color(0xFFE87B21), size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text("Cezsar N.", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF006D5B))),
                  const SizedBox(height: 5),
                  const Text("XII RPL 1", style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFF5EF08F), borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.school, color: Color(0xFF004D40), size: 14),
                        SizedBox(width: 5),
                        Text("STUDENT", style: TextStyle(color: Color(0xFF004D40), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Section Jadwal
            _buildSectionTitle("Jadwal"),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: const Color(0xFF006D5B), borderRadius: BorderRadius.circular(15)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("AKTIF", style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text("Senin - Jumat (07:00 - 16:00)", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Icon(Icons.access_time, color: Colors.white24, size: 28),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: const Color(0xFFF1F4FF), borderRadius: BorderRadius.circular(15)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("IZIN SEMESTER INI", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text("9 Hari", style: TextStyle(color: Color(0xFF0D1B2A), fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Icon(Icons.timer_outlined, color: Color(0xFF006D5B), size: 24),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Section Informasi Pribadi
            _buildSectionTitle("Informasi Pribadi"),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: const Color(0xFFF4F6FB), borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  _buildInfoRow(Icons.person_outline, "FULL NAME", "Cezsar N."),
                  const Divider(height: 30, color: Colors.white),
                  _buildInfoRow(Icons.phone_outlined, "PHONE NUMBER", "+62 812 3456 7890"),
                  const Divider(height: 30, color: Colors.white),
                  _buildInfoRow(Icons.business, "SCHOOL", "SMK Negeri 1 Jakarta"),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Pengaturan & Bantuan
            _buildSectionTitle("Pengaturan & Bantuan"),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: const Color(0xFFF4F6FB), borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  _buildMenuRow(Icons.help_outline, "Pertanyaan Umum (FAQ)"),
                  const Divider(height: 30, color: Colors.white),
                  _buildMenuRow(Icons.support_agent, "Pusat Bantuan"),
                  const SizedBox(height: 20),
                  
                  // Tombol Keluar
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFEBEE),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () {},
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Colors.red),
                          SizedBox(width: 10),
                          Text("Keluar", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text("PADI V2.4.0 • 2026", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0D1B2A))),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: const Color(0xFF006D5B), size: 18),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Color(0xFF0D1B2A), fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuRow(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF006D5B), size: 22),
        const SizedBox(width: 15),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0D1B2A)))),
        const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
      ],
    );
  }
}