const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../config/db'); // Menggunakan koneksi pg pool bawaan
require('dotenv').config();

// ==========================================
// POST /api/auth/login (Dinamis dari Database)
// ==========================================
router.post('/login', async (req, res) => {
  // Menerima input identifier (bisa berupa email atau username) dan password
  const { identifier, password } = req.body; 

  if (!identifier || !password) {
    return res.status(400).json({ message: 'Email/Username dan password wajib diisi' });
  }

  try {
    // Query dinamis: Mencari ke database apakah identifier cocok dengan email ATAU username
    const result = await pool.query(
      'SELECT * FROM "user" WHERE email = $1 OR username = $2', 
      [identifier, identifier]
    );

    // Jika tidak ditemukan di database
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Akun tidak terdaftar di sistem' });
    }

    const user = result.rows[0];

    // Membandingkan password yang diketik dengan hash asli hasil tarikan database
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Password yang Anda masukkan salah' });
    }

    // Ambil role secara dinamis berdasarkan id_role dari database (misal: 1 = admin, 2 = siswa)
    const userRole = user.id_role === 1 ? 'admin' : 'siswa';

    // Buat JWT token dinamis menggunakan data asli dari baris database
    const token = jwt.sign(
      { 
        id: user.id_user, 
        email: user.email, 
        username: user.username,
        role: userRole 
      },
      process.env.JWT_SECRET,
      { expiresIn: '8h' }
    );

    // Kembalikan respon sukses beserta token
    res.status(200).json({
      message: 'Login berhasil!',
      token,
      user: {
        id: user.id_user,
        username: user.username,
        email: user.email,
        role: userRole
      },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Terjadi kesalahan pada server', details: err.message });
  }
});

module.exports = router;