import 'dart:convert';
import 'dart:io' show Platform; // Untuk mendeteksi platform
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint; // Untuk mendeteksi web dan print debug
import 'package:http/http.dart' as http;

class ApiService {
  // Base URL dinamis yang mendeteksi platform (Android/Web/Lainnya)
  // dan langsung mengarah ke root API.
  static String get baseUrl {
    String host;
    if (!kIsWeb && Platform.isAndroid) {
      // Gunakan 10.0.2.2 untuk emulator Android
      host = 'http://10.0.2.2:3000';
    } else {
      // Gunakan localhost untuk web atau platform lain
      host = 'http://localhost:3000';
    }
    return '$host/api'; // Semua endpoint berada di bawah /api
  }

  // --- FUNGSI OTENTIKASI ---
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'), // Endpoint: /api/auth/login
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );
      return json.decode(response.body);
    } catch (e) {
      debugPrint("ERROR API (login): $e");
      return {'status': 'error', 'message': 'Terjadi kesalahan koneksi ke server'};
    }
  }

  /// Mengirim data absensi masuk (wajah & lokasi) ke backend.
  /// Sesuai dengan alur di absen.md
  static Future<Map<String, dynamic>> kirimAbsensiMasuk({
    required int siswaId,
    required List<double> faceEmbedding,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/absensi/masuk'), // Endpoint: /api/absensi/masuk
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'siswaId': siswaId,
          'faceEmbedding': faceEmbedding,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': responseBody['message']};
      } else {
        return {'success': false, 'message': responseBody['message'] ?? 'Gagal melakukan absensi.'};
      }
    } catch (e) {
      debugPrint('Error di ApiService (kirimAbsensiMasuk): $e');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // --- FUNGSI DASHBOARD ---
  static Future<Map<String, dynamic>> getDashboardData(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/$userId'), // Endpoint: /api/dashboard/{userId}
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'status': 'error', 'message': 'Gagal mengambil data dashboard'};
      }
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // --- FUNGSI GURU ---
  static Future<Map<String, dynamic>> getDashboardGuru(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/guru/dashboard/$userId'), // Endpoint: /api/guru/dashboard/{userId}
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'status': 'error', 'message': 'Gagal mengambil data dashboard guru'};
      }
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // --- CONTOH FUNGSI BAWAAN (jika masih diperlukan) ---
  /*
  static Future<List<dynamic>> getItems() async {
    final response = await http.get(Uri.parse('$baseUrl/items')); // Endpoint: /api/items
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load items');
    }
  }

  static Future<void> addItem(String name, String description) async {
    await http.post(
      Uri.parse('$baseUrl/items'), // Endpoint: /api/items
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name, 'description': description}),
    );
  }
  */
}