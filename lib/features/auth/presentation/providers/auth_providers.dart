import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_result.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/auth_models.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/auth_repository.dart';

// ── Datasource ────────────────────────────────────────────────────────────────

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>(
  (ref) => AuthRemoteDatasource(ref.watch(dioProvider)),
);

// ── Repository ────────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    ref.watch(authRemoteDatasourceProvider),
    ref.watch(secureStorageProvider),
  ),
);

// ── Auth state ────────────────────────────────────────────────────────────────

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
  const AuthSuccess(this.response);
  final LoginResponse response;
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

  Future<bool> login({
    required String email,
    required String password,
    String? associationId,
    String? fcmToken,
  }) async {
    state = const AuthLoading();
    final result = await _repo.login(
      email: email,
      password: password,
      associationId: associationId,
      fcmToken: fcmToken,
    );
    return result.fold(
      (msg) {
        state = AuthError(msg);
        return false;
      },
      (data) {
        state = AuthSuccess(data);
        return true;
      },
    );
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthIdle();
  }
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

// ── isLoggedIn stream (for router redirect) ───────────────────────────────────

final isLoggedInProvider = FutureProvider<bool>((ref) async {
  return ref.watch(authRepositoryProvider).isLoggedIn;
});
