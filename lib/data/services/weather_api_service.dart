import 'package:dio/dio.dart';
import '../models/weather_history_model.dart';
import '../models/weather_model.dart'; // Import của Tùng
import '../models/forecast_model.dart'; // Import của Tùng
import '../../screens/sv5_screens/calendar_screen/models/weather_day_model.dart';
import '../../screens/sv5_screens/calendar_screen/utils/date_utils.dart';

class WeatherApiService {
  // Sử dụng Constructor từ develop để linh hoạt quản lý API Key
  WeatherApiService({
    required Dio dio,
    required String apiKey,
    String baseUrl = 'https://api.openweathermap.org/data/2.5',
  })  : _dio = dio,
        _apiKey = apiKey,
        _baseUrl = baseUrl;

  final Dio _dio;
  final String _apiKey;
  final String _baseUrl;

  // --- PHẦN 1: GIỮ CÁC HÀM TỪ TUNGNQ (Để phục vụ màn hình tìm kiếm thành phố) ---

  Future<WeatherModel> getCurrentWeather(String city) async {
    if (USE_MOCK_DATA) {
      await Future.delayed(Duration(milliseconds: 500)); // Simulate API delay
      return _getMockWeather(city);
    }

    try {
      final response = await _dio.get(
        '$_baseUrl/weather',
        queryParameters: {'q': city, 'appid': _apiKey, 'units': 'metric'},
      );
      if (response.statusCode == 200) {
        return WeatherModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Failed to load current weather: $e');
    }
  }

  Future<List<ForecastModel>> getHourlyForecast(String city) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/forecast',
        queryParameters: {'q': city, 'appid': _apiKey, 'units': 'metric'},
      );
      if (response.statusCode == 200) {
        List<dynamic> list = response.data['list'] as List<dynamic>;
        return list
            .map((item) => ForecastModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load forecast data');
      }
    } catch (e) {
      throw Exception('Failed to load hourly forecast: $e');
    }
  }

  Future<List<ForecastModel>> getForecast(String city) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/forecast',
        queryParameters: {'q': city, 'appid': _apiKey, 'units': 'metric'},
      );
      if (response.statusCode == 200) {
        List<dynamic> list = response.data['list'] as List<dynamic>;
        return list
            .map((item) => ForecastModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load forecast data');
      }
    } catch (e) {
      throw Exception('Failed to load daily forecast: $e');
    }
  }

  // --- PHẦN 2: GIỮ CÁC HÀM NÂNG CAO TỪ DEVELOP (Phục vụ Calendar và One Call) ---

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

  // --- PHẦN 3: CÁC HÀM NÂNG CAO CHO CALENDAR (TỪ DEVELOP) ---

  Future<List<WeatherDayModel>> fetchFiveDayForecast({
    required double lat,
    required double lon,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_baseUrl/onecall',
      queryParameters: {
        'lat': lat,
        'lon': lon,
        'exclude': 'minutely,hourly,alerts',
        'appid': _apiKey,
        'units': 'metric',
      },
    );

    final data = response.data ?? <String, dynamic>{};
    final dailyList = (data['daily'] as List?) ?? const <Map>[];
    return _parseOneCallDays(dailyList.cast<Map<dynamic, dynamic>>());
  }

  Future<List<WeatherDayModel>> fetchTodayWithForecast({
    required double lat,
    required double lon,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_baseUrl/onecall',
      queryParameters: {
        'lat': lat,
        'lon': lon,
        'exclude': 'minutely,hourly,alerts',
        'appid': _apiKey,
        'units': 'metric',
      },
    );

    final data = response.data ?? <String, dynamic>{};
    final dailyList = (data['daily'] as List?) ?? const <Map>[];
    return _parseOneCallDays(dailyList.cast<Map<dynamic, dynamic>>());
  }

  Future<WeatherDayModel?> fetchHistoricalDay({
    required double lat,
    required double lon,
    required DateTime date,
  }) async {
    final ts = date.millisecondsSinceEpoch ~/ 1000;
    final response = await _dio.get<Map<String, dynamic>>(
      '$_baseUrl/onecall/timemachine',
      queryParameters: {
        'lat': lat,
        'lon': lon,
        'dt': ts,
        'appid': _apiKey,
        'units': 'metric',
      },
    );

    final data = response.data ?? <String, dynamic>{};
    final current = (data['current'] as Map?) ?? const {};
    final weatherList = (current['weather'] as List?) ?? const [];
    final weather = weatherList.isNotEmpty ? weatherList.first as Map : const {};
    final main = (current['main'] as Map?) ?? const {};
    final wind = (current['wind'] as Map?) ?? const {};
    final rainMap = (current['rain'] as Map?) ?? const {};

    final rainMm = ((rainMap['1h'] ?? rainMap['3h'] ?? 0) as num).toDouble();
    final normalizedPrecipitation = (rainMm / 10).clamp(0, 1).toDouble();

    return WeatherDayModel(
      date: CalendarDateUtils.normalize(date),
      temp: (main['temp'] as num?)?.toDouble() ?? 0,
      tempMax: (main['temp_max'] as num?)?.toDouble() ?? 0,
      tempMin: (main['temp_min'] as num?)?.toDouble() ?? 0,
      feelsLike: (main['feels_like'] as num?)?.toDouble() ?? 0,
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0,
      windDeg: (wind['deg'] as num?)?.toInt() ?? 0,
      precipitationProbability: 0.0,
      precipitationAmount: normalizedPrecipitation,
      uvIndex: (current['uvi'] as num?)?.toDouble() ?? 0,
      sunrise: DateTime.fromMillisecondsSinceEpoch((current['sunrise'] as num?)?.toInt() ?? 0 * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch((current['sunset'] as num?)?.toInt() ?? 0 * 1000),
      condition: (weather['main'] as String?) ?? 'Unknown',
      iconCode: (weather['icon'] as String?) ?? '01d',
      hourlyTemperatures: <double>[0, 0, 0],
    );
  }

  List<WeatherDayModel> _parseOneCallDays(List<Map> dailyList) {
    final List<WeatherDayModel> days = <WeatherDayModel>[];
    for (final day in dailyList) {
      final dt = (day['dt'] as num?)?.toInt() ?? 0;
      final date = DateTime.fromMillisecondsSinceEpoch(dt * 1000);
      final weatherList = (day['weather'] as List?) ?? const [];
      final weather = weatherList.isNotEmpty ? weatherList.first as Map : const {};
      final temp = (day['temp'] as Map?) ?? const {};
      final rainMap = (day['rain'] as Map?) ?? const {};

      final rainMm = ((rainMap['1h'] ?? rainMap['3h'] ?? 0) as num).toDouble();
      final normalizedPrecipitation = (rainMm / 10).clamp(0, 1).toDouble();

      days.add(WeatherDayModel(
        date: CalendarDateUtils.normalize(date),
        temp: (temp['day'] as num?)?.toDouble() ?? 0,
        tempMax: (temp['max'] as num?)?.toDouble() ?? 0,
        tempMin: (temp['min'] as num?)?.toDouble() ?? 0,
        feelsLike: (temp['feels_like'] as num?)?.toDouble() ?? 0,
        humidity: (day['humidity'] as num?)?.toInt() ?? 0,
        windSpeed: (day['wind_speed'] as num?)?.toDouble() ?? 0,
        windDeg: (day['wind_deg'] as num?)?.toInt() ?? 0,
        precipitationProbability: (day['pop'] as num?)?.toDouble() ?? 0.0,
        precipitationAmount: normalizedPrecipitation,
        uvIndex: (day['uvi'] as num?)?.toDouble() ?? 0,
        sunrise: DateTime.fromMillisecondsSinceEpoch((day['sunrise'] as num?)?.toInt() ?? 0 * 1000),
        sunset: DateTime.fromMillisecondsSinceEpoch((day['sunset'] as num?)?.toInt() ?? 0 * 1000),
        condition: (weather['main'] as String?) ?? 'Unknown',
        iconCode: (weather['icon'] as String?) ?? '01d',
        hourlyTemperatures: <double>[0, 0, 0],
      ));
    }
    return days;
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
