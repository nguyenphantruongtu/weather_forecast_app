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

  Future<List<NewsArticleModel>> fetchNews({
    String category = 'All',
    int page = 1,
    int pageSize = 20,
    String country = 'us',
  }) async {
    try {
      final params = {
        'country': country,
        'page': page,
        'pageSize': pageSize,
        'apiKey': _apiKey,
      };

      if (category.toLowerCase() != 'all') {
        params['category'] = category.toLowerCase();
      }

      final response = await _dio.get(
        '/top-headlines',
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final articles = response.data['articles'] as List;
        return articles
            .map((json) => NewsArticleModel.fromJson({
                  ...json,
                  'id': json['url'] ?? DateTime.now().toString(),
                  'category': _formatCategoryForArticle(category),
                }))
            .toList();
      }
      return _getMockArticles();
    } catch (e) {
      return _getMockArticles();
    }
  }

  String _formatCategoryForArticle(String category) {
    final normalized = category.trim().toLowerCase();
    if (normalized == 'all') return 'GENERAL';
    return normalized.toUpperCase();
  }

  // Mock data for development/fallback
  List<NewsArticleModel> _getMockArticles() {
    final now = DateTime.now();
    return [
      NewsArticleModel(
        id: '1',
        title: 'Record-Breaking Heat Wave Sweeps Across Southeast Asia',
        subtitle: 'Temperatures exceed 45°C in multiple countries as the region faces unprecedented heat',
        content: 'A record-breaking heat wave is sweeping across Southeast Asia, with temperatures exceeding 45°C in multiple countries. Meteorologists warn this could be the worst heat event in decades, affecting millions of people across the region.\n\nThe heat wave, which began last week, has already broken temperature records in Thailand, Vietnam, Cambodia, and Myanmar. Weather experts attribute this extreme event to a combination of climate change and a particularly strong El Niño pattern this year.\n\nIn Vietnam, the Central Highlands region recorded its highest-ever temperature of 44.2°C, while Hanoi experienced three consecutive days above 41°C. The Vietnamese Meteorological and Hydrological Administration has issued emergency warnings for 15 provinces.\n\nHealth authorities across the region have reported a significant increase in heat-related illnesses, with hospitals seeing a 40% surge in emergency admissions. Vulnerable populations, including the elderly and outdoor workers, are at the greatest risk.\n\n"This is unprecedented in our recorded history," said Dr. Nguyen Minh Tuan, a climate scientist at Vietnam National University. "The combination of high temperatures and humidity is creating conditions that are genuinely dangerous for human health."',
        category: 'BREAKING',
        source: 'The Weather Channel',
        author: 'Sarah Johnson',
        imageUrl: null,
        url: 'https://example.com/heat-wave-article',
        publishedAt: now.subtract(const Duration(hours: 2)),
        readTimeMinutes: 5,
        isFeatured: true,
        isBreaking: true,
      ),
      NewsArticleModel(
        id: '2',
        title: 'Tropical Storm Formation Expected in Pacific',
        subtitle: 'Meteorologists track developing system that could strengthen rapidly',
        content: 'A new tropical disturbance in the Pacific Ocean is showing signs of organization, with meteorologists warning it could develop into a tropical storm within the next 48 hours. The system, currently designated as Invest 92W, is located approximately 800 miles east-southeast of Guam and is moving westward at about 15 mph.\n\nSatellite imagery shows that the disturbance has developed a well-defined center of circulation, and upper-level outflow is becoming established. Environmental conditions are favorable for further development, with warm sea surface temperatures and low wind shear.\n\nThe Joint Typhoon Warning Center is giving this system a high chance of becoming a tropical depression within the next 24 hours, and a 70% chance of reaching tropical storm strength by Friday. If it continues on its current track, it could affect the Mariana Islands later this week.',
        category: 'STORMS',
        source: 'Global Weather Network',
        author: 'Michael Chen',
        imageUrl: null,
        url: 'https://example.com/tropical-storm-article',
        publishedAt: now.subtract(const Duration(hours: 5)),
        readTimeMinutes: 4,
      ),
      NewsArticleModel(
        id: '3',
        title: 'Scientists Report Alarming Ice Melt Rates in Arctic',
        subtitle: 'New data shows acceleration in polar ice loss exceeding previous models',
        content: 'Scientists have published new data showing that arctic ice is melting at rates far exceeding previous climate models. The latest measurements from the National Snow and Ice Data Center indicate that Arctic sea ice extent has reached its annual minimum earlier than expected, with ice coverage 20% below the 1981-2010 average.\n\n"This acceleration is alarming and suggests that our climate models may be underestimating the rate of ice loss," said Dr. Mark Serreze, director of the NSIDC. "We are seeing changes that are happening much faster than anticipated."',
        category: 'CLIMATE',
        source: 'Climate Science Today',
        author: 'Dr. Emily Watson',
        imageUrl: null,
        url: 'https://example.com/arctic-ice-article',
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