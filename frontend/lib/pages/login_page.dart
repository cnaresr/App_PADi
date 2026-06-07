import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:platform_absensi_digital/providers/user_provider.dart';
import 'package:platform_absensi_digital/pages/contact_admin_page.dart';
import 'package:platform_absensi_digital/pages/main_page.dart';
import 'package:platform_absensi_digital/pages/forgot_password_page.dart';
import 'package:platform_absensi_digital/pages/login_guru_page.dart';
import 'package:platform_absensi_digital/services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 250,
              child: Stack(
                children: [
                  Positioned(top: -50, right: -50, child: Container(width: 200, height: 200, decoration: const BoxDecoration(color: Color(0xFFE8F3F1), shape: BoxShape.circle))),
                  Positioned(top: 100, left: -30, child: Container(width: 100, height: 100, decoration: const BoxDecoration(color: Color(0xFFFFF3E0), shape: BoxShape.circle))),
                  const Positioned(
                    bottom: 20, left: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Selamat Datang", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), letterSpacing: -1)),
                        SizedBox(height: 5),
                        Text("Silakan masuk untuk melanjutkan", style: TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Alamat Email", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none), hintText: "Masukkan email", prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey)),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Kata Sandi", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
                      TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordPage())), child: const Text("Lupa Sandi?", style: TextStyle(color: Color(0xFFEBC15B), fontWeight: FontWeight.bold))),
                    ],
                  ),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none), hintText: "••••••••", prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.grey)),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity, height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF151B2B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 10),
                      onPressed: () async { 
                        var response = await ApiService.login(_emailController.text, _passwordController.text);
                        
                        if (response['status'] == 'success') {
                          var userData = response['data'] as Map<String, dynamic>;
                          
                          String namaLengkap = userData['username'] ?? userData['nama'] ?? "Pengguna";
                          String roleUser = userData['role'] ?? "Siswa";
                          String infoKelas = userData['kelas'] ?? "XII RPL 1 • SMK Negeri 1 Jakarta";
                          
                          // AMBIL ID USER DARI DATABASE
                          int idUser = userData['id'] ?? 0;

                          // 1. SIMPAN DATA KE PROVIDER (DENGAN 4 PARAMETER)
                          final userProvider = Provider.of<UserProvider>(context, listen: false);
                          userProvider.setUserData(idUser, namaLengkap, infoKelas, roleUser);

                          // 2. TEMBAK API DASHBOARD
                          var dashResponse = await ApiService.getDashboardData(idUser);
                          if (dashResponse['status'] == 'success') {
                            var dashData = dashResponse['data'];
                            userProvider.setDashboardData(
                              dashData['hadirBulanIni'],
                              dashData['persentaseKehadiran'],
                              dashData['riwayatAbsensi'],
                              dashData['riwayatPerizinan'],
                            );
                          }

                          // 3. BERPINDAH HALAMAN
                          if (userData['role'] == 'siswa' || userData['role'] == 'Siswa') {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainPage()));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gunakan portal login pengajar!")));
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'] ?? "Login gagal")));
                        }
                      },
                      child: const Text("Masuk", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactAdminPage())),
                          child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), decoration: BoxDecoration(color: const Color(0xFFF1F4FF), borderRadius: BorderRadius.circular(15)), child: const Text("Belum punya akun? Hubungi Admin", style: TextStyle(color: Color(0xFF006D5B), fontWeight: FontWeight.bold, fontSize: 13))),
                        ),
                        const SizedBox(height: 15),
                        TextButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginGuruPage())), child: const Text("Login Sebagai Pengajar", style: TextStyle(color: Color(0xFF151B2B), fontWeight: FontWeight.bold, decoration: TextDecoration.underline))),
                      ],
                    ),
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