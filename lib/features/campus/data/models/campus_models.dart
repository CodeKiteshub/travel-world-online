class AdvisoryBoardMember {
  const AdvisoryBoardMember({
    required this.id,
    required this.name,
    required this.post,
    required this.about,
    required this.images,
  });

  final String id;
  final String name;
  final String post;
  final String about;
  final List<String> images;

  String get firstImage => images.isNotEmpty ? images.first : '';

  factory AdvisoryBoardMember.fromJson(Map<String, dynamic> json) =>
      AdvisoryBoardMember(
        id: json['_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        post: json['post'] as String? ?? '',
        about: json['about'] as String? ?? '',
        images:
            (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
      );
}

class SkillCourse {
  const SkillCourse({
    required this.id,
    required this.label,
    required this.description,
  });

  final String id;
  final String label;
  final String description;

  factory SkillCourse.fromJson(Map<String, dynamic> json) => SkillCourse(
        id: json['id']?.toString() ?? '',
        label: json['name'] as String? ??
            json['videocat'] as String? ??
            json['label'] as String? ??
            '',
        description: json['link'] as String? ??
            json['description'] as String? ??
            '',
      );
}

class DestinationCategory {
  const DestinationCategory({
    required this.id,
    required this.label,
    required this.description,
  });

  final String id;
  final String label;
  final String description;

  factory DestinationCategory.fromJson(Map<String, dynamic> json) =>
      DestinationCategory(
        id: json['id']?.toString() ?? '',
        label: json['videocat'] as String? ?? json['label'] as String? ?? '',
        description: json['detail'] as String? ?? json['description'] as String? ?? '',
      );
}

// ── Destination drill-down models ─────────────────────────────────────────────

class DestSubCategory {
  const DestSubCategory({required this.id, required this.label, required this.imageUrl});
  final String id;
  final String label;
  final String imageUrl;

  factory DestSubCategory.fromJson(Map<String, dynamic> json) => DestSubCategory(
        id: json['id']?.toString() ?? '',
        label: json['videosubcat'] as String? ?? json['label'] as String? ?? '',
        imageUrl: json['image'] as String? ?? '',
      );
}

class DestSubSubCategory {
  const DestSubSubCategory({required this.id, required this.label, required this.imageUrl});
  final String id;
  final String label;
  final String imageUrl;

  factory DestSubSubCategory.fromJson(Map<String, dynamic> json) => DestSubSubCategory(
        id: json['id']?.toString() ?? '',
        label: json['subsubcat'] as String? ?? json['label'] as String? ?? '',
        imageUrl: json['image'] as String? ?? '',
      );
}

class DestVideo {
  const DestVideo({
    required this.id,
    required this.heading,
    required this.imageUrl,
    required this.videoUrl,
    required this.detail,
    required this.place,
  });
  final String id;
  final String heading;
  final String imageUrl;
  final String videoUrl;
  final String detail;
  final String place;

  factory DestVideo.fromJson(Map<String, dynamic> json) => DestVideo(
        id: json['id']?.toString() ?? '',
        heading: json['heading'] as String? ?? '',
        imageUrl: json['image'] as String? ?? '',
        videoUrl: json['video'] as String? ?? '',
        detail: json['detail'] as String? ?? '',
        place: json['place'] as String? ?? '',
      );
}

// ── Skill development models ───────────────────────────────────────────────────

class CampusCourseItem {
  const CampusCourseItem({required this.id, required this.label, required this.link});
  final String id;
  final String label;
  final String link;

  factory CampusCourseItem.fromJson(Map<String, dynamic> json) => CampusCourseItem(
        id: json['id']?.toString() ?? '',
        label: json['name'] as String? ?? json['label'] as String? ?? '',
        link: json['link'] as String? ?? '',
      );
}
