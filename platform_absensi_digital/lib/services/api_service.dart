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

  // Variabel untuk menyimpan token login admin setelah login sukses
  static String? _token;

  // Fungsi untuk menset token setelah admin berhasil login
  static void setToken(String token) {
    _token = token;
  }

  // Helper untuk membuat header request + Token Authorization
  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  // ========================================================
  // 1. API UNTUK CRUD USERS (MAHASISWA/GURU) OLEH ADMIN
  // ========================================================

  // [GET ALL USERS]
  Future<List<dynamic>> getAllUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/users'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat data user: ${response.body}');
    }
  }

  // [CREATE USER]
  Future<bool> createUser(String username, String password, String email, int idRole) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/users'),
      headers: _getHeaders(),
      body: json.encode({
        'username': username,
        'password': password,
        'email': email,
        'id_role': idRole,
      }),
    );
    return response.statusCode == 201;
  }

  // [UPDATE USER]
  Future<bool> updateUser(int idUser, String username, String email, int idRole) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/users/$idUser'),
      headers: _getHeaders(),
      body: json.encode({
        'username': username,
        'email': email,
        'id_role': idRole,
      }),
    );
    return response.statusCode == 200;
  }

  // [DELETE USER]
  Future<bool> deleteUser(int idUser) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/users/$idUser'),
      headers: _getHeaders(),
    );
    return response.statusCode == 200;
  }

  // ========================================================
  // 2. API UNTUK CRUD ABSENSI OLEH ADMIN
  // ========================================================

  // [GET ALL PRESENSI]
  Future<List<dynamic>> getAllPresensi() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/presensi'),
      headers: _getHeaders(),
    );

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
    return response.statusCode == 200;
  }
}