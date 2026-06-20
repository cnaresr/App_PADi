import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../main.dart'; 
import '../services/api_service.dart';
import '../providers/user_provider.dart';

class AbsensiPage extends StatefulWidget {
  final int siswaId;
  const AbsensiPage({super.key, required this.siswaId});

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _AbsensiPageContent(siswaId: widget.siswaId);
  }
}

class _AbsensiPageContent extends StatefulWidget {
  final int siswaId;
  const _AbsensiPageContent({required this.siswaId});

  @override
  State<_AbsensiPageContent> createState() => _AbsensiPageContentState();
}

class _AbsensiPageContentState extends State<_AbsensiPageContent> with WidgetsBindingObserver {
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

  late List<Map<String, double>> _schoolPolygon;

  // [BARU] State kontrol untuk mengubah wujud tombol secara dinamis
  bool _hasCheckedIn = false;

  @override
  void initState() {
    super.initState();

    // [BARU] Daftarkan observer untuk mendeteksi siklus hidup aplikasi (misal: kembali dari background)
    WidgetsBinding.instance.addObserver(this);
    
    final userProvider = context.read<UserProvider>();
    _schoolPolygon = userProvider.schoolPolygon ?? [];
    
    // Evaluasi status presensi awal berdasarkan data dashboard yang ada di provider
    _evaluasiStatusPresensiAwal(userProvider);

    debugPrint("AbsensiPage: Memuat poligon sekolah dengan ${_schoolPolygon.length} vertices.");

    _initializeCamera();
    _loadModel();
    _startLocationCheck();
  }

