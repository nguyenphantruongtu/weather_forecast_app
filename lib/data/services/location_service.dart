import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/location_model.dart';

class LocationService {
  Future<List<Location>> searchCity(String query) async {
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
    
    // Xử lý đặc biệt cho các mã quốc gia phổ biến
    String processedQuery = query;
    if (query.toLowerCase().trim() == 'usa' || 
        query.toLowerCase().trim() == 'us' || 
        query.toLowerCase().trim() == 'america') {
      processedQuery = 'United States';
    }
    
    final url = 'http://api.openweathermap.org/geo/1.0/direct?q=$processedQuery&limit=5&appid=$apiKey';
    
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((e) => _mapToLocation(e)).toList();
    }
    return [];
  }

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
