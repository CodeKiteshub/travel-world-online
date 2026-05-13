import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/route_names.dart';
import '../providers/auth_providers.dart';

const _globeSvg = '''
<svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="24" cy="24" r="20" stroke="currentColor" stroke-width="1.5"/>
  <path d="M4 24 Q24 14 44 24 Q24 34 4 24" stroke="currentColor" stroke-width="1.2" fill="none"/>
  <path d="M24 4 Q14 24 24 44 Q34 24 24 4" stroke="currentColor" stroke-width="1.2" fill="none"/>
</svg>
''';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    HapticFeedback.mediumImpact();

    final success = await ref.read(authNotifierProvider.notifier).signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (!mounted) return;
    if (success) {
      HapticFeedback.heavyImpact();
      context.go(RouteNames.home);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email above first.')),
      );
      return;
    }
    final result = await ref
        .read(authNotifierProvider.notifier)
        .sendPasswordResetEmail(email);
    if (!mounted) return;
    result.fold(
      (msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      ),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent. Check your inbox.'),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;

    ref.listen<AuthState>(authNotifierProvider, (_, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: colors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacing.xl),

                // — Globe logo
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.goldPrimary, width: 2),
                  ),
                  child: Center(
                    child: SvgPicture.string(
                      _globeSvg,
                      colorFilter: ColorFilter.mode(
                          colors.goldPrimary, BlendMode.srcIn),
                      width: 30,
                      height: 30,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 50.ms, duration: 350.ms)
                    .scale(
                      begin: const Offset(0.85, 0.85),
                      delay: 50.ms,
                      duration: 350.ms,
                      curve: Curves.easeOut,
                    ),

                const SizedBox(height: 16),

                // — App name
                Column(
                  children: [
                    Text(
                      'TRAVEL WORLD',
                      style: AppTypography.displayMd.copyWith(
                        color: colors.ink900,
                        fontSize: 18,
                        letterSpacing: 0.06 * 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ONLINE',
                      style: AppTypography.caption.copyWith(
                        fontFamily: 'DMSans',
                        fontSize: 9,
                        letterSpacing: 0.32 * 9,
                        color: colors.ink400,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 120.ms, duration: 400.ms)
                    .slideY(
                        begin: 0.08,
                        end: 0,
                        delay: 120.ms,
                        duration: 400.ms,
                        curve: Curves.easeOut),

                const SizedBox(height: AppSpacing.lg),

                // — Page heading
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back',
                      style: AppTypography.displayLg.copyWith(
                          color: colors.ink900, fontSize: 28, height: 1.2),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sign in to continue to your travel business.',
                      style: AppTypography.body
                          .copyWith(color: colors.ink600, height: 1.55),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 190.ms, duration: 400.ms)
                    .slideY(
                        begin: 0.08,
                        end: 0,
                        delay: 190.ms,
                        duration: 400.ms,
                        curve: Curves.easeOut),

                const SizedBox(height: 28),

                // — Email field
                _LabeledField(
                  label: 'Email Address',
                  child: TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_passwordFocus),
                    style:
                        AppTypography.body.copyWith(color: colors.ink900),
                    decoration: _fieldDecoration(
                        colors: colors, hintText: 'you@example.com'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Enter your email address';
                      }
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                )
                    .animate()
                    .fadeIn(delay: 260.ms, duration: 380.ms)
                    .slideY(
                        begin: 0.06,
                        end: 0,
                        delay: 260.ms,
                        duration: 380.ms,
                        curve: Curves.easeOut),

                const SizedBox(height: 16),

                // — Password field
                _LabeledField(
                  label: 'Password',
                  child: TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    style:
                        AppTypography.body.copyWith(color: colors.ink900),
                    decoration: _fieldDecoration(
                      colors: colors,
                      hintText: '••••••••••',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: colors.ink400,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter your password' : null,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 320.ms, duration: 380.ms)
                    .slideY(
                        begin: 0.06,
                        end: 0,
                        delay: 320.ms,
                        duration: 380.ms,
                        curve: Curves.easeOut),

                const SizedBox(height: 20),

                // — Remember me + Forgot password
                Row(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          setState(() => _rememberMe = !_rememberMe),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: _rememberMe
                                  ? colors.goldPrimary
                                  : Colors.transparent,
                              border: Border.all(
                                color: _rememberMe
                                    ? colors.goldPrimary
                                    : colors.ink400,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: _rememberMe
                                ? const Icon(Icons.check,
                                    size: 12, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Remember Me',
                            style: AppTypography.body.copyWith(
                                color: colors.ink900, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _forgotPassword,
                      child: Text(
                        'Forgot Password?',
                        style: AppTypography.label.copyWith(
                            color: colors.goldPrimary, fontSize: 13),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 370.ms, duration: 350.ms),

                const SizedBox(height: 24),

                // — Gold login CTA
                _PressableButton(
                  onTap: isLoading ? null : _submit,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isLoading
                          ? colors.goldPrimary.withValues(alpha: 0.7)
                          : colors.goldPrimary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white),
                            )
                          : Text(
                              'Sign In',
                              style: AppTypography.label.copyWith(
                                color: AppColors.navyDeep,
                                fontSize: 14,
                                letterSpacing: 0.4,
                              ),
                            ),
                    ),
                  ),
                ).animate().fadeIn(delay: 420.ms, duration: 350.ms),

                const SizedBox(height: AppSpacing.xl),

                // — Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTypography.body
                          .copyWith(color: colors.ink600, fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: () => context.push(RouteNames.register),
                      child: Text(
                        'Sign Up',
                        style: AppTypography.label.copyWith(
                            color: colors.goldPrimary, fontSize: 13),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 460.ms, duration: 350.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required AppColorScheme colors,
    required String hintText,
    Widget? suffixIcon,
  }) {
    const radius = BorderRadius.all(Radius.circular(12));
    final baseBorder = OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: colors.lineSoft));
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTypography.body.copyWith(color: colors.ink400),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: baseBorder,
      enabledBorder: baseBorder,
      focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colors.goldPrimary, width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colors.error)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colors.error, width: 1.5)),
      suffixIcon: suffixIcon,
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.label.copyWith(
                color: colors.ink600,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        child,
      ],
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
