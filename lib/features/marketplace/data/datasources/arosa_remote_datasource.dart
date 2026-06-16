import 'package:dio/dio.dart';
import '../models/arosa_package_model.dart';

class ArosaRemoteDatasource {
  const ArosaRemoteDatasource(this._dio);

  final Dio _dio;

  Future<String> fetchToken() async {
    final response = await _dio.post('/api/arosa/login');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['number'] as String? ??
          data['token'] as String? ??
          data['tokenNumber'] as String? ??
          '';
    }
    return '';
  }

  Future<List<ArosaPackageModel>> fetchPackages({
    required String token,
    required String date,
    required String river,
  }) async {
    final response = await _dio.post(
      '/api/arosa/packages',
      data: {
        'date': date,
        'river': river,
        'tokenNumber': token,
      },
    );
    final data = response.data;
    final List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map<String, dynamic>) {
      list = data['data'] as List<dynamic>? ??
          data['packages'] as List<dynamic>? ??
          data['result'] as List<dynamic>? ??
          [];
    } else {
      list = [];
    }
    return list.cast<Map<String, dynamic>>().map(ArosaPackageModel.fromJson).toList();
  }
}
