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
      throw Exception('Error: $e');
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
      throw Exception('Error: $e');
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

  // ... (Giữ nguyên các hàm fetchFiveDayForecast, fetchTodayWithForecast, 
  // fetchHistoricalDay và _parseOneCallDays từ branch develop của bạn) ...
  
  // Lưu ý: Hãy copy toàn bộ nội dung các hàm đó vào đây để file hoàn chỉnh.
}