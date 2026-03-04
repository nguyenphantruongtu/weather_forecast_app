class ForecastModel {
  final String dt;
  final double temp;
  final double tempMin;
  final double tempMax;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String description;
  final String icon;
  final double precipitation;
  final int cloudiness;

  ForecastModel({
    required this.dt,
    required this.temp,
    required this.tempMin,
    required this.tempMax,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.icon,
    required this.precipitation,
    required this.cloudiness,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    return ForecastModel(
      dt: json['dt_txt'] ?? '',
      temp: (json['main']['temp'] ?? 0).toDouble(),
      tempMin: (json['main']['temp_min'] ?? 0).toDouble(),
      tempMax: (json['main']['temp_max'] ?? 0).toDouble(),
      feelsLike: (json['main']['feels_like'] ?? 0).toDouble(),
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] ?? 0).toDouble(),
      description: json['weather'][0]['main'] ?? '',
      icon: json['weather'][0]['icon'] ?? '',
      precipitation: (json['pop'] ?? 0).toDouble(),
      cloudiness: json['clouds']['all'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dt_txt': dt,
      'temp': temp,
      'temp_min': tempMin,
      'temp_max': tempMax,
      'feels_like': feelsLike,
      'humidity': humidity,
      'wind_speed': windSpeed,
      'description': description,
      'icon': icon,
      'pop': precipitation,
      'cloudiness': cloudiness,
    };
  }
}
