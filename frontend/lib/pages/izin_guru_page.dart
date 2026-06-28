import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:platform_absensi_digital/services/api_service.dart';
import 'package:platform_absensi_digital/providers/user_provider.dart';
import 'package:platform_absensi_digital/widgets/custom_popup.dart';

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
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
              child: CircularProgressIndicator(color: Color(0xFF006D5B)),
            ));
    final result =
        await ApiService.updateStatusIzin(izinId, statusUpdate, user.userId);
    Navigator.pop(context);
    if (result['status'] == 'success') {
      CustomPopup.show(
        context,
        message: 'Izin berhasil $statusUpdate',
        type: statusUpdate == 'Disetujui' ? PopupType.success : PopupType.info,
      );
      _loadPendingIzin();
    } else {
      CustomPopup.show(
        context,
        message: 'Gagal: ${result['message']}',
        type: PopupType.error,
      );
    }
  }

  String _formatIsoDateToID(String isoDate) {
    try {
      DateTime dt = DateTime.parse(isoDate).toLocal();
      List<String> bulan = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agt',
        'Sep',
        'Okt',
        'Nov',
        'Des'
      ];
      return "${dt.day} ${bulan[dt.month - 1]} ${dt.year}";
    } catch (e) {
      return "-";
    }
  }

  Future<void> _openFile(String fileName) async {
    if (fileName == "Tidak ada lampiran") return;

    final String serverUrl = ApiService.baseUrl.replaceAll('/api', '');
    final String fileUrl = '$serverUrl/uploads/$fileName';
    final Uri url = Uri.parse(fileUrl);

    String extension = fileName.split('.').last.toLowerCase();

    if (extension == 'jpg' || extension == 'jpeg' || extension == 'png') {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: InteractiveViewer(
                  child: Image.network(
                    fileUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(20),
                      child: const Text(
                          'Gagal memuat gambar. Pastikan server Backend menyala.',
                          textAlign: TextAlign.center),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context)),
                ),
              )
            ],
          ),
        ),
      );
    } else {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.inAppBrowserView);
      } else {
        CustomPopup.show(
          context,
          message: 'Tidak dapat membuka file.',
          type: PopupType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: _loadPendingIzin,
        color: const Color(0xFF006D5B),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF006D5B)))
            : CustomScrollView(
                slivers: [
                  // ===== HEADER =====
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF006D5B), Color(0xFF004D40)],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(36),
                          bottomRight: Radius.circular(36),
                        ),
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                        Icons.pending_actions_rounded,
                                        color: Colors.white,
                                        size: 22),
                                  ),
                                  const SizedBox(width: 14),
                                  const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Persetujuan Izin",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      Text(
                                        "Pengajuan izin dari siswa",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Pending count card
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.13),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.15)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withOpacity(0.2),
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                          Icons.hourglass_empty_rounded,
                                          color: Colors.white,
                                          size: 24),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${pendingList.length} Pengajuan Menunggu",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const Text(
                                          "Perlu tindakan segera",
                                          style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ===== CONTENT =====
                  if (pendingList.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: const Color(0xFF006D5B).withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle_outline_rounded,
                                color: Color(0xFF006D5B),
                                size: 52,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Semua Beres!",
                              style: TextStyle(
                                color: Color(0xFF1E1E1E),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Tidak ada pengajuan izin yang perlu\nditindaklanjuti saat ini.",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            var izin = pendingList[index];
                            String namaSiswa = izin['siswa']['namaLengkap'];
                            String jenisIzin = izin['jenisIzin'] ?? '-';
                            String alasan = izin['alasan'] ?? '-';
                            String tglMulai =
                                _formatIsoDateToID(izin['tanggalMulai']);
                            String tglSelesai =
                                _formatIsoDateToID(izin['tanggalSelesai']);
                            String file =
                                izin['fileBukti'] ?? "Tidak ada lampiran";

                            return _buildApprovalCard(
                                izin['id'],
                                namaSiswa,
                                jenisIzin,
                                alasan,
                                "$tglMulai s/d $tglSelesai",
                                file,
                                index);
                          },
                          childCount: pendingList.length,
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildApprovalCard(int izinId, String name, String jenis,
      String reason, String date, String attachment, int index) {
    final bool hasAttachment = attachment != "Tidak ada lampiran";
    final String initials = name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    // Warna berdasarkan jenis izin
    Color jenisColor;
    IconData jenisIcon;
    switch (jenis.toLowerCase()) {
      case 'sakit':
        jenisColor = const Color(0xFF1565C0);
        jenisIcon = Icons.medical_services_rounded;
        break;
      case 'izin':
        jenisColor = const Color(0xFFE65100);
        jenisIcon = Icons.assignment_late_rounded;
        break;
      default:
        jenisColor = const Color(0xFF6A1B9A);
        jenisIcon = Icons.note_alt_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        children: [
          // Header kartu
          Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            decoration: BoxDecoration(
              color: jenisColor.withOpacity(0.05),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                  bottom:
                      BorderSide(color: Colors.grey.shade100, width: 1)),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [jenisColor, jenisColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E1E),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(jenisIcon, size: 13, color: jenisColor),
                          const SizedBox(width: 5),
                          Text(
                            jenis,
                            style: TextStyle(
                              color: jenisColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: const Color(0xFFFFCC80)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule_rounded,
                          size: 11, color: Color(0xFFE65100)),
                      SizedBox(width: 4),
                      Text(
                        "Menunggu",
                        style: TextStyle(
                          color: Color(0xFFE65100),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body kartu
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info rows
                _buildInfoRow(
                    Icons.chat_bubble_outline_rounded,
                    "Alasan",
                    reason),
                const SizedBox(height: 10),
                _buildInfoRow(
                    Icons.calendar_today_rounded, "Periode", date),
                const SizedBox(height: 16),

                // Attachment button
                GestureDetector(
                  onTap: () => _openFile(attachment),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: hasAttachment
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: hasAttachment
                            ? const Color(0xFF006D5B).withOpacity(0.3)
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          hasAttachment
                              ? Icons.attachment_rounded
                              : Icons.insert_drive_file_outlined,
                          size: 18,
                          color: hasAttachment
                              ? const Color(0xFF006D5B)
                              : Colors.grey,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            hasAttachment ? attachment : "Tidak ada lampiran",
                            style: TextStyle(
                              color: hasAttachment
                                  ? const Color(0xFF006D5B)
                                  : Colors.grey,
                              fontSize: 13,
                              fontWeight: hasAttachment
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              decoration: hasAttachment
                                  ? TextDecoration.underline
                                  : null,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasAttachment)
                          const Icon(Icons.open_in_new_rounded,
                              size: 14, color: Color(0xFF006D5B)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.close_rounded,
                            size: 16, color: Color(0xFFC62828)),
                        label: const Text(
                          "Tolak",
                          style: TextStyle(
                            color: Color(0xFFC62828),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFFC62828), width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () =>
                            _processIzin(izinId, 'Ditolak'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_rounded,
                            size: 16, color: Colors.white),
                        label: const Text(
                          "Setujui",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006D5B),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () =>
                            _processIzin(izinId, 'Disetujui'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 14, color: const Color(0xFF006D5B)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 11)),
              const SizedBox(height: 2),
              Text(value,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: const TextStyle(
                    color: Color(0xFF1E1E1E),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}