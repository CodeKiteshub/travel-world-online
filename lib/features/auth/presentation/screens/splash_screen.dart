import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/router/route_names.dart';

/// Splash — plays the brand video from the old app (twoappsplash.mp4),
/// then navigates. Falls through after 8s or on any playback error so the
/// user is never stuck here.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final VideoPlayerController _video;
  Timer? _fallbackTimer;
  bool _navigated = false;

  void _navigateOnce() {
    if (_navigated || !mounted) return;
    _navigated = true;
    // TODO: Re-enable onboarding later when needed.
    // context.go(RouteNames.onboarding);
    context.go(RouteNames.login);
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _video = VideoPlayerController.asset('assets/videos/twoappsplash.mp4')
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _video.play();
      }).catchError((_) {
        _navigateOnce();
      });
    // Navigate when the video finishes.
    _video.addListener(() {
      final v = _video.value;
      if (v.isInitialized &&
          v.duration > Duration.zero &&
          v.position >= v.duration) {
        _navigateOnce();
      }
    });
    // Same 8s safety net as the old app.
    _fallbackTimer = Timer(const Duration(seconds: 8), _navigateOnce);
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _video.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _video.value.isInitialized
          ? SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _video.value.size.width,
                  height: _video.value.size.height,
                  child: VideoPlayer(_video),
                ),
              ),
            )
          // Black frame while the video initialises (it's a local asset,
          // so this is a few ms at most).
          : const SizedBox.shrink(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Previous animated splash (globe + wordmark + progress bar), commented out
// per request in favour of the brand video. Restore by reverting this file.
//
// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _progress;
//
//   @override
//   void initState() {
//     super.initState();
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
//     _progress = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 2800),
//     )..forward();
//     _progress.addStatusListener((status) {
//       if (status == AnimationStatus.completed && mounted) {
//         context.go(RouteNames.login);
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.navyDeep,
//       body: ... navy gradient + gold glows
//         + 96px gold circle with Icons.language_outlined
//         + 'TRAVEL WORLD ONLINE' (displayMd) + 'Travel Business. Elevated.'
//         + gold LinearProgressIndicator bottom (48px inset),
//     );
//   }
// }
// ─────────────────────────────────────────────────────────────────────────────
