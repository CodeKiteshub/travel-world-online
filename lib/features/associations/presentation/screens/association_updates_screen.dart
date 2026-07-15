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

class AssociationUpdatesScreen extends ConsumerWidget {
  const AssociationUpdatesScreen({super.key, required this.assoc});
  final AssociationModel assoc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final topPad = MediaQuery.paddingOf(context).top;
    final async = ref.watch(associationUpdatesProvider(assoc.id));

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: Stack(
        children: [
          async.when(
            loading: () => ListView.builder(
              padding: EdgeInsets.fromLTRB(0, topPad + 64, 0, 24),
              itemCount: 4,
              itemBuilder: (_, __) => _ShimmerCard(colors: colors),
            ),
            error: (_, __) => Center(
              child: GestureDetector(
                onTap: () => ref.invalidate(associationUpdatesProvider),
                child: Text('Retry',
                    style: AppTypography.label
                        .copyWith(color: colors.goldPrimary, fontWeight: FontWeight.w600)),
              ),
            ),
            data: (items) => items.isEmpty
                ? Center(
                    child: Text('No updates yet',
                        style: AppTypography.body.copyWith(color: colors.ink600)))
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(0, topPad + 64, 0, 24),
                    itemCount: items.length,
                    itemBuilder: (_, i) => _UpdateCard(update: items[i], colors: colors),
                  ),
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
                Text('Updates',
                    style: AppTypography.displayMd.copyWith(color: colors.ink900, fontSize: 18, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpdateCard extends StatelessWidget {
  const _UpdateCard({required this.update, required this.colors});
  final AssociationUpdateModel update;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    // Matches the website layout: title, date, description (image not shown)
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
          Text(update.text,
              style: AppTypography.body.copyWith(
                  color: colors.ink900, fontSize: 14, fontWeight: FontWeight.w600, height: 1.4)),
          const SizedBox(height: 4),
          Text(_formatDate(update.postedAt),
              style: AppTypography.caption.copyWith(color: colors.ink400, fontSize: 11)),
          if (update.content.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            HtmlWidget(
              update.content,
              textStyle: AppTypography.body.copyWith(color: colors.ink600, fontSize: 13, height: 1.5),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final diff = now.difference(d);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return iso;
    }
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
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          height: 90,
          decoration: BoxDecoration(color: colors.surfaceCard, borderRadius: BorderRadius.circular(16)),
        ),
      );
}
