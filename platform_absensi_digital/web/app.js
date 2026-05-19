const express = require('express');
const app = express();
const path = require('path');

app.set('view engine', 'ejs');
app.use(express.static(path.join(__dirname, 'public')));
app.use(express.urlencoded({ extended: true }));

// Rute Halaman Login
app.get('/', (req, res) => {
    res.render('login');
});

// Simulasi Proses Login
app.post('/login', (req, res) => {
    // Sesuai alur proyek, di sini nanti Anda memanggil API Backend (Node.js/Prisma)
    // Untuk sekarang, kita langsung redirect ke dashboard
    res.redirect('/dashboard');
});

// Rute Halaman Dashboard Admin
app.get('/dashboard', (req, res) => {
    res.render('dashboard');
});

// Tambahkan rute baru di app.js
app.get('/daftar-siswa', (req, res) => {
    res.render('daftar_siswa');
});

// Tambahkan rute baru untuk Halaman Daftar Guru di app.js
app.get('/daftar-guru', (req, res) => {
    res.render('daftar_guru');
});

// Tambahkan rute baru untuk Halaman Jadwal di app.js
app.get('/jadwal', (req, res) => {
    res.render('jadwal');
});

app.listen(4000, () => {
    console.log('Web Admin berjalan di http://localhost:4000');
});