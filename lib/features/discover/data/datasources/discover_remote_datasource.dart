import 'package:dio/dio.dart';
import '../models/deal_model.dart';

class DiscoverRemoteDatasource {
  const DiscoverRemoteDatasource(this._dio);

  final Dio _dio;

  Future<List<Deal>> fetchFeaturedDeals() async {
    final response = await _dio.get('/api/package/getFeaturedPackages');
    final data = (response.data as Map<String, dynamic>?)?['data'] as List<dynamic>? ?? [];
    return data
        .cast<Map<String, dynamic>>()
        .map(Deal.fromJson)
        .toList();
  }
}
