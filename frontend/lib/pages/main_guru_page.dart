import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:platform_absensi_digital/pages/dashboard_guru_page.dart';
import 'package:platform_absensi_digital/pages/rekap_absensi_page.dart';
import 'package:platform_absensi_digital/pages/izin_guru_page.dart';
import 'package:platform_absensi_digital/pages/profil_guru_page.dart';
import 'package:platform_absensi_digital/providers/user_provider.dart';
import 'package:platform_absensi_digital/services/api_service.dart';
import 'package:platform_absensi_digital/services/notification_service.dart';
import 'package:platform_absensi_digital/services/firebase_messaging_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';

class MainGuruPage extends StatefulWidget {
  const MainGuruPage({super.key});
  @override
  State<MainGuruPage> createState() => _MainGuruPageState();
}

class _MainGuruPageState extends State<MainGuruPage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final List<Widget> _pages = const [
    DashboardGuruPage(),
    RekapAbsensiPage(),
    IzinGuruPage(),
    ProfilGuruPage(),
  ];
  StreamSubscription<RemoteMessage>? _notifSubscription;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNotifications(userProvider.userId);
    });

    _notifSubscription = FirebaseMessagingService.onMessageStream.listen((message) {
      if (mounted) {
        ApiService.getDashboardGuru(userProvider.userId).then((dashRes) {
          if (dashRes['status'] == 'success') {
            userProvider.setGuruDashboardData(
              dashRes['data']['izinPending'] ?? 0,
              dashRes['data']['persentaseKehadiranKelas'] ?? 0,
              dashRes['data']['rekapAbsensiKelas'] ?? [],
              dashRes['data']['jadwalAktif'] ?? [],
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _notifSubscription?.cancel();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (_selectedIndex == index) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      extendBody: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildFloatingNavBar(),
    );
  }

  Widget _buildFloatingNavBar() {
    final items = [
      _NavItem(icon: Icons.grid_view_rounded, activeIcon: Icons.grid_view_rounded, label: "Beranda"),
      _NavItem(icon: Icons.people_alt_outlined, activeIcon: Icons.people_alt_rounded, label: "Rekap"),
      _NavItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long_rounded, label: "Perizinan"),
      _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: "Profil"),
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20, top: 8),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFF1C2B2A),
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF006D5B).withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: List.generate(items.length, (index) {
            final isSelected = _selectedIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => _onNavTap(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF006D5B) : Colors.transparent,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          isSelected ? items[index].activeIcon : items[index].icon,
                          key: ValueKey(isSelected),
                          color: isSelected ? Colors.white : Colors.white.withOpacity(0.45),
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 3),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                          color: isSelected ? Colors.white : Colors.white.withOpacity(0.45),
                        ),
                        child: Text(items[index].label),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
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
        for (var notif in unread) {
          if (!mounted) return;
          await NotificationService.showNotification(
            id: notif['id_notifikasi'] ?? notif['id'] ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
            title: notif['judul'] ?? "Notifikasi PADI",
            body: notif['isiPesan'] ?? notif['isi_pesan'] ?? "",
          );
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
                  decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
                  child: Icon(icon, color: iconColor, size: 40),
                ),
                const SizedBox(height: 20),
                Text(
                  notif['judul'] ?? "Notifikasi Baru",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                ),
                const SizedBox(height: 12),
                Text(
                  notif['isiPesan'] ?? "",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006D5B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      await ApiService.markNotificationAsRead(notif['id_notifikasi'] ?? notif['id']);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text(
                      "Mengerti",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}