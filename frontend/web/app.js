const express = require('express');
const app = express();
const path = require('path');
const axios = require('axios'); // Untuk menembak API
const session = require('express-session'); // Untuk menyimpan sesi login

app.set('view engine', 'ejs');
app.use(express.static(path.join(__dirname, 'public')));
app.use(express.urlencoded({ extended: true }));

// --- SETUP SESSION ---
app.use(session({
    secret: 'rahasia_admin_padi_super_aman',
    resave: false,
    saveUninitialized: false
}));

// --- MIDDLEWARE PROTEKSI HALAMAN ---
// Fungsi ini mencegah orang asing masuk ke URL /dashboard tanpa login
const cekAdmin = (req, res, next) => {
    if (req.session.token && req.session.role === 'Admin') {
        next(); // Boleh lewat
    } else {
        res.redirect('/?error=Silakan login sebagai Admin terlebih dahulu');
    }
};

// --- RUTE HALAMAN ---

// Halaman Login
app.get('/', (req, res) => {
    // Menampilkan halaman login, sekalian mengirim pesan error jika ada
    res.render('login', { error: req.query.error });
});

// Proses Penembakan API Login
app.post('/login', async (req, res) => {
    const { email, password } = req.body;

    try {
        // Tembak API Backend Anda yang berjalan di Port 3000!
        const response = await axios.post('http://localhost:3000/api/auth/login', {
            email: email,
            password: password
        });

        const data = response.data;

        // Validasi: Apakah sukses DAN role-nya adalah Admin?
        if (data.status === 'success' && data.data.role === 'Admin') {
            // Simpan token dan role di sesi browser
            req.session.token = data.token;
            req.session.role = data.data.role;
            
            // Lolos, arahkan ke dashboard!
            res.redirect('/dashboard');
        } else {
            // Login sukses, tapi bukan Admin (misal: Siswa coba login di web)
            res.redirect('/?error=Akses Ditolak: Anda bukan Admin!');
        }

    } catch (err) {
        // Menangkap error 401/404 dari API
        console.error("Gagal Login API:", err.message);
        res.redirect('/?error=Kombinasi email dan password salah');
    }
});

// --- RUTE YANG DILINDUNGI (Wajib Login) ---
app.get('/dashboard', cekAdmin, (req, res) => {
    res.render('dashboard');
});

app.get('/daftar-siswa', cekAdmin, (req, res) => {
    res.render('daftar_siswa');
});

app.get('/daftar-guru', cekAdmin, (req, res) => {
    res.render('daftar_guru');
});

app.get('/jadwal', cekAdmin, async (req, res) => {
    try {
        const response = await axios.get('http://localhost:3000/api/jadwal');
        const data = response.data.data;
        res.render('jadwal', { jadwalList: data.jadwal, kelasList: data.kelas });
    } catch (error) {
        console.error("Error fetching jadwal:", error.message);
        res.render('jadwal', { jadwalList: [], kelasList: [] });
    }
});

// Rute Logout
app.get('/logout', (req, res) => {
    req.session.destroy();
    res.redirect('/');
});

app.listen(4000, () => {
    console.log('✅ Web Admin berjalan di http://localhost:4000');
});