import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/space_sub_appbar.dart';

class _Job {
  const _Job({
    required this.title,
    required this.company,
    required this.tags,
    required this.time,
    required this.salary,
  });
  final String title;
  final String company;
  final List<String> tags;
  final String time;
  final String salary;
}

const _kJobs = [
  _Job(
    title: 'Tour Operations Manager',
    company: 'Travel Corp India · New Delhi',
    tags: ['Full-time', '5+ yrs', 'Hybrid'],
    time: '2h ago · 12 applicants',
    salary: '₹8–12 LPA',
  ),
  _Job(
    title: 'Visa Executive',
    company: 'Global Visa Services · Mumbai',
    tags: ['Full-time', '2+ yrs', 'On-site'],
    time: '5h ago · 28 applicants',
    salary: '₹4–6 LPA',
  ),
  _Job(
    title: 'Business Development Executive',
    company: 'Holiday Planet · Bangalore',
    tags: ['Full-time', '3+ yrs', 'Hybrid'],
    time: '1d ago · 45 applicants',
    salary: '₹6–9 LPA',
  ),
  _Job(
    title: 'Ticketing Executive',
    company: 'Fly High Travels · Mumbai',
    tags: ['Full-time', '1+ yrs', 'On-site'],
    time: '2d ago · 64 applicants',
    salary: '₹3–4.5 LPA',
  ),
];

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  int _filterIndex = 0;
  final Set<int> _saved = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(0, topPad + 76, 0, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  decoration: BoxDecoration(
                    color: colors.surfaceCard,
                    border: Border.all(color: colors.lineSoft),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, size: 18, color: colors.ink600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 14,
                            color: colors.ink900,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search jobs by role, company...',
                            hintStyle: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 14,
                              color: colors.ink400,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
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
                        child: Center(
                          child: Icon(
                            Icons.tune_rounded,
                            size: 14,
                            color: colors.surfacePrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SpaceFilterPills(
                  filters: const ['All Jobs', 'My Applications', 'Saved'],
                  selectedIndex: _filterIndex,
                  onSelected: (i) => setState(() => _filterIndex = i),
                  colors: colors,
                ),
                const SizedBox(height: 16),
                ...List.generate(_kJobs.length, (index) {
                  final job = _kJobs[index];
                  final isSaved = _saved.contains(index);
                  return _JobCard(
                    job: job,
                    isSaved: isSaved,
                    colors: colors,
                    onBookmark: () {
                      setState(() {
                        if (isSaved) {
                          _saved.remove(index);
                        } else {
                          _saved.add(index);
                        }
                      });
                    },
                  );
                }),
              ],
            ),
          ),
          SpaceSubAppBar(
            title: 'Jobs',
            topPad: topPad,
            colors: colors,
            actionIcon: Icons.chat_bubble_outline_rounded,
          ),
          Positioned(
            bottom: 24,
            right: 20,
            child: Container(
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
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, size: 16, color: colors.ink900),
                        const SizedBox(width: 6),
                        Text(
                          'Post a Job',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.ink900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.job,
    required this.isSaved,
    required this.colors,
    required this.onBookmark,
  });

  final _Job job;
  final bool isSaved;
  final AppColorScheme colors;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        border: Border.all(color: colors.lineSoft),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colors.ink900,
                        height: 1.33,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.company,
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
                        color: colors.ink600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onBookmark,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSaved ? colors.goldPrimary : colors.surfacePrimary,
                    border: Border.all(
                      color: isSaved ? colors.goldPrimary : colors.lineSoft,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                      size: 16,
                      color: isSaved ? colors.ink900 : colors.ink600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: job.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surfacePrimary,
                  border: Border.all(color: colors.lineSoft),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colors.ink600,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: colors.lineSoft)),
            ),
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  job.time,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 11,
                    color: colors.ink400,
                  ),
                ),
                Text(
                  job.salary,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.goldPrimary,
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
