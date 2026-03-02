class NewsArticleModel {
  final String id;
  final String title;
  final String subtitle;
  final String content;
  final String category;
  final String source;
  final String author;
  final String? authorAvatar;
  final String? imageUrl;
  final DateTime publishedAt;
  final int readTimeMinutes;
  final bool isFeatured;
  final bool isBreaking;

  const NewsArticleModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.category,
    required this.source,
    required this.author,
    this.authorAvatar,
    this.imageUrl,
    required this.publishedAt,
    required this.readTimeMinutes,
    this.isFeatured = false,
    this.isBreaking = false,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(publishedAt);
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  factory NewsArticleModel.fromJson(Map<String, dynamic> json) {
    return NewsArticleModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['description'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? 'General',
      source: json['source']?['name'] ?? '',
      author: json['author'] ?? 'Unknown',
      imageUrl: json['urlToImage'],
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      readTimeMinutes: 4,
    );
  }
}