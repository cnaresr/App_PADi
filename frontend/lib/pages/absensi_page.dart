import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:image/image.dart' as img;

// Asumsi path, sesuaikan jika berbeda
import '../main.dart'; 
import '../services/api_service.dart';

class AbsensiPage extends StatefulWidget {
  final int siswaId; // ID siswa yang sedang login
  const AbsensiPage({super.key, required this.siswaId});

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  // State untuk Geofencing & Logika
  bool _isWithinRadius = false;
  String _locationMessage = "Mencari lokasi Anda...";
  Position? _currentPosition;
  StreamSubscription<Position>? _locationSubscription;

  // State untuk Kamera & AI
  late tfl.Interpreter _interpreter;
  bool _isProcessing = false;
  String? _cameraError;

  // Data Sekolah (Contoh, idealnya didapat dari API)
  final double _schoolLat = -6.9834; // Contoh: Latitude sekolah
  final double _schoolLon = 110.4095; // Contoh: Longitude sekolah
  final double _schoolRadius = 100; // Contoh: Radius dalam meter

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
    _startLocationCheck();
  }

  Future<void> _initializeCamera() async {
    try {
      if (cameras.isEmpty) {
        throw Exception('Tidak ada kamera yang ditemukan di perangkat ini.');
      }

      // Menggunakan variabel global 'cameras' dari main.dart
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
      if (mounted) {
        setState(() => _cameraError = e.toString());
      }
      debugPrint("Gagal memuat kamera: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _interpreter.close();
    _locationSubscription?.cancel();
    super.dispose();
  }

  // --- TAHAP 1: GEOLOCATION & GEOFENCING ---
  Future<void> _startLocationCheck() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        setState(() => _locationMessage = "Izin lokasi ditolak.");
        return;
      }
    }

    _locationSubscription = Geolocator.getPositionStream().listen((Position position) {
      if (!mounted) return;
      final distance = Geolocator.distanceBetween(
          position.latitude, position.longitude, _schoolLat, _schoolLon);

      setState(() {
        _currentPosition = position;
        if (distance <= _schoolRadius) {
          _isWithinRadius = true;
          _locationMessage = "Dalam Jangkauan (${distance.toStringAsFixed(0)}m)";
        } else {
          _isWithinRadius = false;
          _locationMessage = "Di Luar Jangkauan (${distance.toStringAsFixed(0)}m)";
        }
      });
    });
  }

  // --- TAHAP 2: FACE EMBEDDING ---
  Future<void> _loadModel() async {
    try {
      _interpreter = await tfl.Interpreter.fromAsset('mobilefacenet.tflite');
    } catch (e) {
      debugPrint("Gagal memuat model TFLite: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Gagal memuat model AI: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<List<double>?> _runModelOnImage(File imageFile) async {
    img.Image? originalImage = img.decodeImage(await imageFile.readAsBytes());
    if (originalImage == null) return null;

    // Model MobileFaceNet biasanya butuh input 112x112
    img.Image resizedImage = img.copyResize(originalImage, width: 112, height: 112);

    // Konversi ke List<List<List<double>>> dan normalisasi pixel
    // Cara yang lebih aman dan bersih untuk memproses gambar
    var input = List.generate(112, (y) {
      return List.generate(112, (x) {
        final pixel = resizedImage.getPixel(x, y);
        return [(pixel.r - 127.5) / 127.5, (pixel.g - 127.5) / 127.5, (pixel.b - 127.5) / 127.5];
      });
    });

    // Ubah shape input menjadi [1, 112, 112, 3]
    var reshapedInput = [input];

    // Output model biasanya [1, 128] atau [1, 512]
    var output = List.filled(1 * 128, 0.0).reshape([1, 128]);

    _interpreter.run(reshapedInput, output);
    return List<double>.from(output[0]);
  }

  // --- TAHAP 3: VALIDASI & PENYIMPANAN ---
  Future<void> _onAbsenButtonPressed() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing || _currentPosition == null) return;

    setState(() => _isProcessing = true);

    try {
      final XFile imageFile = await _controller!.takePicture();
      final faceEmbedding = await _runModelOnImage(File(imageFile.path));

      if (faceEmbedding == null) {
        throw Exception("Wajah tidak terdeteksi pada gambar.");
      }

      // Menggunakan ApiService yang sudah ada
      final result = await ApiService.kirimAbsensiMasuk(
        siswaId: widget.siswaId,
        faceEmbedding: faceEmbedding,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? 'Terjadi kesalahan.'),
        backgroundColor: (result['success'] ?? false) ? Colors.green : Colors.red,
      ));

      if (result['success'] == true) {
        // Optional: Kembali ke halaman sebelumnya atau refresh
        Navigator.of(context).pop();
      }

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: ${e.toString()}"),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
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
            Text(
              DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.now()),
              style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
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
                  // Jika ada error saat inisialisasi kamera
                  if (_cameraError != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Gagal memuat kamera:\n$_cameraError',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }
                  // Jika kamera berhasil diinisialisasi
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
                    // Tampilan saat kamera sedang loading
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
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isWithinRadius ? const Color(0xFFE8F3F1) : const Color(0xFFFFF0F0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.location_on_rounded, color: _isWithinRadius ? const Color(0xFF006D5B) : Colors.red, size: 28),
                  ),

                  const SizedBox(width: 15),
                  // Informasi Lokasi
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(_locationMessage, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _isWithinRadius ? const Color(0xFF006D5B) : Colors.red)),
                            if (_isWithinRadius) ...[
                              const SizedBox(width: 5),
                              const Icon(Icons.verified_rounded, color: Color(0xFF006D5B), size: 16),
                            ]
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text("SMK Negeri 1 Jakarta • Akurasi 5m", style: TextStyle(color: Colors.grey, fontSize: 12)),
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
                  backgroundColor: _isWithinRadius ? const Color(0xFF151B2B) : Colors.grey, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 10,
                  shadowColor: const Color(0xFF151B2B).withOpacity(0.3),
                ),
                onPressed: (_isWithinRadius && !_isProcessing) ? _onAbsenButtonPressed : null,
                child: _isProcessing 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Ambil Absensi", 
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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