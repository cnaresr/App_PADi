# App_PADi - Platform Absensi Digital

Selamat datang di repositori **App_PADi (Platform Absensi Digital)**. Dokumen ini disusun untuk membantu rekan-rekan kelompok memahami alur kerja (workflow) pengerjaan proyek kita, mulai dari perancangan database, pengembangan API di sisi server, hingga pembuatan antarmuka pengguna di aplikasi mobile.

<<<<<<< HEAD
Repositori ini menggunakan arsitektur pemisahan antara **Backend (Node.js + Express + Prisma)** dan **Frontend (Flutter)**. Berikut adalah panduan alur pengerjaan yang dibagi menjadi tiga bagian utama agar lebih terstruktur dan mudah dikolaborasikan.

---

## 🗄️ 1. Alur Pengerjaan Database

Kita menggunakan **Prisma ORM** untuk berinteraksi dengan database. Semua konfigurasi database terpusat di folder `backend/prisma/`.

**Langkah Pengerjaan:**
1. **Definisi Skema:** Setiap ada penambahan atau perubahan tabel (seperti tabel pengguna, data presensi, atau lokasi), lakukan perubahan pada file `backend/prisma/schema.prisma`.
2. **Migrasi Database:** Setelah skema diubah, jalankan perintah migrasi Prisma untuk memperbarui struktur tabel di database lokal masing-masing.
   ```bash
   npx prisma migrate dev --name <nama_perubahan>
   ```
3. **Generate Client:** Pastikan menjalankan `npx prisma generate` agar Prisma Client di dalam kode Node.js mengenali struktur tabel terbaru.
4. **Inisialisasi Data:** Jika ada data awal yang perlu dimasukkan (seperti akun admin default), gunakan skrip `backend/init-db.js`.

---

## ⚙️ 2. Alur Pengerjaan Backend

Backend dibangun menggunakan **Node.js** dengan framework **Express**. Kodenya berada di dalam direktori `backend/`. Backend bertugas menyediakan REST API yang akan dikonsumsi oleh aplikasi Flutter.

**Langkah Pengerjaan:**

1. **Instalasi:** Masuk ke folder `backend/` dan jalankan `npm install` untuk mengunduh semua dependensi (seperti Express, Prisma, dll).
2. **Konfigurasi Environment:** Buat file `.env` di dalam folder `backend/` untuk menyimpan konfigurasi rahasia (seperti URL Database dan Secret Key JWT).
3. **Pengembangan Rute (Routes) & Kontroler:**
   - Tambahkan logika endpoint baru di dalam folder `backend/src/routes/`.
   - Saat ini sudah ada `auth.js` (untuk login/register) dan `presensi.js` (untuk mencatat absensi).
4. **Keamanan & Middleware:** Pastikan endpoint yang bersifat privat (hanya bisa diakses setelah login) menggunakan middleware yang ada di `backend/src/middleware/auth.js`.
5. **Menjalankan Server:**
   Jalankan server untuk testing menggunakan perintah:
   ```bash
   node index.js
   ```
   *(Atau gunakan nodemon jika sudah dikonfigurasi di package.json)*.

---

## 📱 3. Alur Pengerjaan Frontend

Frontend aplikasi dibangun menggunakan **Flutter** dan berada di dalam direktori `platform_absensi_digital/`. Aplikasi ini akan berjalan di perangkat mobile dan berkomunikasi dengan Backend melalui API. Disarankan menggunakan Visual Studio Code untuk pengembangan yang lebih ringan dan terintegrasi.

**Langkah Pengerjaan:**

1. **Instalasi Dependensi:** Masuk ke folder `platform_absensi_digital/` dan jalankan:
   ```bash
   flutter pub get
   ```
2. **Menghubungkan ke API:**
   - Semua komunikasi ke Backend HTTP dikelola di dalam `lib/services/api_service.dart`.
   - Pastikan URL API yang dituju di file tersebut sesuai dengan URL server backend lokal (misal: `http://10.0.2.2:3000` untuk emulator Android atau alamat IP lokal).
3. **Pengembangan UI & Logika Aplikasi:**
   - Buat atau edit tampilan halaman di dalam folder `lib/`.
   - Gunakan `main.dart` sebagai titik awal (entry point) aplikasi.
4. **Testing Aplikasi:**
   - Jalankan aplikasi di emulator atau perangkat fisik menggunakan:
   ```bash
   flutter run
   ```

---

## 🔄 Alur Kolaborasi Tim (Git Workflow)

Agar pengerjaan tidak saling bentrok, ikuti panduan berikut saat bekerja dalam kelompok:

