class InsurancePlan {
  final String id;
  final String name;
  final double premium;
  final double baseCharge;
  final double serviceTax;
  final List<String> features;
  final String pdfUrl;

  const InsurancePlan({
    required this.id,
    required this.name,
    required this.premium,
    required this.baseCharge,
    required this.serviceTax,
    required this.features,
    this.pdfUrl = '',
  });

  factory InsurancePlan.fromJson(Map<String, dynamic> json) => InsurancePlan(
        id: json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        premium: double.tryParse(json['premium']?.toString() ?? '0') ?? 0,
        baseCharge: double.tryParse(json['base_charge']?.toString() ?? '0') ?? 0,
        serviceTax: double.tryParse(json['service_tax']?.toString() ?? '0') ?? 0,
        features: List<String>.from(json['features'] ?? []),
        pdfUrl: json['pdf_url']?.toString() ?? '',
      );
}

class TravellerInfo {
  String passportNo;
  String fullName;
  String dateOfBirth;
  String nationality;
  String email;
  String phone;
  String medicalConditions;
  String address;
  String district;
  String state;
  String city;
  String country;
  String pincode;
  String nominee;
  String relationship;

  TravellerInfo({
    this.passportNo = '',
    this.fullName = '',
    this.dateOfBirth = '',
    this.nationality = 'Indian',
    this.email = '',
    this.phone = '',
    this.medicalConditions = 'No',
    this.address = '',
    this.district = '',
    this.state = '',
    this.city = '',
    this.country = 'India',
    this.pincode = '',
    this.nominee = '',
    this.relationship = '',
  });
}

class InsuranceBookingState {
  final int currentStep;
  final String travelCategory;
  final String country;
  final DateTime? startDate;
  final DateTime? endDate;
  final int numberOfTravellers;
  final List<DateTime?> travellerDOBs;
  final List<InsurancePlan> availablePlans;
  final InsurancePlan? selectedPlan;
  final bool isLoadingPlans;
  final List<TravellerInfo> travellerInfoList;
  final bool isLoading;
  final String policyNumber;
  final String policyDocumentUrl;

  const InsuranceBookingState({
    this.currentStep = 0,
    this.travelCategory = '',
    this.country = '',
    this.startDate,
    this.endDate,
    this.numberOfTravellers = 1,
    this.travellerDOBs = const [null],
    this.availablePlans = const [],
    this.selectedPlan,
    this.isLoadingPlans = false,
    this.travellerInfoList = const [],
    this.isLoading = false,
    this.policyNumber = '',
    this.policyDocumentUrl = '',
  });

  InsuranceBookingState copyWith({
    int? currentStep,
    String? travelCategory,
    String? country,
    DateTime? startDate,
    bool clearStartDate = false,
    DateTime? endDate,
    bool clearEndDate = false,
    int? numberOfTravellers,
    List<DateTime?>? travellerDOBs,
    List<InsurancePlan>? availablePlans,
    InsurancePlan? selectedPlan,
    bool clearSelectedPlan = false,
    bool? isLoadingPlans,
    List<TravellerInfo>? travellerInfoList,
    bool? isLoading,
    String? policyNumber,
    String? policyDocumentUrl,
  }) =>
      InsuranceBookingState(
        currentStep: currentStep ?? this.currentStep,
        travelCategory: travelCategory ?? this.travelCategory,
        country: country ?? this.country,
        startDate: clearStartDate ? null : (startDate ?? this.startDate),
        endDate: clearEndDate ? null : (endDate ?? this.endDate),
        numberOfTravellers: numberOfTravellers ?? this.numberOfTravellers,
        travellerDOBs: travellerDOBs ?? this.travellerDOBs,
        availablePlans: availablePlans ?? this.availablePlans,
        selectedPlan: clearSelectedPlan ? null : (selectedPlan ?? this.selectedPlan),
        isLoadingPlans: isLoadingPlans ?? this.isLoadingPlans,
        travellerInfoList: travellerInfoList ?? this.travellerInfoList,
        isLoading: isLoading ?? this.isLoading,
        policyNumber: policyNumber ?? this.policyNumber,
        policyDocumentUrl: policyDocumentUrl ?? this.policyDocumentUrl,
      );

  int get durationDays {
    if (startDate == null || endDate == null) return 0;
    final d = endDate!.difference(startDate!).inDays;
    return d < 1 ? 1 : d;
  }

  double get totalPremium => (selectedPlan?.premium ?? 0) * numberOfTravellers;
  double get gst => totalPremium * 0.18;
  double get grandTotal => totalPremium + gst;
}
