import 'package:flutter/material.dart';
import '../onboarding_screen/onboarding_screen.dart';
import 'splash_animation.dart';

/// Màn hình Splash Screen (Màn 1 - Khởi động)
/// Hiển thị logo app với animation, sau đó chuyển sang Onboarding
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Sau 3 giây, chuyển sang màn Onboarding
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // mounted: kiểm tra widget có còn trong tree không
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          // pushReplacement: chuyển sang màn mới và xóa splash screen khỏi stack
          // Để không quay lại được màn splash
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0E6FA1), Color(0xFF11B4E6)],
          ),
        ),
        child: const SafeArea(child: SplashAnimation()),
      ),
    );
  }
}