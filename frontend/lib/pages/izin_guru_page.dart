import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:platform_absensi_digital/services/api_service.dart';
import 'package:platform_absensi_digital/providers/user_provider.dart';

class IzinGuruPage extends StatefulWidget {
  const IzinGuruPage({super.key});

  @override
  State<IzinGuruPage> createState() => _IzinGuruPageState();
}

class _IzinGuruPageState extends State<IzinGuruPage> {
  List<dynamic> pendingList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingIzin();
  }

  Future<void> _loadPendingIzin() async {
    setState(() => isLoading = true);
    final data = await ApiService.getIzinPending();
    setState(() {
      pendingList = data;
      isLoading = false;
    });
  }

  Future<void> _processIzin(int izinId, String statusUpdate) async {
    final user = context.read<UserProvider>();
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
    final result = await ApiService.updateStatusIzin(izinId, statusUpdate, user.userId);
    Navigator.pop(context);
    if (result['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Izin berhasil $statusUpdate')));
      _loadPendingIzin();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: ${result['message']}')));
    }
  }

  String _formatIsoDateToID(String isoDate) {
    try {
      DateTime dt = DateTime.parse(isoDate).toLocal();
      List<String> bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
      return "${dt.day} ${bulan[dt.month - 1]} ${dt.year}";
    } catch (e) { return "-"; }
  }

  // --- FUNGSI BARU: Buka File di Dalam Aplikasi ---
  Future<void> _openFile(String fileName) async {
    if (fileName == "Tidak ada lampiran") return;
    
    final String serverUrl = ApiService.baseUrl.replaceAll('/api', '');
    final String fileUrl = '$serverUrl/uploads/$fileName';
    final Uri url = Uri.parse(fileUrl);
    
    String extension = fileName.split('.').last.toLowerCase();

    // Jika file berupa Gambar (Tampilkan Pop-up)
    if (extension == 'jpg' || extension == 'jpeg' || extension == 'png') {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer( // Agar gambar bisa di-zoom
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    fileUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.white, padding: const EdgeInsets.all(20),
                      child: const Text('Gagal memuat gambar. Pastikan server Backend menyala.', textAlign: TextAlign.center),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10, right: 10,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                ),
              )
            ],
          ),
        ),
      );
    } 
    // Jika file PDF (Buka dengan In-App Browser)
    else {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.inAppBrowserView);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak dapat membuka file PDF.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0, automaticallyImplyLeading: false,
        title: const Text("Persetujuan Izin", style: TextStyle(color: Color(0xFF1E1E1E), fontWeight: FontWeight.bold, fontSize: 24)),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF006D5B)))
        : RefreshIndicator(
            // Panggil fungsi yang sudah ada untuk memuat ulang data
            onRefresh: _loadPendingIzin,
            color: const Color(0xFF006D5B), // Warna ikon loading
            child: pendingList.isEmpty
              // [PENTING] Bungkus dengan ListView agar RefreshIndicator tetap bisa ditarik
              // meskipun kontennya kosong.
              ? ListView(
                  children: const [
                    SizedBox(height: 150), // Beri jarak dari atas
                    Center(child: Text("Tidak ada pengajuan izin yang tertunda", style: TextStyle(color: Colors.grey, fontSize: 16))),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(24.0),
                  itemCount: pendingList.length,
                  itemBuilder: (context, index) {
                    var izin = pendingList[index];
                    String namaSiswa = izin['siswa']['namaLengkap'];
                    String tglMulai = _formatIsoDateToID(izin['tanggalMulai']);
                    String tglSelesai = _formatIsoDateToID(izin['tanggalSelesai']);
                    String file = izin['fileBukti'] ?? "Tidak ada lampiran";

                    return _buildApprovalCard(izin['id'], namaSiswa, "${izin['jenisIzin']}: ${izin['alasan']}", "$tglMulai s/d $tglSelesai", file);
                  },
                ),
          ),
    );
  }

  Widget _buildApprovalCard(int izinId, String name, String reason, String date, String attachment) {
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
          
          GestureDetector(
            onTap: () => _openFile(attachment),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
              child: Row(
                children: [
                  Icon(attachment == "Tidak ada lampiran" ? Icons.insert_drive_file_outlined : Icons.image_rounded, size: 20, color: attachment == "Tidak ada lampiran" ? Colors.grey : Colors.blueAccent),
                  const SizedBox(width: 12),
                  Expanded(child: Text(attachment, style: TextStyle(color: attachment == "Tidak ada lampiran" ? Colors.grey : Colors.blue, fontSize: 13, fontWeight: FontWeight.bold, decoration: attachment == "Tidak ada lampiran" ? TextDecoration.none : TextDecoration.underline), overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),
          
          Row(
            children: [
              Expanded(child: TextButton(style: TextButton.styleFrom(backgroundColor: const Color(0xFFFFF0F0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 16)), onPressed: () => _processIzin(izinId, 'Ditolak'), child: const Text("Tolak", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)))),
              const SizedBox(width: 15),
              Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF151B2B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 16)), onPressed: () => _processIzin(izinId, 'Disetujui'), child: const Text("Setujui", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
            ],
          )
        ],
      ),
    );
  }
}