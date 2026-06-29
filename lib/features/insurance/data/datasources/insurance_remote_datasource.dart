import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../local/insurance_local_data.dart';
import '../models/insurance_models.dart';

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
        ApiEndpoints.insurancePlans,
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
        return list
            .map((e) => InsurancePlan.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    // Fallback to bundled offline data when API is unreachable
    return InsuranceLocalData.lookupPlans(
      categoryCode: travelCategory,
      countryCode: country,
      travellerAges: travellerAges,
      durationDays: durationDays,
    );
  }

  Future<Map<String, dynamic>?> createOrder(double totalInRupees) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.insuranceOrder,
        data: {'amount': (totalInRupees * 100).toInt()},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>?> createPolicy(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(ApiEndpoints.insurancePolicyCreate, data: body);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }
}
