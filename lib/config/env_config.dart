import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized environment keys (loaded after [dotenv.load] in [main]).
abstract final class EnvConfig {
  static const String envFileName = '.env';

  static String get openWeatherApiKey =>
      dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  static String get openWeatherBaseUrl =>
      dotenv.env['OPENWEATHER_BASE_URL'] ??
      'https://api.openweathermap.org/data/2.5';

  static bool get isConfigValid => openWeatherApiKey.isNotEmpty;

  static List<String> validateApiKeys() {
    final missing = <String>[];
    if (openWeatherApiKey.isEmpty) {
      missing.add('OPENWEATHER_API_KEY');
    }
    return missing;
  }
}
