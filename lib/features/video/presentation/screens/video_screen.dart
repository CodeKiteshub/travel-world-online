import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key});

  // Hard‑coded demo data extracted from the HTML design.
  static const _heroImage =
      'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=900&q=80';
  static const _heroTitle = 'Sri Lanka Concludes, TAFI Western India';
  static const _heroSub = 'Travel World Online · Interviews';
  static const _heroDuration = '2:40';

  static const _categories = [
    {'label': 'News', 'color': Color(0xFF0D1B2A), 'bg': Color(0xFF1A3850)},
    {'label': 'Interviews', 'color': Color(0xFFC9A84C), 'bg': Color(0xFFE8D08A)},
    {'label': 'Destinations', 'color': Color(0xFF2D7A4F), 'bg': Color(0xFF1A5036)},
  ];

  static const _videos = [
    {
      'thumb': 'https://images.unsplash.com/photo-1587825140708-dfaf18c4f5a4?w=400&q=80',
      'duration': '8:12',
      'title': 'CM Rekha Gupta Speaks on Hospitality Reforms | Felicitation 2025',
      'author': 'Travel World · 3d ago',
    },
    {
      'thumb': 'https://images.unsplash.com/photo-1566837945700-30057527ade0?w=400&q=80',
      'duration': '5:44',
      'title': 'Kashmir is Ready Again! Tourism Revival Event Sparks Energy',
      'author': 'Travel World · 5d ago',
    },
    {
      'thumb': 'https://images.unsplash.com/photo-1577717903315-1691ae25ab3f?w=400&q=80',
      'duration': '12:08',
      'title': "Manoj Tiwari's Inspiring Speech at World MSME Day 2025",
      'author': 'Travel World · 1w ago',
    },
    {
      'thumb': 'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=400&q=80',
      'duration': '6:32',
      'title': 'World MSME Day 2025 | WASME Panel Discussion at Bharat Mandapam',
      'author': 'Travel World · 1w ago',
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
        title: Text('Video', style: AppTypography.titleMedium.copyWith(color: colors.ink900)),
      ),
      body: ListView(
        children: [
          // Hero video
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
                // dark overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black45,
                  ),
                ),
                // play button
                Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow, size: 32, color: Colors.white),
                  ),
                ),
                // info overlay
                Positioned(
                  bottom: 12,
                  left: 14,
                  right: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _heroTitle,
                        style: const TextStyle(fontFamily: 'Playfair Display', fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _heroSub,
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                // duration badge
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_heroDuration, style: const TextStyle(fontSize: 11, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
          // Category cards
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Categories', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: _categories.map((cat) {
                return Container(
                  width: 110,
                  height: 72,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [cat['bg'] as Color, (cat['bg'] as Color).withValues(alpha: 0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black54],
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          cat['label'] as String,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 22),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Recent', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 8),
          // Video list items
          ..._videos.map((v) => _VideoItem(video: v, colors: colors)).toList(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _VideoItem extends StatelessWidget {
  final Map<String, String> video;
  final AppColorScheme colors;
  const _VideoItem({required this.video, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 130,
                    height: 78,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(video['thumb']!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        video['duration']!,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video['title']!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      video['author']!,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, indent: 20, endIndent: 20, color: Color(0xFFE8E5DC)),
      ],
    );
  }
}
