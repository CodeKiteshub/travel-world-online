import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../data/models/association_content_model.dart';
import '../../data/models/association_model.dart';
import '../providers/association_content_providers.dart';

class AssociationCircularsScreen extends ConsumerStatefulWidget {
  const AssociationCircularsScreen({super.key, required this.assoc});
  final AssociationModel assoc;

  @override
  ConsumerState<AssociationCircularsScreen> createState() =>
      _AssociationCircularsScreenState();
}

class _AssociationCircularsScreenState
    extends ConsumerState<AssociationCircularsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final topPad = MediaQuery.paddingOf(context).top;
    final async = ref.watch(associationCircularsProvider(widget.assoc.id));

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: Stack(
        children: [
          async.when(
            loading: () => ListView.builder(
              padding: EdgeInsets.fromLTRB(0, topPad + 74, 0, 24),
              itemCount: 5,
              itemBuilder: (_, __) => _ShimmerRow(colors: colors),
            ),
            error: (_, __) => Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.cloud_off_rounded, color: colors.ink400, size: 40),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => ref.invalidate(associationCircularsProvider),
                  child: Text('Retry',
                      style: AppTypography.label.copyWith(
                          color: colors.goldPrimary, fontWeight: FontWeight.w600)),
                ),
              ]),
            ),
            data: (all) {
              final items = _query.isEmpty
                  ? all
                  : all
                      .where((c) =>
                          c.title.toLowerCase().contains(_query.toLowerCase()))
                      .toList();
              return ListView(
                padding: EdgeInsets.fromLTRB(0, topPad + 74, 0, 24),
                children: [
                  _SearchBar(colors: colors, onChanged: (v) => setState(() => _query = v)),
                  if (items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Center(
                        child: Text('No circulars found',
                            style: AppTypography.body.copyWith(color: colors.ink600)),
                      ),
                    )
                  else
                    ...items.map((c) => _CircularRow(
                          circular: c,
                          colors: colors,
                          onTap: () => _openDetail(context, c, colors),
                        )),
                ],
              );
            },
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              color: colors.surfacePrimary,
              padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 12),
              child: Row(children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: colors.surfaceCard, border: Border.all(color: colors.lineSoft)),
                    child: Icon(Icons.arrow_back, size: 18, color: colors.ink900),
                  ),
                ),
                const SizedBox(width: 10),
                Text('Circulars',
                    style: AppTypography.displayMd.copyWith(color: colors.ink900, fontSize: 18, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context, AssociationCircularModel c, AppColorScheme colors) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surfacePrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, ctrl) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                          color: colors.lineSoft,
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(c.title,
                      style: AppTypography.displayMd.copyWith(
                          color: colors.ink900, fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(c.date,
                      style: AppTypography.caption.copyWith(color: colors.ink400, fontSize: 11)),
                ],
              ),
            ),
            Divider(color: colors.lineSoft, height: 1),
            Expanded(
              child: SingleChildScrollView(
                controller: ctrl,
                padding: const EdgeInsets.all(20),
                child: HtmlWidget(
                  c.content.isNotEmpty ? c.content : '<p>No content available.</p>',
                  textStyle: AppTypography.body.copyWith(color: colors.ink900, fontSize: 14, height: 1.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircularRow extends StatelessWidget {
  const _CircularRow({required this.circular, required this.colors, required this.onTap});
  final AssociationCircularModel circular;
  final AppColorScheme colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                color: colors.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.description_outlined, color: colors.error, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(circular.title,
                            style: AppTypography.body.copyWith(
                                color: colors.ink900, fontSize: 13, fontWeight: FontWeight.w600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (circular.isNew) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.error,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('NEW',
                              style: AppTypography.overline.copyWith(
                                  color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(circular.date,
                      style: AppTypography.caption.copyWith(color: colors.ink400, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.colors, required this.onChanged});
  final AppColorScheme colors;
  final ValueChanged<String> onChanged;

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
      child: Row(children: [
        Icon(Icons.search_rounded, size: 18, color: colors.ink400),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            onChanged: onChanged,
            style: AppTypography.body.copyWith(color: colors.ink900, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search circulars…',
              hintStyle: AppTypography.body.copyWith(color: colors.ink400, fontSize: 13),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ]),
    );
  }
}

class _ShimmerRow extends StatelessWidget {
  const _ShimmerRow({required this.colors});
  final AppColorScheme colors;
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: colors.surfaceTertiary,
      highlightColor: colors.surfaceCard,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        height: 68,
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
