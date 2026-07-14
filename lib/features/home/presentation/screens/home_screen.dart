import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../discover/data/models/deal_model.dart';
import '../../../discover/presentation/providers/discover_providers.dart';
import '../widgets/home_sections.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final topPad = MediaQuery.paddingOf(context).top;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );

    final user = FirebaseAuth.instance.currentUser;
    final firstName = (user?.displayName ?? '').split(' ').first;

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(0, topPad + 76, 0, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Deals carousel — full bleed with horizontal padding inside
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: _HeroCarousel(colors: colors),
                ),
                const SizedBox(height: 16),

                // Associations — the app's flagship module, first section
                AssociationsSection(colors: colors),
                const SizedBox(height: 24),

                // Icon row — secondary modules
                _IconRow(colors: colors),
                const SizedBox(height: 24),

                QuickActionsRow(colors: colors),
                const SizedBox(height: 28),

                // Top Stories removed from home along with News tab
                // TopStoriesSection(colors: colors),
                // const SizedBox(height: 20),

                LuxuryStaysSection(colors: colors),
                const SizedBox(height: 28),

                // Latest Videos removed from home — Video module stays reachable
                // via the icon row.
                // LatestVideosSection(colors: colors),
                // const SizedBox(height: 28),

                OpenJobsSection(colors: colors),
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
              padding: EdgeInsets.fromLTRB(20, topPad + 10, 20, 10),
              child: Row(
                children: [
                  _AvatarButton(colors: colors),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _dateString(),
                          style: AppTypography.overline.copyWith(
                            color: colors.ink600,
                            fontSize: 10,
                            letterSpacing: 1.4,
                          ),
                        ),
                        Text(
                          firstName.isNotEmpty
                              ? '${_greeting()}, $firstName'
                              : _greeting(),
                          style: AppTypography.body.copyWith(
                            color: colors.ink900,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _dateString() {
    final now = DateTime.now();
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final day = days[now.weekday - 1];
    final month = months[now.month - 1];
    return '$day, ${now.day} $month'.toUpperCase();
  }
}

// ── Avatar button ─────────────────────────────────────────────────────────────

class _AvatarButton extends StatelessWidget {
  const _AvatarButton({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    // Same dummy avatar as the Account profile header card.
    return GestureDetector(
      onTap: () => context.go(RouteNames.account),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: colors.goldPrimary, width: 2),
          color: const Color(0xFFF1E3B7),
        ),
        child: const Center(
          child: Icon(
            Icons.person_outline_rounded,
            size: 20,
            color: Color(0xFF8B6914),
          ),
        ),
      ),
    );
  }
}

// ── Hero Carousel — deals ─────────────────────────────────────────────────────

class _HeroCarousel extends ConsumerStatefulWidget {
  const _HeroCarousel({required this.colors});
  final AppColorScheme colors;

  @override
  ConsumerState<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends ConsumerState<_HeroCarousel> {
  final PageController _controller = PageController();
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      final deals = ref.read(featuredDealsProvider).valueOrNull;
      final count = (deals?.length ?? 0).clamp(0, 5);
      if (count > 1 && _controller.hasClients) {
        final next = (_page + 1) % count;
        _controller.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final dealsAsync = ref.watch(featuredDealsProvider);

    return dealsAsync.when(
      loading: () => _skeleton(colors),
      error: (_, __) => _fallbackCard(colors),
      data: (deals) {
        if (deals.isEmpty) return _fallbackCard(colors);
        final items = deals.take(5).toList();
        return AspectRatio(
          aspectRatio: 5 / 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _controller,
                  itemCount: items.length,
                  onPageChanged: (p) => setState(() => _page = p),
                  itemBuilder: (_, i) => _DealSlide(deal: items[i]),
                ),
                if (items.length > 1)
                  Positioned(
                    bottom: 16,
                    right: 20,
                    child: Row(
                      children: List.generate(
                        items.length,
                        (i) => Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: _heroDot(active: i == _page),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _skeleton(AppColorScheme colors) => AspectRatio(
        aspectRatio: 5 / 3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(color: colors.surfaceTertiary),
        ),
      );

  Widget _fallbackCard(AppColorScheme colors) => AspectRatio(
        aspectRatio: 5 / 3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.navyDeep, Color(0xFF1A3550)],
              ),
            ),
          ),
        ),
      );

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

class _DealSlide extends StatelessWidget {
  const _DealSlide({required this.deal});
  final Deal deal;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RouteNames.dealDetail, extra: deal),
      child: Stack(
        fit: StackFit.expand,
        children: [
          deal.firstImage.isNotEmpty
              ? Image.network(
                  deal.firstImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imgFallback(),
                )
              : _imgFallback(),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 1.0],
                colors: [Color(0x1A0D1B2A), Color(0xCC0D1B2A)],
              ),
            ),
          ),
          Positioned(
            left: 14,
            top: 14,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.goldPrimary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'HOT DEAL',
                style: AppTypography.overline.copyWith(
                  color: AppColors.navyDeep,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
          if (deal.duration?.isNotEmpty == true)
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  deal.duration!,
                  style: AppTypography.overline.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  deal.dealName,
                  style: AppTypography.displayMd.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (deal.priceForSame?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    '₹${deal.priceForSame}',
                    style: AppTypography.label.copyWith(
                      color: const Color(0xFFE8D08A),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                if (deal.destination?.isNotEmpty == true) ...[
                  const SizedBox(height: 2),
                  Text(
                    deal.destination!,
                    style: AppTypography.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgFallback() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.navyDeep, Color(0xFF1A3550)],
          ),
        ),
      );
}

// ── Icon row — secondary modules ──────────────────────────────────────────────

class _IconRow extends StatelessWidget {
  const _IconRow({required this.colors});
  final AppColorScheme colors;

  static const _items = [
    // (icon: Icons.newspaper_outlined, label: 'News'), // News removed from home
    (icon: Icons.play_circle_outline_rounded, label: 'Video'),
    (icon: Icons.school_outlined, label: 'Campus'),
    (icon: Icons.apartment_outlined, label: 'PPP'),
    (icon: Icons.work_outline, label: 'Jobs'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          for (final (i, item) in _items.indexed) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(
              child: _IconTile(
                icon: item.icon,
                label: item.label,
                colors: colors,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.icon,
    required this.label,
    required this.colors,
  });
  final IconData icon;
  final String label;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    // Tappable tile that navigates to the corresponding secondary module screen.
    return GestureDetector(
      onTap: () {
        switch (label) {
          // case 'News': // News removed from home
          //   context.push(RouteNames.news);
          //   break;
          case 'Video':
            context.push(RouteNames.video);
            break;
          case 'Campus':
            context.push(RouteNames.campus);
            break;
          case 'PPP':
            context.push(RouteNames.ppp);
            break;
          case 'Jobs':
            context.push(RouteNames.jobs);
            break;
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.lineSoft),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: colors.ink900),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTypography.overline.copyWith(
                color: colors.ink900,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


