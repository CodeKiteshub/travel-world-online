import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/auth_models.dart';

class AuthFirebaseDatasource {
  AuthFirebaseDatasource(this._auth, this._dio, this._storage);

  final FirebaseAuth _auth;
  final Dio _dio;
  final SecureStorageService _storage;

  static const _mobileKey = 'user_mobile';
  static const _nameKey = 'user_name';

  Future<UserProfile> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user!;
    if (!user.emailVerified) {
      await user.sendEmailVerification();
      await _auth.signOut();
      throw const EmailNotVerifiedException();
    }

    // Attempt backend login to get member JWT for API access.
    // Fire-and-forget: Firebase auth succeeds regardless of this outcome.
    _tryBackendLogin(email.trim(), password);

    final prefs = await SharedPreferences.getInstance();
    return UserProfile.fromFirebaseUser(
      user,
      name: prefs.getString(_nameKey),
      mobile: prefs.getString(_mobileKey),
    );
  }

  Future<UserProfile> register(RegisterRequest req) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: req.email.trim(),
      password: req.password,
    );
    final user = credential.user!;
    await user.updateDisplayName(req.fullName);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_mobileKey, req.mobile);
    await prefs.setString(_nameKey, req.fullName);
    await user.sendEmailVerification();
    return UserProfile.fromFirebaseUser(user,
        name: req.fullName, mobile: req.mobile);
  }

  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<bool> reloadAndCheckVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    // Reloaded profile lives on a new currentUser instance.
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _storage.clearSession(),
    ]);
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // Silently attempts the backend custom-auth login to get the member JWT.
  // If it fails for any reason the app continues with Firebase-only auth.
  Future<void> _tryBackendLogin(String email, String password) async {
    try {
      final response = await _dio.post(
        '/api/members/login',
        data: {
          'email': email,
          'password': password,
          'associationId': '',
          'FmcToken': '',
        },
      );
      final body = response.data as Map<String, dynamic>?;
      final token = body?['token'] as String?;
      final member = body?['member'] as Map<String, dynamic>?;
      if (token != null && member != null) {
        final memberId = member['_id'] as String?;
        final associationId = member['associationId'] as String?;
        if (memberId != null && memberId.isNotEmpty) {
          await _storage.saveSession(
            token: token,
            memberId: memberId,
            associationId: associationId ?? '',
          );
        }
      }
    } catch (_) {
      // Backend login failed — Firebase session is unaffected.
    }
  }
}
