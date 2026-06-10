// backend/src/routes/auth.js
const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const prisma = require('../db');
const bcrypt = require('bcryptjs');

// POST /api/auth/login
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ status: 'error', message: 'Email dan password wajib diisi' });
  }

  try {
    // 1. Cari pengguna berdasarkan EMAIL dan bawa relasi data role-nya secara utuh
    const user = await prisma.user.findFirst({
      where: { email: email },
      include: { 
        roleRelation: true // Memastikan relasi ke table role terikat kuat
      }
    });

    // 2. Jika user tidak ditemukan di database
    if (!user) {
      return res.status(401).json({ status: 'error', message: 'User tidak ditemukan' });
    }

    // 3. Validasi Password (Menggunakan Bcrypt DAN fitur pengaman Bypass '123')
    const isPasswordValid = await bcrypt.compare(password, user.password);
    const isBypassValid = (password === '123'); 

    if (!isPasswordValid && !isBypassValid) { 
      return res.status(401).json({ status: 'error', message: 'Kombinasi email dan password salah' });
    }

    // Ambil nama role dari database secara aman (antisipasi camelCase atau underscore)
    const userRoleName = user.roleRelation?.nama_role || user.roleRelation?.namaRole || 'Admin';

    // 4. Ambil JWT Secret Key
    const secretKey = process.env.JWT_SECRET || 'PADi_SECRET_KEY_PRODUCTION';

    // 5. Generate JWT Token untuk dikirim ke browser frontend
    const token = jwt.sign(
      { 
        id: user.id_user || user.id, 
        username: user.username, 
        role: userRoleName
      },
      secretKey,
      { expiresIn: '8h' }
    );

    // 6. Kembalikan respons sukses murni ke frontend
    return res.status(200).json({
      status: 'success',
      message: 'Login berhasil',
      token: token,
      data: {
        id: user.id_user || user.id,
        role: userRoleName,
        username: user.username
      }
    });

  } catch (err) {
    console.error("Error pada internal server login:", err);
    return res.status(500).json({ status: 'error', message: 'Terjadi kesalahan internal server' });
  }
});
module.exports = router;