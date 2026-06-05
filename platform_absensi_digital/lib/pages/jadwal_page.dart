import 'package:flutter/material.dart';

class JadwalPage extends StatelessWidget {
  const JadwalPage({super.key});

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
        title: const Text("Jadwal Pelajaran", style: TextStyle(color: Color(0xFF1E1E1E), fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Hari Ini (Senin)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
            const SizedBox(height: 15),
            
            _buildJadwalItem("07:00 - 09:30", "Pemrograman Perangkat Bergerak", "Ruang LAB RPL 2", const Color(0xFFD3EADD), const Color(0xFF006D5B)),
            _buildJadwalItem("09:45 - 12:00", "Basis Data & Cloud System", "Ruang LAB RPL 1", const Color(0xFFF1F4FF), const Color(0xFF151B2B)),
            _buildJadwalItem("13:00 - 15:30", "Matematika Komputasi", "Ruang Kelas XII 1", const Color(0xFFFAFAFA), Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildJadwalItem(String time, String subject, String room, Color accentBg, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: accentBg, borderRadius: BorderRadius.circular(14)),
            child: Text(time, style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E1E1E))),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.room_rounded, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(room, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}