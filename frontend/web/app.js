const express = require('express');
const app = express();
const path = require('path');
const axios = require('axios'); // Untuk menembak API
const session = require('express-session'); // Untuk menyimpan sesi login
const multer = require('multer');
const FormData = require('form-data');
const fs = require('fs');
const os = require('os');
const upload = multer({ dest: os.tmpdir() });

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

// --- RUTE MASTER DATA ---
app.get('/master-data', cekAdmin, async (req, res) => {
    try {
        const [resKelas, resAngkatan, resTa, resPengaturan] = await Promise.all([
            axios.get('http://127.0.0.1:3000/api/admin/master/kelas'),
            axios.get('http://127.0.0.1:3000/api/admin/master/angkatan'),
            axios.get('http://127.0.0.1:3000/api/admin/master/tahun-akademik'),
            axios.get('http://127.0.0.1:3000/api/admin/master/pengaturan')
        ]);
        
        let bulanGanjil = 7; let bulanSelesaiGanjil = 12;
        let bulanGenap = 1; let bulanSelesaiGenap = 6;
        if(resPengaturan.data && resPengaturan.data.data) {
            const p = resPengaturan.data.data;
            const ganjil = p.find(x => x.kunci === 'bulan_mulai_ganjil');
            const ganjilSelesai = p.find(x => x.kunci === 'bulan_selesai_ganjil');
            const genap = p.find(x => x.kunci === 'bulan_mulai_genap');
            const genapSelesai = p.find(x => x.kunci === 'bulan_selesai_genap');
            if(ganjil) bulanGanjil = parseInt(ganjil.nilai);
            if(ganjilSelesai) bulanSelesaiGanjil = parseInt(ganjilSelesai.nilai);
            if(genap) bulanGenap = parseInt(genap.nilai);
            if(genapSelesai) bulanSelesaiGenap = parseInt(genapSelesai.nilai);
        }

        res.render('master_data', { 
            kelas: resKelas.data.data,
            angkatan: resAngkatan.data.data,
            tahunAkademik: resTa.data.data,
            pengaturan: { bulanGanjil, bulanSelesaiGanjil, bulanGenap, bulanSelesaiGenap }
        });
    } catch (error) {
        console.error("Gagal mengambil master data:", error.message);
        res.render('master_data', { kelas: [], angkatan: [], tahunAkademik: [], pengaturan: { bulanGanjil: 7, bulanSelesaiGanjil: 12, bulanGenap: 1, bulanSelesaiGenap: 6 } });
    }
});

// Setting Pengaturan
app.post('/master-data/pengaturan', cekAdmin, async (req, res) => {
    try {
        await axios.post('http://127.0.0.1:3000/api/admin/master/pengaturan', req.body);
        res.redirect('/master-data');
    } catch (error) { res.redirect('/master-data?error=Gagal_simpan_pengaturan'); }
});

// Master Kelas
app.post('/master-data/kelas', cekAdmin, async (req, res) => {
    try {
        await axios.post('http://127.0.0.1:3000/api/admin/master/kelas', req.body);
        res.redirect('/master-data');
    } catch (error) { 
        res.redirect('/master-data?error=' + encodeURIComponent(error.response?.data?.message || 'Gagal_tambah_kelas')); 
    }
});
app.post('/master-data/kelas/delete/:id', cekAdmin, async (req, res) => {
    try {
        await axios.delete(`http://127.0.0.1:3000/api/admin/master/kelas/${req.params.id}`);
        res.redirect('/master-data');
    } catch (error) { res.redirect('/master-data?error=Gagal_hapus_kelas'); }
});

