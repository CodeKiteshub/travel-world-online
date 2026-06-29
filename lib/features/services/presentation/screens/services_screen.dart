import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/router/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(20, topPad + 72, 20, 24),
            children: [
              _ServiceCard(
                colors: colors,
                iconBg: const Color(0xFF2D7A4F).withValues(alpha: 0.12),
                iconColor: AppColors.success,
                icon: Icons.shield_outlined,
                title: 'Insurance',
                description:
                    'Book travel insurance for clients. 4-step wizard with instant policy generation.',
                actionLabel: 'Start Booking →',
                onAction: () => context.push(RouteNames.insurance),
                dimmed: false,
              ),
              const SizedBox(height: 14),
              _ServiceCard(
                colors: colors,
                iconBg: const Color(0xFFE8EEF5),
                iconColor: const Color(0xFF2A4A6B),
                icon: Icons.badge_outlined,
                title: 'Visa',
                description:
                    'Submit visa applications on behalf of clients. Country selection, document upload, status tracking.',
                actionLabel: 'Apply Now →',
                onAction: () => context.push(RouteNames.visa),
                dimmed: false,
              ),
              const SizedBox(height: 14),
              _ServiceCard(
                colors: colors,
                iconBg: const Color(0xFFB45309).withValues(alpha: 0.12),
                iconColor: AppColors.warning,
                icon: Icons.currency_exchange_rounded,
                title: 'Forex',
                description:
                    'Currency exchange and live rates for international travel bookings.',
                actionLabel: null,
                onAction: null,
                dimmed: true,
              ),
            ],
          ),

          // App bar overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: colors.surfacePrimary,
              padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 12),
              child: Text(
                'Services',
                style: AppTypography.displayMd.copyWith(
                  color: colors.ink900,
                  fontSize: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Service card ──────────────────────────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.colors,
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
    required this.dimmed,
  });

  final AppColorScheme colors;
  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dimmed ? 0.7 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.lineSoft),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(icon, size: 28, color: iconColor),
              ),
            ),
            const SizedBox(width: 16),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.displayMd.copyWith(
                      color: colors.ink900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTypography.caption.copyWith(
                      color: colors.ink600,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (actionLabel != null)
                    GestureDetector(
                      onTap: onAction,
                      child: Text(
                        actionLabel!,
                        style: AppTypography.label.copyWith(
                          color: colors.goldPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB45309).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'COMING SOON',
                        style: AppTypography.overline.copyWith(
                          color: AppColors.warning,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
