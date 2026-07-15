import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../associations/presentation/providers/associations_providers.dart';
import '../../../discover/data/models/deal_model.dart';
import '../../data/models/luxury_hotel_model.dart';
import '../providers/marketplace_providers.dart';
import '../widgets/association_gate.dart';
import '../widgets/cruise_section.dart';
import '../widgets/tailor_made_tab.dart';
import '../widgets/train_form.dart'; // also exports CabForm, FlightForm

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  int _activeFilter = 0;
  int _packageSubTab = 0; // 0=All, 1=My Packages, 2=Tailor Made

  static const _filters = [
    'Package',
    'Hotel',
    'Villa',
    'Cruise',
    'Cabs',
    'Trains',
    'Flights',
  ];

  static const _packageSubTabs = ['All Packages', 'My Packages', 'Tailor Made'];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: topPad + 72),
              // Filter pills
              _FilterPills(
                filters: _filters,
                active: _activeFilter,
                colors: colors,
                onSelect: (i) => setState(() {
                  _activeFilter = i;
                  _packageSubTab = 0;
                }),
              ),
              const SizedBox(height: 12),
              Expanded(child: _buildContent(colors: colors)),
            ],
          ),

          // App bar overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _SubAppBar(
              colors: colors,
              topPad: topPad,
              title: 'Marketplace',
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

          // Post Deal — Package tab, only when signed in to an association
          // (posting requires an association session; Tailor Made has its own FAB)
          if (_activeFilter == 0 &&
              _packageSubTab != 2 &&
              ref.watch(marketplaceSessionProvider) != null)
            Positioned(
              bottom: 16,
              right: 20,
              child: _PostDealFab(colors: colors, onTap: _openPostDeal),
            ),
        ],
      ),
    );
  }

  /// Opens the association module's deal-create screen for the signed-in
  /// association (posting a deal always belongs to an association).
  void _openPostDeal() {
    final session = ref.read(marketplaceSessionProvider);
    if (session == null) return;
    final assocs = ref.read(associationsProvider).valueOrNull ?? [];
    for (final assoc in assocs) {
      if (assoc.id == session.associationId) {
        context.push(
          RouteNames.associationDealCreate.replaceFirst(':id', assoc.id),
          extra: assoc,
        );
        return;
      }
    }
    // Association list not loaded yet — fall back to the Associations tab.
    context.go(RouteNames.associations);
  }

  Widget _buildContent({required AppColorScheme colors}) {
    switch (_activeFilter) {
      case 0: // Package (3 sub-tabs)
        return _PackageTab(
          subTab: _packageSubTab,
          colors: colors,
          onSubTabChange: (i) => setState(() => _packageSubTab = i),
          subTabs: _packageSubTabs,
          ref: ref,
        );
      case 1: // Hotel
        final hotelsAsync = ref.watch(luxuryHotelsProvider);
        return _AsyncList<LuxuryHotelModel>(
          asyncValue: hotelsAsync,
          colors: colors,
          onRetry: () => ref.invalidate(luxuryHotelsProvider),
          builder: (hotels) => _hotelList(hotels, colors),
        );
      case 2: // Villa — full booking flow
        return _VillaEntryTab(colors: colors);
      case 3: // Cruise — static cards + A-ROSA
        return const CruiseSection();
      case 4: // Cabs — enquiry form
        return const CabForm();
      case 5: // Trains — coming soon (form exists but isn't working yet)
        return _ComingSoonTab(
          colors: colors,
          icon: Icons.train_rounded,
          label: 'Train bookings',
        );
      case 6: // Flights — coming soon (form exists but isn't working yet)
        return _ComingSoonTab(
          colors: colors,
          icon: Icons.flight_rounded,
          label: 'Flight bookings',
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Hotel list ──────────────────────────────────────────────────────────────

  Widget _hotelList(List<LuxuryHotelModel> hotels, AppColorScheme colors) {
    if (hotels.isEmpty) {
      return _EmptyState(colors: colors, label: 'No luxury hotels available');
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: hotels.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _LuxuryHotelCard(hotel: hotels[i], colors: colors),
      ),
    );
  }
}

// ── Package tab with 3 sub-tabs ───────────────────────────────────────────────

class _PackageTab extends ConsumerWidget {
  const _PackageTab({
    required this.subTab,
    required this.colors,
    required this.onSubTabChange,
    required this.subTabs,
    required this.ref,
  });

  final int subTab;
  final AppColorScheme colors;
  final ValueChanged<int> onSubTabChange;
  final List<String> subTabs;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef watchRef) {
    return Column(
      children: [
        // Sub-tab row
        Container(
          color: colors.surfaceCard,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: List.generate(subTabs.length, (i) {
              final active = i == subTab;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSubTabChange(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: EdgeInsets.only(right: i < subTabs.length - 1 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? colors.ink900 : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: active ? colors.ink900 : colors.lineSoft,
                      ),
                    ),
                    child: Text(
                      subTabs[i],
                      textAlign: TextAlign.center,
                      style: AppTypography.caption.copyWith(
                        color: active ? colors.surfacePrimary : colors.ink600,
                        fontWeight:
                            active ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        // Sub-tab content
        Expanded(child: _packageContent(subTab, colors, watchRef)),
      ],
    );
  }

  Widget _packageContent(
      int sub, AppColorScheme colors, WidgetRef watchRef) {
    switch (sub) {
      case 0: // All Packages
        final dealsAsync = watchRef.watch(marketplaceDealsProvider);
        return _AsyncList<Deal>(
          asyncValue: dealsAsync,
          colors: colors,
          onRetry: () => watchRef.invalidate(marketplaceDealsProvider),
          builder: (deals) {
            if (deals.isEmpty) {
              return _EmptyState(
                  colors: colors, label: 'No packages available');
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              itemCount: deals.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DealCard(deal: deals[i], colors: colors),
              ),
            );
          },
        );
      case 1: // My Packages — association members only
        final myAsync = watchRef.watch(myPackagesProvider);
        return AssociationGate(
            child: _AsyncList<Deal>(
          asyncValue: myAsync,
          colors: colors,
          onRetry: () => watchRef.invalidate(myPackagesProvider),
          builder: (deals) {
            if (deals.isEmpty) {
              return _EmptyState(
                  colors: colors,
                  label: 'You have no packages yet');
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              itemCount: deals.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DealCard(deal: deals[i], colors: colors),
              ),
            );
          },
        ));
      case 2: // Tailor Made — association members only
        return const AssociationGate(child: TailorMadeTab());
      default:
        return const SizedBox.shrink();
    }
  }
}

// ── Villa entry tab ───────────────────────────────────────────────────────────

class _VillaEntryTab extends StatelessWidget {
  const _VillaEntryTab({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Luxury Villa Bookings',
            style: AppTypography.heading.copyWith(color: colors.ink900),
          ),
          const SizedBox(height: 4),
          Text(
            'Book premium villas for your clients — powered by Elivaas',
            style: AppTypography.body.copyWith(color: colors.ink400),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: colors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.lineSoft),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    height: 180,
                    color: colors.navyDeep,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.villa_rounded,
                              size: 56, color: Colors.white.withValues(alpha: 0.8)),
                          const SizedBox(height: 8),
                          Text(
                            'ELIVAAS VILLAS',
                            style: AppTypography.label.copyWith(
                              color: AppColors.goldPrimary,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Handpicked Luxury Villas',
                        style: AppTypography.heading
                            .copyWith(color: colors.ink900),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Search from hundreds of premium villa properties across India and abroad. '
                        'Filter by city, dates, and guests — then book directly with Razorpay.',
                        style:
                            AppTypography.body.copyWith(color: colors.ink600),
                      ),
                      const SizedBox(height: 20),
                      _FeatureRow(
                          icon: Icons.search_rounded,
                          label: 'Real-time availability',
                          colors: colors),
                      const SizedBox(height: 8),
                      _FeatureRow(
                          icon: Icons.verified_rounded,
                          label: 'Verified properties',
                          colors: colors),
                      const SizedBox(height: 8),
                      _FeatureRow(
                          icon: Icons.payment_rounded,
                          label: 'Secure Razorpay payment',
                          colors: colors),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => context.push(RouteNames.villaSearch),
                        icon: const Icon(Icons.search_rounded, size: 18),
                        label: const Text('Search Villas'),
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.goldPrimary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow(
      {required this.icon, required this.label, required this.colors});
  final IconData icon;
  final String label;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.success),
        const SizedBox(width: 8),
        Text(label, style: AppTypography.body.copyWith(color: colors.ink600)),
      ],
    );
  }
}

