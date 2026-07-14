class VillaRateModel {
  const VillaRateModel({
    required this.propertyId,
    required this.propertyName,
    required this.city,
    required this.location,
    required this.state,
    required this.streetLine,
    required this.ratePlanCode,
    required this.amount,
    required this.currency,
    required this.imageUrl,
    required this.description,
    required this.quoteId,
    required this.numberOfOffers,
    required this.soldOut,
    required this.topAmenities,
    required this.maxOccupancy,
    required this.checkin,
    required this.checkout,
    required this.adults,
    required this.children,
  });

  final String propertyId;
  final String propertyName;
  final String city;
  final String location; // locality, e.g. "Sonipat"
  final String state;
  final String streetLine;
  final String ratePlanCode;
  final double amount;
  final String currency;
  final String imageUrl;
  final String description;
  final String quoteId;
  final int numberOfOffers;
  final bool soldOut;
  final List<String> topAmenities;
  final int maxOccupancy;
  final String checkin;
  final String checkout;
  final int adults;
  final int children;

  /// "Sonipat, Delhi NCR" — most precise short location available.
  String get fullLocation =>
      [location, city].where((s) => s.isNotEmpty).toSet().join(', ');

  factory VillaRateModel.fromJson(
    Map<String, dynamic> json, {
    String checkin = '',
    String checkout = '',
    int adults = 2,
    int children = 0,
  }) {
    // Extract first quote for amount/quoteId (old app pattern)
    final quotes = json['quotes'] as List<dynamic>?;
    final firstQuote =
        (quotes != null && quotes.isNotEmpty && quotes.first is Map<String, dynamic>)
            ? quotes.first as Map<String, dynamic>
            : null;

    // Without checkin/checkout dates the API returns quotes: null and the
    // price only in top-level priceAmount.
    final rawAmount = firstQuote?['netPerNightAmountAfterTax'] ??
        firstQuote?['netAmountAfterTax'] ??
        firstQuote?['amount'] ??
        json['amount'] ??
        json['price'] ??
        json['totalAmount'] ??
        json['priceAmount'] ??
        0;

    final quoteId = firstQuote?['quoteId'] as String? ??
        firstQuote?['id'] as String? ??
        json['quoteId'] as String? ??
        json['quote_id'] as String? ??
        json['_id'] as String? ??
        '';

    // Extract image from various response shapes
    String imageUrl = '';
    if (json['imageUrl'] != null) {
      imageUrl = json['imageUrl'].toString();
    } else if (json['image'] != null) {
      imageUrl = json['image'].toString();
    } else if (json['defaultMedia'] is Map<String, dynamic>) {
      final media = json['defaultMedia'] as Map<String, dynamic>;
      imageUrl =
          (media['url'] ?? media['src'] ?? media['imageUrl'])?.toString() ?? '';
    } else if (json['images'] is List) {
      final imgs = json['images'] as List<dynamic>;
      if (imgs.isNotEmpty) {
        final first = imgs.first;
        if (first is Map<String, dynamic>) {
          imageUrl =
              (first['url'] ?? first['src'] ?? first['imageUrl'])?.toString() ?? '';
        } else {
          imageUrl = first.toString();
        }
      }
    } else if (json['thumbnail'] != null) {
      imageUrl = json['thumbnail'].toString();
    }

    final rawOffers = json['numberOfOffers'] ?? json['offersCount'] ?? 0;

    final topAmenities = (json['topAmenities'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((a) => (a['name'] ?? '').toString().trim())
        .where((n) => n.isNotEmpty)
        .toList();

    return VillaRateModel(
      propertyId: json['propertyId'] as String? ??
          json['_id'] as String? ??
          json['id'] as String? ??
          '',
      propertyName: json['propertyName'] as String? ??
          json['name'] as String? ??
          '',
      city: json['city'] as String? ?? json['cityName'] as String? ?? '',
      location: json['location'] as String? ?? '',
      state: json['state'] as String? ?? '',
      streetLine: json['streetLine'] as String? ?? '',
      ratePlanCode: json['ratePlanCode'] as String? ??
          json['rateCode'] as String? ??
          '',
      amount: double.tryParse(rawAmount.toString()) ?? 0.0,
      currency:
          json['currency'] as String? ?? json['currencyCode'] as String? ?? 'INR',
      imageUrl: imageUrl,
      description:
          json['description'] as String? ?? json['overview'] as String? ?? '',
      quoteId: quoteId,
      numberOfOffers: rawOffers is int ? rawOffers : 0,
      soldOut: json['soldOut'] == true,
      topAmenities: topAmenities,
      maxOccupancy: int.tryParse((json['maxOccupancy'] ?? '').toString()) ?? 0,
      checkin: json['checkinDate'] as String? ?? checkin,
      checkout: json['checkoutDate'] as String? ?? checkout,
      adults: adults,
      children: children,
    );
  }
}
