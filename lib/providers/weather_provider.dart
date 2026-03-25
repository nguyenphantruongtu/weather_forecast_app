import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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

  Future<void> fetchCurrentLocationWeather() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _error = 'Location services are disabled';
        notifyListeners();
        return;
      }

      // Check and request permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _error = 'Location permission denied';
        notifyListeners();
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Fetch weather for current location
      _currentWeather = await _apiService.getWeatherByCoordinates(
        position.latitude,
        position.longitude,
      );
      notifyListeners();
    } catch (e) {
      _error = 'Failed to get current location weather: $e';
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
