class AlertModel {
  final String event;
  final String description;
  final DateTime start;
  final DateTime end;

  AlertModel({
    required this.event,
    required this.description,
    required this.start,
    required this.end,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      event: json['event'] ?? '',
      description: json['description'] ?? '',
      start: DateTime.fromMillisecondsSinceEpoch((json['start'] ?? 0) * 1000),
      end: DateTime.fromMillisecondsSinceEpoch((json['end'] ?? 0) * 1000),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event': event,
      'description': description,
      'start': start.millisecondsSinceEpoch ~/ 1000,
      'end': end.millisecondsSinceEpoch ~/ 1000,
    };
  }
}
