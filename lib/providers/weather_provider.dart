import 'package:flutter/material.dart';
import '../data/models/weather_model.dart';
import '../data/models/forecast_model.dart';
import '../data/services/weather_api_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherApiService _apiService = WeatherApiService();

  WeatherModel? _currentWeather;
  List<ForecastModel> _hourlyForecast = [];
  List<ForecastModel> _dailyForecast = [];
  bool _isLoading = false;
  String? _error;

  final List<WeatherModel> _compareLocations = [];

  // Getters
  WeatherModel? get currentWeather => _currentWeather;
  List<ForecastModel> get hourlyForecast => _hourlyForecast;
  List<ForecastModel> get dailyForecast => _dailyForecast;
  List<WeatherModel> get compareLocations => _compareLocations;
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
      _dailyForecast = await _apiService.getDailyForecast(city);
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
      _currentWeather = await _apiService.getWeatherByCoordinates(
        latitude,
        longitude,
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

  Future<void> addCityToCompare(String city) async {
    if (_compareLocations.any((w) => 
        w.location.toLowerCase().contains(city.toLowerCase()) || 
        city.toLowerCase().contains(w.location.toLowerCase()))) {
      return;
    }
    
    _isLoading = true;
    notifyListeners();

    try {
      final weather = await _apiService.getCurrentWeather(city);
      if (_compareLocations.length >= 2) {
        _compareLocations.removeAt(0); // keep at most 2
      }
      _compareLocations.add(weather);
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addWeatherToCompare(WeatherModel weather) {
    if (_compareLocations.any((w) => w.location == weather.location)) return;
    if (_compareLocations.length >= 2) {
      _compareLocations.removeAt(0);
    }
    _compareLocations.add(weather);
    notifyListeners();
  }

  void removeCityFromCompare(String city) {
    _compareLocations.removeWhere((w) => w.location == city);
    notifyListeners();
  }
}
