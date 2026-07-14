import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../associations/presentation/providers/associations_providers.dart';
import '../../../associations/presentation/providers/association_session_provider.dart';
import '../../../jobs/presentation/providers/jobs_providers.dart';
import '../../../marketplace/presentation/providers/marketplace_providers.dart';
import '../../../video/presentation/providers/video_providers.dart';
import '../../data/models/article_model.dart';
import '../providers/home_providers.dart';

// Home dashboard sections. Each section collapses entirely on error/empty —
// full error and empty states live on the module screens.

// ── Section header ────────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    required this.colors,
    this.onSeeAll,
  });
  final String title;
  final AppColorScheme colors;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: AppTypography.displayMd.copyWith(
              color: colors.ink900,
              fontSize: 19,
            ),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'See All →',
                  style: AppTypography.label.copyWith(
                    color: colors.goldPrimary,
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

Widget _skeletonStrip(AppColorScheme colors, {double height = 140}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: colors.surfaceTertiary,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );

Widget _netImage(String url, {BoxFit fit = BoxFit.cover}) => url.isNotEmpty
    ? Image.network(url, fit: fit,
        errorBuilder: (_, __, ___) => const _ImageFallback())
    : const _ImageFallback();

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.navyDeep, Color(0xFF1A3550)],
          ),
        ),
      );
}

// ── Quick Actions — Insurance & Visa ─────────────────────────────────────────

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key, required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _QuickActionCard(
              icon: Icons.shield_outlined,
              title: 'Travel Insurance',
              subtitle: 'Cover a trip in minutes',
              colors: colors,
              onTap: () => context.push(RouteNames.insurance),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickActionCard(
              icon: Icons.flight_takeoff_outlined,
              title: 'Visa Assistance',
              subtitle: 'Start an application',
              colors: colors,
              onTap: () => context.push(RouteNames.visa),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final AppColorScheme colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.lineSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: colors.ink900),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppTypography.label.copyWith(
                color: colors.ink900,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTypography.caption.copyWith(
                color: colors.ink600,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top Stories — news ────────────────────────────────────────────────────────

class TopStoriesSection extends ConsumerWidget {
  const TopStoriesSection({super.key, required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsProvider);
    return newsAsync.when(
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Top Stories', colors: colors),
          _skeletonStrip(colors, height: 200),
        ],
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (articles) {
        if (articles.isEmpty) return const SizedBox.shrink();
        final hero = articles.first;
        final compact = articles.skip(1).take(2).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Top Stories',
              colors: colors,
              onSeeAll: () => context.push(RouteNames.news),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _HeroStoryCard(article: hero, colors: colors),
            ),
            const SizedBox(height: 12),
            for (final a in compact)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: _CompactStoryCard(article: a, colors: colors),
              ),
          ],
        );
      },
    );
  }
}

