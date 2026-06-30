# Panduan Rilis APK v1.0.0 (App_PADi)

Dokumen ini berisi informasi mengenai panduan pemilihan berkas APK dan daftar fitur yang tersedia dalam aplikasi mobile **App_PADi (Platform Absensi Digital)** versi **v1.0.0**.

---

## 📱 1. Pilihan Berkas APK (Assets)

Di halaman release GitHub, terdapat beberapa variasi APK yang dapat diunduh sesuai perangkat Anda:

| Nama Berkas | Target Perangkat / Arsitektur CPU | Ukuran File | Keterangan |
|-------------|-----------------------------------|-------------|------------|
| **`app-release.apk`** | Semua Perangkat (Universal) | ~55.4 MB | **Paling Aman.** Berisi semua arsitektur CPU, dijamin berjalan di semua HP/emulator Android namun ukuran file lebih besar. |
| **`app-arm64-v8a-release.apk`** | HP Android Modern (64-bit) | ~19.9 MB | Cocok untuk sebagian besar HP Android keluaran baru (ARM64). Ukuran hemat dan performa optimal. |
| **`app-armeabi-v7a-release.apk`**| HP Android Lama (32-bit) | ~18.0 MB | Cocok untuk HP Android tipe lama/spesifikasi rendah. |
| **`app-x86_64-release.apk`** | Android Emulator (PC / Laptop) | ~21.4 MB | Khusus untuk di-instal pada Android Emulator di PC (seperti LDPlayer, Bluestacks, atau emulator Android Studio). |

---

## ✨ 2. Fitur yang Tersedia dalam APK

Aplikasi mobile pada rilis kali ini telah dilengkapi dengan beberapa fitur utama sebagai berikut:

### A. Fitur Siswa (Student Features)
* **Login & Autentikasi**: Autentikasi akun siswa menggunakan username dan sandi terdaftar.
* **Presensi Mandiri**: Melakukan pencatatan kehadiran (Masuk & Pulang) secara real-time.
* **Geofencing & Jarak**: Verifikasi lokasi presensi otomatis berdasarkan radius/koordinat area sekolah yang diizinkan.
* **Face Verification**: Pencegahan kecurangan absensi menggunakan verifikasi pengenalan wajah (Face Recognition) saat check-in.
* **Pengajuan Perizinan**: Mengajukan surat izin atau sakit secara langsung melalui form aplikasi dengan lampiran alasan.
* **Riwayat Kehadiran**: Melihat rekapitulasi riwayat absensi bulanan secara transparan.
* **Profil Siswa**: Melihat informasi data pribadi siswa dan status kelas aktif.

### B. Fitur Guru (Teacher Features)
* **Login & Autentikasi**: Autentikasi akun guru menggunakan username dan sandi.
* **Approval Perizinan**: Memeriksa, menyetujui, atau menolak pengajuan izin/sakit yang diajukan oleh siswa di bawah perwalian kelasnya secara real-time.
* **Riwayat & Profil**: Melihat informasi data pribadi guru dan riwayat aktivitas absensi kelas.
