class AssociationDealModel {
  const AssociationDealModel({
    required this.id,
    required this.title,
    required this.destination,
    required this.price,
    required this.category,
    this.imageUrl,
    this.nights,
    this.days,
    this.hotelCategory,
    this.postedBy,
    this.postedAt,
    this.isFavourite = false,
  });

  final String id;
  final String title;
  final String destination;
  final double price;
  final String category; // 'Package' | 'Hotel' | 'Transport'
  final String? imageUrl;
  final int? nights;
  final int? days;
  final String? hotelCategory;
  final String? postedBy;
  final String? postedAt;
  final bool isFavourite;

  factory AssociationDealModel.fromJson(Map<String, dynamic> j) {
    final rawImg = j['image'] ?? j['coverImage'] ?? j['images'];
    String? imgUrl;
    if (rawImg is List && rawImg.isNotEmpty) {
      imgUrl = rawImg.first as String?;
    } else if (rawImg is String && rawImg.isNotEmpty) {
      imgUrl = rawImg;
    }
    return AssociationDealModel(
      id: j['_id']?.toString() ?? j['id']?.toString() ?? '',
      // Old API uses 'dealName'; new API uses 'title'
      title: j['title'] as String? ?? j['dealName'] as String? ?? j['destination'] as String? ?? '',
      destination: j['destination'] as String? ?? j['countryOrState'] as String? ?? '',
      // Old API uses 'priceForSame'/'priceForOther'; new API uses 'price'
      price: _toDouble(j['price'] ?? j['priceForSame'] ?? j['pricePerPerson'] ?? 0),
      category: j['category'] as String? ?? 'Package',
      imageUrl: imgUrl,
      nights: _toInt(j['nights']),
      days: _toInt(j['days']),
      hotelCategory: j['hotelCategory'] as String?,
      postedBy: j['postedBy'] as String? ?? j['ContactName'] as String? ?? j['agentName'] as String?,
      postedAt: j['createdAt'] as String? ?? j['addedAt'] as String?,
      isFavourite: j['isFavourite'] as bool? ?? j['isFav'] as bool? ?? false,
    );
  }

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }
}

class AssociationDemandModel {
  const AssociationDemandModel({
    required this.id,
    required this.destination,
    required this.category,
    required this.budgetMin,
    required this.budgetMax,
    this.pax,
    this.nights,
    this.details,
    this.postedBy,
    this.postedAt,
  });

  final String id;
  final String destination;
  final String category;
  final double budgetMin;
  final double budgetMax;
  final int? pax;
  final int? nights;
  final String? details;
  final String? postedBy;
  final String? postedAt;

  factory AssociationDemandModel.fromJson(Map<String, dynamic> j) {
    return AssociationDemandModel(
      id: j['_id']?.toString() ?? j['id']?.toString() ?? '',
      destination: j['destination'] as String? ?? j['countryOrState'] as String? ?? '',
      category: j['category'] as String? ?? 'Package',
      // Old API: priceForSame = what they'll pay, priceForOther = alternate price
      budgetMin: AssociationDealModel._toDouble(j['budgetMin'] ?? j['priceForSame'] ?? j['budget'] ?? 0),
      budgetMax: AssociationDealModel._toDouble(j['budgetMax'] ?? j['priceForOther'] ?? j['budget'] ?? 0),
      pax: AssociationDealModel._toInt(j['pax'] ?? j['passengers']),
      nights: AssociationDealModel._toInt(j['nights']),
      details: j['details'] as String? ?? j['description'] as String? ?? j['inclusions'] as String?,
      postedBy: j['postedBy'] as String? ?? j['ContactName'] as String? ?? j['agentName'] as String?,
      postedAt: j['createdAt'] as String? ?? j['addedAt'] as String?,
    );
  }
}

class AssociationLastMinModel {
  const AssociationLastMinModel({
    required this.id,
    required this.title,
    required this.price,
    required this.expiresAt,
    this.category,
    this.nights,
    this.days,
  });

  final String id;
  final String title;
  final double price;
  final String expiresAt;
  final String? category;
  final int? nights;
  final int? days;

  factory AssociationLastMinModel.fromJson(Map<String, dynamic> j) {
    return AssociationLastMinModel(
      id: j['_id']?.toString() ?? '',
      title: j['title'] as String? ?? j['destination'] as String? ?? '',
      price: AssociationDealModel._toDouble(j['price'] ?? 0),
      expiresAt: j['expiresAt'] as String? ?? j['expiry'] as String? ?? '',
      category: j['category'] as String?,
      nights: AssociationDealModel._toInt(j['nights']),
      days: AssociationDealModel._toInt(j['days']),
    );
  }
}
