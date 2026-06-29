# Services: Insurance & Visa Wizards — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the current stub Services screen with two full 4-step wizards — Travel Insurance and Visa Application — matching the design in `docs/16-services-insurance-visa.html`, backed by the same backend APIs used in the old `travel_app` codebase.

**Architecture:** Riverpod + Dio (same as PPP/Campus modules). Each wizard uses a `StateNotifier` to hold multi-step form state, a `RemoteDatasource` for API calls, and separate wizard + confirmation screens. No new packages needed — `razorpay_flutter` and `image_picker` are already in pubspec.

**Tech Stack:** Flutter, Riverpod 2.x, Dio, GoRouter, Razorpay Flutter, Image Picker, design system from `core/theme/`

## Global Constraints

- Follow the Riverpod + Dio pattern established in `lib/features/ppp/` and `lib/features/campus/` — no GetX
- Use `dioProvider` from `lib/core/network/dio_client.dart` for all HTTP calls
- All UI tokens from `AppColorScheme`, `AppTypography`, `AppColors` — no raw hex except where the design system doesn't have the exact color
- Gold accent `--gold: #C9A84C` → `colors.goldPrimary`; OK green `--ok: #2D7A4F` → `AppColors.success`; blue tint `--tbt: #2A4A6B` and `--tb: #E8EEF5`
- Step indicator: done=green circle with checkmark, active=gold circle with number, pending=grey circle
- Back button: 38×38 circular white/border container with left arrow
- "Next" button: full-width, gold background, `borderRadius 12`, `padding 15`
- Router: sub-routes nested under `/services` using GoRouter `ShellRoute`
- Backend base URL already configured in `DioClient` — use relative paths (e.g. `/api/insurence/plans`)
- Insurance backend: `twoappbackend.onrender.com` (same as current backend)
- Visa backend: `POST https://twoappbackend.onrender.com/api/visa/addVisaToSheet` (multipart, **different** from Dio base — use `http` package multipart or `Dio` FormData)

---

## Discovered APIs (from old travel_app)

### Insurance APIs
| Method | Path | Purpose |
|--------|------|---------|
| GET | `/api/insurence/plans?travel_category=&country=&start_date=&end_date=&travellers=` | Fetch plan list. Falls back to local data on error. |
| POST | `/api/payment/insurance-order` `{amount: int (paisa)}` | Create Razorpay order → returns `{id: ...}` |
| POST | `/api/policy/create` | Full booking payload → returns `{success: true, data: {policyNumber, documentUrl}}` |

**Travel category codes:** Domestic = `de5ee71c-098f-4cc0-b486-e69391cc9fa8`, Overseas = `6b123144-2e3a-490e-baeb-b59f09327b7c`
**Country codes:** Including USA/Canada = `1`, Excluding USA/Canada = `2`, India = `4`

### Visa API
| Method | Path | Purpose |
|--------|------|---------|
| POST | `https://twoappbackend.onrender.com/api/visa/addVisaToSheet` | Multipart form: body fields + multiple file fields |

**Visa file field names:** `documentUrl` (photo), `passport_documentUrl`, `bankstatement_documentUrl`, `hotelbooking_documentUrl`, `flightbook_documentUrl`, `travelInsurance_documentUrl`, `ITR_documentUrl`, `marriage_certificate`, `invitationletter_documentUrl`

---

## File Structure

**New files to create:**
```
lib/features/insurance/
  data/
    datasources/insurance_remote_datasource.dart   # API calls + local fallback
    models/insurance_models.dart                   # InsurancePlan, TravellerInfo, InsuranceBookingState
    local/insurance_local_data.dart                # Ported premium chart from old app
  presentation/
    providers/insurance_providers.dart             # InsuranceBookingNotifier + providers
    screens/
      insurance_wizard_screen.dart                 # AppBar + step indicator + PageView for 4 steps
      insurance_confirmation_screen.dart           # Policy issued screen

lib/features/visa/
  data/
    datasources/visa_remote_datasource.dart        # Multipart POST
    models/visa_models.dart                        # VisaApplicationState, VisaDoc
  presentation/
    providers/visa_providers.dart                  # VisaApplicationNotifier + providers
    screens/
      visa_wizard_screen.dart                      # AppBar + step indicator + PageView for 4 steps
      visa_confirmation_screen.dart                # Application submitted screen
```

**Files to modify:**
```
lib/core/router/route_names.dart                   # Add insurance + visa routes
lib/core/router/app_router.dart                    # Register new GoRoutes
lib/features/services/presentation/screens/services_screen.dart  # Wire buttons to push routes
```

---

## Shared Widget Note

