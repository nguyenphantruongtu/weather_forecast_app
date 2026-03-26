import 'package:dio/dio.dart';

import '../models/weather_day_model.dart' as app_weather;
import '../models/weather_history_model.dart';
import '../../screens/sv5_screens/calendar_screen/models/weather_day_model.dart';
import '../../screens/sv5_screens/calendar_screen/utils/date_utils.dart';

class WeatherApiService {
  WeatherApiService({
    required Dio dio,
    required String apiKey,
    String baseUrl = 'https://api.openweathermap.org/data/2.5',
  }) : _dio = dio,
       _apiKey = apiKey,
       _baseUrl = baseUrl;

  final Dio _dio;
  final String _apiKey;
  final String _baseUrl;

  /// API cần gọi để lấy current weather (dùng để save snapshot hằng ngày):
  /// GET /weather?lat={lat}&lon={lon}&appid={apiKey}&units=metric
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
    final weather = weatherList.isNotEmpty
        ? weatherList.first as Map
        : const {};
    final main = (data['main'] as Map?) ?? const {};
    final wind = (data['wind'] as Map?) ?? const {};
    final rainMap = (data['rain'] as Map?) ?? const {};

    // OpenWeather trả mm/1h hoặc mm/3h, map về 0.0-1.0 để hiển thị probability tương đối.
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

  /// 5 Day / 3 Hour Forecast (free tier). Gộp theo ngày thành `List<WeatherDayModel>`.
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

