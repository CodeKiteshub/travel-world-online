import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../providers/discover_providers.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final topPad = MediaQuery.paddingOf(context).top;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );

    final dealsAsync = ref.watch(featuredDealsProvider);

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(0, topPad + 86, 0, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero spotlight
                dealsAsync.when(
                  loading: () => _HeroSkeleton(colors: colors),
                  error: (_, __) => _HeroFallback(colors: colors),
                  data: (deals) => deals.isEmpty
                      ? _HeroFallback(colors: colors)
                      : _HeroSpotlight(deal: deals.first, colors: colors),
                ),
                const SizedBox(height: 24),

                // Modules label
                Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 12),
                  child: Text(
                    'MODULES',
                    style: AppTypography.overline.copyWith(
                      color: colors.ink600,
                      fontSize: 10,
                      letterSpacing: 1.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // 2×2 grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 160 / 156,
                    children: [
                      _ModuleTile(
                        icon: Icons.menu_book_outlined,
                        title: 'B2B Marketplace',
                        subtitle: 'Hotels, packages, DMCs, villas, transport',
                        meta: '240+ active deals',
                        isLuxury: false,
                        colors: colors,
                        onTap: () {},
                      ),
                      _ModuleTile(
                        icon: Icons.star_outline_rounded,
                        title: 'Luxury',
                        subtitle: 'Hotels, cruises, trains, premium transport',
                        meta: 'Curated picks',
                        isLuxury: true,
                        colors: colors,
                        onTap: () {},
                      ),
                      _ModuleTile(
                        icon: Icons.group_outlined,
                        title: 'Associations',
                        subtitle: 'TAAI, TAFI, IATA · circulars & community',
                        meta: '3 new circulars',
                        isLuxury: false,
                        colors: colors,
                        onTap: () {},
                      ),
                      _ModuleTile(
                        icon: Icons.school_outlined,
                        title: 'Campus',
                        subtitle: 'Training courses & destination specialist',
                        meta: '12 new lessons',
                        isLuxury: false,
                        colors: colors,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // More to Explore label
                Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 12),
                  child: Text(
                    'MORE TO EXPLORE',
                    style: AppTypography.overline.copyWith(
                      color: colors.ink600,
                      fontSize: 10,
                      letterSpacing: 1.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Row tiles
                _RowTile(
                  icon: Icons.local_offer_outlined,
                  title: 'Deals & Offers',
                  subtitle: "Today's best B2B rates",
                  colors: colors,
                  onTap: () {},
                ),
                _RowTile(
                  icon: Icons.calendar_month_outlined,
                  title: 'Events',
                  subtitle: 'Conventions, expos, FAM trips',
                  colors: colors,
                  onTap: () {},
                ),
                _RowTile(
                  icon: Icons.explore_outlined,
                  title: 'Directory',
                  subtitle: 'Find agents, DMCs & sellers',
                  colors: colors,
                  onTap: () {},
                ),
                _RowTile(
                  icon: Icons.videocam_outlined,
                  title: 'Live TV & Radio',
                  subtitle: 'Industry broadcasts & podcasts',
                  colors: colors,
                  onTap: () {},
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
                          'EXPLORE',
                          style: AppTypography.overline.copyWith(
                            color: colors.ink600,
                            fontSize: 10,
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Discover',
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
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.surfaceCard,
                      border: Border.all(color: colors.lineSoft),
                    ),
                    child: Center(
                      child: Icon(Icons.search_rounded,
                          size: 18, color: colors.ink900),
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

class _HeroSpotlight extends StatelessWidget {
  const _HeroSpotlight({required this.deal, required this.colors});
  final dynamic deal;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RouteNames.dealDetail, extra: deal),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: colors.surfaceTertiary,
        ),
        clipBehavior: Clip.antiAlias,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              deal.firstImage.isNotEmpty
                  ? Image.network(
                      deal.firstImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallback(),
                    )
                  : _fallback(),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x1A0D1B2A), Color(0xC50D1B2A)],
                  ),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'SPOTLIGHT',
                        style: AppTypography.overline.copyWith(
                          color: Colors.white,
                          fontSize: 9,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      deal.dealName,
                      style: const TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        color: Colors.white,
                        height: 1.15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (deal.destination?.isNotEmpty == true)
                          deal.destination!,
                        if (deal.priceForSame?.isNotEmpty == true)
                          '₹${deal.priceForSame}',
                      ].join(' · '),
                      style: AppTypography.body.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallback() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.navyDeep, Color(0xFF1A3550)],
          ),
        ),
      );
}

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: colors.surfaceTertiary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const AspectRatio(aspectRatio: 16 / 9),
    );
  }
}

class _HeroFallback extends StatelessWidget {
  const _HeroFallback({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppColors.navyDeep, Color(0xFF1A3550)],
        ),
      ),
      child: const AspectRatio(aspectRatio: 16 / 9),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.isLuxury,
    required this.colors,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final String meta;
  final bool isLuxury;
  final AppColorScheme colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconBg =
        isLuxury ? colors.navyDeep : colors.surfacePrimary;
    final iconColor =
        isLuxury ? colors.goldPrimary : colors.ink900;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          border: Border.all(color: colors.lineSoft),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Icon(icon, size: 22, color: iconColor)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontWeight: FontWeight.w700,
                fontSize: 15,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                subtitle,
                style: AppTypography.body.copyWith(
                  color: colors.ink600,
                  fontSize: 11,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$meta →',
              style: AppTypography.label.copyWith(
                color: colors.goldPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RowTile extends StatelessWidget {
  const _RowTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final AppColorScheme colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          border: Border.all(color: colors.lineSoft),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.surfacePrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Icon(icon, size: 20, color: colors.ink900)),
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
                      fontWeight: FontWeight.w600,
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
            Icon(Icons.chevron_right_rounded, size: 18, color: colors.ink400),
          ],
        ),
      ),
    );
  }
}
