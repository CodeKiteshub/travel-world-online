import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../providers/auth_providers.dart';

/// Owned outside [SplashScreen] so GoRouter refreshes don't dispose the player
/// and fall back to the old logo.
final splashVideoProvider =
    FutureProvider<VideoPlayerController>((ref) async {
  final controller = VideoPlayerController.asset(
    'assets/videos/twoappsplash.mp4',
    videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
  );
  ref.onDispose(controller.dispose);
  await controller.initialize();
  await controller.setLooping(false);
  await controller.play();
  return controller;
});

/// How long the splash clip is shown before the app opens.
const _kSplashPlayDuration = Duration(seconds: 2);

/// Plays [assets/videos/twoappsplash.mp4] as the loading screen.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _navigated = false;
  Timer? _fallbackTimer;

  void _navigateOnce() {
    if (_navigated) return;
    _navigated = true;
    _fallbackTimer?.cancel();
    FlutterNativeSplash.remove();
    ref.read(splashCompletedProvider.notifier).state = true;
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    // Last-resort only — do not send the user to login (old logo) early.
    _fallbackTimer = Timer(const Duration(seconds: 20), _navigateOnce);
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = ref.watch(splashVideoProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: video.when(
          data: (controller) => _SplashVideoView(
            controller: controller,
            onFinished: _navigateOnce,
          ),
          loading: () => Image.asset(
            'assets/images/splash_first_frame.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          error: (_, __) {
            FlutterNativeSplash.remove();
            return Image.asset(
              'assets/images/splash_first_frame.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            );
          },
        ),
      ),
    );
  }
}

class _SplashVideoView extends StatefulWidget {
  const _SplashVideoView({
    required this.controller,
    required this.onFinished,
  });

  final VideoPlayerController controller;
  final VoidCallback onFinished;

  @override
  State<_SplashVideoView> createState() => _SplashVideoViewState();
}

class _SplashVideoViewState extends State<_SplashVideoView> {
  bool _finished = false;
  Timer? _playTimer;

  void _finish() {
    if (_finished) return;
    _finished = true;
    _playTimer?.cancel();
    widget.controller.pause();
    widget.onFinished();
  }

  void _onUpdate() {
    if (_finished) return;
    final value = widget.controller.value;
    if (!value.isInitialized) return;
    if (value.hasError) return;
    if (value.position >= _kSplashPlayDuration) {
      _finish();
    }
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onUpdate);
    if (widget.controller.value.isInitialized &&
        !widget.controller.value.isPlaying) {
      widget.controller.play();
    }
    _playTimer = Timer(_kSplashPlayDuration, _finish);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
  }

  @override
  void dispose() {
    _playTimer?.cancel();
    widget.controller.removeListener(_onUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.controller.value.size;
    if (size.isEmpty) {
      return Image.asset(
        'assets/images/splash_first_frame.png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: VideoPlayer(widget.controller),
        ),
      ),
    );
  }
}
