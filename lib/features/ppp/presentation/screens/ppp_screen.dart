import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/ppp_model.dart';
import '../providers/ppp_providers.dart';

class PPPScreen extends ConsumerStatefulWidget {
  const PPPScreen({super.key});

  @override
  ConsumerState<PPPScreen> createState() => _PPPScreenState();
}

class _PPPScreenState extends ConsumerState<PPPScreen> {
  bool _showInternational = true;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final pppAsync = ref.watch(pppAllProvider);

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      appBar: AppBar(
        backgroundColor: colors.surfacePrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: colors.ink900,
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Tourism Boards',
          style: AppTypography.titleMedium.copyWith(color: colors.ink900),
        ),
      ),
      body: pppAsync.when(
        loading: () => const _PPPShimmer(),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to load tourism boards',
                  style: TextStyle(color: colors.ink600)),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.invalidate(pppAllProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (all) {
          final filtered = all.where((item) {
            final matchesType = _showInternational
                ? item.type == 'International'
                : item.type == 'National';
            final matchesQuery = _query.isEmpty ||
                item.name.toLowerCase().contains(_query.toLowerCase());
            return matchesType && matchesQuery;
          }).toList();

          return Column(
            children: [
              // Segmented control
              _SegmentedControl(
                showInternational: _showInternational,
                onToggle: (val) => setState(() => _showInternational = val),
                colors: colors,
              ),
              // Search bar
              _SearchBar(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                colors: colors,
              ),
              const SizedBox(height: 4),
              // Results
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No tourism boards found',
                          style: TextStyle(color: colors.ink400),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) =>
                            _PPPCard(item: filtered[i], colors: colors),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Segmented control ──────────────────────────────────────────────────────
class _SegmentedControl extends StatelessWidget {
  final bool showInternational;
  final ValueChanged<bool> onToggle;
  final AppColorScheme colors;

  const _SegmentedControl({
    required this.showInternational,
    required this.onToggle,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceTertiary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _SegBtn(
            label: 'International',
            active: showInternational,
            onTap: () => onToggle(true),
            colors: colors,
          ),
          _SegBtn(
            label: 'Domestic',
            active: !showInternational,
            onTap: () => onToggle(false),
            colors: colors,
          ),
        ],
      ),
    );
  }
}

class _SegBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final AppColorScheme colors;

  const _SegBtn({
    required this.label,
    required this.active,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? colors.surfacePrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
                ? [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4)
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    active ? FontWeight.w600 : FontWeight.w500,
                color: active ? colors.ink900 : colors.ink600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Search bar ─────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final AppColorScheme colors;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        border: Border.all(color: colors.lineSoft),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 18, color: colors.ink400),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(fontSize: 13, color: colors.ink900),
              decoration: InputDecoration.collapsed(
                hintText: 'Search tourism boards…',
                hintStyle:
                    TextStyle(fontSize: 13, color: colors.ink400),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tourism board card ─────────────────────────────────────────────────────
class _PPPCard extends StatelessWidget {
  final PppItem item;
  final AppColorScheme colors;

  const _PPPCard({required this.item, required this.colors});

  List<String> get _pills {
    final tags = <String>[];
    if (item.tourismpolicy.isNotEmpty) tags.add('Tourism Policy');
    if (item.investmentOpportunity.isNotEmpty) tags.add('Investment');
    if (tags.length < 3) tags.add('Resources');
    return tags.take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/ppp/${item.id}', extra: item),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: colors.surfaceSecondary,
          border: Border.all(color: colors.lineSoft),
          borderRadius: BorderRadius.circular(18),
        ),
        child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with tag
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 2.0,
                  child: item.firstImage.isNotEmpty
                      ? Image.network(
                          item.firstImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: colors.surfaceTertiary,
                          ),
                        )
                      : Container(color: colors.surfaceTertiary),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      item.isDomestic ? 'Domestic' : 'International',
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.04),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: colors.ink900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.isDomestic
                        ? 'Domestic tourism board. Discover local attractions and tourism initiatives.'
                        : 'International tourism board. World-class destinations and cultural experiences.',
                    style: TextStyle(
                        fontSize: 12,
                        color: colors.ink600,
                        height: 1.5),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _pills
                        .map((p) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: colors.themeBackground,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                p,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: colors.navyDeep),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Explore Board →',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.goldPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

// ── Shimmer loading skeleton ───────────────────────────────────────────────
class _PPPShimmer extends StatelessWidget {
  const _PPPShimmer();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: colors.surfaceTertiary,
        highlightColor: colors.surfaceSecondary,
        child: const _ShimmerCard(),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 2.0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 20, width: 180, color: Colors.white),
                const SizedBox(height: 8),
                Container(height: 12, color: Colors.white),
                const SizedBox(height: 4),
                Container(height: 12, width: 200, color: Colors.white),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      height: 24,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      height: 24,
                      width: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(height: 14, width: 100, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