Both wizards use the same step indicator and "Next" button. Build them as private widgets inside `insurance_wizard_screen.dart` first, then duplicate (YAGNI — don't extract to shared until both wizards are done and you can see the exact API surface needed).

---

## Task 1: Insurance Models + Local Data

**Files:**
- Create: `lib/features/insurance/data/models/insurance_models.dart`
- Create: `lib/features/insurance/data/local/insurance_local_data.dart`

**Interfaces:**
- Produces: `InsurancePlan`, `TravellerInfo`, `InsuranceBookingState` consumed by Task 2 + 3

- [ ] **Step 1: Create insurance_models.dart**

```dart
// lib/features/insurance/data/models/insurance_models.dart

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
  // Step 1
  final String travelCategory;
  final String country;
  final DateTime? startDate;
  final DateTime? endDate;
  final int numberOfTravellers;
  final List<DateTime?> travellerDOBs;
  // Step 2
  final List<InsurancePlan> availablePlans;
  final InsurancePlan? selectedPlan;
  final bool isLoadingPlans;
  // Step 3
  final List<TravellerInfo> travellerInfoList;
  // Step 4 / payment
  final String selectedPaymentMethod; // 'card' | 'upi' | 'wallet'
  final bool isLoading;
  // Confirmation
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
    this.selectedPaymentMethod = 'card',
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
    String? selectedPaymentMethod,
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
        selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
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
```

- [ ] **Step 2: Port insurance_local_data.dart from old app**

Copy `lib/features/insurance/data/insurance_local_data.dart` from `travel_app` verbatim into `lib/features/insurance/data/local/insurance_local_data.dart`, updating the import:

```dart
// lib/features/insurance/data/local/insurance_local_data.dart
import '../models/insurance_models.dart';

// Change InsurancePlan import — rest of file is identical to old app's
// insurance_local_data.dart (the full premium chart and lookupPlans method).
// Reference: /Users/adityabajpai/Documents/personal/travel_app/lib/features/insurance/data/insurance_local_data.dart
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/insurance/
git commit -m "feat(insurance): add models and local premium chart data"
```

---

## Task 2: Insurance Remote Datasource + Providers

**Files:**
- Create: `lib/features/insurance/data/datasources/insurance_remote_datasource.dart`
- Create: `lib/features/insurance/presentation/providers/insurance_providers.dart`

**Interfaces:**
- Consumes: `InsurancePlan`, `TravellerInfo`, `InsuranceBookingState` from Task 1; `dioProvider` from `dio_client.dart`
- Produces: `insuranceBookingProvider` (StateNotifierProvider<InsuranceBookingNotifier, InsuranceBookingState>)

- [ ] **Step 1: Create insurance_remote_datasource.dart**

```dart
// lib/features/insurance/data/datasources/insurance_remote_datasource.dart
import 'package:dio/dio.dart';
import '../models/insurance_models.dart';
import '../local/insurance_local_data.dart';

class InsuranceRemoteDatasource {
  const InsuranceRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<InsurancePlan>> fetchPlans({
    required String travelCategory,
    required String country,
    required String startDate,
    required String endDate,
    required int numberOfTravellers,
    required List<int> travellerAges,
    required int durationDays,
  }) async {
    try {
      final response = await _dio.get(
        '/api/insurence/plans',
        queryParameters: {
          'travel_category': travelCategory,
          'country': country,
          'start_date': startDate,
          'end_date': endDate,
          'travellers': numberOfTravellers.toString(),
        },
      );
      final raw = response.data;
      List<dynamic> list;
      if (raw is List) {
        list = raw;
      } else if (raw is Map<String, dynamic> && raw['data'] is List) {
        list = raw['data'] as List;
      } else {
        list = [];
      }
      if (list.isNotEmpty) {
        return list.map((e) => InsurancePlan.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    // Fallback to local data
    return InsuranceLocalData.lookupPlans(
      categoryCode: travelCategory,
      countryCode: country,
      travellerAges: travellerAges,
      durationDays: durationDays,
    );
  }

  Future<Map<String, dynamic>?> createOrder(double premiumInRupees) async {
    final response = await _dio.post(
      '/api/payment/insurance-order',
      data: {'amount': (premiumInRupees * 100).toInt()},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data as Map<String, dynamic>;
    }
    return null;
  }

  Future<Map<String, dynamic>?> createPolicy(Map<String, dynamic> body) async {
    final response = await _dio.post('/api/policy/create', data: body);
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        response.data['success'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    }
    return null;
  }
}
```

- [ ] **Step 2: Create insurance_providers.dart with InsuranceBookingNotifier**

```dart
// lib/features/insurance/presentation/providers/insurance_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/insurance_remote_datasource.dart';
import '../../data/models/insurance_models.dart';

final _insuranceDatasourceProvider = Provider<InsuranceRemoteDatasource>(
  (ref) => InsuranceRemoteDatasource(ref.watch(dioProvider)),
);

final insuranceBookingProvider =
    StateNotifierProvider.autoDispose<InsuranceBookingNotifier, InsuranceBookingState>(
  (ref) => InsuranceBookingNotifier(ref.watch(_insuranceDatasourceProvider)),
);

// Category display → backend UUID
const _categoryCodeMap = {
  'Domestic Travel Document': 'de5ee71c-098f-4cc0-b486-e69391cc9fa8',
  'Overseas Travel':          '6b123144-2e3a-490e-baeb-b59f09327b7c',
};

// Country display → backend code
const _countryCodeMap = {
  'Excluding USA and Canada': '2',
  'Including USA and Canada (Worldwide)': '1',
  'India': '4',
};

class InsuranceBookingNotifier extends StateNotifier<InsuranceBookingState> {
  InsuranceBookingNotifier(this._ds) : super(const InsuranceBookingState());
  final InsuranceRemoteDatasource _ds;
  Razorpay? _razorpay;

  // ── Getters ───────────────────────────────────────────────────────────────

  static const travelCategories = ['Domestic Travel Document', 'Overseas Travel'];
  static const countries = ['Excluding USA and Canada', 'Including USA and Canada (Worldwide)', 'India'];

  String get _categoryCode => _categoryCodeMap[state.travelCategory] ?? state.travelCategory;
  String get _countryCode  => _countryCodeMap[state.country] ?? state.country;

  String _fmtDate(DateTime? d) {
    if (d == null) return '';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String _fmtApiDate(DateTime? d) {
    if (d == null) return '';
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day.toString().padLeft(2, '0')}-${months[d.month]}-${d.year}';
  }

  int _age(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) age--;
    return age;
  }

  // ── Step navigation ───────────────────────────────────────────────────────

  void goToStep(int step) => state = state.copyWith(currentStep: step);
  void nextStep() { if (state.currentStep < 3) state = state.copyWith(currentStep: state.currentStep + 1); }
  void previousStep() { if (state.currentStep > 0) state = state.copyWith(currentStep: state.currentStep - 1); }

  // ── Step 1 mutations ──────────────────────────────────────────────────────

  void setTravelCategory(String v) => state = state.copyWith(travelCategory: v);
  void setCountry(String v) => state = state.copyWith(country: v);
  void setStartDate(DateTime d) => state = state.copyWith(startDate: d);
  void setEndDate(DateTime d) => state = state.copyWith(endDate: d);

  void setNumberOfTravellers(int count) {
    final dobs = List<DateTime?>.from(state.travellerDOBs);
    final infos = List<TravellerInfo>.from(state.travellerInfoList);
    while (dobs.length < count) dobs.add(null);
    while (dobs.length > count) dobs.removeLast();
    while (infos.length < count) infos.add(TravellerInfo());
    while (infos.length > count) infos.removeLast();
    state = state.copyWith(numberOfTravellers: count, travellerDOBs: dobs, travellerInfoList: infos);
  }

  void setTravellerDOB(int index, DateTime dob) {
    final dobs = List<DateTime?>.from(state.travellerDOBs);
    final infos = List<TravellerInfo>.from(state.travellerInfoList);
    if (index < dobs.length) dobs[index] = dob;
    if (index < infos.length) infos[index].dateOfBirth = _fmtApiDate(dob);
    state = state.copyWith(travellerDOBs: dobs, travellerInfoList: infos);
  }

  // ── Step 2: Fetch plans ───────────────────────────────────────────────────

  Future<void> fetchPlans() async {
    state = state.copyWith(isLoadingPlans: true, clearSelectedPlan: true, availablePlans: []);
    final ages = state.travellerDOBs.map((d) => d != null ? _age(d) : 25).toList();
    final plans = await _ds.fetchPlans(
      travelCategory: _categoryCode,
      country: _countryCode,
      startDate: _fmtDate(state.startDate),
      endDate: _fmtDate(state.endDate),
      numberOfTravellers: state.numberOfTravellers,
      travellerAges: ages,
      durationDays: state.durationDays,
    );
    state = state.copyWith(availablePlans: plans, isLoadingPlans: false);
  }

  void selectPlan(InsurancePlan plan) => state = state.copyWith(selectedPlan: plan);

  // ── Step 3: Traveller info mutations ──────────────────────────────────────

  void updateTravellerInfo(int index, TravellerInfo info) {
    final list = List<TravellerInfo>.from(state.travellerInfoList);
    if (index < list.length) list[index] = info;
    state = state.copyWith(travellerInfoList: list);
  }

  // ── Step 4: Payment ───────────────────────────────────────────────────────

  void setPaymentMethod(String method) => state = state.copyWith(selectedPaymentMethod: method);

  Future<void> openRazorpay({
    required void Function(String policyNumber) onSuccess,
    required void Function(String msg) onError,
  }) async {
    final plan = state.selectedPlan;
    if (plan == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final orderData = await _ds.createOrder(state.grandTotal);
      if (orderData == null) {
        onError('Could not create payment order. Try again.');
        return;
      }
      final traveller = state.travellerInfoList.isNotEmpty ? state.travellerInfoList[0] : TravellerInfo();
      _razorpay = Razorpay();
      _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse r) async {
        await _handlePaymentSuccess(r, onSuccess: onSuccess, onError: onError);
      });
      _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse r) {
        onError(r.message ?? 'Payment failed');
        state = state.copyWith(isLoading: false);
      });
      _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, (_) {});
      _razorpay!.open({
        'key': 'rzp_live_SJyy6qt0I2DKtU',
        'amount': (state.grandTotal * 100).toInt(),
        'order_id': orderData['id'] ?? '',
        'name': 'Travel World Online',
        'description': 'Insurance: ${plan.name}',
        'prefill': {'contact': traveller.phone, 'email': traveller.email},
        'external': {'wallets': ['paytm']},
      });
    } catch (e) {
      onError('Could not open payment. Try again.');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _handlePaymentSuccess(
    PaymentSuccessResponse r, {
    required void Function(String) onSuccess,
    required void Function(String) onError,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final plan = state.selectedPlan!;
      final traveller = state.travellerInfoList.isNotEmpty ? state.travellerInfoList[0] : TravellerInfo();
      final dob = state.travellerDOBs.isNotEmpty ? state.travellerDOBs[0] : null;
      final planCode = plan.id.split('_').first;
      final body = {
        'plan': {
          'categorycode': _categoryCode,
          'plancode': planCode,
          'basecharges': state.grandTotal,
          'totalbasecharges': (state.grandTotal / 1.18).toStringAsFixed(2),
          'servicetax': (state.grandTotal - state.grandTotal / 1.18).toStringAsFixed(2),
          'totalcharges': state.grandTotal,
        },
        'traveldetails': {
          'departuredate': _fmtApiDate(state.startDate),
          'days': state.durationDays,
          'arrivaldate': _fmtApiDate(state.endDate),
        },
        'insured': {
          'passport': traveller.passportNo,
          'contactdetails': {
            'address1': traveller.address,
            'city': traveller.city,
            'district': traveller.district,
            'state': traveller.state,
            'pincode': traveller.pincode,
            'country': traveller.country,
            'phoneno': traveller.phone,
            'mobileno': traveller.phone,
            'emailaddress': traveller.email,
          },
          'name': traveller.fullName,
          'dateofbirth': traveller.dateOfBirth,
          'age': dob != null ? _age(dob) : 0,
          'nominee': traveller.nominee,
          'relation': traveller.relationship,
        },
        'otherdetails': {'policycomment': ''},
        'razorpayOrderId': r.orderId ?? '',
        'razorpayPaymentId': r.paymentId ?? '',
        'razorpaySignature': r.signature ?? '',
        'amountPaid': state.grandTotal,
      };
      final result = await _ds.createPolicy(body);
      if (result != null) {
        final policyNo = result['policyNumber']?.toString().trim() ?? '';
        final docUrl = result['documentUrl']?.toString().trim() ?? '';
        state = state.copyWith(policyNumber: policyNo, policyDocumentUrl: docUrl);
        onSuccess(policyNo);
      } else {
        onError('Booking failed. Please contact support.');
      }
    } finally {
      _razorpay?.clear();
      _razorpay = null;
      state = state.copyWith(isLoading: false);
    }
  }

  void reset() => state = const InsuranceBookingState();

  @override
  void dispose() {
    _razorpay?.clear();
    super.dispose();
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/insurance/
git commit -m "feat(insurance): add datasource and booking state notifier"
```

---

## Task 3: Insurance Wizard Screen (Steps 1–4)

**Files:**
- Create: `lib/features/insurance/presentation/screens/insurance_wizard_screen.dart`

**Interfaces:**
- Consumes: `insuranceBookingProvider` from Task 2
- Produces: renders 4 steps, calls `context.go(RouteNames.insuranceConfirmation)` on success

- [ ] **Step 1: Create insurance_wizard_screen.dart with shared AppBar + step indicator**

The screen uses a `PageController` synced with `state.currentStep`. Each step is a separate private widget (`_Step1TripDetails`, `_Step2ChoosePlan`, `_Step3TravellerDetails`, `_Step4ReviewPay`) defined in the same file.

```dart
// lib/features/insurance/presentation/screens/insurance_wizard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/router/route_names.dart';
import '../providers/insurance_providers.dart';
import '../../data/models/insurance_models.dart';

class InsuranceWizardScreen extends ConsumerStatefulWidget {
  const InsuranceWizardScreen({super.key});
  @override
  ConsumerState<InsuranceWizardScreen> createState() => _InsuranceWizardScreenState();
}

class _InsuranceWizardScreenState extends ConsumerState<InsuranceWizardScreen> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _animateTo(int page) {
    _pageController.animateToPage(page,
        duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final state = ref.watch(insuranceBookingProvider);

    // Sync page on external step change (e.g. back button)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients &&
          _pageController.page?.round() != state.currentStep) {
        _animateTo(state.currentStep);
      }
    });

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: SafeArea(
        child: Column(
          children: [
            _AppBar(colors: colors, currentStep: state.currentStep),
            _StepIndicator(currentStep: state.currentStep, colors: colors),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _Step1TripDetails(colors: colors),
                  _Step2ChoosePlan(colors: colors),
                  _Step3TravellerDetails(colors: colors),
                  _Step4ReviewPay(colors: colors, onPaid: () => context.go(RouteNames.insuranceConfirmation)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────
class _AppBar extends ConsumerWidget {
  const _AppBar({required this.colors, required this.currentStep});
  final AppColorScheme colors;
  final int currentStep;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (currentStep == 0) {
                context.pop();
              } else {
                ref.read(insuranceBookingProvider.notifier).previousStep();
              }
            },
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: colors.surfaceCard,
                shape: BoxShape.circle,
                border: Border.all(color: colors.lineSoft),
              ),
              child: Icon(Icons.arrow_back, size: 18, color: colors.ink900),
            ),
          ),
          const SizedBox(width: 12),
          Text('Travel Insurance',
              style: AppTypography.displayMd.copyWith(color: colors.ink900, fontSize: 18)),
        ],
      ),
    );
  }
}

// ── Step indicator ────────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep, required this.colors});
  final int currentStep;
  final AppColorScheme colors;

  static const _labels = ['Trip', 'Plan', 'Traveller', 'Pay'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: List.generate(4, (i) {
          final isDone = i < currentStep;
          final isActive = i == currentStep;
          return Expanded(
            child: Row(
              children: [
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isDone ? AppColors.success : colors.lineSoft,
                    ),
                  ),
                Column(
                  children: [
                    Container(
                      width: 26, height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? AppColors.success
                            : isActive
                                ? colors.goldPrimary
                                : colors.surfaceTertiary,
                        border: Border.all(color: colors.surfacePrimary, width: 2),
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(Icons.check, size: 12, color: Colors.white)
                            : Text('${i + 1}',
                                style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w700,
                                  color: isActive ? colors.ink900 : colors.ink400,
                                )),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(_labels[i],
                        style: TextStyle(
                          fontSize: 8, fontWeight: FontWeight.w600,
                          letterSpacing: 0.02,
                          color: isActive ? colors.ink900 : colors.ink400,
                        )),
                  ],
                ),
                if (i < 3) const Spacer(),
              ],
            ),
          );
        }),
      ),
    );
  }
}
```

- [ ] **Step 2: Implement _Step1TripDetails**

```dart
class _Step1TripDetails extends ConsumerWidget {
  const _Step1TripDetails({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(insuranceBookingProvider);
    final notifier = ref.read(insuranceBookingProvider.notifier);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Trip Details', style: AppTypography.displayMd.copyWith(color: colors.ink900, fontSize: 18)),
              const SizedBox(height: 4),
              Text('Tell us about the trip you\'re insuring',
                  style: AppTypography.caption.copyWith(color: colors.ink600, fontSize: 12)),
              const SizedBox(height: 20),

              // Travel Category
              _FieldLabel('Travel Category', colors),
              _DropdownField(
                value: state.travelCategory.isEmpty ? null : state.travelCategory,
                hint: 'Select Category',
                items: InsuranceBookingNotifier.travelCategories,
                colors: colors,
                onChanged: notifier.setTravelCategory,
              ),

              // Country
              _FieldLabel('Country of Visit', colors),
              _DropdownField(
                value: state.country.isEmpty ? null : state.country,
                hint: 'Select Country',
                items: InsuranceBookingNotifier.countries,
                colors: colors,
                onChanged: notifier.setCountry,
              ),

              // Dates
              Row(
                children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _FieldLabel('Start Date', colors),
                    _DateField(
                      value: state.startDate,
                      hint: 'dd-mm-yyyy',
                      colors: colors,
                      onChanged: notifier.setStartDate,
                    ),
                  ])),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _FieldLabel('End Date', colors),
                    _DateField(
                      value: state.endDate,
                      hint: 'dd-mm-yyyy',
                      colors: colors,
                      onChanged: notifier.setEndDate,
                    ),
                  ])),
                ],
              ),

              // Number of travellers
              _FieldLabel('Number of Travellers', colors),
              _StepperField(
                value: state.numberOfTravellers,
                colors: colors,
                onDecrement: () { if (state.numberOfTravellers > 1) notifier.setNumberOfTravellers(state.numberOfTravellers - 1); },
                onIncrement: () => notifier.setNumberOfTravellers(state.numberOfTravellers + 1),
              ),

              // DOB per traveller
              ...List.generate(state.numberOfTravellers, (i) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel('Traveller ${i + 1} — Date of Birth', colors),
                  _DateField(
                    value: state.travellerDOBs.length > i ? state.travellerDOBs[i] : null,
                    hint: 'dd-mm-yyyy',
                    colors: colors,
                    onChanged: (d) => notifier.setTravellerDOB(i, d),
                  ),
                ],
              )),
            ],
          ),
        ),
        _NextButton(
          label: 'Next: Choose Plan',
          colors: colors,
          enabled: state.travelCategory.isNotEmpty &&
              state.country.isNotEmpty &&
              state.startDate != null &&
              state.endDate != null,
          onTap: () async {
            await ref.read(insuranceBookingProvider.notifier).fetchPlans();
            ref.read(insuranceBookingProvider.notifier).nextStep();
          },
        ),
      ],
    );
  }
}
```

- [ ] **Step 3: Implement _Step2ChoosePlan, _Step3TravellerDetails, _Step4ReviewPay**

```dart
class _Step2ChoosePlan extends ConsumerWidget {
  const _Step2ChoosePlan({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(insuranceBookingProvider);
    final notifier = ref.read(insuranceBookingProvider.notifier);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose Your Plan', style: AppTypography.displayMd.copyWith(color: colors.ink900, fontSize: 18)),
              const SizedBox(height: 4),
              Text('${state.country} · ${state.durationDays} days · ${state.numberOfTravellers} traveller(s)',
                  style: AppTypography.caption.copyWith(color: colors.ink600, fontSize: 12)),
              const SizedBox(height: 20),
              if (state.isLoadingPlans)
                const Center(child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ))
              else if (state.availablePlans.isEmpty)
                Center(child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text('No plans available for this selection.',
                      style: AppTypography.caption.copyWith(color: colors.ink600)),
                ))
              else
                ...state.availablePlans.map((plan) {
                  final isSelected = state.selectedPlan?.id == plan.id;
                  return _PlanCard(
                    plan: plan,
                    isSelected: isSelected,
                    colors: colors,
                    onTap: () => notifier.selectPlan(plan),
                  );
                }),
            ],
          ),
        ),
        _NextButton(
          label: 'Next: Traveller Details',
          colors: colors,
          enabled: state.selectedPlan != null,
          onTap: () => notifier.nextStep(),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.isSelected, required this.colors, required this.onTap});
  final InsurancePlan plan;
  final bool isSelected;
  final AppColorScheme colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // ponytail: coverage string derived from plan name heuristic (matches old app logic)
    String coverage = '';
    final n = plan.name.toLowerCase();
    if (n.contains('3 lac')) coverage = 'Coverage up to \$3,00,000';
    else if (n.contains('6 lac')) coverage = 'Coverage up to \$6,00,000';
    else if (n.contains('10 lac')) coverage = 'Coverage up to \$10,00,000';
    else if (n.contains('250k')) coverage = 'Coverage up to \$2,50,000';
    else if (n.contains('5 lac')) coverage = 'Coverage up to \$5,00,000';
    else if (n.contains('domestic')) coverage = 'Domestic travel coverage';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colors.goldPrimary : colors.lineSoft,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(plan.name,
                      style: AppTypography.displayMd.copyWith(color: colors.ink900, fontSize: 16)),
                ),
                Text('₹${plan.premium.toStringAsFixed(0)}',
                    style: AppTypography.displayMd.copyWith(color: colors.ink900, fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: isSelected ? colors.goldPrimary : colors.lineSoft, width: 2),
                    color: isSelected ? colors.goldPrimary : Colors.transparent,
                  ),
                ),
              ],
            ),
            if (coverage.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(coverage, style: AppTypography.caption.copyWith(color: colors.ink600, fontSize: 11)),
            ],
            const SizedBox(height: 12),
            ...plan.features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(Icons.check, size: 14, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(child: Text(f, style: AppTypography.caption.copyWith(color: colors.ink600, fontSize: 12))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _Step3TravellerDetails extends ConsumerStatefulWidget {
  const _Step3TravellerDetails({required this.colors});
  final AppColorScheme colors;
  @override
  ConsumerState<_Step3TravellerDetails> createState() => _Step3TravellerDetailsState();
}

class _Step3TravellerDetailsState extends ConsumerState<_Step3TravellerDetails> {
  int _currentTraveller = 0;

  // Controllers for current traveller — rebuilt when _currentTraveller changes
  late final Map<int, Map<String, TextEditingController>> _controllers = {};

  Map<String, TextEditingController> _ctrlsFor(int i) {
    return _controllers.putIfAbsent(i, () => {
      'fullName': TextEditingController(),
      'passportNo': TextEditingController(),
      'nationality': TextEditingController(text: 'Indian'),
      'email': TextEditingController(),
      'phone': TextEditingController(),
    });
  }

  @override
  void dispose() {
    for (final map in _controllers.values) {
      for (final c in map.values) c.dispose();
    }
    super.dispose();
  }

  void _saveCurrentTraveller() {
    final ctrl = _ctrlsFor(_currentTraveller);
    final state = ref.read(insuranceBookingProvider);
    final existing = state.travellerInfoList.length > _currentTraveller
        ? state.travellerInfoList[_currentTraveller]
        : TravellerInfo();
    ref.read(insuranceBookingProvider.notifier).updateTravellerInfo(
      _currentTraveller,
      TravellerInfo(
        fullName: ctrl['fullName']!.text,
        passportNo: ctrl['passportNo']!.text,
        nationality: ctrl['nationality']!.text,
        email: ctrl['email']!.text,
        phone: ctrl['phone']!.text,
        dateOfBirth: existing.dateOfBirth,
        medicalConditions: existing.medicalConditions,
        address: existing.address,
        district: existing.district,
        state: existing.state,
        city: existing.city,
        country: existing.country,
        pincode: existing.pincode,
        nominee: existing.nominee,
        relationship: existing.relationship,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(insuranceBookingProvider);
    final notifier = ref.read(insuranceBookingProvider.notifier);
    final colors = widget.colors;
    final ctrl = _ctrlsFor(_currentTraveller);
    final totalTravellers = state.numberOfTravellers;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Traveller ${_currentTraveller + 1} of $totalTravellers',
                  style: AppTypography.displayMd.copyWith(color: colors.ink900, fontSize: 18)),
              const SizedBox(height: 4),
              Text('${state.selectedPlan?.name ?? ''} · ₹${state.selectedPlan?.premium.toStringAsFixed(0) ?? ''} per traveller',
                  style: AppTypography.caption.copyWith(color: colors.ink600, fontSize: 12)),
              const SizedBox(height: 20),

              _FieldLabel('Full Name (as per Passport)', colors),
              _TextField(controller: ctrl['fullName']!, hint: 'e.g. Rakesh Sharma', colors: colors),

              _FieldLabel('Passport Number', colors),
              _TextField(controller: ctrl['passportNo']!, hint: 'e.g. P1234567', colors: colors),

              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _FieldLabel('Date of Birth', colors),
                  _TextField(
                    controller: TextEditingController(
                      text: state.travellerDOBs.length > _currentTraveller && state.travellerDOBs[_currentTraveller] != null
                          ? '${state.travellerDOBs[_currentTraveller]!.day.toString().padLeft(2,'0')}-${state.travellerDOBs[_currentTraveller]!.month.toString().padLeft(2,'0')}-${state.travellerDOBs[_currentTraveller]!.year}'
                          : '',
                    ),
                    hint: 'dd-mm-yyyy',
                    colors: colors,
                    readOnly: true,
                  ),
                ])),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _FieldLabel('Nationality', colors),
                  _TextField(controller: ctrl['nationality']!, hint: 'Indian', colors: colors),
                ])),
              ]),

              _FieldLabel('Email Address', colors),
              _TextField(controller: ctrl['email']!, hint: 'email@example.com', colors: colors, keyboardType: TextInputType.emailAddress),

              _FieldLabel('Phone Number', colors),
              _TextField(controller: ctrl['phone']!, hint: '+91 98765 43210', colors: colors, keyboardType: TextInputType.phone),

              _FieldLabel('Any Pre-Existing Medical Conditions?', colors),
              _DropdownField(
                value: state.travellerInfoList.length > _currentTraveller
                    ? state.travellerInfoList[_currentTraveller].medicalConditions
                    : 'No',
                hint: 'Select',
                items: const ['No', 'Yes'],
                colors: colors,
                onChanged: (v) {
                  _saveCurrentTraveller();
                  final updated = state.travellerInfoList.length > _currentTraveller
                      ? state.travellerInfoList[_currentTraveller]
                      : TravellerInfo();
                  updated.medicalConditions = v;
                  notifier.updateTravellerInfo(_currentTraveller, updated);
                },
              ),
            ],
          ),
        ),
        _NextButton(
          label: _currentTraveller < totalTravellers - 1
              ? 'Next Traveller'
              : 'Next: Review & Pay',
          colors: colors,
          enabled: true,
          onTap: () {
            _saveCurrentTraveller();
            if (_currentTraveller < totalTravellers - 1) {
              setState(() => _currentTraveller++);
            } else {
              notifier.nextStep();
            }
          },
        ),
      ],
    );
  }
}

class _Step4ReviewPay extends ConsumerWidget {
  const _Step4ReviewPay({required this.colors, required this.onPaid});
  final AppColorScheme colors;
  final VoidCallback onPaid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(insuranceBookingProvider);
    final notifier = ref.read(insuranceBookingProvider.notifier);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Review & Pay', style: AppTypography.displayMd.copyWith(color: colors.ink900, fontSize: 18)),
              const SizedBox(height: 4),
              Text('Check everything before you pay',
                  style: AppTypography.caption.copyWith(color: colors.ink600, fontSize: 12)),
              const SizedBox(height: 20),

              // Summary card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.lineSoft),
                ),
                child: Column(
                  children: [
                    _ReviewRow('Destination', state.country, colors),
                    if (state.startDate != null && state.endDate != null)
                      _ReviewRow('Travel Dates',
                          '${state.startDate!.day} – ${state.endDate!.day} ${_monthName(state.startDate!.month)} ${state.startDate!.year}',
                          colors),
                    _ReviewRow('Plan', state.selectedPlan?.name ?? '', colors),
                    _ReviewRow('Travellers', '${state.numberOfTravellers}', colors),
                    const Divider(height: 24),
                    _ReviewRow('Premium (×${state.numberOfTravellers})', '₹${state.totalPremium.toStringAsFixed(0)}', colors),
                    _ReviewRow('GST (18%)', '₹${state.gst.toStringAsFixed(0)}', colors),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: AppTypography.displayMd.copyWith(color: colors.ink900, fontSize: 15, fontWeight: FontWeight.w700)),
                        Text('₹${state.grandTotal.toStringAsFixed(0)}', style: AppTypography.displayMd.copyWith(color: colors.ink900, fontSize: 15, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text('Payment Method', style: AppTypography.label.copyWith(color: colors.ink900, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _PaymentMethodRow(method: 'card', label: 'Credit / Debit Card', icon: Icons.credit_card, selected: state.selectedPaymentMethod, colors: colors, onTap: () => notifier.setPaymentMethod('card')),
              const SizedBox(height: 8),
              _PaymentMethodRow(method: 'upi', label: 'UPI', icon: Icons.currency_rupee, selected: state.selectedPaymentMethod, colors: colors, onTap: () => notifier.setPaymentMethod('upi')),
            ],
          ),
        ),
        _NextButton(
          label: state.isLoading ? 'Processing…' : 'Pay ₹${state.grandTotal.toStringAsFixed(0)}',
          colors: colors,
          enabled: !state.isLoading,
          onTap: () => notifier.openRazorpay(
            onSuccess: (_) => onPaid(),
            onError: (msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg))),
          ),
        ),
      ],
    );
  }

  static String _monthName(int m) => const ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m];
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow(this.label, this.value, this.colors);
  final String label, value;
  final AppColorScheme colors;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: colors.ink600)),
        Text(value, style: TextStyle(fontSize: 12, color: colors.ink900, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

class _PaymentMethodRow extends StatelessWidget {
  const _PaymentMethodRow({required this.method, required this.label, required this.icon, required this.selected, required this.colors, required this.onTap});
  final String method, label, selected;
  final IconData icon;
  final AppColorScheme colors;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final isSelected = method == selected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? colors.goldPrimary.withValues(alpha: 0.06) : colors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? colors.goldPrimary : colors.lineSoft),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EEF5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: const Color(0xFF2A4A6B)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: colors.ink900))),
            Container(
              width: 18, height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? colors.goldPrimary : colors.lineSoft, width: 2),
                color: isSelected ? colors.goldPrimary : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Add shared helper widgets at bottom of file**

```dart
// Shared across steps — keep private, in same file
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label, this.colors);
  final String label;
  final AppColorScheme colors;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(label, style: AppTypography.label.copyWith(color: colors.ink900, fontSize: 12, fontWeight: FontWeight.w600)),
  );
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({this.value, required this.hint, required this.items, required this.colors, required this.onChanged});
  final String? value;
  final String hint;
  final List<String> items;
  final AppColorScheme colors;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    decoration: BoxDecoration(
      color: colors.surfaceCard,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: colors.lineSoft),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        hint: Text(hint, style: TextStyle(color: colors.ink400, fontSize: 13)),
        isExpanded: true,
        isDense: true,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: colors.ink900, fontSize: 13)))).toList(),
        onChanged: (v) { if (v != null) onChanged(v); },
      ),
    ),
  );
}

