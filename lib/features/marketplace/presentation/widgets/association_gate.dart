import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/marketplace_providers.dart';

/// Shows [child] only when the user is signed in to at least one association.
/// Otherwise shows a sign-in prompt that navigates to the Associations tab.
class AssociationGate extends ConsumerWidget {
  const AssociationGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(marketplaceSessionProvider);
    if (session != null) return child;

    final colors = Theme.of(context).extension<AppColorScheme>()!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surfaceCard,
                border: Border.all(color: colors.lineSoft),
              ),
              child: Icon(Icons.groups_rounded,
                  size: 32, color: colors.goldPrimary),
            ),
            const SizedBox(height: 20),
            Text(
              'Association Sign-In Required',
              textAlign: TextAlign.center,
              style: AppTypography.heading.copyWith(color: colors.ink900),
            ),
            const SizedBox(height: 8),
            Text(
              'You are not signed in with any association. This section is '
              'available to association members only — please sign in to '
              'one of your associations to continue.',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: colors.ink600),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go(RouteNames.associations),
              icon: const Icon(Icons.login_rounded, size: 18),
              label: const Text('Sign In to an Association'),
              style: FilledButton.styleFrom(
                backgroundColor: colors.goldPrimary,
                foregroundColor: AppColors.navyDeep,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