  // [BARU] Fungsi ini akan dipanggil setiap kali state aplikasi berubah
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Jika pengguna kembali ke aplikasi (misal: setelah dari Settings)
    if (state == AppLifecycleState.resumed) {
      debugPrint("App resumed. Re-checking location permissions and status.");
      // Hentikan stream lama jika ada untuk menghindari duplikasi
      _locationSubscription?.cancel();
      // Mulai ulang pengecekan lokasi untuk memastikan izin terbaru terbaca
      _startLocationCheck();
    }
  }

  // [BARU] Fungsi mengecek apakah hari ini sudah pernah klik absen masuk (berdasarkan data provider)
  void _evaluasiStatusPresensiAwal(UserProvider userProvider) {
    final riwayat = userProvider.riwayatAbsensi; // Asumsi format data berupa List
    if (riwayat.isNotEmpty) {
      final String formatHariIni = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      // Jika ada riwayat hari ini yang sudah punya jam masuk tapi belum ada jam pulang
      final bool sudahMasuk = riwayat.any((absen) => 
        absen['tanggal'] == formatHariIni && 
        absen['jam_masuk'] != null && 
        absen['jam_pulang'] == null
      );

      setState(() {
        _hasCheckedIn = sudahMasuk;
      });
    }
  }

  Future<void> _initializeCamera() async {
    try {
      if (cameras.isEmpty) {
        throw Exception('Tidak ada kamera yang ditemukan di perangkat ini.');
      }

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
    WidgetsBinding.instance.removeObserver(this); // [BARU] Hapus observer
    _locationSubscription?.cancel();
    super.dispose();
  }

  // --- TAHAP 1: GEOLOCATION & GEOFENCING ---
  Future<void> _startLocationCheck() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

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

    try {
      Position initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      if (mounted) _updateLocationStatus(initialPosition);
    } catch (e) {
      debugPrint("Error mendapatkan lokasi awal: $e");
      if (mounted) setState(() => _locationMessage = "Gagal mendapat lokasi awal. Pastikan GPS aktif.");
    }

    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10)
    ).listen((Position position) {
      if (mounted) _updateLocationStatus(position);
    });
  }

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
              Geolocator.openAppSettings();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _updateLocationStatus(Position position) {
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

  bool _isPointInPolygon(Position point, List<Map<String, double>> polygon) {
    if (polygon.isEmpty) {
      debugPrint("Pengecekan gagal: Poligon area sekolah kosong.");
      return false;
    }

    double pointLon = point.longitude; 
    double pointLat = point.latitude;  
    bool isInside = false;
    
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      double vertexLonI = polygon[i]['longitude']!; 
      double vertexLatI = polygon[i]['latitude']!;  
      double vertexLonJ = polygon[j]['longitude']!; 
      double vertexLatJ = polygon[j]['latitude']!;  

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
    final options = FaceDetectorOptions(performanceMode: FaceDetectorMode.fast);
    final faceDetector = FaceDetector(options: options);
    final inputImage = InputImage.fromFilePath(imageFile.path);

    final List<Face> faces = await faceDetector.processImage(inputImage);
    faceDetector.close();

    if (faces.isEmpty) {
      throw Exception("Wajah tidak ditemukan. Pastikan wajah terlihat jelas di kamera.");
    }

    final Face firstFace = faces.first;
    final Rect boundingBox = firstFace.boundingBox;

    img.Image? rawImage = img.decodeImage(await imageFile.readAsBytes());
    if (rawImage == null) return null;
    
    img.Image originalImage = img.bakeOrientation(rawImage);

    int x = boundingBox.left.toInt().clamp(0, originalImage.width);
    int y = boundingBox.top.toInt().clamp(0, originalImage.height);
    int w = boundingBox.width.toInt().clamp(0, originalImage.width - x);
    int h = boundingBox.height.toInt().clamp(0, originalImage.height - y);

    img.Image croppedFace = img.copyCrop(originalImage, x: x, y: y, width: w, height: h);
    img.Image resizedImage = img.copyResize(croppedFace, width: 112, height: 112);

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
  Future<void> _onAbsenMasukButtonPressed() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing || _currentPosition == null) return;

    setState(() => _isProcessing = true);

    try {
      final XFile imageFile = await _controller!.takePicture();
      final faceEmbedding = await _runModelOnImage(File(imageFile.path));

      if (faceEmbedding == null) {
        throw Exception("Wajah tidak terdeteksi pada gambar.");
      }

      final result = await ApiService.kirimAbsensiMasuk(
        userId: widget.siswaId,
        faceEmbedding: faceEmbedding,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        fotoMasukPath: imageFile.path,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? 'Terjadi kesalahan.'),
        backgroundColor: (result['success'] ?? false) ? Colors.green : Colors.red,
      ));

      if (result['success'] == true) {
        // Berubah wujud ke status sudah absen masuk
        setState(() {
          _hasCheckedIn = true;
        });

        // Refresh data dashboard secara background
        final user = context.read<UserProvider>();
        final dashRes = await ApiService.getDashboardData(user.userId);
        if (dashRes['status'] == 'success') {
          user.setDashboardData(
            dashRes['data']['hadirBulanIni'],
            dashRes['data']['persentaseKehadiran'],
            dashRes['data']['riwayatAbsensi'],
            dashRes['data']['riwayatPerizinan'],
          );
        }
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

  Future<void> _onAbsenPulangButtonPressed() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing || _currentPosition == null) return;

    setState(() => _isProcessing = true);

    try {
      final XFile imageFile = await _controller!.takePicture();
      final faceEmbedding = await _runModelOnImage(File(imageFile.path));

      if (faceEmbedding == null) {
        throw Exception("Wajah tidak terdeteksi pada gambar.");
      }

      final result = await ApiService.kirimAbsensiPulang(
        userId: widget.siswaId,
        faceEmbedding: faceEmbedding,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        fotoPulangPath: imageFile.path,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? 'Terjadi kesalahan.'),
        backgroundColor: (result['success'] ?? false) ? Colors.green : Colors.red,
      ));

      if (result['success'] == true) {
        // Reset status kembali ke awal setelah berhasil absen pulang
        setState(() {
          _hasCheckedIn = false;
        });

        final user = context.read<UserProvider>();
        final dashRes = await ApiService.getDashboardData(user.userId);
        if (dashRes['status'] == 'success') {
          user.setDashboardData(
            dashRes['data']['hadirBulanIni'],
            dashRes['data']['persentaseKehadiran'],
            dashRes['data']['riwayatAbsensi'],
            dashRes['data']['riwayatPerizinan'],
          );
        }
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
              height: 320, 
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

            // 2. KARTU STATUS GEOFENCING (Dinamis Berdasarkan Lokasi & Sekolah)
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
                        Text(namaSekolah, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // [UX IMPROVEMENT] Jarak disesuaikan setelah penghapusan Card Wi-Fi
            const SizedBox(height: 40),

            // 3. TOMBOL UTAMA ABSENSI PINTAR (Smart Single Button)
            SizedBox(
              width: double.infinity,
              height: 65,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // Jika di luar area, tombol berwarna abu-abu (disabled look). 
                  // Jika di dalam area, warna disesuaikan: Hijau untuk Masuk, Biru Gelap untuk Pulang.
                  backgroundColor: _isWithinRadius 
                      ? (_hasCheckedIn ? const Color(0xFF151B2B) : const Color(0xFF006D5B))
                      : Colors.grey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: _isWithinRadius ? 5 : 0,
                  shadowColor: (_hasCheckedIn ? const Color(0xFF151B2B) : const Color(0xFF006D5B)).withOpacity(0.3),
                ),
                // Tombol terkunci otomatis jika berada di luar jangkauan wilayah sekolah
                onPressed: (_isWithinRadius && !_isProcessing) 
                    ? (_hasCheckedIn ? _onAbsenPulangButtonPressed : _onAbsenMasukButtonPressed)
                    : null,
                child: _isProcessing 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _hasCheckedIn ? Icons.logout_rounded : Icons.login_rounded, 
                            color: Colors.white,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _hasCheckedIn ? "Absen Pulang" : "Absen Masuk", 
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
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