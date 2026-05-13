import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

final _mobileProvider = FutureProvider<String?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_mobile');
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final user = FirebaseAuth.instance.currentUser;
    final mobileAsync = ref.watch(_mobileProvider);

    final name = user?.displayName ?? '';
    final email = user?.email ?? '';
    final initials = name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: AppTypography.displayLg.copyWith(
                  color: colors.ink900,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 28),

              // Avatar + name block
              Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [colors.goldPrimary, const Color(0xFF8B6914)],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initials.isNotEmpty ? initials : '?',
                        style: AppTypography.displayMd.copyWith(
                          color: AppColors.navyDeep,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.isNotEmpty ? name : 'Travel Professional',
                          style: AppTypography.heading.copyWith(
                            color: colors.ink900,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: AppTypography.body.copyWith(
                            color: colors.ink600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Info tiles
              _InfoTile(
                icon: Icons.email_outlined,
                label: 'Email',
                value: email.isNotEmpty ? email : '—',
                colors: colors,
              ),
              const SizedBox(height: 12),
              mobileAsync.when(
                loading: () => _InfoTile(
                  icon: Icons.phone_outlined,
                  label: 'Mobile',
                  value: '—',
                  colors: colors,
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (mobile) => _InfoTile(
                  icon: Icons.phone_outlined,
                  label: 'Mobile',
                  value: mobile?.isNotEmpty == true ? mobile! : '—',
                  colors: colors,
                ),
              ),
              const SizedBox(height: 12),
              _InfoTile(
                icon: Icons.verified_outlined,
                label: 'Email Status',
                value: user?.emailVerified == true ? 'Verified' : 'Unverified',
                valueColor: user?.emailVerified == true
                    ? const Color(0xFF2D7A4F)
                    : colors.error,
                colors: colors,
              ),

              const SizedBox(height: 32),

              // Sign out
              GestureDetector(
                onTap: () async {
                  await ref.read(authNotifierProvider.notifier).signOut();
                  if (context.mounted) context.go(RouteNames.login);
                },
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.error, width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded,
                          size: 18, color: colors.error),
                      const SizedBox(width: 8),
                      Text(
                        'Sign Out',
                        style: AppTypography.label.copyWith(
                          color: colors.error,
                          fontSize: 14,
                        ),
                      ),
                    ],
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

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.colors,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final AppColorScheme colors;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.lineSoft),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.ink400),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.overline.copyWith(
                    color: colors.ink400,
                    fontSize: 10,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.body.copyWith(
                    color: valueColor ?? colors.ink900,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
