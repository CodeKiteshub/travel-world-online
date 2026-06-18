import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/campus_models.dart';
import '../providers/campus_providers.dart';

class DestVideoScreen extends ConsumerWidget {
  const DestVideoScreen(
      {super.key,
      required this.catId,
      required this.subCatId,
      required this.subSubCatId});
  final String catId;
  final String subCatId;
  final String subSubCatId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final key = '$catId|$subCatId|$subSubCatId';
    final async = ref.watch(destVideosProvider(key));

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      appBar: AppBar(
        backgroundColor: colors.surfacePrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.ink900),
          onPressed: () => context.pop(),
        ),
        title: Text('Videos',
            style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: colors.ink900)),
      ),
      body: async.when(
        loading: () => Shimmer.fromColors(
          baseColor: colors.surfaceTertiary,
          highlightColor: colors.surfaceCard,
          child: GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 16 / 10),
            itemCount: 6,
            itemBuilder: (_, __) => ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(color: Colors.white)),
          ),
        ),
        error: (_, __) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Failed to load videos',
                style: TextStyle(fontFamily: 'DMSans', color: colors.ink600)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => ref.invalidate(destVideosProvider(key)),
              child: Text('Retry',
                  style: TextStyle(fontFamily: 'DMSans', color: colors.goldPrimary)),
            ),
          ]),
        ),
        data: (videos) {
          if (videos.isEmpty) {
            return Center(
                child: Text('No videos available',
                    style: TextStyle(fontFamily: 'DMSans', color: colors.ink600)));
          }
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 16 / 10),
            itemCount: videos.length,
            itemBuilder: (_, i) =>
                _DestVideoCard(video: videos[i], colors: colors),
          );
        },
      ),
    );
  }
}

class _DestVideoCard extends StatelessWidget {
  const _DestVideoCard({required this.video, required this.colors});
  final DestVideo video;
  final AppColorScheme colors;

  Future<void> _launch() async {
    if (video.videoUrl.isEmpty) return;
    final uri = Uri.parse(video.videoUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launch,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            video.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: video.imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                        Container(color: colors.navyDeep),
                  )
                : Container(color: colors.navyDeep),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),
            Center(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.goldPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 22),
              ),
            ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    video.heading,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'DMSans',
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.3),
                  ),
                  if (video.place.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      video.place,
                      style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'DMSans',
                          color: Colors.white.withValues(alpha: 0.7)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