// Master Angkatan
app.post('/master-data/angkatan', cekAdmin, async (req, res) => {
    try {
        await axios.post('http://127.0.0.1:3000/api/admin/master/angkatan', req.body);
        res.redirect('/master-data');
    } catch (error) { 
        res.redirect('/master-data?error=' + encodeURIComponent(error.response?.data?.message || 'Gagal_tambah_angkatan')); 
    }
});
app.post('/master-data/angkatan/delete/:id', cekAdmin, async (req, res) => {
    try {
        await axios.delete(`http://127.0.0.1:3000/api/admin/master/angkatan/${req.params.id}`);
        res.redirect('/master-data');
    } catch (error) { res.redirect('/master-data?error=Gagal_hapus_angkatan'); }
});
app.post('/master-data/angkatan/activate/:id', cekAdmin, async (req, res) => {
    try {
        await axios.put(`http://127.0.0.1:3000/api/admin/master/angkatan/${req.params.id}/toggle-active`);
        res.redirect('/master-data');
    } catch (error) { res.redirect('/master-data?error=Gagal_toggle_angkatan'); }
});

// Master Tahun Akademik
app.post('/master-data/tahun-akademik', cekAdmin, async (req, res) => {
    try {
        await axios.post('http://127.0.0.1:3000/api/admin/master/tahun-akademik', req.body);
        res.redirect('/master-data');
    } catch (error) { 
        res.redirect('/master-data?error=' + encodeURIComponent(error.response?.data?.message || 'Gagal_tambah_ta')); 
    }
});
app.post('/master-data/tahun-akademik/activate/:id', cekAdmin, async (req, res) => {
    try {
        await axios.put(`http://127.0.0.1:3000/api/admin/master/tahun-akademik/${req.params.id}/toggle-active`);
        res.redirect('/master-data');
    } catch (error) { res.redirect('/master-data?error=Gagal_aktifkan_ta'); }
});
app.post('/master-data/tahun-akademik/delete/:id', cekAdmin, async (req, res) => {
    try {
        await axios.delete(`http://127.0.0.1:3000/api/admin/master/tahun-akademik/${req.params.id}`);
        res.redirect('/master-data');
    } catch (error) { res.redirect('/master-data?error=Gagal_hapus_ta'); }
});

// --- RUTE ENROLMENT KELAS ---
app.get('/enrolment', cekAdmin, async (req, res) => {
    try {
        const [resEnrolment, resMaster] = await Promise.all([
            axios.get('http://127.0.0.1:3000/api/admin/enrolment'),
            axios.get('http://127.0.0.1:3000/api/admin/enrolment/master-data')
        ]);
        const enrolmentData = resEnrolment.data.data;
        const masterKelasList = resMaster.data.data.kelas;

        // Hitung prefixData (Tingkat Kelas)
        const prefixes = [...new Set(masterKelasList.map(k => k.namaKelas.split(' ')[0].toUpperCase()))].sort();
        const prefixData = prefixes.map(pref => {
            const enr = enrolmentData.find(row => row.masterKelas.namaKelas.startsWith(pref + ' ') && row.enrolment);
            return {
                prefix: pref,
                angkatanId: enr ? enr.enrolment.angkatanId : '',
                tahunAkademikId: enr ? enr.enrolment.tahunAkademikId : '',
                angkatanName: enr ? enr.enrolment.masterAngkatan.nomorAngkatan : '-',
                taName: enr ? `${enr.enrolment.masterTahunAkademik.tahunAjaran} (${enr.enrolment.masterTahunAkademik.semester})` : '-'
            };
        });

        res.render('enrolment', { 
            enrolmentData: enrolmentData,
            masterData: resMaster.data.data,
            prefixData: prefixData
        });
    } catch (error) {
        console.error("Gagal mengambil data enrolment:", error.message);
        res.render('enrolment', { enrolmentData: [], masterData: { kelas: [], angkatan: [], ta: [] }, prefixData: [] });
    }
});

app.post('/enrolment/edit-tingkat', cekAdmin, async (req, res) => {
    try {
        await axios.post(`http://127.0.0.1:3000/api/admin/enrolment/edit-tingkat`, req.body);
        res.redirect('/enrolment');
    } catch (error) { 
        res.redirect('/enrolment?error=' + encodeURIComponent(error.response?.data?.message || 'Gagal_mengatur_tingkat')); 
    }
});

app.post('/enrolment/reset-tingkat', cekAdmin, async (req, res) => {
    try {
        await axios.post(`http://127.0.0.1:3000/api/admin/enrolment/reset-tingkat`, req.body);
        res.redirect('/enrolment');
    } catch (error) { res.redirect('/enrolment?error=Gagal_mereset_tingkat'); }
});

