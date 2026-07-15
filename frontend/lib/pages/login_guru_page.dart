import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Wajib ada untuk Provider
import 'package:platform_absensi_digital/providers/user_provider.dart'; // Wajib ada untuk memanggil set data
import 'package:platform_absensi_digital/pages/main_guru_page.dart';
import 'package:platform_absensi_digital/services/api_service.dart';
import 'package:platform_absensi_digital/services/firebase_messaging_service.dart';
import 'package:platform_absensi_digital/widgets/custom_popup.dart';
import 'package:platform_absensi_digital/widgets/page_transitions.dart';

class LoginGuruPage extends StatefulWidget {
  const LoginGuruPage({super.key});

  @override
  State<LoginGuruPage> createState() => _LoginGuruPageState();
}

class _LoginGuruPageState extends State<LoginGuruPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

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
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      hintText: "••••••••",
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF151B2B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 10, shadowColor: const Color(0xFF151B2B).withValues(alpha: 0.2)),
                      onPressed: () async {
                        // MENGGUNAKAN .trim() AGAR KEBAL TERHADAP SPASI GAIB
                        var response = await ApiService.login(_emailController.text.trim(), _passwordController.text);
                        
                        if (response['status'] == 'success') {
                          if (!context.mounted) return;
                          var userData = response['data'] as Map<String, dynamic>;
                          
                          // Memastikan yang login adalah guru
                          if (userData['role'] == 'guru' || userData['role'] == 'Guru') {
                            
                            // 1. MENYIMPAN IDENTITAS KE MEMORI PROVIDER
                            String namaLengkap = userData['username'] ?? userData['nama'] ?? "Pengajar";
                            String nip = userData['nip'] ?? "NIP Belum Diatur";
                            int idUser = userData['id'] ?? 0;
                            String emailUser = userData['email'] ?? "Email tidak tersedia";

                            Provider.of<UserProvider>(context, listen: false)
                                .setUserData(idUser, namaLengkap, nip, userData['role'], emailStr: emailUser);

                            // 2. AMBIL DATA DASHBOARD KHUSUS GURU
                            var dashResponse = await ApiService.getDashboardGuru(idUser);
                            if (dashResponse['status'] == 'success') {
                              if (!context.mounted) return;
                              var dashData = dashResponse['data'] as Map<String, dynamic>?;
                              // [FIX] Nama method diperbaiki & ditambahkan null-safety
                              Provider.of<UserProvider>(context, listen: false).setGuruDashboardData(
                                dashData?['jumlahIzinPending'] ?? 0,
                                dashData?['persentaseKehadiranKelas'] ?? 0,
                                dashData?['rekapAbsensiKelas'] ?? [],
                                dashData?['jadwalMengajar'] ?? []
                              );
                            }
                            // Update FCM Token ke Server
                            if (response['token'] != null) {
                              FirebaseMessagingService.updateFCMTokenToServer(idUser, response['token']);
                            }

                              if (!context.mounted) return;
                              Navigator.pushReplacement(context, PageTransition.scaleFade(const MainGuruPage()));
                            } else {
                              if (!context.mounted) return;
                              CustomPopup.show(context, message: "Anda bukan pengajar!", type: PopupType.warning);
                            }
                          } else {
                            if (!context.mounted) return;
                            CustomPopup.show(context, message: response['message'] ?? "Login gagal", type: PopupType.error);
                          }
                      },
                      child: const Text("Masuk", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  Center(
                    child: TextButton(
                       onPressed: () => Navigator.pop(context),
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