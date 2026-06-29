import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../data/models/association_content_model.dart';
import '../../data/models/association_model.dart';
import '../providers/association_content_providers.dart';

class AssociationJobsScreen extends ConsumerWidget {
  const AssociationJobsScreen({super.key, required this.assoc});
  final AssociationModel assoc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final topPad = MediaQuery.paddingOf(context).top;
    final async = ref.watch(associationJobsProvider(assoc.id));

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
                onTap: () => ref.invalidate(associationJobsProvider),
                child: Text('Retry',
                    style: AppTypography.label.copyWith(
                        color: colors.goldPrimary, fontWeight: FontWeight.w600)),
              ),
            ),
            data: (jobs) => ListView(
              padding: EdgeInsets.fromLTRB(0, topPad + 64, 0, 24),
              children: [
                // Post a Job CTA
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: colors.goldPrimary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('+ Post a Job',
                        style: AppTypography.label.copyWith(
                            color: colors.ink900, fontSize: 14, fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center),
                  ),
                ),
                if (jobs.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Text('No jobs posted yet',
                          style: AppTypography.body.copyWith(color: colors.ink600)),
                    ),
                  )
                else
                  ...jobs.map((j) => _JobCard(job: j, colors: colors)),
              ],
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
                Text('Jobs',
                    style: AppTypography.displayMd.copyWith(color: colors.ink900, fontSize: 18, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job, required this.colors});
  final AssociationJobModel job;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
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
          Text(job.title,
              style: AppTypography.body.copyWith(
                  color: colors.ink900, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('${job.company} · ${job.location}',
              style: AppTypography.caption.copyWith(color: colors.ink600, fontSize: 12)),
          if (job.salary != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(job.salary!,
                  style: AppTypography.caption.copyWith(
                      color: colors.success, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ],
          if (job.description != null) ...[
            const SizedBox(height: 8),
            Text(job.description!,
                style: AppTypography.caption.copyWith(color: colors.ink600, fontSize: 12, height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 10),
          Divider(color: colors.lineSoft, height: 1),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(_formatDate(job.postedAt),
                style: AppTypography.caption.copyWith(color: colors.ink400, fontSize: 11)),
            Text('Apply →',
                style: AppTypography.label.copyWith(
                    color: colors.goldPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
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
          height: 100,
          decoration: BoxDecoration(color: colors.surfaceCard, borderRadius: BorderRadius.circular(16)),
        ),
      );
}
