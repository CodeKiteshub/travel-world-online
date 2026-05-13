import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/route_names.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
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

  static const _smallDeals = [
    (
      title: 'Dubai Holiday Package',
      price: '₹24,500',
      imageUrl:
          'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=400&q=80',
    ),
    (
      title: 'Kerala Backwaters',
      price: '₹12,099',
      imageUrl:
          'https://images.unsplash.com/photo-1602002418082-a4443e081dd1?w=400&q=80',
    ),
    (
      title: 'Bali Paradise',
      price: '₹38,500',
      imageUrl:
          'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&q=80',
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: Stack(
        children: [
          // — Scrollable content
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, topPad + 76, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
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

                // Featured Deals section
                _B2bSectionRow(
                    heading: 'Featured Deals',
                    colors: colors,
                    onViewAll: () {}),
                const SizedBox(height: 12),

                // Featured card
                _FeaturedCard(
                  colors: colors,
                  onTap: () => context.push(RouteNames.dealDetail),
                ),
                const SizedBox(height: 4),

                // Best Offers section
                _B2bSectionRow(
                    heading: 'Best Offers for You',
                    colors: colors,
                    onViewAll: () {}),
                const SizedBox(height: 12),

                // Horizontal scroll of small cards
                SizedBox(
                  height: 190,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _smallDeals.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => _SmallDealCard(
                      title: _smallDeals[i].title,
                      price: _smallDeals[i].price,
                      imageUrl: _smallDeals[i].imageUrl,
                      colors: colors,
                      onTap: () => context.push(RouteNames.dealDetail),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // — App bar overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: colors.surfacePrimary,
              padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 12),
              child: Row(
                children: [
                  // Back-style icon (rounded square)
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
                  // Wishlist icon (rounded square)
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
            child: Icon(Icons.tune_rounded,
                size: 14, color: colors.navyDeep),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isActive,
    required this.colors,
  });
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
          color: isActive ? colors.goldPrimary : colors.lineSoft,
        ),
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
  const _B2bSectionRow({
    required this.heading,
    required this.colors,
    required this.onViewAll,
  });
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
        Text(
          heading,
          style:
              AppTypography.displayMd.copyWith(color: colors.ink900, fontSize: 19),
        ),
        GestureDetector(
          onTap: onViewAll,
          child: Text(
            'View All',
            style: AppTypography.label
                .copyWith(color: colors.goldPrimary, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.colors, required this.onTap});
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
            // Image area
            SizedBox(
              height: 180,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=900&q=80',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.navyDeep, const Color(0xFF1A3550)],
                        ),
                      ),
                    ),
                  ),
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
                  // HOTEL tag
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
                        'HOTEL',
                        style: AppTypography.overline.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  // Heart icon
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
                        child: Icon(Icons.favorite_rounded,
                            size: 16, color: colors.goldPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Luxury Goa Getaway',
                    style: AppTypography.displayMd.copyWith(
                      color: colors.ink900,
                      fontSize: 19,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '5★ Resort · 3D/2N · Goa, India',
                    style: AppTypography.body
                        .copyWith(color: colors.ink600, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₹16,999',
                        style: AppTypography.body.copyWith(
                          color: colors.goldPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '/ person · 4.8 ★ (128)',
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
}

class _SmallDealCard extends StatelessWidget {
  const _SmallDealCard({
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.colors,
    required this.onTap,
  });
  final String title;
  final String price;
  final String imageUrl;
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
            // Image
            SizedBox(
              height: 110,
              child: Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: colors.surfaceTertiary,
                ),
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
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
                    price,
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
