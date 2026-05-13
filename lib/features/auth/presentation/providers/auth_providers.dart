import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_result.dart';
import '../../data/datasources/auth_firebase_datasource.dart';
import '../../data/models/auth_models.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/auth_repository.dart';

// ── Datasource ────────────────────────────────────────────────────────────────

final authFirebaseDatasourceProvider = Provider<AuthFirebaseDatasource>(
  (ref) => AuthFirebaseDatasource(FirebaseAuth.instance),
);

// ── Repository ────────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(authFirebaseDatasourceProvider)),
);

// ── Firebase auth state stream (drives router redirect) ───────────────────────

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// ── Auth action state ─────────────────────────────────────────────────────────

sealed class AuthState {
  const AuthState();
}

final class AuthIdle extends AuthState {
  const AuthIdle();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthSuccess extends AuthState {
  const AuthSuccess(this.profile);
  final UserProfile profile;
}

final class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthIdle();

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<bool> signIn(String email, String password) async {
    state = const AuthLoading();
    final result = await _repo.signIn(email, password);
    return _handleResult(result);
  }

  Future<bool> register(RegisterRequest req) async {
    state = const AuthLoading();
    final result = await _repo.register(req);
    return _handleResult(result);
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AuthIdle();
  }

  Future<ApiResult<void>> sendPasswordResetEmail(String email) {
    return _repo.sendPasswordResetEmail(email);
  }

  Future<void> sendEmailVerification() => _repo.sendEmailVerification();

  Future<bool> reloadAndCheckVerified() => _repo.reloadAndCheckVerified();

  bool _handleResult(ApiResult<UserProfile> result) {
    return result.fold(
      (msg) {
        state = AuthError(msg);
        return false;
      },
      (profile) {
        state = AuthSuccess(profile);
        return true;
      },
    );
  }
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