class _DateField extends StatelessWidget {
  const _DateField({required this.hint, required this.colors, required this.onChanged, this.value, this.readOnly = false});
  final String hint;
  final AppColorScheme colors;
  final void Function(DateTime) onChanged;
  final DateTime? value;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final text = value != null
        ? '${value!.day.toString().padLeft(2,'0')}-${value!.month.toString().padLeft(2,'0')}-${value!.year}'
        : '';
    return GestureDetector(
      onTap: readOnly ? null : () async {
        final d = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(1930),
          lastDate: DateTime(2100),
        );
        if (d != null) onChanged(d);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.lineSoft),
        ),
        child: Row(
          children: [
            Expanded(child: Text(
              text.isEmpty ? hint : text,
              style: TextStyle(color: text.isEmpty ? colors.ink400 : colors.ink900, fontSize: 13),
            )),
            if (!readOnly) Icon(Icons.calendar_today_outlined, size: 14, color: colors.ink400),
          ],
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({required this.controller, required this.hint, required this.colors, this.keyboardType, this.readOnly = false});
  final TextEditingController controller;
  final String hint;
  final AppColorScheme colors;
  final TextInputType? keyboardType;
  final bool readOnly;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    readOnly: readOnly,
    keyboardType: keyboardType,
    style: TextStyle(fontSize: 13, color: colors.ink900),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: colors.ink400, fontSize: 13),
      filled: true,
      fillColor: colors.surfaceCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.lineSoft)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.lineSoft)),
    ),
  );
}

