import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  // Hard‑coded demo data extracted from the HTML design.
  static const _categories = ['Browse Jobs', 'Post Resume'];
  static const _jobs = [
    {
      'title': 'Tour Operations Manager',
      'company': 'Travel Corp India · New Delhi',
      'type': 'Full-time',
      'exp': '5+ yrs',
      'mode': 'Hybrid',
      'time': '2h ago · 12 applicants',
      'salary': '₹8–12 LPA',
    },
    {
      'title': 'Visa Executive',
      'company': 'Global Visa Services · Mumbai',
      'type': 'Full-time',
      'exp': '2+ yrs',
      'mode': 'On-site',
      'time': '5h ago · 28 applicants',
      'salary': '₹4–6 LPA',
    },
    {
      'title': 'Business Development Executive',
      'company': 'Holiday Planet · Bangalore',
      'type': 'Full-time',
      'exp': '3+ yrs',
      'mode': 'Hybrid',
      'time': '1d ago · 45 applicants',
      'salary': '₹6–9 LPA',
    },
    {
      'title': 'Ticketing Executive',
      'company': 'Fly High Travels · Mumbai',
      'type': 'Full-time',
      'exp': '1+ yrs',
      'mode': 'On-site',
      'time': '2d ago · 64 applicants',
      'salary': '₹3–4.5 LPA',
    },
  ];

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
        title: Text('Jobs', style: AppTypography.titleMedium.copyWith(color: colors.ink900)),
      ),
      body: ListView(
        children: [
          // Segmented control (static, first selected)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: _categories.map((cat) {
                final bool selected = cat == _categories[0];
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? colors.surfacePrimary : colors.surfaceTertiary,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: selected ? [BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
                    ),
                    child: Center(
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                          color: selected ? colors.ink900 : colors.ink600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Job cards
          ..._jobs.map((j) => _JobCard(job: j, colors: colors)).toList(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final Map<String, String> job;
  final AppColorScheme colors;
  const _JobCard({required this.job, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfacePrimary,
        border: Border.all(color: colors.ink400),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: title & company + bookmark icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job['title']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
                    const SizedBox(height: 3),
                    Text(job['company']!, style: const TextStyle(fontSize: 12, color: Color(0xFF6E6E6E))),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.ink400),
                  color: colors.surfacePrimary,
                ),
                child: Icon(Icons.bookmark_border, color: colors.ink600, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Tags row
          Wrap(
            spacing: 6,
            children: [
              _Tag(text: job['type']!),
              _Tag(text: job['exp']!),
              _Tag(text: job['mode']!),
            ],
          ),
          const SizedBox(height: 12),
          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(job['time']!, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
              Text(job['salary']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFC9A84C))),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF9E9E9E)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
    );
  }
}
