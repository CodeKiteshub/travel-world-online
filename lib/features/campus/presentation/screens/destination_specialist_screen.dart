import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/campus_providers.dart';

class DestinationSpecialistScreen extends ConsumerWidget {
  const DestinationSpecialistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final async = ref.watch(destinationsProvider);

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      appBar: AppBar(
        backgroundColor: colors.surfacePrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.ink900),
          onPressed: () => context.pop(),
        ),
        title: Text('Destination Specialist',
            style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: colors.ink900)),
      ),
      body: async.when(
        loading: () => _ShimmerList(colors: colors),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to load destinations',
                  style: TextStyle(fontFamily: 'DMSans', color: colors.ink600)),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.invalidate(destinationsProvider),
                child: Text('Retry',
                    style: TextStyle(fontFamily: 'DMSans', color: colors.goldPrimary)),
              ),
            ],
          ),
        ),
        data: (destinations) {
          if (destinations.isEmpty) {
            return Center(
                child: Text('No destinations available',
                    style: TextStyle(fontFamily: 'DMSans', color: colors.ink600)));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
            itemCount: destinations.length,
            itemBuilder: (_, i) {
              final dest = destinations[i];
              return GestureDetector(
                onTap: () => context.push(
                    '/destination-specialist/${dest.id}',
                    extra: dest.label),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colors.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.lineSoft),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(color: colors.navyDeep),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.4),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 16,
                                bottom: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.public_rounded,
                                          color: Colors.white70, size: 14),
                                      const SizedBox(width: 4),
                                      const Text('Destination',
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontFamily: 'DMSans',
                                              color: Colors.white70)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  dest.label,
                                  style: TextStyle(
                                      fontFamily: 'PlayfairDisplay',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                      color: colors.ink900),
                                ),
                              ),
                              Text('Explore →',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontFamily: 'DMSans',
                                      fontWeight: FontWeight.w600,
                                      color: colors.goldPrimary)),
                            ],
                          ),
                        ),
                      ],
                    ),
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

class _ShimmerList extends StatelessWidget {
  const _ShimmerList({required this.colors});
  final AppColorScheme colors;
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: colors.surfaceTertiary,
      highlightColor: colors.surfaceCard,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          height: 220,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
