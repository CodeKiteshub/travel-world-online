class VillaRateModel {
  const VillaRateModel({
    required this.propertyId,
    required this.propertyName,
    required this.city,
    required this.ratePlanCode,
    required this.amount,
    required this.currency,
    required this.imageUrl,
    required this.description,
    required this.quoteId,
    required this.numberOfOffers,
    required this.checkin,
    required this.checkout,
    required this.adults,
    required this.children,
  });

  final String propertyId;
  final String propertyName;
  final String city;
  final String ratePlanCode;
  final double amount;
  final String currency;
  final String imageUrl;
  final String description;
  final String quoteId;
  final int numberOfOffers;
  final String checkin;
  final String checkout;
  final int adults;
  final int children;

  factory VillaRateModel.fromJson(
    Map<String, dynamic> json, {
    String checkin = '',
    String checkout = '',
    int adults = 2,
    int children = 0,
  }) {
    final rawAmount = json['amount'] ?? json['price'] ?? json['totalAmount'] ?? 0;
    final rawOffers = json['numberOfOffers'] ?? json['offersCount'] ?? 0;
    return VillaRateModel(
      propertyId: json['propertyId'] as String? ??
          json['_id'] as String? ??
          json['id'] as String? ??
          '',
      propertyName: json['propertyName'] as String? ??
          json['name'] as String? ??
          '',
      city: json['city'] as String? ?? json['cityName'] as String? ?? '',
      ratePlanCode: json['ratePlanCode'] as String? ??
          json['rateCode'] as String? ??
          '',
      amount: rawAmount is num ? rawAmount.toDouble() : 0.0,
      currency:
          json['currency'] as String? ?? json['currencyCode'] as String? ?? 'INR',
      imageUrl: json['imageUrl'] as String? ??
          json['image'] as String? ??
          json['thumbnail'] as String? ??
          '',
      description:
          json['description'] as String? ?? json['overview'] as String? ?? '',
      quoteId: json['quoteId'] as String? ??
          json['quote_id'] as String? ??
          json['_id'] as String? ??
          '',
      numberOfOffers: rawOffers is int ? rawOffers : 0,
      checkin: json['checkinDate'] as String? ?? checkin,
      checkout: json['checkoutDate'] as String? ?? checkout,
      adults: adults,
      children: children,
    );
  }
}
