import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/auth_repository.dart';
import '../datasources/auth_firebase_datasource.dart';
import '../models/auth_models.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._datasource);

  final AuthFirebaseDatasource _datasource;

  @override
  Future<ApiResult<UserProfile>> signIn(String email, String password) async {
    try {
      final profile = await _datasource.signIn(email, password);
      return ApiResult.success(profile);
    } on EmailNotVerifiedException {
      return const ApiResult.failure(
        'Please verify your email before signing in. We\'ve resent the verification link.',
      );
    } on FirebaseAuthException catch (e) {
      return ApiResult.failure(_messageFromCode(e.code));
    } catch (_) {
      return const ApiResult.failure('Something went wrong. Please try again.');
    }
  }

  @override
  Future<ApiResult<UserProfile>> register(RegisterRequest req) async {
    try {
      final profile = await _datasource.register(req);
      return ApiResult.success(profile);
    } on FirebaseAuthException catch (e) {
      return ApiResult.failure(_messageFromCode(e.code));
    } catch (_) {
      return const ApiResult.failure('Something went wrong. Please try again.');
    }
  }

  @override
  Future<void> signOut() => _datasource.signOut();

  @override
  Future<ApiResult<void>> sendPasswordResetEmail(String email) async {
    try {
      await _datasource.sendPasswordResetEmail(email);
      return const ApiResult.success(null);
    } on FirebaseAuthException catch (e) {
      return ApiResult.failure(_messageFromCode(e.code));
    } catch (_) {
      return const ApiResult.failure('Could not send reset email. Try again.');
    }
  }

  @override
  Future<void> sendEmailVerification() => _datasource.sendEmailVerification();

  @override
  Future<bool> reloadAndCheckVerified() => _datasource.reloadAndCheckVerified();

  @override
  Stream<UserProfile?> authStateChanges() => _datasource.authStateChanges.map(
        (user) => user == null ? null : UserProfile.fromFirebaseUser(user),
      );

  String _messageFromCode(String code) => switch (code) {
        'user-not-found' => 'No account found with this email.',
        'wrong-password' => 'Incorrect password.',
        'invalid-credential' => 'Invalid email or password.',
        'invalid-email' => 'Please enter a valid email address.',
        'email-already-in-use' => 'An account already exists with this email.',
        'weak-password' => 'Password must be at least 6 characters.',
        'too-many-requests' => 'Too many attempts. Please try again later.',
        'network-request-failed' => 'Network error. Check your connection.',
        _ => 'Authentication failed. Please try again.',
      };
}
