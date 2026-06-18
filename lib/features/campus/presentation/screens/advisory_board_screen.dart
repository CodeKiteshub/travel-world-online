import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/campus_models.dart';
import '../providers/campus_providers.dart';

class AdvisoryBoardScreen extends ConsumerWidget {
  const AdvisoryBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final async = ref.watch(advisoryBoardProvider);

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
          'Advisory Board',
          style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: colors.ink900),
        ),
      ),
      body: async.when(
        loading: () => _ShimmerGrid(colors: colors),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to load advisory board',
                  style: TextStyle(fontFamily: 'DMSans', color: colors.ink600)),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.invalidate(advisoryBoardProvider),
                child: Text('Retry',
                    style: TextStyle(
                        fontFamily: 'DMSans', color: colors.goldPrimary)),
              ),
            ],
          ),
        ),
        data: (members) {
          if (members.isEmpty) {
            return Center(
                child: Text('No advisory board members found',
                    style: TextStyle(
                        fontFamily: 'DMSans', color: colors.ink600)));
          }
          return Column(
            children: [
              // Header banner
              Container(
                margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [AppColors.navyDeep, colors.navyDeep.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people_outline_rounded,
                        color: Colors.white70, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('OUR ADVISORY BOARD',
                              style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 0.16,
                                  color: Colors.white70,
                                  fontFamily: 'DMSans')),
                          const SizedBox(height: 4),
                          Text(
                            '${members.length} Industry Expert${members.length != 1 ? 's' : ''}',
                            style: const TextStyle(
                                fontFamily: 'PlayfairDisplay',
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: members.length,
                  itemBuilder: (ctx, i) => _MemberCard(
                      member: members[i],
                      colors: colors,
                      onTap: () => _showMemberDetail(ctx, members[i], colors)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showMemberDetail(
      BuildContext context, AdvisoryBoardMember member, AppColorScheme colors) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MemberDetailSheet(member: member, colors: colors),
    );
  }
}

// ── Member grid card ──────────────────────────────────────────────────────────

class _MemberCard extends StatelessWidget {
  const _MemberCard(
      {required this.member, required this.colors, required this.onTap});
  final AdvisoryBoardMember member;
  final AppColorScheme colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.lineSoft),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.goldPrimary, width: 2),
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: colors.surfaceTertiary,
                child: member.firstImage.isNotEmpty
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: member.firstImage,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: colors.surfaceTertiary,
                          ),
                          errorWidget: (context, url, error) => Icon(
                              Icons.person_outline_rounded,
                              size: 32,
                              color: colors.ink400),
                        ),
                      )
                    : Icon(Icons.person_outline_rounded,
                        size: 32, color: colors.ink400),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              member.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: colors.ink900),
            ),
            const SizedBox(height: 4),
            Text(
              member.post,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 11,
                  color: colors.ink600),
            ),
            const Spacer(),
            Text('View Profile →',
                style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'DMSans',
                    fontWeight: FontWeight.w600,
                    color: colors.goldPrimary)),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

// ── Member detail bottom sheet ────────────────────────────────────────────────

class _MemberDetailSheet extends StatelessWidget {
  const _MemberDetailSheet({required this.member, required this.colors});
  final AdvisoryBoardMember member;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: colors.surfacePrimary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.lineSoft,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.goldPrimary, width: 3),
                ),
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: colors.surfaceTertiary,
                  child: member.firstImage.isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: member.firstImage,
                            width: 112,
                            height: 112,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: colors.surfaceTertiary,
                            ),
                            errorWidget: (context, url, error) => Icon(
                                Icons.person_outline_rounded,
                                size: 48,
                                color: colors.ink400),
                          ),
                        )
                      : Icon(Icons.person_outline_rounded,
                          size: 48, color: colors.ink400),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                member.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: colors.ink900),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surfaceTertiary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(member.post,
                    style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.ink600)),
              ),
            ),
            const SizedBox(height: 24),
            Divider(color: colors.lineSoft),
            const SizedBox(height: 16),
            Text('About',
                style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: colors.ink900)),
            const SizedBox(height: 8),
            Text(
              member.about.isNotEmpty
                  ? member.about
                  : 'Industry veteran contributing to the growth of Indian travel and tourism.',
              style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 14,
                  color: colors.ink600,
                  height: 1.7),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shimmer ───────────────────────────────────────────────────────────────────

class _ShimmerGrid extends StatelessWidget {
  const _ShimmerGrid({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: colors.surfaceTertiary,
      highlightColor: colors.surfaceCard,
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
