class AssociationSessionModel {
  const AssociationSessionModel({
    required this.token,
    required this.memberId,
    required this.associationId,
    this.memberName,
    this.memberEmail,
    this.memberPhone,
    this.memberCity,
  });

  final String token;
  final String memberId;
  final String associationId;
  final String? memberName;
  final String? memberEmail;
  final String? memberPhone;
  final String? memberCity;

  factory AssociationSessionModel.fromLoginResponse({
    required String token,
    required String associationId,
    required Map<String, dynamic> member,
  }) {
    return AssociationSessionModel(
      token: token,
      memberId: member['id']?.toString() ?? member['_id']?.toString() ?? '',
      associationId: associationId,
      memberName: member['name'] as String?,
      memberEmail: member['email'] as String?,
      memberPhone: member['phone'] as String?,
      memberCity: member['city'] as String?,
    );
  }
}
