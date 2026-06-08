// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io' show Platform; 
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint; 
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    String host;
    if (!kIsWeb && Platform.isAndroid) {
      host = 'http://10.0.2.2:3000';
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
    required int siswaId,
    required List<double> faceEmbedding,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/absensi/masuk'), 
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