import 'package:flutter/material.dart';

class PusatBantuanPage extends StatelessWidget {
  final bool isGuru;
  const PusatBantuanPage({super.key, this.isGuru = false});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> siswaFaqList = [
      {
        'q': 'Bagaimana cara melakukan absensi?',
        'a': 'Buka halaman Absensi, pastikan lokasi GPS aktif dan Anda berada di dalam area sekolah. Arahkan wajah ke kamera, lalu tekan tombol "Absen Masuk". Sistem akan memverifikasi wajah Anda secara otomatis.',
        'icon': Icons.fingerprint_rounded,
        'color': const Color(0xFF006D5B),
        'bg': const Color(0xFFE8F5E9),
      },
      {
        'q': 'Kenapa tombol absen tidak aktif?',
        'a': 'Tombol absen hanya aktif saat Anda berada dalam area geofence sekolah. Pastikan GPS/lokasi perangkat Anda aktif dan izin lokasi sudah diberikan ke aplikasi.',
        'icon': Icons.location_on_rounded,
        'color': const Color(0xFF1565C0),
        'bg': const Color(0xFFE3F2FD),
      },
      {
        'q': 'Bagaimana cara mengajukan izin?',
        'a': 'Masuk ke halaman Riwayat, pilih tab "Perizinan", isi formulir dengan lengkap (tanggal, jenis izin, dan alasan), unggah dokumen pendukung jika ada, lalu tekan "Kirim Pengajuan".',
        'icon': Icons.assignment_rounded,
        'color': const Color(0xFF6A1B9A),
        'bg': const Color(0xFFF3E5F5),
      },
      {
        'q': 'Berapa lama proses persetujuan izin?',
        'a': 'Proses persetujuan izin dilakukan oleh guru yang bersangkutan. Anda dapat memantau status pengajuan di tab "Perizinan" pada bagian Status Pengajuan.',
        'icon': Icons.hourglass_top_rounded,
        'color': const Color(0xFFE65100),
        'bg': const Color(0xFFFFF3E0),
      },
      {
        'q': 'Wajah saya tidak terdeteksi, apa yang harus dilakukan?',
        'a': 'Pastikan pencahayaan di sekitar wajah Anda cukup terang, tidak ada objek yang menutupi wajah, dan arahkan wajah tepat ke kamera. Jika masalah berlanjut, hubungi admin sekolah.',
        'icon': Icons.camera_front_rounded,
        'color': const Color(0xFF00796B),
        'bg': const Color(0xFFE0F2F1),
      },
      {
        'q': 'Bagaimana jika saya lupa kata sandi?',
        'a': 'Di halaman login, tekan tombol "Lupa Sandi?" dan ikuti petunjuk yang diberikan. Jika masih mengalami kesulitan, silakan hubungi administrator sekolah Anda.',
        'icon': Icons.lock_reset_rounded,
        'color': const Color(0xFFC62828),
        'bg': const Color(0xFFFFEBEE),
      },
    ];

    final List<Map<String, dynamic>> guruFaqList = [
      {
        'q': 'Bagaimana cara menyetujui izin siswa?',
        'a': 'Buka tab "Perizinan", pilih daftar izin yang berstatus "Pending". Tekan tombol "Setujui" atau "Tolak". Jika disetujui, absensi siswa akan otomatis terisi dengan status Izin/Sakit.',
        'icon': Icons.check_circle_outline_rounded,
        'color': const Color(0xFF006D5B),
        'bg': const Color(0xFFE8F5E9),
      },
      {
        'q': 'Bagaimana melihat rekap kehadiran?',
        'a': 'Buka tab "Beranda" (Dashboard) untuk melihat statistik kehadiran harian secara keseluruhan, atau tab "Profil" untuk opsi lainnya.',
        'icon': Icons.bar_chart_rounded,
        'color': const Color(0xFF1565C0),
        'bg': const Color(0xFFE3F2FD),
      },
      {
        'q': 'Kenapa notifikasi persetujuan tidak muncul?',
        'a': 'Pastikan izin notifikasi di perangkat Anda sudah diaktifkan untuk aplikasi ini. Sistem akan mengirim notifikasi saat ada pengajuan izin baru dari siswa.',
        'icon': Icons.notifications_active_rounded,
        'color': const Color(0xFF6A1B9A),
        'bg': const Color(0xFFF3E5F5),
      },
      {
        'q': 'Bagaimana jika saya lupa kata sandi?',
        'a': 'Silakan hubungi administrator sekolah (Admin) untuk mereset kata sandi akun Guru Anda.',
        'icon': Icons.lock_reset_rounded,
        'color': const Color(0xFFC62828),
        'bg': const Color(0xFFFFEBEE),
      },
    ];

    final List<Map<String, dynamic>> faqList = isGuru ? guruFaqList : siswaFaqList;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
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
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.help_center_rounded,
                                color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 14),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Pusat Bantuan",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                "Pertanyaan yang sering ditanyakan",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Info banner
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                color: Colors.white70, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isGuru 
                                  ? "Jika pertanyaan Anda tidak terjawab di sini, silakan hubungi administrator sekolah."
                                  : "Jika pertanyaan Anda tidak terjawab di sini, silakan hubungi administrator sekolah atau guru wali kelas Anda.",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  height: 1.5),
                              ),
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

          // ===== FAQ LIST =====
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final faq = faqList[index];
                  return _FaqCard(
                    question: faq['q'],
                    answer: faq['a'],
                    icon: faq['icon'],
                    iconColor: faq['color'],
                    iconBg: faq['bg'],
                  );
                },
                childCount: faqList.length,
              ),
            ),
          ),

          // ===== KONTAK ADMIN =====
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2B2A),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.support_agent_rounded,
                            color: Colors.white, size: 22),
                        SizedBox(width: 10),
                        Text(
                          "Masih butuh bantuan?",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isGuru 
                        ? "Hubungi administrator sekolah Anda untuk mendapatkan bantuan lebih lanjut."
                        : "Hubungi wali kelas atau administrator sekolah Anda untuk mendapatkan bantuan lebih lanjut.",
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 13,
                          height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF006D5B),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.email_outlined,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            isGuru ? "Hubungi Admin" : "Hubungi Guru / Admin",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqCard extends StatefulWidget {
  final String question;
  final String answer;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const _FaqCard({
    required this.question,
    required this.answer,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _toggle,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.iconBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          Icon(widget.icon, color: widget.iconColor, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        widget.question,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF1E1E1E),
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 250),
                      turns: _isExpanded ? 0.5 : 0,
                      child: Icon(Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey.shade400, size: 22),
                    ),
                  ],
                ),
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14, left: 4),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        widget.answer,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
