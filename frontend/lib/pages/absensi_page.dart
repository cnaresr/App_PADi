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
import '../widgets/custom_popup.dart';

class AbsensiPage extends StatefulWidget {
  final int siswaId;
  const AbsensiPage({super.key, required this.siswaId});

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage>
    with AutomaticKeepAliveClientMixin {
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

class _AbsensiPageContentState extends State<_AbsensiPageContent>
    with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  bool _isWithinRadius = false;
  String _locationMessage = "Mencari lokasi Anda...";
  Position? _currentPosition;
  StreamSubscription<Position>? _locationSubscription;

  late tfl.Interpreter _interpreter;
  bool _isProcessing = false;
  String? _cameraError;

  late List<Map<String, double>> _schoolPolygon;
  bool _hasCheckedIn = false;
  bool _isIzinHariIni = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final userProvider = context.read<UserProvider>();
    _schoolPolygon = userProvider.schoolPolygon ?? [];
    if (!userProvider.isGeofenceActive) {
      _isWithinRadius = true;
      _locationMessage = "Bebas Lokasi (Geofencing Nonaktif)";
    }
    _evaluasiStatusPresensiAwal(userProvider);
    _fetchLatestGeofenceAndData(userProvider);
    debugPrint(
      "AbsensiPage: Memuat poligon sekolah dengan ${_schoolPolygon.length} vertices.",
    );
    _initializeCamera();
    _loadModel();
    _startLocationCheck();
  }

