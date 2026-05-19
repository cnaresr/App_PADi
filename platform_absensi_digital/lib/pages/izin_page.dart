import 'package:flutter/material.dart';

class IzinPage extends StatelessWidget {
  const IzinPage({super.key});

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
        title: const Text("Perizinan", style: TextStyle(color: Color(0xFF1E1E1E), fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kontainer Unggah Berkas Formal
            const Text("Ajukan Izin Baru", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFF006D5B).withOpacity(0.2), width: 2, strokeAlign: BorderSide.strokeAlignInside),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(color: Color(0xFFE8F3F1), shape: BoxShape.circle),
                    child: const Icon(Icons.cloud_upload_rounded, size: 36, color: Color(0xFF006D5B)),
                  ),
                  const SizedBox(height: 15),
                  const Text("Unggah Dokumen Pendukung", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
                  const SizedBox(height: 5),
                  const Text("Format PDF atau Gambar (Surat Dokter / Resmi)", style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 35),

            // Daftar Riwayat dan Status Pengajuan
            const Text("Status Pengajuan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
            const SizedBox(height: 15),
            _buildIzinStatusItem("Izin Sakit", "Surat_Dokter_Cezsar.pdf", "Ditinjau", const Color(0xFFFFF3E0), const Color(0xFFEBC15B)),
            _buildIzinStatusItem("Izin Dinas Sekolah", "Surat_Undangan_Lomba.pdf", "Disetujui", const Color(0xFFD3EADD), const Color(0xFF006D5B)),
          ],
        ),
      ),
    );
  }

  Widget _buildIzinStatusItem(String title, String fileName, String statusText, Color bgStatus, Color textStatus) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E1E1E))),
                const SizedBox(height: 4),
                Text(fileName, style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: bgStatus, borderRadius: BorderRadius.circular(12)),
            child: Text(
              statusText,
              style: TextStyle(color: textStatus, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}