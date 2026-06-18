import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/campus_models.dart';
import '../providers/campus_providers.dart';

class CourseListScreen extends ConsumerWidget {
  const CourseListScreen({
    super.key,
    required this.catId,
    this.catLabel,
  });

  final String catId;
  final String? catLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final async = ref.watch(campusCourseItemsProvider(catId));

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
          catLabel ?? 'Courses',
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
              height: 88,
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
                onPressed: () => ref.invalidate(campusCourseItemsProvider(catId)),
                child: Text(
                  'Retry',
                  style: TextStyle(
                      fontFamily: 'DMSans', color: colors.goldPrimary),
                ),
              ),
            ],
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Text(
                'No courses available',
                style: TextStyle(fontFamily: 'DMSans', color: colors.ink600),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: items.length,
            itemBuilder: (_, i) => _CourseCard(item: items[i], colors: colors),
          );
        },
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.item, required this.colors});

  final CampusCourseItem item;
  final AppColorScheme colors;

  Future<void> _launch() async {
    final link = item.link;
    if (link.isEmpty) return;
    final uri = Uri.parse(link.startsWith('http') ? link : 'https://$link');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.lineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.label,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: colors.ink900,
            ),
          ),
          if (item.link.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              item.link,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12,
                color: colors.ink400,
              ),
            ),
          ],
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _launch,
            child: Text(
              'Start Course →',
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
    );
  }
}
