class LoginRequest {
  const LoginRequest({
    required this.email,
    required this.password,
    this.associationId,
    this.fcmToken,
  });

  final String email;
  final String password;
  final String? associationId;
  final String? fcmToken;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        if (associationId != null && associationId!.isNotEmpty)
          'associationId': associationId,
        if (fcmToken != null && fcmToken!.isNotEmpty) 'FmcToken': fcmToken,
      };
}

class MemberModel {
  const MemberModel({
    required this.id,
    required this.name,
    required this.email,
    required this.associationId,
    this.password,
    this.favoritesHotel = const [],
    this.favoritesTransport = const [],
    this.favoritesPackage = const [],
    this.fcmToken,
  });

  final String id;
  final String name;
  final String email;
  final String associationId;
  final String? password;
  final List<String> favoritesHotel;
  final List<String> favoritesTransport;
  final List<String> favoritesPackage;
  final String? fcmToken;

  factory MemberModel.fromJson(Map<String, dynamic> json) => MemberModel(
        id: json['_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        associationId: json['associationId'] as String? ?? '',
        password: json['password'] as String?,
        favoritesHotel: _toStringList(json['favoritesHotel']),
        favoritesTransport: _toStringList(json['favoritesTransport']),
        favoritesPackage: _toStringList(json['favoritesPackage']),
        fcmToken: json['FmcToken'] as String?,
      );

  static List<String> _toStringList(dynamic value) {
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }
}

class LoginResponse {
  const LoginResponse({required this.token, required this.member});

  final String token;
  final MemberModel member;

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        token: json['token'] as String,
        member: MemberModel.fromJson(json['member'] as Map<String, dynamic>),
      );
}
