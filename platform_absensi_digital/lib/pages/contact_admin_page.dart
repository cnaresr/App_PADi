import 'package:flutter/material.dart';

class ContactAdminPage extends StatelessWidget {
  const ContactAdminPage({super.key});

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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ikon Utama
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F3F1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(Icons.support_agent_rounded, size: 40, color: Color(0xFF006D5B)),
            ),
            const SizedBox(height: 30),
            const Text(
              "Belum Punya Akun?",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), letterSpacing: -1),
            ),
            const SizedBox(height: 10),
            const Text(
              "Untuk menjaga keamanan, pembuatan akun hanya dapat dilakukan melalui Administrator Sekolah. Silakan hubungi kontak di bawah ini.",
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 40),

            // Card Kontak
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
                ],
              ),
              child: Column(
                children: [
                  _buildContactBtn(
                    icon: Icons.chat_bubble_rounded, 
                    color: const Color(0xFF38A169), 
                    bgColor: const Color(0xFFE5F4EC), 
                    title: "WhatsApp Admin"
                  ),
                  const SizedBox(height: 15),
                  _buildContactBtn(
                    icon: Icons.email_rounded, 
                    color: const Color(0xFFEBC15B), 
                    bgColor: const Color(0xFFFFF3E0), 
                    title: "Email Support"
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on_rounded, color: Colors.grey, size: 16),
                        SizedBox(width: 8),
                        Text("Gedung Utama, Lantai 2, Ruang IT", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactBtn({required IconData icon, required Color color, required Color bgColor, required String title}) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E1E1E))),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}