import 'package:dio/dio.dart';
import '../models/news_article_model.dart';

class NewsApiService {
  static const String _baseUrl = 'https://newsapi.org/v2';
  static const String _apiKey = '359073eb7b8244588772c49a252fb25d'; // Replace with actual key

  final Dio _dio;

  NewsApiService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: _baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

  Future<List<NewsArticleModel>> fetchWeatherNews({
    String category = 'all',
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      String query = 'weather';
      if (category == 'Breaking') query = 'breaking weather';
      if (category == 'Climate') query = 'climate change';
      if (category == 'Storms') query = 'storm hurricane';
      if (category == 'Local') query = 'vietnam weather';

      final response = await _dio.get(
        '/everything',
        queryParameters: {
          'q': query,
          'language': 'en',
          'sortBy': 'publishedAt',
          'page': page,
          'pageSize': pageSize,
          'apiKey': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final articles = response.data['articles'] as List;
        return articles
            .map((json) => NewsArticleModel.fromJson({
                  ...json,
                  'id': json['url'] ?? DateTime.now().toString(),
                  'category': _mapCategory(category),
                }))
            .toList();
      }
      return _getMockArticles();
    } catch (e) {
      return _getMockArticles();
    }
  }

  String _mapCategory(String filter) {
    switch (filter) {
      case 'Storms':
        return 'STORMS';
      case 'Climate':
        return 'CLIMATE';
      case 'Local':
        return 'LOCAL';
      case 'Breaking':
        return 'BREAKING';
      default:
        return 'WEATHER';
    }
  }

  // Mock data for development/fallback
  List<NewsArticleModel> _getMockArticles() {
    final now = DateTime.now();
    return [
      NewsArticleModel(
        id: '1',
        title: 'Record-Breaking Heat Wave Sweeps Across Southeast Asia',
        subtitle: 'Temperatures exceed 45°C in multiple countries as the region faces unprecedented heat',
        content: 'A record-breaking heat wave is sweeping across Southeast Asia, with temperatures exceeding 45°C in multiple countries. Meteorologists warn this could be the worst heat event in decades...',
        category: 'BREAKING',
        source: 'The Weather Channel',
        author: 'Sarah Johnson',
        imageUrl: null,
        publishedAt: now.subtract(const Duration(hours: 2)),
        readTimeMinutes: 5,
        isFeatured: true,
        isBreaking: true,
      ),
      NewsArticleModel(
        id: '2',
        title: 'Tropical Storm Formation Expected in Pacific',
        subtitle: 'Meteorologists track developing system that could strengthen rapidly',
        content: 'A new tropical disturbance in the Pacific Ocean is showing signs of organization, with meteorologists warning it could develop into a tropical storm within the next 48 hours...',
        category: 'STORMS',
        source: 'Global Weather Network',
        author: 'Michael Chen',
        imageUrl: null,
        publishedAt: now.subtract(const Duration(hours: 5)),
        readTimeMinutes: 4,
      ),
      NewsArticleModel(
        id: '3',
        title: 'Scientists Report Alarming Ice Melt Rates in Arctic',
        subtitle: 'New data shows acceleration in polar ice loss exceeding previous models',
        content: 'Scientists have published new data showing that arctic ice is melting at rates far exceeding previous climate models...',
        category: 'CLIMATE',
        source: 'Climate Science Today',
        author: 'Dr. Emily Watson',
        imageUrl: null,
        publishedAt: now.subtract(const Duration(hours: 8)),
        readTimeMinutes: 6,
      ),
      NewsArticleModel(
        id: '4',
        title: 'Hanoi Experiences Unseasonably Cool Weather',
        subtitle: 'Capital sees temperatures drop 8 degrees below seasonal average',
        content: 'Residents of Hanoi were surprised by unusually cool temperatures this week, with thermometers reading 8 degrees below the seasonal average...',
        category: 'LOCAL',
        source: 'Hanoi Daily Weather',
        author: 'Nguyen Van An',
        imageUrl: null,
        publishedAt: now.subtract(const Duration(hours: 12)),
        readTimeMinutes: 3,
      ),
    ];
  }
}