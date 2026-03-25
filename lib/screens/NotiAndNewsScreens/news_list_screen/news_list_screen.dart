import 'package:flutter/material.dart';
import '../../../../data/models/news_article_model.dart';
import '../../../../data/services/news_api_service.dart';
import '../news_detail_screen/news_detail_screen.dart';
import 'widgets/category_chips.dart';
import 'widgets/news_card.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  final NewsApiService _apiService = NewsApiService();
  List<NewsArticleModel> _articles = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  final ScrollController _scrollController = ScrollController();

  static const List<String> _categories = [
    'All',
    'Business',
    'Entertainment',
    'General',
    'Health',
    'Science',
    'Sports',
    'Technology',
  ];

  static const Map<String, int> _badgeCounts = {'Breaking': 1};

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadNews({bool refresh = false}) async {
    setState(() => _isLoading = true);
    final articles = await _apiService.fetchNews(
      category: _selectedCategory,
      pageSize: 20,
    );
    setState(() {
      _articles = articles;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Color(0xFF1A1A2E)),
          onPressed: () {},
        ),
        title: const Text(
          'Top News',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadNews(refresh: true),
        color: const Color(0xFF6B7AEF),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Categories
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: CategoryChips(
                  categories: _categories,
                  selectedCategory: _selectedCategory,
                  onSelected: (cat) {
                    setState(() => _selectedCategory = cat);
                    _loadNews();
                  },
                  badgeCounts: _badgeCounts,
                ),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF6B7AEF)),
                ),
              )
            else ...[
              // Featured article
              if (_articles.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildFeaturedCard(_articles.first),
                  ),
                ),
              // Regular articles
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final article = _articles[index + 1];
                      return NewsCard(
                        article: article,
                        onTap: () => _navigateToDetail(article),
                      );
                    },
                    childCount:
                        (_articles.length - 1).clamp(0, _articles.length),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(NewsArticleModel article) {
    return GestureDetector(
      onTap: () => _navigateToDetail(article),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E).withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A1A2E).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background image
            if (article.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  article.imageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey[300],
                    ),
                    child: Center(
                      child: Icon(Icons.image_outlined, size: 48, color: Colors.grey[400]),
                    ),
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[300],
                ),
                child: Center(
                  child: Icon(Icons.image_outlined, size: 48, color: Colors.grey[400]),
                ),
              ),
            // Background image hint
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      _buildBadge('FEATURED', const Color(0xFF6B7AEF)),
                      const SizedBox(width: 8),
                      if (article.isBreaking)
                        _buildBadge('BREAKING', const Color(0xFFD32F2F)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'By ${article.source} • ${article.timeAgo}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _navigateToDetail(NewsArticleModel article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NewsDetailScreen(article: article),
      ),
    );
  }
}