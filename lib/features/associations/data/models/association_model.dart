class AssociationModel {
  const AssociationModel({
    required this.name,
    required this.id,
    required this.atype,
    required this.logoUrl,
  });

  final String name;
  final String id;
  final String atype;
  // Full Cloudinary URL (already absolute)
  final String logoUrl;

  factory AssociationModel.fromJson(Map<String, dynamic> json) {
    final rawLogo = json['logo'];
    final String logoUrl;
    if (rawLogo is List) {
      logoUrl = rawLogo.isNotEmpty ? rawLogo.first as String : '';
    } else {
      logoUrl = rawLogo as String? ?? '';
    }
    return AssociationModel(
      name: json['name'] as String? ?? '',
      id: json['id'] as String? ?? '',
      atype: json['atype'] as String? ?? '',
      logoUrl: logoUrl,
    );
  }
}
