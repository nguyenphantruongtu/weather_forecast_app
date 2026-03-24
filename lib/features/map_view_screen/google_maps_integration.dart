import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import '../../data/models/location_model.dart' as app_location;

class GoogleMapsIntegration {
  
  /// Lấy vị trí hiện tại (GPS) của thiết bị
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Kiểm tra xem dịch vụ vị trí có được bật không
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null; // Người dùng từ chối cấp quyền
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null; // Quyền bị từ chối vĩnh viễn
    }

    // Lấy tọa độ hiện tại
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );
  }

  /// Chuyển đổi tọa độ (Lat, Lng) thành Địa chỉ dạng Text
  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      // Sử dụng Nominatim API để chuyển đổi tọa độ thành địa chỉ
      final String encodedParams = Uri.encodeQueryComponent('$latitude,$longitude');
      final String url = 'https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json&addressdetails=1';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data.containsKey('address')) {
          final address = data['address'];
          final String city = address['city'] ?? address['town'] ?? address['village'] ?? address['hamlet'] ?? '';
          final String country = address['country'] ?? '';
          
          if (city.isNotEmpty && country.isNotEmpty) {
            return '$city, $country';
          } else if (city.isNotEmpty) {
            return city;
          } else if (country.isNotEmpty) {
            return country;
          }
        }
      }
    } catch (e) {
      print('Error getting address from coords: $e');
    }
    return null;
  }

  /// Chuyển đổi Địa chỉ dạng Text thành tọa độ (Location Model)
  Future<app_location.Location?> getLocationFromAddress(String address) async {
    try {
      // Encode URL tham số address
      final String encodedAddress = Uri.encodeQueryComponent(address);
      
      // Gọi GET request tới Nominatim API
      final String url = 'https://nominatim.openstreetmap.org/search?q=$encodedAddress&format=json&limit=1';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // Nếu response 200 và danh sách trả về isNotEmpty
        if (data.isNotEmpty) {
          final Map<String, dynamic> locationData = data[0];
          
          // Lấy lat và lon (API này trả về lat/lon dạng String, cần parse sang double)
          final double lat = double.parse(locationData['lat']);
          final double lon = double.parse(locationData['lon']);
          
          // Trả về đối tượng AppLocation.Location với tọa độ vừa lấy được
          return app_location.Location(
            id: '${lat}_${lon}_$address',
            name: address,
            latitude: lat,
            longitude: lon,
            country: '', // Có thể tích hợp thêm Geocoding ngược ở đây để lấy Quốc gia nếu cần
            state: '',
            isFavorite: false,
          );
        }
      }
    } catch (e) {
      print('Error getting coordinates from address: $e');
    }
    // Nếu lỗi hoặc danh sách rỗng, trả về null
    return null;
  }
}