import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../storage/secure_storage.dart';
import 'auth_interceptor.dart';

const _baseUrl = 'https://backend.twoapp.in';
const _twoContentBaseUrl = 'https://travelworldonline.in';

final _secureStorageProvider = Provider<SecureStorageService>(
  (_) => SecureStorageService(const FlutterSecureStorage()),
);

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(_secureStorageProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
  dio.interceptors.add(AuthInterceptor(storage));
  return dio;
});

// Unauthenticated Dio for travelworldonline.in content APIs (associations, etc.)
// ResponseType.plain: the legacy PHP travelvideojson endpoints return text/html
// content-type. Dio 5 throws when it tries to JSON-parse non-JSON bodies, so we
// force plain-text and let each datasource decode manually.
final twoDioProvider = Provider<Dio>((_) => Dio(
      BaseOptions(
        baseUrl: _twoContentBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        responseType: ResponseType.plain,
      ),
    ));

// Unauthenticated Dio for A-ROSA cruise API (separate backend)
final arosaDioProvider = Provider<Dio>((_) => Dio(
      BaseOptions(
        baseUrl: 'https://twoappbackend.onrender.com',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    ));

final secureStorageProvider = _secureStorageProvider;
