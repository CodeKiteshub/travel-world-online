import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/ppp_model.dart';
import '../providers/ppp_providers.dart';

class PPPDirectoryScreen extends ConsumerStatefulWidget {
  const PPPDirectoryScreen({
    super.key,
    required this.pppId,
    this.boardName,
  });

  final String pppId;
  final String? boardName;

  @override
  ConsumerState<PPPDirectoryScreen> createState() => _PPPDirectoryScreenState();
}

class _PPPDirectoryScreenState extends ConsumerState<PPPDirectoryScreen> {
  String _filter = 'All';
  String _search = '';

  static const _types = [
    'All',
    'Tour operator',
    'Travel Agent',
    'Hotel',
    'Service Provider',
    'Guide',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final async = ref.watch(pppDirectoryProvider(widget.pppId));

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      appBar: AppBar(
        backgroundColor: colors.surfacePrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.ink900),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.boardName != null
              ? '${widget.boardName} Directory'
              : 'Directory',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: colors.ink900,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _search = v.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search by name, company…',
                hintStyle: TextStyle(
                    fontFamily: 'DMSans', fontSize: 13, color: colors.ink400),
                prefixIcon: Icon(Icons.search, color: colors.ink400, size: 20),
                filled: true,
                fillColor: colors.surfaceSecondary,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(fontFamily: 'DMSans', color: colors.ink900),
            ),
          ),
          // Filter chips row
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _types.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final t = _types[i];
                final selected = _filter == t;
                return GestureDetector(
                  onTap: () => setState(() => _filter = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? colors.goldPrimary
                          : colors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: selected
                            ? colors.goldPrimary
                            : colors.lineSoft,
                      ),
                    ),
                    child: Text(
                      t,
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : colors.ink600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Results
          Expanded(
            child: async.when(
              loading: () => _DirectoryShimmer(colors: colors),
              error: (_, __) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Failed to load directory',
                        style: TextStyle(
                            fontFamily: 'DMSans', color: colors.ink600)),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () =>
                          ref.invalidate(pppDirectoryProvider(widget.pppId)),
                      child: Text('Retry',
                          style: TextStyle(
                              fontFamily: 'DMSans', color: colors.goldPrimary)),
                    ),
                  ],
                ),
              ),
              data: (all) {
                final filtered = all.where((s) {
                  final matchesType =
                      _filter == 'All' || s.type == _filter;
                  if (!matchesType) return false;
                  if (_search.isEmpty) return true;
                  return s.fullName.toLowerCase().contains(_search) ||
                      s.cname.toLowerCase().contains(_search) ||
                      s.email.toLowerCase().contains(_search);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      _search.isNotEmpty || _filter != 'All'
                          ? 'No results found'
                          : 'No stakeholders registered yet',
                      style: TextStyle(
                          fontFamily: 'DMSans', color: colors.ink600),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _StakeholderCard(
                    stakeholder: filtered[i],
                    colors: colors,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stakeholder list card ─────────────────────────────────────────────────────

class _StakeholderCard extends StatelessWidget {
  const _StakeholderCard({
    required this.stakeholder,
    required this.colors,
  });

  final PppStakeholder stakeholder;
  final AppColorScheme colors;

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surfacePrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _StakeholderDetailSheet(
          stakeholder: stakeholder, colors: colors),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imgUrl = stakeholder.firstImage;
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.lineSoft),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 26,
              backgroundColor: colors.surfaceTertiary,
              child: imgUrl.isNotEmpty
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: imgUrl,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Text(
                          stakeholder.initials,
                          style: TextStyle(
                              fontFamily: 'DMSans',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: colors.ink600),
                        ),
                      ),
                    )
                  : Text(
                      stakeholder.initials,
                      style: TextStyle(
                          fontFamily: 'DMSans',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: colors.ink600),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (stakeholder.cname.isNotEmpty)
                    Text(
                      stakeholder.cname,
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: colors.ink900,
                      ),
                    ),
                  Text(
                    stakeholder.fullName,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 12,
                      color: colors.ink600,
                    ),
                  ),
                  if (stakeholder.email.isNotEmpty)
                    Text(
                      stakeholder.email,
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 11,
                        color: colors.ink400,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Type badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors.infoBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                stakeholder.type,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: colors.navyDeep,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Detail bottom sheet ───────────────────────────────────────────────────────

class _StakeholderDetailSheet extends StatelessWidget {
  const _StakeholderDetailSheet({
    required this.stakeholder,
    required this.colors,
  });

  final PppStakeholder stakeholder;
  final AppColorScheme colors;

  Widget _row(IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: colors.goldPrimary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10,
                        color: colors.ink400)),
                const SizedBox(height: 2),
                SelectableText(
                  value,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 13,
                    color: colors.ink900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, controller) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: ListView(
          controller: controller,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.lineSoft,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Header
            if (stakeholder.cname.isNotEmpty)
              Text(
                stakeholder.cname,
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: colors.ink900,
                ),
              ),
            Text(
              stakeholder.fullName,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 14,
                color: colors.ink600,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.infoBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                stakeholder.type,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colors.navyDeep,
                ),
              ),
            ),
            Divider(color: colors.lineSoft),
            const SizedBox(height: 8),
            _row(Icons.email_outlined, 'Email', stakeholder.email),
            _row(Icons.phone_outlined, 'Phone', stakeholder.phone),
            _row(Icons.location_on_outlined, 'Address', stakeholder.address),
            _row(Icons.location_city_outlined, 'City', stakeholder.city),
            _row(Icons.language_outlined, 'Website', stakeholder.website),
            if (stakeholder.description.isNotEmpty) ...[
              Divider(color: colors.lineSoft),
              const SizedBox(height: 8),
              Text('About',
                  style: TextStyle(
                      fontFamily: 'DMSans',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: colors.ink900)),
              const SizedBox(height: 6),
              Text(
                stakeholder.description,
                style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 13,
                    color: colors.ink600,
                    height: 1.6),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Shimmer skeleton ──────────────────────────────────────────────────────────

class _DirectoryShimmer extends StatelessWidget {
  const _DirectoryShimmer({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: colors.surfaceTertiary,
      highlightColor: colors.surfaceCard,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        itemCount: 7,
        itemBuilder: (_, __) => Container(
          height: 80,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
