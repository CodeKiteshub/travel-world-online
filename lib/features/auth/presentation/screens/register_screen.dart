import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../data/models/auth_models.dart';
import '../providers/auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms of Service.')),
      );
      return;
    }
    if (!(_form.currentState?.validate() ?? false)) return;
    HapticFeedback.mediumImpact();

    final success = await ref.read(authNotifierProvider.notifier).register(
          RegisterRequest(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            mobile: _mobileController.text.trim(),
            password: _passwordController.text,
          ),
        );

    if (!mounted) return;
    if (success) {
      HapticFeedback.mediumImpact();
      context.go(RouteNames.verifyEmail);
    }
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

                const SizedBox(height: 20),

                // — Page heading
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create an account',
                      style: AppTypography.displayLg.copyWith(
                          color: colors.ink900, fontSize: 28, height: 1.2),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Join thousands of travel professionals on India's premier B2B platform.",
                      style: AppTypography.body
                          .copyWith(color: colors.ink600, height: 1.55),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 80.ms, duration: 400.ms)
                    .slideY(
                        begin: 0.08,
                        end: 0,
                        delay: 80.ms,
                        duration: 400.ms,
                        curve: Curves.easeOut),

                const SizedBox(height: 28),

                // — First Name + Last Name
                Row(
                  children: [
                    Expanded(
                      child: _LabeledField(
                        label: 'First Name',
                        child: TextFormField(
                          controller: _firstNameController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          style: AppTypography.body
                              .copyWith(color: colors.ink900),
                          decoration: _fieldDec(colors: colors, hint: 'Rakesh'),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LabeledField(
                        label: 'Last Name',
                        child: TextFormField(
                          controller: _lastNameController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          style: AppTypography.body
                              .copyWith(color: colors.ink900),
                          decoration: _fieldDec(colors: colors, hint: 'Sharma'),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 160.ms, duration: 380.ms)
                    .slideY(
                        begin: 0.06,
                        end: 0,
                        delay: 160.ms,
                        duration: 380.ms,
                        curve: Curves.easeOut),

                const SizedBox(height: 16),

                // — Email
                _LabeledField(
                  label: 'Email Address',
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    style: AppTypography.body.copyWith(color: colors.ink900),
                    decoration: _fieldDec(
                        colors: colors,
                        hint: 'rakesh@sharmatravels.com'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                )
                    .animate()
                    .fadeIn(delay: 220.ms, duration: 380.ms)
                    .slideY(
                        begin: 0.06,
                        end: 0,
                        delay: 220.ms,
                        duration: 380.ms,
                        curve: Curves.easeOut),

                const SizedBox(height: 16),

                // — Mobile Number
                _LabeledField(
                  label: 'Mobile Number',
                  child: TextFormField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    maxLength: 10,
                    style: AppTypography.body.copyWith(color: colors.ink900),
                    decoration: _fieldDec(
                        colors: colors, hint: '98765 43210'),
                    validator: (v) => (v == null || v.trim().length != 10)
                        ? 'Enter a valid 10-digit number'
                        : null,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 280.ms, duration: 380.ms)
                    .slideY(
                        begin: 0.06,
                        end: 0,
                        delay: 280.ms,
                        duration: 380.ms,
                        curve: Curves.easeOut),

                const SizedBox(height: 16),

                // — Password
                _LabeledField(
                  label: 'Password',
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    style: AppTypography.body.copyWith(color: colors.ink900),
                    decoration: _fieldDec(
                      colors: colors,
                      hint: 'At least 6 characters',
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
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Password must be at least 6 characters'
                        : null,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 340.ms, duration: 380.ms)
                    .slideY(
                        begin: 0.06,
                        end: 0,
                        delay: 340.ms,
                        duration: 380.ms,
                        curve: Curves.easeOut),

                const SizedBox(height: 20),

                // — Terms checkbox
                GestureDetector(
                  onTap: () =>
                      setState(() => _agreedToTerms = !_agreedToTerms),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 18,
                        height: 18,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: _agreedToTerms
                              ? colors.goldPrimary
                              : Colors.transparent,
                          border: Border.all(
                            color: _agreedToTerms
                                ? colors.goldPrimary
                                : colors.ink400,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: _agreedToTerms
                            ? const Icon(Icons.check,
                                size: 12, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: AppTypography.body.copyWith(
                                color: colors.ink600,
                                fontSize: 12,
                                height: 1.5),
                            children: [
                              const TextSpan(
                                  text: 'By signing up, you agree to our '),
                              TextSpan(
                                text: 'Terms of Service',
                                style: TextStyle(
                                    color: colors.goldPrimary,
                                    fontWeight: FontWeight.w600),
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                    color: colors.goldPrimary,
                                    fontWeight: FontWeight.w600),
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 390.ms, duration: 350.ms),

                const SizedBox(height: 24),

                // — Gold CTA
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
                                  strokeWidth: 2.5, color: Colors.white),
                            )
                          : Text(
                              'Create Account',
                              style: AppTypography.label.copyWith(
                                color: AppColors.navyDeep,
                                fontSize: 14,
                                letterSpacing: 0.4,
                              ),
                            ),
                    ),
                  ),
                ).animate().fadeIn(delay: 440.ms, duration: 350.ms),

                const SizedBox(height: 20),

                // — Sign in link
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTypography.body
                            .copyWith(color: colors.ink600, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          'Sign In',
                          style: AppTypography.label.copyWith(
                              color: colors.goldPrimary, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 480.ms, duration: 350.ms),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDec({
    required AppColorScheme colors,
    required String hint,
    Widget? suffixIcon,
  }) {
    const radius = BorderRadius.all(Radius.circular(12));
    final base = OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: colors.lineSoft));
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.body.copyWith(color: colors.ink400),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      counterText: '',
      border: base,
      enabledBorder: base,
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
