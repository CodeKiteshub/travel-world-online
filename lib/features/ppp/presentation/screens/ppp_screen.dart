import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class PPPScreen extends StatelessWidget {
  const PPPScreen({super.key});

  // Hard‑coded demo data extracted from the HTML design.
  static const _segments = ['International', 'Domestic'];
  static const _cards = [
    {
      'image': 'https://images.unsplash.com/photo-1555862124-94036092ab14?w=800&q=80',
      'tag': 'International',
      'name': 'Saint Petersburg',
      'info': 'Imperial Russian capital. World-class museums, palaces, canals and white nights. Major destination for cultural tourism.',
      'pills': ['Tourism Policy', 'Investment', 'Resources'],
    },
    {
      'image': 'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=800&q=80',
      'tag': 'Domestic',
      'name': 'Chhattisgarh Tourism',
      'info': 'Undiscovered India. Adventure parks, tribal heritage, wildlife sanctuaries and eco‑tourism circuits.',
      'pills': ['Tourism Policy', 'Hotels', 'Adventure', 'Film Tourism'],
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
        title: Text('Tourism Boards', style: AppTypography.titleMedium.copyWith(color: colors.ink900)),
      ),
      body: ListView(
        children: [
          // Segmented control placeholder (static for now)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: _segments.map((seg) {
                final bool selected = seg == _segments[0];
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
                        seg,
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
          // Search bar placeholder
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.ink400),
              ),
              child: Row(
                children: const [
                  Icon(Icons.search, size: 20, color: Color(0xFF9E9E9E)),
                  SizedBox(width: 8),
                  Expanded(child: Text('Search tourism boards...', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Cards
          ..._cards.map((c) => _PPPCard(card: c, colors: colors)).toList(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _PPPCard extends StatelessWidget {
  final Map<String, dynamic> card;
  final AppColorScheme colors;
  const _PPPCard({required this.card, required this.colors});

  @override
  Widget build(BuildContext context) {
    final List<String> pills = List<String>.from(card['pills'] as List);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfacePrimary,
        border: Border.all(color: colors.ink400),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with tag
          Stack(
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  image: DecorationImage(
                    image: NetworkImage(card['image'] as String),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(card['tag'] as String, style: const TextStyle(fontSize: 10, color: Colors.white)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card['name'] as String, style: const TextStyle(fontFamily: 'Playfair Display', fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF1A1A1A))),
                const SizedBox(height: 6),
                Text(card['info'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF6E6E6E))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: pills.map((p) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.themeBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(p, style: const TextStyle(fontSize: 10, color: Color(0xFF1A3850))),
                  )).toList(),
                ),
                const SizedBox(height: 12),
                Text('Explore Board →', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFC9A84C))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
