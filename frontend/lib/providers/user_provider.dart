import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  int _userId = 0;
  String _namaLengkap = "Memuat...";
  String _kelasAtauNip = "Memuat...";
  String _role = "";
  
  // Variabel baru untuk statistik dan riwayat
  int _hadirBulanIni = 0;
  int _persentaseKehadiran = 0;
  List<dynamic> _riwayatAbsensi = [];
  List<dynamic> _riwayatPerizinan = [];

  // [DIUBAH] Variabel geofencing sekarang menyimpan poligon, bukan radius.
  List<Map<String, double>>? _schoolPolygon;
  // Getters
  int get userId => _userId;
  String get namaLengkap => _namaLengkap;
  String get kelasAtauNip => _kelasAtauNip;
  String get role => _role;
  int get hadirBulanIni => _hadirBulanIni;
  int get persentaseKehadiran => _persentaseKehadiran;
  List<dynamic> get riwayatAbsensi => _riwayatAbsensi;
  List<dynamic> get riwayatPerizinan => _riwayatPerizinan;

  // [BARU] Getter untuk data poligon.
  List<Map<String, double>>? get schoolPolygon => _schoolPolygon;
  // Menyimpan data Akun saat login
  void setUserData(int id, String nama, String detail, String roleUser) {
    _userId = id;
    _namaLengkap = nama;
    _kelasAtauNip = detail;
    _role = roleUser;
    notifyListeners();
  }

  // [BARU] Setter untuk menyimpan data poligon dari API.
  void setSchoolPolygon(List<Map<String, double>> polygon) {
    _schoolPolygon = polygon;
    notifyListeners();
  }

  // Menyimpan data Statistik & Riwayat dari API Dashboard
  void setDashboardData(int hadir, int persentase, List<dynamic> absensi, List<dynamic> perizinan) {
    _hadirBulanIni = hadir;
    _persentaseKehadiran = persentase;
    _riwayatAbsensi = absensi;
    _riwayatPerizinan = perizinan;
    notifyListeners(); // Memicu UI untuk reload otomatis dengan data asli
  }

  void clearData() {
    _userId = 0;
    _namaLengkap = "";
    _kelasAtauNip = "";
    _role = "";
    _hadirBulanIni = 0;
    _persentaseKehadiran = 0;
    _riwayatAbsensi = [];
    _riwayatPerizinan = [];
    
    // [DIUBAH] Bersihkan data poligon saat logout.
    _schoolPolygon = null;
    notifyListeners();
  }

  // --- VARIABEL KHUSUS GURU ---
  int _jumlahIzinPending = 0;
  int _persentaseKehadiranKelas = 0;
  List<dynamic> _rekapAbsensiKelas = [];
  List<dynamic> _jadwalMengajar = [];

  // Getters Guru
  int get jumlahIzinPending => _jumlahIzinPending;
  int get persentaseKehadiranKelas => _persentaseKehadiranKelas;
  List<dynamic> get rekapAbsensiKelas => _rekapAbsensiKelas;
  List<dynamic> get jadwalMengajar => _jadwalMengajar;

  // Setter untuk menyimpan data Guru
  void setGuruDashboardData(int izinPending, int persentase, List<dynamic> rekap, List<dynamic> jadwal) {
    _jumlahIzinPending = izinPending;
    _persentaseKehadiranKelas = persentase;
    _rekapAbsensiKelas = rekap;
    _jadwalMengajar = jadwal;
    notifyListeners();
  }
}