class _StepperField extends StatelessWidget {
  const _StepperField({required this.value, required this.colors, required this.onDecrement, required this.onIncrement});
  final int value;
  final AppColorScheme colors;
  final VoidCallback onDecrement, onIncrement;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(
      color: colors.surfaceCard,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: colors.lineSoft),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: onDecrement,
          child: Container(
            width: 30, height: 30,
            decoration: BoxDecoration(shape: BoxShape.circle, color: colors.surfaceTertiary),
            child: Icon(Icons.remove, size: 14, color: colors.ink900),
          ),
        ),
        Text('$value', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.ink900)),
        GestureDetector(
          onTap: onIncrement,
          child: Container(
            width: 30, height: 30,
            decoration: BoxDecoration(shape: BoxShape.circle, color: colors.surfaceTertiary),
            child: Icon(Icons.add, size: 14, color: colors.ink900),
          ),
        ),
      ],
    ),
  );
}

class _NextButton extends StatelessWidget {
  const _NextButton({required this.label, required this.colors, required this.enabled, required this.onTap});
  final String label;
  final AppColorScheme colors;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Positioned(
    bottom: 20, left: 20, right: 20,
    child: GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: enabled ? colors.goldPrimary : colors.lineSoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: enabled ? colors.ink900 : colors.ink400),
        )),
      ),
    ),
  );
}
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/insurance/presentation/screens/insurance_wizard_screen.dart
git commit -m "feat(insurance): add 4-step wizard screen"
```

---

## Task 4: Insurance Confirmation Screen

**Files:**
- Create: `lib/features/insurance/presentation/screens/insurance_confirmation_screen.dart`

**Interfaces:**
- Consumes: `insuranceBookingProvider` (reads `policyNumber`, `policyDocumentUrl`)
- Produces: confirmation UI; calls `ref.read(insuranceBookingProvider.notifier).reset()` on "Done"

- [ ] **Step 1: Create insurance_confirmation_screen.dart**

```dart
// lib/features/insurance/presentation/screens/insurance_confirmation_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/router/route_names.dart';
import '../providers/insurance_providers.dart';

