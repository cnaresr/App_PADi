import 'package:flutter/material.dart';

class IzinGuruPage extends StatelessWidget {
  const IzinGuruPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0, automaticallyImplyLeading: false,
        title: const Text("Persetujuan Izin", style: TextStyle(color: Color(0xFF1E1E1E), fontWeight: FontWeight.bold, fontSize: 24)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildApprovalCard("Cezsar N.", "Sakit Demam", "Hari ini", "Surat_Dokter.pdf"),
          _buildApprovalCard("Siti A.", "Keperluan Keluarga", "Besok", "Surat_Ortu.jpg"),
        ],
      ),
    );
  }

  Widget _buildApprovalCard(String name, String reason, String date, String attachment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20), padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(12)), child: const Text("Menunggu", style: TextStyle(color: Color(0xFFEBC15B), fontSize: 11, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 15),
          Text("Alasan: $reason\nTanggal: $date", style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.5)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
            child: Row(
              children: [
                const Icon(Icons.picture_as_pdf_rounded, size: 20, color: Colors.redAccent),
                const SizedBox(width: 12),
                Text(attachment, style: const TextStyle(color: Color(0xFF1E1E1E), fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(backgroundColor: const Color(0xFFFFF0F0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: () {}, child: const Text("Tolak", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF151B2B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 16), elevation: 5, shadowColor: const Color(0xFF151B2B).withOpacity(0.3)),
                  onPressed: () {}, child: const Text("Setujui", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}