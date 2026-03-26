import 'package:flutter/material.dart';

class SplashAnimation extends StatefulWidget {
  final Duration duration;

  const SplashAnimation({
    super.key,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<SplashAnimation> createState() => _SplashAnimationState();
}

class _SplashAnimationState extends State<SplashAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.68, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 136,
                height: 136,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF2590C8), Color(0xFF2EB1EE)],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22003B5D),
                      offset: Offset(0, 14),
                      blurRadius: 22,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Positioned(
                          left: 18,
                          child: Icon(
                            Icons.cloud,
                            size: 30,
                            color: Color(0xFFEFF7FE),
                          ),
                        ),
                        Positioned(
                          right: 15,
                          top: 12,
                          child: Icon(
                            Icons.wb_sunny,
                            size: 16,
                            color: Colors.amber.shade400,
                          ),
                        ),
                        Positioned(
                          right: 13,
                          bottom: 12,
                          child: Icon(
                            Icons.thunderstorm,
                            size: 14,
                            color: Colors.lightBlue.shade100,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                'WeatherNow',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your Personal Weather Companion',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 34),
              Container(
                width: 196,
                height: 1,
                color: Colors.white.withValues(alpha: 0.32),
              ),
              const SizedBox(height: 12),
              Text(
                'Loading weather data...',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.50),
                  fontSize: 9,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
