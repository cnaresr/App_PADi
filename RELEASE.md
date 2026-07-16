# Panduan Rilis APK & Riwayat Versi (App_PADi)

Dokumen ini berisi informasi mengenai panduan pemilihan berkas APK, pembaruan versi terbaru, serta daftar fitur yang tersedia dalam aplikasi mobile **App_PADi (Platform Absensi Digital)**.

---

## 🚀 Rilis Terbaru: v1.0.1 (16 Juli 2026)

### 📱 1. Pilihan Berkas APK (Assets)

Di halaman release GitHub, terdapat beberapa variasi APK versi **v1.0.1** yang dapat diunduh sesuai perangkat Anda:

| Nama Berkas | Target Perangkat / Arsitektur CPU | Ukuran File | Keterangan |
|-------------|-----------------------------------|-------------|------------|
| **`app-release.apk`** | Semua Perangkat (Universal) | ~55.4 MB | **Paling Aman.** Berisi semua arsitektur CPU, dijamin berjalan di semua HP/emulator Android namun ukuran file lebih besar. |
| **`app-arm64-v8a-release.apk`** | HP Android Modern (64-bit) | ~19.9 MB | Cocok untuk sebagian besar HP Android keluaran baru (ARM64). Ukuran hemat dan performa optimal. |
| **`app-armeabi-v7a-release.apk`**| HP Android Lama (32-bit) | ~18.0 MB | Cocok untuk HP Android tipe lama/spesifikasi rendah. |
| **`app-x86_64-release.apk`** | Android Emulator (PC / Laptop) | ~21.4 MB | Khusus untuk di-instal pada Android Emulator di PC (seperti LDPlayer, Bluestacks, atau emulator Android Studio). |

---

### ✨ 2. Pembaruan dan Fitur Baru di v1.0.1

Rilis versi **v1.0.1** ini berfokus pada kestabilan sistem, integrasi push notification, peningkatan biometrik wajah, serta optimalisasi panel admin. Berikut adalah ringkasan perubahan utamanya:

* **Firebase Push Notifications (Notifikasi Presensi & Izin)**:
  - Mengintegrasikan modul Firebase Cloud Messaging (FCM) ke aplikasi mobile dan backend database.
  - Guru kini menerima notifikasi secara real-time saat siswa mengajukan perizinan baru.
  - Siswa menerima notifikasi status pengajuan izin yang disetujui atau ditolak secara instan.
* **Peningkatan Keamanan Biometrik Wajah (Face Recognition)**:
  - Implementasi pemotongan gambar berformat kotak (*square crop*) secara lokal sebelum dikirim untuk deteksi wajah.
  - Peningkatan threshold akurasi serta perbandingan deteksi wajah (dual embedding) untuk mencegah manipulasi foto dari kejauhan.
  - Validasi ketat ukuran minimum wajah pada layar kamera check-in.
* **Geofencing & Sinkronisasi Lokasi Dinamis**:
  - Validasi lokasi koordinat absensi siswa yang terintegrasi secara dinamis dengan pengaturan koordinat sekolah di panel admin.
  - Perbaikan bug timezone absensi (penyesuaian jam masuk dan jam pulang).
  - Optimasi kinerja pembukaan kamera absensi agar lebih responsif.
* **Portal Administrasi Multi-Sekolah (`devadmin`)**:
  - Implementasi portal developer admin untuk delegasi manajemen admin per sekolah.
  - Penambahan fitur import data siswa secara massal menggunakan format Excel.
  - Perbaikan modul jadwal pelajaran reguler dan histori penempatan kelas per tahun akademik.
* **Penyederhanaan UI & Animasi Transisi**:
  - Penambahan animasi transisi layar (page transition) yang lebih halus di aplikasi Flutter.
  - Pembersihan sisa pustaka kecerdasan buatan (AI) lama dari sisi frontend mobile untuk memperkecil ukuran aplikasi.

---

## 📜 Riwayat Rilis Sebelumnya

### Rilis: v1.0.0 (Rilis Awal)

Versi pertama aplikasi mobile **App_PADi** yang membawa fitur dasar presensi dan perizinan.

#### A. Fitur Siswa (Student Features)
* **Login & Autentikasi**: Autentikasi akun siswa menggunakan username dan sandi terdaftar.
* **Presensi Mandiri**: Melakukan pencatatan kehadiran (Masuk & Pulang) secara real-time.
* **Geofencing & Jarak**: Verifikasi lokasi presensi otomatis berdasarkan radius/koordinat area sekolah yang diizinkan.
* **Face Verification**: Pencegahan kecurangan absensi menggunakan verifikasi pengenalan wajah (Face Recognition) saat check-in.
* **Pengajuan Perizinan**: Mengajukan surat izin atau sakit secara langsung melalui form aplikasi dengan lampiran alasan.
* **Riwayat Kehadiran**: Melihat rekapitulasi riwayat absensi bulanan secara transparan.
* **Profil Siswa**: Melihat informasi data pribadi siswa dan status kelas aktif.

#### B. Fitur Guru (Teacher Features)
* **Login & Autentikasi**: Autentikasi akun guru menggunakan username dan sandi.
* **Approval Perizinan**: Memeriksa, menyetujui, atau menolak pengajuan izin/sakit yang diajukan oleh siswa di bawah perwalian kelasnya secara real-time.
* **Riwayat & Profil**: Melihat informasi data pribadi guru dan riwayat aktivitas absensi kelas.