class InsuranceConfirmationScreen extends ConsumerWidget {
  const InsuranceConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final state = ref.watch(insuranceBookingProvider);

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(30, 80, 30, 30),
          child: Column(
            children: [
              // Green check icon
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withValues(alpha: 0.12),
                ),
                child: Icon(Icons.verified_outlined, size: 40, color: AppColors.success),
              ),
              const SizedBox(height: 24),
              Text('Policy Issued',
                  style: AppTypography.displayMd.copyWith(color: colors.ink900, fontSize: 22)),
              const SizedBox(height: 8),
              Text(
                'Your travel insurance is confirmed. A confirmation has been sent to you.',
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(color: colors.ink600, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 28),

              // Policy details card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.lineSoft),
                ),
                child: Column(
                  children: [
                    if (state.policyNumber.isNotEmpty)
                      _ConfRow('Policy Number', state.policyNumber, colors),
                    _ConfRow('Plan', state.selectedPlan?.name ?? '', colors),
                    if (state.startDate != null && state.endDate != null)
                      _ConfRow('Valid',
                          '${state.startDate!.day} – ${state.endDate!.day} ${_monthName(state.startDate!.month)} ${state.startDate!.year}',
                          colors, last: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Download PDF
              if (state.policyDocumentUrl.isNotEmpty)
                _ActionButton(
                  label: 'Download Policy PDF',
                  colors: colors,
                  filled: true,
                  onTap: () => launchUrl(Uri.parse(state.policyDocumentUrl)),
                ),
              const SizedBox(height: 10),
              _ActionButton(
                label: 'Done',
                colors: colors,
                filled: false,
                onTap: () {
                  ref.read(insuranceBookingProvider.notifier).reset();
                  context.go(RouteNames.services);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _monthName(int m) => const ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m];
}

class _ConfRow extends StatelessWidget {
  const _ConfRow(this.label, this.value, this.colors, {this.last = false});
  final String label, value;
  final AppColorScheme colors;
  final bool last;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: last ? null : BoxDecoration(border: Border(bottom: BorderSide(color: colors.lineSoft))),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: colors.ink600)),
        Text(value, style: TextStyle(fontSize: 12, color: colors.ink900, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.colors, required this.filled, required this.onTap});
  final String label;
  final AppColorScheme colors;
  final bool filled;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: filled ? colors.goldPrimary : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: filled ? null : Border.all(color: colors.lineSoft),
      ),
      child: Center(child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: filled ? colors.ink900 : colors.ink900),
      )),
    ),
  );
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/insurance/presentation/screens/insurance_confirmation_screen.dart
git commit -m "feat(insurance): add confirmation / policy issued screen"
```

---

## Task 5: Visa Models + Remote Datasource + Providers

**Files:**
- Create: `lib/features/visa/data/models/visa_models.dart`
- Create: `lib/features/visa/data/datasources/visa_remote_datasource.dart`
- Create: `lib/features/visa/presentation/providers/visa_providers.dart`

**Interfaces:**
- Produces: `VisaApplicationState`, `visaApplicationProvider` consumed by Task 6

- [ ] **Step 1: Create visa_models.dart**

```dart
// lib/features/visa/data/models/visa_models.dart
import 'dart:io';

