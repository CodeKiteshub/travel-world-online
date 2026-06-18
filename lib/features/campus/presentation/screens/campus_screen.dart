import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/campus_providers.dart';

class CampusScreen extends ConsumerWidget {
  const CampusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;

    final advisoryAsync = ref.watch(advisoryBoardProvider);
    final coursesAsync = ref.watch(skillCoursesProvider);
    final destAsync = ref.watch(destinationsProvider);

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
          'Campus',
          style: AppTypography.titleMedium.copyWith(color: colors.ink900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: [
          // Welcome banner
          Container(
            margin:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [colors.navyDeep, const Color(0xFF1A3850)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TRAVEL BUSINESS CAMPUS',
                  style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 0.16,
                      color: Colors.white70),
                ),
                SizedBox(height: 6),
                Text(
                  'Upskill Your Travel Expertise',
                  style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: Colors.white),
                ),
                SizedBox(height: 6),
                Text(
                  'Learn from industry leaders, master destinations, and grow your professional skills.',
                  style: TextStyle(
                      fontSize: 12, color: Colors.white70, height: 1.5),
                ),
              ],
            ),
          ),

          // Advisory Board card
          GestureDetector(
            onTap: () => context.push(RouteNames.advisoryBoard),
            child: advisoryAsync.when(
              loading: () => _CampusCard(
                icon: Icons.people,
                iconBg: colors.surfaceSecondary,
                iconColor: colors.ink900,
                title: 'Advisory Board',
                desc:
                    'Industry veterans guiding the future of Indian travel and tourism.',
                count: 'Loading…',
                link: 'View All →',
                colors: colors,
              ),
              error: (_, __) => _CampusCard(
                icon: Icons.people,
                iconBg: colors.surfaceSecondary,
                iconColor: colors.ink900,
                title: 'Advisory Board',
                desc:
                    'Industry veterans guiding the future of Indian travel and tourism.',
                count: 'Experts',
                link: 'View All →',
                colors: colors,
              ),
              data: (members) {
                final featured =
                    members.isNotEmpty ? members.first : null;
                return _CampusCard(
                  icon: Icons.people,
                  iconBg: colors.surfaceSecondary,
                  iconColor: colors.ink900,
                  title: 'Advisory Board',
                  desc:
                      'Industry veterans guiding the future of Indian travel and tourism.',
                  count: '${members.length} Expert${members.length != 1 ? 's' : ''}',
                  link: 'View All →',
                  colors: colors,
                  extra: featured != null
                      ? _FeaturedMember(member: featured, colors: colors)
                      : null,
                );
              },
            ),
          ),

          // Destination Specialist card
          GestureDetector(
            onTap: () => context.push(RouteNames.destinationSpecialist),
            child: destAsync.when(
              loading: () => _CampusCard(
                icon: Icons.public,
                iconBg: colors.infoBg,
                iconColor: colors.navyDeep,
                title: 'Destination Specialist',
                desc:
                    'Master India, Canada, Nepal and more. Circuits include Buddhist Circuit, Golden Triangle, Royal Rajasthan.',
                count: 'Loading…',
                link: 'Explore →',
                colors: colors,
              ),
              error: (_, __) => _CampusCard(
                icon: Icons.public,
                iconBg: colors.infoBg,
                iconColor: colors.navyDeep,
                title: 'Destination Specialist',
                desc:
                    'Master India, Canada, Nepal and more. Circuits include Buddhist Circuit, Golden Triangle, Royal Rajasthan.',
                count: '5+ Circuits',
                link: 'Explore →',
                colors: colors,
              ),
              data: (dests) => _CampusCard(
                icon: Icons.public,
                iconBg: colors.infoBg,
                iconColor: colors.navyDeep,
                title: 'Destination Specialist',
                desc:
                    'Master India, Canada, Nepal and more. Circuits include Buddhist Circuit, Golden Triangle, Royal Rajasthan.',
                count: '${dests.length} Destination${dests.length != 1 ? 's' : ''}',
                link: 'Explore →',
                colors: colors,
              ),
            ),
          ),

          // Skill Development card
          GestureDetector(
            onTap: () => context.push(RouteNames.skillDevelopment),
            child: coursesAsync.when(
              loading: () => _CampusCard(
                icon: Icons.school,
                iconBg: colors.warningBg,
                iconColor: colors.warning,
                title: 'Skill Development',
                desc:
                    'Practical courses: GST for tour operators, news capsule creation, and business fundamentals.',
                count: 'Loading…',
                link: 'Start Learning →',
                colors: colors,
              ),
              error: (_, __) => _CampusCard(
                icon: Icons.school,
                iconBg: colors.warningBg,
                iconColor: colors.warning,
                title: 'Skill Development',
                desc:
                    'Practical courses: GST for tour operators, news capsule creation, and business fundamentals.',
                count: 'Courses Available',
                link: 'Start Learning →',
                colors: colors,
              ),
              data: (courses) => _CampusCard(
                icon: Icons.school,
                iconBg: colors.warningBg,
                iconColor: colors.warning,
                title: 'Skill Development',
                desc:
                    'Practical courses: GST for tour operators, news capsule creation, and business fundamentals.',
                count: '${courses.length} Course${courses.length != 1 ? 's' : ''} Available',
                link: 'Start Learning →',
                colors: colors,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Featured advisory member preview ──────────────────────────────────────
class _FeaturedMember extends StatelessWidget {
  final dynamic member;
  final AppColorScheme colors;

  const _FeaturedMember({required this.member, required this.colors});

  @override
  Widget build(BuildContext context) {
    final imgUrl = member.firstImage as String;
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: colors.surfacePrimary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: colors.surfaceTertiary,
            backgroundImage:
                imgUrl.isNotEmpty ? NetworkImage(imgUrl) : null,
            child: imgUrl.isEmpty
                ? Icon(Icons.person, color: colors.ink400, size: 18)
                : null,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.name as String,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: colors.ink900),
              ),
              Text(
                member.post as String,
                style:
                    TextStyle(fontSize: 10, color: colors.ink600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Module card ────────────────────────────────────────────────────────────
class _CampusCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String desc;
  final String? count;
  final String? link;
  final Widget? extra;
  final AppColorScheme colors;

  const _CampusCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.desc,
    this.count,
    this.link,
    this.extra,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        border: Border.all(color: colors.lineSoft),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: colors.ink900),
                ),
                const SizedBox(height: 4),
                Text(desc,
                    style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: colors.ink600)),
                if (extra != null) extra!,
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(count ?? '',
                        style: TextStyle(
                            fontSize: 12,
                            color: colors.ink400)),
                    Text(link ?? '',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.goldPrimary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
