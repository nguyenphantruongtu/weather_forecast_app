import 'package:flutter/material.dart';

class SavedLocationsProvider with ChangeNotifier {
  List<Map<String, dynamic>> _savedLocations = [];

  List<Map<String, dynamic>> get savedLocations => _savedLocations;

  void addLocation(Map<String, dynamic> location) {
    print('SavedLocationsProvider: Adding location ${location['name']}');
    if (!_savedLocations.any((item) => item['name'] == location['name'])) {
      _savedLocations.add(location);
      print('SavedLocationsProvider: Added ${location['name']}, total: ${_savedLocations.length}');
      notifyListeners();
    } else {
      print('SavedLocationsProvider: ${location['name']} already exists');
    }
  }

  void removeLocation(String locationName) {
    print('SavedLocationsProvider: Removing location $locationName');
    _savedLocations.removeWhere((item) => item['name'] == locationName);
    print('SavedLocationsProvider: Removed $locationName, total: ${_savedLocations.length}');
    notifyListeners();
  }

  bool isLocationSaved(String locationName) {
    bool isSaved = _savedLocations.any((item) => item['name'] == locationName);
    print('SavedLocationsProvider: isLocationSaved($locationName) = $isSaved');
    return isSaved;
  }

  void clearAll() {
    print('SavedLocationsProvider: Clearing all locations');
    _savedLocations.clear();
    notifyListeners();
  }
}
