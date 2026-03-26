import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../data/models/news_article_model.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../utils/app_strings.dart';
import 'widgets/news_header.dart';
import 'widgets/share_button.dart';

class NewsDetailScreen extends StatefulWidget {
  final NewsArticleModel article;

  const NewsDetailScreen({super.key, required this.article});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  double _fontSize = 15.0;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final languageCode = settings.language;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(
          slivers: [
            // App bar with image
            SliverAppBar(
              backgroundColor:
                  Theme.of(context).scaffoldBackgroundColor,
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
                  color: isDarkMode ? const Color(0xFF16213E) : Colors.white,
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
                          _buildAction(Icons.share_outlined, AppStrings.tr(languageCode, en: 'Share', vi: 'Chia se'), isDarkMode, () => _shareArticle()),
                          _buildAction(Icons.open_in_browser, AppStrings.tr(languageCode, en: 'Open', vi: 'Mo'), isDarkMode, _openArticleUrl),
                          _buildAction(Icons.text_fields, AppStrings.tr(languageCode, en: 'Size', vi: 'Co chu'), isDarkMode, _changeSize),
                          _buildAction(
                            isDarkMode
                                ? Icons.light_mode_outlined
                                : Icons.dark_mode_outlined,
                            AppStrings.tr(languageCode, en: 'Theme', vi: 'Giao dien'),
                            isDarkMode,
                            () {},
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
                        color: isDarkMode
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
      );
  }

  Widget _buildAction(IconData icon, String label, bool isDarkMode, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 22,
            color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
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
        if (!mounted) return;
        // Fallback: show snackbar or something
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.tr(context.read<SettingsProvider>().settings.language, en: 'Unable to open article link', vi: 'Khong the mo lien ket bai viet'))),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.tr(context.read<SettingsProvider>().settings.language, en: 'Article link not available', vi: 'Lien ket bai viet khong kha dung'))),
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
      final languageCode = context.read<SettingsProvider>().settings.language;
      return AppStrings.tr(
        languageCode,
        en: 'Content not available. Please use the "Open" button to read the full article.',
        vi: 'Noi dung khong kha dung. Vui long dung nut "Mo" de doc day du bai viet.',
      );
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
}