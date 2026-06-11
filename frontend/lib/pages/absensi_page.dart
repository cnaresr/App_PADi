import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart'; // [BARU] Import provider
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

// Asumsi path, sesuaikan jika berbeda
import '../main.dart'; 
import '../services/api_service.dart';
import '../providers/user_provider.dart'; // [BARU] Import UserProvider

// =======================================================================
// [PERUBAHAN] - MEMBUAT HALAMAN ABSENSI MENJADI "LAZY"
// =======================================================================

// 1. Widget AbsensiPage yang asli sekarang menjadi "pembungkus" (wrapper).
//    Tugasnya adalah menunda pembuatan konten kamera sampai halaman ini benar-benar terlihat.
class AbsensiPage extends StatefulWidget {
  final int siswaId;
  const AbsensiPage({super.key, required this.siswaId});

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> with AutomaticKeepAliveClientMixin {
  // [PERBAIKAN] Gunakan Future yang resolve setelah frame pertama untuk lazy loading.
  // Ini adalah pola yang lebih stabil daripada setState di addPostFrameCallback.
  final Future<void> _contentLoader = Future.delayed(Duration.zero);

  @override
  bool get wantKeepAlive => true; // Ini penting untuk menjaga state saat berpindah tab.

  @override
  Widget build(BuildContext context) {
    super.build(context); // Wajib dipanggil saat menggunakan AutomaticKeepAliveClientMixin.

    return FutureBuilder<void>(
      future: _contentLoader,
      builder: (context, snapshot) {
        // Jika future sudah selesai (setelah frame pertama), bangun konten utama.
        if (snapshot.connectionState == ConnectionState.done) {
          return _AbsensiPageContent(siswaId: widget.siswaId);
        }
        // Selama future belum selesai, tampilkan loading indicator.
        return const Scaffold(
          backgroundColor: Color(0xFFFAFAFA),
          body: Center(child: CircularProgressIndicator(color: Color(0xFF006D5B))),
        );
      },
    );
  }
}

// 2. Logika dan UI AbsensiPage yang asli dipindahkan ke dalam widget dan state baru ini.
class _AbsensiPageContent extends StatefulWidget {
  final int siswaId;
  const _AbsensiPageContent({required this.siswaId});

  @override
  State<_AbsensiPageContent> createState() => _AbsensiPageContentState();
}

class _AbsensiPageContentState extends State<_AbsensiPageContent> {
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

  // [DIUBAH] State sekarang menyimpan poligon, bukan titik pusat dan radius.
  late List<Map<String, double>> _schoolPolygon;

  @override
  void initState() {
    super.initState();
    
    // [DIUBAH] Menarik data poligon dari UserProvider.
    final userProvider = context.read<UserProvider>();
    
    // Fallback ke poligon kosong jika data dari provider tidak ada.
    _schoolPolygon = userProvider.schoolPolygon ?? [];
    
    // [DEBUGGING] Tambahkan print ini untuk memastikan data poligon ter-load.
    // Jika outputnya "0 vertices", berarti data tidak masuk dari halaman login.
    debugPrint("AbsensiPage: Memuat poligon sekolah dengan ${_schoolPolygon.length} vertices.");

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
    // 1. Cek dan minta izin lokasi terlebih dahulu
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Handle berbagai status penolakan izin
    if (permission == LocationPermission.denied) {
      if (!mounted) return;
      setState(() => _locationMessage = "Izin lokasi ditolak.");
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      setState(() => _locationMessage = "Izin lokasi ditolak permanen.");
      _showPermissionDeniedDialog();
      return;
    }

    // 2. Dapatkan lokasi awal dengan cepat untuk feedback instan
    try {
      Position initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10), // Batas waktu agar tidak menunggu selamanya
      );
      if (mounted) _updateLocationStatus(initialPosition);
    } catch (e) {
      debugPrint("Error mendapatkan lokasi awal: $e");
      if (mounted) setState(() => _locationMessage = "Gagal mendapat lokasi awal. Pastikan GPS aktif.");
    }

