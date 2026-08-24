import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          loading: () => const SizedBox.expand(),
          error: (_, __) => const SizedBox.expand(),
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

  void _onUpdate() {
    if (_finished) return;
    final value = widget.controller.value;
    if (!value.isInitialized) return;
    if (value.hasError) return;
    if (value.duration <= Duration.zero) return;
    if (value.position >= value.duration - const Duration(milliseconds: 250)) {
      _finished = true;
      widget.onFinished();
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
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.controller.value.size;
    if (size.isEmpty) {
      return const SizedBox.expand();
    }
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: VideoPlayer(widget.controller),
        ),
      ),
    );
  }
}
