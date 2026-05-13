import '../../../../core/network/api_result.dart';
import '../data/models/auth_models.dart';

abstract interface class AuthRepository {
  Future<ApiResult<UserProfile>> signIn(String email, String password);

  Future<ApiResult<UserProfile>> register(RegisterRequest req);

  Future<void> signOut();

  Future<ApiResult<void>> sendPasswordResetEmail(String email);

  Future<void> sendEmailVerification();

  /// Reloads the Firebase user and returns whether email is now verified.
  Future<bool> reloadAndCheckVerified();

  Stream<UserProfile?> authStateChanges();
}