// ── Generic async list wrapper ────────────────────────────────────────────────

class _AsyncList<T> extends StatelessWidget {
  const _AsyncList({
    required this.asyncValue,
    required this.colors,
    required this.onRetry,
    required this.builder,
  });
  final AsyncValue<List<T>> asyncValue;
  final AppColorScheme colors;
  final VoidCallback onRetry;
  final Widget Function(List<T>) builder;

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      loading: () => _LoadingSkeleton(colors: colors),
      error: (_, __) => _ErrorState(colors: colors, onRetry: onRetry),
      data: builder,
    );
  }
}

// ── Loading skeleton ──────────────────────────────────────────────────────────

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Container(
        height: 220,
        decoration: BoxDecoration(
          color: colors.surfaceTertiary,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.colors, required this.onRetry});
  final AppColorScheme colors;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, size: 48, color: colors.ink400),
          const SizedBox(height: 12),
          Text('Could not load data',
              style: AppTypography.body.copyWith(color: colors.ink600)),
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
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

// ── Coming soon (Trains / Flights) ───────────────────────────────────────────

class _ComingSoonTab extends StatelessWidget {
  const _ComingSoonTab({
    required this.colors,
    required this.icon,
    required this.label,
  });
  final AppColorScheme colors;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surfaceCard,
                border: Border.all(color: colors.lineSoft),
              ),
              child: Icon(icon, size: 32, color: colors.ink400),
            ),
            const SizedBox(height: 20),
            Text(
              'Coming Soon',
              style: AppTypography.heading.copyWith(color: colors.ink900),
            ),
            const SizedBox(height: 8),
            Text(
              '$label are on their way. Stay tuned!',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: colors.ink600),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colors, required this.label});
  final AppColorScheme colors;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(label,
          style: AppTypography.body.copyWith(color: colors.ink600)),
    );
  }
}

