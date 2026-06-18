class PppItem {
  const PppItem({
    required this.id,
    required this.name,
    required this.type,
    required this.images,
    required this.tourismpolicy,
    required this.investmentOpportunity,
  });

  final String id;
  final String name;
  final String type; // "National" or "International"
  final List<String> images;
  final List<PppPolicy> tourismpolicy;
  final List<PppInvestment> investmentOpportunity;

  bool get isDomestic => type == 'National';

  String get firstImage => images.isNotEmpty ? images.first : '';

  factory PppItem.fromJson(Map<String, dynamic> json) => PppItem(
        id: json['_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        type: json['type'] as String? ?? '',
        images: (json['image'] as List<dynamic>?)?.cast<String>() ?? [],
        tourismpolicy: (json['tourismpolicy'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>()
                .map(PppPolicy.fromJson)
                .toList() ??
            [],
        investmentOpportunity:
            (json['investmentOpportunity'] as List<dynamic>?)
                    ?.cast<Map<String, dynamic>>()
                    .map(PppInvestment.fromJson)
                    .toList() ??
                [],
      );
}

class PppPolicy {
  const PppPolicy({required this.id, required this.name});

  final String id;
  final String name;

  factory PppPolicy.fromJson(Map<String, dynamic> json) => PppPolicy(
        id: json['_id'] as String? ?? '',
        name: json['policyName'] as String? ?? '',
      );
}

class PppInvestment {
  const PppInvestment({required this.id, required this.name});

  final String id;
  final String name;

  factory PppInvestment.fromJson(Map<String, dynamic> json) => PppInvestment(
        id: json['_id'] as String? ?? '',
        name: json['opportunityName'] as String? ?? '',
      );
}

// ── PPP Detail models ────────────────────────────────────────────────────────

class PppPolicyFull {
  const PppPolicyFull({required this.id, required this.policyName, required this.policyDetails});
  final String id;
  final String policyName;
  final String policyDetails; // HTML string

  factory PppPolicyFull.fromJson(Map<String, dynamic> json) => PppPolicyFull(
        id: json['_id'] as String? ?? '',
        policyName: json['policyName'] as String? ?? '',
        policyDetails: json['policyDetails'] as String? ?? '',
      );
}

class PppInvestFull {
  const PppInvestFull({required this.id, required this.opportunityName, required this.opportunityDetails});
  final String id;
  final String opportunityName;
  final String opportunityDetails; // HTML string

  factory PppInvestFull.fromJson(Map<String, dynamic> json) => PppInvestFull(
        id: json['_id'] as String? ?? '',
        opportunityName: json['opportunityName'] as String? ?? '',
        opportunityDetails: json['opportunityDetails'] as String? ?? '',
      );
}

class PppVideo {
  const PppVideo({required this.id, required this.title, required this.videoUrl});
  final String id;
  final String title;
  final String videoUrl; // YouTube URL

  factory PppVideo.fromJson(Map<String, dynamic> json) => PppVideo(
        id: json['_id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        videoUrl: json['video'] as String? ?? '',
      );
}

class PppImage {
  const PppImage({required this.id, required this.imageUrls});
  final String id;
  final List<String> imageUrls;

  factory PppImage.fromJson(Map<String, dynamic> json) => PppImage(
        id: json['_id'] as String? ?? '',
        imageUrls: (json['image'] as List<dynamic>?)?.cast<String>() ?? [],
      );
}

class PppPdf {
  const PppPdf({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.description,
    required this.pdfUrls,
  });
  final String id;
  final String name;
  final String thumbnail;
  final String description;
  final List<String> pdfUrls;

  factory PppPdf.fromJson(Map<String, dynamic> json) => PppPdf(
        id: json['_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        thumbnail: json['thumbnail'] as String? ?? '',
        description: json['description'] as String? ?? '',
        pdfUrls: (json['pdf'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      );
}
