import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/luxury_hotel_model.dart';

class LuxuryHotelDetailScreen extends StatefulWidget {
  const LuxuryHotelDetailScreen({super.key, required this.hotel});
  final LuxuryHotelModel hotel;

  @override
  State<LuxuryHotelDetailScreen> createState() =>
      _LuxuryHotelDetailScreenState();
}

class _LuxuryHotelDetailScreenState extends State<LuxuryHotelDetailScreen> {
  final PageController _pageCtrl = PageController();
  int _currentImage = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _launchWebsite() async {
    final raw = widget.hotel.website.trim();
    if (raw.isEmpty) return;
    final url = raw.startsWith('http') ? raw : 'https://$raw';
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final hotel = widget.hotel;
    final images = hotel.imageUrls;

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: CustomScrollView(
        slivers: [
          // ── Hero image with back button ────────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: colors.surfaceCard,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image carousel
                  if (images.isNotEmpty)
                    PageView.builder(
                      controller: _pageCtrl,
                      itemCount: images.length,
                      onPageChanged: (i) => setState(() => _currentImage = i),
                      itemBuilder: (_, i) => CachedNetworkImage(
                        imageUrl: images[i],
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: colors.surfaceTertiary),
                        errorWidget: (_, __, ___) => _NavyFallback(
                            colors: colors, name: hotel.name),
                      ),
                    )
                  else
                    _NavyFallback(colors: colors, name: hotel.name),

                  // Gradient overlay
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x33000000), Color(0xCC000000)],
                        stops: [0.0, 1.0],
                      ),
                    ),
                  ),

                  // LUXURY badge
                  Positioned(
                    top: 12,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.navyDeep,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: AppColors.goldPrimary.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 10, color: AppColors.goldPrimary),
                          const SizedBox(width: 4),
                          Text(
                            'LUXURY',
                            style: AppTypography.overline.copyWith(
                              color: AppColors.goldPrimary,
                              fontSize: 9,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Hotel name at bottom
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Text(
                      hotel.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        shadows: [
                          Shadow(color: Color(0x80000000), blurRadius: 8)
                        ],
                      ),
                      maxLines: 2,
                    ),
                  ),

                  // Page dots
                  if (images.length > 1)
                    Positioned(
                      bottom: 8,
                      right: 16,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          images.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: i == _currentImage ? 16 : 6,
                            height: 6,
                            margin: const EdgeInsets.only(left: 4),
                            decoration: BoxDecoration(
                              color: i == _currentImage
                                  ? AppColors.goldPrimary
                                  : Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location + address
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hotel.location.isNotEmpty)
                        _InfoRow(
                          icon: Icons.location_on_outlined,
                          text: hotel.location,
                          colors: colors,
                          bold: true,
                        ),
                      if (hotel.address.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _InfoRow(
                          icon: Icons.map_outlined,
                          text: hotel.address,
                          colors: colors,
                        ),
                      ],
                      if (hotel.title.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          hotel.title,
                          style: AppTypography.body.copyWith(
                            color: colors.ink600,
                            height: 1.5,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Divider
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 20),
                  child: Divider(color: colors.lineSoft),
                ),

                // About / Information
                if (hotel.information.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About',
                          style: AppTypography.heading
                              .copyWith(color: colors.ink900),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          hotel.information,
                          style: AppTypography.body.copyWith(
                            color: colors.ink600,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Divider(color: colors.lineSoft),
                  ),
                ],

                // Amenities
                if (hotel.amenities.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Amenities',
                          style: AppTypography.heading
                              .copyWith(color: colors.ink900),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: hotel.amenities
                              .map((a) => _AmenityChip(
                                    label: a,
                                    colors: colors,
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // CTA buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (hotel.website.isNotEmpty)
                        FilledButton.icon(
                          onPressed: _launchWebsite,
                          icon: const Icon(Icons.language_rounded, size: 18),
                          label: const Text('Visit Website'),
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.goldPrimary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      if (hotel.website.isNotEmpty)
                        const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.arrow_back_rounded,
                            size: 18, color: colors.ink900),
                        label: Text(
                          'Back to Hotels',
                          style: AppTypography.body
                              .copyWith(color: colors.ink900),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          side: BorderSide(color: colors.lineSoft),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    required this.colors,
    this.bold = false,
  });
  final IconData icon;
  final String text;
  final AppColorScheme colors;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: colors.ink400),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppTypography.body.copyWith(
              color: bold ? colors.ink900 : colors.ink600,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

class _AmenityChip extends StatelessWidget {
  const _AmenityChip({required this.label, required this.colors});
  final String label;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.lineSoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline_rounded,
              size: 12, color: colors.goldPrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style:
                AppTypography.caption.copyWith(color: colors.ink600),
          ),
        ],
      ),
    );
  }
}

class _NavyFallback extends StatelessWidget {
  const _NavyFallback({required this.colors, required this.name});
  final AppColorScheme colors;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.navyDeep, Color(0xFF1A3550)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hotel_rounded,
                size: 48, color: Colors.white.withValues(alpha: 0.4)),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
