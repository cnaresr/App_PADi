import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api'; // Ditambahkan /api sesuai route backend
    }
    return 'http://localhost:3000/api';
  }

  // --- FUNGSI LOGIN YANG DIBUTUHKAN HALAMAN LOGIN ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'), // <--- TAMBAHKAN /auth DI SINI
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      return json.decode(response.body);
    } catch (e) {
      print("ERROR API: $e");
      return {'status': 'error', 'message': 'Terjadi kesalahan koneksi ke server'};
    }
  }

  // --- FUNGSI BAWAAN ANDA ---
  Future<List<dynamic>> getItems() async {
    final response = await http.get(Uri.parse('$baseUrl/items'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat data presensi: ${response.body}');
    }
  }

  // [UPDATE PRESENSI]
  Future<bool> updatePresensi(int idPresensi, String status, String mataKuliah) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/presensi/$idPresensi'),
      headers: _getHeaders(),
      body: json.encode({
        'status': status,
        'mata_kuliah': mataKuliah,
      }),
    );
    return response.statusCode == 200;
  }

  // [DELETE PRESENSI]
  Future<bool> deletePresensi(int idPresensi) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/presensi/$idPresensi'),
      headers: _getHeaders(),
    );
  }
  Future<Map<String, dynamic>> getDashboardData(int userId) async {
  try {
    // Sesuaikan URL baseUrl Anda jika menggunakan emulator (misal http://10.0.2.2:3000)
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/api/dashboard/$userId'),
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
  // Fungsi Mengambil Data Dashboard Guru
  Future<Map<String, dynamic>> getDashboardGuru(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/guru/dashboard/$userId'),
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