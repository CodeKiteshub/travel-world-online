import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/job_post_model.dart';
import '../providers/jobs_providers.dart';

class JobsScreen extends ConsumerStatefulWidget {
  const JobsScreen({super.key});

  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> {
  static const _tabs = ['Browse Jobs', 'Post Resume'];
  int _selectedTab = 0;
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
      body: Column(
        children: [
          // Segmented control
          _SegmentedControl(
            tabs: _tabs,
            selected: _selectedTab,
            onSelect: (i) => setState(() => _selectedTab = i),
            colors: colors,
          ),

          // Search bar with filter button (Browse Jobs tab only)
          if (_selectedTab == 0)
            _SearchBar(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              colors: colors,
            ),

          // Content
          Expanded(
            child: _selectedTab == 0
                ? _BrowseJobs(
                    jobsAsync: jobsAsync,
                    query: _query,
                    colors: colors,
                    onRetry: () => ref.invalidate(jobsProvider),
                  )
                : _PostResumeTab(colors: colors),
          ),
        ],
      ),
    );
  }
}

// ── Segmented control ──────────────────────────────────────────────────────
class _SegmentedControl extends StatelessWidget {
  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onSelect;
  final AppColorScheme colors;

  const _SegmentedControl({
    required this.tabs,
    required this.selected,
    required this.onSelect,
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
        children: List.generate(tabs.length, (i) {
          final active = i == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? colors.surfacePrimary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    tabs[i],
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
        }),
      ),
    );
  }
}

// ── Search bar with filter icon ────────────────────────────────────────────
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
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
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
                hintText: 'Search by title, company, location…',
                hintStyle:
                    TextStyle(fontSize: 13, color: colors.ink400),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: colors.ink900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.tune, size: 14, color: colors.surfacePrimary),
          ),
        ],
      ),
    );
  }
}

// ── Browse Jobs tab ────────────────────────────────────────────────────────
class _BrowseJobs extends StatelessWidget {
  final AsyncValue<List<JobPost>> jobsAsync;
  final String query;
  final AppColorScheme colors;
  final VoidCallback onRetry;

  const _BrowseJobs({
    required this.jobsAsync,
    required this.query,
    required this.colors,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return jobsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Failed to load jobs',
                style: TextStyle(color: colors.ink600)),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
      data: (jobs) {
        final filtered = query.isEmpty
            ? jobs
            : jobs
                .where((j) =>
                    j.jobTitle
                        .toLowerCase()
                        .contains(query.toLowerCase()) ||
                    j.companyName
                        .toLowerCase()
                        .contains(query.toLowerCase()) ||
                    j.location
                        .toLowerCase()
                        .contains(query.toLowerCase()))
                .toList();

        if (filtered.isEmpty) {
          return Center(
            child: Text('No jobs found',
                style: TextStyle(color: colors.ink400)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: filtered.length,
          itemBuilder: (context, i) =>
              _JobCard(job: filtered[i], colors: colors),
        );
      },
    );
  }
}

// ── Post Resume placeholder tab ────────────────────────────────────────────
class _PostResumeTab extends StatelessWidget {
  final AppColorScheme colors;
  const _PostResumeTab({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Resume posting coming soon',
        style: TextStyle(color: colors.ink400, fontSize: 14),
      ),
    );
  }
}

// ── Job card ───────────────────────────────────────────────────────────────
class _JobCard extends StatefulWidget {
  final JobPost job;
  final AppColorScheme colors;
  const _JobCard({required this.job, required this.colors});

  @override
  State<_JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<_JobCard> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final colors = widget.colors;

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
          // Top row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
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
                      style: TextStyle(
                          fontSize: 12, color: colors.ink600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Bookmark — rounded rectangle per HTML spec
              GestureDetector(
                onTap: () => setState(() => _saved = !_saved),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _saved
                        ? const Color(0xFFC9A84C)
                        : colors.surfacePrimary,
                    border: Border.all(
                      color: _saved
                          ? const Color(0xFFC9A84C)
                          : colors.lineSoft,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _saved ? Icons.bookmark : Icons.bookmark_border,
                    size: 18,
                    color: _saved ? colors.surfacePrimary : colors.ink600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Tags
          Wrap(
            spacing: 6,
            children: [
              _Tag(text: 'Full-time', colors: colors),
              _Tag(text: 'Travel Industry', colors: colors),
            ],
          ),
          const SizedBox(height: 10),
          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                job.timeAgo,
                style:
                    TextStyle(fontSize: 11, color: colors.ink400),
              ),
              Container(
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
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final AppColorScheme colors;
  const _Tag({required this.text, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: colors.lineSoft),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text,
          style: TextStyle(fontSize: 11, color: colors.ink600)),
    );
  }
}
