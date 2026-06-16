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
  // --- FUNGSI PERIZINAN (DINAMIS) ---
  
  // 1. Fungsi Siswa Mengirim Izin (Multipart untuk File)
  static Future<Map<String, dynamic>> ajukanIzin({
    required int userId,
    required String tanggalMulai,
    required String tanggalSelesai,
    required String jenisIzin,
    required String alasan,
    String? filePath,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/perizinan'));
      request.fields['userId'] = userId.toString();
      request.fields['tanggalMulai'] = tanggalMulai;
      request.fields['tanggalSelesai'] = tanggalSelesai;
      request.fields['jenisIzin'] = jenisIzin;
      request.fields['alasan'] = alasan;

      if (filePath != null) {
        request.files.add(await http.MultipartFile.fromPath('fileBukti', filePath));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Terjadi kesalahan sistem saat mengirim file.'};
    }
  }

  // 2. Fungsi Guru Mengambil Daftar Izin Pending
  static Future<List<dynamic>> getIzinPending() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/perizinan/pending'));
      if (response.statusCode == 200) {
        return json.decode(response.body)['data'];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 3. Fungsi Guru Menyetujui/Menolak
  static Future<Map<String, dynamic>> updateStatusIzin(int izinId, String status, int guruUserId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/perizinan/$izinId/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'statusUpdate': status, 'guruUserId': guruUserId}),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal memperbarui status.'};
    }
  }
}