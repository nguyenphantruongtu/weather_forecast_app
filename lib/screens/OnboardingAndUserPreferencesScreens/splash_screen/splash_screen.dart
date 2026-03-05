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
      // Scaffold: cấu trúc cơ bản của một screen (AppBar, body, FloatingButton...)
      body: Container(
        // Container: widget để chứa các widget khác, có thể set background color
        width: double.infinity,
        height: double.infinity,
        // double.infinity: chiếm toàn bộ kích thước khả dụng
        decoration: BoxDecoration(
          // Gradient background từ xanh nhạt đến xanh đậm
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade100,
              Colors.blue.shade600,
            ],
          ),
        ),
        child: const SplashAnimation(),
        // Gọi widget animation mà ta đã tạo
      ),
    );
  }
}