class JobPost {
  const JobPost({
    required this.id,
    required this.jobTitle,
    required this.companyName,
    required this.location,
    required this.jobDescription,
    required this.createdAt,
  });

  final String id;
  final String jobTitle;
  final String companyName;
  final String location;
  final String jobDescription;
  final DateTime createdAt;

  String get companyLocation =>
      location.isNotEmpty ? '$companyName · $location' : companyName;

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays >= 7) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }

  factory JobPost.fromJson(Map<String, dynamic> json) => JobPost(
        id: json['_id'] as String? ?? '',
        jobTitle: json['jobTitle'] as String? ?? '',
        companyName: json['companyName'] as String? ?? '',
        location: json['location'] as String? ?? '',
        jobDescription: json['jobDescription'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}
