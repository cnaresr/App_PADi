import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:platform_absensi_digital/services/api_service.dart';
import 'package:platform_absensi_digital/providers/user_provider.dart';
import 'package:platform_absensi_digital/services/firebase_messaging_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';
import 'package:platform_absensi_digital/widgets/custom_popup.dart';

class IzinGuruPage extends StatefulWidget {
  const IzinGuruPage({super.key});

  @override
  State<IzinGuruPage> createState() => _IzinGuruPageState();
}

class _IzinGuruPageState extends State<IzinGuruPage> {
  List<dynamic> pendingList = [];
  List<dynamic> riwayatList = [];
  bool isLoading = true;
  StreamSubscription<RemoteMessage>? _notifSubscription;
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _loadData();
    _notifSubscription = FirebaseMessagingService.onMessageStream.listen((message) {
      if (mounted) {
        _loadData();
      }
    });
  }

  @override
  void dispose() {
    _notifSubscription?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final user = context.read<UserProvider>();
    final hasData = user.izinPendingGuru.isNotEmpty || user.izinRiwayatGuru.isNotEmpty;
    if (!hasData) {
      setState(() => isLoading = true);
    } else {
      pendingList = user.izinPendingGuru;
      riwayatList = user.izinRiwayatGuru;
      isLoading = false;
    }
    final dataPending = await ApiService.getIzinPending();
    final dataRiwayat = await ApiService.getIzinRiwayat();
    user.setIzinGuruData(dataPending, dataRiwayat);
    if (mounted) {
      setState(() {
        pendingList = dataPending;
        riwayatList = dataRiwayat;
        isLoading = false;
      });
    }
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
    
    if (mounted) Navigator.pop(context);
    
    // Memberikan jeda agar animasi pop selesai sebelum memanggil push dialog baru
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (!mounted) return;
    if (result['status'] == 'success') {
      CustomPopup.show(
        context,
        message: 'Izin berhasil $statusUpdate',
        type: statusUpdate == 'Disetujui' ? PopupType.success : PopupType.info,
      );
      _loadData();
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
        if (!mounted) return;
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
        onRefresh: _loadData,
        color: const Color(0xFF006D5B),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF006D5B)))
            : Column(
                children: [
                  // ===== HEADER =====
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF006D5B), Color(0xFF004D40)],
                      ),
                      borderRadius: const BorderRadius.only(
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
                                    color: Colors.white.withValues(alpha: 0.15),
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
                            const SizedBox(height: 16),
                            
                            // Segmented Toggle
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Stack(
                                children: [
                                  AnimatedAlign(
                                    alignment: _selectedIndex == 0
                                        ? Alignment.centerLeft
                                        : Alignment.centerRight,
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOutCubic,
                                    child: FractionallySizedBox(
                                      widthFactor: 0.5,
                                      child: Container(
                                        margin: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() => _selectedIndex = 0);
                                            _pageController.animateToPage(0,
                                                duration: const Duration(milliseconds: 450),
                                                curve: Curves.easeInOutCubic);
                                          },
                                          behavior: HitTestBehavior.opaque,
                                          child: Center(
                                            child: AnimatedDefaultTextStyle(
                                              duration: const Duration(milliseconds: 250),
                                              style: TextStyle(
                                                color: _selectedIndex == 0
                                                    ? const Color(0xFF006D5B)
                                                    : Colors.white70,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              child: const Text("Menunggu"),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() => _selectedIndex = 1);
                                            _pageController.animateToPage(1,
                                                duration: const Duration(milliseconds: 450),
                                                curve: Curves.easeInOutCubic);
                                          },
                                          behavior: HitTestBehavior.opaque,
                                          child: Center(
                                            child: AnimatedDefaultTextStyle(
                                              duration: const Duration(milliseconds: 250),
                                              style: TextStyle(
                                                color: _selectedIndex == 1
                                                    ? const Color(0xFF006D5B)
                                                    : Colors.white70,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              child: const Text("Riwayat"),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Info card
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.13),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.15)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.2),
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
                                        _selectedIndex == 0
                                            ? "${pendingList.length} Pengajuan Menunggu"
                                            : "${riwayatList.length} Riwayat Tersedia",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        _selectedIndex == 0
                                            ? "Perlu tindakan segera"
                                            : "Daftar izin yang telah diproses",
                                        style: const TextStyle(
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

                  // ===== CONTENT WITH PAGEVIEW =====
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      children: [
                        // Page 0: Menunggu (Pending)
                        _buildGuruList(pendingList, true),
                        // Page 1: Riwayat
                        _buildGuruList(riwayatList, false),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildGuruList(List<dynamic> list, bool isPending) {
    if (list.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.45,
          alignment: Alignment.center,
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
              Text(
                isPending
                    ? "Tidak ada pengajuan izin yang perlu\nditindaklanjuti saat ini."
                    : "Belum ada riwayat persetujuan izin.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
      itemCount: list.length,
      itemBuilder: (context, index) {
        var izin = list[index];
        String namaSiswa = izin['siswa']['namaLengkap'];
        String jenisIzin = izin['jenisIzin'] ?? '-';
        String alasan = izin['alasan'] ?? '-';
        String tglMulai = _formatIsoDateToID(izin['tanggalMulai']);
        String tglSelesai = _formatIsoDateToID(izin['tanggalSelesai']);
        String file = izin['fileBukti'] ?? "Tidak ada lampiran";

        return _buildApprovalCard(
            izin['id'],
            namaSiswa,
            jenisIzin,
            alasan,
            "$tglMulai s/d $tglSelesai",
            file,
            index,
            status: izin['status']);
      },
    );
  }

  Widget _buildApprovalCard(int izinId, String name, String jenis,
      String reason, String date, String attachment, int index, {String? status}) {
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

    Color statusBgColor;
    Color statusTextColor;
    Color statusBorderColor;
    IconData statusIcon;
    String statusText;

    if (status == 'Disetujui') {
      statusBgColor = const Color(0xFFE8F5E9);
      statusTextColor = const Color(0xFF2E7D32);
      statusBorderColor = const Color(0xFFA5D6A7);
      statusIcon = Icons.check_circle_rounded;
      statusText = "Disetujui";
    } else if (status == 'Ditolak') {
      statusBgColor = const Color(0xFFFFEBEE);
      statusTextColor = const Color(0xFFC62828);
      statusBorderColor = const Color(0xFFEF9A9A);
      statusIcon = Icons.cancel_rounded;
      statusText = "Ditolak";
    } else {
      statusBgColor = const Color(0xFFFFF3E0);
      statusTextColor = const Color(0xFFE65100);
      statusBorderColor = const Color(0xFFFFCC80);
      statusIcon = Icons.schedule_rounded;
      statusText = "Menunggu";
    }

    return Container(
      key: ValueKey('card_${izinId}_$status'),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              color: jenisColor.withValues(alpha: 0.05),
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
                      colors: [jenisColor, jenisColor.withValues(alpha: 0.7)],
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
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusBorderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon,
                          size: 11, color: statusTextColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusTextColor,
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
                            ? const Color(0xFF006D5B).withValues(alpha: 0.3)
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

                if (status == 'Pending')
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
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: status == 'Disetujui' ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      status == 'Disetujui' ? "Telah Disetujui" : "Ditolak",
                      style: TextStyle(
                        color: status == 'Disetujui' ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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