import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/route_names.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    // Progress bar fills over 2.8s; navigation fires on completion.
    _progress = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..forward();
    _progress.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        context.go(RouteNames.onboarding);
      }
    });
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B2A), Color(0xFF06111D)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Subtle gold radial glow in top-left corner
              Positioned(
                top: -80,
                left: -80,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.goldPrimary.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Second glow in bottom-right
              Positioned(
                bottom: -60,
                right: -60,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.goldPrimary.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Center content with staggered entrance animations
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Globe logo — spring scale entrance
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.goldPrimary,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.language_outlined,
                        color: AppColors.goldPrimary,
                        size: 48,
                      ),
                    )
                        .animate()
                        .scale(
                          begin: const Offset(0, 0),
                          end: const Offset(1, 1),
                          delay: 200.ms,
                          duration: 750.ms,
                          curve: Curves.elasticOut,
                        )
                        .fadeIn(delay: 200.ms, duration: 300.ms),
                    const SizedBox(height: 24),
                    Text(
                      'TRAVEL WORLD ONLINE',
                      style: AppTypography.displayMd.copyWith(
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(delay: 620.ms, duration: 400.ms)
                        .slideY(
                          begin: 0.1,
                          end: 0,
                          delay: 620.ms,
                          duration: 400.ms,
                          curve: Curves.easeOut,
                        ),
                    const SizedBox(height: 8),
                    Text(
                      'Travel Business. Elevated.',
                      style: AppTypography.body.copyWith(
                        color: AppColors.goldPrimary,
                        fontStyle: FontStyle.italic,
                        fontSize: 15,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 870.ms, duration: 400.ms),
                  ],
                ),
              ),
              // Gold progress bar at bottom
              Positioned(
                bottom: 48,
                left: 48,
                right: 48,
                child: AnimatedBuilder(
                  animation: _progress,
                  builder: (_, __) => ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: _progress.value,
                      backgroundColor:
                          AppColors.goldPrimary.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.goldPrimary,
                      ),
                      minHeight: 3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
