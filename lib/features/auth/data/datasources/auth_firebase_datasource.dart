import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';

class AuthFirebaseDatasource {
  AuthFirebaseDatasource(this._auth);

  final FirebaseAuth _auth;

  static const _mobileKey = 'user_mobile';
  static const _nameKey = 'user_name';

  Future<UserProfile> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user!;
    if (!user.emailVerified) {
      // Re-send verification and sign out — user must verify first.
      await user.sendEmailVerification();
      await _auth.signOut();
      throw const EmailNotVerifiedException();
    }
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

    // Persist display name on the Firebase user record.
    await user.updateDisplayName(req.fullName);

    // Save mobile locally (Firestore not yet configured).
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_mobileKey, req.mobile);
    await prefs.setString(_nameKey, req.fullName);

    // Send verification email — user stays signed in until they navigate away.
    await user.sendEmailVerification();

    return UserProfile.fromFirebaseUser(user,
        name: req.fullName, mobile: req.mobile);
  }

  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  // Reloads the Firebase user record and returns updated emailVerified status.
  Future<bool> reloadAndCheckVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;
}
