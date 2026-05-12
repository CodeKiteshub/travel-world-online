import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/route_names.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _slides = [
    (
      eyebrow: '01 · CONNECT',
      title: 'Your association, at your fingertips.',
      body:
          "Stay in sync with TAAI, TAFI, IATA and India's leading travel associations. Read circulars, find members, and never miss an industry update.",
      illustration: 'assets/illustrations/onboarding_1.svg',
    ),
    (
      eyebrow: '02 · DISCOVER',
      title: 'The B2B marketplace, made for agents.',
      body:
          'Discover hotels, packages, and luxury properties. Post your own deals, find a DMC, and connect with verified sellers across the trade.',
      illustration: 'assets/illustrations/onboarding_2.svg',
    ),
    (
      eyebrow: '03 · GROW',
      title: 'Upskill, book, and scale your agency.',
      body:
          'Train on the Campus, book insurance and visas for clients, and run your travel business — all in one professional tool.',
      illustration: 'assets/illustrations/onboarding_3.svg',
    ),
  ];

  void _goToPage(int page) {
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOut,
    );
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _goToPage(_currentPage + 1);
    } else {
      context.go(RouteNames.login);
    }
  }

  void _prev() => _goToPage(_currentPage - 1);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final topPad = MediaQuery.paddingOf(context).top;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    // Card height: 44% of screen
    final cardHeight = size.height * 0.44;

    return Scaffold(
      // Static navy — never changes between slides
      backgroundColor: const Color(0xFF0D1B2A),
      body: Stack(
        children: [
          // — Swipeable illustration PageView (fills everything above the card)
          Positioned.fill(
            bottom: cardHeight - 32,
            child: PageView.builder(
              controller: _controller,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: _slides.length,
              itemBuilder: (_, i) => SvgPicture.asset(
                _slides[i].illustration,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),

          // — Skip button (top-right, frosted pill)
          Positioned(
            top: topPad + 12,
            right: 20,
            child: GestureDetector(
              onTap: () => context.go(RouteNames.login),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Text(
                  'Skip',
                  style: AppTypography.label.copyWith(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),

          // — White bottom card (static; only text inside animates)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: cardHeight + bottomPad,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surfacePrimary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: EdgeInsets.fromLTRB(28, 36, 28, 28 + bottomPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Animated slide text
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.06),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: anim,
                            curve: Curves.easeOut,
                          )),
                          child: child,
                        ),
                      ),
                      child: _SlideContent(
                        key: ValueKey(_currentPage),
                        eyebrow: _slides[_currentPage].eyebrow,
                        title: _slides[_currentPage].title,
                        body: _slides[_currentPage].body,
                      ),
                    ),
                  ),

                  // Pagination dots
                  Row(
                    children: List.generate(
                      _slides.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.only(right: 6),
                        width: i == _currentPage ? 24 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? AppColors.goldPrimary
                              : AppColors.lineSoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Action row
                  Row(
                    children: [
                      if (_currentPage > 0) ...[
                        _BackButton(onTap: _prev),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: _PressableButton(
                          onTap: _next,
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.goldPrimary,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentPage == _slides.length - 1
                                      ? 'Get Started'
                                      : 'Next',
                                  style: AppTypography.label.copyWith(
                                    color: AppColors.navyDeep,
                                    fontSize: 14,
                                  ),
                                ),
                                if (_currentPage < _slides.length - 1) ...[
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: AppColors.navyDeep,
                                    size: 18,
                                  ),
                                ],
                              ],
                            ),
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

// — Text block for each slide
class _SlideContent extends StatelessWidget {
  const _SlideContent({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.body,
  });

  final String eyebrow;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          eyebrow,
          style: AppTypography.overline.copyWith(
            color: AppColors.goldPrimary,
            fontSize: 10,
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          title,
          style: AppTypography.displayLg.copyWith(
            color: AppColors.ink900,
            fontSize: 26,
            height: 1.22,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          body,
          style: AppTypography.body.copyWith(
            color: AppColors.ink600,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

// — Square back-nav button
class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lineSoft, width: 1.5),
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
        ),
        child: const Center(
          child: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.ink900,
            size: 20,
          ),
        ),
      ),
    );
  }
}

// — Scale micro-interaction wrapper
class _PressableButton extends StatefulWidget {
  const _PressableButton({required this.onTap, required this.child});
  final VoidCallback onTap;
  final Widget child;

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.96),
        onTapUp: (_) {
          setState(() => _scale = 1.0);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _scale = 1.0),
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      );
}
