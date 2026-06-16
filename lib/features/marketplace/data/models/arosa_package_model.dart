class ArosaPackageModel {
  const ArosaPackageModel({
    required this.serviceCode,
    required this.name,
    required this.description,
    required this.river,
    required this.date,
    required this.price,
    required this.currency,
    required this.duration,
    required this.imageUrl,
  });

  final String serviceCode;
  final String name;
  final String description;
  final String river;
  final String date;
  final double price;
  final String currency;
  final String duration;
  final String imageUrl;

  factory ArosaPackageModel.fromJson(Map<String, dynamic> json) {
    final rawPrice = json['price'] ?? json['amount'] ?? json['Price'] ?? 0;
    return ArosaPackageModel(
      serviceCode: json['serviceCode'] as String? ??
          json['ServiceCode'] as String? ??
          json['code'] as String? ??
          '',
      name: json['name'] as String? ??
          json['Name'] as String? ??
          json['packageName'] as String? ??
          '',
      description: json['description'] as String? ??
          json['Description'] as String? ??
          '',
      river: json['river'] as String? ??
          json['River'] as String? ??
          json['destination'] as String? ??
          '',
      date: json['date'] as String? ??
          json['Date'] as String? ??
          json['departureDate'] as String? ??
          '',
      price: rawPrice is num ? rawPrice.toDouble() : 0.0,
      currency: json['currency'] as String? ??
          json['Currency'] as String? ??
          'EUR',
      duration: json['duration'] as String? ??
          json['Duration'] as String? ??
          '',
      imageUrl: json['imageUrl'] as String? ??
          json['ImageUrl'] as String? ??
          json['image'] as String? ??
          '',
    );
  }
}
