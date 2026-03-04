import 'package:dio/dio.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

class WeatherApiService {
  final String apiKey =
      'YOUR_API_KEY_HERE'; // Replace with your OpenWeatherMap API key
  final String baseUrl = 'https://api.openweathermap.org/data/2.5';
  final Dio dio = Dio();

  Future<WeatherModel> getCurrentWeather(String city) async {
    try {
      final response = await dio.get(
        '$baseUrl/weather',
        queryParameters: {'q': city, 'appid': apiKey, 'units': 'metric'},
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
      final response = await dio.get(
        '$baseUrl/forecast',
        queryParameters: {'q': city, 'appid': apiKey, 'units': 'metric'},
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

  Future<List<ForecastModel>> getDailyForecast(String city) async {
    try {
      final response = await dio.get(
        '$baseUrl/forecast',
        queryParameters: {
          'q': city,
          'appid': apiKey,
          'units': 'metric',
          'cnt': 40, // 5 days * 8 (3-hour intervals)
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> list = response.data['list'] as List<dynamic>;
        List<ForecastModel> forecasts = list
            .map((item) => ForecastModel.fromJson(item as Map<String, dynamic>))
            .toList();

        // Filter to get daily forecasts (one per day at noon)
        List<ForecastModel> dailyForecasts = [];
        for (var forecast in forecasts) {
          if (forecast.dt.contains('12:00:00')) {
            dailyForecasts.add(forecast);
          }
        }
        return dailyForecasts;
      } else {
        throw Exception('Failed to load daily forecast');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<WeatherModel> getWeatherByCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await dio.get(
        '$baseUrl/weather',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'appid': apiKey,
          'units': 'metric',
        },
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
}
