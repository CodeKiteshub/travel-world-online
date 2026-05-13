class Deal {
  const Deal({
    required this.id,
    required this.dealName,
    this.duration,
    this.dealType,
    this.priceForSame,
    this.priceForOther,
    this.destination,
    this.countryOrState,
    this.inclusions,
    this.description,
    this.hotelCategory,
    this.images = const [],
    this.contactName,
    this.contactNumber,
    this.contactEmail,
    this.isFeatured = false,
  });

  final String id;
  final String dealName;
  final String? duration;
  final String? dealType;
  final String? priceForSame;
  final String? priceForOther;
  final String? destination;
  final String? countryOrState;
  final String? inclusions;
  final String? description;
  final String? hotelCategory;
  final List<String> images;
  final String? contactName;
  final String? contactNumber;
  final String? contactEmail;
  final bool isFeatured;

  String get firstImage => images.isNotEmpty ? images.first : '';

  String get displayTag =>
      (dealType?.isNotEmpty == true ? dealType! : hotelCategory ?? 'DEAL')
          .toUpperCase();

  List<String> get inclusionsList {
    if (inclusions == null || inclusions!.isEmpty) return [];
    return inclusions!
        .split(RegExp(r'[,\n]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  factory Deal.fromJson(Map<String, dynamic> json) => Deal(
        id: json['_id'] as String? ?? '',
        dealName: json['dealName'] as String? ?? '',
        duration: json['duration'] as String?,
        dealType: json['dealType'] as String?,
        priceForSame: json['priceForSame'] as String?,
        priceForOther: json['priceForOther'] as String?,
        destination: json['destination'] as String?,
        countryOrState: json['countryOrState'] as String?,
        inclusions: json['inclusions'] as String?,
        description: json['description'] as String?,
        hotelCategory: json['hotelCategory'] as String?,
        images: (json['image'] as List<dynamic>?)?.cast<String>() ?? [],
        contactName: json['ContactName'] as String?,
        contactNumber: json['ContactNumber'] as String?,
        contactEmail: json['ContactEmail'] as String?,
        isFeatured: json['isFeatured'] as bool? ?? false,
      );
}