1. **Pull Dulu:** Sebelum mulai ngoding, biasakan melakukan `git pull origin main` untuk mendapatkan pembaruan kode terbaru dari rekan yang lain.
2. **Kerjakan Per Bagian:** Fokus pada tugas masing-masing. Jika mendapat tugas API Presensi, edit file backend yang bersangkutan. Jika tugas UI, fokus di folder Flutter.
3. **Commit Pesan yang Jelas:** Gunakan pesan commit yang deskriptif. Contoh: `feat: menambahkan endpoint untuk riwayat presensi` atau `fix: perbaikan error login di flutter`.
4. **Push:** Setelah selesai, lakukan `git push` agar kodenya bisa digabungkan.

Semangat mengerjakan proyek PBL ini, Kelompok 2!

# App PADi

## Deskripsi Project

App PADi merupakan aplikasi yang dikembangkan secara tim dengan pembagian pengerjaan menjadi:

- Frontend
- Backend
- Database

Tujuan pembagian ini agar proses development lebih rapi, mudah dipahami, dan mengurangi konflik saat pengerjaan kelompok.

---

# Struktur Tim

## 1. Frontend Team

Bertanggung jawab terhadap:

- Tampilan aplikasi
- UI/UX
- Integrasi API ke backend
- Validasi input user
- State management
- Routing halaman

### Fokus Pengerjaan

- Login/Register
- Dashboard
- Halaman Data
- Form Input
- Responsive Layout
- Notifikasi/Error Handling

### Output Frontend

Frontend hanya:

- Mengirim request ke API
- Menampilkan data dari backend

### Alur Frontend

```text
User
 ↓
Frontend (UI)
 ↓
Request API
 ↓
Backend
 ↓
Response Data
 ↓
Ditampilkan ke User
```

---

## 2. Backend Team

Bertanggung jawab terhadap:

- Logic aplikasi
- API
- Authentication
- Validasi data
- CRUD
- Integrasi database

### Fokus Pengerjaan

- Membuat endpoint API
- Login Authentication
- Middleware
- Validasi request
- Pengolahan data
- Response JSON

### Output Backend

Backend menerima request dari frontend lalu:

- Memproses logic
- Mengakses database
- Mengirim response

### Alur Backend

```text
Frontend Request
 ↓
API Endpoint
 ↓
Controller
 ↓
Service/Logic
 ↓
Database Query
 ↓
Response JSON
```

---

## 3. Database Team

Bertanggung jawab terhadap:

- Desain database
- Relasi tabel
- Query SQL
- Optimasi database
- Backup data

### Fokus Pengerjaan

- ERD
- Normalisasi tabel
- Primary Key & Foreign Key
- Query CRUD
- Seeder/Data Dummy

### Output Database

Database menyediakan:

- Struktur tabel
- Relasi data
- Data yang dipakai backend

### Alur Database

```text
Backend
 ↓
Query SQL
 ↓
Database
 ↓
Data Result
 ↓
Backend
=======
---

## 📖 Deskripsi Project

App_PADi merupakan aplikasi yang dikembangkan secara tim dengan arsitektur pemisahan antara **Backend (Node.js + Express + Prisma)** dan **Frontend (Flutter)**. Pembagian pengerjaan dibagi menjadi tiga: Frontend, Backend, dan Database.

Tujuan pembagian ini agar proses development lebih rapi, terstruktur, mudah dipahami, dan mengurangi konflik saat pengerjaan kolaborasi kelompok.

### Teknologi yang Digunakan

- **Frontend:** Flutter (Mobile UI)
- **Backend:** Node.js, Express.js
- **Database:** PostgreSQL dengan Prisma ORM

---

## 👥 Struktur Tim & Tanggung Jawab

### 1. Frontend Team

Bertanggung jawab terhadap:

- Tampilan aplikasi (UI/UX)
- Integrasi API ke backend
- Validasi input user
- State management & Routing halaman

**Fokus Pengerjaan:** Login/Register, Dashboard, Halaman Data, Form Input, Responsive Layout, Notifikasi/Error Handling.
**Output:** Hanya mengirim request ke API dan menampilkan data dari backend.

### 2. Backend Team

Bertanggung jawab terhadap:

- Logic aplikasi & pembuatan API
- Authentication & Validasi data
- CRUD & Integrasi database

**Fokus Pengerjaan:** Membuat endpoint API, Login Authentication, Middleware, Validasi request, Pengolahan data, Response JSON.
**Output:** Menerima request dari frontend, memproses logic, mengakses database, dan mengirim response.

### 3. Database Team

Bertanggung jawab terhadap:

- Desain database & Relasi tabel
- Query SQL & Optimasi database
- Backup data

**Fokus Pengerjaan:** ERD, Normalisasi tabel, Primary Key & Foreign Key, Query CRUD, Seeder/Data Dummy.
**Output:** Menyediakan struktur tabel, relasi data, dan data yang dipakai backend.

---

## 🔄 Alur Besar Project

```text
User  ➔  Frontend (UI)  ➔  Request API  ➔  Backend  ➔  Database
User  🡄  Frontend (UI)  🡄  Response Data 🡄  Backend  🡄  Query Result
>>>>>>> 4ac2566c8f8efd7bb8649492a20e2778871acc44
```

---

<<<<<<< HEAD
# Alur Besar Project

```text
User
 ↓
