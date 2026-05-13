import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'access_token';
  static const _memberIdKey = 'member_id';
  static const _associationIdKey = 'association_id';

  Future<void> saveSession({
    required String token,
    required String memberId,
    String? associationId,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: token),
      _storage.write(key: _memberIdKey, value: memberId),
      if (associationId != null && associationId.isNotEmpty)
        _storage.write(key: _associationIdKey, value: associationId),
    ]);
  }

  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _memberIdKey),
      _storage.delete(key: _associationIdKey),
    ]);
  }

  Future<String?> get accessToken => _storage.read(key: _accessTokenKey);
  Future<String?> get memberId => _storage.read(key: _memberIdKey);
  Future<String?> get associationId => _storage.read(key: _associationIdKey);
}
