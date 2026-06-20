import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:platform_absensi_digital/providers/user_provider.dart';
import 'package:platform_absensi_digital/services/api_service.dart';
import 'package:intl/intl.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    if (userId > 0) {
      final notifs = await ApiService.getNotifications(userId);
      setState(() {
        _notifications = notifs;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAllAsRead() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    if (userId > 0) {
      setState(() => _isLoading = true);
      await ApiService.markAllNotificationsAsRead(userId);
      final notifs = await ApiService.getNotifications(userId);
      setState(() {
        _notifications = notifs;
        _isLoading = false;
      });
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return "-";
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 60) {
        return "${difference.inMinutes} Menit Lalu";
      } else if (difference.inHours < 24) {
        return "${difference.inHours} Jam Lalu";
      } else if (difference.inDays == 1) {
        return "Kemarin, ${DateFormat('HH:mm').format(date)}";
      } else {
        return DateFormat('dd MMM yyyy, HH:mm').format(date);
      }
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = _notifications.any((n) => !(n['isRead'] ?? n['is_read'] ?? false));

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E1E1E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Notifikasi", style: TextStyle(color: Color(0xFF1E1E1E), fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: false,
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                "Tandai Dibaca",
                style: TextStyle(color: Color(0xFF006D5B), fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchNotifications,
        color: const Color(0xFF006D5B),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF006D5B)))
            : _notifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24.0),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotifItem(_notifications[index]);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F3F1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_off_outlined, color: Color(0xFF006D5B), size: 50),
              ),
              const SizedBox(height: 20),
              const Text(
                "Belum Ada Notifikasi",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E1E1E)),
              ),
              const SizedBox(height: 8),
              const Text(
                "Semua pemberitahuan aktivitas sekolah Anda\nakan muncul di sini.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotifItem(Map<String, dynamic> notif) {
    final bool isRead = notif['isRead'] ?? notif['is_read'] ?? false;
    final String title = notif['judul'] ?? "Notifikasi";
    final String body = notif['isiPesan'] ?? notif['isi_pesan'] ?? "";
    final String time = _formatTime(notif['createdAt'] ?? notif['created_at']);
    final String tipe = notif['tipe'] ?? 'Sistem';

    IconData icon;
    Color bgIcon;
    Color iconColor;

    if (tipe == 'Peringatan') {
      icon = Icons.warning_amber_rounded;
      bgIcon = const Color(0xFFFFEBEE);
      iconColor = const Color(0xFFC62828);
    } else if (tipe == 'Pengingat') {
      icon = Icons.notifications_active_rounded;
      bgIcon = const Color(0xFFFFF3E0);
      iconColor = const Color(0xFFEF6C00);
    } else {
      icon = Icons.info_outline_rounded;
      bgIcon = const Color(0xFFE8F3F1);
      iconColor = const Color(0xFF006D5B);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? Colors.white.withOpacity(0.7) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isRead ? null : Border.all(color: iconColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isRead ? 0.005 : 0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgIcon, borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                          fontSize: 14,
                          color: const Color(0xFF1E1E1E),
                        ),
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: const TextStyle(color: Colors.grey, fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: const TextStyle(color: Colors.black26, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}