enum VisaDocType { passportCopy, passportPhoto, flightItinerary, bankStatement }

class VisaDoc {
  final VisaDocType type;
  final String label;
  final String fieldName; // multipart field name for backend
  File? file;

  VisaDoc({required this.type, required this.label, required this.fieldName, this.file});

  bool get isUploaded => file != null;

  static List<VisaDoc> defaultDocs() => [
    VisaDoc(type: VisaDocType.passportCopy,   label: 'Passport Copy',    fieldName: 'passport_documentUrl'),
    VisaDoc(type: VisaDocType.passportPhoto,  label: 'Passport Photo',   fieldName: 'documentUrl'),
    VisaDoc(type: VisaDocType.flightItinerary, label: 'Flight Itinerary', fieldName: 'flightbook_documentUrl'),
    VisaDoc(type: VisaDocType.bankStatement,  label: 'Bank Statement',   fieldName: 'bankstatement_documentUrl'),
  ];
}

class VisaApplicationState {
  final int currentStep;
  // Step 1: Personal Info
  final String fullName;
  final DateTime? dateOfBirth;
  final String nationality;
  final String passportNumber;
  final DateTime? passportExpiry;
  final String email;
  final String phone;
  // Step 2: Travel Details
  final String destinationCountry;
  final String visaType;
  final DateTime? travelDate;
  final String durationOfStay;
  final String purposeOfVisit;
  final String accommodationAddress;
  // Step 3: Documents
  final List<VisaDoc> documents;
  // Submission
  final bool isLoading;
  final String applicationId;

  const VisaApplicationState({
    this.currentStep = 0,
    this.fullName = '',
    this.dateOfBirth,
    this.nationality = 'Indian',
    this.passportNumber = '',
    this.passportExpiry,
    this.email = '',
    this.phone = '',
    this.destinationCountry = '',
    this.visaType = '',
    this.travelDate,
    this.durationOfStay = '',
    this.purposeOfVisit = '',
    this.accommodationAddress = '',
    this.documents = const [],
    this.isLoading = false,
    this.applicationId = '',
  });

  int get uploadedCount => documents.where((d) => d.isUploaded).length;

  VisaApplicationState copyWith({
    int? currentStep,
    String? fullName,
    DateTime? dateOfBirth,
    String? nationality,
    String? passportNumber,
    DateTime? passportExpiry,
    String? email,
    String? phone,
    String? destinationCountry,
    String? visaType,
    DateTime? travelDate,
    String? durationOfStay,
    String? purposeOfVisit,
    String? accommodationAddress,
    List<VisaDoc>? documents,
    bool? isLoading,
    String? applicationId,
  }) =>
      VisaApplicationState(
        currentStep: currentStep ?? this.currentStep,
        fullName: fullName ?? this.fullName,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        nationality: nationality ?? this.nationality,
        passportNumber: passportNumber ?? this.passportNumber,
        passportExpiry: passportExpiry ?? this.passportExpiry,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        destinationCountry: destinationCountry ?? this.destinationCountry,
        visaType: visaType ?? this.visaType,
        travelDate: travelDate ?? this.travelDate,
        durationOfStay: durationOfStay ?? this.durationOfStay,
        purposeOfVisit: purposeOfVisit ?? this.purposeOfVisit,
        accommodationAddress: accommodationAddress ?? this.accommodationAddress,
        documents: documents ?? this.documents,
        isLoading: isLoading ?? this.isLoading,
        applicationId: applicationId ?? this.applicationId,
      );
}
```

- [ ] **Step 2: Create visa_remote_datasource.dart**

Note: The visa endpoint is at `twoappbackend.onrender.com/api/visa/addVisaToSheet` as a **direct URL**, not a relative path. Use `Dio` with FormData.

```dart
// lib/features/visa/data/datasources/visa_remote_datasource.dart
import 'dart:math';
import 'package:dio/dio.dart';
import '../models/visa_models.dart';

class VisaRemoteDatasource {
  const VisaRemoteDatasource(this._dio);
  final Dio _dio;

  static const _endpoint = 'https://twoappbackend.onrender.com/api/visa/addVisaToSheet';

  Future<String> submitApplication({
    required Map<String, String> fields,
    required List<VisaDoc> documents,
  }) async {
    final formFields = <String, dynamic>{...fields};
    for (final doc in documents) {
      if (doc.file != null) {
        formFields[doc.fieldName] = await MultipartFile.fromFile(
          doc.file!.path,
          filename: doc.file!.path.split('/').last,
        );
      }
    }
    final formData = FormData.fromMap(formFields);
    final response = await _dio.post(_endpoint, data: formData);
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Backend returns application ID or just 200 OK
      final id = 'TWO-VISA-${Random().nextInt(90000) + 10000}'; // ponytail: local ID until backend returns one
      return id;
    }
    throw Exception('Visa submission failed: ${response.statusCode}');
  }
}
```

- [ ] **Step 3: Create visa_providers.dart**

```dart
// lib/features/visa/presentation/providers/visa_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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

