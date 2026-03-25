import 'package:dio/dio.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

// Mock data flag
const bool USE_MOCK_DATA = true;

class WeatherApiService {
  static const String _forecastBaseUrl = 'https://api.open-meteo.com/v1';
  static const String _geocodingBaseUrl = 'https://geocoding-api.open-meteo.com/v1';

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // Use mock data for testing
  static const bool USE_MOCK_DATA = true;

  // Mock weather data generator
  WeatherModel _getMockWeather(String city) {
    return WeatherModel(
      location: city,
      temperature: 28.5,
      description: 'Clear',
      icon: '01d',
      feelsLike: 29.2,
      humidity: 65,
      windSpeed: 3.5,
      pressure: 1013,
      visibility: 10.0,
      uvIndex: 7.2,
      dewPoint: 20.0,
      sunrise: DateTime.now().subtract(Duration(hours: 6)),
      sunset: DateTime.now().add(Duration(hours: 6)),
      lastUpdated: DateTime.now(),
    );
  }

  List<ForecastModel> _getMockForecast(String city) {
    List<ForecastModel> forecasts = [];
    for (int i = 0; i < 8; i++) {
      forecasts.add(
        ForecastModel(
          dt: DateTime.now().add(Duration(hours: i)).toString(),
          temp: 25.0 + (i * 0.5),
          tempMin: 23.0 + (i * 0.3),
          tempMax: 27.0 + (i * 0.7),
          feelsLike: 25.5 + (i * 0.5),
          humidity: 60 + i,
          windSpeed: 3.0 + (i * 0.2),
          description: 'Clear',
          icon: '01d',
          precipitation: 0.0,
          cloudiness: 10,
        ),
      );
    }
    return forecasts;
  }

  Future<WeatherModel> getCurrentWeather(String city) async {
    if (USE_MOCK_DATA) {
      await Future.delayed(Duration(milliseconds: 500)); // Simulate API delay
      return _getMockWeather(city);
    }

    try {
      final geo = await _searchCity(city);
      final forecastData = await _fetchForecastData(geo.latitude, geo.longitude);
      return _buildCurrentWeather(
        forecastData,
        '${geo.name}, ${geo.country}',
      );
    } catch (e) {
      throw Exception('Failed to load current weather: $e');
    }
  }

  Future<List<ForecastModel>> getHourlyForecast(String city) async {
    if (USE_MOCK_DATA) {
      await Future.delayed(Duration(milliseconds: 500));
      return _getMockForecast(city);
    }

    try {
      final geo = await _searchCity(city);
      final forecastData = await _fetchForecastData(geo.latitude, geo.longitude);
      return _buildHourlyForecast(forecastData);
    } catch (e) {
      throw Exception('Failed to load hourly forecast: $e');
    }
  }

  Future<List<ForecastModel>> getDailyForecast(String city) async {
    try {
      final geo = await _searchCity(city);
      final forecastData = await _fetchForecastData(geo.latitude, geo.longitude);
      return _buildDailyForecast(forecastData);
    } catch (e) {
      throw Exception('Failed to load daily forecast: $e');
    }
  }

  Future<WeatherModel> getWeatherByCoordinates(
    double latitude,
    double longitude,
  ) async {
    return getWeatherByCoordinatesWithLocation(
      latitude,
      longitude,
      locationName: null,
    );
  }

  Future<WeatherModel> getWeatherByCoordinatesWithLocation(
    double latitude,
    double longitude, {
    String? locationName,
  }) async {
    try {
      final placeName = locationName ?? await _reverseGeocode(latitude, longitude);
      final forecastData = await _fetchForecastData(latitude, longitude);
      return _buildCurrentWeather(forecastData, placeName);
    } catch (e) {
      throw Exception('Failed to load weather by coordinates: $e');
    }
  }

  Future<_GeoPoint> _searchCity(String city) async {
    final response = await _dio.get(
      '$_geocodingBaseUrl/search',
      queryParameters: {
        'name': city,
        'count': 1,
        'language': 'en',
        'format': 'json',
      },
    );

    final results = response.data['results'] as List<dynamic>?;
    if (results == null || results.isEmpty) {
      throw Exception('City not found: $city');
    }

    final first = results.first as Map<String, dynamic>;
    return _GeoPoint(
      name: (first['name'] ?? city).toString(),
      country: (first['country'] ?? '').toString(),
      latitude: _toDouble(first['latitude']),
      longitude: _toDouble(first['longitude']),
    );
  }