// ── Deal card (Package) ───────────────────────────────────────────────────────

class _DealCard extends StatelessWidget {
  const _DealCard({required this.deal, required this.colors});
  final Deal deal;
  final AppColorScheme colors;

  int get _stars {
    final match = RegExp(r'\d').firstMatch(deal.hotelCategory ?? '');
    if (match == null) return 0;
    return (int.tryParse(match.group(0)!) ?? 0).clamp(0, 5);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RouteNames.dealDetail, extra: deal),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.lineSoft),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  deal.firstImage.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: deal.firstImage,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: colors.surfaceTertiary),
                          errorWidget: (_, __, ___) => const _NavyFallback(),
                        )
                      : const _NavyFallback(),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x22000000), Color(0xBB000000)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Text(
                      (deal.destination ?? deal.dealName).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: 0.6,
                        shadows: [
                          Shadow(color: Color(0x80000000), blurRadius: 8)
                        ],
                      ),
                    ),
                  ),
                  if (_stars > 0)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < _stars
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 14,
                            color: AppColors.goldPrimary,
                          ),
                        ),
                      ),
                    ),
                  if (deal.duration != null)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Text(
                        deal.duration!.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          shadows: [
                            Shadow(color: Color(0x80000000), blurRadius: 4)
                          ],
                        ),
                      ),
                    ),
                  if (deal.priceForSame != null && deal.priceForSame!.isNotEmpty)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '₹${deal.priceForSame}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      deal.dealName,
                      style: AppTypography.caption.copyWith(
                        color: colors.ink600,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    'View Deal →',
                    style: AppTypography.label.copyWith(
                      color: colors.goldPrimary,
                      fontSize: 12,
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

// ── Luxury hotel card ─────────────────────────────────────────────────────────

class _LuxuryHotelCard extends StatelessWidget {
  const _LuxuryHotelCard({required this.hotel, required this.colors});
  final LuxuryHotelModel hotel;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RouteNames.hotelDetail, extra: hotel),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.lineSoft),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  hotel.firstImage.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: hotel.firstImage,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: colors.surfaceTertiary),
                          errorWidget: (_, __, ___) => const _NavyFallback(),
                        )
                      : const _NavyFallback(),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xBB000000)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.navyDeep,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded,
                              size: 10, color: AppColors.goldPrimary),
                          const SizedBox(width: 4),
                          Text(
                            'LUXURY',
                            style: AppTypography.overline.copyWith(
                              color: AppColors.goldPrimary,
                              fontSize: 9,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Text(
                      hotel.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        shadows: [
                          Shadow(color: Color(0x80000000), blurRadius: 8)
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 13, color: colors.ink400),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hotel.location,
                          style: AppTypography.caption.copyWith(
                            color: colors.ink600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (hotel.title.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      hotel.title,
                      style: AppTypography.caption.copyWith(
                        color: colors.ink600,
                        fontSize: 11,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (hotel.amenities.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: hotel.amenities
                          .take(4)
                          .map((a) => _AmenityChip(label: a, colors: colors))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'View Hotel →',
                        style: AppTypography.label.copyWith(
                          color: colors.goldPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
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

// ── Amenity chip ──────────────────────────────────────────────────────────────

class _AmenityChip extends StatelessWidget {
  const _AmenityChip({required this.label, required this.colors});
  final String label;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfacePrimary,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.lineSoft),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(color: colors.ink600, fontSize: 10),
      ),
    );
  }
}

// ── Navy fallback image ───────────────────────────────────────────────────────

class _NavyFallback extends StatelessWidget {
  const _NavyFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.navyDeep, Color(0xFF1A3550)],
        ),
      ),
    );
  }
}

// ── Post deal FAB ─────────────────────────────────────────────────────────────

class _PostDealFab extends StatelessWidget {
  const _PostDealFab({required this.colors, required this.onTap});
  final AppColorScheme colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        decoration: BoxDecoration(
          color: colors.goldPrimary,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFC9A84C).withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, size: 16, color: AppColors.navyDeep),
            const SizedBox(width: 6),
            Text(
              'Post Deal',
              style: AppTypography.label.copyWith(
                color: AppColors.navyDeep,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
