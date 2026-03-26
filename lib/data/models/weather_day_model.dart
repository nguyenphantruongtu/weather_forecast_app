class WeatherDay {
  const WeatherDay({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.condition,
    required this.icon,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.precipitation,
    required this.uvIndex,
    required this.sunrise,
    required this.sunset,
    this.feelsLike,
  });

  final DateTime date;
  final double tempMax;
  final double tempMin;
  final String condition;
  final String icon;
  final String description;
  final int humidity;
  final double windSpeed;
  final double precipitation;
  final int uvIndex;
  final DateTime sunrise;
  final DateTime sunset;
  final double? feelsLike;

  factory WeatherDay.fromOneCallDaily(Map<String, dynamic> json) {
    final weatherList = (json['weather'] as List?) ?? const [];
    final w = weatherList.isNotEmpty
        ? Map<String, dynamic>.from(weatherList.first as Map)
        : <String, dynamic>{};
    final temp = Map<String, dynamic>.from((json['temp'] as Map?) ?? const {});
    final feels = Map<String, dynamic>.from(
      (json['feels_like'] as Map?) ?? const {},
    );

    return WeatherDay(
      date: DateTime.fromMillisecondsSinceEpoch(
        ((json['dt'] as num?)?.toInt() ?? 0) * 1000,
      ),
      tempMax: (temp['max'] as num?)?.toDouble() ?? 0,
      tempMin: (temp['min'] as num?)?.toDouble() ?? 0,
      condition: (w['main'] as String?) ?? 'Clear',
      icon: _mapConditionToEmoji((w['main'] as String?) ?? 'Clear'),
      description: (w['description'] as String?) ?? '',
      humidity: (json['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind_speed'] as num?)?.toDouble() ?? 0,
      precipitation: _parseDailyPrecipitation(json),
      uvIndex: ((json['uvi'] as num?)?.toDouble() ?? 0).round(),
      sunrise: DateTime.fromMillisecondsSinceEpoch(
        ((json['sunrise'] as num?)?.toInt() ?? 0) * 1000,
      ),
      sunset: DateTime.fromMillisecondsSinceEpoch(
        ((json['sunset'] as num?)?.toInt() ?? 0) * 1000,
      ),
      feelsLike: (feels['day'] as num?)?.toDouble(),
    );
  }

  /// Aggregated from /forecast 3-hour slots for one calendar day.
  factory WeatherDay.fromForecastSlots(
    DateTime date,
    List<Map<String, dynamic>> slots,
  ) {
    if (slots.isEmpty) {
      return WeatherDay(
        date: date,
        tempMax: 0,
        tempMin: 0,
        condition: 'Clear',
        icon: '☀️',
        description: '',
        humidity: 0,
        windSpeed: 0,
        precipitation: 0,
        uvIndex: 0,
        sunrise: DateTime(date.year, date.month, date.day, 6),
        sunset: DateTime(date.year, date.month, date.day, 18),
      );
    }

    final temps = slots
        .map(
          (e) =>
              ((e['main'] as Map?)?['temp'] as num?)?.toDouble() ?? 0.0,
        )
        .toList();
    final maxT = temps.reduce((a, b) => a > b ? a : b);
    final minT = temps.reduce((a, b) => a < b ? a : b);
    final mid = slots[slots.length ~/ 2];
    final main = Map<String, dynamic>.from((mid['main'] as Map?) ?? const {});
    final weatherList = (mid['weather'] as List?) ?? const [];
    final w = weatherList.isNotEmpty
        ? Map<String, dynamic>.from(weatherList.first as Map)
        : <String, dynamic>{};
    final wind = Map<String, dynamic>.from((mid['wind'] as Map?) ?? const {});
    double rainSum = 0;
    for (final s in slots) {
      final rain = (s['rain'] as Map?);
      final snow = (s['snow'] as Map?);
      rainSum += ((rain?['3h'] ?? rain?['1h'] ?? 0) as num?)?.toDouble() ?? 0;
      rainSum += ((snow?['3h'] ?? snow?['1h'] ?? 0) as num?)?.toDouble() ?? 0;
    }
    final popMax = slots
        .map((e) => (e['pop'] as num?)?.toDouble() ?? 0.0)
        .fold<double>(0, (a, b) => a > b ? a : b);

    return WeatherDay(
      date: date,
      tempMax: maxT,
      tempMin: minT,
      condition: (w['main'] as String?) ?? 'Clear',
      icon: _mapConditionToEmoji((w['main'] as String?) ?? 'Clear'),
      description: (w['description'] as String?) ?? '',
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0,
      precipitation: rainSum > 0 ? rainSum : popMax * 5,
      uvIndex: 0,
      sunrise: DateTime(date.year, date.month, date.day, 6),
      sunset: DateTime(date.year, date.month, date.day, 18),
      feelsLike: (main['feels_like'] as num?)?.toDouble(),
    );
  }

  static double _parseDailyPrecipitation(Map<String, dynamic> json) {
    final r = json['rain'];
    if (r == null) return 0;
    if (r is num) return r.toDouble();
    if (r is Map) {
      return ((r['1d'] ?? r['3h'] ?? r['1h'] ?? 0) as num?)?.toDouble() ?? 0;
    }
    return 0;
  }

  static String _mapConditionToEmoji(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
        return '🌧️';
      case 'drizzle':
        return '🌦️';
      case 'thunderstorm':
        return '⛈️';
      case 'snow':
        return '🌨️';
      case 'mist':
      case 'fog':
      case 'haze':
        return '🌫️';
      default:
        return '☀️';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'tempMax': tempMax,
      'tempMin': tempMin,
      'condition': condition,
      'icon': icon,
      'description': description,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'precipitation': precipitation,
      'uvIndex': uvIndex,
      'sunrise': sunrise.toIso8601String(),
      'sunset': sunset.toIso8601String(),
      'feelsLike': feelsLike,
    };
  }

  factory WeatherDay.fromJson(Map<String, dynamic> json) {
    return WeatherDay(
      date: DateTime.parse(json['date'] as String),
      tempMax: (json['tempMax'] as num).toDouble(),
      tempMin: (json['tempMin'] as num).toDouble(),
      condition: json['condition'] as String,
      icon: json['icon'] as String,
      description: json['description'] as String,
      humidity: (json['humidity'] as num).toInt(),
      windSpeed: (json['windSpeed'] as num).toDouble(),
      precipitation: (json['precipitation'] as num).toDouble(),
      uvIndex: (json['uvIndex'] as num).toInt(),
      sunrise: DateTime.parse(json['sunrise'] as String),
      sunset: DateTime.parse(json['sunset'] as String),
      feelsLike: json['feelsLike'] != null
          ? (json['feelsLike'] as num).toDouble()
          : null,
    );
  }
}
