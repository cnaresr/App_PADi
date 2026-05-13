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

