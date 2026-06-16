import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';

class CruiseSection extends StatelessWidget {
  const CruiseSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Luxury Cruise Experiences',
          style: AppTypography.heading.copyWith(color: colors.ink900),
        ),
        const SizedBox(height: 4),
        Text(
          'World-class ocean and river cruise packages for your clients',
          style: AppTypography.body.copyWith(color: colors.ink400),
        ),
        const SizedBox(height: 20),

        // Holland America Line card
        _CruiseCard(
          colors: colors,
          title: 'Holland America Line',
          subtitle: 'Ocean Cruises',
          description:
              'Explore the world with Holland America Line — premium ocean cruises '
              'to Alaska, Caribbean, Europe, Asia and beyond. Award-winning ships '
              'with exceptional service and culinary excellence.',
          badge: 'OCEAN CRUISE',
          badgeColor: const Color(0xFF1565C0),
          icon: Icons.directions_boat_rounded,
          iconColor: const Color(0xFF1565C0),
          onTap: null, // HAL detail not yet available
        ),

        const SizedBox(height: 16),

        // A-ROSA card
        _CruiseCard(
          colors: colors,
          title: 'A-ROSA River Cruises',
          subtitle: 'European River Cruises',
          description:
              'Discover the heart of Europe on A-ROSA\'s luxurious river cruise ships. '
              'Sail through the Danube, Rhine, Rhône, Seine and Douro — iconic rivers '
              'connecting historic cities and breathtaking landscapes.',
          badge: 'RIVER CRUISE',
          badgeColor: AppColors.success,
          icon: Icons.water_rounded,
          iconColor: AppColors.success,
          actionLabel: 'Search Cruises',
          onTap: () => context.push(RouteNames.arosaResults),
        ),
      ],
    );
  }
}

class _CruiseCard extends StatelessWidget {
  const _CruiseCard({
    required this.colors,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.badge,
    required this.badgeColor,
    required this.icon,
    required this.iconColor,
    this.actionLabel,
    this.onTap,
  });

  final AppColorScheme colors;
  final String title;
  final String subtitle;
  final String description;
  final String badge;
  final Color badgeColor;
  final IconData icon;
  final Color iconColor;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.lineSoft),
        boxShadow: [
          BoxShadow(
            color: colors.navyDeep.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header band
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.heading
                            .copyWith(color: colors.ink900),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTypography.caption
                            .copyWith(color: colors.ink400),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: AppTypography.label.copyWith(
                      color: badgeColor,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Description
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              description,
              style: AppTypography.body.copyWith(
                color: colors.ink600,
                height: 1.55,
              ),
            ),
          ),

          // Action
          if (actionLabel != null && onTap != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: FilledButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.search_rounded, size: 16),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.goldPrimary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            )
          else if (onTap == null && actionLabel == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: OutlinedButton(
                onPressed: null,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colors.lineSoft),
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Coming Soon',
                  style: AppTypography.body.copyWith(color: colors.ink400),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
