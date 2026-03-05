import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  String get displayTemp => '${tempMax.round()}° / ${tempMin.round()}°';

  String get fullDateLabel => DateFormat('EEEE, MMM d, yyyy').format(date);

  String get weatherIconPath {
    switch (icon) {
      case '01d':
      case '01n':
        return 'assets/images/weather_icons/clear.png';
      case '02d':
      case '02n':
        return 'assets/images/weather_icons/few_clouds.png';
      case '03d':
      case '03n':
        return 'assets/images/weather_icons/scattered_clouds.png';
      case '04d':
      case '04n':
        return 'assets/images/weather_icons/broken_clouds.png';
      case '09d':
      case '09n':
        return 'assets/images/weather_icons/shower_rain.png';
      case '10d':
      case '10n':
        return 'assets/images/weather_icons/rain.png';
      case '11d':
      case '11n':
        return 'assets/images/weather_icons/thunderstorm.png';
      case '13d':
      case '13n':
        return 'assets/images/weather_icons/snow.png';
      case '50d':
      case '50n':
        return 'assets/images/weather_icons/mist.png';
      default:
        return 'assets/images/weather_icons/clear.png';
    }
  }

  Color get temperatureColor {
    final avg = (tempMax + tempMin) / 2;
    if (avg > 30) return Colors.red.shade100;
    if (avg >= 20) return Colors.orange.shade100;
    if (avg >= 10) return Colors.green.shade100;
    return Colors.blue.shade100;
  }

  WeatherHistory copyWith({
    DateTime? date,
    double? tempMax,
    double? tempMin,
    String? condition,
    String? icon,
    int? humidity,
    double? windSpeed,
    double? precipitation,
  }) {
    return WeatherHistory(
      date: date ?? this.date,
      tempMax: tempMax ?? this.tempMax,
      tempMin: tempMin ?? this.tempMin,
      condition: condition ?? this.condition,
      icon: icon ?? this.icon,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      precipitation: precipitation ?? this.precipitation,
    );
  }

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
      date: DateTime.parse(
        (json['date'] as String?) ?? DateTime.now().toIso8601String(),
      ),
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
