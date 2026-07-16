import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  int _userId = 0;
  String _namaLengkap = "Memuat...";
  String _kelasAtauNip = "Memuat...";
  String _role = "";
  String _email = "";
  
  // Variabel baru untuk statistik dan riwayat
  int _hadirBulanIni = 0;
  int _persentaseKehadiran = 0;
  List<dynamic> _riwayatAbsensi = [];
  List<dynamic> _riwayatPerizinan = [];
  List<dynamic> _jadwalAktif = [];

  // [DIUBAH] Variabel geofencing sekarang menyimpan poligon, bukan radius.
  List<Map<String, double>>? _schoolPolygon;
  bool _isGeofenceActive = true;

  // Getters
  int get userId => _userId;
  String get namaLengkap => _namaLengkap;
  String get kelasAtauNip => _kelasAtauNip;
  String get role => _role;
  String get email => _email;
  int get hadirBulanIni => _hadirBulanIni;
  int get persentaseKehadiran => _persentaseKehadiran;
  List<dynamic> get riwayatAbsensi => _riwayatAbsensi;
  List<dynamic> get riwayatPerizinan => _riwayatPerizinan;
  List<dynamic> get jadwalAktif => _jadwalAktif;

  // [BARU] Getter untuk data poligon dan status aktif geofence.
  List<Map<String, double>>? get schoolPolygon => _schoolPolygon;
  bool get isGeofenceActive => _isGeofenceActive;

  // Menyimpan data Akun saat login
  void setUserData(int id, String nama, String detail, String roleUser, {String emailStr = ""}) {
    _userId = id;
    _namaLengkap = nama;
    _kelasAtauNip = detail;
    _role = roleUser;
    _email = emailStr;
    notifyListeners();
  }

  // [BARU] Setter untuk menyimpan data poligon dari API.
  void setSchoolPolygon(List<Map<String, double>> polygon) {
    _schoolPolygon = polygon;
    notifyListeners();
  }

  void setGeofenceActive(bool active) {
    _isGeofenceActive = active;
    notifyListeners();
  }

  // Menyimpan data Statistik & Riwayat dari API Dashboard
  void setDashboardData(int hadir, int persentase, List<dynamic> absensi, List<dynamic> perizinan, {List<dynamic> jadwal = const [], Map<String, dynamic>? geofence}) {
    _hadirBulanIni = hadir;
    _persentaseKehadiran = persentase;
    _riwayatAbsensi = absensi;
    _riwayatPerizinan = perizinan;
    if (jadwal.isNotEmpty) {
      _jadwalAktif = jadwal;
    }
    if (geofence != null) {
      _isGeofenceActive = geofence['isActive'] ?? true;
      if (geofence['polygon'] != null) {
        try {
          List<Map<String, double>> polygon = (geofence['polygon'] as List)
            .map((point) => {
                  'latitude': (point[1] as num).toDouble(),
                  'longitude': (point[0] as num).toDouble(),
                })
            .toList();
          _schoolPolygon = polygon;
        } catch (e) {
          debugPrint("Error parsing polygon geofence in setDashboardData: $e");
        }
      } else {
        _schoolPolygon = null;
      }
    }
    notifyListeners(); // Memicu UI untuk reload otomatis dengan data asli
  }

  void clearData() {
    _userId = 0;
    _namaLengkap = "";
    _kelasAtauNip = "";
    _role = "";
    _email = "";
    _hadirBulanIni = 0;
    _persentaseKehadiran = 0;
    _riwayatAbsensi = [];
    _riwayatPerizinan = [];
    _jadwalAktif = [];
    
    // [DIUBAH] Bersihkan data poligon saat logout.
    _schoolPolygon = null;
    _isGeofenceActive = true;
    _jumlahIzinPending = 0;
    _persentaseKehadiranKelas = 0;
    _rekapAbsensiKelas = [];
    _jadwalMengajar = [];
    _izinPendingGuru = [];
    _izinRiwayatGuru = [];
    notifyListeners();
  }

  // --- VARIABEL KHUSUS GURU ---
  int _jumlahIzinPending = 0;
  int _persentaseKehadiranKelas = 0;
  List<dynamic> _rekapAbsensiKelas = [];
  List<dynamic> _jadwalMengajar = [];
  List<dynamic> _izinPendingGuru = [];
  List<dynamic> _izinRiwayatGuru = [];

  // Getters Guru
  int get jumlahIzinPending => _jumlahIzinPending;
  int get persentaseKehadiranKelas => _persentaseKehadiranKelas;
  List<dynamic> get rekapAbsensiKelas => _rekapAbsensiKelas;
  List<dynamic> get jadwalMengajar => _jadwalMengajar;
  List<dynamic> get izinPendingGuru => _izinPendingGuru;
  List<dynamic> get izinRiwayatGuru => _izinRiwayatGuru;

  // Setter untuk menyimpan data Guru
  void setGuruDashboardData(int izinPending, int persentase, List<dynamic> rekap, List<dynamic> jadwal) {
    _jumlahIzinPending = izinPending;
    _persentaseKehadiranKelas = persentase;
    _rekapAbsensiKelas = rekap;
    _jadwalMengajar = jadwal;
    _jadwalAktif = jadwal;
    notifyListeners();
  }

  void setIzinGuruData(List<dynamic> pending, List<dynamic> riwayat) {
    _izinPendingGuru = pending;
    _izinRiwayatGuru = riwayat;
    notifyListeners();
  }
}