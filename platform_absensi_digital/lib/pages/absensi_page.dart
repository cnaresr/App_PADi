import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class AbsensiPage extends StatefulWidget {
  const AbsensiPage({super.key});

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint("Gagal memuat kamera: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text("Presensi", style: TextStyle(color: Color(0xFF1E1E1E), fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Senin, 24 Mei 2026",
              style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 25),

            // 1. Tampilan Kamera (Face Recognition)
            Container(
              height: 320, // Sedikit dikurangi agar ada ruang untuk kartu lokasi
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F3F1),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
                ],
              ),
              child: FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _controller!.value.previewSize?.height ?? 1,
                            height: _controller!.value.previewSize?.width ?? 1,
                            child: CameraPreview(_controller!),
                          ),
                        ),
                        // Frame Lingkaran Pemindai Wajah
                        Center(
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.6), width: 2.5),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF006D5B)),
                        SizedBox(height: 15),
                        Text("Membuka Kamera...", style: TextStyle(color: Color(0xFF006D5B), fontWeight: FontWeight.bold)),
                      ],
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 25),

            // 2. KARTU STATUS GEOFENCING (BARU)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))
                ],
              ),
              child: Row(
                children: [
                  // Ikon Lokasi Beranimasi/Menyala
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F3F1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.location_on_rounded, color: Color(0xFF006D5B), size: 28),
                  ),
                  const SizedBox(width: 15),
                  // Informasi Lokasi
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text("Dalam Jangkauan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF006D5B))),
                            SizedBox(width: 5),
                            Icon(Icons.verified_rounded, color: Color(0xFF006D5B), size: 16),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text("SMK Negeri 1 Jakarta • Akurasi 5m", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // 3. Info Jaringan (Tetap dipertahankan sebagai opsi)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.wifi_rounded, color: Color(0xFFEBC15B)),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("School_Main_5G", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E1E1E))),
                      Text("Verified Network", style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withOpacity(0.1))),
                  child: const Icon(Icons.autorenew_rounded, color: Color(0xFF1E1E1E)),
                ),
              ],
            ),
            const SizedBox(height: 35),

            // 4. Tombol Utama Ambil Absensi
            SizedBox(
              width: double.infinity,
              height: 65,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF151B2B), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 10,
                  shadowColor: const Color(0xFF151B2B).withOpacity(0.3),
                ),
                onPressed: () {
                  // Aksi pengenalan wajah & absensi geofencing
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Ambil Absensi", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(width: 10),
                    Icon(Icons.face_retouching_natural_rounded, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}