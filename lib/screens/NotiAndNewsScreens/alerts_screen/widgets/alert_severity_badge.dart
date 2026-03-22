import 'package:flutter/material.dart';
import '../../../../data/models/news_alert_model.dart';

class AlertSeverityBadge extends StatelessWidget {
  final AlertSeverity severity;
  final int? count;

  const AlertSeverityBadge({super.key, required this.severity, this.count});

  String get label {
    switch (severity) {
      case AlertSeverity.extreme:
        return 'Extreme';
      case AlertSeverity.severe:
        return 'Severe';
      case AlertSeverity.moderate:
        return 'Moderate';
      case AlertSeverity.minor:
        return 'Minor';
    }
  }

  Color get color {
    switch (severity) {
      case AlertSeverity.extreme:
        return const Color(0xFFD32F2F);
      case AlertSeverity.severe:
        return const Color(0xFFE65100);
      case AlertSeverity.moderate:
        return const Color(0xFFF57C00);
      case AlertSeverity.minor:
        return const Color(0xFF388E3C);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        if (count != null) ...[
          const SizedBox(width: 4),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ],
    );
  }
}