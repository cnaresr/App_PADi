import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _namaLengkap = "Memuat...";
  String _kelasAtauNip = "Memuat...";
  String _role = "";

  // Getters
  String get namaLengkap => _namaLengkap;
  String get kelasAtauNip => _kelasAtauNip;
  String get role => _role;

  // Fungsi ini dipanggil setelah proses Login API sukses
  void setUserData(String nama, String detail, String roleUser) {
    _namaLengkap = nama;
    _kelasAtauNip = detail;
    _role = roleUser;
    notifyListeners(); // Memperbarui semua halaman yang memakai data ini
  }

  // Fungsi saat Keluar Akun
  void clearData() {
    _namaLengkap = "";
    _kelasAtauNip = "";
    _role = "";
    notifyListeners();
  }
}