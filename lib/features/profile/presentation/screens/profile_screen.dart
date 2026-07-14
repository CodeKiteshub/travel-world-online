import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../providers/profile_providers.dart';

final _mobileProvider = FutureProvider<String?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_mobile');
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final topPad = MediaQuery.paddingOf(context).top;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );

    final user = FirebaseAuth.instance.currentUser;
    final mobileAsync = ref.watch(_mobileProvider);
    final member = ref.watch(memberProfileProvider).valueOrNull;

    final name = user?.displayName ?? '';
    final email = user?.email ?? '';
    final mobile = mobileAsync.valueOrNull ?? '';
    final memberships = member?.memberships ?? [];

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(0, topPad + 86, 0, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile header card
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colors.surfaceCard,
                    border: Border.all(color: colors.lineSoft),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.goldPrimary, width: 2),
                          color: const Color(0xFFF1E3B7),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person_outline_rounded,
                            size: 32,
                            color: Color(0xFF8B6914),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.isNotEmpty ? name : 'Travel Professional',
                              style: const TextStyle(
                                fontFamily: 'PlayfairDisplay',
                                fontWeight: FontWeight.w700,
                                fontSize: 19,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            if (email.isNotEmpty)
                              Text(
                                email,
                                style: AppTypography.body.copyWith(
                                  color: colors.ink600,
                                  fontSize: 12,
                                ),
                              ),
                            if (mobile.isNotEmpty)
                              Text(
                                mobile,
                                style: AppTypography.body.copyWith(
                                  color: colors.ink600,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),

                // Membership banner(s) — only shown when user belongs to ≥1 association
                if (memberships.isNotEmpty)
                  _MembershipSection(memberships: memberships),

                const SizedBox(height: 16),
                _MenuSection(
                  label: 'MORE',
                  colors: colors,
                  children: [
                    _MenuRow(
                      icon: Icons.help_outline_rounded,
                      title: 'About',
                      subtitle: 'v2026.2.24',
                      trailing: null,
                      colors: colors,
                      onTap: () {},
                    ),
                    _MenuRow(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      subtitle: null,
                      trailing: null,
                      colors: colors,
                      isDestructive: true,
                      onTap: () async {
                        await ref
                            .read(authNotifierProvider.notifier)
                            .signOut();
                        if (context.mounted) context.go(RouteNames.login);
                      },
                      isLast: true,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // App bar overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: colors.surfacePrimary,
              padding: EdgeInsets.fromLTRB(20, topPad + 14, 20, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'ACCOUNT',
                          style: AppTypography.overline.copyWith(
                            color: colors.ink600,
                            fontSize: 10,
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Profile',
                          style: AppTypography.displayLg.copyWith(
                            color: colors.ink900,
                            fontSize: 26,
                            letterSpacing: -0.01,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Shows one card per association. If there are multiple, a PageView with
/// indicator dots lets the user swipe between them.
class _MembershipSection extends StatefulWidget {
  const _MembershipSection({required this.memberships});
  final List<MembershipInfo> memberships;

  @override
  State<_MembershipSection> createState() => _MembershipSectionState();
}

class _MembershipSectionState extends State<_MembershipSection> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final single = widget.memberships.length == 1;

    if (single) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: _MembershipCard(membership: widget.memberships[0]),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 96,
          child: PageView.builder(
            padEnds: false,
            controller: PageController(viewportFraction: 0.92),
            itemCount: widget.memberships.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => Padding(
              padding: EdgeInsets.only(
                left: i == 0 ? 20 : 6,
                right: i == widget.memberships.length - 1 ? 20 : 6,
              ),
              child: _MembershipCard(membership: widget.memberships[i]),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.memberships.length, (i) {
            final active = i == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFFD4A843)
                    : Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}

class _MembershipCard extends StatelessWidget {
  const _MembershipCard({required this.membership});
  final MembershipInfo membership;

  @override
  Widget build(BuildContext context) {
    final shortId = membership.associationId.length > 8
        ? membership.associationId
            .substring(membership.associationId.length - 8)
            .toUpperCase()
        : membership.associationId.toUpperCase();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D1B2A), Color(0xFF1A3850)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ACTIVE MEMBERSHIP',
                  style: AppTypography.overline.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 9,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  membership.associationName,
                  style: const TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Member ID: $shortId',
                  style: AppTypography.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF2D7A4F),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'Active',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    color: Colors.white,
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

// ─────────────────────────────────────────────────────────────────────────────

class _MenuSection extends StatelessWidget {
  const _MenuSection({
    required this.label,
    required this.colors,
    required this.children,
  });
  final String label;
  final AppColorScheme colors;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              label,
              style: AppTypography.overline.copyWith(
                color: colors.ink400,
                fontSize: 10,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: colors.surfaceCard,
              border: Border.all(color: colors.lineSoft),
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.colors,
    required this.onTap,
    this.isDestructive = false,
    this.isLast = false,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final AppColorScheme colors;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final textColor = isDestructive ? colors.error : colors.ink900;
    final iconBg = isDestructive
        ? colors.error.withValues(alpha: 0.12)
        : colors.surfacePrimary;
    final iconColor = isDestructive ? colors.error : colors.ink900;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: isLast
            ? null
            : BoxDecoration(
                border: Border(bottom: BorderSide(color: colors.lineSoft)),
              ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Icon(icon, size: 18, color: iconColor)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body.copyWith(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.body
                          .copyWith(color: colors.ink600, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

