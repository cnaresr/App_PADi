const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const bcrypt = require('bcryptjs');

const verifyToken = require('../middleware/auth');
const adminAuth = require('../middleware/adminAuth');

// Proteksi rute: Hanya user log-in dengan token & role admin yang bisa lewat
router.use(verifyToken);
router.use(adminAuth);

// =======================================================
// [CREATE] - Membuat Akun Admin Baru Secara Dinamis
// =======================================================
router.post('/users', async (req, res) => {
  // Semua data diambil murni dari body request client, bukan di-set manual
  const { username, email, password, id_role } = req.body;

  if (!username || !email || !password) {
    return res.status(400).json({ message: 'Username, email, dan password wajib diisi' });
  }

  try {
    // 1. Validasi Dinamis: Cek ke database apakah email/username sudah dipakai akun lain
    const existingUser = await prisma.user.findFirst({
      where: {
        OR: [
          { email: email },
          { username: username }
        ]
      }
    });

    if (existingUser) {
      return res.status(409).json({ message: 'Email atau Username sudah digunakan' });
    }

    // 2. Hash password yang dikirim dari request secara dinamis
    const hashedPassword = await bcrypt.hash(password, 10);

    // 3. Simpan data ke tabel user secara dinamis
    const userBaru = await prisma.user.create({
      data: {
        username,
        email,
        password: hashedPassword,
        id_role: parseInt(id_role) || 1 // Jika tidak ditentukan, default ke 1 (Admin)
      },
      select: {
        id_user: true,
        username: true,
        email: true,
        id_role: true
      }
    });

    res.status(201).json({
      message: 'Akun baru berhasil disimpan ke database!',
      data: userBaru
    });

  } catch (error) {
    res.status(500).json({ error: 'Gagal menyimpan data', details: error.message });
  }
});

module.exports = router;