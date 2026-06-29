import 'package:dio/dio.dart';

class AssociationAuthDatasource {
  AssociationAuthDatasource(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> login({
    required String associationId,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/api/members/login',
      data: {
        'associationId': associationId,
        'email': email,
        'password': password,
        'FmcToken': '',
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    throw Exception('Unexpected login response');
  }

  Future<void> forgotPassword({
    required String email,
    required String associationId,
  }) async {
    await _dio.put(
      '/api/members/forgotPassword',
      data: {'email': email, 'associationId': associationId},
    );
  }
}
