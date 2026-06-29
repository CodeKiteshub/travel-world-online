import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/router/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../data/models/association_model.dart';
import '../providers/association_session_provider.dart';

class AssociationLoginScreen extends ConsumerStatefulWidget {
  const AssociationLoginScreen({
    super.key,
    required this.assoc,
  });
  final AssociationModel assoc;

  @override
  ConsumerState<AssociationLoginScreen> createState() =>
      _AssociationLoginScreenState();
}

class _AssociationLoginScreenState
    extends ConsumerState<AssociationLoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;
  bool _forgotSent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Please enter email and password.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(associationSessionProvider.notifier).login(
            associationId: widget.assoc.id,
            email: email,
            password: pass,
          );
      if (mounted) {
        context.go(
          RouteNames.associationDashboard.replaceFirst(':id', widget.assoc.id),
          extra: widget.assoc,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = _parseError(e);
          _loading = false;
        });
      }
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Enter your email above to reset your password.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(associationSessionProvider.notifier).forgotPassword(
            email: email,
            associationId: widget.assoc.id,
          );
      if (mounted) setState(() => _forgotSent = true);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not send reset email.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _parseError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('401') || msg.contains('invalid') || msg.contains('incorrect')) {
      return 'Invalid email or password.';
    }
    if (msg.contains('network') || msg.contains('socket')) {
      return 'No internet connection.';
    }
    return 'Sign in failed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    final colors = Theme.of(context).extension<AppColorScheme>()!;

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Hero(
              assoc: widget.assoc,
              topPad: topPad,
              onBack: () => context.pop(),
            ),
            _Form(
              emailCtrl: _emailCtrl,
              passCtrl: _passCtrl,
              obscure: _obscure,
              loading: _loading,
              error: _error,
              forgotSent: _forgotSent,
              colors: colors,
              onToggleObscure: () => setState(() => _obscure = !_obscure),
              onSignIn: _signIn,
              onForgot: _forgotPassword,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Navy gradient hero ────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero({required this.assoc, required this.topPad, required this.onBack});
  final AssociationModel assoc;
  final double topPad;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, topPad + 16, 24, 36),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D1B2A), Color(0xFF1A3850)],
        ),
      ),
      child: Stack(
        children: [
          // Gold glow accent
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFC9A84C).withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: onBack,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Logo circle
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: assoc.logoUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: assoc.logoUrl,
                        fit: BoxFit.contain,
                        placeholder: (_, __) =>
                            const Center(child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 2))),
                        errorWidget: (_, __, ___) =>
                            _LogoInitials(name: assoc.name),
                      )
                    : _LogoInitials(name: assoc.name),
              ),
              const SizedBox(height: 16),
              Text(
                assoc.name,
                style: AppTypography.displayMd.copyWith(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                assoc.atype,
                style: AppTypography.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LogoInitials extends StatelessWidget {
  const _LogoInitials({required this.name});
  final String name;
  @override
  Widget build(BuildContext context) {
    final initials = name.trim().split(' ').take(2).map((w) => w[0]).join();
    return Center(
      child: Text(
        initials.toUpperCase(),
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0D1B2A),
        ),
      ),
    );
  }
}

// ── Cream form ────────────────────────────────────────────────────────────────

class _Form extends StatelessWidget {
  const _Form({
    required this.emailCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.loading,
    required this.error,
    required this.forgotSent,
    required this.colors,
    required this.onToggleObscure,
    required this.onSignIn,
    required this.onForgot,
  });

  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool obscure;
  final bool loading;
  final String? error;
  final bool forgotSent;
  final AppColorScheme colors;
  final VoidCallback onToggleObscure;
  final VoidCallback onSignIn;
  final VoidCallback onForgot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Email',
            style: AppTypography.label.copyWith(
              color: colors.ink900,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          _InputField(
            controller: emailCtrl,
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            colors: colors,
          ),
          const SizedBox(height: 4),
          Text(
            'Password',
            style: AppTypography.label.copyWith(
              color: colors.ink900,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          _PasswordField(
            controller: passCtrl,
            obscure: obscure,
            colors: colors,
            onToggle: onToggleObscure,
          ),
          const SizedBox(height: 8),
          if (error != null) ...[
            Text(
              error!,
              style: AppTypography.caption.copyWith(
                color: colors.error,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
          if (forgotSent)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Password reset instructions sent to your email.',
                style: AppTypography.caption.copyWith(
                  color: colors.success,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 4),
          // Sign In button
          GestureDetector(
            onTap: loading ? null : onSignIn,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: colors.goldPrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: loading
                  ? const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Text(
                      'Sign In',
                      style: AppTypography.label.copyWith(
                        color: colors.ink900,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
          const SizedBox(height: 10),
          // Get Password button
          GestureDetector(
            onTap: loading ? null : onForgot,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: colors.success,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Get Password',
                style: AppTypography.label.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    required this.colors,
    this.keyboardType,
  });
  final TextEditingController controller;
  final String hint;
  final AppColorScheme colors;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppTypography.body.copyWith(color: colors.ink900, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.body.copyWith(color: colors.ink400, fontSize: 14),
          filled: true,
          fillColor: colors.surfaceCard,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.lineSoft),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.lineSoft),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.ink900),
          ),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.colors,
    required this.onToggle,
  });
  final TextEditingController controller;
  final bool obscure;
  final AppColorScheme colors;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: AppTypography.body.copyWith(color: colors.ink900, fontSize: 14),
        decoration: InputDecoration(
          hintText: '••••••••',
          hintStyle: AppTypography.body.copyWith(color: colors.ink400, fontSize: 14),
          filled: true,
          fillColor: colors.surfaceCard,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.lineSoft),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.lineSoft),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.ink900),
          ),
          suffixIcon: GestureDetector(
            onTap: onToggle,
            child: Icon(
              obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 18,
              color: colors.ink400,
            ),
          ),
        ),
      ),
    );
  }
}
