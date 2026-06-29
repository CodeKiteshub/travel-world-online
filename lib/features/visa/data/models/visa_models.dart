import 'dart:io';

enum VisaDocType {
  passport,
  photo,
  bankStatement,
  itinerary,
  insurance,
  other,
}

class VisaDoc {
  final VisaDocType type;
  final String label;
  final String fieldName;
  File? file;

  VisaDoc({
    required this.type,
    required this.label,
    required this.fieldName,
    this.file,
  });
}

class VisaApplicationState {
  final int currentStep;

  // Step 1 — Personal Info
  final String fullName;
  final String passportNo;
  final String dateOfBirth;
  final String nationality;
  final String email;
  final String phone;

  // Step 2 — Travel Details
  final String country;
  final String visaType;
  final String travelDate;
  final String returnDate;
  final String purpose;

  // Step 3 — Documents
  final List<VisaDoc> documents;

  // Submission
  final bool isLoading;
  final bool isSubmitted;
  final String errorMessage;

  const VisaApplicationState({
    this.currentStep = 0,
    this.fullName = '',
    this.passportNo = '',
    this.dateOfBirth = '',
    this.nationality = 'Indian',
    this.email = '',
    this.phone = '',
    this.country = '',
    this.visaType = '',
    this.travelDate = '',
    this.returnDate = '',
    this.purpose = '',
    this.documents = const [],
    this.isLoading = false,
    this.isSubmitted = false,
    this.errorMessage = '',
  });

  VisaApplicationState copyWith({
    int? currentStep,
    String? fullName,
    String? passportNo,
    String? dateOfBirth,
    String? nationality,
    String? email,
    String? phone,
    String? country,
    String? visaType,
    String? travelDate,
    String? returnDate,
    String? purpose,
    List<VisaDoc>? documents,
    bool? isLoading,
    bool? isSubmitted,
    String? errorMessage,
  }) =>
      VisaApplicationState(
        currentStep: currentStep ?? this.currentStep,
        fullName: fullName ?? this.fullName,
        passportNo: passportNo ?? this.passportNo,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        nationality: nationality ?? this.nationality,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        country: country ?? this.country,
        visaType: visaType ?? this.visaType,
        travelDate: travelDate ?? this.travelDate,
        returnDate: returnDate ?? this.returnDate,
        purpose: purpose ?? this.purpose,
        documents: documents ?? this.documents,
        isLoading: isLoading ?? this.isLoading,
        isSubmitted: isSubmitted ?? this.isSubmitted,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
