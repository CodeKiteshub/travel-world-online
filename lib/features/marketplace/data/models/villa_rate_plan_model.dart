class VillaRatePlanModel {
  const VillaRatePlanModel({
    required this.id,
    required this.ratePlanCode,
    required this.displayName,
    required this.netBeforeTax,
    required this.gstAmount,
    required this.netAfterTax,
    required this.securityDeposit,
    required this.numberOfNights,
    required this.numberOfGuests,
  });

  final String id;
  final String ratePlanCode;
  final String displayName;
  final double netBeforeTax;
  final double gstAmount;
  final double netAfterTax;
  final double securityDeposit;
  final int numberOfNights;
  final int numberOfGuests;

  double get totalPayable => netAfterTax + securityDeposit;
  int get totalPayableInPaise => (totalPayable * 100).round();

  factory VillaRatePlanModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) => v is num ? v.toDouble() : 0.0;
    int toInt(dynamic v) => v is int ? v : (v is num ? v.toInt() : 0);
    return VillaRatePlanModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      ratePlanCode: json['ratePlanCode'] as String? ??
          json['rateCode'] as String? ??
          '',
      displayName: json['displayName'] as String? ??
          json['ratePlanName'] as String? ??
          json['name'] as String? ??
          '',
      netBeforeTax: toDouble(json['netBeforeTax'] ?? json['baseAmount']),
      gstAmount: toDouble(json['gstAmount'] ?? json['tax']),
      netAfterTax: toDouble(json['netAfterTax'] ?? json['totalAmount']),
      securityDeposit: toDouble(json['securityDeposit'] ?? json['deposit']),
      numberOfNights: toInt(json['numberOfNights'] ?? json['nights']),
      numberOfGuests: toInt(json['numberOfGuests'] ?? json['guests']),
    );
  }
}
