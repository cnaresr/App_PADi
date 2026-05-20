import 'package:flutter/material.dart';

class ProfilGuruPage extends StatelessWidget {
  const ProfilGuruPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0, automaticallyImplyLeading: false,
        title: const Text("Profil Pengajar", style: TextStyle(color: Color(0xFF1E1E1E), fontWeight: FontWeight.bold, fontSize: 24)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 110, height: 110,
                    decoration: BoxDecoration(color: const Color(0xFFEBC15B), borderRadius: BorderRadius.circular(35), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))]),
                    child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 55),
                  ),
                  const SizedBox(height: 20),
                  const Text("Budi Santoso, M.Kom", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), letterSpacing: -0.5)),
                  const SizedBox(height: 5),
                  const Text("NIP: 19800512 201001 1 015", style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 40),

            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 5))]),
              child: Column(
                children: [
                  _buildMenuRow(Icons.email_outlined, "Email Resmi", "budi.s@smk1jkt.sch.id"),
                  Divider(height: 1, color: Colors.grey.shade100, indent: 20, endIndent: 20),
                  _buildMenuRow(Icons.phone_outlined, "Nomor Telepon", "+62 812 3456"),
                  Divider(height: 1, color: Colors.grey.shade100, indent: 20, endIndent: 20),
                  _buildMenuRow(Icons.security_rounded, "Ubah Kata Sandi", ""),
                ],
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity, height: 65,
              child: TextButton(
                style: TextButton.styleFrom(backgroundColor: const Color(0xFFFFF0F0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                onPressed: () {}, child: const Text("Keluar Akun", style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: const Color(0xFF1E1E1E), size: 22)),
          const SizedBox(width: 15),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E)))),
          if (subtitle.isNotEmpty) Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          if (subtitle.isEmpty) const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
        ],
      ),
    );
  }
}