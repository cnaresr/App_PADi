// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io' show Platform; 
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint; 
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    String host;
    if (!kIsWeb && Platform.isAndroid) {
      host = 'http://192.168.1.98:3000';
    } else {
      host = 'http://localhost:3000';
    }
    return '$host/api'; 
  }

  // --- FUNGSI OTENTIKASI ---
  // [UPDATE]: Parameter pertama diubah namanya menjadi 'identifier' agar bisa untuk email atau username
  static Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'), 
        headers: {'Content-Type': 'application/json'},
        // Kita kirimkan sebagai 'username' ke backend (Express akan membaca ini di loginIdentifier)
        body: json.encode({'username': identifier, 'password': password}), 
      );
      return json.decode(response.body);
    } catch (e) {
      debugPrint("ERROR API (login): $e");
      return {'status': 'error', 'message': 'Terjadi kesalahan koneksi ke server'};
    }
  }

  // --- FUNGSI ABSENSI ---
  static Future<Map<String, dynamic>> kirimAbsensiMasuk({
    required int userId, // [DIUBAH] Menggunakan userId
    required List<double> faceEmbedding,
    required double latitude,
    required double longitude,
    required String fotoMasuk, // [BARU] Tambahkan foto (sebagai Base64 String)
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/absensi/masuk'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId, // [DIUBAH] Mengirim userId ke backend
          'faceEmbedding': faceEmbedding,
          'latitude': latitude,
          'longitude': longitude,
          'fotoMasuk': fotoMasuk, // [BARU] Kirim foto ke backend
        }),
      );

      // [PERBAIKAN] Cek status code SEBELUM mencoba decode JSON
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody = jsonDecode(response.body);
        return {'success': true, 'message': responseBody['message'] ?? 'Absensi berhasil.'};
      } else {
        // Jika response dari server bukan JSON (misal: halaman error HTML)
        try {
          final errorBody = jsonDecode(response.body);
          return {'success': false, 'message': errorBody['message'] ?? 'Gagal: Terjadi kesalahan di server.'};
        } catch(e) {
          return {'success': false, 'message': 'Server Error (Kode: ${response.statusCode}). Response tidak valid.'};
        }
      }
    } catch (e) {
      debugPrint('Error di ApiService (kirimAbsensiMasuk): $e');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // [BARU] Fungsi untuk mengirim absensi pulang
  static Future<Map<String, dynamic>> kirimAbsensiPulang({
    required int userId,
    required List<double> faceEmbedding,
    required double latitude,
    required double longitude,
    required String fotoPulang, // Foto bukti pulang
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/absensi/pulang'), // Panggil endpoint /pulang
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'faceEmbedding': faceEmbedding,
          'latitude': latitude,
          'longitude': longitude,
          'fotoPulang': fotoPulang, // Kirim foto pulang
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody = jsonDecode(response.body);
        // Berikan pesan sukses yang lebih spesifik untuk pulang
        return {'success': true, 'message': responseBody['message'] ?? 'Absensi pulang berhasil.'};
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          return {'success': false, 'message': errorBody['message'] ?? 'Gagal: Terjadi kesalahan di server.'};
        } catch(e) {
          return {'success': false, 'message': 'Server Error (Kode: ${response.statusCode}). Response tidak valid.'};
        }
      }
    } catch (e) {
      debugPrint('Error di ApiService (kirimAbsensiPulang): $e');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // --- FUNGSI DASHBOARD ---
  static Future<Map<String, dynamic>> getDashboardData(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/$userId'), 
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
        Uri.parse('$baseUrl/guru/dashboard/$userId'), 
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
}