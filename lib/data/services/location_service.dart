import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/location_model.dart';

class LocationService {
  Future<List<LocationModel>> searchCity(String query) async {
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
      return data.map((e) => LocationModel.fromJson(e)).toList();
    }
    return [];
  }
}