class VideoItem {
  const VideoItem({
    required this.id,
    required this.title,
    required this.youtubeIds,
    required this.category,
    required this.createdAt,
  });

  final String id;
  final String title;
  final List<String> youtubeIds;
  final String category;
  final DateTime createdAt;

  String get firstVideoId => youtubeIds.isNotEmpty ? youtubeIds.first : '';

  String get thumbnailUrl => firstVideoId.isNotEmpty
      ? 'https://img.youtube.com/vi/$firstVideoId/0.jpg'
      : '';

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays >= 7) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }

  factory VideoItem.fromJson(Map<String, dynamic> json) => VideoItem(
        id: json['_id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        youtubeIds: (json['videos'] as List<dynamic>?)
                ?.whereType<String>()
                .toList() ??
            [],
        category: json['category'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}
