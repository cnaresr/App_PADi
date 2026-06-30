# Panduan & Ketentuan Rilis APK v1.0.0 (App_PADi)

Dokumen ini berisi ketentuan, petunjuk instalasi, dan kredensial akun uji coba untuk berkas APK rilis **App_PADi (Platform Absensi Digital)** versi **v1.0.0**.

---

## 📱 1. Pilihan Berkas APK (Assets)

Di halaman release GitHub, terdapat beberapa variasi APK yang dapat diunduh:

| Nama Berkas | Target Perangkat / Arsitektur CPU | Ukuran File | Keterangan |
|-------------|-----------------------------------|-------------|------------|
| **`app-release.apk`** | Semua Perangkat (Universal) | ~55.4 MB | **Paling Aman.** Berisi semua arsitektur CPU, dijamin berjalan di semua HP/emulator Android namun ukuran file lebih besar. |
| **`app-arm64-v8a-release.apk`** | HP Android Modern (64-bit) | ~19.9 MB | Cocok untuk sebagian besar HP Android keluaran baru (ARM64). Ukuran hemat dan performa optimal. |
| **`app-armeabi-v7a-release.apk`**| HP Android Lama (32-bit) | ~18.0 MB | Cocok untuk HP Android tipe lama/spesifikasi rendah. |
| **`app-x86_64-release.apk`** | Android Emulator (PC / Laptop) | ~21.4 MB | Khusus untuk di-instal pada Android Emulator di PC (seperti LDPlayer, Bluestacks, atau emulator Android Studio). |

---

## 🔒 2. Kredensial Akun Uji Coba (Testing Accounts)

Database pengujian telah diisi menggunakan seeder dengan kredensial berikut untuk melakukan login pada aplikasi mobile dan web admin:

### A. Akun Admin (Akses Web Dashboard Admin)
* **Username**: `admin`
* **Password**: `admin123`

### B. Akun Guru (Akses Aplikasi Mobile / Web Guru)
Semua akun guru menggunakan password: **`guru123`**

* **Guru Kelas X**: `budi` (Drs. Budi Utomo)
* **Guru Kelas XI**: `siti` (Siti Aminah, S.Pd.)
* **Guru Kelas XII**: `ahmad` (Ahmad Fauzi, M.Pd.)

### C. Akun Siswa (Akses Aplikasi Mobile Siswa)
Semua akun siswa menggunakan password: **`siswa123`**

* **Kelas X (Tingkat X)**:
  * `aditya` (Aditya Pratama)
  * `beni` (Beni Setiawan)
  * `citra` (Citra Lestari)
* **Kelas XI (Tingkat XI)**:
  * `dina` (Dina Wijaya)
  * `eko` (Eko Prasetyo)
  * `farhan` (Farhan Hidayat)
* **Kelas XII (Tingkat XII)**:
  * `gita` (Gita Permata)
  * `hendra` (Hendra Wijaya)
  * `indah` (Indah Kusuma)

---

## 🔌 3. Prasyarat & Konektivitas API

Aplikasi mobile Flutter memerlukan koneksi ke server backend yang berjalan untuk memvalidasi presensi, perizinan, dan login.

1. **Jalankan Backend**:
   Pastikan server backend di komputer Anda berjalan menggunakan perintah:
   ```bash
   cd backend
   npm run dev
   ```
2. **Koneksi Jaringan**:
   * **Menggunakan Emulator**: Aplikasi pada emulator secara default dikonfigurasi untuk memanggil API di `http://10.0.2.2:3000/api` (alamat gerbang localhost komputer Anda).
   * **Menggunakan HP Fisik**: Pastikan HP dan Laptop Anda berada dalam **satu jaringan Wi-Fi yang sama**, dan sesuaikan IP API di konfigurasi aplikasi mobile dengan IP lokal laptop Anda (misal: `http://192.168.x.x:3000/api`).

---

## 📌 4. Ketentuan Uji Coba Fitur
* **Geofencing**: Pengujian kehadiran diverifikasi berdasarkan koordinat lokasi GPS HP Anda terhadap area koordinat geofence sekolah SMKN 1 Malang (yang di-set default pada seeder).
* **Face Recognition**: Fitur absensi memerlukan verifikasi foto wajah. Pastikan Anda telah melakukan registrasi/upload sampel foto wajah sebelum melakukan absensi masuk/pulang.
* **Perizinan**: Siswa dapat mengajukan izin/sakit melalui aplikasi mobile, yang kemudian akan langsung muncul di halaman web admin/guru untuk disetujui atau ditolak.
