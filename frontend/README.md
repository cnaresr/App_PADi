# App_PADi - Frontend Mobile Application

Selamat datang di repositori **Frontend App_PADi (Platform Absensi Digital)**. Repositori ini dikhususkan untuk pengembangan aplikasi antarmuka mobile menggunakan framework Flutter.

---

## 📱 Deskripsi Proyek (Frontend)

Repositori ini fokus menangani pengalaman pengguna (UI/UX), validasi input di sisi klien, manajemen state aplikasi, serta melakukan komunikasi data dengan Backend API.

### Teknologi yang Digunakan

- **Framework:** Flutter (Dart)
- **IDE Terintegrasi:** Visual Studio Code (Sangat Disarankan)

---

## 📁 Struktur Direktori Frontend

Pastikan Anda menambahkan halaman maupun komponen baru di dalam folder yang benar agar struktur proyek terorganisir:

```text
platform_absensi_digital/
├── android/                     # Konfigurasi native Android
├── ios/                         # Konfigurasi native iOS
├── lib/                         # 🎨 Path Frontend utama (Tempat kita ngoding)
│   ├── screens/                 # -> Kumpulan halaman UI aplikasi (Login, Dashboard, dll)
│   ├── services/                # -> Modul penghubung & request HTTP ke Backend API
│   └── main.dart                # 🚀 Entry point / Titik awal aplikasi Flutter berjalan
├── pubspec.yaml                 # 📦 Tempat manajemen aset gambar dan package pihak ketiga
└── README.md                    # Dokumentasi panduan ini

```

---

## 🚀 Alur Pengerjaan Frontend (Step-by-Step)

### Langkah Pengerjaan:

1. Buka folder proyek ini menggunakan editor pilihan Anda (disarankan VS Code).
2. Unduh semua _dependencies_ / _package_ yang dibutuhkan aplikasi dengan menjalankan perintah berikut di terminal:

```bash
flutter pub get

```

3. Jika Anda ingin menghubungkan aplikasi dengan database/server lokal, buka file koneksi API di `lib/services/api_service.dart`. Ubah `baseUrl` sesuai IP lokal server Anda (gunakan `http://10.0.2.2:3000` jika Anda menguji menggunakan Emulator Android bawaan).
4. Buat rancangan layout halaman baru di dalam folder `lib/screens/` (misalnya membuat halaman `presensi_screen.dart`).
5. Buat fungsi pemanggil fungsi HTTP (GET/POST) di dalam `lib/services/api_service.dart` agar terhubung ke backend.
6. Kaitkan aksi tombol UI (_onPressed_) dengan fungsi layanan API yang telah dibuat.
7. Jalankan aplikasi di emulator atau perangkat fisik Anda menggunakan perintah:

```bash
flutter run

```

---

## 💻 Contoh Implementasi Kode Frontend

### A. File Komunikasi API (`lib/services/api_service.dart`):

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // Gunakan IP lokal mesin jika run di HP asli, atau 10.0.2.2 jika run di emulator Android
  static const String baseUrl = '[http://10.0.2.2:3000/api](http://10.0.2.2:3000/api)';

  static Future<bool> catatPresensi(int userId, String status, String lokasi) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/presensi'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'status': status, 'lokasi': lokasi}),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}

```

### B. File Antarmuka Tombol Absen (`lib/screens/presensi_screen.dart`):

```dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PresensiScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Menu Presensi")),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          onPressed: () async {
            // Simulasi pengiriman data presensi kelompok 2
            bool sukses = await ApiService.catatPresensi(1, "Hadir", "-6.982, 110.432");

            if (sukses) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Berhasil melakukan presensi! 🎉"))
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Gagal terhubung ke server backend ❌"))
              );
            }
          },
          child: Text("Absen Masuk", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

```

---

## 🤝 Alur Git & Branching Tim Frontend

Sesuai kesepakatan bersama kelompok agar tidak terjadi konflik kode (_merge conflict_):

- **Branch Pengerjaan:** Gunakan branch khusus `frontend-dev`. Jangan menggabungkan kode langsung ke branch `main`.
- **Workflow harian:**

```bash
git checkout frontend-dev
git pull origin frontend-dev
# ... silakan buat UI halaman kamu di folder screens/ ...
git add .
git commit -m "feat(frontend): menambah halaman form presensi"
git push origin frontend-dev

```

---

## ⚠️ Aturan Penting Tim Frontend

1. Selalu lakukan `git pull origin frontend-dev` sebelum mulai menulis kode baru.
2. Pastikan format penamaan file menggunakan standar Flutter (`snake_case.dart`).
3. Jangan mengubah file konfigurasi native folder `android/` atau `ios/` tanpa koordinasi tim.

---

## ✅ Checklist Frontend

- [ ] Jalankan `flutter pub get` sukses tanpa error
- [ ] Konfigurasi `baseUrl` lokal di `api_service.dart`
- [ ] Pembuatan komponen UI halaman Login & Register
- [ ] Pembuatan komponen UI Dashboard utama
- [ ] Integrasi fungsi kirim data presensi ke server backend
