import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../core/router/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../data/models/association_deal_model.dart';
import '../../data/models/association_model.dart';
import '../providers/association_content_providers.dart';

const _categories = ['Packages', 'Hotels', 'Transport', 'Flights'];
const _categoryKeys = ['Package', 'Hotel', 'Transport', 'Flight'];

class AssociationDealsScreen extends ConsumerStatefulWidget {
  const AssociationDealsScreen({super.key, required this.assoc});
  final AssociationModel assoc;

  @override
  ConsumerState<AssociationDealsScreen> createState() =>
      _AssociationDealsScreenState();
}

class _AssociationDealsScreenState
    extends ConsumerState<AssociationDealsScreen> {
  int _segment = 0; // 0=Buying, 1=Selling, 2=Last Min.
  int _catIndex = 0;
  bool _myPostsOnly = false;

  String get _catKey => _categoryKeys[_catIndex];

  String _sub(String route) => route.replaceFirst(':id', widget.assoc.id);

  String get _fabLabel => switch (_segment) {
        0 => 'Post Demand',
        2 => 'Post Last Min.',
        _ => 'Create Offer',
      };

  void _onFab() {
    if (_segment == 0) {
      context.push(_sub(RouteNames.associationDemandCreate), extra: widget.assoc);
    } else if (_segment == 2) {
      context.push(_sub(RouteNames.associationLastMinCreate), extra: widget.assoc);
    } else {
      context.push(_sub(RouteNames.associationDealCreate), extra: widget.assoc);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topPad + 64)),

              // ── Segment control ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: _Segment(
                  selected: _segment,
                  colors: colors,
                  onSelect: (i) => setState(() {
                    _segment = i;
                    _myPostsOnly = false;
                  }),
                ),
              ),

              // ── Category pills (hidden for Last Min.) ───────────────────
              if (_segment != 2) ...[
                SliverToBoxAdapter(
                  child: _CategoryPills(
                    selected: _catIndex,
                    colors: colors,
                    onSelect: (i) => setState(() => _catIndex = i),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ] else
                const SliverToBoxAdapter(child: SizedBox(height: 6)),

              // ── My-posts indicator (Selling only) ───────────────────────
              if (_segment == 1 && _myPostsOnly)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: Row(
                      children: [
                        Icon(Icons.bookmark, size: 14, color: colors.ink900),
                        const SizedBox(width: 6),
                        RichText(
                          text: TextSpan(
                            style: AppTypography.caption.copyWith(color: colors.ink600, fontSize: 11),
                            children: [
                              const TextSpan(text: 'Showing '),
                              TextSpan(
                                text: 'My Offers',
                                style: TextStyle(color: colors.ink900, fontWeight: FontWeight.w600),
                              ),
                              const TextSpan(text: ' only'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Search bar (Selling only) ────────────────────────────────
              if (_segment == 1)
                SliverToBoxAdapter(child: _SearchBar(colors: colors)),

              // ── Feed ────────────────────────────────────────────────────
              if (_segment == 0)
                _BuyingFeed(assoc: widget.assoc, catKey: _catKey, colors: colors),
              if (_segment == 1)
                _SellingFeed(
                  assoc: widget.assoc,
                  catKey: _catKey,
                  myOnly: _myPostsOnly,
                  colors: colors,
                ),
              if (_segment == 2)
                _LastMinFeed(assoc: widget.assoc, colors: colors),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          // ── App bar ─────────────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              color: colors.surfacePrimary,
              padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.surfaceCard,
                        border: Border.all(color: colors.lineSoft),
                      ),
                      child: Icon(Icons.arrow_back, size: 18, color: colors.ink900),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Network Deals',
                      style: AppTypography.displayMd.copyWith(
                        color: colors.ink900,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _AppBarIcon(
                    icon: Icons.search_rounded,
                    colors: colors,
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                  _AppBarIcon(
                    icon: _myPostsOnly ? Icons.bookmark : Icons.bookmark_border,
                    colors: colors,
                    active: _myPostsOnly,
                    onTap: () => setState(() => _myPostsOnly = !_myPostsOnly),
                  ),
                ],
              ),
            ),
          ),

          // ── FAB ─────────────────────────────────────────────────────────
          Positioned(
            bottom: 24, right: 20,
            child: GestureDetector(
              onTap: _onFab,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                decoration: BoxDecoration(
                  color: colors.goldPrimary,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: colors.goldPrimary.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 14, color: colors.ink900),
                    const SizedBox(width: 6),
                    Text(
                      _fabLabel,
                      style: AppTypography.label.copyWith(
                        color: colors.ink900,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Segment control ───────────────────────────────────────────────────────────

class _Segment extends StatelessWidget {
  const _Segment({required this.selected, required this.colors, required this.onSelect});
  final int selected;
  final AppColorScheme colors;
  final ValueChanged<int> onSelect;

  static const _labels = ['Buying', 'Selling', 'Last Min.'];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceTertiary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(3, (i) {
          final active = i == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? colors.surfaceCard : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: active
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 6)]
                      : null,
                ),
                child: Text(
                  _labels[i],
                  style: AppTypography.label.copyWith(
                    color: active ? colors.ink900 : colors.ink600,
                    fontSize: 12,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    height: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Category pills ────────────────────────────────────────────────────────────

class _CategoryPills extends StatelessWidget {
  const _CategoryPills({required this.selected, required this.colors, required this.onSelect});
  final int selected;
  final AppColorScheme colors;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(_categories.length, (i) {
          final active = i == selected;
          return Padding(
            padding: EdgeInsets.only(right: i < _categories.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? colors.ink900 : colors.surfaceCard,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: active ? colors.ink900 : colors.lineSoft,
                  ),
                ),
                child: Text(
                  _categories[i],
                  style: AppTypography.label.copyWith(
                    color: active ? colors.surfacePrimary : colors.ink600,
                    fontSize: 12,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.lineSoft),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 18, color: colors.ink400),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              style: AppTypography.body.copyWith(color: colors.ink900, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search destination, title…',
                hintStyle: AppTypography.body.copyWith(color: colors.ink400, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Buying (demands) feed ─────────────────────────────────────────────────────

class _BuyingFeed extends ConsumerWidget {
  const _BuyingFeed({required this.assoc, required this.catKey, required this.colors});
  final AssociationModel assoc;
  final String catKey;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(associationDemandsProvider(
      (assocId: assoc.id, segment: 'buying', category: catKey),
    ));
    return async.when(
      loading: () => SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, __) => _ShimmerCard(colors: colors),
          childCount: 3,
        ),
      ),
      error: (_, __) => SliverToBoxAdapter(
        child: _ErrorState(colors: colors, onRetry: () => ref.invalidate(associationDemandsProvider)),
      ),
      data: (items) => items.isEmpty
          ? SliverToBoxAdapter(child: _EmptyState(colors: colors, label: 'No demands posted yet'))
          : SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _DemandCard(demand: items[i], colors: colors),
                childCount: items.length,
              ),
            ),
    );
  }
}

// ── Selling (offers) feed ─────────────────────────────────────────────────────

class _SellingFeed extends ConsumerWidget {
  const _SellingFeed({
    required this.assoc,
    required this.catKey,
    required this.myOnly,
    required this.colors,
  });
  final AssociationModel assoc;
  final String catKey;
  final bool myOnly;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(associationOffersProvider(
      (assocId: assoc.id, segment: 'selling', category: catKey),
    ));
    return async.when(
      loading: () => SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, __) => _ShimmerDealCard(colors: colors),
          childCount: 2,
        ),
      ),
      error: (_, __) => SliverToBoxAdapter(
        child: _ErrorState(colors: colors, onRetry: () => ref.invalidate(associationOffersProvider)),
      ),
      data: (items) {
        final filtered = myOnly ? items.where((d) => d.isFavourite).toList() : items;
        return filtered.isEmpty
            ? SliverToBoxAdapter(child: _EmptyState(colors: colors, label: 'No offers posted yet'))
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _DealCard(deal: filtered[i], colors: colors),
                  childCount: filtered.length,
                ),
              );
      },
    );
  }
}

// ── Last-min feed ─────────────────────────────────────────────────────────────

class _LastMinFeed extends ConsumerWidget {
  const _LastMinFeed({required this.assoc, required this.colors});
  final AssociationModel assoc;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(associationLastMinProvider(assoc.id));
    return async.when(
      loading: () => SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, __) => _ShimmerCard(colors: colors),
          childCount: 3,
        ),
      ),
      error: (_, __) => SliverToBoxAdapter(
        child: _ErrorState(colors: colors, onRetry: () => ref.invalidate(associationLastMinProvider)),
      ),
      data: (items) => items.isEmpty
          ? SliverToBoxAdapter(child: _EmptyState(colors: colors, label: 'No last-minute deals'))
          : SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _LastMinCard(item: items[i], colors: colors),
                childCount: items.length,
              ),
            ),
    );
  }
}

