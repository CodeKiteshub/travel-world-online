class VillaCityModel {
  const VillaCityModel({
    required this.id,
    required this.name,
    required this.slug,
  });

  final String id;
  final String name;
  final String slug;

  factory VillaCityModel.fromJson(Map<String, dynamic> json) => VillaCityModel(
        id: json['_id'] as String? ?? json['id'] as String? ?? '',
        name: json['name'] as String? ?? json['cityName'] as String? ?? '',
        slug: json['slug'] as String? ?? '',
      );
}
