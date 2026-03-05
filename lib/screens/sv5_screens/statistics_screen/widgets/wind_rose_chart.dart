import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/chart_data_model.dart';

class WindRoseChart extends StatelessWidget {
  const WindRoseChart({super.key, required this.data});

  final List<WindRoseBucket> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text('No wind data', style: TextStyle(color: Colors.white70)),
      );
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return CustomPaint(
          painter: _WindRosePainter(data: data, progress: value),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _WindRosePainter extends CustomPainter {
  _WindRosePainter({required this.data, required this.progress});

  final List<WindRoseBucket> data;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2.4;
    final maxValue = data
        .map((e) => e.value)
        .reduce(math.max)
        .clamp(1, double.infinity);

    for (var i = 0; i < data.length; i++) {
      final angle = (2 * math.pi / data.length) * i - math.pi / 2;
      final normalized = data[i].value / maxValue;
      final segment = radius * normalized * progress;
      final end = Offset(
        center.dx + math.cos(angle) * segment,
        center.dy + math.sin(angle) * segment,
      );
      final p = Paint()
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..color = const Color(
          0xFFB4A5FF,
        ).withValues(alpha: 0.45 + (0.45 * normalized));
      canvas.drawLine(center, end, p);
    }

    final centerPaint = Paint()..color = Colors.white70;
    canvas.drawCircle(center, 3, centerPaint);
  }

  @override
  bool shouldRepaint(covariant _WindRosePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.data != data;
  }
}
