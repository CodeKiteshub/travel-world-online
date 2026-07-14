import 'package:dio/dio.dart';
import '../../../discover/data/models/deal_model.dart';
import '../models/luxury_hotel_model.dart';
import '../models/villa_city_model.dart';
import '../models/villa_rate_model.dart';
import '../models/villa_rate_plan_model.dart';

class MarketplaceRemoteDatasource {
  const MarketplaceRemoteDatasource(this._dio);

  final Dio _dio;

  // ── Packages ────────────────────────────────────────────────────────────────

  Future<List<Deal>> fetchDeals() async {
    final response = await _dio.get('/api/package/getFeaturedPackages');
    final data = response.data;
    final List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map<String, dynamic>) {
      list = data['data'] as List<dynamic>? ??
          data['packages'] as List<dynamic>? ??
          [];
    } else {
      list = [];
    }
    return list.cast<Map<String, dynamic>>().map(Deal.fromJson).toList();
  }

  Future<List<Deal>> fetchMyPackages() async {
    final response = await _dio.get('/api/package/mypackages');
    final data = response.data;
    final List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map<String, dynamic>) {
      list = data['data'] as List<dynamic>? ??
          data['packages'] as List<dynamic>? ??
          [];
    } else {
      list = [];
    }
    return list.cast<Map<String, dynamic>>().map(Deal.fromJson).toList();
  }

  Future<void> submitTailorMade(Map<String, dynamic> data) async {
    await _dio.post('/api/tailer-made/add', data: data);
  }

  // ── Luxury Hotels ───────────────────────────────────────────────────────────

  Future<List<LuxuryHotelModel>> fetchLuxuryHotels() async {
    final response = await _dio.get('/api/LaxuryHotel/getLaxuryHotel');
    final data = response.data as Map<String, dynamic>;
    final list = data['hotels'] as List<dynamic>? ?? [];
    return list
        .cast<Map<String, dynamic>>()
        .map(LuxuryHotelModel.fromJson)
        .toList();
  }

  // ── Form submissions ────────────────────────────────────────────────────────

  Future<void> submitTrainEnquiry(Map<String, String> fields) async {
    await _dio.post(
      'https://travelworldonline.in/travelvideojson/b2b/transport/Default.aspx',
      data: fields,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
  }

  Future<void> submitCabEnquiry(Map<String, dynamic> data) async {
    await _dio.post('/api/CabBooking/cab', data: data);
  }

  Future<void> submitFlightEnquiry(Map<String, dynamic> data) async {
    await _dio.post('/api/charterFlight/addCharterFlight', data: data);
  }

  // ── Villa / Elivaas ─────────────────────────────────────────────────────────

  Future<List<VillaCityModel>> fetchVillaCities() async {
    final response = await _dio.get('/api/elivaas/cities');
    final data = response.data;
    final List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map<String, dynamic>) {
      list = data['data'] as List<dynamic>? ??
          data['cities'] as List<dynamic>? ??
          [];
    } else {
      list = [];
    }
    return list.cast<Map<String, dynamic>>().map(VillaCityModel.fromJson).toList();
  }

  Future<List<VillaRateModel>> searchVillaRates({
    required String city,
    String? checkin,
    String? checkout,
    required int adults,
    required int children,
  }) async {
    final params = <String, dynamic>{
      'city': city,
      'adults': adults,
      'children': children,
      'page': 0,
      'pageSize': 10,
    };
    if (checkin != null && checkin.isNotEmpty) params['checkinDate'] = checkin;
    if (checkout != null && checkout.isNotEmpty) params['checkoutDate'] = checkout;

    final response = await _dio.get('/api/elivaas/rates', queryParameters: params);
    final data = response.data;
    final List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map<String, dynamic>) {
      list = data['list'] as List<dynamic>? ??
          data['data'] as List<dynamic>? ??
          data['rates'] as List<dynamic>? ??
          [];
    } else {
      list = [];
    }
    return list
        .cast<Map<String, dynamic>>()
        .map((j) => VillaRateModel.fromJson(
              j,
              checkin: checkin ?? '',
              checkout: checkout ?? '',
              adults: adults,
              children: children,
            ))
        .toList();
  }

  Future<List<VillaRatePlanModel>> fetchVillaRatePlans({
    required String propertyId,
    required String checkin,
    required String checkout,
    required int adults,
    required int children,
    required String city,
  }) async {
    final response = await _dio.get(
      '/api/elivaas/rates',
      queryParameters: {
        'propertyId': propertyId,
        'checkinDate': checkin,
        'checkoutDate': checkout,
        'adults': adults,
        'children': children,
        'city': city,
      },
    );
    final data = response.data;
    final List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map<String, dynamic>) {
      list = data['list'] as List<dynamic>? ??
          data['data'] as List<dynamic>? ??
          [];
    } else {
      list = [];
    }
    // The endpoint returns the property object; its rate plans are nested
    // inside the 'quotes' array.
    if (list.isEmpty || list.first is! Map<String, dynamic>) return [];
    final quotes =
        (list.first as Map<String, dynamic>)['quotes'] as List<dynamic>? ?? [];
    return quotes
        .whereType<Map<String, dynamic>>()
        .where((q) => (q['id'] ?? '').toString().trim().isNotEmpty)
        .map(VillaRatePlanModel.fromJson)
        .toList();
  }

  Future<String> createVillaPaymentOrder(int amountInPaise) async {
    final response = await _dio.post(
      '/api/payment/villa',
      data: {'amount': amountInPaise},
    );
    final data = response.data as Map<String, dynamic>? ?? {};
    final order = data['order'];
    return (data['id'] ??
            data['orderId'] ??
            data['order_id'] ??
            (order is Map<String, dynamic> ? order['id'] : null) ??
            '')
        .toString();
  }

  Future<void> submitVillaBooking(Map<String, dynamic> payload) async {
    await _dio.post('/api/elivaas/booking', data: payload);
  }
}

/// Booking body for POST /api/elivaas/booking — must match the old app's
/// shape exactly: guest split into firstName/lastName, payment amount in
/// whole rupees.
Map<String, dynamic> buildVillaBookingBody({
  required String quoteId,
  required String guestName,
  required String guestEmail,
  required String guestPhone,
  required String transactionId,
  required int paidAmountRupees,
}) {
  final nameParts =
      guestName.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
  final firstName = nameParts.isEmpty ? guestName.trim() : nameParts.first;
  final lastName =
      nameParts.length > 1 ? nameParts.skip(1).join(' ') : guestName.trim();
  return {
    'quoteId': quoteId,
    'bookingStatus': 'CONFIRMED',
    'guest': {
      'email': guestEmail,
      'phone': guestPhone,
      'firstName': firstName,
      'lastName': lastName,
    },
    'payment': {
      'provider': 'Razorpay',
      'transactionId': transactionId,
      'amount': paidAmountRupees,
    },
  };
}
