import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/campus_providers.dart';

class DestSubSubCategoryScreen extends ConsumerWidget {
  const DestSubSubCategoryScreen(
      {super.key, required this.catId, required this.subCatId});
  final String catId;
  final String subCatId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final key = '$catId|$subCatId';
    final async = ref.watch(destSubSubCategoriesProvider(key));

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      appBar: AppBar(
        backgroundColor: colors.surfacePrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.ink900),
          onPressed: () => context.pop(),
        ),
        title: Text('Select Circuit',
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
            Text('Failed to load circuits',
                style: TextStyle(fontFamily: 'DMSans', color: colors.ink600)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () =>
                  ref.invalidate(destSubSubCategoriesProvider(key)),
              child: Text('Retry',
                  style:
                      TextStyle(fontFamily: 'DMSans', color: colors.goldPrimary)),
            ),
          ]),
        ),
        data: (subSubCats) {
          // If no sub-sub-categories, go straight to the video screen
          if (subSubCats.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.pushReplacement(
                  '/destination-specialist/$catId/$subCatId/_');
            });
            return const SizedBox.shrink();
          }
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 16 / 10),
            itemCount: subSubCats.length,
            itemBuilder: (_, i) {
              final item = subSubCats[i];
              return GestureDetector(
                onTap: () => context.push(
                    '/destination-specialist/$catId/$subCatId/${item.id}'),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      item.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: item.imageUrl,
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
                              Colors.black.withValues(alpha: 0.65),
                            ],
                          ),
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
                              item.label,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'DMSans',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  height: 1.3),
                            ),
                            const SizedBox(height: 2),
                            Text('Explore →',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontFamily: 'DMSans',
                                    fontWeight: FontWeight.w600,
                                    color: colors.goldPrimary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
