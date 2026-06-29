import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../data/models/association_content_model.dart';
import '../../data/models/association_model.dart';
import '../providers/association_content_providers.dart';

const _tileBlue = Color(0xFFE8EEF5);
const _tileBlueText = Color(0xFF2A4A6B);

const _filterLabels = ['Available', 'Accepted', 'All'];

class AssociationCabsScreen extends ConsumerStatefulWidget {
  const AssociationCabsScreen({super.key, required this.assoc, this.isAdmin = false});
  final AssociationModel assoc;
  final bool isAdmin;

  @override
  ConsumerState<AssociationCabsScreen> createState() => _AssociationCabsScreenState();
}

class _AssociationCabsScreenState extends ConsumerState<AssociationCabsScreen> {
  int _filterIdx = 0; // 0=Available, 1=Accepted, 2=All

  List<AssociationCabModel> _filtered(List<AssociationCabModel> all) {
    if (_filterIdx == 2) return all;
    final wantAvailable = _filterIdx == 0;
    return all.where((c) => (c.status == 'available') == wantAvailable).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final topPad = MediaQuery.paddingOf(context).top;
    final async = widget.isAdmin
        ? ref.watch(associationCabsProvider(widget.assoc.id))
        : ref.watch(associationCabNetworkProvider);

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: Stack(
        children: [
          async.when(
            loading: () => ListView.builder(
              padding: EdgeInsets.fromLTRB(0, topPad + 108, 0, 24),
              itemCount: 4,
              itemBuilder: (_, __) => _ShimmerCard(colors: colors),
            ),
            error: (_, __) => Center(
              child: GestureDetector(
                onTap: () => widget.isAdmin
                    ? ref.invalidate(associationCabsProvider)
                    : ref.invalidate(associationCabNetworkProvider),
                child: Text('Retry',
                    style: AppTypography.label.copyWith(
                        color: colors.goldPrimary, fontWeight: FontWeight.w600)),
              ),
            ),
            data: (all) {
              final cabs = _filtered(all);
              return cabs.isEmpty
                  ? _emptyState(colors)
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(0, topPad + 108, 0, 24),
                      itemCount: cabs.length,
                      itemBuilder: (_, i) => _CabCard(cab: cabs[i], colors: colors),
                    );
            },
          ),

          // ── App bar + filter pills
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              color: colors.surfacePrimary,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 12),
                    child: Row(children: [
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
                      Text(
                        widget.isAdmin ? 'Admin Cab' : 'Cab Network',
                        style: AppTypography.displayMd.copyWith(
                          color: colors.ink900, fontSize: 18, fontWeight: FontWeight.w700,
                        ),
                      ),
                    ]),
                  ),
                  // Filter pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Row(
                      children: List.generate(_filterLabels.length, (i) {
                        final active = i == _filterIdx;
                        return Padding(
                          padding: EdgeInsets.only(right: i < _filterLabels.length - 1 ? 8 : 0),
                          child: GestureDetector(
                            onTap: () => setState(() => _filterIdx = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: active ? colors.ink900 : Colors.transparent,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: active ? colors.ink900 : colors.lineSoft,
                                ),
                              ),
                              child: Text(
                                _filterLabels[i],
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(AppColorScheme colors) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(shape: BoxShape.circle, color: colors.surfaceTertiary),
            child: Icon(Icons.airport_shuttle_outlined, color: colors.ink400, size: 28),
          ),
          const SizedBox(height: 14),
          Text('No cabs available',
              style: AppTypography.body.copyWith(
                  color: colors.ink600, fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
      );
}

class _CabCard extends StatelessWidget {
  const _CabCard({required this.cab, required this.colors});
  final AssociationCabModel cab;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final isAvailable = cab.status == 'available';
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.lineSoft),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: colors.surfaceTertiary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.airport_shuttle_outlined, color: colors.ink600, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(cab.driverName,
                  style: AppTypography.body.copyWith(
                      color: colors.ink900, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(cab.location,
                  style: AppTypography.caption.copyWith(color: colors.ink600, fontSize: 11)),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _tileBlue,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(cab.vehicleType,
                    style: const TextStyle(
                        color: _tileBlueText, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
          GestureDetector(
            onTap: () {
              if (isAvailable && cab.phone != null) {
                launchUrl(Uri.parse('tel:${cab.phone}'));
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isAvailable ? colors.goldPrimary : colors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isAvailable ? 'Accept' : 'Accepted',
                style: AppTypography.label.copyWith(
                  color: isAvailable ? colors.ink900 : colors.success,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard({required this.colors});
  final AppColorScheme colors;
  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: colors.surfaceTertiary,
        highlightColor: colors.surfaceCard,
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          height: 72,
          decoration: BoxDecoration(
              color: colors.surfaceCard, borderRadius: BorderRadius.circular(14)),
        ),
      );
}
