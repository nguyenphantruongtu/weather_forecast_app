import 'package:dio/dio.dart';
import '../../../../data/models/weather_model.dart';
import '../../../../data/services/weather_api_service.dart';
import '../models/location_choice.dart';

class LocationApiService {
  static const String _geocodingBaseUrl = 'https://geocoding-api.open-meteo.com/v1';

  final Dio _dio;
  final WeatherApiService _weatherApiService;

  LocationApiService({Dio? dio, WeatherApiService? weatherApiService})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            ),
        _weatherApiService = weatherApiService ?? WeatherApiService();

  Future<LocationChoice> resolveCurrentLocation(
    double latitude,
    double longitude,
  ) async {
    final reverse = await _reverseGeocode(latitude, longitude);
    final weather = await _weatherApiService.getWeatherByCoordinatesWithLocation(
      latitude,
      longitude,
      locationName: '${reverse.city}, ${reverse.country}',
    );

    return _toLocationChoice(
      city: reverse.city,
      country: reverse.country,
      latitude: latitude,
      longitude: longitude,
      weather: weather,
    );
  }

  Future<List<LocationChoice>> searchCities(String query, {int count = 8}) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return [];

    final response = await _dio.get(
      '$_geocodingBaseUrl/search',
      queryParameters: {
        'name': normalized,
        'count': count,
        'language': 'en',
        'format': 'json',
      },
    );

    final results = response.data['results'] as List<dynamic>? ?? [];
    if (results.isEmpty) return [];

    final List<Future<LocationChoice>> tasks = [];
    for (final raw in results) {
      final item = raw as Map<String, dynamic>;
      final city = (item['name'] ?? '').toString();
      final country = (item['country'] ?? '').toString();
      final latitude = _toDouble(item['latitude']);
      final longitude = _toDouble(item['longitude']);

      tasks.add(
        _weatherApiService
            .getWeatherByCoordinatesWithLocation(
              latitude,
              longitude,
              locationName: '$city, $country',
            )
            .then(
              (weather) => _toLocationChoice(
                city: city,
                country: country,
                latitude: latitude,
                longitude: longitude,
                weather: weather,
              ),
            ),
      );
    }

    return Future.wait(tasks);
  }

  Future<List<LocationChoice>> getPopularCities() async {
    final List<_PopularSeed> seeds = const [
      _PopularSeed(city: 'Tokyo', country: 'Japan', latitude: 35.6762, longitude: 139.6503, region: 'Asia'),
      _PopularSeed(city: 'Singapore', country: 'Singapore', latitude: 1.3521, longitude: 103.8198, region: 'Asia'),
      _PopularSeed(city: 'Dubai', country: 'United Arab Emirates', latitude: 25.2048, longitude: 55.2708, region: 'Asia'),
      _PopularSeed(city: 'Sydney', country: 'Australia', latitude: -33.8688, longitude: 151.2093, region: 'Asia'),
      _PopularSeed(city: 'Barcelona', country: 'Spain', latitude: 41.3874, longitude: 2.1686, region: 'Europe'),
      _PopularSeed(city: 'London', country: 'United Kingdom', latitude: 51.5072, longitude: -0.1276, region: 'Europe'),
      _PopularSeed(city: 'Los Angeles', country: 'United States', latitude: 34.0522, longitude: -118.2437, region: 'America'),
      _PopularSeed(city: 'San Francisco', country: 'United States', latitude: 37.7749, longitude: -122.4194, region: 'America'),
      _PopularSeed(city: 'New York', country: 'United States', latitude: 40.7128, longitude: -74.0060, region: 'America'),
    ];

    final tasks = seeds.map((seed) async {
      final weather = await _weatherApiService.getWeatherByCoordinatesWithLocation(
        seed.latitude,
        seed.longitude,
        locationName: '${seed.city}, ${seed.country}',
      );

      return _toLocationChoice(
        city: seed.city,
        country: seed.country,
        latitude: seed.latitude,
        longitude: seed.longitude,
        weather: weather,
        region: seed.region,
      );
    });

    return Future.wait(tasks);
  }

  Future<_ReverseGeoResult> _reverseGeocode(double latitude, double longitude) async {
    final response = await _dio.get(
      '$_geocodingBaseUrl/reverse',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'count': 1,
        'language': 'en',
        'format': 'json',
      },
    );

    final results = response.data['results'] as List<dynamic>? ?? [];
    if (results.isEmpty) {
      return const _ReverseGeoResult(city: 'Current Location', country: 'Unknown');
    }

    final first = results.first as Map<String, dynamic>;
    final city = (first['name'] ?? 'Current Location').toString();
    final country = (first['country'] ?? 'Unknown').toString();
    return _ReverseGeoResult(city: city, country: country);
  }

  LocationChoice _toLocationChoice({
    required String city,
    required String country,
    required double latitude,
    required double longitude,
    required WeatherModel weather,
    String region = 'All',
  }) {
    final condition = _conditionLabel(weather.description);
    return LocationChoice(
      city: city,
      country: country,
      latitude: latitude,
      longitude: longitude,
      temperature: weather.temperature.round(),
      condition: condition,
      emoji: _emojiFromCondition(weather.description),
      region: region,
    );
  }

  String _conditionLabel(String source) {
    final normalized = source.trim().toLowerCase();
    if (normalized.isEmpty) return 'Unknown';
    if (normalized == 'clear') return 'Sunny';
    if (normalized == 'clouds') return 'Cloudy';
    if (normalized == 'rain') return 'Rainy';
    if (normalized == 'drizzle') return 'Drizzle';
    if (normalized == 'thunderstorm') return 'Stormy';
    if (normalized == 'mist') return 'Misty';
    return '${normalized[0].toUpperCase()}${normalized.substring(1)}';
  }

  String _emojiFromCondition(String source) {
    switch (source.trim().toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
      case 'drizzle':
        return '🌧️';
      case 'thunderstorm':
        return '⛈️';
      case 'snow':
        return '❄️';
      default:
        return '⛅';
    }
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class _ReverseGeoResult {
  final String city;
  final String country;

  const _ReverseGeoResult({required this.city, required this.country});
}

class _PopularSeed {
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final String region;

  const _PopularSeed({
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.region,
  });
}
