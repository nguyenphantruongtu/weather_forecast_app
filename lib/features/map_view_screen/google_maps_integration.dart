import 'package:dio/dio.dart';

class AppMapLocation {
  final double latitude;
  final double longitude;
  AppMapLocation({required this.latitude, required this.longitude});
}

class GoogleMapsIntegration {
  /// Converts an address string to geographic coordinates (latitude and longitude)
  /// using the open-meteo geocoding API instead of flaky native packages.
  Future<AppMapLocation?> getLocationFromAddress(String address) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://geocoding-api.open-meteo.com/v1/search',
        queryParameters: {
          'name': address,
          'count': 1,
          'language': 'en',
          'format': 'json',
        },
      );

      final results = response.data['results'] as List<dynamic>?;
      if (results != null && results.isNotEmpty) {
        final first = results.first as Map<String, dynamic>;
        return AppMapLocation(
          latitude: (first['latitude'] as num).toDouble(),
          longitude: (first['longitude'] as num).toDouble(),
        );
      }
      
      return null;
    } catch (e) {
      print('Error geocoding address: $e');
      return null;
    }
  }
}