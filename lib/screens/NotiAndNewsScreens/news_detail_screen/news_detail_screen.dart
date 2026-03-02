import 'package:flutter/material.dart';
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
  bool _isBookmarked = false;
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
                GestureDetector(
                  onTap: () => setState(() => _isBookmarked = !_isBookmarked),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      size: 18,
                      color: _isBookmarked
                          ? const Color(0xFF6B7AEF)
                          : const Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                ShareButton(onShare: () {}),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(4, 8, 8, 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.more_vert,
                        size: 18, color: Color(0xFF1A1A2E)),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image background
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
                    // Action bar (Save, Share, Size, Dark, More)
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
                          _buildAction(Icons.bookmark_border, 'Save', () {}),
                          _buildAction(Icons.share_outlined, 'Share', () {}),
                          _buildAction(Icons.text_fields, 'Size', _changeSize),
                          _buildAction(
                            _isDarkMode
                                ? Icons.light_mode_outlined
                                : Icons.dark_mode_outlined,
                            'Dark',
                            () => setState(() => _isDarkMode = !_isDarkMode),
                          ),
                          _buildAction(Icons.more_horiz, 'More', () {}),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Article content
                    Text(
                      widget.article.content.isNotEmpty
                          ? widget.article.content
                          : _generateLoremContent(),
                      style: TextStyle(
                        fontSize: _fontSize,
                        height: 1.7,
                        color: _isDarkMode
                            ? Colors.grey[300]
                            : const Color(0xFF444444),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Related topics
                    Text(
                      'Related Topics',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _isDarkMode ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildTopicChip('Weather'),
                        _buildTopicChip(widget.article.category),
                        _buildTopicChip('Climate'),
                        _buildTopicChip('Vietnam'),
                        _buildTopicChip('Southeast Asia'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Bottom actions bar
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAction(Icons.bookmark_border, 'Save', () {}),
                    _buildAction(Icons.share_outlined, 'Share', () {}),
                    _buildAction(Icons.comment_outlined, 'Comment', () {}),
                    _buildAction(Icons.thumb_up_outlined, 'Helpful', () {}),
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

  Widget _buildTopicChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF6B7AEF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6B7AEF).withOpacity(0.3)),
      ),
      child: Text(
        '#$label',
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF6B7AEF),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
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