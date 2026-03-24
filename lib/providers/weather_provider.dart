import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../data/models/weather_model.dart';
import '../data/models/forecast_model.dart';
import '../data/services/weather_api_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherApiService _apiService = WeatherApiService(
    dio: Dio(),
    apiKey: '',
  );

  WeatherModel? _currentWeather;
  List<ForecastModel> _hourlyForecast = [];
  List<ForecastModel> _dailyForecast = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  WeatherModel? get currentWeather => _currentWeather;
  List<ForecastModel> get hourlyForecast => _hourlyForecast;
  List<ForecastModel> get dailyForecast => _dailyForecast;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCurrentWeather(String city) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentWeather = await _apiService.getCurrentWeather(city);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHourlyForecast(String city) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _hourlyForecast = await _apiService.getHourlyForecast(city);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDailyForecast(String city) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dailyForecast = await _apiService.getForecast(city);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWeatherByCoordinates(
    double latitude,
    double longitude,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final weatherHistory = await _apiService.fetchCurrentWeatherSnapshot(
        lat: latitude,
        lon: longitude,
      );
      
      // Convert WeatherHistory to WeatherModel
      _currentWeather = WeatherModel(
        location: 'Current Location',
        temperature: weatherHistory.tempMax,
        description: weatherHistory.condition,
        icon: weatherHistory.icon,
        feelsLike: weatherHistory.tempMax,
        humidity: weatherHistory.humidity,
        windSpeed: weatherHistory.windSpeed,
        pressure: 1013, // Default pressure value
        visibility: 10.0, // Default visibility in km
        uvIndex: 0.0, // Default UV index
        dewPoint: weatherHistory.tempMax - 5, // Simple dew point calculation
        sunrise: DateTime.now().subtract(Duration(hours: 6)), // Default sunrise
        sunset: DateTime.now().add(Duration(hours: 6)), // Default sunset
        lastUpdated: DateTime.now(),
      );
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    _currentWeather = null;
    _hourlyForecast = [];
    _dailyForecast = [];
    _error = null;
    notifyListeners();
  }
}