Frontend
 ↓
Backend/API
 ↓
Database
 ↓
Backend/API
 ↓
Frontend
 ↓
User
=======
## 📁 Struktur Direktori Utama

Penting untuk mengetahui di mana letak file yang harus dikerjakan agar tidak salah mengubah file:

```text
App_PADi/
├── backend/                     # ⚙️ Semua urusan Server & Database ada di sini
│   ├── prisma/                  # 🗄️ Path Database (skema tabel)
│   └── src/                     # 💻 Path Backend utama (logika, rute API)
│       ├── routes/              # -> Tempat membuat endpoint API
│       └── middleware/          # -> Tempat menaruh proteksi keamanan (JWT)
└── platform_absensi_digital/    # 📱 Semua urusan UI/UX Mobile (Flutter) ada di sini
    └── lib/                     # 🎨 Path Frontend utama (tampilan, koneksi API)
        ├── screens/             # -> Tempat membuat halaman (UI)
        └── services/            # -> Tempat memanggil API backend
>>>>>>> 4ac2566c8f8efd7bb8649492a20e2778871acc44
```

---

<<<<<<< HEAD
# Pembagian Folder Project

## Frontend

```bash
frontend/
```

Contoh isi:

```bash
frontend/
├── pages/
├── components/
├── services/
├── assets/
├── routes/
└── utils/
=======
## 🚀 Workflow Pengerjaan Tim

- **Tahap 1 — Database:** Membuat ERD, struktur tabel, relasi, dan query dasar. Menghasilkan skema database.
- **Tahap 2 — Backend:** Membuat endpoint API, Authentication, dan CRUD menggunakan struktur database yang sudah dibuat.
- **Tahap 3 — Frontend:** Membuat UI dan menghubungkan API/menampilkan data menggunakan endpoint dari backend.

---

## 🗄️ 1. Alur Pengerjaan Database (Prisma ORM & PostgreSQL)

**Path pengerjaan:** `backend/prisma/schema.prisma`

Bagian ini digunakan ketika ada penambahan fitur yang membutuhkan penyimpanan data baru (contoh: menambah tabel Presensi). Pastikan koneksi ke database PostgreSQL sudah diatur di file `.env` kamu.

**Langkah Pengerjaan:**

1. Buka file `backend/prisma/schema.prisma`.
2. Tambahkan model (tabel) baru sesuai kebutuhan.
3. Buka terminal, masuk ke folder `backend/`, lalu jalankan migrasi untuk memperbarui struktur tabel di database lokal masing-masing:

```bash
npx prisma migrate dev --name <nama_perubahan>
```

4. Pastikan menjalankan `npx prisma generate` agar Prisma Client di dalam kode Node.js mengenali struktur tabel terbaru.
5. Jika ada data awal yang perlu dimasukkan (seperti akun admin default), gunakan skrip `backend/init-db.js`.

**Contoh Kode (`schema.prisma`):**

```prisma
// Konfigurasi koneksi PostgreSQL
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// Menambahkan tabel Presensi
model Presensi {
  id        Int      @id @default(autoincrement())
  userId    Int
  user      User     @relation(fields: [userId], references: [id])
  waktu     DateTime @default(now())
  status    String   // "Hadir", "Izin", "Sakit"
  lokasi    String?  // Koordinat GPS
}
>>>>>>> 4ac2566c8f8efd7bb8649492a20e2778871acc44
```

---

<<<<<<< HEAD
## Backend

```bash
backend/
```

Contoh isi:

```bash
backend/
├── controllers/
├── routes/
├── middleware/
├── services/
├── models/
└── config/
=======
## ⚙️ 2. Alur Pengerjaan Backend (Node.js + Express)

**Path pengerjaan:** `backend/src/routes/` (untuk rute) dan `backend/src/app.js` (untuk registrasi rute)

Bagian ini bertugas menyediakan REST API yang akan dikonsumsi oleh aplikasi Flutter.

**Langkah Pengerjaan:**

