import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/visa_remote_datasource.dart';
import '../../data/models/visa_models.dart';

final _visaDatasourceProvider = Provider<VisaRemoteDatasource>(
  (ref) => VisaRemoteDatasource(ref.watch(dioProvider)),
);

final visaApplicationProvider =
    StateNotifierProvider.autoDispose<VisaApplicationNotifier, VisaApplicationState>(
  (ref) => VisaApplicationNotifier(ref.watch(_visaDatasourceProvider)),
);

class VisaApplicationNotifier extends StateNotifier<VisaApplicationState> {
  VisaApplicationNotifier(this._ds) : super(VisaApplicationState(documents: _defaultDocs()));
  final VisaRemoteDatasource _ds;

  static const countries = [
    'Australia', 'Canada', 'Dubai (UAE)', 'France', 'Germany',
    'Japan', 'New Zealand', 'Singapore', 'Thailand', 'United Kingdom',
    'United States', 'Schengen Area', 'Other',
  ];

  static const visaTypes = [
    'Tourist', 'Business', 'Student', 'Transit', 'Work', 'Medical',
  ];

  static const purposes = [
    'Leisure / Vacation', 'Business Meeting', 'Education', 'Medical Treatment',
    'Family Visit', 'Transit', 'Other',
  ];

  static List<VisaDoc> _defaultDocs() => [
    VisaDoc(type: VisaDocType.passport, label: 'Passport (front & back)', fieldName: 'passport'),
    VisaDoc(type: VisaDocType.photo, label: 'Passport Photo', fieldName: 'photo'),
    VisaDoc(type: VisaDocType.bankStatement, label: 'Bank Statement', fieldName: 'bankStatement'),
    VisaDoc(type: VisaDocType.itinerary, label: 'Travel Itinerary', fieldName: 'itinerary'),
    VisaDoc(type: VisaDocType.insurance, label: 'Travel Insurance (if applicable)', fieldName: 'insurance'),
  ];

  // ── Step navigation ───────────────────────────────────────────────────────

  void nextStep() {
    if (state.currentStep < 3) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  // ── Step 1: Personal Info ─────────────────────────────────────────────────

  void setFullName(String v) => state = state.copyWith(fullName: v);
  void setPassportNo(String v) => state = state.copyWith(passportNo: v);
  void setDateOfBirth(String v) => state = state.copyWith(dateOfBirth: v);
  void setNationality(String v) => state = state.copyWith(nationality: v);
  void setEmail(String v) => state = state.copyWith(email: v);
  void setPhone(String v) => state = state.copyWith(phone: v);

  // ── Step 2: Travel Details ────────────────────────────────────────────────

  void setCountry(String v) => state = state.copyWith(country: v);
  void setVisaType(String v) => state = state.copyWith(visaType: v);
  void setTravelDate(DateTime d) => state = state.copyWith(
        travelDate:
            '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}',
      );
  void setReturnDate(DateTime d) => state = state.copyWith(
        returnDate:
            '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}',
      );
  void setPurpose(String v) => state = state.copyWith(purpose: v);

  // ── Step 3: Documents ─────────────────────────────────────────────────────

  Future<void> pickDocument(int index) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.first.path;
    if (path == null) return;
    final docs = List<VisaDoc>.from(state.documents);
    docs[index].file = File(path);
    state = state.copyWith(documents: docs);
  }

  // ── Step 4: Submit ────────────────────────────────────────────────────────

  Future<void> submit() async {
    state = state.copyWith(isLoading: true, errorMessage: '');
    final ok = await _ds.submitApplication(state);
    state = state.copyWith(
      isLoading: false,
      isSubmitted: ok,
      errorMessage: ok ? '' : 'Submission failed. Please try again.',
    );
  }

  void reset() => state = VisaApplicationState(documents: _defaultDocs());
}
