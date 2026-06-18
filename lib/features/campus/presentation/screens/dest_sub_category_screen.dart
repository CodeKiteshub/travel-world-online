import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/campus_providers.dart';

class DestSubCategoryScreen extends ConsumerWidget {
  const DestSubCategoryScreen(
      {super.key, required this.catId, required this.catLabel});
  final String catId;
  final String catLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final async = ref.watch(destSubCategoriesProvider(catId));

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      appBar: AppBar(
        backgroundColor: colors.surfacePrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.ink900),
          onPressed: () => context.pop(),
        ),
        title: Text(catLabel,
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
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: 5,
            itemBuilder: (_, __) => Container(
                height: 80,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12))),
          ),
        ),
        error: (_, __) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Failed to load sub-categories',
                style: TextStyle(fontFamily: 'DMSans', color: colors.ink600)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => ref.invalidate(destSubCategoriesProvider(catId)),
              child: Text('Retry',
                  style: TextStyle(fontFamily: 'DMSans', color: colors.goldPrimary)),
            ),
          ]),
        ),
        data: (subCats) {
          if (subCats.isEmpty) {
            return Center(
                child: Text('No sub-categories available',
                    style: TextStyle(fontFamily: 'DMSans', color: colors.ink600)));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
            itemCount: subCats.length,
            itemBuilder: (_, i) {
              final sub = subCats[i];
              return GestureDetector(
                onTap: () => context.push(
                    '/destination-specialist/$catId/${sub.id}',
                    extra: sub.label),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: colors.surfaceCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.lineSoft),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(14)),
                        child: sub.imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: sub.imageUrl,
                                width: 88,
                                height: 80,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Container(
                                    width: 88,
                                    height: 80,
                                    color: colors.surfaceTertiary),
                              )
                            : Container(
                                width: 88,
                                height: 80,
                                color: colors.surfaceTertiary,
                                child: Icon(Icons.landscape_outlined,
                                    color: colors.ink400, size: 32)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(sub.label,
                                  style: TextStyle(
                                      fontFamily: 'PlayfairDisplay',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: colors.ink900)),
                              const SizedBox(height: 4),
                              Text('View Circuits →',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'DMSans',
                                      fontWeight: FontWeight.w600,
                                      color: colors.goldPrimary)),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Icon(Icons.chevron_right_rounded,
                            color: colors.ink400),
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
