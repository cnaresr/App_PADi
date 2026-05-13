# App_PADi - Platform Absensi Digital

Selamat datang di repositori **App_PADi (Platform Absensi Digital)**. Dokumen ini disusun untuk membantu rekan-rekan kelompok memahami alur kerja (workflow) pengerjaan proyek kita, mulai dari perancangan database, pengembangan API di sisi server, hingga pembuatan antarmuka pengguna di aplikasi mobile.

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
```

---

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
```

---

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
```

---

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
```

---

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
```

---

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

```json
{
  "email": "admin@mail.com",
  "password": "123456"
}
```

Response:

```json
{
  "success": true,
  "token": "xxxxx"
}
```

---

# Rules Tim

- Jangan push langsung ke `main`
- Semua fitur wajib melalui branch masing-masing
- Pull terbaru sebelum coding
- Gunakan nama file yang konsisten
- Hindari konflik merge

---

# Checklist Development

## Database

- [ ] ERD selesai
- [ ] Tabel selesai
- [ ] Seeder selesai

## Backend

- [ ] Authentication
- [ ] CRUD API
- [ ] Middleware

## Frontend

- [ ] UI Login
- [ ] Dashboard
- [ ] Integrasi API

---

# Penutup

Dokumentasi ini dibuat agar seluruh anggota kelompok memahami:

- Tugas masing-masing divisi
- Alur data aplikasi
- Workflow GitHub
- Struktur project

Dengan pembagian ini diharapkan development lebih teratur dan mudah dikerjakan bersama.

