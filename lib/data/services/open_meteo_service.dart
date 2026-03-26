import 'package:dio/dio.dart';

import '../models/weather_forecast_day_model.dart';
import '../../utils/calendar_date_utils.dart';

/// Open-Meteo Historical Weather API (free, no API key).
/// https://open-meteo.com/en/docs/historical-weather-api
class OpenMeteoService {
  OpenMeteoService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  static const _baseUrl = 'https://archive-api.open-meteo.com/v1/archive';

  /// Lấy dữ liệu thời tiết theo ngày trong khoảng [startDate, endDate].
  /// Dùng cho màn Statistics (tuần / tháng / 3 tháng / năm).
  Future<List<WeatherDayModel>> fetchDailyHistory({
    required double lat,
    required double lon,
    required DateTime startDate,
    required DateTime endDate,
    String timezone = 'Asia/Ho_Chi_Minh',
  }) async {
    final start = _formatDate(startDate);
    final end = _formatDate(endDate);
    final response = await _dio.get<Map<String, dynamic>>(
      _baseUrl,
      queryParameters: {
        'latitude': lat,
        'longitude': lon,
        'start_date': start,
        'end_date': end,
        'timezone': timezone,
        'daily': [
          'weather_code',
          'temperature_2m_max',
          'temperature_2m_min',
          'temperature_2m_mean',
          'precipitation_sum',
          'wind_speed_10m_max',
          'wind_direction_10m_dominant',
          'sunrise',
          'sunset',
        ].join(','),
      },
    );

    final data = response.data ?? <String, dynamic>{};
    final daily = data['daily'] as Map<String, dynamic>?;
    if (daily == null) return [];

    final times = (daily['time'] as List<dynamic>?)?.cast<String>() ?? [];
    if (times.isEmpty) return [];

    final maxT = _toDoubleList(daily['temperature_2m_max']);
    final minT = _toDoubleList(daily['temperature_2m_min']);
    final meanT = _toDoubleList(daily['temperature_2m_mean']);
    final precip = _toDoubleList(daily['precipitation_sum']);
    final windSpeed = _toDoubleList(daily['wind_speed_10m_max']);
    final windDir = _toDoubleList(daily['wind_direction_10m_dominant']);
    final sunrise = (daily['sunrise'] as List<dynamic>?)?.cast<String>() ?? [];
    final sunset = (daily['sunset'] as List<dynamic>?)?.cast<String>() ?? [];
    final weatherCode = _toDoubleList(daily['weather_code']);

    final result = <WeatherDayModel>[];
    for (var i = 0; i < times.length; i++) {
      final date = DateTime.tryParse(times[i]);
      if (date == null) continue;

      final max = i < maxT.length ? maxT[i] : 0.0;
      final min = i < minT.length ? minT[i] : 0.0;
      final mean = i < meanT.length ? meanT[i] : (max + min) / 2;
      final code = i < weatherCode.length ? weatherCode[i].round() : 0;
      final prec = i < precip.length ? precip[i] : 0.0;
      final wind = i < windSpeed.length ? windSpeed[i] : 0.0;
      final wdir = i < windDir.length ? windDir[i].round() : 0;
      final sr = i < sunrise.length ? _parseTime(sunrise[i], date) : DateTime(date.year, date.month, date.day, 6);
      final ss = i < sunset.length ? _parseTime(sunset[i], date) : DateTime(date.year, date.month, date.day, 18);

      final (condition, iconCode) = _wmoToConditionAndIcon(code);
      result.add(
        WeatherDayModel(
          date: CalendarDateUtils.normalize(date),
          temp: mean,
          tempMax: max,
          tempMin: min,
          feelsLike: mean,
          humidity: 0,
          windSpeed: wind,
          windDeg: wdir,
          precipitationProbability: prec > 0 ? (prec / 20).clamp(0.0, 1.0) : 0.0,
          precipitationAmount: prec,
          uvIndex: 0,
          sunrise: sr,
          sunset: ss,
          condition: condition,
          iconCode: iconCode,
          hourlyTemperatures: List<double>.filled(24, mean),
        ),
      );
    }
    return result;
  }

  String _formatDate(DateTime d) {
    final y = d.year;
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  List<double> _toDoubleList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => (e is num ? e.toDouble() : 0.0)).toList();
    }
    return [];
  }

  DateTime _parseTime(String iso, DateTime date) {
    final dt = DateTime.tryParse(iso);
    if (dt != null) return dt;
    return DateTime(date.year, date.month, date.day, 12);
  }

  /// WMO Weather interpretation codes -> (condition string, OpenWeather-style iconCode).
  static (String, String) _wmoToConditionAndIcon(int code) {
    if (code == 0) return ('Clear', '01d');
    if (code <= 3) return ('Clouds', code == 1 ? '02d' : code == 2 ? '03d' : '04d');
    if (code == 45 || code == 48) return ('Mist', '50d');
    if (code >= 51 && code <= 57) return ('Drizzle', '09d');
    if (code >= 61 && code <= 67) return ('Rain', '10d');
    if (code >= 71 && code <= 77) return ('Snow', '13d');
    if (code >= 80 && code <= 82) return ('Rain', '09d');
    if (code >= 85 && code <= 86) return ('Snow', '13d');
    if (code >= 95 && code <= 99) return ('Thunderstorm', '11d');
    return ('Clouds', '04d');
  }
}
