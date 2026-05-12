import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/router/route_names.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  void _submit() {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms of Service.')),
      );
      return;
    }
    if (_form.currentState?.validate() ?? false) {
      HapticFeedback.mediumImpact();
      context.push(RouteNames.verifyEmail);
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
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Create an account',
                  style: AppTypography.displayLg.copyWith(color: colors.ink900),
                )
                    .animate()
                    .fadeIn(delay: 80.ms, duration: 400.ms)
                    .slideY(begin: 0.08, end: 0, delay: 80.ms, duration: 400.ms, curve: Curves.easeOut),
                const SizedBox(height: AppSpacing.xl),
                // First Name + Last Name row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'First Name'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Required'
                            : null,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: TextFormField(
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Last Name'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Required'
                            : null,
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 160.ms, duration: 400.ms)
                    .slideY(begin: 0.06, end: 0, delay: 160.ms, duration: 400.ms, curve: Curves.easeOut),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                )
                    .animate()
                    .fadeIn(delay: 230.ms, duration: 400.ms)
                    .slideY(begin: 0.06, end: 0, delay: 230.ms, duration: 400.ms, curve: Curves.easeOut),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number',
                    prefixText: '+91  ',
                  ),
                  validator: (v) => (v == null || v.trim().length < 10)
                      ? 'Enter a valid 10-digit number'
                      : null,
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms)
                    .slideY(begin: 0.06, end: 0, delay: 300.ms, duration: 400.ms, curve: Curves.easeOut),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
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
                  validator: (v) => (v == null || v.length < 8)
                      ? 'Password must be at least 8 characters'
                      : null,
                )
                    .animate()
                    .fadeIn(delay: 370.ms, duration: 400.ms)
                    .slideY(begin: 0.06, end: 0, delay: 370.ms, duration: 400.ms, curve: Curves.easeOut),
                const SizedBox(height: AppSpacing.lg),
                // Terms checkbox
                GestureDetector(
                  onTap: () =>
                      setState(() => _agreedToTerms = !_agreedToTerms),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: _agreedToTerms
                              ? colors.goldPrimary
                              : Colors.transparent,
                          border: Border.all(
                            color: _agreedToTerms
                                ? colors.goldPrimary
                                : colors.ink400,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: _agreedToTerms
                            ? const Icon(Icons.check,
                                size: 14, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'By signing up, you agree to our Terms of Service and Privacy Policy.',
                          style: AppTypography.body
                              .copyWith(color: colors.ink600),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 430.ms, duration: 350.ms),
                const SizedBox(height: AppSpacing.lg),
                // Gold CTA
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
                        'Create Account',
                        style: AppTypography.label.copyWith(
                          color: AppColors.navyDeep,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 490.ms, duration: 350.ms),
                const SizedBox(height: AppSpacing.lg),
                // Sign in link
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Already have an account? ',
                        style:
                            AppTypography.body.copyWith(color: colors.ink600),
                      ),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          'Sign In',
                          style: AppTypography.label
                              .copyWith(color: colors.goldPrimary),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 540.ms, duration: 350.ms),
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
