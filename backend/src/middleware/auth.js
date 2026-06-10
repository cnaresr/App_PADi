const jwt = require('jsonwebtoken');

const verifyToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) return res.status(401).json({ message: 'Token tidak tersedia' });

  const secretKey = process.env.JWT_SECRET || 'PADi_SECRET_KEY_PRODUCTION';
  jwt.verify(token, secretKey, (err, decoded) => {
    if (err) return res.status(403).json({ message: 'Token tidak valid' });
    
    // Simpan data decoded (id, email, role) ke req.user agar bisa dibaca oleh adminAuth
    req.user = decoded; 
    next();
  });
};

module.exports = verifyToken;