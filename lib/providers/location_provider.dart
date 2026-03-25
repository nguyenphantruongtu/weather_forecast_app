import 'package:flutter/foundation.dart';
import '../../data/models/location_model.dart' as AppLocation;

class LocationProvider with ChangeNotifier {
  AppLocation.Location? _selectedCity;
  List<AppLocation.Location> _favoriteLocations = [];
  Map<String, dynamic>? _currentWeather;

  AppLocation.Location? get selectedCity => _selectedCity;
  List<AppLocation.Location> get favoriteLocations => _favoriteLocations;
  Map<String, dynamic>? get currentWeather => _currentWeather;

  void setSelectedCity(AppLocation.Location? city) {
    _selectedCity = city;
    notifyListeners();
  }

  bool isFavorite(AppLocation.Location location) {
    return _favoriteLocations.any((fav) => fav.id == location.id);
  }

  void toggleFavorite(AppLocation.Location location) {
    final isCurrentlyFavorite = isFavorite(location);
    
    if (isCurrentlyFavorite) {
      _favoriteLocations.removeWhere((fav) => fav.id == location.id);
    } else {
      _favoriteLocations.add(location);
    }
    
    notifyListeners();
  }

  void addFavorite(AppLocation.Location location) {
    if (!isFavorite(location)) {
      _favoriteLocations.add(location);
      notifyListeners();
    }
  }

  void removeFavorite(AppLocation.Location location) {
    _favoriteLocations.removeWhere((fav) => fav.id == location.id);
    notifyListeners();
  }

  // Method to fetch weather data (placeholder implementation)
  // This would typically make an API call to get weather data
  Future<void> fetchWeather(double latitude, double longitude) async {
    // This is a placeholder - in a real implementation, you would:
    // 1. Make an API call to get weather data
    // 2. Parse the response
    // 3. Store it in _currentWeather
    // 4. Call notifyListeners()
    
    // For now, we'll simulate some weather data
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    _currentWeather = {
      'main': {
        'temp': 25.5,
        'humidity': 65,
      },
      'wind': {
        'speed': 3.2,
      },
      'weather': [
        {'description': 'Clear sky'}
      ]
    };
    
    notifyListeners();
  }
}
