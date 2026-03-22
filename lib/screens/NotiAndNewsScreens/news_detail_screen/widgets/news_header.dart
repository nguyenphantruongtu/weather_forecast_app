import 'package:flutter/material.dart';
import '../../../../data/models/news_article_model.dart';

class NewsHeader extends StatelessWidget {
  final NewsArticleModel article;

  const NewsHeader({super.key, required this.article});

  Color get _categoryColor {
    switch (article.category.toUpperCase()) {
      case 'BUSINESS':
        return const Color(0xFF1A237E);
      case 'ENTERTAINMENT':
        return const Color(0xFFD81B60);
      case 'GENERAL':
        return const Color(0xFF757575);
      case 'HEALTH':
        return const Color(0xFF2E7D32);
      case 'SCIENCE':
        return const Color(0xFF0288D1);
      case 'SPORTS':
        return const Color(0xFFEF6C00);
      case 'TECHNOLOGY':
        return const Color(0xFF616161);
      default:
        return const Color(0xFF757575);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _categoryColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            article.category,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Title
        Text(
          article.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        // Subtitle
        Text(
          article.subtitle,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF6B7AEF),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        // Author row
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF6B7AEF).withOpacity(0.2),
              child: Text(
                article.author.isNotEmpty ? article.author[0] : 'W',
                style: const TextStyle(
                  color: Color(0xFF6B7AEF),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'by ${article.author}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  Text(
                    '${article.source} • ${article.timeAgo} • ${article.readTimeMinutes} min read',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}