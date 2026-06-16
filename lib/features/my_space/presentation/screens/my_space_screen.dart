import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../data/datasources/my_space_remote_datasource.dart';
import '../providers/my_space_providers.dart';

class MySpaceScreen extends ConsumerWidget {
  const MySpaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final topPad = MediaQuery.paddingOf(context).top;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );

    final statsAsync = ref.watch(mySpaceStatsProvider);
    final stats = statsAsync.valueOrNull ?? const MySpaceStats();

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(0, topPad + 86, 0, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats strip
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.surfaceCard,
                    border: Border.all(color: colors.lineSoft),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _StatCell(value: '${stats.bookings}', label: 'Bookings', colors: colors, hasDivider: true),
                      _StatCell(value: '${stats.pending}', label: 'Pending', colors: colors, hasDivider: true),
                      _StatCell(value: '${stats.saved}', label: 'Saved', colors: colors, hasDivider: false),
                    ],
                  ),
                ),

                // Activity
                _SectLabel(label: 'ACTIVITY', colors: colors),
                _ListGroup(
                  colors: colors,
                  children: [
                    _ListRow(
                      icon: Icons.bookmark_outline_rounded,
                      title: 'Bookings',
                      subtitle: "Trips you've booked for clients",
                      trailing: stats.bookings > 0 ? _MetaText(text: '${stats.bookings}', colors: colors) : null,
                      colors: colors,
                      onTap: () {},
                    ),
                    _ListRow(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'My Enquiries',
                      subtitle: 'Deal requests & status',
                      trailing: stats.enquiriesBadge > 0 ? _Badge(count: stats.enquiriesBadge) : null,
                      colors: colors,
                      onTap: () {},
                    ),
                    _ListRow(
                      icon: Icons.forum_outlined,
                      title: 'Chat',
                      subtitle: 'Conversations with peers',
                      trailing: stats.chatBadge > 0 ? _Badge(count: stats.chatBadge) : null,
                      colors: colors,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Book for Clients
                _SectLabel(label: 'BOOK FOR CLIENTS', colors: colors),
                _ListGroup(
                  colors: colors,
                  children: [
                    _ListRow(
                      icon: Icons.shield_outlined,
                      title: 'Insurance',
                      subtitle: 'Travel insurance booking',
                      trailing: null,
                      colors: colors,
                      onTap: () {},
                    ),
                    _ListRow(
                      icon: Icons.badge_outlined,
                      title: 'Visa',
                      subtitle: 'Submit & track applications',
                      trailing: null,
                      colors: colors,
                      onTap: () {},
                    ),
                    _ListRow(
                      icon: Icons.flight_outlined,
                      title: 'Flights',
                      subtitle: 'Submit flight enquiries',
                      trailing: null,
                      colors: colors,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Career
                _SectLabel(label: 'CAREER', colors: colors),
                _ListGroup(
                  colors: colors,
                  children: [
                    _ListRow(
                      icon: Icons.work_outline_rounded,
                      title: 'Jobs',
                      subtitle: 'Industry openings & applications',
                      trailing: _MetaText(text: '48 new', colors: colors),
                      colors: colors,
                      onTap: () {},
                    ),
                    _ListRow(
                      icon: Icons.school_outlined,
                      title: 'My Campus',
                      subtitle: 'Courses in progress',
                      trailing: _MetaText(text: '3 active', colors: colors),
                      colors: colors,
                      onTap: () {},
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
                          'YOUR ACTIVITY',
                          style: AppTypography.overline.copyWith(
                            color: colors.ink600,
                            fontSize: 10,
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'My Space',
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
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.surfaceCard,
                          border: Border.all(color: colors.lineSoft),
                        ),
                        child: Center(
                          child: Icon(Icons.notifications_outlined,
                              size: 18, color: colors.ink900),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colors.error,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: colors.surfaceCard, width: 1.5),
                          ),
                        ),
                      ),
                    ],
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

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.value,
    required this.label,
    required this.colors,
    required this.hasDivider,
  });
  final String value;
  final String label;
  final AppColorScheme colors;
  final bool hasDivider;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: hasDivider
            ? BoxDecoration(
                border: Border(
                  right: BorderSide(color: colors.lineSoft),
                ),
              )
            : null,
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontWeight: FontWeight.w700,
                fontSize: 22,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: AppTypography.overline.copyWith(
                color: colors.ink600,
                fontSize: 9,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectLabel extends StatelessWidget {
  const _SectLabel({required this.label, required this.colors});
  final String label;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 10),
      child: Text(
        label,
        style: AppTypography.overline.copyWith(
          color: colors.ink600,
          fontSize: 10,
          letterSpacing: 1.6,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ListGroup extends StatelessWidget {
  const _ListGroup({required this.colors, required this.children});
  final AppColorScheme colors;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        border: Border.all(color: colors.lineSoft),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _ListRow extends StatelessWidget {
  const _ListRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.colors,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final AppColorScheme colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colors.lineSoft)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colors.surfacePrimary,
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Center(child: Icon(icon, size: 20, color: colors.ink900)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body.copyWith(
                      color: colors.ink900,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.body
                        .copyWith(color: colors.ink600, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, size: 18, color: colors.ink400),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 22),
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFC0392B),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Center(
        child: Text(
          '$count',
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText({required this.text, required this.colors});
  final String text;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.body.copyWith(
        color: colors.ink400,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