// ── Deal card (Selling — image hero + info body) ──────────────────────────────

class _DealCard extends StatelessWidget {
  const _DealCard({required this.deal, required this.colors});
  final AssociationDealModel deal;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final displayName = deal.title.isNotEmpty ? deal.title : deal.destination;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.lineSoft),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Image hero ─────────────────────────────────────────────────
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                deal.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: deal.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: colors.surfaceTertiary),
                        errorWidget: (_, __, ___) => _ImgPlaceholder(colors: colors),
                      )
                    : _ImgPlaceholder(colors: colors),
                // gradient
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)],
                      stops: const [0.45, 1.0],
                    ),
                  ),
                ),
                // destination — plain bold text top-left (per spec)
                if (deal.destination.isNotEmpty)
                  Positioned(
                    top: 12, left: 14,
                    child: Text(
                      deal.destination.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: 0.78, // 0.06em @ 13px
                      ),
                    ),
                  ),
                // stars top-right (parsed from hotelCategory)
                if (_starCount(deal.hotelCategory) > 0)
                  Positioned(
                    top: 12, right: 14,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        _starCount(deal.hotelCategory),
                        (_) => const Icon(Icons.star, size: 12, color: Color(0xFFE8D08A)),
                      ),
                    ),
                  ),
                // nights/price overlay bottom
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (deal.nights != null)
                          Text(
                            '${deal.nights} NIGHTS, ${deal.nights! + 1} DAYS',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        if (deal.price > 0)
                          Text(
                            '₹${_fmt(deal.price)}',
                            style: TextStyle(
                              color: colors.goldAccent,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Card body ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + category badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: AppTypography.body.copyWith(
                          color: colors.ink900,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: colors.surfaceTertiary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        deal.category,
                        style: AppTypography.caption.copyWith(
                          color: colors.ink600,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                // Hotel category (stars / category label)
                if (deal.hotelCategory != null && deal.hotelCategory!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    deal.hotelCategory!,
                    style: AppTypography.caption.copyWith(
                      color: colors.goldPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                // Nights + price row
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (deal.nights != null) ...[
                      Icon(Icons.nights_stay_outlined, size: 13, color: colors.ink400),
                      const SizedBox(width: 4),
                      Text(
                        '${deal.nights}N / ${deal.nights! + 1}D',
                        style: AppTypography.caption.copyWith(
                          color: colors.ink600, fontSize: 11,
                        ),
                      ),
                      if (deal.price > 0) const SizedBox(width: 12),
                    ],
                    if (deal.price > 0)
                      Text(
                        '₹${_fmt(deal.price)}',
                        style: AppTypography.label.copyWith(
                          color: colors.goldPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),

                // Posted-by footer
                if (deal.postedBy != null && deal.postedBy!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Divider(color: colors.lineSoft, height: 1),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 13, color: colors.ink400),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          deal.postedBy!,
                          style: AppTypography.caption.copyWith(
                            color: colors.ink400, fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'Contact →',
                        style: AppTypography.label.copyWith(
                          color: colors.goldPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  int _starCount(String? hotelCategory) {
    if (hotelCategory == null) return 0;
    final m = RegExp(r'(\d)').firstMatch(hotelCategory);
    return m == null ? 0 : (int.tryParse(m.group(1)!) ?? 0).clamp(0, 5);
  }
}

// ── Demand card (Buying) ──────────────────────────────────────────────────────

class _DemandCard extends StatelessWidget {
  const _DemandCard({required this.demand, required this.colors});
  final AssociationDemandModel demand;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final dest = demand.destination.isNotEmpty ? demand.destination : 'Destination TBD';
    final budgetStr = demand.budgetMax > 0
        ? '₹${_fmt(demand.budgetMin)}–${_fmt(demand.budgetMax)}'
        : demand.budgetMin > 0
            ? '₹${_fmt(demand.budgetMin)}'
            : '';

    // Build inline detail string: "8 pax · 6N/7D · {description}"
    final parts = <String>[];
    if (demand.pax != null) parts.add('${demand.pax} pax');
    if (demand.nights != null) parts.add('${demand.nights}N/${demand.nights! + 1}D');
    if (demand.details != null && demand.details!.isNotEmpty) parts.add(demand.details!);
    final detailStr = parts.join(' · ');

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.lineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top: destination title + budget badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Need: $dest',
                  style: AppTypography.displayMd.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.ink900,
                    height: 1.3,
                  ),
                ),
              ),
              if (budgetStr.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    budgetStr,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      height: 1.0,
                      color: colors.success,
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Detail line
          if (detailStr.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              detailStr,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12,
                height: 1.5,
                color: Color(0xFF5E5E5E),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Footer
          const SizedBox(height: 10),
          Divider(color: colors.lineSoft, height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (demand.postedBy != null && demand.postedBy!.isNotEmpty)
                Text(
                  'Posted by ${demand.postedBy!}',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 11,
                    color: colors.ink400,
                  ),
                )
              else
                const SizedBox.shrink(),
              Text(
                'Respond →',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: colors.goldPrimary,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}

// ── Last-min card ─────────────────────────────────────────────────────────────

class _LastMinCard extends StatelessWidget {
  const _LastMinCard({required this.item, required this.colors});
  final AssociationLastMinModel item;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.error, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: colors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.timer_outlined, color: colors.error, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTypography.body.copyWith(
                    color: colors.ink900,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.expiresAt.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Expires: ${item.expiresAt}',
                    style: AppTypography.caption.copyWith(
                      color: colors.error,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (item.price > 0)
            Text(
              '₹${item.price.toStringAsFixed(0)}',
              style: AppTypography.body.copyWith(
                color: colors.ink900,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _AppBarIcon extends StatelessWidget {
  const _AppBarIcon({required this.icon, required this.colors, required this.onTap, this.active = false});
  final IconData icon;
  final AppColorScheme colors;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? colors.goldPrimary : colors.surfaceCard,
            border: Border.all(color: active ? colors.goldPrimary : colors.lineSoft),
          ),
          child: Icon(icon, size: 18, color: colors.ink900),
        ),
      );
}

class _ImgPlaceholder extends StatelessWidget {
  const _ImgPlaceholder({required this.colors});
  final AppColorScheme colors;
  @override
  Widget build(BuildContext context) => Container(
        color: colors.surfaceTertiary,
        child: Icon(Icons.image_outlined, color: colors.ink400, size: 40),
      );
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard({required this.colors});
  final AppColorScheme colors;
  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: colors.surfaceTertiary,
        highlightColor: colors.surfaceCard,
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          height: 80,
          decoration: BoxDecoration(
            color: colors.surfaceCard,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
}

class _ShimmerDealCard extends StatelessWidget {
  const _ShimmerDealCard({required this.colors});
  final AppColorScheme colors;
  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: colors.surfaceTertiary,
        highlightColor: colors.surfaceCard,
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          height: 260,
          decoration: BoxDecoration(
            color: colors.surfaceCard,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colors, required this.label});
  final AppColorScheme colors;
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(30, 48, 30, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(shape: BoxShape.circle, color: colors.surfaceTertiary),
              child: Icon(Icons.inbox_outlined, color: colors.ink400, size: 28),
            ),
            const SizedBox(height: 14),
            Text(label,
                style: AppTypography.body.copyWith(
                    color: colors.ink600, fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.colors, required this.onRetry});
  final AppColorScheme colors;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, color: colors.ink400, size: 40),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onRetry,
              child: Text('Retry',
                  style: AppTypography.label
                      .copyWith(color: colors.goldPrimary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
}
