import 'package:firebase_auth/firebase_auth.dart';

class RegisterRequest {
  const RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobile,
    required this.password,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String mobile;
  final String password;

  String get fullName => '$firstName $lastName'.trim();
}

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.emailVerified,
    this.name,
    this.mobile,
  });

  final String uid;
  final String email;
  final bool emailVerified;
  final String? name;
  final String? mobile;

  factory UserProfile.fromFirebaseUser(User user, {String? name, String? mobile}) =>
      UserProfile(
        uid: user.uid,
        email: user.email ?? '',
        emailVerified: user.emailVerified,
        name: name ?? user.displayName,
        mobile: mobile,
      );
}

// Thrown when login succeeds but email is not yet verified
class EmailNotVerifiedException implements Exception {
  const EmailNotVerifiedException();
}
