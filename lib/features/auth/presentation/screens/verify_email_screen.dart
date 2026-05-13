import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../providers/auth_providers.dart';

const _envelopeSvg = '''
<svg viewBox="0 0 200 200" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="100" cy="100" r="88" stroke="#E8E5DC" stroke-width="1.5" stroke-dasharray="6,4"/>
  <line x1="28" y1="44" x2="28" y2="52" stroke="#C9A84C" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="24" y1="48" x2="32" y2="48" stroke="#C9A84C" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="172" y1="40" x2="172" y2="48" stroke="#1A1A1A" stroke-width="1.2" stroke-linecap="round" opacity="0.4"/>
  <line x1="168" y1="44" x2="176" y2="44" stroke="#1A1A1A" stroke-width="1.2" stroke-linecap="round" opacity="0.4"/>
  <line x1="22" y1="148" x2="22" y2="156" stroke="#1A1A1A" stroke-width="1.2" stroke-linecap="round" opacity="0.4"/>
  <line x1="18" y1="152" x2="26" y2="152" stroke="#1A1A1A" stroke-width="1.2" stroke-linecap="round" opacity="0.4"/>
  <line x1="174" y1="154" x2="174" y2="162" stroke="#C9A84C" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="170" y1="158" x2="178" y2="158" stroke="#C9A84C" stroke-width="1.5" stroke-linecap="round"/>
  <rect x="38" y="88" width="124" height="84" rx="4" fill="white" stroke="#1A1A1A" stroke-width="1.5"/>
  <path d="M38 92 L100 138 L162 92" stroke="#1A1A1A" stroke-width="1.5" stroke-linejoin="round" fill="none"/>
  <rect x="62" y="58" width="76" height="60" rx="2" fill="#FAF8F3" stroke="#1A1A1A" stroke-width="1.5"/>
  <line x1="76" y1="76" x2="124" y2="76" stroke="#1A1A1A" stroke-width="1.2" stroke-linecap="round" opacity="0.5"/>
  <line x1="76" y1="88" x2="124" y2="88" stroke="#1A1A1A" stroke-width="1.2" stroke-linecap="round" opacity="0.5"/>
  <line x1="76" y1="100" x2="108" y2="100" stroke="#1A1A1A" stroke-width="1.2" stroke-linecap="round" opacity="0.5"/>
  <circle cx="138" cy="62" r="14" fill="#C9A84C"/>
  <path d="M131 62 L136 68 L145 55" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
</svg>
''';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _checking = false;
  bool _resending = false;

  String get _email =>
      FirebaseAuth.instance.currentUser?.email ?? 'your email';

  Future<void> _checkVerification() async {
    setState(() => _checking = true);
    HapticFeedback.lightImpact();

    final verified =
        await ref.read(authNotifierProvider.notifier).reloadAndCheckVerified();

    if (!mounted) return;
    setState(() => _checking = false);

    if (verified) {
      HapticFeedback.heavyImpact();
      context.go(RouteNames.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Email not verified yet. Check your inbox and tap the link.'),
          backgroundColor: Theme.of(context).extension<AppColorScheme>()!.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    HapticFeedback.lightImpact();
    await ref.read(authNotifierProvider.notifier).sendEmailVerification();
    if (!mounted) return;
    setState(() => _resending = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verification email resent. Check your inbox.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _signOut() async {
    await ref.read(authNotifierProvider.notifier).signOut();
    if (!mounted) return;
    context.go(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // — Back button
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: colors.lineSoft),
                  ),
                  child: Center(
                    child: Icon(Icons.arrow_back_rounded,
                        size: 18, color: colors.ink900),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // — Envelope illustration
              Center(
                child: SvgPicture.string(_envelopeSvg,
                    width: 180, height: 180),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 300.ms),

              const SizedBox(height: 32),

              // — Heading
              Center(
                child: Text(
                  'Check your inbox',
                  style: AppTypography.displayLg.copyWith(
                      color: colors.ink900, fontSize: 26, height: 1.2),
                  textAlign: TextAlign.center,
                ),
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(
                      begin: 0.08,
                      end: 0,
                      delay: 200.ms,
                      duration: 400.ms,
                      curve: Curves.easeOut),

              const SizedBox(height: 16),

              // — Body text with dynamic email
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTypography.body
                        .copyWith(color: colors.ink600, height: 1.55),
                    children: [
                      const TextSpan(
                          text: "We've sent a verification link to\n"),
                      TextSpan(
                        text: _email,
                        style: TextStyle(
                            color: colors.ink900,
                            fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(
                        text:
                            '\nTap the link in the email to activate your account, then come back here.',
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 280.ms, duration: 400.ms),

              const SizedBox(height: 36),

              // — Gold CTA: I Have Verified
              _PressableButton(
                onTap: _checking ? null : _checkVerification,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _checking
                        ? colors.goldPrimary.withValues(alpha: 0.7)
                        : colors.goldPrimary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: _checking
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white),
                          )
                        : Text(
                            'I Have Verified',
                            style: AppTypography.label.copyWith(
                              color: AppColors.navyDeep,
                              fontSize: 14,
                              letterSpacing: 0.4,
                            ),
                          ),
                  ),
                ),
              ).animate().fadeIn(delay: 360.ms, duration: 350.ms),

              const SizedBox(height: 12),

              // — Resend Email
              _PressableButton(
                onTap: _resending ? null : _resend,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.ink900, width: 1.5),
                  ),
                  child: Center(
                    child: _resending
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: colors.ink900),
                          )
                        : Text(
                            'Resend Email',
                            style: AppTypography.label.copyWith(
                              color: colors.ink900,
                              fontSize: 14,
                              letterSpacing: 0.4,
                            ),
                          ),
                  ),
                ),
              ).animate().fadeIn(delay: 410.ms, duration: 350.ms),

              const SizedBox(height: 24),

              // — Sign out link
              Center(
                child: GestureDetector(
                  onTap: _signOut,
                  child: Text(
                    'Wrong account? Sign Out',
                    style: AppTypography.body
                        .copyWith(color: colors.ink400, fontSize: 13),
                  ),
                ),
              ).animate().fadeIn(delay: 460.ms, duration: 350.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _PressableButton extends StatefulWidget {
  const _PressableButton({required this.onTap, required this.child});
  final VoidCallback? onTap;
  final Widget child;

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: widget.onTap != null
            ? (_) => setState(() => _scale = 0.97)
            : null,
        onTapUp: widget.onTap != null
            ? (_) {
                setState(() => _scale = 1.0);
                widget.onTap!();
              }
            : null,
        onTapCancel: widget.onTap != null
            ? () => setState(() => _scale = 1.0)
            : null,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      );
}
