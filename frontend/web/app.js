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
        const response = await axios.post('http://127.0.0.1:3000/api/auth/login', {
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
app.get('/dashboard', cekAdmin, async (req, res) => {
    try {
        const response = await axios.get('http://127.0.0.1:3000/api/dashboard/stats');
        const statsData = response.data.data;
        
        res.render('dashboard', { stats: statsData });
    } catch (error) {
        console.error("Gagal mengambil statistik via Axios:", error.message);
        res.render('dashboard', { 
            stats: { totalSiswa: 0, totalGuru: 0, totalAdmin: 0, attendanceWeekly: [0,0,0,0,0,0,0], statusChart: [0,0,0] } 
        });
    }
});

// --- RUTE DAFTAR SISWA ---
app.get('/daftar-siswa', cekAdmin, async (req, res) => {
    try {
        const search = req.query.search || '';
        const response = await axios.get(`http://127.0.0.1:3000/api/admin/siswa?search=${search}`);
        res.render('daftar_siswa', { siswas: response.data.data, search: search });
    } catch (error) {
        console.error("Gagal mengambil daftar siswa:", error.message);
        res.render('daftar_siswa', { siswas: [], search: '' });
    }
});

app.post('/daftar-siswa', cekAdmin, async (req, res) => {
    try {
        await axios.post('http://127.0.0.1:3000/api/admin/siswa', req.body);
        res.redirect('/daftar-siswa'); // Refresh halaman setelah berhasil
    } catch (error) {
        console.error("Gagal tambah siswa:", error.message);
        res.redirect('/daftar-siswa?error=Gagal_menambahkan_siswa');
    }
});

app.post('/daftar-siswa/edit/:id', cekAdmin, async (req, res) => {
    try {
        await axios.put(`http://127.0.0.1:3000/api/admin/siswa/${req.params.id}`, req.body);
        res.redirect('/daftar-siswa');
    } catch (error) {
        console.error("Gagal edit siswa:", error.message);
        res.redirect('/daftar-siswa?error=Gagal_update');
    }
});

app.post('/daftar-siswa/delete/:id', cekAdmin, async (req, res) => {
    try {
        await axios.delete(`http://127.0.0.1:3000/api/admin/siswa/${req.params.id}`);
        res.redirect('/daftar-siswa');
    } catch (error) {
        console.error("Gagal hapus siswa:", error.message);
        res.redirect('/daftar-siswa?error=Gagal_hapus');
    }
});

// --- RUTE DAFTAR GURU ---
app.get('/daftar-guru', cekAdmin, async (req, res) => {
    try {
        const search = req.query.search || '';
        const response = await axios.get(`http://127.0.0.1:3000/api/admin/guru?search=${search}`);
        res.render('daftar_guru', { gurus: response.data.data, search: search });
    } catch (error) {
        console.error("Gagal mengambil daftar guru:", error.message);
        res.render('daftar_guru', { gurus: [], search: '' });
    }
});

app.post('/daftar-guru', cekAdmin, async (req, res) => {
    try {
        await axios.post('http://127.0.0.1:3000/api/admin/guru', req.body);
        res.redirect('/daftar-guru');
    } catch (error) {
        console.error("Gagal tambah guru:", error.message);
        res.redirect('/daftar-guru?error=Gagal_menambahkan_guru');
    }
});

app.post('/daftar-guru/edit/:id', cekAdmin, async (req, res) => {
    try {
        await axios.put(`http://127.0.0.1:3000/api/admin/guru/${req.params.id}`, req.body);
        res.redirect('/daftar-guru');
    } catch (error) {
        console.error("Gagal edit guru:", error.message);
        res.redirect('/daftar-guru?error=Gagal_update');
    }
});

app.post('/daftar-guru/delete/:id', cekAdmin, async (req, res) => {
    try {
        await axios.delete(`http://127.0.0.1:3000/api/admin/guru/${req.params.id}`);
        res.redirect('/daftar-guru');
    } catch (error) {
        console.error("Gagal hapus guru:", error.message);
        res.redirect('/daftar-guru?error=Gagal_hapus');
    }
});

// --- RUTE JADWAL ---
app.get('/jadwal', cekAdmin, async (req, res) => {
    try {
        // PERBAIKAN: Gunakan 127.0.0.1 agar tidak error
        const response = await axios.get('http://127.0.0.1:3000/api/jadwal');
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