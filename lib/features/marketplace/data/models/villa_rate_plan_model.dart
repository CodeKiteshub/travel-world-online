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

  // Amount charged via Razorpay — matches the old app: the security deposit
  // is not collected online.
  int get payableInPaise => (netAfterTax * 100).round();

  // Parses a quote object from /api/elivaas/rates (list[0].quotes[i]).
  factory VillaRatePlanModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) => double.tryParse(v.toString()) ?? 0.0;
    int toInt(dynamic v) => int.tryParse(v.toString()) ?? 0;
    final ratePlan = json['ratePlanDTO'] as Map<String, dynamic>?;
    final code = (json['ratePlanCode'] ?? json['rateCode'] ?? 'EP').toString();
    return VillaRatePlanModel(
      id: (json['id'] ?? json['_id'] ?? json['quoteId'] ?? '').toString(),
      ratePlanCode: code,
      displayName:
          (ratePlan?['displayName'] ?? ratePlan?['name'] ?? code).toString(),
      netBeforeTax:
          toDouble(json['netAmountBeforeTax'] ?? json['netBeforeTax']),
      gstAmount: toDouble(json['gstAmount'] ?? json['tax']),
      netAfterTax: toDouble(json['netAmountAfterTax'] ?? json['netAfterTax']),
      securityDeposit: toDouble(json['securityDeposit'] ?? json['deposit']),
      numberOfNights: toInt(json['numberOfNights'] ?? json['nights']),
      numberOfGuests:
          toInt(json['numberOfGuests'] ?? json['adults'] ?? json['guests']),
    );
  }
}
