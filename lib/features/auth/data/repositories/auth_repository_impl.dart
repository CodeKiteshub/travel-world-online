import 'package:dio/dio.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_models.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._datasource, this._storage);

  final AuthRemoteDatasource _datasource;
  final SecureStorageService _storage;

  @override
  Future<ApiResult<LoginResponse>> login({
    required String email,
    required String password,
    String? associationId,
    String? fcmToken,
  }) async {
    try {
      final response = await _datasource.login(
        LoginRequest(
          email: email,
          password: password,
          associationId: associationId,
          fcmToken: fcmToken,
        ),
      );
      await _storage.saveSession(
        token: response.token,
        memberId: response.member.id,
        associationId: response.member.associationId,
      );
      return ApiResult.success(response);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final msg = switch (status) {
        400 => 'Invalid credentials. Please check your details.',
        401 => 'Unauthorized. Please check your credentials.',
        404 => 'Account not found.',
        500 => 'Server error. Please try again later.',
        _ => e.message ?? 'Network error. Please check your connection.',
      };
      return ApiResult.failure(msg, statusCode: status);
    } catch (e) {
      return ApiResult.failure('Something went wrong. Please try again.');
    }
  }

  @override
  Future<void> logout() => _storage.clearSession();

  @override
  Future<bool> get isLoggedIn async {
    final token = await _storage.accessToken;
    return token != null && token.isNotEmpty;
  }
}
