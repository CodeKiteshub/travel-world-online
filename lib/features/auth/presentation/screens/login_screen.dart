import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/router/route_names.dart';
import '../widgets/social_login_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _mobileFocus = FocusNode();
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
    _mobileFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (_form.currentState?.validate() ?? false) {
      HapticFeedback.mediumImpact();
      // Auth logic will be wired via AuthNotifier in a future task
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacing.xl),
                // Logo
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.goldPrimary,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.language_outlined,
                    color: colors.goldPrimary,
                    size: 36,
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
                const SizedBox(height: AppSpacing.md),
                Text(
                  'TRAVEL WORLD ONLINE',
                  style: AppTypography.displayMd.copyWith(
                    color: colors.ink900,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(delay: 120.ms, duration: 400.ms)
                    .slideY(begin: 0.08, end: 0, delay: 120.ms, duration: 400.ms, curve: Curves.easeOut),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Welcome back',
                  style: AppTypography.displayLg.copyWith(color: colors.ink900),
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .slideY(begin: 0.08, end: 0, delay: 200.ms, duration: 400.ms, curve: Curves.easeOut),
                const SizedBox(height: AppSpacing.xl),
                // Mobile number field
                TextFormField(
                  focusNode: _mobileFocus,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_passwordFocus),
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number',
                    prefixText: '+91  ',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().length < 10)
                          ? 'Enter a valid 10-digit mobile number'
                          : null,
                )
                    .animate()
                    .fadeIn(delay: 280.ms, duration: 400.ms)
                    .slideY(begin: 0.06, end: 0, delay: 280.ms, duration: 400.ms, curve: Curves.easeOut),
                const SizedBox(height: AppSpacing.md),
                // Password field
                TextFormField(
                  focusNode: _passwordFocus,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: colors.ink400,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter your password' : null,
                )
                    .animate()
                    .fadeIn(delay: 340.ms, duration: 400.ms)
                    .slideY(begin: 0.06, end: 0, delay: 340.ms, duration: 400.ms, curve: Curves.easeOut),
                const SizedBox(height: AppSpacing.md),
                // Remember me + Forgot password row
                Row(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          setState(() => _rememberMe = !_rememberMe),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: _rememberMe
                                  ? colors.goldPrimary
                                  : Colors.transparent,
                              border: Border.all(
                                color: _rememberMe
                                    ? colors.goldPrimary
                                    : colors.ink400,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: _rememberMe
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Remember Me',
                            style: AppTypography.body
                                .copyWith(color: colors.ink600),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Forgot Password?',
                        style: AppTypography.label
                            .copyWith(color: colors.goldPrimary),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms, duration: 350.ms),
                const SizedBox(height: AppSpacing.lg),
                // Gold primary CTA with scale press
                _PressableButton(
                  onTap: _submit,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: colors.goldPrimary,
                      borderRadius: AppRadius.smAll,
                    ),
                    child: Center(
                      child: Text(
                        'Login',
                        style: AppTypography.label.copyWith(
                          color: AppColors.navyDeep,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 460.ms, duration: 350.ms),
                const SizedBox(height: AppSpacing.lg),
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: colors.lineSoft)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Text(
                        'or continue with',
                        style: AppTypography.caption
                            .copyWith(color: colors.ink400),
                      ),
                    ),
                    Expanded(child: Divider(color: colors.lineSoft)),
                  ],
                ).animate().fadeIn(delay: 500.ms, duration: 350.ms),
                const SizedBox(height: AppSpacing.lg),
                // Social login buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialLoginButton(
                      icon: const Icon(
                        Icons.g_mobiledata,
                        size: 30,
                        color: Color(0xFF4285F4),
                      ),
                      onTap: () {},
                    ),
                    const SizedBox(width: AppSpacing.md),
                    SocialLoginButton(
                      icon: Icon(
                        Icons.apple,
                        size: 28,
                        color: colors.ink900,
                      ),
                      onTap: () {},
                    ),
                    const SizedBox(width: AppSpacing.md),
                    SocialLoginButton(
                      icon: const Icon(
                        Icons.window,
                        size: 24,
                        color: Color(0xFF00A4EF),
                      ),
                      onTap: () {},
                    ),
                  ],
                ).animate().fadeIn(delay: 540.ms, duration: 350.ms),
                const SizedBox(height: AppSpacing.xl),
                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTypography.body.copyWith(color: colors.ink600),
                    ),
                    GestureDetector(
                      onTap: () => context.push(RouteNames.register),
                      child: Text(
                        'Sign Up',
                        style: AppTypography.label
                            .copyWith(color: colors.goldPrimary),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 580.ms, duration: 350.ms),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
