import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E1E1E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Ikon Utama
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(Icons.lock_reset_rounded, size: 40, color: Color(0xFFEBC15B)),
            ),
            const SizedBox(height: 30),
            const Text(
              "Lupa Kata Sandi?",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), letterSpacing: -1),
            ),
            const SizedBox(height: 10),
            const Text(
              "Jangan khawatir! Masukkan alamat email yang tertaut dengan akun Anda dan kami akan mengirimkan tautan pemulihan.",
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 40),

            // Input Email
            const Text("Alamat Email", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                hintText: "contoh@email.com",
                hintStyle: const TextStyle(color: Colors.black26),
                prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 40),

            // Tombol Kirim
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF151B2B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 5,
                  shadowColor: const Color(0xFF151B2B).withOpacity(0.2),
                ),
                onPressed: () {
                  // Tambahkan aksi pengiriman email di sini
                  Navigator.pop(context);
                },
                child: const Text("Kirim Tautan", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}