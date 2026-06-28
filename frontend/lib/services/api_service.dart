// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'package:platform_absensi_digital/services/storage_service.dart';

class SessionExpiredException implements Exception {
  final String message;
  SessionExpiredException([this.message = 'SESI_HABIS']);

  @override
  String toString() => message;
}

class ApiService {
  static final StorageService _storageService = StorageService();

  static Future<Map<String, String>> _authHeaders({bool isJson = false}) async {
    final token = await _storageService.getToken();
    final headers = <String, String>{
      'ngrok-skip-browser-warning': 'true',
    };
    if (isJson) {
      headers['Content-Type'] = 'application/json';
    }
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Map<String, String>> _authHeadersMultipart() async {
    final token = await _storageService.getToken();
    final headers = <String, String>{
      'ngrok-skip-browser-warning': 'true',
    }; // Tanpa 'Content-Type' default
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<void> _handleUnauthorizedResponse(
    http.Response response,
  ) async {
    if (response.statusCode == 401 || response.statusCode == 403) {
      await clearLocalSession();
      throw SessionExpiredException();
    }
  }

  static Future<void> clearLocalSession() async {
    await _storageService.clearSession();
  }

  static String get baseUrl {
    // TODO: GANTI string di bawah ini dengan URL ngrok Anda.
    // Contoh: 'https://abcd-12-34-56.ngrok-free.app'
    // Pastikan tidak ada slash '/' di akhir URL.
    String ngrokUrl = 'https://float-passing-washroom.ngrok-free.dev';

    // Jika ngrokUrl tidak kosong, gunakan URL tersebut
    if (ngrokUrl.isNotEmpty) {
      return '$ngrokUrl/api';
    }

    // Konfigurasi bawaan (localhost)
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
  static Future<Map<String, dynamic>> login(
    String identifier,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: json.encode({'username': identifier, 'password': password}),
      );

      final result = json.decode(response.body);
      if (result['status'] == 'success' && result['token'] != null) {
        final data = result['data'] as Map<String, dynamic>;
        final token = result['token'] as String;

        await _storageService.saveSession(
          token: token,
          userId: data['id'] ?? 0,
          name: data['username'] ?? data['nama'] ?? '',
          detail: data['kelas'] ?? data['nip'] ?? '',
          role: data['role'] ?? '',
        );
      }

      return result;
    } catch (e) {
      debugPrint("ERROR API (login): $e");
      return {
        'status': 'error',
        'message': 'Terjadi kesalahan koneksi ke server',
      };
    }
  }

  // --- FUNGSI ABSENSI ---
  static Future<Map<String, dynamic>> kirimAbsensiMasuk({
    required int userId, // [DIUBAH] Menggunakan userId
    required List<double> faceEmbedding,
    required double latitude,
    required double longitude,
    required String
    fotoMasukPath, // [DIUBAH] Menggunakan path file, bukan Base64
  }) async {
    try {
      // [DIUBAH] Menggunakan MultipartRequest untuk mengirim file dan data
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/absensi/masuk'),
      );
      request.headers.addAll(await _authHeadersMultipart());

      // Tambahkan field data
      request.fields['userId'] = userId.toString();
      request.fields['faceEmbedding'] = jsonEncode(
        faceEmbedding,
      ); // Encode list menjadi string JSON
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();

      // Tambahkan file foto
      request.files.add(
        await http.MultipartFile.fromPath('fotoMasuk', fotoMasukPath),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      debugPrint("API Absensi Masuk Status: ${response.statusCode}");
      debugPrint("API Absensi Masuk Body: ${response.body}");

      // [PERBAIKAN] Cek status code SEBELUM mencoba decode JSON
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody = jsonDecode(response.body);
        return {
          'success': true,
          'message': responseBody['message'] ?? 'Absensi berhasil.',
        };
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorBody['message'] ?? 'Gagal: Terjadi kesalahan di server.',
          };
        } catch (_) {
          return {
            'success': false,
            'message': 'Gagal merespons server (Status: ${response.statusCode}).',
          };
        }
      }
    } catch (e, stacktrace) {
      debugPrint('Error di ApiService (kirimAbsensiMasuk): $e\n$stacktrace');
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
    required String fotoPulangPath, // [DIUBAH] Menggunakan path file
  }) async {
    try {
      // [DIUBAH] Menggunakan MultipartRequest
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/absensi/pulang'),
      );
      request.headers.addAll(await _authHeadersMultipart());

      request.fields['userId'] = userId.toString();
      request.fields['faceEmbedding'] = jsonEncode(faceEmbedding);
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();

      request.files.add(
        await http.MultipartFile.fromPath('fotoPulang', fotoPulangPath),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      debugPrint("API Absensi Pulang Status: ${response.statusCode}");
      debugPrint("API Absensi Pulang Body: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody = jsonDecode(response.body);
        // Berikan pesan sukses yang lebih spesifik untuk pulang
        return {
          'success': true,
          'message': responseBody['message'] ?? 'Absensi pulang berhasil.',
        };
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorBody['message'] ?? 'Gagal: Terjadi kesalahan di server.',
          };
        } catch (_) {
          return {
            'success': false,
            'message': 'Gagal merespons server (Status: ${response.statusCode}).',
          };
        }
      }
    } catch (e, stacktrace) {
      debugPrint('Error di ApiService (kirimAbsensiPulang): $e\n$stacktrace');
      debugPrint('Error di ApiService (kirimAbsensiPulang): $e');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // --- FUNGSI DASHBOARD ---
  static Future<Map<String, dynamic>> getDashboardData(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/$userId'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        await _handleUnauthorizedResponse(response);
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
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        await _handleUnauthorizedResponse(response);
        return {
          'status': 'error',
          'message': 'Gagal mengambil data dashboard guru',
        };
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
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/perizinan'),
      );
      request.headers.addAll(await _authHeaders());
      request.fields['userId'] = userId.toString();
      request.fields['tanggalMulai'] = tanggalMulai;
      request.fields['tanggalSelesai'] = tanggalSelesai;
      request.fields['jenisIzin'] = jenisIzin;
      request.fields['alasan'] = alasan;

      if (filePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath('fileBukti', filePath),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        await _handleUnauthorizedResponse(response);
      }
      return json.decode(response.body);
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Terjadi kesalahan sistem saat mengirim file.',
      };
    }
  }

  // 2. Fungsi Guru Mengambil Daftar Izin Pending
  static Future<List<dynamic>> getIzinPending() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/perizinan/pending'),
        headers: await _authHeaders(),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body)['data'];
      }
      await _handleUnauthorizedResponse(response);
      return [];
    } catch (e) {
      return [];
    }
  }

  // 3. Fungsi Guru Menyetujui/Menolak
  static Future<Map<String, dynamic>> updateStatusIzin(
    int izinId,
    String status,
    int guruUserId,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/perizinan/$izinId/status'),
        headers: await _authHeaders(isJson: true),
        body: json.encode({'statusUpdate': status, 'guruUserId': guruUserId}),
      );
      await _handleUnauthorizedResponse(response);
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal memperbarui status.'};
    }
  }

  // --- FUNGSI NOTIFIKASI (BARU) ---

  // 1. Mengambil semua notifikasi siswa
  static Future<List<dynamic>> getNotifications(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifikasi/$userId'),
        headers: await _authHeaders(),
      );
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == 'success') {
          return body['data'] ?? [];
        }
      }
      return [];
    } catch (e) {
      debugPrint("Error getNotifications: $e");
      return [];
    }
  }

  // 2. Mengambil notifikasi yang belum terbaca saja
  static Future<List<dynamic>> getUnreadNotifications(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifikasi/$userId/unread'),
        headers: await _authHeaders(),
      );
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == 'success') {
          return body['data'] ?? [];
        }
      }
      return [];
    } catch (e) {
      debugPrint("Error getUnreadNotifications: $e");
      return [];
    }
  }

  // 3. Menandai satu notifikasi sebagai terbaca
  static Future<Map<String, dynamic>> markNotificationAsRead(int id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notifikasi/$id/read'),
        headers: await _authHeaders(isJson: true),
      );
      return json.decode(response.body);
    } catch (e) {
      debugPrint("Error markNotificationAsRead: $e");
      return {'status': 'error', 'message': 'Terjadi kesalahan sistem.'};
    }
  }

  // 4. Menandai semua notifikasi siswa sebagai terbaca
  static Future<Map<String, dynamic>> markAllNotificationsAsRead(
    int userId,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notifikasi/$userId/read-all'),
        headers: await _authHeaders(isJson: true),
      );
      return json.decode(response.body);
    } catch (e) {
      debugPrint("Error markAllNotificationsAsRead: $e");
      return {'status': 'error', 'message': 'Terjadi kesalahan sistem.'};
    }
  }
}
