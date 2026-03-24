enum AlertSeverity { extreme, severe, moderate, minor }
enum AlertType { thunderstorm, heat, flood, wind, cold, fog }

class AlertModel {
  final String id;
  final String title;
  final String description;
  final AlertSeverity severity;
  final AlertType type;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime updatedAt;
  final String impact;
  final bool isActive;

  const AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.type,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.updatedAt,
    required this.impact,
    required this.isActive,
  });

  String get severityLabel {
    switch (severity) {
      case AlertSeverity.extreme:
        return 'EXTREME';
      case AlertSeverity.severe:
        return 'SEVERE WEATHER';
      case AlertSeverity.moderate:
        return 'MODERATE';
      case AlertSeverity.minor:
        return 'MINOR';
    }
  }

  String get timeRange {
    final start = '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')} ${startTime.hour >= 12 ? 'PM' : 'AM'}';
    final end = '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')} ${endTime.hour >= 12 ? 'PM' : 'AM'}';
    return 'Today $start – $end';
  }
}