const _visaTypes = ['Transit Visa', 'Tourist Visa', 'Business Visa', 'Employment Visa', 'Student Visa', 'Research Visa'];

class VisaApplicationNotifier extends StateNotifier<VisaApplicationState> {
  VisaApplicationNotifier(this._ds)
      : super(VisaApplicationState(documents: VisaDoc.defaultDocs()));
  final VisaRemoteDatasource _ds;
  final _picker = ImagePicker();

  static const visaTypes = _visaTypes;

  void goToStep(int step) => state = state.copyWith(currentStep: step);
  void nextStep() { if (state.currentStep < 3) state = state.copyWith(currentStep: state.currentStep + 1); }
  void previousStep() { if (state.currentStep > 0) state = state.copyWith(currentStep: state.currentStep - 1); }

  // Step 1 setters
  void setFullName(String v) => state = state.copyWith(fullName: v);
  void setDateOfBirth(DateTime v) => state = state.copyWith(dateOfBirth: v);
  void setNationality(String v) => state = state.copyWith(nationality: v);
  void setPassportNumber(String v) => state = state.copyWith(passportNumber: v);
  void setPassportExpiry(DateTime v) => state = state.copyWith(passportExpiry: v);
  void setEmail(String v) => state = state.copyWith(email: v);
  void setPhone(String v) => state = state.copyWith(phone: v);

  // Step 2 setters
  void setDestinationCountry(String v) => state = state.copyWith(destinationCountry: v);
  void setVisaType(String v) => state = state.copyWith(visaType: v);
  void setTravelDate(DateTime v) => state = state.copyWith(travelDate: v);
  void setDurationOfStay(String v) => state = state.copyWith(durationOfStay: v);
  void setPurposeOfVisit(String v) => state = state.copyWith(purposeOfVisit: v);
  void setAccommodationAddress(String v) => state = state.copyWith(accommodationAddress: v);

