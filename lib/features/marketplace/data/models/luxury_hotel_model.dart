class LuxuryHotelModel {
  const LuxuryHotelModel({
    required this.id,
    required this.name,
    required this.title,
    required this.address,
    required this.city,
    required this.country,
    required this.amenities,
    required this.imageUrls,
    required this.website,
    required this.information,
  });

  final String id;
  final String name;
  final String title;
  final String address;
  final String city;
  final String country;
  final List<String> amenities;
  final List<String> imageUrls;
  final String website;
  final String information;

  String get firstImage => imageUrls.isNotEmpty ? imageUrls.first : '';
  String get location => [city, country].where((s) => s.isNotEmpty).join(', ');

  factory LuxuryHotelModel.fromJson(Map<String, dynamic> json) =>
      LuxuryHotelModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        title: json['title'] as String? ?? '',
        address: json['address'] as String? ?? '',
        city: json['city'] as String? ?? '',
        country: json['country'] as String? ?? '',
        amenities: (json['amenities'] as List<dynamic>?)?.cast<String>() ?? [],
        imageUrls:
            (json['image_url'] as List<dynamic>?)?.cast<String>() ?? [],
        website: json['website'] as String? ?? '',
        information: json['information'] as String? ?? '',
      );
}
