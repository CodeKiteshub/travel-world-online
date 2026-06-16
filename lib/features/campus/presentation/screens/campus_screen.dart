import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class CampusScreen extends StatelessWidget {
  const CampusScreen({super.key});

  // Hard‑coded demo data extracted from the HTML design.
  static const _bannerTitle = 'Upskill Your Travel Expertise';
  static const _bannerSubtitle =
      'Learn from industry leaders, master destinations, and grow your professional skills.';

  static const _advisory = {
    'expertName': 'Zia Siddiqui',
    'expertRole': '44 yrs in Hospitality \u00b7 Cornell',
    'expertImg': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&q=80',
    'title': 'Advisory Board',
    'desc': 'Industry veterans guiding the future of Indian travel and tourism.',
    'count': '6 Experts',
    'link': 'View All \u2192',
  };

  static const _destination = {
    'title': 'Destination Specialist',
    'desc': 'Master India, Canada, Nepal and more. Circuits include Buddhist Circuit, Golden Triangle, Royal Rajasthan.',
    'count': '3 Countries \u00b7 5+ Circuits',
    'link': 'Explore \u2192',
  };

  static const _skillDev = {
    'title': 'Skill Development',
    'desc': 'Practical courses: GST for tour operators, news capsule creation, and business fundamentals.',
    'count': '3 Courses Available',
    'link': 'Start Learning \u2192',
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      appBar: AppBar(
        backgroundColor: colors.surfacePrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: colors.ink900,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Campus', style: AppTypography.titleMedium.copyWith(color: colors.ink900)),
      ),
      body: ListView(
        children: [
          // Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF0D1B2A), Color(0xFF1A3850)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('TRAVEL BUSINESS CAMPUS', style: TextStyle(fontSize: 10, letterSpacing: 0.16, color: Colors.white70)),
                SizedBox(height: 6),
                Text('Upskill Your Travel Expertise', style: TextStyle(fontFamily: 'Playfair Display', fontWeight: FontWeight.w700, fontSize: 22, color: Colors.white)),
                SizedBox(height: 6),
                Text('Learn from industry leaders, master destinations, and grow your professional skills.', style: TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
          // Advisory Board Card
          _CampusCard(
            icon: Icons.people,
            iconBg: colors.surfaceSecondary,
            title: _advisory['title'] as String,
            desc: _advisory['desc'] as String,
            extra: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(_advisory['expertImg'] as String),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_advisory['expertName'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF1A1A1A))),
                    Text(_advisory['expertRole'] as String, style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
                  ],
                ),
              ],
            ),
            count: _advisory['count'] as String,
            link: _advisory['link'] as String,
            colors: colors,
          ),
          // Destination Specialist Card
          _CampusCard(
            icon: Icons.public,
            iconBg: colors.infoBg,
            title: _destination['title'] as String,
            desc: _destination['desc'] as String,
            count: _destination['count'] as String,
            link: _destination['link'] as String,
            colors: colors,
          ),
          // Skill Development Card
          _CampusCard(
            icon: Icons.school,
            iconBg: colors.warningBg,
            title: _skillDev['title'] as String,
            desc: _skillDev['desc'] as String,
            count: _skillDev['count'] as String,
            link: _skillDev['link'] as String,
            colors: colors,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _CampusCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String desc;
  final Widget? extra;
  final String? count;
  final String? link;
  final AppColorScheme colors;

  const _CampusCard({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.desc,
    this.extra,
    this.count,
    this.link,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfacePrimary,
        border: Border.all(color: colors.ink400),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: colors.ink900, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontFamily: 'Playfair Display', fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF1A1A1A))),
                    const SizedBox(height: 4),
                    Text(desc, style: const TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF6E6E6E))),
                  ],
                ),
              ),
            ],
          ),
          if (extra != null) ...[
            const SizedBox(height: 12),
            extra!,
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(count ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
              Text(link ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFC9A84C))),
            ],
          ),
        ],
      ),
    );
  }
}
