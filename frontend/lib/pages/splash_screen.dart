import 'package:flutter/material.dart';
import 'package:platform_absensi_digital/pages/login_page.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:platform_absensi_digital/pages/main_page.dart';
import 'package:platform_absensi_digital/pages/main_guru_page.dart';
import 'package:platform_absensi_digital/services/storage_service.dart';
import 'package:platform_absensi_digital/providers/user_provider.dart';
import 'package:platform_absensi_digital/services/firebase_messaging_service.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  late Animation<double> _logoScale;
  late Animation<double> _bgScale;
  late Animation<double> _logoOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800), 
    );

    _logoScale = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.1).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 30, 
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 0.9).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 15, 
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 15.0).chain(CurveTween(curve: Curves.easeInExpo)),
        weight: 55, 
      ),
    ]).animate(_controller);

    _bgScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 1.0, curve: Curves.easeInOutQuart),
    );

    _logoOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
    );

    _runAnimation();
  }

  void _runAnimation() async {
    // 1. Tahan logo agar diam dulu selama 1 detik
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // 2. Jalankan animasi Pop & Zoom
    await _controller.forward();
    
    // 3. Tahan layar gelap sebentar (0.2 detik) sebelum pindah
    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;
    final target = await _resolveInitialRoute();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, a, b) => target,
          transitionsBuilder: (context, a, b, child) => FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  Future<Widget> _resolveInitialRoute() async {
    final storage = StorageService();
    final token = await storage.getToken();
    final userId = await storage.getUserId();
    final role = await storage.getUserRole();
    final name = await storage.getUserName();
    final detail = await storage.getUserDetail();
    final email = await storage.getUserEmail();

    if (token != null && token.isNotEmpty) {
      final bool isTokenExpired = JwtDecoder.isExpired(token);
      if (isTokenExpired) {
        await storage.clearSession();
        return const LoginPage();
      }

      if (userId != null && userId > 0) {
        if (!mounted) return const LoginPage();
        final userProvider = context.read<UserProvider>();
        userProvider.setUserData(userId, name ?? 'Pengguna', detail ?? '', role ?? '', emailStr: email ?? '');

        // Update FCM Token ke Server saat restore sesi
        FirebaseMessagingService.updateFCMTokenToServer(userId, token);

        if (role != null && role.toLowerCase() == 'guru') {
          return const MainGuruPage();
        }
        return const MainPage();
      }
    }

    await storage.clearSession();
    return const LoginPage();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), 
      body: Center( // Memastikan Stack beserta seluruh isinya ditarik ke pusat layar
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            bool showWhiteLogo = _controller.value > 0.55;

            return Stack(
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scale: _bgScale.value * 100, 
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Color(0xFF151B2B), 
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                
                Opacity(
                  opacity: 1.0 - _logoOpacity.value, 
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: Image.asset(
                      'assets/logo_padi.png',
                      width: 130,
                      height: 130,
                      color: showWhiteLogo ? Colors.white : const Color(0xFF006D5B),
                      colorBlendMode: BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}