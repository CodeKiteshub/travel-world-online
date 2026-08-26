import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // Keep the native splash (video first frame) up while Firebase boots so the
  // auth stream is never subscribed before [Firebase.initializeApp] finishes.
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  await _initFirebase();
  runApp(const ProviderScope(child: TravelWorldApp()));
}

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
        .timeout(const Duration(seconds: 12));
  } on TimeoutException catch (_) {
    // Emulators can stall here; don't keep the native window forever.
  }
  // App Check must not block first frame / login.
  unawaited(
    FirebaseAppCheck.instance
        .activate(
          providerAndroid: kDebugMode
              ? const AndroidDebugProvider()
              : const AndroidPlayIntegrityProvider(),
          providerApple: kDebugMode
              ? const AppleDebugProvider()
              : const AppleDeviceCheckProvider(),
        )
        .catchError((Object _) {}),
  );
}

class TravelWorldApp extends ConsumerWidget {
  const TravelWorldApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp.router(
      title: 'Travel World Online',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
