const adminAuth = (req, res, next) => {
  // 1. Pastikan token sudah lolos verifikasi verifyToken (auth.js)
  if (!req.user) {
    return res.status(401).json({ message: 'Akses ditolak. Token tidak ditemukan.' });
  }

  // 2. Cek role berdasarkan string 'admin' (case-insensitive)
  if (req.user.role && req.user.role.toLowerCase() === 'admin') {
    next(); // Lolos, silakan lanjut ke CRUD Admin
  } else {
    return res.status(403).json({ message: 'Akses ditolak. Halaman ini khusus untuk akun Admin.' });
  }
};

module.exports = adminAuth;