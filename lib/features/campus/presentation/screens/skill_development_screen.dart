import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/campus_models.dart';
import '../providers/campus_providers.dart';

class SkillDevelopmentScreen extends ConsumerWidget {
  const SkillDevelopmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final async = ref.watch(skillCoursesProvider);

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
          'Skill Development',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: colors.ink900,
          ),
        ),
      ),
      body: async.when(
        loading: () => Shimmer.fromColors(
          baseColor: colors.surfaceTertiary,
          highlightColor: colors.surfaceCard,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: 5,
            itemBuilder: (_, __) => Container(
              height: 96,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Failed to load courses',
                style: TextStyle(fontFamily: 'DMSans', color: colors.ink600),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.invalidate(skillCoursesProvider),
                child: Text(
                  'Retry',
                  style:
                      TextStyle(fontFamily: 'DMSans', color: colors.goldPrimary),
                ),
              ),
            ],
          ),
        ),
        data: (courses) {
          if (courses.isEmpty) {
            return Center(
              child: Text(
                'No courses available',
                style: TextStyle(fontFamily: 'DMSans', color: colors.ink600),
              ),
            );
          }
          return Column(
            children: [
              // Banner
              Container(
                margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: colors.navyDeep,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.school_outlined,
                        color: Colors.white70, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SKILL DEVELOPMENT',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 0.16,
                              color: Colors.white70,
                              fontFamily: 'DMSans',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${courses.length} Course${courses.length != 1 ? 's' : ''} Available',
                            style: const TextStyle(
                              fontFamily: 'PlayfairDisplay',
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                  itemCount: courses.length,
                  itemBuilder: (_, i) => _SkillCategoryCard(
                    course: courses[i],
                    index: i,
                    colors: colors,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SkillCategoryCard extends StatelessWidget {
  const _SkillCategoryCard({
    required this.course,
    required this.index,
    required this.colors,
  });

  final SkillCourse course;
  final int index;
  final AppColorScheme colors;

  static const _iconBgs = [
    Color(0xFFFEF3C7), // amber
    Color(0xFFDCFCE7), // green
    Color(0xFFEDE9FE), // purple
    Color(0xFFFFEDD5), // orange
    Color(0xFFDBEAFE), // blue
  ];
  static const _iconColors = [
    Color(0xFFB45309),
    Color(0xFF166534),
    Color(0xFF7C3AED),
    Color(0xFFC2410C),
    Color(0xFF1D4ED8),
  ];
  static const _icons = [
    Icons.calculate_outlined,
    Icons.trending_up_rounded,
    Icons.cast_for_education_outlined,
    Icons.business_center_outlined,
    Icons.language_outlined,
  ];

  Future<void> _launch(String link) async {
    if (link.isEmpty) return;
    final uri = Uri.parse(link.startsWith('http') ? link : 'https://$link');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorIdx = index % _iconBgs.length;
    return GestureDetector(
      onTap: () => context.push(
        '/skill-development/${course.id}',
        extra: course.label,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0)
            .copyWith(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.lineSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _iconBgs[colorIdx],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _icons[colorIdx],
                    color: _iconColors[colorIdx],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.label,
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: colors.ink900,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.surfaceTertiary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Courses',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 11,
                      color: colors.ink600,
                    ),
                  ),
                ),
              ],
            ),
            if (course.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                course.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  color: colors.ink600,
                ),
              ),
            ],
            const SizedBox(height: 10),
            GestureDetector(
              onTap: course.description.startsWith('http')
                  ? () => _launch(course.description)
                  : null,
              child: Text(
                'Explore Courses →',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.goldPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
