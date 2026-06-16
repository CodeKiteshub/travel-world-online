import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../discover/data/models/deal_model.dart';
import '../../../discover/presentation/providers/discover_providers.dart';
import '../providers/home_providers.dart';

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
    final newsAsync = ref.watch(newsProvider);

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

                // TV LIVE widget
                _TvLiveWidget(colors: colors),
                const SizedBox(height: 20),

                // Icon row — secondary modules
                _IconRow(colors: colors),
                const SizedBox(height: 24),

                // Top Stories heading
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SectionRow(
                    heading: 'Top Stories',
                    colors: colors,
                    onViewAll: () {},
                  ),
                ),
                const SizedBox(height: 12),

                // News cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: newsAsync.when(
                    loading: () => const _NewsSkeletonList(),
                    error: (e, _) => _NewsError(colors: colors),
                    data: (articles) => articles.isEmpty
                        ? _NewsError(colors: colors)
                        : Column(
                            children: articles
                                .take(8)
                                .map((a) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: _NewsCard(
                                        eyebrow:
                                            a.category.name.toUpperCase(),
                                        title: a.title,
                                        meta: a.sourceMeta,
                                        imageUrl: a.firstImage,
                                        colors: colors,
                                      ),
                                    ))
                                .toList(),
                          ),
                  ),
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
              padding: EdgeInsets.fromLTRB(20, topPad + 10, 20, 10),
              child: Row(
                children: [
                  _AvatarButton(user: user, colors: colors),
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
                  _BellButton(colors: colors),
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
  const _AvatarButton({required this.user, required this.colors});
  final User? user;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final photoUrl = user?.photoURL;
    return GestureDetector(
      onTap: () => context.go(RouteNames.account),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: colors.goldPrimary, width: 2),
          color: colors.surfaceTertiary,
        ),
        child: ClipOval(
          child: photoUrl != null && photoUrl.isNotEmpty
              ? Image.network(photoUrl, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _initials(colors))
              : _initials(colors),
        ),
      ),
    );
  }

  Widget _initials(AppColorScheme colors) {
    final name = user?.displayName ?? '';
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((w) => w[0]).take(2).join()
        : '?';
    return Center(
      child: Text(
        initials.toUpperCase(),
        style: AppTypography.label.copyWith(
          color: colors.ink900,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── Bell button ───────────────────────────────────────────────────────────────

class _BellButton extends StatelessWidget {
  const _BellButton({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 40,
          height: 40,
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
          right: 9,
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

// ── TV LIVE widget ────────────────────────────────────────────────────────────

class _TvLiveWidget extends StatefulWidget {
  const _TvLiveWidget({required this.colors});
  final AppColorScheme colors;

  @override
  State<_TvLiveWidget> createState() => _TvLiveWidgetState();
}

class _TvLiveWidgetState extends State<_TvLiveWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.navyDeep,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => Opacity(
                opacity: _pulseAnim.value,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF85149),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'LIVE',
              style: AppTypography.overline.copyWith(
                color: const Color(0xFFF85149),
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Breaking News · TWO TV',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.goldPrimary,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.play_arrow_rounded,
                    size: 20, color: AppColors.navyDeep),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Icon row — secondary modules ──────────────────────────────────────────────

class _IconRow extends StatelessWidget {
  const _IconRow({required this.colors});
  final AppColorScheme colors;

  static const _items = [
    (icon: Icons.feed_outlined, label: 'News'),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _items
            .map((item) => _IconTile(
                  icon: item.icon,
                  label: item.label,
                  colors: colors,
                ))
            .toList(),
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
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: colors.surfaceCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.lineSoft),
          ),
          child: Center(child: Icon(icon, size: 22, color: colors.ink900)),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTypography.overline.copyWith(
            color: colors.ink900,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Section heading row ───────────────────────────────────────────────────────

class _SectionRow extends StatelessWidget {
  const _SectionRow(
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
            'See All →',
            style: AppTypography.label
                .copyWith(color: colors.goldPrimary, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

// ── News cards ────────────────────────────────────────────────────────────────

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
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 76,
                    height: 66,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagePlaceholder(colors),
                  )
                : _imagePlaceholder(colors),
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 3),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body.copyWith(
                    color: colors.ink900,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 3),
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

  Widget _imagePlaceholder(AppColorScheme colors) => Container(
        width: 76,
        height: 66,
        color: colors.surfaceTertiary,
        child: Center(
          child: Icon(Icons.image_outlined, size: 22, color: colors.ink400),
        ),
      );
}

// ── News skeleton + error ─────────────────────────────────────────────────────

class _NewsSkeletonList extends StatelessWidget {
  const _NewsSkeletonList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (_) => const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: _NewsSkeleton(),
        ),
      ),
    );
  }
}

class _NewsSkeleton extends StatelessWidget {
  const _NewsSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    return Container(
      height: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.lineSoft),
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 66,
            decoration: BoxDecoration(
              color: colors.surfaceTertiary,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(height: 9, width: 56, color: colors.surfaceTertiary),
                const SizedBox(height: 7),
                Container(
                    height: 12,
                    width: double.infinity,
                    color: colors.surfaceTertiary),
                const SizedBox(height: 4),
                Container(
                    height: 12, width: 140, color: colors.surfaceTertiary),
                const SizedBox(height: 7),
                Container(height: 9, width: 72, color: colors.surfaceTertiary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsError extends StatelessWidget {
  const _NewsError({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.lineSoft),
      ),
      child: Column(
        children: [
          Icon(Icons.wifi_off_rounded, size: 32, color: colors.ink400),
          const SizedBox(height: 8),
          Text(
            'Could not load stories',
            style: AppTypography.body.copyWith(color: colors.ink600),
          ),
        ],
      ),
    );
  }
}
