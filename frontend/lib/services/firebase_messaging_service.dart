import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

// Setup background handler (harus di top level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Pastikan inisialisasi Firebase sudah dipanggil di main() jika perlu,
  // tapi background handler biasanya cukup menerima pesan.
  print("Handling a background message: ${message.messageId}");
}

class FirebaseMessagingService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Meminta izin notifikasi (wajib di Android 13+)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Inisialisasi flutter_local_notifications untuk menampilkan popup saat app di foreground
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Notification clicked: ${response.payload}');
      },
    );

    // Setup channel khusus Android agar notifikasi muncul dengan suara/head-up
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // name
      description: 'This channel is used for important notifications.', // description
      importance: Importance.max,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Mendaftarkan background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Mendengarkan pesan masuk saat aplikasi berjalan di Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        _showLocalNotification(message, channel);
      }
    });

    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");
    // Token akan dikirim ke server saat user login, atau bisa dikirim di sini jika login dipertahankan
    
    // Dengarkan perubahan token
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print("FCM Token refreshed: $newToken");
      // Kita bisa update token, tapi butuh userId dan jwtToken yang sedang aktif.
      // Bisa disimpan di memory state.
    });
  }

  static Future<void> _showLocalNotification(
      RemoteMessage message, AndroidNotificationChannel channel) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  // Fungsi untuk mengirim token FCM ke backend
  static Future<void> updateFCMTokenToServer(int userId, String jwtToken) async {
    try {
      String? fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken == null) return;

      // Sesuaikan URL Backend Anda (jangan lupa ganti localhost dengan IP jika pakai physical device)
      final String baseUrl = Platform.isAndroid ? 'http://10.0.2.2:5000' : 'http://localhost:5000';

      final response = await http.put(
        Uri.parse('$baseUrl/api/auth/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({
          'userId': userId,
          'fcmToken': fcmToken,
        }),
      );

      if (response.statusCode == 200) {
        print("FCM Token successfully updated to server.");
      } else {
        print("Failed to update FCM Token: ${response.body}");
      }
    } catch (e) {
      print("Error updating FCM token to server: $e");
    }
  }
}
