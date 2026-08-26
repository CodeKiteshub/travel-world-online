import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/auth_firebase_datasource.dart';
import '../../data/models/auth_models.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/auth_repository.dart';

// ── Datasource ────────────────────────────────────────────────────────────────

final authFirebaseDatasourceProvider = Provider<AuthFirebaseDatasource>(
  (ref) => AuthFirebaseDatasource(
    FirebaseAuth.instance,
    ref.watch(dioProvider),
    ref.watch(secureStorageProvider),
  ),
);

// ── Repository ────────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(authFirebaseDatasourceProvider)),
);

// ── Firebase auth state stream (drives router redirect) ───────────────────────

final authStateChangesProvider = StreamProvider<User?>((ref) {
  // [main] awaits Firebase.initializeApp before runApp; guard anyway so a
  // hot-restart race cannot leave this provider stuck in AsyncError forever.
  if (Firebase.apps.isEmpty) {
    return const Stream<User?>.empty();
  }
  // userChanges (not authStateChanges) also emits after User.reload(), which
  // is required for the email-verification → home redirect to see emailVerified.
  return FirebaseAuth.instance.userChanges();
});

/// Flip to true when splash video (or its fallback) finishes.
final splashCompletedProvider = StateProvider<bool>((ref) => false);

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

  Future<bool> reloadAndCheckVerified() async {
    final verified = await _repo.reloadAndCheckVerified();
    // Ensure GoRouter re-reads auth after reload (userChanges + refresh).
    ref.invalidate(authStateChangesProvider);
    return verified;
  }

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
