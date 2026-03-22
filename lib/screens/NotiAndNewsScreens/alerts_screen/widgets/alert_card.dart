import 'package:flutter/material.dart';
import '../../../../data/models/news_alert_model.dart';

class AlertCard extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback? onTap;

  const AlertCard({super.key, required this.alert, this.onTap});

  Color get _severityColor {
    switch (alert.severity) {
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

  Color get _bgColor {
    switch (alert.severity) {
      case AlertSeverity.extreme:
        return const Color(0xFFFFF3F3);
      case AlertSeverity.severe:
        return const Color(0xFFFFF8F5);
      case AlertSeverity.moderate:
        return const Color(0xFFFFFBF0);
      case AlertSeverity.minor:
        return const Color(0xFFF0FFF4);
    }
  }

  IconData get _alertIcon {
    switch (alert.type) {
      case AlertType.thunderstorm:
        return Icons.thunderstorm_outlined;
      case AlertType.heat:
        return Icons.thermostat;
      case AlertType.flood:
        return Icons.water;
      case AlertType.wind:
        return Icons.air;
      case AlertType.cold:
        return Icons.ac_unit;
      case AlertType.fog:
        return Icons.cloud;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: _bgColor,
          border: Border(
            left: BorderSide(color: _severityColor, width: 4),
          ),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _severityColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      alert.severityLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    alert.updatedAt.difference(DateTime.now()).abs().inHours > 0
                        ? '${alert.updatedAt.difference(DateTime.now()).abs().inHours} hours ago'
                        : '${alert.updatedAt.difference(DateTime.now()).abs().inMinutes} min ago',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.more_vert, color: Colors.grey[400], size: 18),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _severityColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_alertIcon, color: _severityColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 13, color: Colors.grey[500]),
                            const SizedBox(width: 2),
                            Text(
                              alert.location,
                              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          alert.timeRange,
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                alert.description,
                style: TextStyle(
                  fontSize: 13.5,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      border: Border.all(color: _severityColor.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Impact: ${alert.impact}',
                      style: TextStyle(
                        fontSize: 12,
                        color: _severityColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: onTap,
                    icon: Icon(Icons.keyboard_arrow_down, size: 16, color: _severityColor),
                    label: Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 13,
                        color: _severityColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.share_outlined, size: 18, color: Colors.grey[500]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}