app.post('/enrolment/edit-keterangan/:kelasId', cekAdmin, async (req, res) => {
    try {
        await axios.post(`http://127.0.0.1:3000/api/admin/enrolment/edit-keterangan/${req.params.kelasId}`, req.body);
        res.redirect('/enrolment');
    } catch (error) { 
        res.redirect('/enrolment?error=' + encodeURIComponent(error.response?.data?.message || 'Gagal_mengatur_keterangan')); 
    }
});

// GET Template Excel
app.get('/enrolment/template-excel', cekAdmin, async (req, res) => {
    try {
        const response = await axios.get('http://127.0.0.1:3000/api/admin/enrolment/template-excel', { responseType: 'arraybuffer' });
        res.setHeader('Content-Disposition', 'attachment; filename="Template_Upload_Siswa.xlsx"');
        res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        res.send(response.data);
    } catch (error) {
        console.error("Gagal unduh template:", error.message);
        res.redirect('/enrolment?error=Gagal_mengunduh_template');
    }
});

// Upload Excel Siswa
app.post('/enrolment/:id/siswa/upload', cekAdmin, upload.single('fileExcel'), async (req, res) => {
    try {
        if (!req.file) {
            return res.redirect(`/enrolment/${req.params.id}?error=File_tidak_ditemukan`);
        }
        const formData = new FormData();
        formData.append('fileExcel', fs.createReadStream(req.file.path));

        await axios.post(`http://127.0.0.1:3000/api/admin/enrolment/${req.params.id}/siswa/upload`, formData, {
            headers: {
                ...formData.getHeaders()
            }
        });
        
        fs.unlinkSync(req.file.path);
        res.redirect(`/enrolment/${req.params.id}`);
    } catch (error) {
        if(req.file) fs.unlinkSync(req.file.path);
        console.error("Gagal upload excel:", error.message);
        res.redirect(`/enrolment/${req.params.id}?error=Gagal_upload_excel`);
    }
});

// Detail Enrolment (Siswa & Guru)
app.get('/enrolment/:id', cekAdmin, async (req, res) => {
    try {
        const response = await axios.get(`http://127.0.0.1:3000/api/admin/enrolment/${req.params.id}/detail`);
        res.render('enrolment_detail', { detail: response.data.data });
    } catch (error) {
        console.error("Gagal mengambil detail kelas:", error.message);
        res.redirect('/enrolment?error=Gagal_mengambil_detail');
    }
});

app.post('/enrolment/:id/siswa', cekAdmin, async (req, res) => {
    try {
        await axios.post(`http://127.0.0.1:3000/api/admin/enrolment/${req.params.id}/siswa`, req.body);
        res.redirect(`/enrolment/${req.params.id}`);
    } catch (error) { res.redirect(`/enrolment/${req.params.id}?error=Gagal_tambah_siswa`); }
});

app.post('/enrolment/:id/siswa/delete/:siswaId', cekAdmin, async (req, res) => {
    try {
        await axios.delete(`http://127.0.0.1:3000/api/admin/enrolment/${req.params.id}/siswa/${req.params.siswaId}`);
        res.redirect(`/enrolment/${req.params.id}`);
    } catch (error) { res.redirect(`/enrolment/${req.params.id}?error=Gagal_hapus_siswa`); }
});

app.post('/enrolment/:id/guru', cekAdmin, async (req, res) => {
    try {
        await axios.post(`http://127.0.0.1:3000/api/admin/enrolment/${req.params.id}/guru`, req.body);
        res.redirect(`/enrolment/${req.params.id}`);
    } catch (error) { res.redirect(`/enrolment/${req.params.id}?error=Gagal_tambah_guru`); }
});

app.post('/enrolment/:id/guru/delete/:guruId', cekAdmin, async (req, res) => {
    try {
        await axios.delete(`http://127.0.0.1:3000/api/admin/enrolment/${req.params.id}/guru/${req.params.guruId}`);
        res.redirect(`/enrolment/${req.params.id}`);
    } catch (error) { res.redirect(`/enrolment/${req.params.id}?error=Gagal_hapus_guru`); }
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