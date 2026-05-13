import '../../../core/network/api_result.dart';
import '../data/models/auth_models.dart';

abstract interface class AuthRepository {
  Future<ApiResult<LoginResponse>> login({
    required String email,
    required String password,
    String? associationId,
    String? fcmToken,
  });

  Future<void> logout();

  Future<bool> get isLoggedIn;
}
