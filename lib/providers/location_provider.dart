import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../data/models/location_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationProvider with ChangeNotifier {
  List<LocationModel> _searchResults = [];
  final List<String> _recentSearches = []; // Lịch sử tìm kiếm
  final List<LocationModel> _savedLocations = [];
  final List<LocationModel> _compareList = [];
  Map<String, dynamic>? _currentWeather;
  bool _isLoading = false;

  // Getters
  List<LocationModel> get searchResults => _searchResults;
  List<String> get recentSearches => _recentSearches;
  List<LocationModel> get savedLocations => _savedLocations;
  List<LocationModel> get compareList => _compareList;
  Map<String, dynamic>? get currentWeather => _currentWeather;
  bool get isLoading => _isLoading;

  // 1. Tìm kiếm thành phố
  Future<void> searchCity(String query) async {
    if (query.isEmpty) return;
    
    _isLoading = true;
    _searchResults = []; // Xóa kết quả cũ để hiện loading
    notifyListeners();

    // Thêm vào lịch sử tìm kiếm (Recent)
    _addToRecent(query);

    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
    final url = 'http://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        _searchResults = data.map((e) => LocationModel.fromJson(e)).toList();
      }
    } catch (e) {
      print("Lỗi kết nối: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // 2. Lấy thời tiết chi tiết (Dùng cho onTap)
  Future<void> fetchWeather(double lat, double lon) async {
    _currentWeather = null;
    notifyListeners();

    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
    final url = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=vi';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        _currentWeather = json.decode(response.body);
        notifyListeners();
      }
    } catch (e) {
      print("Lỗi lấy thời tiết: $e");
    }
  }

  // 3. Quản lý Lịch sử
  void _addToRecent(String query) {
    if (!_recentSearches.contains(query)) {
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 5) _recentSearches.removeLast();
    }
  }

  void clearRecent() {
    _recentSearches.clear();
    notifyListeners();
  }

  // 4. Các hàm bổ trợ khác
  void toggleFavorite(LocationModel loc) {
    _savedLocations.any((e) => e.name == loc.name) 
      ? _savedLocations.removeWhere((e) => e.name == loc.name) 
      : _savedLocations.add(loc);
    notifyListeners();
  }

  // 5. Sắp xếp lại danh sách địa điểm đã lưu
  void reorderSavedLocations(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final LocationModel item = _savedLocations.removeAt(oldIndex);
    _savedLocations.insert(newIndex, item);
    notifyListeners();
  }

  void toggleCompare(LocationModel loc) {
    if (_compareList.any((e) => e.name == loc.name)) {
      _compareList.removeWhere((e) => e.name == loc.name);
    } else if (_compareList.length < 3) {
      _compareList.add(loc);
    }
    notifyListeners();
  }

  Set<Marker> get mapMarkers => _savedLocations.map((loc) => Marker(
    markerId: MarkerId(loc.name),
    position: LatLng(loc.lat, loc.lon),
    infoWindow: InfoWindow(title: loc.name),
  )).toSet();
}