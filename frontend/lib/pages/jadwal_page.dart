import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:platform_absensi_digital/providers/user_provider.dart';

class JadwalPage extends StatelessWidget {
  const JadwalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final jadwalAktif = userProvider.jadwalAktif;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E1E1E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Jadwal Absensi", style: TextStyle(color: Color(0xFF1E1E1E), fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Jadwal Aktif", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
            const SizedBox(height: 15),
            
            if (jadwalAktif.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40.0),
                  child: Text("Tidak ada jadwal aktif.", style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ...jadwalAktif.map((jadwal) {
                String namaJadwal = jadwal['namaJadwal'] ?? "Jadwal";
                String jamMasukStart = jadwal['jamMasukStart']?.toString().substring(0, 5) ?? "00:00";
                String jamMasukFinish = jadwal['jamMasukFinish']?.toString().substring(0, 5) ?? "00:00";
                String jamPulang = jadwal['jamPulang']?.toString().substring(0, 5) ?? "00:00";
                bool isLibur = jadwal['isLibur'] ?? false;

                if (isLibur) {
                  return _buildJadwalItem("Libur", namaJadwal, "Tidak ada presensi", const Color(0xFFFFEBEE), const Color(0xFFC62828));
                }

                String timeDisplay = "$jamMasukStart - $jamMasukFinish\n(Pulang: $jamPulang)";
                
                return _buildJadwalItem(
                  timeDisplay, 
                  namaJadwal, 
                  "Jam Absensi", 
                  const Color(0xFFD3EADD), 
                  const Color(0xFF006D5B)
                );
              }).toList(),
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: accentBg, borderRadius: BorderRadius.circular(14)),
            child: Text(time, style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center),
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
                    const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
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