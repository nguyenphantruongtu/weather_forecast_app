import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../data/models/location_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationProvider with ChangeNotifier {
  List<Location> _searchResults = [];
  final List<String> _recentSearches = []; // Lịch sử tìm kiếm
  final List<Location> _savedLocations = [];
  final List<Location> _compareList = [];
  Map<String, dynamic>? _currentWeather;
  bool _isLoading = false;
  Location? _selectedCity; // Thành phố đang được chọn

  // Getters
  List<Location> get searchResults => _searchResults;
  List<String> get recentSearches => _recentSearches;
  List<Location> get savedLocations => _savedLocations;
  List<Location> get compareList => _compareList;
  Map<String, dynamic>? get currentWeather => _currentWeather;
  bool get isLoading => _isLoading;
  Location? get selectedCity => _selectedCity;

  // 1. Tìm kiếm thành phố (Chỉ lưu vào lịch sử khi có query thực sự)
  Future<void> searchCity(String query) async {
    if (query.isEmpty) return;
    
    _isLoading = true;
    _searchResults = []; // Xóa kết quả cũ để hiện loading
    notifyListeners();

    // Thêm vào lịch sử tìm kiếm (Recent) - CHỈ KHI CÓ QUERY THỰC SỰ
    _addToRecent(query);

    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
    final url = 'http://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        _searchResults = data.map((e) => _mapToLocation(e)).toList();
      }
    } catch (e) {
      print("Lỗi kết nối: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // 1.1 Tìm kiếm thành phố mà KHÔNG lưu vào lịch sử (dành cho real-time search)
  Future<void> searchCityWithoutHistory(String query) async {
    if (query.isEmpty) return;
    
    _isLoading = true;
    _searchResults = []; // Xóa kết quả cũ để hiện loading
    notifyListeners();

    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
    final url = 'http://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        _searchResults = data.map((e) => _mapToLocation(e)).toList();
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

  // 2.1. Lấy thời tiết chi tiết và trả về dữ liệu (Dùng cho so sánh)
  Future<Map<String, dynamic>?> fetchWeatherData(double lat, double lon) async {
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
    final url = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=vi';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print("Lỗi lấy thời tiết: $e");
    }
    return null;
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
  void toggleFavorite(Location loc) {
    print('LocationProvider: toggleFavorite called for ${loc.name}');
    // SỬA: Kiểm tra theo latitude & longitude thay vì id
    final exists = _savedLocations.any((e) => e.latitude == loc.latitude && e.longitude == loc.longitude);
    print('LocationProvider: exists = $exists');
    if (exists) {
      _savedLocations.removeWhere((e) => e.latitude == loc.latitude && e.longitude == loc.longitude);
      print('LocationProvider: Removed ${loc.name}, remaining: ${_savedLocations.length}');
    } else {
      _savedLocations.add(loc);
      print('LocationProvider: Added ${loc.name}, total: ${_savedLocations.length}');
    }
    notifyListeners();
  }

  // 6. Quản lý danh sách yêu thích (Favorites)
  void toggleFavoriteLocation(Location loc) {
    final exists = _savedLocations.any((e) => e.id == loc.id);
    if (exists) {
      _savedLocations.removeWhere((e) => e.id == loc.id);
    } else {
      _savedLocations.add(loc);
    }
    notifyListeners();
  }

  bool isFavorite(Location loc) {
    return _savedLocations.any((e) => e.id == loc.id);
  }

  // 5. Sắp xếp lại danh sách địa điểm đã lưu
  void reorderSavedLocations(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final Location item = _savedLocations.removeAt(oldIndex);
    _savedLocations.insert(newIndex, item);
    notifyListeners();
  }

  void toggleCompare(Location loc) {
    // Sử dụng id để kiểm tra thay vì chỉ dùng name
    final exists = _compareList.any((e) => e.id == loc.id);
    if (exists) {
      _compareList.removeWhere((e) => e.id == loc.id);
    } else if (_compareList.length < 3) {
      _compareList.add(loc);
    }
    notifyListeners();
  }


  void clearCompare() {
    _compareList.clear();
    notifyListeners();
  }

  // 7. Quản lý thành phố đang chọn (Selected City)
  void setSelectedCity(Location? city) {
    _selectedCity = city;
    notifyListeners();
  }

  List<Marker> get mapMarkers => _savedLocations.map((loc) => Marker(
    point: LatLng(loc.latitude, loc.longitude),
    width: 40,
    height: 40,
    child: const Icon(
      Icons.location_on,
      color: Colors.blue,
      size: 40,
    ),
  )).toList();
  
  Location _mapToLocation(Map<String, dynamic> data) {
    return Location(
      id: '${data['lat']}_${data['lon']}_${data['name']}_${data['country']}',
      name: data['name'] ?? '',
      latitude: data['lat']?.toDouble() ?? 0.0,
      longitude: data['lon']?.toDouble() ?? 0.0,
      country: data['country'] ?? '',
      state: data['state'],
      isFavorite: false,
    );
  }
}
