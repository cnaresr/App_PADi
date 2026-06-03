import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
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
      throw Exception('Failed to load items');
    }
  }

  Future<void> addItem(String name, String description) async {
    await http.post(
      Uri.parse('$baseUrl/items'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name, 'description': description}),
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