  /// Hôm nay (current) + tối đa 5 ngày dự báo (forecast API free). One Call thử nếu có.
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
        final fromOneCall = _parseOneCallDays(response.data ?? <String, dynamic>{});
        if (fromOneCall.isNotEmpty) return fromOneCall;
      } catch (_) { /* One Call không khả dụng (free tier) → dùng current + forecast */ }

      try {
        final forecastDays = await fetchFiveDayForecast(lat: lat, lon: lon);
        if (forecastDays.isEmpty) return [today];
        final todayKey = CalendarDateUtils.dayKey(now);
        final combined = <WeatherDayModel>[];
        combined.add(today);
        for (final day in forecastDays) {
          if (CalendarDateUtils.dayKey(day.date) == todayKey) continue;
          combined.add(day);
        }
        combined.sort((a, b) => a.date.compareTo(b.date));
        return combined;
      } catch (_) {
        return [today];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<WeatherDayModel?> fetchHistoricalDay({
    required double lat,
    required double lon,
    required DateTime date,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/onecall/timemachine',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'dt': date.millisecondsSinceEpoch ~/ 1000,
          'appid': _apiKey,
          'units': 'metric',
        },
      );

      final data = response.data ?? <String, dynamic>{};
      final hourly = (data['hourly'] as List?) ?? const [];
      if (hourly.isEmpty) return null;

      final first = Map<String, dynamic>.from(hourly.first as Map);
      final weatherItem = ((first['weather'] as List?) ?? const []).isNotEmpty
          ? Map<String, dynamic>.from((first['weather'] as List).first as Map)
          : <String, dynamic>{};
      final hourlyTemps = hourly
          .map(
            (e) =>
                (Map<String, dynamic>.from(e as Map)['temp'] as num?)
                    ?.toDouble() ??
                0,
          )
          .toList()
          .cast<double>();

      final maxTemp = hourlyTemps.isEmpty
          ? 0.0
          : hourlyTemps.reduce((a, b) => a > b ? a : b);
      final minTemp = hourlyTemps.isEmpty
          ? 0.0
          : hourlyTemps.reduce((a, b) => a < b ? a : b);
      final rain = (first['rain'] as num?)?.toDouble() ?? 0;

      return WeatherDayModel(
        date: CalendarDateUtils.normalize(date),
        temp: (first['temp'] as num?)?.toDouble() ?? (maxTemp + minTemp) / 2,
        tempMax: maxTemp,
        tempMin: minTemp,
        feelsLike: (first['feels_like'] as num?)?.toDouble() ?? maxTemp,
        humidity: (first['humidity'] as num?)?.toInt() ?? 0,
        windSpeed: (first['wind_speed'] as num?)?.toDouble() ?? 0,
        windDeg: (first['wind_deg'] as num?)?.toInt() ?? 0,
        precipitationProbability:
            ((first['pop'] as num?)?.toDouble() ?? (rain > 0 ? 0.5 : 0)).clamp(
              0.0,
              1.0,
            ),
        precipitationAmount: rain,
        uvIndex: (first['uvi'] as num?)?.toDouble() ?? 0,
        sunrise: DateTime.fromMillisecondsSinceEpoch(
          ((first['sunrise'] as num?)?.toInt() ?? 0) * 1000,
        ),
        sunset: DateTime.fromMillisecondsSinceEpoch(
          ((first['sunset'] as num?)?.toInt() ?? 0) * 1000,
        ),
        condition: (weatherItem['main'] as String?) ?? 'Unknown',
        iconCode: (weatherItem['icon'] as String?) ?? '01d',
        hourlyTemperatures: hourlyTemps.isEmpty
            ? <double>[0, 0, 0]
            : hourlyTemps,
      );
    } catch (_) {
      return null;
    }
  }

  List<WeatherDayModel> _parseOneCallDays(Map<String, dynamic> data) {
    final current = Map<String, dynamic>.from(
      (data['current'] as Map?) ?? const {},
    );
    final currentWeather =
        ((current['weather'] as List?) ?? const []).isNotEmpty
        ? Map<String, dynamic>.from((current['weather'] as List).first as Map)
        : <String, dynamic>{};
    final hourly = (data['hourly'] as List?) ?? const [];
    final daily = (data['daily'] as List?) ?? const [];

    final now = DateTime.now();
    final dailyList = <WeatherDayModel>[
      WeatherDayModel(
        date: CalendarDateUtils.normalize(now),
        temp: (current['temp'] as num?)?.toDouble() ?? 0,
        tempMax: (current['temp'] as num?)?.toDouble() ?? 0,
        tempMin: (current['temp'] as num?)?.toDouble() ?? 0,
        feelsLike: (current['feels_like'] as num?)?.toDouble() ?? 0,
        humidity: (current['humidity'] as num?)?.toInt() ?? 0,
        windSpeed: (current['wind_speed'] as num?)?.toDouble() ?? 0,
        windDeg: (current['wind_deg'] as num?)?.toInt() ?? 0,
        precipitationProbability: (current['pop'] as num?)?.toDouble() ?? 0,
        precipitationAmount: (current['rain'] as num?)?.toDouble() ?? 0,
        uvIndex: (current['uvi'] as num?)?.toDouble() ?? 0,
        sunrise: DateTime.fromMillisecondsSinceEpoch(
          ((current['sunrise'] as num?)?.toInt() ?? 0) * 1000,
        ),
        sunset: DateTime.fromMillisecondsSinceEpoch(
          ((current['sunset'] as num?)?.toInt() ?? 0) * 1000,
        ),
        condition: (currentWeather['main'] as String?) ?? 'Unknown',
        iconCode: (currentWeather['icon'] as String?) ?? '01d',
        hourlyTemperatures: hourly
            .take(24)
            .map(
              (e) =>
                  (Map<String, dynamic>.from(e as Map)['temp'] as num?)
                      ?.toDouble() ??
                  0,
            )
            .toList(),
      ),
    ];

    for (final raw in daily.take(7)) {
      final day = Map<String, dynamic>.from(raw as Map);
      final weather = ((day['weather'] as List?) ?? const []).isNotEmpty
          ? Map<String, dynamic>.from((day['weather'] as List).first as Map)
          : <String, dynamic>{};
      final temp = Map<String, dynamic>.from((day['temp'] as Map?) ?? const {});
      final dt = DateTime.fromMillisecondsSinceEpoch(
        ((day['dt'] as num?)?.toInt() ?? 0) * 1000,
      );
      dailyList.add(
        WeatherDayModel(
          date: CalendarDateUtils.normalize(dt),
          temp: (temp['day'] as num?)?.toDouble() ?? 0,
          tempMax: (temp['max'] as num?)?.toDouble() ?? 0,
          tempMin: (temp['min'] as num?)?.toDouble() ?? 0,
          feelsLike:
              ((day['feels_like'] as Map?)?['day'] as num?)?.toDouble() ??
              ((temp['day'] as num?)?.toDouble() ?? 0),
          humidity: (day['humidity'] as num?)?.toInt() ?? 0,
          windSpeed: (day['wind_speed'] as num?)?.toDouble() ?? 0,
          windDeg: (day['wind_deg'] as num?)?.toInt() ?? 0,
          precipitationProbability: (day['pop'] as num?)?.toDouble() ?? 0,
          precipitationAmount: (day['rain'] as num?)?.toDouble() ?? 0,
          uvIndex: (day['uvi'] as num?)?.toDouble() ?? 0,
          sunrise: DateTime.fromMillisecondsSinceEpoch(
            ((day['sunrise'] as num?)?.toInt() ?? 0) * 1000,
          ),
          sunset: DateTime.fromMillisecondsSinceEpoch(
            ((day['sunset'] as num?)?.toInt() ?? 0) * 1000,
          ),
          condition: (weather['main'] as String?) ?? 'Unknown',
          iconCode: (weather['icon'] as String?) ?? '01d',
          hourlyTemperatures: List<double>.filled(
            24,
            (temp['day'] as num?)?.toDouble() ?? 0,
          ),
        ),
      );
    }

    return dailyList;
  }

  // --- App screens (WeatherDay model in lib/data/models) ---

  /// Raw One Call 2.5 response (may 401 on free keys — caller should fall back).
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

  /// Raw 5-day / 3-hour forecast JSON.
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

  static DateTime _dateOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  /// Merges One Call daily (when available) with `/forecast` aggregates.
  Future<Map<DateTime, app_weather.WeatherDay>> fetchAppWeatherDays({
    required double lat,
    required double lon,
  }) async {
    final result = <DateTime, app_weather.WeatherDay>{};

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
}
