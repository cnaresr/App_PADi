import 'package:flutter/material.dart';

class ContactAdminPage extends StatelessWidget {
  const ContactAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC), // Warna background abu-abu sangat muda
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF006D5B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Padi",
          style: TextStyle(color: Color(0xFF006D5B), fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBanner(),
            const SizedBox(height: 20),
            _buildInfoCard(),
            const SizedBox(height: 20),
            _buildContactCard(),
            const SizedBox(height: 40),
            _buildFooterText(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 1. Widget Banner Bergambar
  Widget _buildBanner() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF006D5B), // Warna fallback jika gambar belum ada
        // TODO: Hapus komentar di bawah jika Anda sudah memiliki gambar 'banner.png' di folder assets
        /*
        image: const DecorationImage(
          image: AssetImage('assets/banner.png'),
          fit: BoxFit.cover,
        ),
        */
      ),
      child: Container(
        // Gradient gelap di bagian bawah agar teks putih tetap terbaca
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              const Color(0xFF004D40).withOpacity(0.9),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Badge Akses Terbatas
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE87B21), // Warna Oranye
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, color: Colors.white, size: 14),
                  SizedBox(width: 5),
                  Text(
                    "AKSES TERBATAS",
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            
            // Teks Langkah Awal
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
                children: [
                  TextSpan(text: "Langkah Awal\nMenuju\n", style: TextStyle(color: Colors.white)),
                  TextSpan(text: "Profesionalisme.", style: TextStyle(color: Color(0xFF64FFDA))), // Warna teal terang
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Widget Card Info (Belum memiliki akun)
  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      // ClipRRect & Border kiri untuk aksen warna hijau
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: Color(0xFF006D5B), width: 6)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Belum memiliki akun?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006D5B)),
              ),
              const SizedBox(height: 15),
              RichText(
                text: const TextSpan(
                  style: TextStyle(color: Colors.black87, fontSize: 13, height: 1.5),
                  children: [
                    TextSpan(text: "Untuk menjaga keamanan data dan integritas akademik, akun "),
                    TextSpan(text: "Padi ", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006D5B))),
                    TextSpan(text: "hanya dapat dibuat oleh "),
                    TextSpan(text: "Administrator Sekolah.", style: TextStyle(color: Color(0xFFE87B21))),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Row Ikon Siswa & Guru
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF006D5B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.how_to_reg, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Siswa & Guru", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        SizedBox(height: 4),
                        Text(
                          "Data anda didaftarkan secara otomatis melalui sistem akademik pusat.",
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 3. Widget Card Kontak Admin
  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4FA), // Warna dasar biru/ungu sangat muda
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Hubungi Admin",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D1B2A)),
          ),
          const SizedBox(height: 10),
          const Text(
            "Silakan hubungi kantor tata usaha atau administrator IT sekolah melalui saluran berikut:",
            style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 20),
          
          // Tombol WhatsApp
          _buildContactButton(
            icon: Icons.chat_bubble_rounded,
            iconColor: Colors.green,
            iconBgColor: Colors.green.withOpacity(0.15),
            text: "WhatsApp Admin",
          ),
          const SizedBox(height: 12),
          
          // Tombol Email
          _buildContactButton(
            icon: Icons.email_rounded,
            iconColor: const Color(0xFFC06B3E),
            iconBgColor: const Color(0xFFC06B3E).withOpacity(0.15),
            text: "Email Support",
          ),
          const SizedBox(height: 25),
          
          // Lokasi Kantor
          const Row(
            children: [
              Icon(Icons.location_on_outlined, color: Colors.grey, size: 14),
              SizedBox(width: 5),
              Text(
                "GEDUNG UTAMA, LANTAI 2, RUANG IT",
                style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Komponen pembantu untuk membuat tombol kontak
  Widget _buildContactButton({required IconData icon, required Color iconColor, required Color iconBgColor, required String text}) {
    return InkWell(
      onTap: () {
        // Aksi ketika tombol ditekan (misal membuka link WhatsApp/Email)
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ),
            const Icon(Icons.arrow_forward_rounded, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  // 4. Widget Footer Teks Peringatan Offline
  Widget _buildFooterText() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        "Pastikan Anda membawa Kartu Identitas Siswa (KTI) atau SK Pegawai saat melakukan verifikasi langsung di kantor administrator.",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey, fontSize: 11, height: 1.5),
      ),
    );
  }
}