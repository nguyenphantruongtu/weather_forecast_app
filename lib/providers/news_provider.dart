import 'package:flutter/foundation.dart';
import '../data/models/news_article_model.dart';
import '../data/services/news_api_service.dart';

class NewsProvider extends ChangeNotifier {
  final NewsApiService _apiService;

  List<NewsArticleModel> _articles = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'All News';
  int _currentPage = 1;
  bool _hasMore = true;

  static const List<String> categories = [
    'All News',
    'Breaking',
    'Climate',
    'Storms',
    'Local',
  ];

  NewsProvider({NewsApiService? apiService})
      : _apiService = apiService ?? NewsApiService();

  List<NewsArticleModel> get articles => _articles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  bool get hasMore => _hasMore;

  NewsArticleModel? get featuredArticle =>
      _articles.firstWhere((a) => a.isFeatured, orElse: () => _articles.isNotEmpty ? _articles.first : throw StateError('No articles'));

  Future<void> loadNews({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newArticles = await _apiService.fetchWeatherNews(
        category: _selectedCategory,
        page: _currentPage,
      );

      if (refresh) {
        _articles = newArticles;
      } else {
        _articles.addAll(newArticles);
      }

      if (newArticles.length < 20) _hasMore = false;
      _currentPage++;
    } catch (e) {
      _error = 'Failed to load news. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
    loadNews(refresh: true);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}