import 'package:dio/dio.dart';
import '../models/dmc_model.dart';

/// DMC (Destination Management Company) directory + supplier registration.
///
/// Public endpoints — no association session/token required, matching the
/// old app's DMC module which was reachable without signing into any
/// association.
class DmcDatasource {
  DmcDatasource(this._dio);
  final Dio _dio;

  Future<List<String>> fetchCountries() async {
    final res = await _dio.get('/api/dmc/getCountry');
    return _stringList(res.data);
  }

  Future<List<String>> fetchStates(String country) async {
    final res = await _dio.get('/api/dmc/states/$country');
    return _stringList(res.data);
  }

  Future<List<DmcModel>> fetchDmcList(String country, String state) async {
    final res = await _dio.get('/api/dmc/list/$country/$state');
    final data = res.data;
    if (data is Map<String, dynamic> &&
        data['success'] == true &&
        data['data'] is List) {
      return (data['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(DmcModel.fromJson)
          .toList();
    }
    return [];
  }

  /// Creates a Razorpay order for the supplier registration fee.
  /// Returns the raw response body: {success, order: {id, amount, currency}, message}.
  Future<Map<String, dynamic>> createSupplierOrder({
    required String supplierType,
    String? couponCode,
  }) async {
    final res = await _dio.post('/api/payment/supplier/order', data: {
      'supplierType': supplierType,
      if (couponCode != null && couponCode.isNotEmpty) 'couponCode': couponCode,
    });
    return res.data as Map<String, dynamic>;
  }

  /// Submits the supplier registration form (multipart, with documents).
  /// Returns the raw response body: {success, message}.
  Future<Map<String, dynamic>> submitSupplierRegistration(
    FormData formData,
  ) async {
    final res = await _dio.post(
      '/api/dmc/supplier-registration',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return res.data as Map<String, dynamic>;
  }

  List<String> _stringList(dynamic data) {
    if (data is Map<String, dynamic> &&
        data['success'] == true &&
        data['data'] is List) {
      return (data['data'] as List).map((e) => e.toString()).toList();
    }
    return [];
  }
}