  Future<void> _fetchLatestGeofenceAndData(UserProvider userProvider) async {
    try {
      final dashRes = await ApiService.getDashboardData(widget.siswaId);
      if (dashRes['status'] == 'success' && mounted) {
        userProvider.setDashboardData(
          dashRes['data']['hadirBulanIni'],
          dashRes['data']['persentaseKehadiran'],
          dashRes['data']['riwayatAbsensi'],
          dashRes['data']['riwayatPerizinan'],
          jadwal: dashRes['data']['jadwalAktif'] ?? [],
          geofence: dashRes['data']['geofence'],
        );
        setState(() {
          _schoolPolygon = userProvider.schoolPolygon ?? [];
          if (!userProvider.isGeofenceActive) {
            _isWithinRadius = true;
            _locationMessage = "Bebas Lokasi (Geofencing Nonaktif)";
          } else {
            if (_currentPosition != null) {
              _updateLocationStatus(_currentPosition!);
            } else {
              _isWithinRadius = false;
              _locationMessage = "Mencari lokasi Anda...";
            }
          }
        });
        // Panggil evaluasi agar state _hasCheckedIn diperbarui setelah data di-fetch ulang dari server
        _evaluasiStatusPresensiAwal(userProvider);
      }
    } catch (e) {
      debugPrint("Gagal memperbarui geofence terbaru di AbsensiPage: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      debugPrint("App resumed. Re-checking location permissions and status.");
      _locationSubscription?.cancel();
      _startLocationCheck();
    }
  }

  void _evaluasiStatusPresensiAwal(UserProvider userProvider) {
    final riwayat = userProvider.riwayatAbsensi;
    final perizinan = userProvider.riwayatPerizinan;

    final String formatHariIni = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now());

    bool sudahMasuk = false;
    bool izinSakitHariIni = false;

    if (riwayat.isNotEmpty) {
      sudahMasuk = riwayat.any(
        (absen) =>
            absen['tanggal'] == formatHariIni &&
            absen['jam_masuk'] != null &&
            absen['jam_pulang'] == null &&
            absen['status'] != 'Izin' &&
            absen['status'] != 'Sakit',
      );

      izinSakitHariIni = riwayat.any(
        (absen) =>
            absen['tanggal'] == formatHariIni &&
            (absen['status'] == 'Izin' || absen['status'] == 'Sakit'),
      );
    }

    bool izinDiSetujuiHariIni = perizinan.any((izin) {
      if (izin['status'] != 'Disetujui') return false;
      try {
        DateTime mulai = DateTime.parse(izin['tanggalMulai']).toLocal();
        DateTime selesai = DateTime.parse(izin['tanggalSelesai']).toLocal();
        DateTime hariIni = DateTime.now();
        DateTime mulaiDate = DateTime(mulai.year, mulai.month, mulai.day);
        DateTime selesaiDate = DateTime(
          selesai.year,
          selesai.month,
          selesai.day,
        );
        DateTime hariIniDate = DateTime(
          hariIni.year,
          hariIni.month,
          hariIni.day,
        );
        return !hariIniDate.isBefore(mulaiDate) &&
            !hariIniDate.isAfter(selesaiDate);
      } catch (e) {
        return false;
      }
    });

    setState(() {
      _hasCheckedIn = sudahMasuk;
      _isIzinHariIni = izinSakitHariIni || izinDiSetujuiHariIni;
    });
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
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) setState(() => _cameraError = e.toString());
      debugPrint("Gagal memuat kamera: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _interpreter.close();
    WidgetsBinding.instance.removeObserver(this);
    _locationSubscription?.cancel();
    super.dispose();
  }

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
      if (mounted) {
        setState(
          () => _locationMessage =
              "Gagal mendapat lokasi awal. Pastikan GPS aktif.",
        );
      }
    }
    _locationSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position position) {
          if (mounted) _updateLocationStatus(position);
        });
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          "Izin Lokasi Diperlukan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Aplikasi ini membutuhkan izin lokasi untuk fitur absensi. Silakan aktifkan izin lokasi di pengaturan aplikasi.",
        ),
        actions: <Widget>[
          TextButton(
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006D5B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Buka Pengaturan",
              style: TextStyle(color: Colors.white),
            ),
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
    final userProvider = context.read<UserProvider>();
    final polygon = userProvider.schoolPolygon ?? [];
    final isGeofenceActive = userProvider.isGeofenceActive;

    final isInside = isGeofenceActive
        ? _isPointInPolygon(position, polygon)
        : true;

    if (!mounted) return;
    setState(() {
      _currentPosition = position;
      if (isInside) {
        _isWithinRadius = true;
        _locationMessage = isGeofenceActive
            ? "Anda berada di dalam area"
            : "Bebas Lokasi (Geofencing Nonaktif)";
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
      bool intersect =
          ((vertexLatI > pointLat) != (vertexLatJ > pointLat)) &&
          (pointLon <
              (vertexLonJ - vertexLonI) *
                      (pointLat - vertexLatI) /
                      (vertexLatJ - vertexLatI) +
                  vertexLonI);
      if (intersect) isInside = !isInside;
    }
    return isInside;
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await tfl.Interpreter.fromAsset(
        'assets/mobilefacenet.tflite',
      );
    } catch (e) {
      debugPrint("Gagal memuat model TFLite: $e");
      CustomPopup.show(
        context,
        message: "Gagal memuat model AI: $e",
        type: PopupType.error,
      );
    }
  }

  Future<List<List<double>>?> _runModelOnImage(File imageFile) async {
    final options = FaceDetectorOptions(performanceMode: FaceDetectorMode.fast);
    final faceDetector = FaceDetector(options: options);
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final List<Face> faces = await faceDetector.processImage(inputImage);
    faceDetector.close();
    if (faces.isEmpty) {
      throw Exception(
        "Wajah tidak ditemukan. Pastikan wajah terlihat jelas di kamera.",
      );
    }
    final Face firstFace = faces.first;
    final Rect boundingBox = firstFace.boundingBox;
    img.Image? rawImage = img.decodeImage(await imageFile.readAsBytes());
    if (rawImage == null) return null;
    img.Image originalImage = img.bakeOrientation(rawImage);

    // [PERBAIKAN FATAL ORIENTASI ML KIT VS PACKAGE:IMAGE]
    // Kamera HP menyimpan foto selfie secara rotasi Landscape (width > height) di tingkat sensor.
    // Google ML Kit otomatis merotasi ke Portrait (height > width) saat mendeteksi boundingBox.
    // Jika originalImage dari package:image masih berstatus width > height, kita rotasi terlebih dahulu ke portrait 
    // agar dimensi dan koordinat bounding box dari ML Kit cocok dengan pixel image saat di-crop.
    if (originalImage.width > originalImage.height) {
      final int sensorOrientation = _controller?.description.sensorOrientation ?? 90;
      originalImage = img.copyRotate(originalImage, angle: sensorOrientation);
    }

    // [VALIDASI BARU] Cegah wajah terlalu jauh (Resolution Collapse)
    final double faceWidthRatio = boundingBox.width / originalImage.width;
    if (faceWidthRatio < 0.25) {
      throw Exception(
        "Jarak wajah terlalu jauh. Silakan dekatkan wajah Anda ke kamera agar terlihat jelas.",
      );
    }

    int origX = boundingBox.left.toInt();
    int origY = boundingBox.top.toInt();
    int origW = boundingBox.width.toInt();
    int origH = boundingBox.height.toInt();

    // Terapkan Square Crop agar wajah tidak gepeng/terdistorsi saat di-resize ke 112x112
    int maxDimension = origW > origH ? origW : origH;
    int centerX = origX + (origW ~/ 2);
    int centerY = origY + (origH ~/ 2);

    int x = (centerX - (maxDimension ~/ 2)).clamp(0, originalImage.width);
    int y = (centerY - (maxDimension ~/ 2)).clamp(0, originalImage.height);
    int w = maxDimension.clamp(0, originalImage.width - x);
    int h = maxDimension.clamp(0, originalImage.height - y);
    // Jika di batas gambar tepi w dan h bisa sedikit berbeda, ambil nilai minimum agar tetap bujur sangkar sempurna
    int finalDimension = w < h ? w : h;

    img.Image croppedFace = img.copyCrop(
      originalImage,
      x: x,
      y: y,
      width: finalDimension,
      height: finalDimension,
    );

    // Buat versi normal dan versi flipped secara horizontal
    img.Image croppedFaceNormal = croppedFace;
    img.Image croppedFaceFlipped = img.copyFlip(
      croppedFace,
      direction: img.FlipDirection.horizontal,
    );

    // Helper untuk memproses sebuah gambar wajah dan menjalankan model MobileFaceNet
    List<double> getEmbedding(img.Image faceImage) {
      img.Image resizedImage = img.copyResize(
        faceImage,
        width: 112,
        height: 112,
      );
      var input = List.generate(112, (y) {
        return List.generate(112, (x) {
          final pixel = resizedImage.getPixel(x, y);
          return [
            (pixel.r - 127.5) / 127.5,
            (pixel.g - 127.5) / 127.5,
            (pixel.b - 127.5) / 127.5,
          ];
        });
      });
      var reshapedInput = [input];
      var output = List.filled(1 * 192, 0.0).reshape([1, 192]);
      _interpreter.run(reshapedInput, output);
      return List<double>.from(output[0]);
    }

    final embeddingNormal = getEmbedding(croppedFaceNormal);
    final embeddingFlipped = getEmbedding(croppedFaceFlipped);

    return [embeddingNormal, embeddingFlipped];
  }

  Future<void> _onAbsenMasukButtonPressed() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isProcessing ||
        _currentPosition == null)
      return;
    setState(() => _isProcessing = true);
    try {
      final XFile imageFile = await _controller!.takePicture();
      final faceEmbedding = await _runModelOnImage(File(imageFile.path));
      if (faceEmbedding == null) {
        throw Exception("Wajah tidak terdeteksi pada gambar.");
      }

      // [PERBAIKAN] Kompresi gambar secara background agar tidak terjadi timeout di Ngrok (berkurang dari 15MB ke ~200KB)
      final rawBytes = await File(imageFile.path).readAsBytes();
      final decodedImage = img.decodeImage(rawBytes);
      if (decodedImage != null) {
        img.Image resized = decodedImage;
        // Resize jika resolusi terlalu besar (lebih dari 1080p)
        if (decodedImage.width > 1080 || decodedImage.height > 1080) {
          final bool isLandscape = decodedImage.width > decodedImage.height;
          resized = img.copyResize(
            decodedImage,
            width: isLandscape ? 1080 : null,
            height: isLandscape ? null : 1080,
          );
        }
        final compressedJpg = img.encodeJpg(resized, quality: 60);
        await File(imageFile.path).writeAsBytes(compressedJpg);
      }

      final result = await ApiService.kirimAbsensiMasuk(
        userId: widget.siswaId,
        faceEmbedding: faceEmbedding,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        fotoMasukPath: imageFile.path,
      );
      if (!mounted) return;
      CustomPopup.show(
        context,
        message: result['message'] ?? 'Terjadi kesalahan.',
        type: (result['success'] ?? false)
            ? PopupType.success
            : PopupType.error,
      );
      if (result['success'] == true) {
        setState(() => _hasCheckedIn = true);
        final user = context.read<UserProvider>();
        final dashRes = await ApiService.getDashboardData(user.userId);
        if (dashRes['status'] == 'success') {
          user.setDashboardData(
            dashRes['data']['hadirBulanIni'],
            dashRes['data']['persentaseKehadiran'],
            dashRes['data']['riwayatAbsensi'],
            dashRes['data']['riwayatPerizinan'],
            jadwal: dashRes['data']['jadwalAktif'] ?? [],
            geofence: dashRes['data']['geofence'],
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      CustomPopup.show(
        context,
        message: "Error: ${e.toString()}",
        type: PopupType.error,
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _onAbsenPulangButtonPressed() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isProcessing ||
        _currentPosition == null)
      return;
    setState(() => _isProcessing = true);
    try {
      final XFile imageFile = await _controller!.takePicture();
      final faceEmbedding = await _runModelOnImage(File(imageFile.path));
      if (faceEmbedding == null) {
        throw Exception("Wajah tidak terdeteksi pada gambar.");
      }

      // [PERBAIKAN] Kompresi gambar secara background agar tidak terjadi timeout di Ngrok (berkurang dari 15MB ke ~200KB)
      final rawBytes = await File(imageFile.path).readAsBytes();
      final decodedImage = img.decodeImage(rawBytes);
      if (decodedImage != null) {
        img.Image resized = decodedImage;
        // Resize jika resolusi terlalu besar (lebih dari 1080p)
        if (decodedImage.width > 1080 || decodedImage.height > 1080) {
          final bool isLandscape = decodedImage.width > decodedImage.height;
          resized = img.copyResize(
            decodedImage,
            width: isLandscape ? 1080 : null,
            height: isLandscape ? null : 1080,
          );
        }
        final compressedJpg = img.encodeJpg(resized, quality: 60);
        await File(imageFile.path).writeAsBytes(compressedJpg);
      }

      final result = await ApiService.kirimAbsensiPulang(
        userId: widget.siswaId,
        faceEmbedding: faceEmbedding,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        fotoPulangPath: imageFile.path,
      );
      if (!mounted) return;
      CustomPopup.show(
        context,
        message: result['message'] ?? 'Terjadi kesalahan.',
        type: (result['success'] ?? false)
            ? PopupType.success
            : PopupType.error,
      );
      if (result['success'] == true) {
        setState(() => _hasCheckedIn = false);
        final user = context.read<UserProvider>();
        final dashRes = await ApiService.getDashboardData(user.userId);
        if (dashRes['status'] == 'success') {
          user.setDashboardData(
            dashRes['data']['hadirBulanIni'],
            dashRes['data']['persentaseKehadiran'],
            dashRes['data']['riwayatAbsensi'],
            dashRes['data']['riwayatPerizinan'],
            jadwal: dashRes['data']['jadwalAktif'] ?? [],
            geofence: dashRes['data']['geofence'],
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      CustomPopup.show(
        context,
        message: "Error: ${e.toString()}",
        type: PopupType.error,
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final String infoKelas = userProvider.kelasAtauNip;
    final List<String> infoParts = infoKelas.split(' • ');
    final String namaSekolah = infoParts.length > 1
        ? infoParts[1]
        : "Area Presensi Sekolah";

    // Validasi 10 menit sebelum jam pulang
    bool isWaktuPulang = true;
    String? jamPulangStr;
    if (_hasCheckedIn && userProvider.jadwalAktif.isNotEmpty) {
      final jadwal = userProvider.jadwalAktif.first;
      if (jadwal['jamPulang'] != null) {
        try {
          DateTime jamDb = DateTime.parse(jadwal['jamPulang']).toUtc();
          int batasMenitPulang = (jamDb.hour * 60) + jamDb.minute;
          DateTime now = DateTime.now();
          int menitSekarang = (now.hour * 60) + now.minute;
          if (menitSekarang < (batasMenitPulang - 10)) {
            isWaktuPulang = false;
            jamPulangStr = "${jamDb.hour.toString().padLeft(2, '0')}:${jamDb.minute.toString().padLeft(2, '0')}";
          }
        } catch (e) {
          debugPrint("Gagal parse jamPulang: $e");
        }
      }
    }

    // UI Colors and states
    final bool isButtonDisabled = (!_isWithinRadius && !_hasCheckedIn) || _isIzinHariIni || (_hasCheckedIn && !isWaktuPulang);
    final Color btnColor = isButtonDisabled
        ? Colors.grey.shade400
        : (_hasCheckedIn ? const Color(0xFF1C2B2A) : const Color(0xFF006D5B));
    final Color btnTextColor = isButtonDisabled
        ? const Color(0xFFA0AEC0)
        : Colors.white;

    String btnLabel;
    if (_isIzinHariIni) {
      btnLabel = "Sedang Izin/Sakit";
    } else if (_hasCheckedIn) {
      if (!isWaktuPulang && jamPulangStr != null) {
        btnLabel = "Pulang Pukul $jamPulangStr";
      } else {
        btnLabel = "Presensi Pulang";
      }
    } else {
      btnLabel = "Presensi Masuk";
    }

    final IconData btnIcon = _isIzinHariIni
        ? Icons.check_circle_outline
        : (_hasCheckedIn ? Icons.logout_rounded : Icons.login_rounded);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // ===== HEADER =====
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF006D5B), Color(0xFF004D40)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.fingerprint_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Presensi",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  Text(
                                    "Verifikasi kehadiran Anda",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Status indicator
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: _isWithinRadius
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.red.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _isWithinRadius
                                    ? Colors.white.withOpacity(0.4)
                                    : Colors.red.withOpacity(0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: _isWithinRadius
                                        ? Colors.greenAccent
                                        : Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isWithinRadius ? "Dalam Area" : "Luar Area",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        DateFormat(
                          'EEEE, dd MMMM yyyy',
                          'id_ID',
                        ).format(DateTime.now()),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ===== BODY CONTENT =====
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (_isIzinHariIni)
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE65100).withOpacity(0.1),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFFFFCC80),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF3E0),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.beach_access_rounded,
                            size: 64,
                            color: Color(0xFFE65100),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Anda Sedang Izin",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE65100),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Pengajuan izin Anda telah disetujui. Silakan beristirahat dan tidak perlu melakukan presensi absensi hari ini.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  // KAMERA
                  Container(
                    height: 320,
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C2B2A),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF006D5B).withOpacity(0.2),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: FutureBuilder<void>(
                      future: _initializeControllerFuture,
                      builder: (context, snapshot) {
                        if (_cameraError != null) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt_rounded,
                                    size: 48,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Gagal memuat kamera:\n$_cameraError',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
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
                                  width:
                                      _controller!.value.previewSize?.height ??
                                      1,
                                  height:
                                      _controller!.value.previewSize?.width ??
                                      1,
                                  child: CameraPreview(_controller!),
                                ),
                              ),
                              // Face guide overlay
                              Center(
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _isWithinRadius
                                          ? const Color(0xFF00E676)
                                          : Colors.white.withOpacity(0.5),
                                      width: 3,
                                    ),
                                  ),
                                ),
                              ),
                              // Corner guides
                              _buildCornerGuide(Alignment.topLeft, 20, 20),
                              _buildCornerGuide(Alignment.topRight, 20, 20),
                              _buildCornerGuide(Alignment.bottomLeft, 20, 20),
                              _buildCornerGuide(Alignment.bottomRight, 20, 20),
                            ],
                          );
                        } else {
                          return const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Color(0xFF006D5B),
                              ),
                              SizedBox(height: 15),
                              Text(
                                "Membuka Kamera...",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // STATUS LOKASI
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: _isWithinRadius
                            ? const Color(0xFF006D5B).withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (_isWithinRadius
                                      ? const Color(0xFF006D5B)
                                      : Colors.red)
                                  .withOpacity(0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _isWithinRadius
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: _isWithinRadius
                                ? const Color(0xFF006D5B)
                                : Colors.redAccent,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _locationMessage,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: _isWithinRadius
                                            ? const Color(0xFF006D5B)
                                            : Colors.redAccent,
                                      ),
                                    ),
                                  ),
                                  if (_isWithinRadius) ...[
                                    const SizedBox(width: 5),
                                    const Icon(
                                      Icons.verified_rounded,
                                      color: Color(0xFF006D5B),
                                      size: 15,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                namaSekolah,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // TOMBOL ABSEN
                  SizedBox(
                    width: double.infinity,
                    height: 68,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: btnColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: _isWithinRadius ? 6 : 0,
                        shadowColor: const Color(0xFF006D5B).withOpacity(0.3),
                      ),
                      onPressed:
                          (_isWithinRadius && !_isProcessing && !_isIzinHariIni)
                          ? (_hasCheckedIn
                                ? _onAbsenPulangButtonPressed
                                : _onAbsenMasukButtonPressed)
                          : null,
                      child: _isProcessing
                          ? const SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(btnIcon, color: btnTextColor, size: 22),
                                const SizedBox(width: 10),
                                Text(
                                  btnLabel,
                                  style: TextStyle(
                                    color: btnTextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  if (!_isWithinRadius)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 13,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Tombol aktif saat Anda berada di area sekolah",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerGuide(Alignment alignment, double width, double height) {
    final isTop =
        alignment == Alignment.topLeft || alignment == Alignment.topRight;
    final isLeft =
        alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;
    return Align(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isLeft ? 20 : 0,
          isTop ? 20 : 0,
          isLeft ? 0 : 20,
          isTop ? 0 : 20,
        ),
        child: CustomPaint(
          size: Size(width, height),
          painter: _CornerPainter(isTop: isTop, isLeft: isLeft),
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;

  _CornerPainter({required this.isTop, required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (isTop && isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
