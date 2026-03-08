class WeatherModel {
  final String location;
  final double temperature;
  final String description;
  final String icon;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final double visibility;
  final double uvIndex;
  final double dewPoint;
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime lastUpdated;

  WeatherModel({
    required this.location,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.visibility,
    required this.uvIndex,
    required this.dewPoint,
    required this.sunrise,
    required this.sunset,
    required this.lastUpdated,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      location: json['name'] ?? '',
      temperature: (json['main']['temp'] ?? 0).toDouble(),
      description: json['weather'][0]['main'] ?? '',
      icon: json['weather'][0]['icon'] ?? '',
      feelsLike: (json['main']['feels_like'] ?? 0).toDouble(),
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] ?? 0).toDouble(),
      pressure: json['main']['pressure'] ?? 0,
      visibility: ((json['visibility'] ?? 0) / 1000).toDouble(),
      uvIndex: (json['uvi'] ?? 0).toDouble(),
      dewPoint: (json['main']['temp'] ?? 0).toDouble() - 5,
      sunrise: DateTime.fromMillisecondsSinceEpoch(
        (json['sys']['sunrise'] ?? 0) * 1000,
      ),
      sunset: DateTime.fromMillisecondsSinceEpoch(
        (json['sys']['sunset'] ?? 0) * 1000,
      ),
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'temperature': temperature,
      'description': description,
      'icon': icon,
      'feels_like': feelsLike,
      'humidity': humidity,
      'wind_speed': windSpeed,
      'pressure': pressure,
      'visibility': visibility,
      'uv_index': uvIndex,
      'dew_point': dewPoint,
      'sunrise': sunrise.toIso8601String(),
      'sunset': sunset.toIso8601String(),
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}
