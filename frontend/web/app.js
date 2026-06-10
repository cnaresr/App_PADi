const express = require('express');
const app = express();
const path = require('path');
const axios = require('axios'); // Untuk integrasi dengan API Backend
const session = require('express-session'); // Untuk mengelola session login Admin

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
// Memastikan halaman hanya bisa diakses oleh Admin yang sudah login
const cekAdmin = (req, res, next) => {
    if (req.session && req.session.role === 'Admin') {
        next();
    } else {
        res.redirect('/?error=Silakan login sebagai Admin terlebih dahulu');
    }
};

// --- RUTE HALAMAN ---

// Halaman Login Utama Web Admin
app.get('/', (req, res) => {
    res.render('login', { error: req.query.error });
});

// Aksi POST Login ke API Backend (Port 3000)
app.post('/login', async (req, res) => {
    const { email, password } = req.body;

    try {
        const response = await axios.post('http://localhost:3000/api/auth/login', {
            email: email,
            password: password
        });

        const data = response.data;

        // PERBAIKAN: Gunakan .toString() atau abaikan pengecekan sensitif huruf kapital jika perlu
        if (data.status === 'success' && String(data.data.role) === 'Admin') {
            req.session.token = data.token;
            req.session.role = String(data.data.role);
            
            // Simpan session agar tidak terlempar kembali
            req.session.save(() => {
                res.redirect('/dashboard');
            });
        } else {
            res.redirect('/?error=Akses Ditolak: Role Anda tidak dikenali');
        }

    } catch (err) {
        console.error("Gagal Login API:", err.message);
        res.redirect('/?error=Kombinasi email dan password salah');
    }
});

app.get('/dashboard', (req, res) => {
    // Jika Anda menggunakan session tapi belum diisi saat login, 
    // halaman ini akan terus-terusan melempar Anda keluar (Redirect).
    res.render('Dashboard', { 
        user: req.session.user || { username: 'Admin' } 
    });
});
// ==========================================
// INTEGRASI CRUD GURU (FRONTEND - API)
// ==========================================
app.get('/daftar-guru', cekAdmin, async (req, res) => {
    try {
        // Mengirimkan Token JWT di Header agar lolos verifikasi Backend
        const config = {
            headers: { Authorization: `Bearer ${req.session.token}` }
        };

        const responseGuru = await axios.get('http://localhost:3000/api/guru', config);

        res.render('daftar_guru', { 
            gurus: responseGuru.data.data, 
            error: req.query.error,
            success: req.query.success 
        });
    } catch (err) {
        console.error("Gagal mengambil data guru dari API:", err.message);
        res.render('daftar_guru', { gurus: [], sekolahs: [], error: 'Gagal memuat data dari server pusat.' });
    }
});

app.post('/daftar-guru/tambah', cekAdmin, async (req, res) => {
    try {
        await axios.post('http://localhost:3000/api/guru', req.body, {
            headers: { Authorization: `Bearer ${req.session.token}` }
        });
        res.status(200).json({ status: 'success', message: 'Guru berhasil ditambahkan!' });
    } catch (err) {
        const pesanError = err.response?.data?.message || 'Gagal menambahkan guru';
        res.status(err.response?.status || 500).json({ status: 'error', message: pesanError });
    }
});

app.post('/daftar-guru/edit/:id_guru', cekAdmin, async (req, res) => {
    try {
        await axios.put(`http://localhost:3000/api/guru/${req.params.id_guru}`, req.body, {
            headers: { Authorization: `Bearer ${req.session.token}` }
        });
        res.status(200).json({ status: 'success', message: 'Data guru berhasil diperbarui!' });
    } catch (err) {
        console.error(`[APP.JS] Error saat memperbarui guru ${req.params.id_guru}:`, err); // Log error lengkap
        const pesanError = err.response?.data?.message || err.message || 'Gagal memperbarui data'; // Ambil pesan error lebih detail
        res.status(err.response?.status || 500).json({ status: 'error', message: pesanError });
    }
});

app.get('/daftar-guru/hapus/:id_guru', cekAdmin, async (req, res) => {
    try {
        await axios.delete(`http://localhost:3000/api/guru/${req.params.id_guru}`, {
            headers: { Authorization: `Bearer ${req.session.token}` }
        });
        res.redirect('/daftar-guru?success=Guru berhasil dihapus!');
    } catch (err) {
        res.redirect('/daftar-guru?error=Gagal menghapus guru.');
    }
});

// Halaman Lainnya
app.get('/daftar-siswa', cekAdmin, (req, res) => {
    res.render('daftar_siswa');
});

app.get('/jadwal', cekAdmin, (req, res) => {
    res.render('jadwal');
});

// Rute Proses Logout
app.get('/logout', (req, res) => {
    req.session.destroy();
    res.redirect('/');
});

app.listen(4000, () => {
    console.log('✅ Web Admin berjalan di http://localhost:4000');
});