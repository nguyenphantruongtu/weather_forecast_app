import 'package:dio/dio.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

class WeatherApiService {
  final String apiKey =
      '8c1e5f04ab7603a4247f35cdabacbf31'; // Replace with your OpenWeatherMap API key
  final String baseUrl = 'https://api.openweathermap.org/data/2.5';
  final Dio dio = Dio();

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
    if (USE_MOCK_DATA) {
      await Future.delayed(Duration(milliseconds: 500));
      return _getMockForecast(city);
    }

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
