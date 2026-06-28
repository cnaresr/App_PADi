import 'package:flutter/material.dart';

enum PopupType { success, error, warning, info }

class CustomPopup {
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    PopupType type = PopupType.info,
    VoidCallback? onClose,
  }) {
    if (!context.mounted) return;

    Color primaryColor;
    IconData icon;
    String defaultTitle;

    switch (type) {
      case PopupType.success:
        primaryColor = const Color(0xFF006D5B);
        icon = Icons.check_circle_rounded;
        defaultTitle = "Berhasil";
        break;
      case PopupType.error:
        primaryColor = const Color(0xFFC62828);
        icon = Icons.cancel_rounded;
        defaultTitle = "Gagal";
        break;
      case PopupType.warning:
        primaryColor = const Color(0xFFFF9800);
        icon = Icons.warning_rounded;
        defaultTitle = "Peringatan";
        break;
      case PopupType.info:
        primaryColor = const Color(0xFF2196F3);
        icon = Icons.info_rounded;
        defaultTitle = "Info";
        break;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: Colors.white,
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: primaryColor,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  title ?? defaultTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Message
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                // Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (onClose != null) onClose();
                    },
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
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
