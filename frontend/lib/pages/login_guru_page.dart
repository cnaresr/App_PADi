import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Wajib ada untuk Provider
import 'package:platform_absensi_digital/providers/user_provider.dart'; // Wajib ada untuk memanggil set data
import 'package:platform_absensi_digital/pages/main_guru_page.dart';
import 'package:platform_absensi_digital/pages/login_page.dart';
import 'package:platform_absensi_digital/services/api_service.dart';

class LoginGuruPage extends StatefulWidget {
  const LoginGuruPage({super.key});

  @override
  State<LoginGuruPage> createState() => _LoginGuruPageState();
}

class _LoginGuruPageState extends State<LoginGuruPage> {
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
                  Positioned(top: -50, right: -50, child: Container(width: 200, height: 200, decoration: const BoxDecoration(color: Color(0xFFF3E5F5), shape: BoxShape.circle))),
                  Positioned(top: 100, left: -30, child: Container(width: 100, height: 100, decoration: const BoxDecoration(color: Color(0xFFFFF3E0), shape: BoxShape.circle))),
                  const Positioned(
                    bottom: 20, left: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Portal Guru", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), letterSpacing: -1)),
                        SizedBox(height: 5),
                        Text("Manajemen absensi & kelas", style: TextStyle(color: Colors.grey, fontSize: 14)),
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
                  const Text("NIP / Email Pengajar", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none), hintText: "Masukkan NIP/Email", prefixIcon: const Icon(Icons.badge_outlined, color: Colors.grey)),
                  ),
                  const SizedBox(height: 25),

                  const Text("Kata Sandi", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    obscureText: true, 
                    decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none), hintText: "••••••••", prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.grey)),
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF151B2B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 10, shadowColor: const Color(0xFF151B2B).withOpacity(0.2)),
                      onPressed: () async {
                        // MENGGUNAKAN .trim() AGAR KEBAL TERHADAP SPASI GAIB
                        var response = await ApiService.login(_emailController.text.trim(), _passwordController.text);
                        
                        if (response['status'] == 'success') {
                          var userData = response['data'] as Map<String, dynamic>;
                          
                          // Memastikan yang login adalah guru
                          if (userData['role'] == 'guru' || userData['role'] == 'Guru') {
                            
                            // 1. MENYIMPAN IDENTITAS KE MEMORI PROVIDER
                            String namaLengkap = userData['username'] ?? userData['nama'] ?? "Pengajar";
                            String nip = userData['nip'] ?? "NIP Belum Diatur";
                            int idUser = userData['id'] ?? 0;

                            Provider.of<UserProvider>(context, listen: false)
                                .setUserData(idUser, namaLengkap, nip, userData['role']);

                            // 2. AMBIL DATA DASHBOARD KHUSUS GURU
                            var dashResponse = await ApiService.getDashboardGuru(idUser);
                            if (dashResponse['status'] == 'success') {
                              var dashData = dashResponse['data'];
                              Provider.of<UserProvider>(context, listen: false).setDashboardGuruData(
                                dashData['jumlahIzinPending'],
                                dashData['persentaseKehadiranKelas'],
                                dashData['rekapAbsensiKelas'],
                                dashData['jadwalMengajar']
                              );
                            }

                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainGuruPage()));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Anda bukan pengajar!")));
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
                    child: TextButton(
                      onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage())),
                      child: const Text("Kembali ke Login Siswa", style: TextStyle(color: Color(0xFF8F306A), fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
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