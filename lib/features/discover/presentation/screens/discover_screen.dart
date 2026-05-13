import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../data/models/deal_model.dart';
import '../providers/discover_providers.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  int _activeChip = 0;

  static const _chips = [
    'All',
    'Hotels',
    'Packages',
    'Transport',
    'Villas',
    'Tailor Made',
    'DMC',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );
  }

  List<Deal> _filtered(List<Deal> deals) {
    if (_activeChip == 0) return deals;
    final chip = _chips[_activeChip].toLowerCase();
    return deals.where((d) {
      final type = (d.dealType ?? d.hotelCategory ?? '').toLowerCase();
      return type.contains(chip);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final topPad = MediaQuery.paddingOf(context).top;
    final dealsAsync = ref.watch(featuredDealsProvider);

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, topPad + 76, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _B2bSearchBar(colors: colors),
                const SizedBox(height: 18),

                // Category chips
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _chips.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => setState(() => _activeChip = i),
                      child: _CategoryChip(
                        label: _chips[i],
                        isActive: _activeChip == i,
                        colors: colors,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                dealsAsync.when(
                  loading: () => _DealsSkeletonBody(colors: colors),
                  error: (_, __) => _DealsError(colors: colors),
                  data: (all) {
                    final deals = _filtered(all);
                    if (deals.isEmpty) {
                      return _DealsError(
                          colors: colors, message: 'No deals found');
                    }
                    final featured = deals.first;
                    final rest = deals.skip(1).toList();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _B2bSectionRow(
                            heading: 'Featured Deals',
                            colors: colors,
                            onViewAll: () {}),
                        const SizedBox(height: 12),
                        _FeaturedCard(
                          deal: featured,
                          colors: colors,
                          onTap: () => context.push(
                              RouteNames.dealDetail,
                              extra: featured),
                        ),
                        if (rest.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          _B2bSectionRow(
                              heading: 'Best Offers for You',
                              colors: colors,
                              onViewAll: () {}),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 190,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: rest.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (_, i) => _SmallDealCard(
                                deal: rest[i],
                                colors: colors,
                                onTap: () => context.push(
                                    RouteNames.dealDetail,
                                    extra: rest[i]),
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
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
              padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: colors.surfaceCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.lineSoft),
                    ),
                    child: Center(
                      child: Icon(Icons.arrow_back_rounded,
                          size: 18, color: colors.ink900),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'B2B Marketplace',
                    style: AppTypography.displayMd.copyWith(
                      color: colors.ink900,
                      fontSize: 19,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: colors.surfaceCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.lineSoft),
                    ),
                    child: Center(
                      child: Icon(Icons.favorite_border_rounded,
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

class _B2bSearchBar extends StatelessWidget {
  const _B2bSearchBar({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.lineSoft),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 18, color: colors.ink600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Search deals...',
              style: AppTypography.body.copyWith(color: colors.ink400),
            ),
          ),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: colors.goldPrimary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.tune_rounded, size: 14, color: colors.navyDeep),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip(
      {required this.label, required this.isActive, required this.colors});
  final String label;
  final bool isActive;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? colors.goldPrimary : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
            color: isActive ? colors.goldPrimary : colors.lineSoft),
      ),
      child: Text(
        label,
        style: AppTypography.body.copyWith(
          color: isActive ? colors.navyDeep : colors.ink600,
          fontSize: 12,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _B2bSectionRow extends StatelessWidget {
  const _B2bSectionRow(
      {required this.heading, required this.colors, required this.onViewAll});
  final String heading;
  final AppColorScheme colors;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(heading,
            style: AppTypography.displayMd
                .copyWith(color: colors.ink900, fontSize: 19)),
        GestureDetector(
          onTap: onViewAll,
          child: Text('View All',
              style: AppTypography.label
                  .copyWith(color: colors.goldPrimary, fontSize: 12)),
        ),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard(
      {required this.deal, required this.colors, required this.onTap});
  final Deal deal;
  final AppColorScheme colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.lineSoft),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 180,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  deal.firstImage.isNotEmpty
                      ? Image.network(
                          deal.firstImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _imgFallback(colors),
                        )
                      : _imgFallback(colors),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.4, 1.0],
                        colors: [Colors.transparent, Color(0x80000000)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        deal.displayTag,
                        style: AppTypography.overline.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(Icons.favorite_border_rounded,
                            size: 16, color: colors.goldPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deal.dealName,
                    style: AppTypography.displayMd
                        .copyWith(color: colors.ink900, fontSize: 19),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    [
                      if (deal.hotelCategory?.isNotEmpty == true)
                        deal.hotelCategory!,
                      if (deal.duration?.isNotEmpty == true) deal.duration!,
                      if (deal.destination?.isNotEmpty == true)
                        deal.destination!,
                    ].join(' · '),
                    style: AppTypography.body
                        .copyWith(color: colors.ink600, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        deal.priceForSame?.isNotEmpty == true
                            ? '₹${deal.priceForSame}'
                            : 'On Request',
                        style: AppTypography.body.copyWith(
                          color: colors.goldPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '/ person',
                        style: AppTypography.body
                            .copyWith(color: colors.ink600, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imgFallback(AppColorScheme colors) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.navyDeep, const Color(0xFF1A3550)],
          ),
        ),
      );
}

class _SmallDealCard extends StatelessWidget {
  const _SmallDealCard(
      {required this.deal, required this.colors, required this.onTap});
  final Deal deal;
  final AppColorScheme colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.lineSoft),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 110,
              child: deal.firstImage.isNotEmpty
                  ? Image.network(
                      deal.firstImage,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: colors.surfaceTertiary),
                    )
                  : Container(color: colors.surfaceTertiary),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deal.dealName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body.copyWith(
                      color: colors.ink900,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    deal.priceForSame?.isNotEmpty == true
                        ? '₹${deal.priceForSame}'
                        : 'On Request',
                    style: AppTypography.body.copyWith(
                      color: colors.goldPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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

class _DealsSkeletonBody extends StatelessWidget {
  const _DealsSkeletonBody({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            height: 16, width: 120, color: colors.surfaceTertiary),
        const SizedBox(height: 12),
        Container(
          height: 280,
          decoration: BoxDecoration(
            color: colors.surfaceTertiary,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(height: 20),
        Container(
            height: 16, width: 160, color: colors.surfaceTertiary),
        const SizedBox(height: 12),
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, __) => Container(
              width: 160,
              decoration: BoxDecoration(
                color: colors.surfaceTertiary,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DealsError extends StatelessWidget {
  const _DealsError({required this.colors, this.message});
  final AppColorScheme colors;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.lineSoft),
      ),
      child: Column(
        children: [
          Icon(Icons.wifi_off_rounded, size: 32, color: colors.ink400),
          const SizedBox(height: 8),
          Text(
            message ?? 'Could not load deals',
            style: AppTypography.body.copyWith(color: colors.ink600),
          ),
        ],
      ),
    );
  }
}
