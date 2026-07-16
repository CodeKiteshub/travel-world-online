import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/job_post_model.dart';
import '../providers/jobs_providers.dart';
import '../widgets/job_apply_sheet.dart';

class JobsScreen extends ConsumerWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final jobsAsync = ref.watch(jobsProvider);

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
          'Jobs',
          style: AppTypography.titleMedium.copyWith(color: colors.ink900),
        ),
      ),
      body: jobsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to load jobs',
                  style: TextStyle(color: colors.ink600)),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.invalidate(jobsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (jobs) {
          if (jobs.isEmpty) {
            return Center(
              child: Text('No jobs found',
                  style: TextStyle(color: colors.ink400)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: jobs.length,
            itemBuilder: (context, i) =>
                _JobCard(job: jobs[i], colors: colors),
          );
        },
      ),
    );
  }
}

// ── Job card ───────────────────────────────────────────────────────────────
class _JobCard extends StatelessWidget {
  final JobPost job;
  final AppColorScheme colors;
  const _JobCard({required this.job, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        border: Border.all(color: colors.lineSoft),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.jobTitle,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.ink900,
                height: 1.3),
          ),
          const SizedBox(height: 3),
          Text(
            job.companyLocation,
            style: TextStyle(fontSize: 12, color: colors.ink600),
          ),
          if (job.jobDescription.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              job.jobDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 12, color: colors.ink600, height: 1.4),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                job.timeAgo,
                style: TextStyle(fontSize: 11, color: colors.ink400),
              ),
              GestureDetector(
                onTap: () => showJobApplySheet(context, job),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.surfacePrimary,
                    border: Border.all(color: colors.lineSoft),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Apply Now',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFC9A84C)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