  Future<String> _reverseGeocode(double latitude, double longitude) async {
    try {
      final response = await _dio.get(
        '$_geocodingBaseUrl/reverse',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'count': 1,
          'language': 'en',
          'format': 'json',
        },
      );

      final results = response.data['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) {
        return '${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)}';
      }

      final first = results.first as Map<String, dynamic>;
      final name = (first['name'] ?? '').toString();
      final country = (first['country'] ?? '').toString();
      if (name.isEmpty) return country;
      if (country.isEmpty) return name;
      return '$name, $country';
    } catch (_) {
      return '${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)}';
    }
  }

  Future<Map<String, dynamic>> _fetchForecastData(
    double latitude,
    double longitude,
  ) async {
    final response = await _dio.get(
      '$_forecastBaseUrl/forecast',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'current':
            'temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,surface_pressure,weather_code',
        'hourly':
            'temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,precipitation_probability,cloud_cover,weather_code,visibility,dew_point_2m,uv_index',
        'daily':
            'weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,wind_speed_10m_max,precipitation_probability_max',
        'forecast_days': 7,
        'timezone': 'auto',
      },
    );

    return response.data as Map<String, dynamic>;
  }

  WeatherModel _buildCurrentWeather(
    Map<String, dynamic> data,
    String locationName,
  ) {
    final current = data['current'] as Map<String, dynamic>? ?? {};
    final hourly = data['hourly'] as Map<String, dynamic>? ?? {};
    final daily = data['daily'] as Map<String, dynamic>? ?? {};

    final hourlyTimes = (hourly['time'] as List<dynamic>? ?? [])
        .map((item) => item.toString())
        .toList();
    final currentTime = (current['time'] ?? '').toString();
    int index = hourlyTimes.indexOf(currentTime);
    if (index < 0) index = 0;

    final visibilityMeters = _valueAt(hourly['visibility'], index, 0);
    final uvIndex = _valueAt(hourly['uv_index'], index, 0);
    final dewPoint = _valueAt(hourly['dew_point_2m'], index, 0);

    final sunriseList = daily['sunrise'] as List<dynamic>? ?? [];
    final sunsetList = daily['sunset'] as List<dynamic>? ?? [];

    final weatherCode = _toInt(current['weather_code']);
    final condition = _legacyConditionFromCode(weatherCode);

    return WeatherModel(
      location: locationName,
      temperature: _toDouble(current['temperature_2m']),
      description: condition,
      icon: _iconFromCondition(condition),
      feelsLike: _toDouble(current['apparent_temperature']),
      humidity: _toInt(current['relative_humidity_2m']),
      windSpeed: _toDouble(current['wind_speed_10m']),
      pressure: _toInt(current['surface_pressure']),
      visibility: _toDouble(visibilityMeters) / 1000,
      uvIndex: _toDouble(uvIndex),
      dewPoint: _toDouble(dewPoint),
      sunrise: _parseDateTime(
        sunriseList.isNotEmpty ? sunriseList.first.toString() : null,
      ),
      sunset: _parseDateTime(
        sunsetList.isNotEmpty ? sunsetList.first.toString() : null,
      ),
      lastUpdated: DateTime.now(),
    );
  }

  List<ForecastModel> _buildHourlyForecast(Map<String, dynamic> data) {
    final hourly = data['hourly'] as Map<String, dynamic>? ?? {};
    final time = (hourly['time'] as List<dynamic>? ?? [])
        .map((item) => item.toString())
        .toList();
    final temp = hourly['temperature_2m'] as List<dynamic>? ?? [];
    final feelsLike = hourly['apparent_temperature'] as List<dynamic>? ?? [];
    final humidity = hourly['relative_humidity_2m'] as List<dynamic>? ?? [];
    final wind = hourly['wind_speed_10m'] as List<dynamic>? ?? [];
    final weatherCode = hourly['weather_code'] as List<dynamic>? ?? [];
    final pop = hourly['precipitation_probability'] as List<dynamic>? ?? [];
    final clouds = hourly['cloud_cover'] as List<dynamic>? ?? [];

    final int count = time.length < 48 ? time.length : 48;
    final List<ForecastModel> items = [];

    for (int i = 0; i < count; i++) {
      final condition = _legacyConditionFromCode(_valueAt(weatherCode, i, 3));
      final currentTemp = _toDouble(_valueAt(temp, i, 0));

      items.add(
        ForecastModel(
          dt: _normalizeDateTimeString(time[i]),
          temp: currentTemp,
          tempMin: currentTemp - 1,
          tempMax: currentTemp + 1,
          feelsLike: _toDouble(_valueAt(feelsLike, i, currentTemp)),
          humidity: _toInt(_valueAt(humidity, i, 0)),
          windSpeed: _toDouble(_valueAt(wind, i, 0)),
          description: condition,
          icon: _iconFromCondition(condition),
          precipitation: _toDouble(_valueAt(pop, i, 0)) / 100,
          cloudiness: _toInt(_valueAt(clouds, i, 0)),
        ),
      );
    }

    return items;
  }

  List<ForecastModel> _buildDailyForecast(Map<String, dynamic> data) {
    final daily = data['daily'] as Map<String, dynamic>? ?? {};
    final dates = (daily['time'] as List<dynamic>? ?? [])
        .map((item) => item.toString())
        .toList();
    final code = daily['weather_code'] as List<dynamic>? ?? [];
    final tempMax = daily['temperature_2m_max'] as List<dynamic>? ?? [];
    final tempMin = daily['temperature_2m_min'] as List<dynamic>? ?? [];
    final wind = daily['wind_speed_10m_max'] as List<dynamic>? ?? [];
    final pop = daily['precipitation_probability_max'] as List<dynamic>? ?? [];

    final List<ForecastModel> items = [];
    for (int i = 0; i < dates.length; i++) {
      final minT = _toDouble(_valueAt(tempMin, i, 0));
      final maxT = _toDouble(_valueAt(tempMax, i, 0));
      final condition = _legacyConditionFromCode(_valueAt(code, i, 3));
      items.add(
        ForecastModel(
          dt: '${dates[i]} 12:00:00',
          temp: (minT + maxT) / 2,
          tempMin: minT,
          tempMax: maxT,
          feelsLike: (minT + maxT) / 2,
          humidity: 0,
          windSpeed: _toDouble(_valueAt(wind, i, 0)),
          description: condition,
          icon: _iconFromCondition(condition),
          precipitation: _toDouble(_valueAt(pop, i, 0)) / 100,
          cloudiness: 0,
        ),
      );
    }

    return items;
  }

  String _legacyConditionFromCode(int code) {
    if (code == 0) return 'clear';
    if (code == 1 || code == 2 || code == 3) return 'clouds';
    if (code == 45 || code == 48) return 'mist';
    if (code == 51 || code == 53 || code == 55 || code == 56 || code == 57) {
      return 'drizzle';
    }
    if (code == 61 || code == 63 || code == 65 || code == 66 || code == 67) {
      return 'rain';
    }
    if (code == 71 || code == 73 || code == 75 || code == 77 || code == 85 || code == 86) {
      return 'snow';
    }
    if (code == 95 || code == 96 || code == 99) return 'thunderstorm';
    return 'clouds';
  }

  String _iconFromCondition(String condition) {
    switch (condition) {
      case 'clear':
        return '01d';
      case 'clouds':
        return '03d';
      case 'drizzle':
        return '09d';
      case 'rain':
        return '10d';
      case 'thunderstorm':
        return '11d';
      case 'snow':
        return '13d';
      case 'mist':
        return '50d';
      default:
        return '03d';
    }
  }

  DateTime _parseDateTime(String? value) {
    final parsed = DateTime.tryParse(value ?? '');
    return parsed ?? DateTime.now();
  }

  String _normalizeDateTimeString(String value) {
    var normalized = value.replaceFirst('T', ' ');
    if (normalized.length == 16) {
      normalized = '$normalized:00';
    }
    return normalized;
  }

  dynamic _valueAt(dynamic source, int index, dynamic fallback) {
    if (source is! List<dynamic>) return fallback;
    if (index < 0 || index >= source.length) return fallback;
    return source[index];
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  int _toInt(dynamic value) {
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  WeatherModel _getMockWeather(String city) {
    return WeatherModel(
      location: city,
      temperature: 25.0,
      description: 'Clear',
      icon: '01d',
      feelsLike: 26.0,
      humidity: 60,
      windSpeed: 5.0,
      pressure: 1013,
      visibility: 10.0,
      uvIndex: 5.0,
      dewPoint: 20.0,
      sunrise: DateTime.now().add(Duration(hours: 6)),
      sunset: DateTime.now().add(Duration(hours: 18)),
      lastUpdated: DateTime.now(),
    );
  }

  Future<WeatherModel> getWeatherByCoordinatesWithLocation(
    double latitude,
    double longitude, {
    required String locationName,
  }) async {
    if (USE_MOCK_DATA) {
      await Future.delayed(Duration(milliseconds: 500));
      return WeatherModel(
        location: locationName,
        temperature: 25.0,
        description: 'Clear',
        icon: '01d',
        feelsLike: 26.0,
        humidity: 60,
        windSpeed: 5.0,
        pressure: 1013,
        visibility: 10.0,
        uvIndex: 5.0,
        dewPoint: 20.0,
        sunrise: DateTime.now().add(Duration(hours: 6)),
        sunset: DateTime.now().add(Duration(hours: 18)),
        lastUpdated: DateTime.now(),
      );
    }

    try {
      final response = await _dio.get(
        '$_baseUrl/weather',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'appid': _apiKey,
          'units': 'metric',
        },
      );
      if (response.statusCode == 200) {
        return WeatherModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Failed to load weather by coordinates: $e');
    }
  }
}

class _GeoPoint {
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  const _GeoPoint({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });
}
