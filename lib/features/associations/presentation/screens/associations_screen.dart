import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/association_model.dart';
import '../providers/associations_providers.dart';

class AssociationsScreen extends ConsumerStatefulWidget {
  const AssociationsScreen({super.key});

  @override
  ConsumerState<AssociationsScreen> createState() => _AssociationsScreenState();
}

class _AssociationsScreenState extends ConsumerState<AssociationsScreen> {
  int _activeFilter = 0;
  final Set<String> _signedIn = {};

  static const _filters = ['National', 'Regional', 'International', 'DMC'];

  List<AssociationModel> _applyFilter(List<AssociationModel> all) {
    final key = _filters[_activeFilter];
    return all.where((a) => a.atype == key).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final topPad = MediaQuery.paddingOf(context).top;
    final assocAsync = ref.watch(associationsProvider);

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: Stack(
        children: [
          assocAsync.when(
            loading: () => _LoadingList(topPad: topPad, colors: colors),
            error: (_, __) => _ErrorBody(
              topPad: topPad,
              colors: colors,
              onRetry: () => ref.invalidate(associationsProvider),
            ),
            data: (all) {
              final visible = _applyFilter(all);
              return ListView(
                padding: EdgeInsets.fromLTRB(0, topPad + 72, 0, 24),
                children: [
                  _FilterPills(
                    filters: _filters,
                    active: _activeFilter,
                    colors: colors,
                    onSelect: (i) => setState(() => _activeFilter = i),
                  ),
                  const SizedBox(height: 8),
                  if (visible.isEmpty)
                    _EmptyState(colors: colors, filter: _filters[_activeFilter])
                  else
                    ...visible.asMap().entries.map((e) {
                      final assoc = e.value;
                      return _AssocRow(
                        assoc: assoc,
                        isSignedIn: _signedIn.contains(assoc.id),
                        colors: colors,
                        onToggle: () => setState(() {
                          if (_signedIn.contains(assoc.id)) {
                            _signedIn.remove(assoc.id);
                          } else {
                            _signedIn.add(assoc.id);
                          }
                        }),
                        isLast: e.key == visible.length - 1,
                      );
                    }),
                ],
              );
            },
          ),

          // App bar overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _SubAppBar(
              colors: colors,
              topPad: topPad,
              title: 'Associations',
              action: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.surfaceCard,
                  border: Border.all(color: colors.lineSoft),
                ),
                child: Icon(Icons.search_rounded, size: 18, color: colors.ink900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Loading skeleton ──────────────────────────────────────────────────────────

class _LoadingList extends StatelessWidget {
  const _LoadingList({required this.topPad, required this.colors});
  final double topPad;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20, topPad + 80, 20, 24),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Container(
        height: 68,
        decoration: BoxDecoration(
          color: colors.surfaceTertiary,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.topPad,
    required this.colors,
    required this.onRetry,
  });
  final double topPad;
  final AppColorScheme colors;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, topPad + 80, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48, color: colors.ink400),
            const SizedBox(height: 12),
            Text(
              'Could not load associations',
              style: AppTypography.body.copyWith(color: colors.ink600),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onRetry,
              child: Text(
                'Retry',
                style: AppTypography.label.copyWith(
                  color: colors.goldPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty filter result ───────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colors, required this.filter});
  final AppColorScheme colors;
  final String filter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: Text(
          'No $filter associations found',
          style: AppTypography.body.copyWith(color: colors.ink600),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ── Sub app bar ───────────────────────────────────────────────────────────────

class _SubAppBar extends StatelessWidget {
  const _SubAppBar({
    required this.colors,
    required this.topPad,
    required this.title,
    this.action,
  });
  final AppColorScheme colors;
  final double topPad;
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colors.surfacePrimary,
      padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTypography.displayMd.copyWith(
                color: colors.ink900,
                fontSize: 22,
              ),
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

// ── Filter pills ──────────────────────────────────────────────────────────────

class _FilterPills extends StatelessWidget {
  const _FilterPills({
    required this.filters,
    required this.active,
    required this.colors,
    required this.onSelect,
  });
  final List<String> filters;
  final int active;
  final AppColorScheme colors;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final isActive = i == active;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? colors.ink900 : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isActive ? colors.ink900 : colors.lineSoft,
                ),
              ),
              child: Text(
                filters[i],
                style: AppTypography.body.copyWith(
                  color: isActive ? colors.surfacePrimary : colors.ink600,
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Association row ───────────────────────────────────────────────────────────

class _AssocRow extends StatelessWidget {
  const _AssocRow({
    required this.assoc,
    required this.isSignedIn,
    required this.colors,
    required this.onToggle,
    required this.isLast,
  });
  final AssociationModel assoc;
  final bool isSignedIn;
  final AppColorScheme colors;
  final VoidCallback onToggle;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: colors.lineSoft)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // Logo tile
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colors.surfaceCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.lineSoft),
            ),
            clipBehavior: Clip.antiAlias,
            child: assoc.logoUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: assoc.logoUrl,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) => _LogoFallback(
                      abbr: assoc.name,
                      colors: colors,
                    ),
                    placeholder: (_, __) => Container(color: colors.surfaceTertiary),
                  )
                : _LogoFallback(abbr: assoc.name, colors: colors),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assoc.name,
                  style: AppTypography.body.copyWith(
                    color: colors.ink900,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  assoc.atype,
                  style: AppTypography.caption.copyWith(
                    color: colors.ink600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Toggle button
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSignedIn
                    ? colors.error.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isSignedIn ? colors.error : colors.lineSoft,
                ),
              ),
              child: Text(
                isSignedIn ? 'Sign Out' : 'Sign In',
                style: AppTypography.label.copyWith(
                  color: isSignedIn ? colors.error : colors.ink900,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoFallback extends StatelessWidget {
  const _LogoFallback({required this.abbr, required this.colors});
  final String abbr;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        abbr.length > 5 ? abbr.substring(0, 5) : abbr,
        style: AppTypography.displayMd.copyWith(
          color: colors.ink900,
          fontSize: abbr.length > 4 ? 8 : 10,
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
