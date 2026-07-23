class DmcModel {
  const DmcModel({
    required this.id,
    required this.companyName,
    required this.supplierType,
    required this.website,
    required this.country,
    required this.state,
    required this.destinations,
    required this.services,
    required this.contactName,
    required this.email,
    required this.phone,
    required this.approved,
    required this.status,
  });

  final String id;
  final String companyName;
  final String supplierType;
  final String website;
  final String country;
  final String state;
  final String destinations;
  final List<String> services;
  final String contactName;
  final String email;
  final String phone;
  final bool approved;
  final String status;

  factory DmcModel.fromJson(Map<String, dynamic> json) {
    return DmcModel(
      id: json['_id']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      supplierType: json['supplierType']?.toString() ?? '',
      website: json['website']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      destinations: json['destinations']?.toString() ?? '',
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      contactName: json['contactName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      approved: json['approved'] == true,
      status: json['status']?.toString() ?? '',
    );
  }
}
