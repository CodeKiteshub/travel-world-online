import 'package:dio/dio.dart';
import '../models/auth_models.dart';

class AuthRemoteDatasource {
  AuthRemoteDatasource(this._dio);

  final Dio _dio;

  static const _loginPath = '/api/members/login';

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      _loginPath,
      data: request.toJson(),
    );

    final data = response.data;
    if (data == null) throw Exception('Empty response from server');
    return LoginResponse.fromJson(data);
  }
}
