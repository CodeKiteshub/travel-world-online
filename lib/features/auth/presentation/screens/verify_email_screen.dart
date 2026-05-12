import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/router/route_names.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              // Back button
              IconButton(
                onPressed: () => context.pop(),
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.lineSoft),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    size: 18,
                    color: colors.ink900,
                  ),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Envelope illustration (line-art style)
                    _EnvelopeIllustration(color: colors.ink900)
                        .animate()
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          duration: 500.ms,
                          curve: Curves.elasticOut,
                        )
                        .fadeIn(duration: 300.ms),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Check your inbox',
                      style: AppTypography.displayLg
                          .copyWith(color: colors.ink900),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 400.ms)
                        .slideY(begin: 0.08, end: 0, delay: 200.ms, duration: 400.ms, curve: Curves.easeOut),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      "We've sent a verification link to your email address. "
                      "Click the link in the email to verify your account.",
                      style: AppTypography.body.copyWith(color: colors.ink600),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(delay: 280.ms, duration: 400.ms),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Check your spam folder if you don\'t see it within a few minutes.',
                      style: AppTypography.caption
                          .copyWith(color: colors.ink400),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(delay: 340.ms, duration: 400.ms),
                    const SizedBox(height: AppSpacing.xxl),
                    // Gold CTA — "I Have Verified"
                    _PressableButton(
                      onTap: () {
                        HapticFeedback.heavyImpact();
                        context.go(RouteNames.home);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: colors.goldPrimary,
                          borderRadius: AppRadius.smAll,
                        ),
                        child: Center(
                          child: Text(
                            'I Have Verified',
                            style: AppTypography.label.copyWith(
                              color: AppColors.navyDeep,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 400.ms, duration: 350.ms),
                    const SizedBox(height: AppSpacing.md),
                    // Secondary — Resend Email
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Verification email resent.'),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colors.lineSoft),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.smAll,
                          ),
                        ),
                        child: Text(
                          'Resend Email',
                          style: AppTypography.label
                              .copyWith(color: colors.ink600, fontSize: 15),
                        ),
                      ),
                    ).animate().fadeIn(delay: 450.ms, duration: 350.ms),
                    const SizedBox(height: AppSpacing.lg),
                    // Sign out text link
                    Center(
                      child: GestureDetector(
                        onTap: () => context.go(RouteNames.login),
                        child: Text(
                          'Wrong account? Sign Out',
                          style: AppTypography.body
                              .copyWith(color: colors.ink400),
                        ),
                      ),
                    ).animate().fadeIn(delay: 500.ms, duration: 350.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Line-art envelope illustration drawn with CustomPainter.
class _EnvelopeIllustration extends StatelessWidget {
  const _EnvelopeIllustration({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(140, 110),
      painter: _EnvelopePainter(color: color),
    );
  }
}

class _EnvelopePainter extends CustomPainter {
  _EnvelopePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final goldPaint = Paint()
      ..color = AppColors.goldPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Envelope body
    final body = RRect.fromLTRBR(0, h * 0.2, w, h, const Radius.circular(6));
    canvas.drawRRect(body, paint);

    // Envelope flap (open, V-shape)
    final flapPath = Path()
      ..moveTo(0, h * 0.2)
      ..lineTo(w * 0.5, h * 0.55)
      ..lineTo(w, h * 0.2);
    canvas.drawPath(flapPath, paint);

    // Letter coming out of envelope
    final letter = RRect.fromLTRBR(
      w * 0.2,
      0,
      w * 0.8,
      h * 0.45,
      const Radius.circular(4),
    );
    canvas.drawRRect(letter, paint);

    // Lines on the letter
    canvas.drawLine(
      Offset(w * 0.32, h * 0.15),
      Offset(w * 0.68, h * 0.15),
      paint,
    );
    canvas.drawLine(
      Offset(w * 0.32, h * 0.26),
      Offset(w * 0.68, h * 0.26),
      paint,
    );
    canvas.drawLine(
      Offset(w * 0.32, h * 0.37),
      Offset(w * 0.55, h * 0.37),
      paint,
    );

    // Gold checkmark badge (bottom-right of envelope)
    final badgePaint = Paint()
      ..color = AppColors.goldPrimary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.82, h * 0.78), 12, badgePaint);

    final checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final checkPath = Path()
      ..moveTo(w * 0.76, h * 0.78)
      ..lineTo(w * 0.81, h * 0.84)
      ..lineTo(w * 0.89, h * 0.72);
    canvas.drawPath(checkPath, checkPaint);

    // Decorative stars
    _drawStar(canvas, Offset(w * 0.08, h * 0.08), 4, goldPaint);
    _drawStar(canvas, Offset(w * 0.92, h * 0.12), 3, paint);
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    canvas.drawLine(
      center.translate(-radius, 0),
      center.translate(radius, 0),
      paint,
    );
    canvas.drawLine(
      center.translate(0, -radius),
      center.translate(0, radius),
      paint,
    );
  }

  @override
  bool shouldRepaint(_EnvelopePainter old) => old.color != color;
}

class _PressableButton extends StatefulWidget {
  const _PressableButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.97),
        onTapUp: (_) {
          setState(() => _scale = 1.0);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _scale = 1.0),
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      );
}
