import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
import '../../features/marketplace/presentation/screens/marketplace_screen.dart';
import '../../features/associations/presentation/screens/associations_screen.dart';
import '../../features/services/presentation/screens/services_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/discover/presentation/screens/deal_detail_screen.dart';
import '../../features/discover/presentation/screens/deal_enquiry_screen.dart';
import '../../features/news/presentation/screens/news_screen.dart';
import '../../features/news/presentation/screens/news_article_detail_screen.dart';
import '../../features/video/presentation/screens/video_screen.dart';
import '../../features/campus/presentation/screens/campus_screen.dart';
import '../../features/campus/presentation/screens/advisory_board_screen.dart';
import '../../features/campus/presentation/screens/destination_specialist_screen.dart';
import '../../features/campus/presentation/screens/dest_sub_category_screen.dart';
import '../../features/campus/presentation/screens/dest_sub_sub_category_screen.dart';
import '../../features/campus/presentation/screens/dest_video_screen.dart';
import '../../features/campus/presentation/screens/skill_development_screen.dart';
import '../../features/campus/presentation/screens/course_list_screen.dart';
import '../../features/ppp/presentation/screens/ppp_screen.dart';
import '../../features/ppp/presentation/screens/ppp_detail_screen.dart';
import '../../features/ppp/presentation/screens/ppp_directory_screen.dart';
import '../../features/ppp/presentation/screens/ppp_register_screen.dart';
import '../../features/ppp/data/models/ppp_model.dart';
import '../../features/jobs/presentation/screens/jobs_screen.dart';
import '../../features/associations/data/models/association_model.dart';
import '../../features/associations/data/models/association_content_model.dart';
import '../../features/associations/presentation/screens/association_login_screen.dart';
import '../../features/associations/presentation/screens/association_dashboard_screen.dart';
import '../../features/associations/presentation/screens/association_deals_screen.dart';
import '../../features/associations/presentation/screens/association_deal_create_screen.dart';
import '../../features/associations/presentation/screens/association_circulars_screen.dart';
import '../../features/associations/presentation/screens/association_updates_screen.dart';
import '../../features/associations/presentation/screens/association_directory_screen.dart';
import '../../features/associations/presentation/screens/association_jobs_screen.dart';
import '../../features/associations/presentation/screens/association_job_create_screen.dart';
import '../../features/associations/presentation/screens/association_job_applicants_screen.dart';
import '../../features/associations/presentation/screens/association_chat_screen.dart';
import '../../features/associations/presentation/screens/association_cabs_screen.dart';
import '../../features/associations/presentation/screens/association_admin_cab_screen.dart';
import '../../features/associations/presentation/screens/association_dmc_register_screen.dart';
import '../../features/discover/data/models/deal_model.dart';
import '../../features/home/data/models/article_model.dart';
import '../../features/marketplace/presentation/screens/villa_search_screen.dart';
import '../../features/marketplace/presentation/screens/villa_detail_screen.dart';
import '../../features/marketplace/presentation/screens/arosa_results_screen.dart';
import '../../features/marketplace/presentation/screens/luxury_hotel_detail_screen.dart';
import '../../features/marketplace/data/models/villa_rate_model.dart';
import '../../features/marketplace/data/models/luxury_hotel_model.dart';
import '../../features/insurance/presentation/screens/insurance_wizard_screen.dart';
import '../../features/insurance/presentation/screens/insurance_confirmation_screen.dart';
import '../../features/visa/presentation/screens/visa_wizard_screen.dart';
import '../../features/visa/presentation/screens/visa_confirmation_screen.dart';
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
    _ref.listen<bool>(splashCompletedProvider, (_, __) {
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
      final location = state.matchedLocation;
      final splashDone = ref.read(splashCompletedProvider);

      if (location == RouteNames.splash && !splashDone) return null;

      if (asyncUser.isLoading) {
        if (location == RouteNames.splash && splashDone) {
          return RouteNames.login;
        }
        return null;
      }

      // Prefer currentUser: authStateChanges/userChanges can lag behind
      // User.reload() (emailVerified), which would bounce verify → home → verify.
      User? user;
      if (Firebase.apps.isNotEmpty) {
        user = FirebaseAuth.instance.currentUser;
      }
      user ??= asyncUser.valueOrNull;

      final onAuthScreen = location == RouteNames.login ||
          location == RouteNames.register ||
          location == RouteNames.onboarding ||
          location == RouteNames.splash;
      final onVerifyScreen = location == RouteNames.verifyEmail;

      if (user == null) {
        if (onAuthScreen && location != RouteNames.splash) return null;
        return RouteNames.login;
      }

      if (!user.emailVerified) {
        if (onVerifyScreen) return null;
        return RouteNames.verifyEmail;
      }

      if (onAuthScreen || onVerifyScreen) return RouteNames.home;
      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        pageBuilder: (context, state) => const NoTransitionPage<void>(
          key: ValueKey('splash'),
          child: SplashScreen(),
        ),
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

      // — Full-screen deal flow (no bottom nav)
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

      // — Luxury hotel detail (no bottom nav)
      GoRoute(
        path: RouteNames.hotelDetail,
        pageBuilder: (_, state) => _slideLeftPage(
            LuxuryHotelDetailScreen(hotel: state.extra as LuxuryHotelModel)),
      ),

      // — Villa flow (no bottom nav)
      GoRoute(
        path: RouteNames.villaSearch,
        pageBuilder: (_, __) => _slideLeftPage(const VillaSearchScreen()),
      ),
      GoRoute(
        path: RouteNames.villaDetail,
        pageBuilder: (_, state) =>
            _slideLeftPage(VillaDetailScreen(rate: state.extra as VillaRateModel)),
      ),

      // — A-ROSA cruise results (no bottom nav)
      GoRoute(
        path: RouteNames.arosaResults,
        pageBuilder: (_, __) => _slideLeftPage(const ArosaResultsScreen()),
      ),

      // — Insurance wizard
      GoRoute(
        path: RouteNames.insurance,
        pageBuilder: (_, __) => _slideLeftPage(const InsuranceWizardScreen()),
      ),
      GoRoute(
        path: RouteNames.insuranceConfirmation,
        pageBuilder: (_, __) =>
            _slideLeftPage(const InsuranceConfirmationScreen()),
      ),

      // — Visa wizard
      GoRoute(
        path: RouteNames.visa,
        pageBuilder: (_, __) => _slideLeftPage(const VisaWizardScreen()),
      ),
      GoRoute(
        path: RouteNames.visaConfirmation,
        pageBuilder: (_, __) =>
            _slideLeftPage(const VisaConfirmationScreen()),
      ),

      // — Secondary module screens (available from home IconRow)
      GoRoute(
        path: RouteNames.news,
        pageBuilder: (_, __) => _fadeScalePage(const NewsScreen()),
        routes: [
          GoRoute(
            path: 'article',
            pageBuilder: (_, state) {
              final article = state.extra as Article?;
              if (article == null) return _slideLeftPage(const NewsScreen());
              return _slideLeftPage(NewsArticleDetailScreen(article: article));
            },
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.video,
        pageBuilder: (_, __) => _fadeScalePage(const VideoScreen()),
      ),
      GoRoute(
        path: RouteNames.campus,
        pageBuilder: (_, __) => _fadeScalePage(const CampusScreen()),
      ),
      GoRoute(
        path: RouteNames.ppp,
        pageBuilder: (_, __) => _fadeScalePage(const PPPScreen()),
      ),
      GoRoute(
        path: RouteNames.pppDetail,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          final item = state.extra as PppItem?;
          return _slideLeftPage(PPPDetailScreen(id: id, item: item));
        },
      ),
      GoRoute(
        path: RouteNames.pppDirectory,
        pageBuilder: (_, state) {
          final pppId = state.pathParameters['id']!;
          final boardName = state.extra as String?;
          return _slideLeftPage(
              PPPDirectoryScreen(pppId: pppId, boardName: boardName));
        },
      ),
      GoRoute(
        path: RouteNames.pppRegister,
        pageBuilder: (_, state) {
          final pppId = state.pathParameters['id']!;
          return _slideLeftPage(PPPRegisterScreen(pppId: pppId));
        },
      ),
      GoRoute(
        path: RouteNames.jobs,
        pageBuilder: (_, __) => _fadeScalePage(const JobsScreen()),
      ),

      // — Association sub-screens
      GoRoute(
        path: RouteNames.associationLogin,
        pageBuilder: (_, state) {
          final assoc = state.extra as AssociationModel;
          return _slideLeftPage(AssociationLoginScreen(assoc: assoc));
        },
      ),
      GoRoute(
        path: RouteNames.associationDashboard,
        pageBuilder: (_, state) {
          final assoc = state.extra as AssociationModel;
          return _slideLeftPage(AssociationDashboardScreen(assoc: assoc));
        },
      ),
      GoRoute(
        path: RouteNames.associationDeals,
        pageBuilder: (_, state) {
          final assoc = state.extra as AssociationModel;
          return _slideLeftPage(AssociationDealsScreen(assoc: assoc));
        },
      ),
      GoRoute(
        path: RouteNames.associationDealCreate,
        pageBuilder: (_, state) {
          final assoc = state.extra as AssociationModel;
          return _slideUpPage(AssociationDealCreateScreen(assoc: assoc));
        },
      ),
      GoRoute(
        path: RouteNames.associationDemandCreate,
        pageBuilder: (_, state) {
          final assoc = state.extra as AssociationModel;
          return _slideUpPage(AssociationDemandCreateScreen(assoc: assoc));
        },
      ),
      GoRoute(
        path: RouteNames.associationLastMinCreate,
        pageBuilder: (_, state) {
          final assoc = state.extra as AssociationModel;
          return _slideUpPage(AssociationDealCreateScreen(assoc: assoc));
        },
      ),
      GoRoute(
        path: RouteNames.associationCirculars,
        pageBuilder: (_, state) {
          final assoc = state.extra as AssociationModel;
          return _slideLeftPage(AssociationCircularsScreen(assoc: assoc));
        },
      ),
      GoRoute(
        path: RouteNames.associationUpdates,
        pageBuilder: (_, state) {
          final assoc = state.extra as AssociationModel;
          return _slideLeftPage(AssociationUpdatesScreen(assoc: assoc));
        },
      ),
      GoRoute(
        path: RouteNames.associationDirectory,
        pageBuilder: (_, state) {
          final assoc = state.extra as AssociationModel;
          return _slideLeftPage(AssociationDirectoryScreen(assoc: assoc));
        },
      ),
      GoRoute(
        path: RouteNames.associationJobs,
        pageBuilder: (_, state) {
          final assoc = state.extra as AssociationModel;
          return _slideLeftPage(AssociationJobsScreen(assoc: assoc));
        },
      ),
      GoRoute(
        path: RouteNames.associationJobCreate,
        pageBuilder: (_, state) {
          final assoc = state.extra as AssociationModel;
          return _slideLeftPage(AssociationJobCreateScreen(assoc: assoc));
        },
      ),
      GoRoute(
        path: RouteNames.associationJobApplicants,
        pageBuilder: (_, state) {
          final job = state.extra as AssociationJobModel;
          return _slideLeftPage(AssociationJobApplicantsScreen(
            assocId: state.pathParameters['id']!,
            job: job,
          ));
        },
      ),
      GoRoute(
        path: RouteNames.associationChat,
        pageBuilder: (_, state) {
          final assoc = state.extra as AssociationModel;
          return _slideLeftPage(AssociationChatScreen(assoc: assoc));
        },
      ),
      GoRoute(
        path: RouteNames.associationChatThread,
        pageBuilder: (_, state) {
          final chat = state.extra as AssociationChatModel;
          return _slideLeftPage(AssociationChatThreadScreen(chat: chat));
        },
      ),
      GoRoute(
        path: RouteNames.associationCabs,
        pageBuilder: (_, state) {
          final assoc = state.extra as AssociationModel;
          return _slideLeftPage(AssociationCabsScreen(assoc: assoc));
        },
      ),
      GoRoute(
        path: RouteNames.associationAdminCabs,
        pageBuilder: (_, state) {
          final assoc = state.extra as AssociationModel;
          return _slideLeftPage(AssociationAdminCabScreen(assoc: assoc));
        },
      ),
      GoRoute(
        path: RouteNames.associationCabUpload,
        pageBuilder: (_, state) {
          final assoc = state.extra as AssociationModel;
          return _slideUpPage(AssociationCabUploadScreen(assoc: assoc));
        },
      ),
      GoRoute(
        path: RouteNames.dmcRegister,
        pageBuilder: (_, __) => _slideUpPage(const AssociationDmcRegisterScreen()),
      ),

      // — Campus sub-screens
      GoRoute(
        path: RouteNames.advisoryBoard,
        pageBuilder: (_, __) => _slideLeftPage(const AdvisoryBoardScreen()),
      ),
      GoRoute(
        path: RouteNames.destinationSpecialist,
        pageBuilder: (_, __) =>
            _slideLeftPage(const DestinationSpecialistScreen()),
      ),
      GoRoute(
        path: '/destination-specialist/:catId',
        pageBuilder: (_, state) {
          final catId = state.pathParameters['catId']!;
          final catLabel = state.extra as String? ?? catId;
          return _slideLeftPage(
              DestSubCategoryScreen(catId: catId, catLabel: catLabel));
        },
      ),
      GoRoute(
        path: '/destination-specialist/:catId/:subCatId',
        pageBuilder: (_, state) {
          final catId = state.pathParameters['catId']!;
          final subCatId = state.pathParameters['subCatId']!;
          return _slideLeftPage(
              DestSubSubCategoryScreen(catId: catId, subCatId: subCatId));
        },
      ),
      GoRoute(
        path: '/destination-specialist/:catId/:subCatId/:subSubCatId',
        pageBuilder: (_, state) {
          final catId = state.pathParameters['catId']!;
          final subCatId = state.pathParameters['subCatId']!;
          final subSubCatId = state.pathParameters['subSubCatId']!;
          return _slideLeftPage(DestVideoScreen(
              catId: catId, subCatId: subCatId, subSubCatId: subSubCatId));
        },
      ),
      GoRoute(
        path: RouteNames.skillDevelopment,
        pageBuilder: (_, __) =>
            _slideLeftPage(const SkillDevelopmentScreen()),
      ),
      GoRoute(
        path: '/skill-development/:catId',
        pageBuilder: (context, state) {
          final catId = state.pathParameters['catId']!;
          final catLabel = state.extra as String?;
          return _slideLeftPage(
              CourseListScreen(catId: catId, catLabel: catLabel));
        },
      ),

      // — Main shell (5-tab bottom nav)
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
              path: RouteNames.marketplace,
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: MarketplaceScreen()),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.associations,
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: AssociationsScreen()),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.services,
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: ServicesScreen()),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.account,
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: ProfileScreen()),
            ),
          ]),
        ],
      ),
    ],
  );
});

// ── Shell scaffold with 5-tab bottom nav ─────────────────────────────────────

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
                icon: Icons.shopping_cart_outlined,
                activeIcon: Icons.shopping_cart_rounded,
                label: 'Market',
                isActive: navigationShell.currentIndex == 1,
                onTap: () => navigationShell.goBranch(1,
                    initialLocation: navigationShell.currentIndex == 1),
                colors: colors,
              ),
              _NavItem(
                icon: Icons.people_outline_rounded,
                activeIcon: Icons.people_rounded,
                label: 'Assoc.',
                isActive: navigationShell.currentIndex == 2,
                onTap: () => navigationShell.goBranch(2,
                    initialLocation: navigationShell.currentIndex == 2),
                colors: colors,
              ),
              _NavItem(
                icon: Icons.desktop_mac_outlined,
                activeIcon: Icons.desktop_mac,
                label: 'Services',
                isActive: navigationShell.currentIndex == 3,
                onTap: () => navigationShell.goBranch(3,
                    initialLocation: navigationShell.currentIndex == 3),
                colors: colors,
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Account',
                isActive: navigationShell.currentIndex == 4,
                onTap: () => navigationShell.goBranch(4,
                    initialLocation: navigationShell.currentIndex == 4),
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
