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

/// Plain text from PPP HTML bodies. Used to detect empty / placeholder CMS rows.
String stripPppHtml(String html) => html
    .replaceAll(RegExp(r'<[^>]+>'), '')
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&amp;', '&')
    .trim();

/// Legacy Investment tab pairs policy *titles* with investment *bodies* by index.
/// CMS placeholders like `<p>admin</p>` must not hide that body.
String pppPairedHtml({
  required String title,
  required String primaryHtml,
  String? pairedHtml,
}) {
  if (pairedHtml == null || pairedHtml.trim().isEmpty) return primaryHtml;
  final text = stripPppHtml(primaryHtml);
  final isPlaceholder =
      text.isEmpty || text.toLowerCase() == title.trim().toLowerCase();
  return isPlaceholder ? pairedHtml : primaryHtml;
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
  final String videoUrl; // bare YouTube video ID or full URL

  /// Bare YouTube ID, or parsed from a watch / youtu.be / embed / shorts URL.
  String get youtubeVideoId {
    final v = videoUrl.trim();
    if (v.isEmpty) return '';
    if (!v.startsWith('http')) return v.split('?').first;

    final uri = Uri.tryParse(v);
    if (uri == null) return '';

    final fromQuery = uri.queryParameters['v'];
    if (fromQuery != null && fromQuery.isNotEmpty) return fromQuery;

    if (uri.host.contains('youtu.be') && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.first;
    }

    for (final marker in const ['embed', 'shorts', 'v']) {
      final i = uri.pathSegments.indexOf(marker);
      if (i >= 0 && i + 1 < uri.pathSegments.length) {
        return uri.pathSegments[i + 1];
      }
    }
    return '';
  }

  /// The API's `video` field usually holds a bare YouTube ID (e.g.
  /// "mwDQ_fxzD5E"); occasionally a full URL. Normalise to a launchable URL.
  String get youtubeUrl {
    final id = youtubeVideoId;
    if (id.isEmpty) return '';
    return 'https://www.youtube.com/watch?v=$id';
  }

  String get thumbnailUrl {
    final id = youtubeVideoId;
    if (id.isEmpty) return '';
    return 'https://img.youtube.com/vi/$id/0.jpg';
  }

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

// ── Directory / Stakeholder models ────────────────────────────────────────────

class PppStakeholder {
  const PppStakeholder({
    required this.id,
    required this.pppId,
    required this.type,
    required this.fname,
    required this.lname,
    required this.cname,
    required this.website,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.pincode,
    required this.description,
    required this.document,
  });

  final String id;
  final String pppId;
  final String type;
  final String fname;
  final String lname;
  final String cname;
  final String website;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String pincode;
  final String description;
  final List<String> document;

  String get fullName => '$fname $lname'.trim();
  String get firstImage => document.isNotEmpty ? document.first : '';
  String get initials {
    final f = fname.isNotEmpty ? fname[0] : '';
    final l = lname.isNotEmpty ? lname[0] : '';
    return '$f$l'.toUpperCase();
  }

  factory PppStakeholder.fromJson(Map<String, dynamic> json) => PppStakeholder(
        id: json['_id'] as String? ?? '',
        pppId: json['pppId'] as String? ?? '',
        type: json['type'] as String? ?? '',
        fname: json['fname'] as String? ?? '',
        lname: json['lname'] as String? ?? '',
        cname: json['cname'] as String? ?? '',
        website: json['website'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        address: json['address'] as String? ?? '',
        city: json['City'] as String? ?? '',
        pincode: json['pincode'] as String? ?? '',
        description: json['description'] as String? ?? '',
        document: (json['Document'] as List<dynamic>?)?.cast<String>() ?? [],
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
