import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );
  }

  static const _newsItems = [
    (
      eyebrow: 'INDUSTRY',
      title: 'Ministry of Tourism Announces New Incredible India 2.0 Campaign',
      meta: 'Travel World · 2h ago',
      imageUrl:
          'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=300&q=80',
    ),
    (
      eyebrow: 'AVIATION',
      title: 'Air India Orders 470 Aircraft from Airbus & Boeing',
      meta: 'Reuters · 5h ago',
      imageUrl:
          'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=300&q=80',
    ),
  ];

  static const _quickTiles = [
    (icon: Icons.menu_book_outlined, label: 'B2B Deals'),
    (icon: Icons.group_outlined, label: 'Associations'),
    (icon: Icons.bookmark_border, label: 'Bookings'),
    (icon: Icons.school_outlined, label: 'Campus'),
    (icon: Icons.work_outline, label: 'Jobs'),
  ];

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
            padding: EdgeInsets.fromLTRB(20, topPad + 88, 20, 112),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                _SearchBar(colors: colors),
                const SizedBox(height: 20),

                // Hero deal card
                _HeroDealCard(colors: colors),
                const SizedBox(height: 24),

                // Quick tiles (5-column)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _quickTiles
                      .map((t) => _QuickTile(
                            icon: t.icon,
                            label: t.label,
                            colors: colors,
                          ))
                      .toList(),
                ),
                const SizedBox(height: 24),

                // Top Stories section
                _SectionRow(
                  heading: 'Top Stories',
                  colors: colors,
                  onViewAll: () {},
                ),
                const SizedBox(height: 14),

                ..._newsItems.map((n) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _NewsCard(
                        eyebrow: n.eyebrow,
                        title: n.title,
                        meta: n.meta,
                        imageUrl: n.imageUrl,
                        colors: colors,
                      ),
                    )),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Hello, Rakesh 👋',
                        style: AppTypography.heading.copyWith(
                          color: colors.ink900,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        'Good Morning',
                        style: AppTypography.caption
                            .copyWith(color: colors.ink600),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _BellButton(colors: colors),
                ],
              ),
            ),
          ),

          // — Miniplayer (floating above bottom nav)
          Positioned(
            bottom: 12,
            left: 16,
            right: 16,
            child: _Miniplayer(colors: colors),
          ),
        ],
      ),
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                size: 20, color: colors.ink900),
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
              border: Border.all(color: colors.surfaceCard, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.colors});
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
              'Search deals, news, people...',
              style:
                  AppTypography.body.copyWith(color: colors.ink400),
            ),
          ),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: colors.ink900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.tune_rounded,
                size: 14, color: colors.surfacePrimary),
          ),
        ],
      ),
    );
  }
}

class _HeroDealCard extends StatelessWidget {
  const _HeroDealCard({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.network(
              'https://images.unsplash.com/photo-1602002418082-a4443e081dd1?w=800&q=80',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.navyDeep,
                      const Color(0xFF1A3550),
                    ],
                  ),
                ),
              ),
            ),
            // Gradient overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 1.0],
                  colors: [
                    Color(0x1A0D1B2A),
                    Color(0xBF0D1B2A),
                  ],
                ),
              ),
            ),
            // Content
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'TAAI CONVENTION · GOA 2025',
                      style: AppTypography.overline.copyWith(
                        color:
                            Colors.white.withValues(alpha: 0.85),
                        fontSize: 10,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Annual Convention &\nTravel Awards',
                    style: AppTypography.displayLg.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '28–30 November · Taj Aguada, Goa',
                    style: AppTypography.body.copyWith(
                      color:
                          Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Register Now',
                          style: AppTypography.label.copyWith(
                            color: AppColors.navyDeep,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded,
                            size: 12,
                            color: AppColors.navyDeep),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Pagination dots
            Positioned(
              bottom: 20,
              right: 24,
              child: Row(
                children: [
                  _heroDot(active: true),
                  const SizedBox(width: 4),
                  _heroDot(active: false),
                  const SizedBox(width: 4),
                  _heroDot(active: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroDot({required bool active}) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: active ? 18 : 5,
        height: 5,
        decoration: BoxDecoration(
          color: active
              ? AppColors.goldPrimary
              : Colors.white.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(999),
        ),
      );
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.label,
    required this.colors,
  });
  final IconData icon;
  final String label;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: colors.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.lineSoft),
          ),
          child: Center(
            child:
                Icon(icon, size: 22, color: colors.navyDeep),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTypography.overline.copyWith(
            color: colors.ink900,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SectionRow extends StatelessWidget {
  const _SectionRow({
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
          style: AppTypography.displayMd.copyWith(
            color: colors.ink900,
            fontSize: 19,
          ),
        ),
        GestureDetector(
          onTap: onViewAll,
          child: Text(
            'View All',
            style: AppTypography.label.copyWith(
              color: colors.goldPrimary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({
    required this.eyebrow,
    required this.title,
    required this.meta,
    required this.imageUrl,
    required this.colors,
  });
  final String eyebrow;
  final String title;
  final String meta;
  final String imageUrl;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.lineSoft),
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
              width: 88,
              height: 76,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 88,
                height: 76,
                color: colors.surfaceTertiary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Text body
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: AppTypography.overline.copyWith(
                    color: colors.goldPrimary,
                    fontSize: 9,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body.copyWith(
                    color: colors.ink900,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.38,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meta,
                  style: AppTypography.caption
                      .copyWith(color: colors.ink400, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Miniplayer extends StatelessWidget {
  const _Miniplayer({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.navyDeep,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: Color(0x400D1B2A),
              blurRadius: 24,
              offset: Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          // Thumb
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.goldPrimary, Color(0xFF8B6914)],
              ),
            ),
            child: const Center(
              child: Icon(Icons.videocam_outlined,
                  size: 20, color: AppColors.navyDeep),
            ),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF85149),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'LIVE',
                      style: AppTypography.overline.copyWith(
                        color: const Color(0xFFF85149),
                        fontSize: 9,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'TWO Live · Travel World',
                  style: AppTypography.body.copyWith(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Play button
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.goldPrimary,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.play_arrow_rounded,
                  size: 18, color: AppColors.navyDeep),
            ),
          ),
        ],
      ),
    );
  }
}