class _HeroStoryCard extends StatelessWidget {
  const _HeroStoryCard({required this.article, required this.colors});
  final Article article;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RouteNames.newsArticleDetail, extra: article),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _netImage(article.firstImage),
                  if (article.category.name.isNotEmpty)
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.navyDeep.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          article.category.name.toUpperCase(),
                          style: AppTypography.overline.copyWith(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            article.title,
            style: AppTypography.body.copyWith(
              color: colors.ink900,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            article.sourceMeta,
            style: AppTypography.caption.copyWith(
              color: colors.ink600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactStoryCard extends StatelessWidget {
  const _CompactStoryCard({required this.article, required this.colors});
  final Article article;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RouteNames.newsArticleDetail, extra: article),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 80,
              height: 70,
              child: _netImage(article.firstImage),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (article.category.name.isNotEmpty)
                  Text(
                    article.category.name.toUpperCase(),
                    style: AppTypography.overline.copyWith(
                      color: colors.goldPrimary,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                const SizedBox(height: 3),
                Text(
                  article.title,
                  style: AppTypography.body.copyWith(
                    color: colors.ink900,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  article.sourceMeta,
                  style: AppTypography.caption.copyWith(
                    color: colors.ink600,
                    fontSize: 10.5,
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

// ── Luxury Stays — marketplace hotels ────────────────────────────────────────

class LuxuryStaysSection extends ConsumerWidget {
  const LuxuryStaysSection({super.key, required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hotelsAsync = ref.watch(luxuryHotelsProvider);
    return hotelsAsync.when(
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Luxury Stays', colors: colors),
          _skeletonStrip(colors, height: 160),
        ],
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (hotels) {
        if (hotels.isEmpty) return const SizedBox.shrink();
        final items = hotels.take(8).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Luxury Stays',
              colors: colors,
              onSeeAll: () => context.go(RouteNames.marketplace),
            ),
            SizedBox(
              height: 176,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final hotel = items[i];
                  return GestureDetector(
                    onTap: () =>
                        context.push(RouteNames.hotelDetail, extra: hotel),
                    child: SizedBox(
                      width: 180,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: SizedBox(
                              width: 180,
                              height: 120,
                              child: _netImage(hotel.firstImage),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            hotel.name,
                            style: AppTypography.label.copyWith(
                              color: colors.ink900,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hotel.location,
                            style: AppTypography.caption.copyWith(
                              color: colors.ink600,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Latest Videos ─────────────────────────────────────────────────────────────

class LatestVideosSection extends ConsumerWidget {
  const LatestVideosSection({super.key, required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(videoFeedProvider);
    if (feed.items.isEmpty) {
      if (feed.isLoading) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: 'Latest Videos', colors: colors),
            _skeletonStrip(colors, height: 130),
          ],
        );
      }
      return const SizedBox.shrink();
    }
    final items = feed.items.take(8).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Latest Videos',
          colors: colors,
          onSeeAll: () => context.push(RouteNames.video),
        ),
        SizedBox(
          height: 156,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final video = items[i];
              return GestureDetector(
                onTap: () => context.push(RouteNames.video),
                child: SizedBox(
                  width: 190,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          width: 190,
                          height: 107,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              _netImage(video.thumbnailUrl),
                              Center(
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.45),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        video.title,
                        style: AppTypography.label.copyWith(
                          color: colors.ink900,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Open Jobs ─────────────────────────────────────────────────────────────────

class OpenJobsSection extends ConsumerWidget {
  const OpenJobsSection({super.key, required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(jobsProvider);
    return jobsAsync.when(
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Open Jobs', colors: colors),
          _skeletonStrip(colors, height: 120),
        ],
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (jobs) {
        if (jobs.isEmpty) return const SizedBox.shrink();
        final items = jobs.take(2).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Open Jobs',
              colors: colors,
              onSeeAll: () => context.push(RouteNames.jobs),
            ),
            for (final job in items)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: GestureDetector(
                  onTap: () => context.push(RouteNames.jobs),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.surfaceCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.lineSoft),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: colors.surfaceTertiary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.work_outline,
                              size: 20, color: colors.ink600),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.jobTitle,
                                style: AppTypography.label.copyWith(
                                  color: colors.ink900,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                job.companyLocation,
                                style: AppTypography.caption.copyWith(
                                  color: colors.ink600,
                                  fontSize: 11.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          job.timeAgo,
                          style: AppTypography.caption.copyWith(
                            color: colors.ink400,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ── Your Associations ─────────────────────────────────────────────────────────

class AssociationsSection extends ConsumerWidget {
  const AssociationsSection({super.key, required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assocAsync = ref.watch(associationsProvider);
    return assocAsync.when(
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Associations', colors: colors),
          _skeletonStrip(colors, height: 148),
        ],
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (associations) {
        if (associations.isEmpty) return const SizedBox.shrink();
        final sessions = ref.watch(associationSessionProvider);
        // Signed-in associations lead the strip.
        final sorted = [...associations]..sort((a, b) {
            final aIn = sessions.containsKey(a.id) ? 0 : 1;
            final bIn = sessions.containsKey(b.id) ? 0 : 1;
            return aIn.compareTo(bIn);
          });
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Associations',
              colors: colors,
              onSeeAll: () => context.go(RouteNames.associations),
            ),
            SizedBox(
              height: 148,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: sorted.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final assoc = sorted[i];
                  final signedIn = sessions.containsKey(assoc.id);
                  return GestureDetector(
                    // Signed in → straight to that association's dashboard.
                    onTap: () => signedIn
                        ? context.push(
                            RouteNames.associationDashboard
                                .replaceFirst(':id', assoc.id),
                            extra: assoc,
                          )
                        : context.go(RouteNames.associations),
                    child: Container(
                      width: 150,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: signedIn
                            ? colors.goldPrimary.withValues(alpha: 0.06)
                            : colors.surfaceCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              signedIn ? colors.goldPrimary : colors.lineSoft,
                          width: signedIn ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: colors.surfaceTertiary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: colors.lineSoft),
                                ),
                                child: ClipOval(
                                  child: assoc.logoUrl.isNotEmpty
                                      ? Image.network(
                                          assoc.logoUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Icon(
                                            Icons.groups_outlined,
                                            size: 22,
                                            color: colors.ink600,
                                          ),
                                        )
                                      : Icon(
                                          Icons.groups_outlined,
                                          size: 22,
                                          color: colors.ink600,
                                        ),
                                ),
                              ),
                              const Spacer(),
                              if (signedIn)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color:
                                        colors.success.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: colors.success,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'IN',
                                        style: AppTypography.overline.copyWith(
                                          color: colors.success,
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            assoc.name,
                            style: AppTypography.label.copyWith(
                              color: colors.ink900,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            signedIn
                                ? 'Open dashboard →'
                                : assoc.atype.toUpperCase(),
                            style: signedIn
                                ? AppTypography.label.copyWith(
                                    color: colors.goldPrimary,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                  )
                                : AppTypography.overline.copyWith(
                                    color: colors.ink600,
                                    fontSize: 9,
                                    letterSpacing: 0.6,
                                  ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
