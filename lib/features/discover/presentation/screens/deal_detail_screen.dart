import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/route_names.dart';

class DealDetailScreen extends StatelessWidget {
  const DealDetailScreen({super.key});

  static const _includes = [
    '2 Nights stay in a 5★ Resort',
    'Daily Breakfast & Dinner',
    'Airport pickup & drop transfers',
    'Free access to resort activities',
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    const bg = Color(0xFFFAF8F3);
    const ink900 = Color(0xFF1A1A1A);
    const ink600 = Color(0xFF5E5E5E);
    const lineSoft = Color(0xFFE8E5DC);
    const gold = Color(0xFFC9A84C);
    const success = Color(0xFF2D7A4F);
    const successBg = Color(0x1F2D7A4F);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // — Scrollable content
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero image
                SizedBox(
                  height: 320,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=900&q=80',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.navyDeep, Color(0xFF1A3550)],
                            ),
                          ),
                        ),
                      ),
                      // Subtle top gradient for icons readability
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.0, 0.3],
                            colors: [Color(0x4D000000), Colors.transparent],
                          ),
                        ),
                      ),
                      // Glass app bar
                      Positioned(
                        top: MediaQuery.paddingOf(context).top + 12,
                        left: 20,
                        right: 20,
                        child: Row(
                          children: [
                            _GlassIcon(
                              onTap: () => context.pop(),
                              child: const Icon(Icons.arrow_back_rounded,
                                  size: 18, color: Colors.white),
                            ),
                            const Spacer(),
                            _GlassIcon(
                              onTap: () {},
                              child: const Icon(Icons.favorite_border_rounded,
                                  size: 18, color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            _GlassIcon(
                              onTap: () {},
                              child: const Icon(Icons.share_outlined,
                                  size: 18, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      // HOTEL tag
                      const Positioned(
                        bottom: 20,
                        left: 20,
                        child: _GoldTag(label: 'HOTEL'),
                      ),
                      // Pagination dots
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _heroDot(active: true),
                            const SizedBox(width: 5),
                            _heroDot(active: false),
                            const SizedBox(width: 5),
                            _heroDot(active: false),
                            const SizedBox(width: 5),
                            _heroDot(active: false),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // — White body card (overlaps hero by 28px)
                Transform.translate(
                  offset: const Offset(0, -28),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: bg,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + sub
                        const Text(
                          'Luxury Goa Getaway',
                          style: TextStyle(
                            fontFamily: 'PlayfairDisplay',
                            fontWeight: FontWeight.w700,
                            fontSize: 26,
                            height: 1.2,
                            color: ink900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '5★ Resort · 3 Days 2 Nights',
                          style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 13,
                              color: ink600),
                        ),
                        const SizedBox(height: 12),

                        // Meta row: location + rating
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 14, color: gold),
                            const SizedBox(width: 5),
                            const Text('Goa, India',
                                style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 13,
                                    color: ink600)),
                            const SizedBox(width: 16),
                            const Icon(Icons.star_rounded,
                                size: 14, color: gold),
                            const SizedBox(width: 4),
                            const Text(
                              '4.8',
                              style: TextStyle(
                                  fontFamily: 'DMSans',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: ink900),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(128)',
                              style: AppTypography.caption.copyWith(
                                  color: const Color(0xFF9E9E9E), fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Price row (bordered)
                        Container(
                          padding:
                              const EdgeInsets.symmetric(vertical: 18),
                          decoration: const BoxDecoration(
                            border: Border.symmetric(
                              horizontal:
                                  BorderSide(color: lineSoft),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              const Text(
                                '₹16,999',
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 28,
                                  color: gold,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '/ person',
                                style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 13,
                                    color: ink600),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                '₹22,999',
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: 14,
                                  color: Color(0xFF9E9E9E),
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: successBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '26% OFF',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                    color: success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Deal Includes
                        const Text(
                          'Deal Includes',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: ink900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._includes.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: const BoxDecoration(
                                      color: successBg,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.check_rounded,
                                          size: 12, color: success),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                          fontFamily: 'DMSans',
                                          fontSize: 13,
                                          color: ink900),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        const SizedBox(height: 12),

                        // About
                        const Text(
                          'About this property',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: ink900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Set on a private stretch of Vagator Beach, the resort offers panoramic Arabian Sea views, two infinity pools, and an award-winning spa. Ideal for honeymooners and high-value leisure clients.',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 13,
                            height: 1.7,
                            color: ink600,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Seller card
                        const Text(
                          'Seller',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: ink900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: lineSoft),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [gold, Color(0xFF8B6914)],
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'SS',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: ink900,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: const [
                                        Text(
                                          'Sunset Stays Pvt Ltd',
                                          style: TextStyle(
                                            fontFamily: 'DMSans',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: ink900,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Icon(Icons.verified_rounded,
                                            size: 14, color: gold),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'DMC · Goa · TAAI Verified · 42 deals',
                                      style: TextStyle(
                                          fontFamily: 'DMSans',
                                          fontSize: 11,
                                          color: ink600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // — Fixed bottom action bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(
                  20, 14, 20, MediaQuery.paddingOf(context).bottom + 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: lineSoft)),
              ),
              child: Row(
                children: [
                  _ActionIcon(
                    icon: Icons.chat_bubble_outline_rounded,
                    onTap: () {},
                  ),
                  const SizedBox(width: 10),
                  _ActionIcon(
                    icon: Icons.phone_outlined,
                    onTap: () {},
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.push(RouteNames.dealEnquiry),
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: gold,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Text(
                            'Request Deal',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              letterSpacing: 0.2,
                              color: ink900,
                            ),
                          ),
                        ),
                      ),
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

  Widget _heroDot({required bool active}) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: active ? 20 : 6,
        height: 6,
        decoration: BoxDecoration(
          color: active
              ? Colors.white
              : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(999),
        ),
      );
}

class _GlassIcon extends StatelessWidget {
  const _GlassIcon({required this.onTap, required this.child});
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.85),
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _GoldTag extends StatelessWidget {
  const _GoldTag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.goldPrimary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'DMSans',
          fontWeight: FontWeight.w600,
          fontSize: 10,
          letterSpacing: 1.2,
          color: Color(0xFF1A1A1A),
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8E5DC)),
        ),
        child: Center(
          child: Icon(icon, size: 20, color: const Color(0xFF1A1A1A)),
        ),
      ),
    );
  }
}
