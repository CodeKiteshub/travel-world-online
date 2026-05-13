class ArticleCategory {
  const ArticleCategory({required this.id, required this.name});

  final String id;
  final String name;

  factory ArticleCategory.fromJson(Map<String, dynamic> json) =>
      ArticleCategory(
        id: json['_id'] as String? ?? '',
        name: json['category_name'] as String? ?? '',
      );
}

class Article {
  const Article({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.images,
    required this.addedAt,
  });

  final String id;
  final String title;
  final String author;
  final ArticleCategory category;
  final List<String> images;
  final DateTime addedAt;

  String get firstImage => images.isNotEmpty ? images.first : '';

  String get timeAgo {
    final diff = DateTime.now().difference(addedAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  String get sourceMeta => '${author.isNotEmpty ? author : 'Travel World'} · $timeAgo';

  factory Article.fromJson(Map<String, dynamic> json) => Article(
        id: json['_id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        author: json['author'] as String? ?? '',
        category: ArticleCategory.fromJson(
            json['category'] as Map<String, dynamic>? ?? {}),
        images: (json['urlToImage'] as List<dynamic>?)?.cast<String>() ?? [],
        addedAt: DateTime.tryParse(json['addedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}
