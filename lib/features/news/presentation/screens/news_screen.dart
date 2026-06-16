import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  // Hard‑coded data extracted from the HTML design for demonstration.
  static const _heroImage =
      'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=900&q=80';
  static const _heroTitle =
      'Air India Unveils Maharaja Lounge at San Francisco Airport';
  static const _heroMeta = 'GNN Bureau · 2h ago · 4 min read';

  static const _categories = [
    'All',
    'Hotels',
    'Associations',
    'Airlines',
    'Tourism Boards',
    'Destination',
  ];

  static const _feed = [
    {
      'image':
          'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=300&q=80',
      'category': 'TOURISM',
      'title':
          'APTM 2026 Press Conference: Andhra Pradesh Tourism Minister Outlines Plans',
      'src': 'GNN · 14 Feb, 7:38 AM',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=300&q=80',
      'category': 'EVENTS',
      'title': 'GBTA India Summit 2025 Sets New Benchmark for Business Travel',
      'src': 'Travel World · 6 Dec, 8:17 AM',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1542039940-04e2c4e2b14e?w=300&q=80',
      'category': 'HOTELS',
      'title': 'Rotana Joins WTTC as Regional Member to Foster Sustainable Growth',
      'src': 'GNN · 5 Dec, 4:36 AM',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1569154941061-e231b4725ef1?w=300&q=80',
      'category': 'ASSOC.',
      'title': "TAAI Hosts First NR Members Meet at Prime Minister's Museum",
      'src': 'GNN · 7 Oct, 10:24 PM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final textTheme = Theme.of(context).textTheme;
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
        title: Text('News', style: AppTypography.titleMedium.copyWith(color: colors.ink900)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            color: colors.ink900,
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          // Hero
          Container(
            height: 250,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: NetworkImage(_heroImage),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                // gradient overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xFF0D1B2A)],
                    ),
                  ),
                ),
                // content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC9A84C),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "✦ Editor's Pick",
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.08, color: Color(0xFF1A1A1A)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _heroTitle,
                        style: const TextStyle(fontFamily: 'Playfair Display', fontWeight: FontWeight.w700, fontSize: 22, color: Colors.white, height: 1.2),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _heroMeta,
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Category pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: _categories.map((cat) {
                final bool selected = cat == 'All';
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? colors.ink900 : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colors.ink600),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected ? colors.surfacePrimary : colors.ink600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),
          // Feed cards
          ..._feed.map((item) => _NewsCard(item: item, colors: colors)).toList(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final Map<String, String> item;
  final AppColorScheme colors;
  const _NewsCard({required this.item, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfacePrimary,
        border: Border.all(color: colors.ink400),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Stack(
            children: [
              Container(
                width: 88,
                height: 74,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(item['image']!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item['category']!,
                    style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600, letterSpacing: 0.1, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          // Body
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title']!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.38, color: Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['src']!,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
                    ),
                    Icon(Icons.share, size: 16, color: const Color(0xFF9E9E9E)),
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
