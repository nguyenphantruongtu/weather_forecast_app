/// Represents a historical weather snapshot at a specific point in time.
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

  /// The date/time of the weather snapshot
  final DateTime date;

  /// Maximum temperature in Celsius
  final double tempMax;

  /// Minimum temperature in Celsius
  final double tempMin;

  /// Weather condition (e.g., 'Clear', 'Rainy', 'Cloudy')
  final String condition;

  /// Weather icon code (e.g., '01d', '02n')
  final String icon;

  /// Humidity percentage (0-100)
  final int humidity;

  /// Wind speed in m/s
  final double windSpeed;

  /// Normalized precipitation value (0.0-1.0)
  final double precipitation;
}
