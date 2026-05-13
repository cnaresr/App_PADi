import 'package:flutter/material.dart';
import 'package:platform_absensi_digital/pages/contact_admin_page.dart'; // Sesuaikan jika namanya berbeda
// PERBAIKAN: Import main_page.dart agar tombol 'Masuk' berfungsi
import 'package:platform_absensi_digital/pages/main_page.dart'; 
// Tambahkan import halaman lupa password di sini
import 'package:platform_absensi_digital/pages/forgot_password_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Selamat Datang",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0D1B2A)),
            ),
            const SizedBox(height: 8),
            const Text(
              "Silahkan masuk ke akun anda untuk melanjutkan.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            
            // Input Email
            const Text("Alamat Email", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF1F4FF),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),

            // Input Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Kata Sandi", style: TextStyle(fontWeight: FontWeight.w600)),
                // PERBAIKAN: Navigasi ke Halaman Lupa Password
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()), 
                    );
                  }, 
                  child: const Text("Lupa Password?", style: TextStyle(color: Colors.brown, fontSize: 12)),
                ),
              ],
            ),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: const Icon(Icons.visibility_outlined),
                filled: true,
                fillColor: const Color(0xFFF1F4FF),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                hintText: ".........",
              ),
            ),
            const SizedBox(height: 30),

            // Tombol Masuk
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006D5B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                onPressed: () {
                  // PERBAIKAN: Navigasi ke MainPage saat tombol Masuk ditekan
                  Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(builder: (context) => const MainPage())
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Masuk", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            // Footer
            Center(
              child: Column(
                children: [
                  // Membungkus Text dengan GestureDetector agar bisa di-klik
                  GestureDetector(
                    onTap: () {
                      // Kode untuk berpindah ke halaman ContactAdminPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ContactAdminPage()),
                      );
                    },
                    child: const Text(
                      "Belum punya akun? Hubungi Admin Sekolah", 
                      style: TextStyle(color: Color(0xFF006D5B), fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 5),
                  
                  // Opsional: Anda juga bisa melakukan hal yang sama untuk teks ini nanti
                  const Text(
                    "Login Sebagai Guru?", 
                    style: TextStyle(color: Color(0xFF006D5B), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}