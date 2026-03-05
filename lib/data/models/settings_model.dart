/// Temperature unit options for weather display
enum TemperatureUnit {
  celsius,
  fahrenheit;

  /// Get display label for temperature unit
  String get label => this == TemperatureUnit.celsius ? '°C' : '°F';
}

/// Wind speed unit options
enum WindSpeedUnit {
  kmh,
  mph;

  /// Get display label for wind speed unit
  String get label => this == WindSpeedUnit.kmh ? 'km/h' : 'mph';
}

/// App theme options (light or dark mode)
enum AppTheme {
  light,
  dark;

  /// Get display label for theme
  String get label => this == AppTheme.light ? 'Light' : 'Dark';
}

/// Time format options (12-hour or 24-hour)
enum TimeFormat {
  h12,
  h24;

  /// Get display label for time format
  String get label => this == TimeFormat.h12 ? '12h' : '24h';
}

/// Model for storing user settings preferences
/// Stores all user preferences like temperature unit, theme, language, etc.
class SettingsModel {
  /// Temperature unit preference (Celsius or Fahrenheit)
  TemperatureUnit temperatureUnit;

  /// Wind speed unit preference (km/h or mph)
  WindSpeedUnit windSpeedUnit;

  /// App theme preference (Light or Dark)
  AppTheme theme;

  /// Time format preference (12-hour or 24-hour)
  TimeFormat timeFormat;

  /// Language preference (default: English)
  String language;

  /// Constructor with default values
  /// Default: Celsius, km/h, Light theme, 24-hour format, English
  SettingsModel({
    this.temperatureUnit = TemperatureUnit.celsius,
    this.windSpeedUnit = WindSpeedUnit.kmh,
    this.theme = AppTheme.light,
    this.timeFormat = TimeFormat.h24,
    this.language = 'en',
  });
}