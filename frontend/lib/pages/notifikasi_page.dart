import 'package:flutter/material.dart';

class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

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
        title: const Text("Notifikasi", style: TextStyle(color: Color(0xFF1E1E1E), fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildNotifItem("Pengajuan Izin Disetujui", "Permohonan izin dinas sekolah Anda tanggal 19 Mei telah diverifikasi dan disetujui.", "10 Menit Lalu", Icons.verified_user_rounded, const Color(0xFFD3EADD), const Color(0xFF006D5B)),
          _buildNotifItem("Presensi Masuk Berhasil", "Anda tercatat hadir tepat waktu pada jam 07:15 WIB menggunakan Face Recognition.", "Hari Ini, 07:16", Icons.check_circle_rounded, const Color(0xFFE8F3F1), const Color(0xFF006D5B)),
          _buildNotifItem("Pemberitahuan Sistem", "Lakukan pembaharuan berkas pendukung jika terdapat data administrasi kelas yang salah.", "Kemarin", Icons.info_outline_rounded, const Color(0xFFFFF3E0), const Color(0xFFEBC15B)),
        ],
      ),
    );
  }

  Widget _buildNotifItem(String title, String body, String time, IconData icon, Color bgIcon, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgIcon, borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E1E1E))),
                const SizedBox(height: 5),
                Text(body, style: const TextStyle(color: Colors.grey, fontSize: 12, height: 1.4)),
                const SizedBox(height: 8),
                Text(time, style: const TextStyle(color: Colors.black26, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }
}