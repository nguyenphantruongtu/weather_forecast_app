import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeatherDayModel {
  const WeatherDayModel({
    required this.date,
    required this.temp,
    required this.tempMax,
    required this.tempMin,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    required this.precipitationProbability,
    required this.precipitationAmount,
    required this.uvIndex,
    required this.sunrise,
    required this.sunset,
    required this.condition,
    required this.iconCode,
    required this.hourlyTemperatures,
  });

  final DateTime date;
  final double temp;
  final double tempMax;
  final double tempMin;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int windDeg;
  final double precipitationProbability;
  final double precipitationAmount;
  final double uvIndex;
  final DateTime sunrise;
  final DateTime sunset;
  final String condition;
  final String iconCode;
  final List<double> hourlyTemperatures;

  String get dateKey => DateFormat('yyyy-MM-dd').format(date);

  String get fullDateLabel => DateFormat('EEEE, MMM d, yyyy').format(date);

  String get iconAssetPath {
    switch (iconCode) {
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

  WeatherDayModel copyWith({
    DateTime? date,
    double? temp,
    double? tempMax,
    double? tempMin,
    double? feelsLike,
    int? humidity,
    double? windSpeed,
    int? windDeg,
    double? precipitationProbability,
    double? precipitationAmount,
    double? uvIndex,
    DateTime? sunrise,
    DateTime? sunset,
    String? condition,
    String? iconCode,
    List<double>? hourlyTemperatures,
  }) {
    return WeatherDayModel(
      date: date ?? this.date,
      temp: temp ?? this.temp,
      tempMax: tempMax ?? this.tempMax,
      tempMin: tempMin ?? this.tempMin,
      feelsLike: feelsLike ?? this.feelsLike,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      windDeg: windDeg ?? this.windDeg,
      precipitationProbability:
          precipitationProbability ?? this.precipitationProbability,
      precipitationAmount: precipitationAmount ?? this.precipitationAmount,
      uvIndex: uvIndex ?? this.uvIndex,
      sunrise: sunrise ?? this.sunrise,
      sunset: sunset ?? this.sunset,
      condition: condition ?? this.condition,
      iconCode: iconCode ?? this.iconCode,
      hourlyTemperatures: hourlyTemperatures ?? this.hourlyTemperatures,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'temp': temp,
      'tempMax': tempMax,
      'tempMin': tempMin,
      'feelsLike': feelsLike,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'windDeg': windDeg,
      'precipitationProbability': precipitationProbability,
      'precipitationAmount': precipitationAmount,
      'uvIndex': uvIndex,
      'sunrise': sunrise.toIso8601String(),
      'sunset': sunset.toIso8601String(),
      'condition': condition,
      'iconCode': iconCode,
      'hourlyTemperatures': hourlyTemperatures,
    };
  }

  factory WeatherDayModel.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    final hourly = ((json['hourlyTemperatures'] as List?) ?? const <dynamic>[])
        .map((e) => (e as num).toDouble())
        .toList();
    return WeatherDayModel(
      date: DateTime.tryParse((json['date'] as String?) ?? '') ?? now,
      temp: (json['temp'] as num?)?.toDouble() ?? 0,
      tempMax: (json['tempMax'] as num?)?.toDouble() ?? 0,
      tempMin: (json['tempMin'] as num?)?.toDouble() ?? 0,
      feelsLike: (json['feelsLike'] as num?)?.toDouble() ?? 0,
      humidity: (json['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (json['windSpeed'] as num?)?.toDouble() ?? 0,
      windDeg: (json['windDeg'] as num?)?.toInt() ?? 0,
      precipitationProbability:
          (json['precipitationProbability'] as num?)?.toDouble() ?? 0,
      precipitationAmount:
          (json['precipitationAmount'] as num?)?.toDouble() ?? 0,
      uvIndex: (json['uvIndex'] as num?)?.toDouble() ?? 0,
      sunrise: DateTime.tryParse((json['sunrise'] as String?) ?? '') ?? now,
      sunset: DateTime.tryParse((json['sunset'] as String?) ?? '') ?? now,
      condition: (json['condition'] as String?) ?? 'Unknown',
      iconCode: (json['iconCode'] as String?) ?? '01d',
      hourlyTemperatures: hourly.isEmpty ? <double>[0, 0, 0] : hourly,
    );
  }
}

class WeatherUiPalette {
  const WeatherUiPalette._();

  static const hotGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const coldGradient = LinearGradient(
    colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const normalGradient = LinearGradient(
    colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
