/// Snapshot of current weather used for calendar/statistics history.
class WeatherHistory {
  const WeatherHistory({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.condition,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.precipitation,
  });

  final DateTime date;
  final double tempMax;
  final double tempMin;
  final String condition;
  final String icon;
  final int humidity;
  final double windSpeed;
  final double precipitation;

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'tempMax': tempMax,
      'tempMin': tempMin,
      'condition': condition,
      'icon': icon,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'precipitation': precipitation,
    };
  }

  factory WeatherHistory.fromJson(Map<String, dynamic> json) {
    return WeatherHistory(
      date: DateTime.tryParse((json['date'] as String?) ?? '') ?? DateTime.now(),
      tempMax: (json['tempMax'] as num?)?.toDouble() ?? 0,
      tempMin: (json['tempMin'] as num?)?.toDouble() ?? 0,
      condition: (json['condition'] as String?) ?? 'Unknown',
      icon: (json['icon'] as String?) ?? '01d',
      humidity: (json['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (json['windSpeed'] as num?)?.toDouble() ?? 0,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0,
    );
  }
}