  // Step 3: pick file for a document slot
  Future<void> pickDocument(int index) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    final docs = List<VisaDoc>.from(state.documents);
    docs[index] = VisaDoc(
      type: docs[index].type,
      label: docs[index].label,
      fieldName: docs[index].fieldName,
      file: File(picked.path),
    );
    state = state.copyWith(documents: docs);
  }

  // Step 4: Submit
  Future<void> submit({
    required void Function(String applicationId) onSuccess,
    required void Function(String msg) onError,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final s = state;
      final fields = <String, String>{
        'fname': s.fullName.split(' ').first,
        'lname': s.fullName.split(' ').length > 1 ? s.fullName.split(' ').skip(1).join(' ') : '',
        'email': s.email,
        'phone': s.phone,
        'visaType': s.visaType,
        'countryName': s.destinationCountry,
        'country': s.destinationCountry,
        'purposeOfVisit': s.purposeOfVisit,
        'accommodationAddress': s.accommodationAddress,
        'durationOfStay': s.durationOfStay,
        if (s.passportNumber.isNotEmpty) 'passportNumber': s.passportNumber,
      };
      final appId = await _ds.submitApplication(fields: fields, documents: state.documents);
      state = state.copyWith(applicationId: appId);
      onSuccess(appId);
    } catch (e) {
      onError('Submission failed. Please try again.');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void reset() => state = VisaApplicationState(documents: VisaDoc.defaultDocs());
}
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/visa/
git commit -m "feat(visa): add models, datasource, and application state notifier"
```

---

## Task 6: Visa Wizard Screen (Steps 1–4) + Confirmation

**Files:**
- Create: `lib/features/visa/presentation/screens/visa_wizard_screen.dart`
- Create: `lib/features/visa/presentation/screens/visa_confirmation_screen.dart`

**Interfaces:**
- Consumes: `visaApplicationProvider` from Task 5
- Produces: same step-indicator + form pattern as insurance, calls `context.go(RouteNames.visaConfirmation)` on success

- [ ] **Step 1: Create visa_wizard_screen.dart**

Structure mirrors insurance wizard. Steps: Personal Info, Travel Details, Document Upload, Review & Submit.

```dart
// lib/features/visa/presentation/screens/visa_wizard_screen.dart
// [Structure identical to insurance_wizard_screen.dart — same AppBar, _StepIndicator, PageView]
// Steps: _VisaStep1Personal, _VisaStep2Travel, _VisaStep3Docs, _VisaStep4Review
// Step labels: 'Personal', 'Travel', 'Docs', 'Submit'

class VisaWizardScreen extends ConsumerStatefulWidget {
  const VisaWizardScreen({super.key});
  @override
  ConsumerState<VisaWizardScreen> createState() => _VisaWizardScreenState();
}

class _VisaWizardScreenState extends ConsumerState<VisaWizardScreen> {
  final _pageController = PageController();

  @override
  void dispose() { _pageController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final state = ref.watch(visaApplicationProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients && _pageController.page?.round() != state.currentStep) {
        _pageController.animateToPage(state.currentStep,
            duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
      }
    });

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: SafeArea(
        child: Column(
          children: [
            _VisaAppBar(colors: colors, currentStep: state.currentStep),
            _VisaStepIndicator(currentStep: state.currentStep, colors: colors),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _VisaStep1Personal(colors: colors),
                  _VisaStep2Travel(colors: colors),
                  _VisaStep3Docs(colors: colors),
                  _VisaStep4Review(
                    colors: colors,
                    onSubmitted: () => context.go(RouteNames.visaConfirmation),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Implement _VisaStep1Personal**

Fields: Full Name, Date of Birth, Nationality, Passport Number, Passport Expiry, Email, Phone. All use the same `_TextField` and `_DateField` helpers (copy into visa_wizard_screen.dart — they are private widgets, not extracted).

Next button enabled when `fullName`, `passportNumber`, `email`, `phone` are non-empty.

- [ ] **Step 3: Implement _VisaStep2Travel**

Fields: Destination Country (text field), Visa Type (dropdown from `VisaApplicationNotifier.visaTypes`), Travel Date (date picker), Duration of Stay (text), Purpose of Visit (text), Accommodation Address (text).

Next button enabled when `destinationCountry` and `visaType` are non-empty.

- [ ] **Step 4: Implement _VisaStep3Docs — Document Upload**

For each `VisaDoc` in `state.documents`, show a row:
- Green icon + "Uploaded · filename" if `isUploaded`
- Grey upload icon + label + "Required" if not uploaded
- Tap on "Upload" / "Replace" calls `notifier.pickDocument(index)`

```dart
class _VisaStep3Docs extends ConsumerWidget {
  const _VisaStep3Docs({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(visaApplicationProvider);
    final notifier = ref.read(visaApplicationProvider.notifier);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Upload Documents', style: AppTypography.displayMd.copyWith(color: colors.ink900, fontSize: 18)),
              const SizedBox(height: 4),
              Text('${state.uploadedCount} of ${state.documents.length} documents uploaded',
                  style: AppTypography.caption.copyWith(color: colors.ink600, fontSize: 12)),
              const SizedBox(height: 20),
              ...state.documents.asMap().entries.map((entry) {
                final i = entry.key;
                final doc = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.surfaceCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.lineSoft),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: doc.isUploaded
                              ? AppColors.success.withValues(alpha: 0.12)
                              : colors.surfaceTertiary,
                        ),
                        child: Icon(
                          doc.isUploaded ? Icons.check : Icons.upload_outlined,
                          size: 18,
                          color: doc.isUploaded ? AppColors.success : colors.ink400,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doc.label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: colors.ink900)),
                          const SizedBox(height: 2),
                          Text(
                            doc.isUploaded
                                ? 'Uploaded · ${doc.file!.path.split('/').last}'
                                : 'Required',
                            style: TextStyle(
                              fontSize: 11,
                              color: doc.isUploaded ? AppColors.success : colors.ink400,
                            ),
                          ),
                        ],
                      )),
                      GestureDetector(
                        onTap: () => notifier.pickDocument(i),
                        child: Text(
                          doc.isUploaded ? 'Replace' : 'Upload',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.goldPrimary),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        _NextButton(
          label: 'Next: Review & Submit',
          colors: colors,
          enabled: true, // allow partial upload — user may not have all docs
          onTap: () => notifier.nextStep(),
        ),
      ],
    );
  }
}
```

- [ ] **Step 5: Implement _VisaStep4Review**

```dart
class _VisaStep4Review extends ConsumerWidget {
  const _VisaStep4Review({required this.colors, required this.onSubmitted});
  final AppColorScheme colors;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(visaApplicationProvider);
    final notifier = ref.read(visaApplicationProvider.notifier);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Review & Submit', style: AppTypography.displayMd.copyWith(color: colors.ink900, fontSize: 18)),
              const SizedBox(height: 4),
              Text('Please check everything carefully',
                  style: AppTypography.caption.copyWith(color: colors.ink600, fontSize: 12)),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: colors.surfaceCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: colors.lineSoft)),
                child: Column(children: [
                  _ReviewRow('Applicant', state.fullName, colors),
                  _ReviewRow('Passport No.', state.passportNumber, colors),
                  const Divider(height: 16),
                  _ReviewRow('Destination', state.destinationCountry, colors),
                  _ReviewRow('Visa Type', state.visaType, colors),
                  if (state.travelDate != null)
                    _ReviewRow('Travel Date', '${state.travelDate!.day} ${_monthName(state.travelDate!.month)} ${state.travelDate!.year}', colors),
                  const Divider(height: 16),
                  _ReviewRow('Documents', '${state.uploadedCount} of ${state.documents.length} uploaded', colors, last: true),
                ]),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EEF5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'By submitting, you confirm all information and documents provided are true and accurate. Processing fees are non-refundable once submitted to the embassy.',
                  style: TextStyle(fontSize: 11, color: const Color(0xFF2A4A6B), height: 1.5),
                ),
              ),
            ],
          ),
        ),
        _NextButton(
          label: state.isLoading ? 'Submitting…' : 'Submit Application',
          colors: colors,
          enabled: !state.isLoading,
          onTap: () => notifier.submit(
            onSuccess: (_) => onSubmitted(),
            onError: (msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg))),
          ),
        ),
      ],
    );
  }

  static String _monthName(int m) => const ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m];
}
```

- [ ] **Step 6: Create visa_confirmation_screen.dart**

```dart
// lib/features/visa/presentation/screens/visa_confirmation_screen.dart
// Mirror of InsuranceConfirmationScreen. Reads visaApplicationProvider state.
// Shows: Application ID, Destination, Submitted date, Processing time (5–7 business days)
// Buttons: "Track Application Status" (no-op for now), "Done" → reset + go(RouteNames.services)

class VisaConfirmationScreen extends ConsumerWidget {
  const VisaConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final state = ref.watch(visaApplicationProvider);

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(30, 80, 30, 30),
          child: Column(
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.success.withValues(alpha: 0.12)),
                child: Icon(Icons.verified_outlined, size: 40, color: AppColors.success),
              ),
              const SizedBox(height: 24),
              Text('Application Submitted', style: AppTypography.displayMd.copyWith(color: colors.ink900, fontSize: 22)),
              const SizedBox(height: 8),
              Text('Your visa application has been received and is being processed.',
                  textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(color: colors.ink600, fontSize: 13, height: 1.5)),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: colors.surfaceCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: colors.lineSoft)),
                child: Column(children: [
                  _ConfRow('Application ID', state.applicationId.isEmpty ? 'Pending' : state.applicationId, colors),
                  _ConfRow('Destination', state.destinationCountry, colors),
                  _ConfRow('Submitted', _today(), colors),
                  _ConfRow('Processing Time', '5–7 business days', colors, last: true),
                ]),
              ),
              const SizedBox(height: 24),
              _ActionButton(label: 'Track Application Status', colors: colors, filled: true, onTap: () {}),
              const SizedBox(height: 10),
              _ActionButton(
                label: 'Done',
                colors: colors,
                filled: false,
                onTap: () {
                  ref.read(visaApplicationProvider.notifier).reset();
                  context.go(RouteNames.services);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _today() {
    final d = DateTime.now();
    const months = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month]} ${d.year}';
  }
}
```

- [ ] **Step 7: Commit**

```bash
git add lib/features/visa/
git commit -m "feat(visa): add 4-step wizard and confirmation screens"
```

---

## Task 7: Router + Services Screen Wiring

**Files:**
- Modify: `lib/core/router/route_names.dart`
- Modify: `lib/core/router/app_router.dart`
- Modify: `lib/features/services/presentation/screens/services_screen.dart`

**Interfaces:**
- Consumes: new screen classes from Tasks 3, 4, 6
- Produces: fully navigable Insurance and Visa flows from Services tab

- [ ] **Step 1: Add route constants to route_names.dart**

```dart
// In RouteNames class, add:
static const insurance = '/services/insurance';
static const insuranceConfirmation = '/services/insurance/confirmation';
static const visa = '/services/visa';
static const visaConfirmation = '/services/visa/confirmation';
```

- [ ] **Step 2: Register GoRoutes in app_router.dart**

Add the following GoRoute entries in the router under the existing `services` route (or alongside it). Because these need to live under the shell that has the bottom nav, they should be sibling GoRoutes or nested — check current `/services` route structure and match it.

```dart
// Add imports at top:
import '../../features/insurance/presentation/screens/insurance_wizard_screen.dart';
import '../../features/insurance/presentation/screens/insurance_confirmation_screen.dart';
import '../../features/visa/presentation/screens/visa_wizard_screen.dart';
import '../../features/visa/presentation/screens/visa_confirmation_screen.dart';

// Add GoRoutes (full-screen, no bottom nav shell):
GoRoute(
  path: RouteNames.insurance,
  builder: (_, __) => const InsuranceWizardScreen(),
),
GoRoute(
  path: RouteNames.insuranceConfirmation,
  builder: (_, __) => const InsuranceConfirmationScreen(),
),
GoRoute(
  path: RouteNames.visa,
  builder: (_, __) => const VisaWizardScreen(),
),
GoRoute(
  path: RouteNames.visaConfirmation,
  builder: (_, __) => const VisaConfirmationScreen(),
),
```

- [ ] **Step 3: Wire Services screen buttons**

In `lib/features/services/presentation/screens/services_screen.dart`, update the `onAction` callbacks:

```dart
// Insurance card:
onAction: () => context.push(RouteNames.insurance),

// Visa card:
onAction: () => context.push(RouteNames.visa),
```

Remove the `_insuranceUrl` constant and `url_launcher` import for insurance (the webview approach is replaced by the in-app wizard).

- [ ] **Step 4: Commit**

```bash
git add lib/core/router/ lib/features/services/
git commit -m "feat(services): wire insurance and visa wizards into router and services screen"
```

---

## Self-Review Checklist

**Spec coverage:**
- [x] Insurance: 4 steps (Trip, Plan, Traveller, Pay) + Policy Issued confirmation
- [x] Insurance: step indicator with done/active/pending states, gold active, green done
- [x] Insurance: plan cards with radio, coverage text, feature list, Most Popular badge (skipped: badge is just first plan; add if needed)
- [x] Insurance: review card with GST calculation, payment method selection
- [x] Insurance: Razorpay integration for actual payment
- [x] Visa: 4 steps (Personal, Travel, Docs, Submit) + Application Submitted confirmation
- [x] Visa: document upload rows with done/pending state, Replace/Upload action
- [x] Visa: disclaimer note on step 4
- [x] Both: back button navigates between steps, not exiting the screen
- [x] Both: Next button disabled when required fields empty

**Skipped (YAGNI):**
- Most Popular badge logic (can trivially add in Task 3 if needed)
- Wallet Balance payment method (Razorpay handles this — no need for custom wallet balance display)
- "Track Application Status" screen for visa (no backend endpoint exists for status tracking yet)
- `file_picker` (using `image_picker.pickImage` which covers the document photo use case; actual PDF upload would need `file_picker` — add that package if the user needs PDF uploads)

---

## Execution Options

Plan complete and saved to `docs/superpowers/plans/2026-06-29-services-insurance-visa-wizards.md`.

**Two execution options:**

**1. Subagent-Driven (recommended)** — Fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** — Execute tasks in this session using `superpowers:executing-plans`
