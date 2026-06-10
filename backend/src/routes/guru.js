const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const bcrypt = require('bcryptjs');

// Import middleware proteksi
const verifyToken = require('../middleware/auth');
const adminAuth = require('../middleware/adminAuth');

// Proteksi semua rute Guru: Hanya Admin yang sudah login yang boleh akses
router.use(verifyToken);
router.use(adminAuth);

// ==========================================
// 1. [READ] - Mengambil Semua Data Guru
// ==========================================
router.get('/', async (req, res) => {
  try {
    const daftarGuru = await prisma.guru.findMany({
      include: {
        user: {
          select: {
            username: true,
            email: true,
            roleRelation: {
              select: {
                namaRole: true
              }
            }
          }
        },
        sekolah: {
          select: {
            namaSekolah: true
          }
        }
      }
    });
    res.status(200).json({ status: 'success', data: daftarGuru });
  } catch (error) {
    console.error("Error pada GET /api/guru:", error);
    res.status(500).json({ status: 'error', message: error.message });
  }
});

// ==========================================\
// 2. [CREATE] - Menambahkan Guru & User Baru
// ==========================================\
router.post('/', async (req, res) => {
  const { username, email, password, nama_lengkap, NIP } = req.body;

  // Sinkronisasi: pastikan input NIP atau nip bisa terbaca keduanya
  const nomorIndukPegawai = NIP || req.body.nip;

  if (!username || !email || !password || !nama_lengkap || !nomorIndukPegawai) {
    return res.status(400).json({ status: 'error', message: 'Semua data wajib diisi (Username, Email, Password, Sekolah, Nama, NIP)' });
  }

  try {
    // Cek apakah email user sudah terdaftar
    const existingUser = await prisma.user.findFirst({ where: { email } });
    if (existingUser) {
      return res.status(409).json({ status: 'error', message: 'Email sudah terdaftar!' });
    }

    // Hash password guru baru
    const hashedPassword = await bcrypt.hash(password, 10);

    const guruBaru = await prisma.$transaction(async (tx) => {
      console.log("DEBUG: Mencoba membuat User...");
      // Buat akun di tabel user terlebih dahulu (id_role = 2 untuk Guru)
      const user = await tx.user.create({
        data: {
          username,
          email,
          password: hashedPassword,
          roleId: 2 // Sesuaikan dengan seed.js
        }
      });

      console.log("DEBUG: User berhasil dibuat dengan ID:", user.id);
      // Hubungkan ke tabel guru
      console.log("DEBUG: Mencoba membuat Profil Guru...");
      return await tx.guru.create({
        data: {
          userId: user.id, // Sesuaikan dengan seed.js
          namaLengkap: nama_lengkap,
          nip: nomorIndukPegawai,
          sekolahId: 1 // Tambahkan default ID Sekolah agar tidak error di database/query
        }
      });
    });

    res.status(201).json({ status: 'success', message: 'Guru berhasil ditambahkan!', data: guruBaru });
  } catch (error) {
    console.error("Error pada POST /api/guru:", error);
    res.status(500).json({ status: 'error', message: error.message });
  }
});
// ==========================================
// 3. [UPDATE] - Memperbarui Data Guru & User
// ==========================================
router.put('/:id_guru', async (req, res) => {
  const { id_guru } = req.params;
  const { username, email, password, nama_lengkap, NIP } = req.body;

  // Sinkronisasi: pastikan input NIP atau nip bisa terbaca keduanya
  const nomorIndukPegawai = NIP || req.body.nip;

  try {
    const guruTarget = await prisma.guru.findUnique({
      where: { id: parseInt(id_guru) },
      include: { user: true } // Sertakan relasi user untuk mendapatkan ID user
    });
    if (!guruTarget) {
      return res.status(404).json({ status: 'error', message: 'Data guru tidak ditemukan!' });
    }

    await prisma.$transaction(async (tx) => {
      // Update data Profil Guru
      await tx.guru.update({
        where: { id: parseInt(id_guru) }, 
        data: {
          namaLengkap: nama_lengkap,
          nip: nomorIndukPegawai
        }
      });

      // Siapkan data user yang diupdate
      const userData = { username, email };
      if (password) {
        userData.password = await bcrypt.hash(password, 10);
      }

      // Update data Akun User terkait
      await tx.user.update({
        where: { id: guruTarget.user.id }, // Akses ID user melalui relasi user
        data: userData
      });
    });

    res.status(200).json({ status: 'success', message: 'Data guru berhasil diperbarui!' });
  } catch (error) {
    console.error("Error pada PUT /api/guru/:id_guru:", error);
    res.status(500).json({ status: 'error', message: error.message });
  }
});

// ==========================================
// 4. [DELETE] - Menghapus Guru beserta User-nya
// ==========================================
router.delete('/:id_guru', async (req, res) => {
  const { id_guru } = req.params;

  try {
    const guruTarget = await prisma.guru.findUnique({
      where: { id: parseInt(id_guru) },
      include: { user: true } // Sertakan relasi user untuk mendapatkan ID user
    });
    if (!guruTarget) {
      return res.status(404).json({ status: 'error', message: 'Data guru tidak ditemukan!' });
    }

    await prisma.$transaction(async (tx) => {
      // Hapus profil guru terlebih dahulu karena ia memegang Foreign Key ke User
      await tx.guru.delete({ where: { id: parseInt(id_guru) } });
      // Hapus akun user
      await tx.user.delete({ where: { id: guruTarget.user.id } }); // Akses ID user melalui relasi user
    });

    res.status(200).json({ status: 'success', message: 'Guru dan akun berhasil dihapus!' });
  } catch (error) {
    console.error("Error pada DELETE /api/guru/:id_guru:", error);
    res.status(500).json({ status: 'error', message: 'Gagal menghapus data. Pastikan tidak ada data absensi/kelas terkait.', detail: error.message });
  }
});

module.exports = router;