    // 3. Lanjutkan dengan stream untuk update real-time
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10) // Update tiap 10 meter
    ).listen((Position position) {
      if (mounted) _updateLocationStatus(position);
    });
  }

  // Fungsi baru untuk menampilkan dialog notifikasi
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Izin Lokasi Diperlukan"),
        content: const Text("Aplikasi ini membutuhkan izin lokasi untuk fitur absensi. Silakan aktifkan izin lokasi di pengaturan aplikasi."),
        actions: <Widget>[
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text("Buka Pengaturan"),
            onPressed: () {
              // Buka pengaturan aplikasi untuk perangkat ini
              Geolocator.openAppSettings();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  // Fungsi baru untuk memproses update lokasi & UI (menghindari duplikasi)
  void _updateLocationStatus(Position position) {
    // [DIUBAH] Logika pengecekan diubah dari menghitung jarak menjadi pengecekan di dalam poligon.
    final isInside = _isPointInPolygon(position, _schoolPolygon);

    if (!mounted) return;
    setState(() {
      _currentPosition = position;
      if (isInside) {
        _isWithinRadius = true;
        _locationMessage = "Anda berada di dalam area";
      } else {
        _isWithinRadius = false;
        _locationMessage = "Anda berada di luar area";
      }
    });
  }

  // [BARU] Algoritma Ray-Casting untuk mengecek apakah sebuah titik berada di dalam poligon.
  // Ini adalah pengganti Geolocator.distanceBetween.
  // [PERBAIKAN] Logika dibuat lebih eksplisit untuk menghindari kebingungan lat/lon.
  bool _isPointInPolygon(Position point, List<Map<String, double>> polygon) {
    if (polygon.isEmpty) {
      debugPrint("Pengecekan gagal: Poligon area sekolah kosong.");
      return false;
    }

    double pointLon = point.longitude; // Anggap Longitude sebagai sumbu X
    double pointLat = point.latitude;  // Anggap Latitude sebagai sumbu Y
    bool isInside = false;
    
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      double vertexLonI = polygon[i]['longitude']!; // X1
      double vertexLatI = polygon[i]['latitude']!;  // Y1
      double vertexLonJ = polygon[j]['longitude']!; // X2
      double vertexLatJ = polygon[j]['latitude']!;  // Y2

      bool intersect = ((vertexLatI > pointLat) != (vertexLatJ > pointLat)) && (pointLon < (vertexLonJ - vertexLonI) * (pointLat - vertexLatI) / (vertexLatJ - vertexLatI) + vertexLonI);
      if (intersect) {
        isInside = !isInside;
      }
    }
    return isInside;
  }

  // --- TAHAP 2: FACE EMBEDDING ---
  Future<void> _loadModel() async {
    try {
      _interpreter = await tfl.Interpreter.fromAsset('assets/mobilefacenet.tflite');
    } catch (e) {
      debugPrint("Gagal memuat model TFLite: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Gagal memuat model AI: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<List<double>?> _runModelOnImage(File imageFile) async {
    // 1. INISIALISASI PENDETEKSI WAJAH GOOGLE ML KIT
    final options = FaceDetectorOptions(performanceMode: FaceDetectorMode.fast);
    final faceDetector = FaceDetector(options: options);
    final inputImage = InputImage.fromFilePath(imageFile.path);

    // 2. MENCARI LOKASI WAJAH DI DALAM FOTO
    final List<Face> faces = await faceDetector.processImage(inputImage);
    faceDetector.close(); // Tutup detector untuk menghemat memori HP

    // Jika tidak ada wajah manusia di depan kamera, hentikan proses
    if (faces.isEmpty) {
      throw Exception("Wajah tidak ditemukan. Pastikan wajah terlihat jelas di kamera.");
    }

    // Ambil koordinat wajah pertama/terbesar yang terdeteksi
    final Face firstFace = faces.first;
    final Rect boundingBox = firstFace.boundingBox;

    // 3. MUAT GAMBAR ASLI UNTUK DIPOTONG
    img.Image? rawImage = img.decodeImage(await imageFile.readAsBytes());
    if (rawImage == null) return null;
    
    // [TAMBAHKAN INI] Memaksa gambar tegak sesuai rotasi EXIF-nya
    img.Image originalImage = img.bakeOrientation(rawImage);

    // 4. POTONG (CROP) GAMBAR TEPAT DI KOTAK WAJAH
    // Mencegah error jika kotak wajah sedikit keluar dari batas layar
    int x = boundingBox.left.toInt().clamp(0, originalImage.width);
    int y = boundingBox.top.toInt().clamp(0, originalImage.height);
    int w = boundingBox.width.toInt().clamp(0, originalImage.width - x);
    int h = boundingBox.height.toInt().clamp(0, originalImage.height - y);

    // Menggunting gambar agar hanya tersisa bagian wajah (latar belakang dibuang)
    img.Image croppedFace = img.copyCrop(originalImage, x: x, y: y, width: w, height: h);

    // 5. UBAH UKURAN WAJAH YANG SUDAH DIPOTONG MENJADI 112x112
    img.Image resizedImage = img.copyResize(croppedFace, width: 112, height: 112);

    // 6. EKSTRAKSI FITUR MENGGUNAKAN TFLITE (MobileFaceNet)
    var input = List.generate(112, (y) {
      return List.generate(112, (x) {
        final pixel = resizedImage.getPixel(x, y);
        return [(pixel.r - 127.5) / 127.5, (pixel.g - 127.5) / 127.5, (pixel.b - 127.5) / 127.5];
      });
    });

    var reshapedInput = [input];
    var output = List.filled(1 * 192, 0.0).reshape([1, 192]);

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
        userId: widget.siswaId, // Akses siswaId dari state widget baru
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
    // [BARU] Ambil nama sekolah dari provider jika ada untuk ditampilkan di UI
    final String infoKelas = context.read<UserProvider>().kelasAtauNip;
    final List<String> infoParts = infoKelas.split(' • ');
    final String namaSekolah = infoParts.length > 1 ? infoParts[1] : "Area Presensi Sekolah";

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
                        // [UPDATE] Teks Hardcode dihapus, diganti menggunakan nama Sekolah dari provider
                        Text(namaSekolah, style: const TextStyle(color: Colors.grey, fontSize: 12)),
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