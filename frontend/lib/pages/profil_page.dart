import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:platform_absensi_digital/providers/user_provider.dart';
import 'package:platform_absensi_digital/pages/login_page.dart';
import 'package:platform_absensi_digital/services/api_service.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text("Profil", style: TextStyle(color: Color(0xFF1E1E1E), fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Header Avatar
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF151B2B),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
                    ),
                    child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 50),
                  ),
                  const SizedBox(height: 15),
                  // KODE DINAMIS: Menampilkan nama lengkap dari provider
                  Text(
                    context.watch<UserProvider>().namaLengkap, 
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), letterSpacing: -0.5)
                  ),
                  const SizedBox(height: 5),
                  // KODE DINAMIS: Menampilkan detail kelas/NIP dari provider
                  Text(
                    context.watch<UserProvider>().kelasAtauNip, 
                    style: const TextStyle(color: Colors.grey, fontSize: 13)
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Card Menu Profil
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  _buildMenuRow(Icons.phone_outlined, "Nomor Telepon", "+62 812 3456"),
                  Divider(height: 1, color: Colors.grey.shade100, indent: 20, endIndent: 20),
                  _buildMenuRow(Icons.schedule_rounded, "Jadwal Aktif", "Senin - Jumat"),
                  Divider(height: 1, color: Colors.grey.shade100, indent: 20, endIndent: 20),
                  _buildMenuRow(Icons.help_outline_rounded, "Pusat Bantuan", ""),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Tombol Keluar
            SizedBox(
              width: double.infinity,
              height: 60,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF0F0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () async {
                  // Hapus data pengguna yang sedang login dari memori Provider dan Secure Storage
                  context.read<UserProvider>().clearData();
                  await ApiService.clearLocalSession();
                  
                  // Navigasi ke LoginPage dan hancurkan semua rute sebelumnya
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text("Keluar Akun", style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: const Color(0xFF1E1E1E), size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E))),
          ),
          if (subtitle.isNotEmpty) 
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          if (subtitle.isEmpty)
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
        ],
      ),
    );
  }
}