1. Masuk ke folder `backend/` dan jalankan `npm install` untuk mengunduh semua dependensi.
2. Buat file `.env` di dalam folder `backend/` untuk menyimpan konfigurasi rahasia (URL Database PostgreSQL & Secret Key JWT).
3. Buat file rute baru di `backend/src/routes/` (misal: `presensi.js`). Tulis logika endpoint menggunakan Express dan panggil data menggunakan Prisma Client.
4. Daftarkan file rute tersebut di `backend/src/app.js`.
5. Pastikan endpoint privat menggunakan middleware di `backend/src/middleware/auth.js`.
6. Jalankan server untuk testing: `node index.js` atau `npm start`.

**Contoh Kode (`backend/src/routes/presensi.js`):**

```javascript
const express = require("express");
const router = express.Router();
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

// Endpoint untuk mencatat kehadiran (POST /api/presensi)
router.post("/", async (req, res) => {
  try {
    const { userId, status, lokasi } = req.body;

    // Menyimpan data ke database menggunakan Prisma
    const presensiBaru = await prisma.presensi.create({
      data: { userId, status, lokasi },
    });

    res.status(201).json({ message: "Presensi berhasil!", data: presensiBaru });
  } catch (error) {
    res.status(500).json({ error: "Terjadi kesalahan pada server" });
  }
});

module.exports = router;
>>>>>>> 4ac2566c8f8efd7bb8649492a20e2778871acc44
```

---

<<<<<<< HEAD
## Database

```bash
database/
```

Contoh isi:

```bash
database/
├── migration/
├── seeder/
├── schema/
└── backup/
=======
## 📱 3. Alur Pengerjaan Frontend (Flutter)

**Path pengerjaan:** `platform_absensi_digital/lib/`

Disarankan menggunakan Visual Studio Code untuk pengembangan yang lebih ringan dan terintegrasi.

**Langkah Pengerjaan:**

1. Masuk ke folder `platform_absensi_digital/` dan jalankan `flutter pub get`.
2. Buat fungsi untuk memanggil API di dalam folder `services/` (misal: `api_service.dart`). Pastikan URL API sesuai dengan server lokal (misal `http://10.0.2.2:3000` untuk emulator Android).
3. Buat tampilan UI di dalam folder `screens/` (misal: `presensi_screen.dart`). Gunakan `main.dart` sebagai entry point.
4. Hubungkan tombol di layar dengan fungsi API yang sudah dibuat.
5. Jalankan aplikasi di emulator: `flutter run`.

**Contoh Kode:**

