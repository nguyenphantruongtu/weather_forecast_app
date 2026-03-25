import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../data/models/news_article_model.dart';
import 'widgets/news_header.dart';
import 'widgets/share_button.dart';

class NewsDetailScreen extends StatefulWidget {
  final NewsArticleModel article;

  const NewsDetailScreen({super.key, required this.article});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  bool _isDarkMode = false;
  double _fontSize = 15.0;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode
          ? ThemeData.dark().copyWith(
              scaffoldBackgroundColor: const Color(0xFF1A1A2E),
            )
          : ThemeData.light(),
      child: Scaffold(
        backgroundColor:
            _isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFF7F8FA),
        body: CustomScrollView(
          slivers: [
            // App bar with image
            SliverAppBar(
              backgroundColor:
                  _isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
              expandedHeight: 220,
              pinned: true,
              leading: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      size: 18, color: Color(0xFF1A1A2E)),
                ),
              ),
              actions: [
                ShareButton(onShare: () => _shareArticle()),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image background
                    if (widget.article.imageUrl != null)
                      Image.network(
                        widget.article.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF2C3E50),
                                const Color(0xFF4A5568),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 64,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF2C3E50),
                              const Color(0xFF4A5568),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 64,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                    // Photo credit
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Photo by NASA',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                    // Zoom button
                    Positioned(
                      top: 80,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.zoom_in,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _isDarkMode ? const Color(0xFF16213E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NewsHeader(article: widget.article),
                    const SizedBox(height: 16),
                    // Action bar (Share, Open, Size, Dark)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey.withOpacity(0.2)),
                          bottom:
                              BorderSide(color: Colors.grey.withOpacity(0.2)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildAction(Icons.share_outlined, 'Share', () => _shareArticle()),
                          _buildAction(Icons.open_in_browser, 'Open', _openArticleUrl),
                          _buildAction(Icons.text_fields, 'Size', _changeSize),
                          _buildAction(
                            _isDarkMode
                                ? Icons.light_mode_outlined
                                : Icons.dark_mode_outlined,
                            'Dark',
                            () => setState(() => _isDarkMode = !_isDarkMode),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Article content
                    Text(
                      _getDisplayContent(),
                      style: TextStyle(
                        fontSize: _fontSize,
                        height: 1.7,
                        color: _isDarkMode
                            ? Colors.grey[300]
                            : const Color(0xFF444444),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 22,
            color: _isDarkMode ? Colors.grey[300] : Colors.grey[600],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: _isDarkMode ? Colors.grey[400] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _shareArticle() {
    final url = widget.article.url ?? 'https://newsapi.org';
    Share.share('Check out this article: ${widget.article.title}\n$url');
  }

  void _openArticleUrl() async {
    final url = widget.article.url;
    if (url != null && url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: show snackbar or something
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open article link')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article link not available')),
      );
    }
  }

  String _getDisplayContent() {
    if (widget.article.content.isNotEmpty) {
      // Remove the "[+X chars]" suffix and trailing "..." if present
      String content = widget.article.content.replaceAll(RegExp(r'\s*\[\+\d+\s*chars\]$'), '');
      content = content.replaceAll(RegExp(r'\.\.\.\s*$'), '');
      return content.trim();
    } else {
      return 'Content not available. Please use the "Open" button to read the full article.';
    }
  }

  void _changeSize() {
    setState(() {
      if (_fontSize >= 20) {
        _fontSize = 13;
      } else {
        _fontSize += 2;
      }
    });
  }

  String _generateLoremContent() {
    return '''A record-breaking heat wave is sweeping across Southeast Asia, with temperatures exceeding 45°C in multiple countries. Meteorologists warn this could be the worst heat event in decades, affecting millions of people across the region.

The heat wave, which began last week, has already broken temperature records in Thailand, Vietnam, Cambodia, and Myanmar. Weather experts attribute this extreme event to a combination of climate change and a particularly strong El Niño pattern this year.

In Vietnam, the Central Highlands region recorded its highest-ever temperature of 44.2°C, while Hanoi experienced three consecutive days above 41°C. The Vietnamese Meteorological and Hydrological Administration has issued emergency warnings for 15 provinces.

Health authorities across the region have reported a significant increase in heat-related illnesses, with hospitals seeing a 40% surge in emergency admissions. Vulnerable populations, including the elderly and outdoor workers, are at the greatest risk.

"This is unprecedented in our recorded history," said Dr. Nguyen Minh Tuan, a climate scientist at Vietnam National University. "The combination of high temperatures and humidity is creating conditions that are genuinely dangerous for human health."

Governments are responding with emergency measures, including the opening of cooling centers in urban areas, restrictions on outdoor work during peak heat hours (10 AM to 4 PM), and increased distribution of water to vulnerable communities.

The heat wave is expected to continue for at least another week before monsoon moisture begins to provide relief. Climate scientists warn that such extreme events are likely to become more frequent and intense as global temperatures continue to rise.''';
  }
}