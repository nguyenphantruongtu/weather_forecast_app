import 'package:dio/dio.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../models/weather_day_model.dart' as app_weather;
import '../models/weather_forecast_day_model.dart';
import '../models/weather_history_model.dart';
import '../../utils/calendar_date_utils.dart';

class WeatherApiService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _forecastBaseUrl = 'https://api.open-meteo.com/v1';
  static const String _geocodingBaseUrl = 'https://geocoding-api.open-meteo.com/v1';

  final Dio _dio;
  final String _apiKey;

  // Use mock data for testing
  static const bool USE_MOCK_DATA = false;

  WeatherApiService({
    Dio? dio,
    String? apiKey,
    String? baseUrl,
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            ),
        _apiKey = apiKey ?? '';

  // ============================================================
  // MOCK DATA (for testing without API)
  // ============================================================

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

  // ============================================================
  // OPEN-METEO API (Current Weather - Free Tier)
  // ============================================================

  Future<WeatherModel> getCurrentWeather(String city) async {
    if (USE_MOCK_DATA) {
      await Future.delayed(Duration(milliseconds: 500));
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

  // ============================================================
  // GEOCODING (Open-Meteo)
  // ============================================================

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

  // ============================================================
  // OPENWEATHERMAP API (for Calendar & Statistics screens)
  // ============================================================

  /// Fetch current weather snapshot (for WeatherHistory model)
  Future<WeatherHistory> fetchCurrentWeatherSnapshot({
    required double lat,
    required double lon,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_baseUrl/weather',
      queryParameters: {
        'lat': lat,
        'lon': lon,
        'appid': _apiKey,
        'units': 'metric',
      },
    );

    final data = response.data ?? <String, dynamic>{};
    final weatherList = (data['weather'] as List?) ?? const [];
    final weather = weatherList.isNotEmpty ? weatherList.first as Map : const {};
    final main = (data['main'] as Map?) ?? const {};
    final wind = (data['wind'] as Map?) ?? const {};
    final rainMap = (data['rain'] as Map?) ?? const {};

    // OpenWeather returns mm/1h or mm/3h, normalize to 0.0-1.0
    final rainMm = ((rainMap['1h'] ?? rainMap['3h'] ?? 0) as num).toDouble();
    final normalizedPrecipitation = (rainMm / 10).clamp(0, 1).toDouble();

    return WeatherHistory(
      date: DateTime.now(),
      tempMax: (main['temp_max'] as num?)?.toDouble() ?? 0,
      tempMin: (main['temp_min'] as num?)?.toDouble() ?? 0,
      condition: (weather['main'] as String?) ?? 'Unknown',
      icon: (weather['icon'] as String?) ?? '01d',
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0,
      precipitation: normalizedPrecipitation,
    );
  }

  /// 5 Day / 3 Hour Forecast (free tier)
  Future<List<WeatherDayModel>> fetchFiveDayForecast({
    required double lat,
    required double lon,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_baseUrl/forecast',
      queryParameters: {
        'lat': lat,
        'lon': lon,
        'appid': _apiKey,
        'units': 'metric',
      },
    );

    final data = response.data ?? <String, dynamic>{};
    final list = (data['list'] as List?) ?? <dynamic>[];
    if (list.isEmpty) return [];

    // Group by day
    final byDay = <String, List<Map<String, dynamic>>>{};
    for (final raw in list) {
      final item = Map<String, dynamic>.from(raw as Map);
      final dt = DateTime.fromMillisecondsSinceEpoch(
        ((item['dt'] as num?)?.toInt() ?? 0) * 1000,
      );
      final dayKey = CalendarDateUtils.dayKey(dt);
      byDay.putIfAbsent(dayKey, () => []).add(item);
    }

    final result = <WeatherDayModel>[];
    for (final dayKey in byDay.keys.toList()..sort()) {
      final slots = byDay[dayKey]!;
      final temps = slots
          .map((e) => ((e['main'] as Map?)?['temp'] as num?)?.toDouble() ?? 0.0)
          .toList();
      final maxT = temps.isEmpty ? 0.0 : temps.reduce((a, b) => a > b ? a : b);
      final minT = temps.isEmpty ? 0.0 : temps.reduce((a, b) => a < b ? a : b);
      final midIndex = slots.length ~/ 2;
      final mid = slots[midIndex];
      final main = Map<String, dynamic>.from((mid['main'] as Map?) ?? {});
      final weatherList = (mid['weather'] as List?) ?? [];
      final weather = weatherList.isNotEmpty
          ? Map<String, dynamic>.from(weatherList.first as Map)
          : <String, dynamic>{};
      final wind = Map<String, dynamic>.from((mid['wind'] as Map?) ?? {});
      final rain = (mid['rain'] as Map?) ?? {};
      final pop = (slots.map((e) => (e['pop'] as num?)?.toDouble() ?? 0.0))
          .reduce((a, b) => a > b ? a : b);
      final date = DateTime.parse(dayKey);

      result.add(
        WeatherDayModel(
          date: CalendarDateUtils.normalize(date),
          temp: (maxT + minT) / 2,
          tempMax: maxT,
          tempMin: minT,
          feelsLike: (main['feels_like'] as num?)?.toDouble() ?? (maxT + minT) / 2,
          humidity: (main['humidity'] as num?)?.toInt() ?? 0,
          windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0,
          windDeg: (wind['deg'] as num?)?.toInt() ?? 0,
          precipitationProbability: pop.clamp(0.0, 1.0),
          precipitationAmount: ((rain['3h'] ?? rain['1h'] ?? 0) as num).toDouble(),
          uvIndex: 0,
          sunrise: DateTime(date.year, date.month, date.day, 6),
          sunset: DateTime(date.year, date.month, date.day, 18),
          condition: (weather['main'] as String?) ?? 'Unknown',
          iconCode: (weather['icon'] as String?) ?? '01d',
          hourlyTemperatures: temps.isEmpty
              ? List<double>.filled(24, (maxT + minT) / 2)
              : temps,
        ),
      );
    }
    return result;
  }

  /// Today (current) + up to 5 days forecast
  Future<List<WeatherDayModel>> fetchTodayWithForecast({
    required double lat,
    required double lon,
  }) async {
    try {
      final single = await fetchCurrentWeatherSnapshot(lat: lat, lon: lon);
      final now = DateTime.now();
      final today = WeatherDayModel(
        date: CalendarDateUtils.normalize(now),
        temp: (single.tempMax + single.tempMin) / 2,
        tempMax: single.tempMax,
        tempMin: single.tempMin,
        feelsLike: (single.tempMax + single.tempMin) / 2,
        humidity: single.humidity,
        windSpeed: single.windSpeed,
        windDeg: 0,
        precipitationProbability: single.precipitation,
        precipitationAmount: single.precipitation * 10,
        uvIndex: 0,
        sunrise: DateTime(now.year, now.month, now.day, 6),
        sunset: DateTime(now.year, now.month, now.day, 18),
        condition: single.condition,
        iconCode: single.icon,
        hourlyTemperatures: List<double>.filled(
          24,
          (single.tempMax + single.tempMin) / 2,
        ),
      );

      // Try One Call API (may fail on free tier)
      try {
        final response = await _dio.get<Map<String, dynamic>>(
          '$_baseUrl/onecall',
          queryParameters: {
            'lat': lat,
            'lon': lon,
            'appid': _apiKey,
            'units': 'metric',
            'exclude': 'minutely,alerts',
          },
        );

        final data = response.data ?? <String, dynamic>{};
        final daily = (data['daily'] as List?) ?? [];
        final result = <WeatherDayModel>[today];

        for (final raw in daily.skip(1)) {
          final day = WeatherDayModel.fromOneCallDaily(
            Map<String, dynamic>.from(raw as Map),
          );
          result.add(day);
        }

        return result;
      } catch (_) {
        // One Call failed, use 5-day forecast instead
        final forecast = await fetchFiveDayForecast(lat: lat, lon: lon);
        return [today, ...forecast];
      }
    } catch (e) {
      throw Exception('Failed to fetch today with forecast: $e');
    }
  }

  /// Raw One Call 2.5 response (may 401 on free keys)
  Future<Map<String, dynamic>> fetchOneCallWeather({
    required double lat,
    required double lon,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_baseUrl/onecall',
      queryParameters: {
        'lat': lat,
        'lon': lon,
        'appid': _apiKey,
        'units': 'metric',
        'exclude': 'minutely,alerts',
      },
    );
    return response.data ?? <String, dynamic>{};
  }

  /// Raw 5-day / 3-hour forecast JSON
  Future<Map<String, dynamic>> fetchFiveDayForecastJson({
    required double lat,
    required double lon,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_baseUrl/forecast',
      queryParameters: {
        'lat': lat,
        'lon': lon,
        'appid': _apiKey,
        'units': 'metric',
      },
    );
    return response.data ?? <String, dynamic>{};
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Merges One Call daily (when available) with `/forecast` aggregates
  Future<Map<DateTime, app_weather.WeatherDay>> fetchAppWeatherDays({
    required double lat,
    required double lon,
  }) async {
    final result = <DateTime, app_weather.WeatherDay>{};

    // Try One Call first
    try {
      final one = await fetchOneCallWeather(lat: lat, lon: lon);
      final daily = (one['daily'] as List?) ?? const [];
      for (final raw in daily) {
        final day = app_weather.WeatherDay.fromOneCallDaily(
          Map<String, dynamic>.from(raw as Map),
        );
        result[_dateOnly(day.date)] = day;
      }
    } catch (_) {
      // One Call not available
    }

    // Then try 5-day forecast
    try {
      final fj = await fetchFiveDayForecastJson(lat: lat, lon: lon);
      final list = (fj['list'] as List?) ?? const [];
      final byDay = <String, List<Map<String, dynamic>>>{};
      for (final raw in list) {
        final item = Map<String, dynamic>.from(raw as Map);
        final dt = DateTime.fromMillisecondsSinceEpoch(
          ((item['dt'] as num?)?.toInt() ?? 0) * 1000,
        );
        final key =
            '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
        byDay.putIfAbsent(key, () => []).add(item);
      }
      for (final entry in byDay.entries) {
        final segs = entry.key.split('-');
        final d = DateTime(
          int.parse(segs[0]),
          int.parse(segs[1]),
          int.parse(segs[2]),
        );
        final key = _dateOnly(d);
        final merged = app_weather.WeatherDay.fromForecastSlots(d, entry.value);
        result.putIfAbsent(key, () => merged);
      }
    } catch (_) {
      // Forecast failed
    }

    return result;
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

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
}

// ============================================================
// HELPER CLASS
// ============================================================

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