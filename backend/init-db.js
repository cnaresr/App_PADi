const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    password: process.env.DB_PASSWORD,
    port: process.env.DB_PORT,
});

async function initDB() {
    try {
        console.log("Mencoba terhubung ke PostgreSQL...");
        
        // 1. Menyiapkan Tabel Users (Menggunakan EMAIL & USERNAME, Bukan NIM)
        const createUsersTable = `
            CREATE TABLE IF NOT EXISTS "user" (
                id_user SERIAL PRIMARY KEY,
                nama VARCHAR(255) NOT NULL,
                username VARCHAR(100) UNIQUE NOT NULL,
                email VARCHAR(255) UNIQUE NOT NULL,
                password TEXT NOT NULL,
                role VARCHAR(50) DEFAULT 'siswa',
                fcm_token TEXT
            );
        `;
        await pool.query(createUsersTable);
        console.log("✅ Tabel 'user' sekolah berhasil disiapkan.");

        // 2. MENYISIPKAN DATA ADMIN DEFAULT (Menggunakan Email & Username)
        // Menggunakan ON CONFLICT (email) DO NOTHING agar tidak duplikat saat di-run ulang
        const insertAdminSeed = `
            INSERT INTO "user" (nama, username, email, password, role)
            VALUES ('Admin App PADi', 'naresz', 'admin@gmail.com', '123', 'admin')
            ON CONFLICT (email) DO NOTHING;
        `;
        await pool.query(insertAdminSeed);
        console.log("✅ Data seed Admin Sekolah default berhasil dipastikan aman.");

        // 3. Menyiapkan Tabel Presensi (Menggunakan MATA_PELAJARAN, Bukan Mata Kuliah)
        const createPresensiTable = `
            CREATE TABLE IF NOT EXISTS presensi (
                id SERIAL PRIMARY KEY,
                user_id INTEGER REFERENCES "user"(id_user) ON DELETE CASCADE,
                mata_pelajaran VARCHAR(255) NOT NULL,
                latitude VARCHAR(100),
                longitude VARCHAR(100),
                tanggal DATE DEFAULT CURRENT_DATE,
                waktu TIME DEFAULT CURRENT_TIME,
                status VARCHAR(50) DEFAULT 'hadir'
            );
        `;
        await pool.query(createPresensiTable);
        console.log("✅ Tabel 'presensi' sekolah berhasil disiapkan.");

        console.log("\nKonfigurasi database SEKOlAH selesai! Anda bisa menjalankan 'npm start' sekarang.");
    } catch (err) {
        console.error("❌ Terjadi kesalahan saat konfigurasi database:");
        console.error(err.message);
    } finally {
        await pool.end();
    }
}

initDB();