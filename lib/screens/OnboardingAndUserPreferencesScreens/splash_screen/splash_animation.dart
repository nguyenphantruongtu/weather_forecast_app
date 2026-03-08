import 'package:flutter/material.dart';

/// Widget tạo animation cho Splash Screen
/// Animation này làm logo phóng to dần (scale animation)
class SplashAnimation extends StatefulWidget {
  final Duration duration; // Thời gian animation

  const SplashAnimation({
    super.key,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<SplashAnimation> createState() => _SplashAnimationState();
}

class _SplashAnimationState extends State<SplashAnimation>
    with SingleTickerProviderStateMixin {
  // SingleTickerProviderStateMixin: cung cấp ticker cho animation
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Khởi tạo AnimationController
    // duration: thời gian animation chạy
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this, // vsync: đồng bộ với refresh rate màn hình
    );

    // Tạo Animation từ 0.8 đến 1.0 (phóng to từ 80% đến 100%)
    _animation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticInOut),
      // CurvedAnimation: thêm easing effect (elasticInOut: co giãn ra)
    );

    // Bắt đầu animation
    _animationController.forward();
  }

  @override
  void dispose() {
    // Dọn dẹp khi widget bị destroy (important!)
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      // ScaleTransition: widget animation để phóng to/nhỏ
      scale: _animation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo ứng dụng - Sử dụng Icon thay vì Image.asset() để chạy ngay
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud,
                color: Colors.blue.shade600,
                size: 80,
              ),
            ),
            const SizedBox(height: 20),
            // App name
            Text(
              'WeatherNow',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            // Tagline
            Text(
              'Check Weather Anytime',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
