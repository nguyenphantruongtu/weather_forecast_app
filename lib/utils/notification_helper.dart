import 'package:flutter/material.dart';

class NotificationHelper {
  /// Format notification time for display
  static String formatTime(int hour, int minute) {
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  /// Get color for alert severity
  static Color getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'extreme':
        return const Color(0xFFD32F2F);
      case 'severe':
        return const Color(0xFFE65100);
      case 'moderate':
        return const Color(0xFFF57C00);
      default:
        return const Color(0xFF388E3C);
    }
  }

  /// Show snackbar for notification action
  static void showActionSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF6B7AEF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Check if notifications should be shown based on current time
  static bool isQuietHours(int startHour, int endHour) {
    final currentHour = DateTime.now().hour;
    if (startHour <= endHour) {
      return currentHour >= startHour && currentHour < endHour;
    } else {
      return currentHour >= startHour || currentHour < endHour;
    }
  }
}