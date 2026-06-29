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

// ── Category / country display → backend code maps ─────────────────────────

const _categoryCodeMap = {
  'Domestic Travel Document': 'de5ee71c-098f-4cc0-b486-e69391cc9fa8',
  'Overseas Travel':          '6b123144-2e3a-490e-baeb-b59f09327b7c',
};

const _countryCodeMap = {
  'Excluding USA and Canada':              '2',
  'Including USA and Canada (Worldwide)':  '1',
  'India':                                 '4',
};

// ── Notifier ───────────────────────────────────────────────────────────────

class InsuranceBookingNotifier extends StateNotifier<InsuranceBookingState> {
  InsuranceBookingNotifier(this._ds) : super(const InsuranceBookingState());
  final InsuranceRemoteDatasource _ds;
  Razorpay? _razorpay;

  static const travelCategories = [
    'Domestic Travel Document',
    'Overseas Travel',
  ];

  static const countries = [
    'Excluding USA and Canada',
    'Including USA and Canada (Worldwide)',
    'India',
  ];

  String get _categoryCode =>
      _categoryCodeMap[state.travelCategory] ?? state.travelCategory;

  String get _countryCode =>
      _countryCodeMap[state.country] ?? state.country;

  // ── Helpers ───────────────────────────────────────────────────────────────

  static String fmtIsoDate(DateTime? d) {
    if (d == null) return '';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static String fmtApiDate(DateTime? d) {
    if (d == null) return '';
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day.toString().padLeft(2, '0')}-${months[d.month]}-${d.year}';
  }

  static int calcAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  // ── Step navigation ───────────────────────────────────────────────────────

  void goToStep(int step) => state = state.copyWith(currentStep: step);
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

  // ── Step 1 mutations ──────────────────────────────────────────────────────

  void setTravelCategory(String v) => state = state.copyWith(travelCategory: v);
  void setCountry(String v) => state = state.copyWith(country: v);
  void setStartDate(DateTime d) => state = state.copyWith(startDate: d);
  void setEndDate(DateTime d) => state = state.copyWith(endDate: d);

  void setNumberOfTravellers(int count) {
    final dobs = List<DateTime?>.from(state.travellerDOBs);
    final infos = List<TravellerInfo>.from(state.travellerInfoList);
    while (dobs.length < count) { dobs.add(null); }
    while (dobs.length > count) { dobs.removeLast(); }
    while (infos.length < count) { infos.add(TravellerInfo()); }
    while (infos.length > count) { infos.removeLast(); }
    state = state.copyWith(
        numberOfTravellers: count,
        travellerDOBs: dobs,
        travellerInfoList: infos);
  }

  void setTravellerDOB(int index, DateTime dob) {
    final dobs = List<DateTime?>.from(state.travellerDOBs);
    final infos = List<TravellerInfo>.from(state.travellerInfoList);
    if (index < dobs.length) dobs[index] = dob;
    if (index < infos.length) infos[index].dateOfBirth = fmtApiDate(dob);
    state = state.copyWith(travellerDOBs: dobs, travellerInfoList: infos);
  }

  // ── Step 2 ────────────────────────────────────────────────────────────────

  Future<void> fetchPlans() async {
    state = state.copyWith(
        isLoadingPlans: true, clearSelectedPlan: true, availablePlans: []);
    final ages = state.travellerDOBs
        .map((d) => d != null ? calcAge(d) : 25)
        .toList();
    final plans = await _ds.fetchPlans(
      travelCategory: _categoryCode,
      country: _countryCode,
      startDate: fmtIsoDate(state.startDate),
      endDate: fmtIsoDate(state.endDate),
      numberOfTravellers: state.numberOfTravellers,
      travellerAges: ages,
      durationDays: state.durationDays,
    );
    state = state.copyWith(availablePlans: plans, isLoadingPlans: false);
  }

  void selectPlan(InsurancePlan plan) => state = state.copyWith(selectedPlan: plan);

  // ── Step 3 ────────────────────────────────────────────────────────────────

  void updateTravellerInfo(int index, TravellerInfo info) {
    final list = List<TravellerInfo>.from(state.travellerInfoList);
    if (index < list.length) list[index] = info;
    state = state.copyWith(travellerInfoList: list);
  }


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
        state = state.copyWith(isLoading: false);
        onError('Could not create payment order. Try again.');
        return;
      }
      final traveller = state.travellerInfoList.isNotEmpty
          ? state.travellerInfoList[0]
          : TravellerInfo();
      _razorpay = Razorpay();
      _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS,
          (PaymentSuccessResponse r) async {
        await _handlePaymentSuccess(r, onSuccess: onSuccess, onError: onError);
      });
      _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR,
          (PaymentFailureResponse r) {
        state = state.copyWith(isLoading: false);
        onError(r.message ?? 'Payment failed');
      });
      _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, (_) {});
      _razorpay!.open({
        'key': 'rzp_live_SJyy6qt0I2DKtU',
        'amount': (state.grandTotal * 100).toInt(),
        'order_id': orderData['id'] ?? '',
        'name': 'Travel World Online',
        'description': 'Insurance: ${plan.name}',
        'prefill': {
          'contact': traveller.phone,
          'email': traveller.email,
        },
        'external': {'wallets': ['paytm']},
      });
    } catch (e) {
      state = state.copyWith(isLoading: false);
      onError('Could not open payment. Try again.');
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
      final traveller = state.travellerInfoList.isNotEmpty
          ? state.travellerInfoList[0]
          : TravellerInfo();
      final dob =
          state.travellerDOBs.isNotEmpty ? state.travellerDOBs[0] : null;
      final planCode = plan.id.split('_').first;

      final body = {
        'plan': {
          'categorycode': _categoryCode,
          'plancode': planCode,
          'basecharges': state.grandTotal,
          'totalbasecharges': (state.grandTotal / 1.18).toStringAsFixed(2),
          'servicetax':
              (state.grandTotal - state.grandTotal / 1.18).toStringAsFixed(2),
          'totalcharges': state.grandTotal,
        },
        'traveldetails': {
          'departuredate': fmtApiDate(state.startDate),
          'days': state.durationDays,
          'arrivaldate': fmtApiDate(state.endDate),
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
          'age': dob != null ? calcAge(dob) : 0,
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
        state = state.copyWith(
          policyNumber: result['policyNumber']?.toString().trim() ?? '',
          policyDocumentUrl: result['documentUrl']?.toString().trim() ?? '',
        );
        onSuccess(state.policyNumber);
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
