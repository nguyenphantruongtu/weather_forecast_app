import 'package:flutter/material.dart';

enum OnboardingArtType {
  smartWeather,
  informedAlerts,
  multiLocation,
}

class OnboardingPage {
  final String title;
  final String description;
  final OnboardingArtType artType;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.artType,
  });
}

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;

  const OnboardingPageWidget({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _OnboardingIllustration(artType: page.artType),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF171B2C),
              height: 1.05,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Text(
            page.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF7D8598),
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _OnboardingIllustration extends StatelessWidget {
  final OnboardingArtType artType;

  const _OnboardingIllustration({required this.artType});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      width: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 188,
            height: 188,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE9F0F8),
            ),
          ),
          if (artType == OnboardingArtType.smartWeather) ...[
            Positioned(
              top: 48,
              child: Icon(Icons.wb_sunny, size: 24, color: Colors.orange.shade700),
            ),
            Positioned(
              left: 56,
              top: 74,
              child: Container(
                width: 62,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.shade500,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.cloud, color: Color(0xFFEFF7FF), size: 28),
              ),
            ),
            Positioned(
              right: 68,
              top: 76,
              child: Icon(Icons.cloud, size: 36, color: Colors.blueGrey.shade600),
            ),
            Positioned(
              right: 67,
              top: 107,
              child: Icon(Icons.flash_on, size: 20, color: Colors.amber.shade700),
            ),
            Positioned(
              right: 54,
              bottom: 57,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.orange.shade400,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.shade200,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.notifications, color: Colors.white, size: 18),
              ),
            ),
          ],
          if (artType == OnboardingArtType.informedAlerts) ...[
            Positioned(
              top: 38,
              child: Container(
                width: 94,
                height: 130,
                decoration: BoxDecoration(
                  color: const Color(0xFF2F84D8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.phone_android_rounded, color: Colors.white, size: 72),
              ),
            ),
            Positioned(
              left: 58,
              top: 74,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_active, color: Colors.white, size: 20),
              ),
            ),
            Positioned(
              right: 54,
              top: 86,
              child: Icon(Icons.cloud, color: Colors.blueGrey.shade600, size: 34),
            ),
            Positioned(
              right: 54,
              top: 116,
              child: Icon(Icons.bolt, color: Colors.orange.shade700, size: 18),
            ),
          ],
          if (artType == OnboardingArtType.multiLocation) ...[
            Positioned(
              left: 64,
              top: 76,
              child: _pinNode(Colors.orange.shade300, Icons.wb_sunny),
            ),
            Positioned(
              right: 56,
              top: 82,
              child: _pinNode(Colors.blue.shade200, Icons.water_drop),
            ),
            Positioned(
              left: 98,
              bottom: 56,
              child: _pinNode(Colors.blueGrey.shade200, Icons.cloud),
            ),
            Positioned.fill(
              child: CustomPaint(painter: _PathPainter()),
            ),
          ],
        ],
      ),
    );
  }

  Widget _pinNode(Color color, IconData icon) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.82),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.6),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC7D8EE)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(86, 96)
      ..quadraticBezierTo(112, 66, 144, 92)
      ..quadraticBezierTo(126, 114, 113, 142)
      ..quadraticBezierTo(96, 132, 86, 96);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
