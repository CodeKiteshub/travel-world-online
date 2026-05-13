import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/verify_email_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/discover/presentation/screens/discover_screen.dart';
import '../../features/discover/presentation/screens/deal_detail_screen.dart';
import '../../features/discover/presentation/screens/deal_enquiry_screen.dart';
import '../../features/discover/data/models/deal_model.dart';
import '../../features/my_space/presentation/screens/my_space_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'route_names.dart';

// ── Transition helpers ────────────────────────────────────────────────────────

Page<void> _fadeScalePage(Widget child) => CustomTransitionPage(
      child: child,
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (_, animation, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.97, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: child,
        ),
      ),
    );

Page<void> _slideUpPage(Widget child) => CustomTransitionPage(
      child: child,
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (_, animation, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
        child: child,
      ),
    );

Page<void> _slideLeftPage(Widget child) => CustomTransitionPage(
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (_, animation, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
      ),
    );

// ── ChangeNotifier that bridges Riverpod auth state → GoRouter refresh ────────

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<User?>>(authStateChangesProvider, (_, __) {
      notifyListeners();
    });
    _ref.listen<AuthState>(authNotifierProvider, (_, __) {
      notifyListeners();
    });
  }
  final Ref _ref;
}

// ── Router provider — created ONCE, refresh driven by notifier ────────────────

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: false,
    refreshListenable: notifier,
    redirect: (context, state) {
      final asyncUser = ref.read(authStateChangesProvider);

      // While Firebase auth state is resolving, stay put.
      if (asyncUser.isLoading) return null;

      final user = asyncUser.valueOrNull;
      final location = state.matchedLocation;

      final onAuthScreen = location == RouteNames.login ||
          location == RouteNames.register ||
          location == RouteNames.onboarding ||
          location == RouteNames.splash;
      final onVerifyScreen = location == RouteNames.verifyEmail;

      // No user → ensure they can only reach auth screens.
      if (user == null) {
        if (onAuthScreen) return null;
        return RouteNames.login;
      }

      // User exists but email not verified → only verifyEmail is allowed.
      if (!user.emailVerified) {
        if (onVerifyScreen) return null;
        return RouteNames.verifyEmail;
      }

      // Fully verified → bounce away from all auth-related screens.
      if (onAuthScreen || onVerifyScreen) return RouteNames.home;
      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        pageBuilder: (_, __) => _fadeScalePage(const SplashScreen()),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        pageBuilder: (_, __) => _fadeScalePage(const OnboardingScreen()),
      ),
      GoRoute(
        path: RouteNames.login,
        pageBuilder: (_, __) => _slideUpPage(const LoginScreen()),
      ),
      GoRoute(
        path: RouteNames.register,
        pageBuilder: (_, __) => _slideLeftPage(const RegisterScreen()),
      ),
      GoRoute(
        path: RouteNames.verifyEmail,
        pageBuilder: (_, __) => _slideLeftPage(const VerifyEmailScreen()),
      ),

      // — Full-screen deal screens (no bottom nav)
      GoRoute(
        path: RouteNames.dealDetail,
        pageBuilder: (_, state) =>
            _slideLeftPage(DealDetailScreen(deal: state.extra as Deal)),
      ),
      GoRoute(
        path: RouteNames.dealEnquiry,
        pageBuilder: (_, state) =>
            _slideLeftPage(DealEnquiryScreen(deal: state.extra as Deal)),
      ),

      // — Main shell (bottom nav, 4 tabs)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _ShellScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.home,
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: HomeScreen()),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.discover,
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: DiscoverScreen()),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.mySpace,
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: MySpaceScreen()),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.profile,
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: ProfileScreen()),
            ),
          ]),
        ],
      ),
    ],
  );
});

// ── Shell scaffold with 4-tab bottom nav ─────────────────────────────────────

class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          border: Border(top: BorderSide(color: colors.lineSoft)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                isActive: navigationShell.currentIndex == 0,
                onTap: () => navigationShell.goBranch(0,
                    initialLocation: navigationShell.currentIndex == 0),
                colors: colors,
              ),
              _NavItem(
                icon: Icons.search_rounded,
                activeIcon: Icons.search_rounded,
                label: 'Discover',
                isActive: navigationShell.currentIndex == 1,
                onTap: () => navigationShell.goBranch(1,
                    initialLocation: navigationShell.currentIndex == 1),
                colors: colors,
              ),
              _NavItem(
                icon: Icons.grid_view_outlined,
                activeIcon: Icons.grid_view_rounded,
                label: 'My Space',
                isActive: navigationShell.currentIndex == 2,
                onTap: () => navigationShell.goBranch(2,
                    initialLocation: navigationShell.currentIndex == 2),
                colors: colors,
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
                isActive: navigationShell.currentIndex == 3,
                onTap: () => navigationShell.goBranch(3,
                    initialLocation: navigationShell.currentIndex == 3),
                colors: colors,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.colors,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isActive ? activeIcon : icon,
                  key: ValueKey(isActive),
                  size: 22,
                  color: isActive ? colors.goldPrimary : colors.ink400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.overline.copyWith(
                  color: isActive ? colors.goldPrimary : colors.ink400,
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