**A. Memanggil API (`lib/services/api_service.dart`):**

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  static Future<bool> catatPresensi(int userId, String status, String lokasi) async {
    final response = await http.post(
      Uri.parse('$baseUrl/presensi'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'status': status, 'lokasi': lokasi}),
    );
    return response.statusCode == 201;
  }
}
```

**B. Tampilan Tombol Absen (`lib/screens/presensi_screen.dart`):**

```dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PresensiScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Catat Kehadiran")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            bool sukses = await ApiService.catatPresensi(1, "Hadir", "-6.982, 110.432");
            if (sukses) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Berhasil absen! 🎉"))
              );
            }
          },
          child: Text("Absen Sekarang"),
        ),
      ),
    );
  }
}
>>>>>>> 4ac2566c8f8efd7bb8649492a20e2778871acc44
```

---

<<<<<<< HEAD
# Workflow Pengerjaan Tim

## Tahap 1 — Database

Database team membuat:

- ERD
- Struktur tabel
- Relasi
- Query dasar

Output:

- File SQL
- Dokumentasi tabel

---

## Tahap 2 — Backend

Backend team membuat:

- Endpoint API
- Authentication
- CRUD
- Testing API

Backend menggunakan struktur database yang sudah dibuat.

---

## Tahap 3 — Frontend

Frontend team:

- Membuat UI
- Menghubungkan API
- Menampilkan data

Frontend menggunakan endpoint dari backend.

---

# Aturan Branch GitHub

## Branch Utama

```bash
main
```

## Branch Frontend

```bash
frontend-dev
```

## Branch Backend

```bash
backend-dev
```

## Branch Database

```bash
database-dev
```

---

# Alur Git Collaboration

## 1. Clone Repository

```bash
git clone https://github.com/cnaresr/App_PADi.git
```

## 2. Masuk Folder

```bash
cd App_PADi
```

## 3. Pindah Branch

Contoh:

```bash
git checkout frontend-dev
```

## 4. Commit Perubahan

```bash
git add .
git commit -m "Menambahkan halaman login"
```

## 5. Push ke GitHub

```bash
git push origin frontend-dev
```

---

# Standarisasi Commit

## Frontend

```bash
feat(frontend): menambahkan halaman dashboard
```

## Backend

```bash
feat(backend): membuat endpoint login
```

## Database

```bash
feat(database): membuat tabel user
```

---

# Teknologi yang Digunakan

## Frontend

- HTML/CSS/JS
- React/Vue/Flutter (sesuaikan project)

## Backend

- Node.js / Laravel / Express (sesuaikan project)

## Database

- MySQL / PostgreSQL

---

# Dokumentasi API

Contoh endpoint:

## Login

```http
POST /api/login
```

Request:
=======
## 📚 Dokumentasi API (Contoh)

**Endpoint Login:** `POST /api/login`

**Request:**
>>>>>>> 4ac2566c8f8efd7bb8649492a20e2778871acc44

```json
{
  "email": "admin@mail.com",
  "password": "123456"
}
```

<<<<<<< HEAD
Response:
=======
**Response:**
>>>>>>> 4ac2566c8f8efd7bb8649492a20e2778871acc44

```json
{
  "success": true,
  "token": "xxxxx"
}
```

---

<<<<<<< HEAD
# Rules Tim

- Jangan push langsung ke `main`
- Semua fitur wajib melalui branch masing-masing
- Pull terbaru sebelum coding
- Gunakan nama file yang konsisten
- Hindari konflik merge

---

# Checklist Development

## Database
=======
## 🤝 Alur Kolaborasi Tim (Git Workflow)

Agar pengerjaan tidak saling bentrok, ikuti panduan dan aturan branch berikut:

### Aturan Branch

- `main`: Branch Utama (Production/Stabil)
- `frontend-dev`: Branch pengerjaan Frontend
- `backend-dev`: Branch pengerjaan Backend
- `database-dev`: Branch pengerjaan Database

### Step-by-Step Kolaborasi Git

1. **Clone Repository (Hanya pertama kali):**

```bash
git clone https://github.com/cnaresr/App_PADi.git
cd App_PADi
```

2. **Pindah ke Branch Divisimu & Pull Dulu:** Sebelum ngoding, pastikan mendapat update terbaru.

```bash
git checkout frontend-dev  # ganti sesuai devisimu
git pull origin frontend-dev
```

3. **Kerjakan Per Bagian:** Fokus pada path tugas masing-masing agar tidak terjadi konflik file.
4. **Commit Perubahan:** Simpan dengan standarisasi pesan.

```bash
git add .
git commit -m "feat(frontend): menambahkan halaman dashboard"
```

5. **Push ke GitHub:**

```bash
git push origin frontend-dev
```

### Standarisasi Commit

- `feat(frontend): menambahkan halaman dashboard`
- `feat(backend): membuat endpoint login`
- `feat(database): membuat tabel user`
- `fix(frontend): perbaikan error login di flutter`

---

## ⚠️ Rules Tim

1. **JANGAN** push langsung ke branch `main`.
2. Semua fitur wajib melalui branch divisinya masing-masing.
3. Selalu lakukan `git pull` terbaru sebelum mulai coding.
4. Gunakan nama file yang konsisten (snake_case atau camelCase sesuai standar bahasa).
5. Komunikasikan di grup jika terjadi konflik (merge conflict).

---

## ✅ Checklist Development

**Database**
>>>>>>> 4ac2566c8f8efd7bb8649492a20e2778871acc44

- [ ] ERD selesai
- [ ] Tabel selesai
- [ ] Seeder selesai

<<<<<<< HEAD
## Backend
=======
**Backend**
>>>>>>> 4ac2566c8f8efd7bb8649492a20e2778871acc44

- [ ] Authentication
- [ ] CRUD API
- [ ] Middleware

<<<<<<< HEAD
## Frontend
=======
**Frontend**
>>>>>>> 4ac2566c8f8efd7bb8649492a20e2778871acc44

- [ ] UI Login
- [ ] Dashboard
- [ ] Integrasi API

---

<<<<<<< HEAD
# Penutup

Dokumentasi ini dibuat agar seluruh anggota kelompok memahami:

- Tugas masing-masing divisi
- Alur data aplikasi
- Workflow GitHub
- Struktur project

Dengan pembagian ini diharapkan development lebih teratur dan mudah dikerjakan bersama.

=======
Dokumentasi ini dibuat agar seluruh anggota kelompok memahami tugas masing-masing divisi, alur data aplikasi, workflow GitHub, dan struktur project. Semangat mengerjakan proyek PBL ini, Kelompok 2!
>>>>>>> 4ac2566c8f8efd7bb8649492a20e2778871acc44
