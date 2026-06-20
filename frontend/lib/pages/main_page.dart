import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:platform_absensi_digital/pages/home_page.dart';
import 'package:platform_absensi_digital/pages/absensi_page.dart';
import 'package:platform_absensi_digital/pages/izin_page.dart';
import 'package:platform_absensi_digital/pages/profil_page.dart';
import 'package:platform_absensi_digital/providers/user_provider.dart';
import 'package:platform_absensi_digital/services/api_service.dart';

import 'package:platform_absensi_digital/services/notification_service.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Index untuk melacak menu mana yang sedang dipilih (0 = Beranda)
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Ambil data user sekali saja saat inisialisasi, tanpa "mendengarkan" perubahan
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Inisialisasi daftar halaman di initState agar tidak dibuat ulang setiap saat
    _pages = [
      const HomePage(),
      AbsensiPage(siswaId: userProvider.userId), // Halaman absensi
      const IzinPage(openRiwayatTab: true), // Halaman riwayat
      const ProfilPage(), // Halaman profil
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNotifications(userProvider.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      
      // [PERBAIKAN SIBER]: IndexedStack dihapus! 
      // Sekarang halaman hanya akan dibangun (dan kamera dinyalakan) 
      // JIKA index-nya benar-benar sedang aktif dipilih.
      body: _pages[_selectedIndex],
      
      // Menggunakan NavigationBar Material 3 agar mirip dengan desain Anda
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: Color(0xFF006D5B), fontSize: 12, fontWeight: FontWeight.bold);
            }
            return const TextStyle(color: Colors.grey, fontSize: 12);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Color(0xFF006D5B));
            }
            return const IconThemeData(color: Colors.grey);
          }),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFC8F6E6), // Warna hijau muda untuk highlight menu aktif
          destinations: const [
            NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: "Beranda"),
            NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: "Absensi"),
            NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: "Riwayat"),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }

  Future<void> _checkNotifications(int userId) async {
    if (userId <= 0) return;
    try {
      final unread = await ApiService.getUnreadNotifications(userId);
      if (!mounted) return;
      if (unread.isNotEmpty) {
        // Tampilkan popup & notifikasi bar satu per satu
        for (var notif in unread) {
          if (!mounted) return;

          // Pemicu notifikasi sistem luar aplikasi (Notification Bar)
          await NotificationService.showNotification(
            id: notif['id_notifikasi'] ?? notif['id'] ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
            title: notif['judul'] ?? "Notifikasi PADI",
            body: notif['isiPesan'] ?? notif['isi_pesan'] ?? "",
          );

          // Tampilkan pop-up dialog dalam aplikasi
          await _showNotifPopup(notif);
        }
      }
    } catch (e) {
      debugPrint("Error checking notifications: $e");
    }
  }

  Future<void> _showNotifPopup(Map<String, dynamic> notif) {
    IconData icon;
    Color iconBgColor;
    Color iconColor;

    final tipe = notif['tipe'] ?? 'Sistem';
    if (tipe == 'Peringatan') {
      icon = Icons.warning_amber_rounded;
      iconBgColor = const Color(0xFFFFEBEE);
      iconColor = const Color(0xFFC62828);
    } else if (tipe == 'Pengingat') {
      icon = Icons.notifications_active_rounded;
      iconBgColor = const Color(0xFFFFF3E0);
      iconColor = const Color(0xFFEF6C00);
    } else {
      icon = Icons.info_outline_rounded;
      iconBgColor = const Color(0xFFE8F3F1);
      iconColor = const Color(0xFF006D5B);
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 10,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 40),
                ),
                const SizedBox(height: 20),
                Text(
                  notif['judul'] ?? "Notifikasi Baru",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  notif['isiPesan'] ?? "",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF151B2B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      // Tandai sebagai terbaca
                      await ApiService.markNotificationAsRead(notif['id_notifikasi'] ?? notif['id']);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      "Mengerti",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}