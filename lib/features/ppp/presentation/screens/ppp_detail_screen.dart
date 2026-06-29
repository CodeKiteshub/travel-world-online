import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/ppp_model.dart';
import '../providers/ppp_providers.dart';

class PPPDetailScreen extends ConsumerStatefulWidget {
  const PPPDetailScreen({super.key, required this.id, this.item});
  final String id;
  final PppItem? item;

  @override
  ConsumerState<PPPDetailScreen> createState() => _PPPDetailScreenState();
}

class _PPPDetailScreenState extends ConsumerState<PPPDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final item = widget.item;
    final heroImage = item?.firstImage ?? '';
    final boardName = item?.name ?? '';

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.navyDeep,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                tooltip: 'Directory',
                icon: const Icon(Icons.people_outline_rounded,
                    color: Colors.white70),
                onPressed: () => context.push(
                  '/ppp/${widget.id}/directory',
                  extra: boardName,
                ),
              ),
              TextButton(
                onPressed: () =>
                    context.push('/ppp/${widget.id}/register'),
                child: const Text('Register',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontFamily: 'DMSans')),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  heroImage.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: heroImage,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              ColoredBox(color: AppColors.navyDeep),
                        )
                      : ColoredBox(color: AppColors.navyDeep),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.2),
                          Colors.black.withValues(alpha: 0.65),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    bottom: 20,
                    right: 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          boardName,
                          style: const TextStyle(
                            fontFamily: 'PlayfairDisplay',
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            item?.isDomestic == true
                                ? 'Domestic'
                                : 'International',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontFamily: 'DMSans'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
                tabController: _tabController, colors: colors),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _PolicyTab(id: widget.id, colors: colors),
            _InvestmentTab(id: widget.id, colors: colors),
            _ResourcesTab(id: widget.id, colors: colors),
          ],
        ),
      ),
    );
  }

}

// ── Tab bar sticky header ─────────────────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate(
      {required this.tabController, required this.colors});
  final TabController tabController;
  final AppColorScheme colors;

  @override
  double get minExtent => 56;
  @override
  double get maxExtent => 56;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: colors.surfacePrimary,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceTertiary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Policy'),
            Tab(text: 'Investment'),
            Tab(text: 'Resources'),
          ],
          indicator: BoxDecoration(
            color: colors.surfaceCard,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 4)
            ],
          ),
          labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: 'DMSans'),
          unselectedLabelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: 'DMSans'),
          labelColor: colors.ink900,
          unselectedLabelColor: colors.ink600,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          padding: const EdgeInsets.all(4),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate old) => false;
}

// ── Policy tab ────────────────────────────────────────────────────────────────

class _PolicyTab extends ConsumerWidget {
  const _PolicyTab({required this.id, required this.colors});
  final String id;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(pppPoliciesProvider(id));
    return async.when(
      loading: () => _ShimmerList(colors: colors),
      error: (_, __) => _RetryError(
          message: 'Failed to load policies',
          onRetry: () => ref.invalidate(pppPoliciesProvider(id))),
      data: (policies) {
        if (policies.isEmpty) {
          return const Center(
              child: Text('No tourism policies available',
                  style: TextStyle(fontFamily: 'DMSans', fontSize: 14)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: policies.length,
          itemBuilder: (_, i) =>
              _ContentExpansionTile(
                title: policies[i].policyName,
                details: policies[i].policyDetails,
                colors: colors,
              ),
        );
      },
    );
  }
}

// ── Investment tab ────────────────────────────────────────────────────────────

class _InvestmentTab extends ConsumerWidget {
  const _InvestmentTab({required this.id, required this.colors});
  final String id;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(pppInvestmentsProvider(id));
    return async.when(
      loading: () => _ShimmerList(colors: colors),
      error: (_, __) => _RetryError(
          message: 'Failed to load investment opportunities',
          onRetry: () => ref.invalidate(pppInvestmentsProvider(id))),
      data: (investments) {
        if (investments.isEmpty) {
          return const Center(
              child: Text('No investment opportunities available',
                  style: TextStyle(fontFamily: 'DMSans', fontSize: 14)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: investments.length,
          itemBuilder: (_, i) =>
              _ContentExpansionTile(
                title: investments[i].opportunityName,
                details: investments[i].opportunityDetails,
                colors: colors,
              ),
        );
      },
    );
  }
}

// ── Shared expansion tile ─────────────────────────────────────────────────────

class _ContentExpansionTile extends StatelessWidget {
  const _ContentExpansionTile(
      {required this.title, required this.details, required this.colors});
  final String title;
  final String details;
  final AppColorScheme colors;

  String _stripHtml(String html) =>
      html.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll('&nbsp;', ' ').trim();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        border: Border.all(color: colors.lineSoft),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12))),
        collapsedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12))),
        title: Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              fontFamily: 'DMSans',
              color: colors.ink900),
        ),
        iconColor: colors.goldPrimary,
        collapsedIconColor: colors.ink400,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              _stripHtml(details),
              style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'DMSans',
                  color: colors.ink600,
                  height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Resources tab ─────────────────────────────────────────────────────────────

class _ResourcesTab extends ConsumerStatefulWidget {
  const _ResourcesTab({required this.id, required this.colors});
  final String id;
  final AppColorScheme colors;

  @override
  ConsumerState<_ResourcesTab> createState() => _ResourcesTabState();
}

class _ResourcesTabState extends ConsumerState<_ResourcesTab> {
  int _selected = 0;
  static const _labels = ['Videos', 'Photos', 'E-Brochures'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter chips
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _labels.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => setState(() => _selected = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: _selected == i
                      ? widget.colors.goldPrimary
                      : widget.colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                      color: _selected == i
                          ? widget.colors.goldPrimary
                          : widget.colors.lineSoft),
                ),
                child: Text(
                  _labels[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'DMSans',
                    fontWeight: FontWeight.w600,
                    color: _selected == i
                        ? Colors.white
                        : widget.colors.ink600,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: KeyedSubtree(
              key: ValueKey(_selected),
              child: _selected == 0
                  ? _VideosGrid(id: widget.id, colors: widget.colors)
                  : _selected == 1
                      ? _PhotosGrid(id: widget.id, colors: widget.colors)
                      : _PdfsGrid(id: widget.id, colors: widget.colors),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Videos grid ───────────────────────────────────────────────────────────────

class _VideosGrid extends ConsumerWidget {
  const _VideosGrid({required this.id, required this.colors});
  final String id;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(pppVideosProvider(id));
    return async.when(
      loading: () => _ShimmerGrid(colors: colors),
      error: (_, __) => _RetryError(
          message: 'Failed to load videos',
          onRetry: () => ref.invalidate(pppVideosProvider(id))),
      data: (videos) {
        if (videos.isEmpty) {
          return const Center(
              child: Text('No videos available',
                  style: TextStyle(fontFamily: 'DMSans')));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 16 / 10),
          itemCount: videos.length,
          itemBuilder: (_, i) => _VideoThumbnailCard(
              video: videos[i], colors: colors),
        );
      },
    );
  }
}

class _VideoThumbnailCard extends StatelessWidget {
  const _VideoThumbnailCard({required this.video, required this.colors});
  final PppVideo video;
  final AppColorScheme colors;

  Future<void> _launch() async {
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
            ColoredBox(color: colors.navyDeep),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
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
              child: Text(
                video.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'DMSans',
                    color: Colors.white,
                    height: 1.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Photos grid ───────────────────────────────────────────────────────────────

class _PhotosGrid extends ConsumerWidget {
  const _PhotosGrid({required this.id, required this.colors});
  final String id;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(pppImagesProvider(id));
    return async.when(
      loading: () => _ShimmerGrid(colors: colors),
      error: (_, __) => _RetryError(
          message: 'Failed to load photos',
          onRetry: () => ref.invalidate(pppImagesProvider(id))),
      data: (images) {
        // Flatten list of image lists into single list
        final allUrls = images.expand((img) => img.imageUrls).toList();
        if (allUrls.isEmpty) {
          return const Center(
              child: Text('No photos available',
                  style: TextStyle(fontFamily: 'DMSans')));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1),
          itemCount: allUrls.length,
          itemBuilder: (ctx, i) => GestureDetector(
            onTap: () => _showFullImage(ctx, allUrls[i]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: allUrls[i],
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) =>
                    Container(color: colors.surfaceTertiary,
                        child: Icon(Icons.broken_image_outlined,
                            color: colors.ink400)),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFullImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain),
            ),
            SafeArea(
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── PDFs grid ─────────────────────────────────────────────────────────────────

class _PdfsGrid extends ConsumerWidget {
  const _PdfsGrid({required this.id, required this.colors});
  final String id;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(pppPdfsProvider(id));
    return async.when(
      loading: () => _ShimmerList(colors: colors),
      error: (_, __) => _RetryError(
          message: 'Failed to load e-brochures',
          onRetry: () => ref.invalidate(pppPdfsProvider(id))),
      data: (pdfs) {
        if (pdfs.isEmpty) {
          return const Center(
              child: Text('No e-brochures available',
                  style: TextStyle(fontFamily: 'DMSans')));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pdfs.length,
          itemBuilder: (_, i) => _PdfCard(pdf: pdfs[i], colors: colors),
        );
      },
    );
  }
}

class _PdfCard extends StatelessWidget {
  const _PdfCard({required this.pdf, required this.colors});
  final PppPdf pdf;
  final AppColorScheme colors;

  Future<void> _openPdf() async {
    if (pdf.pdfUrls.isEmpty) return;
    final uri = Uri.parse(pdf.pdfUrls.first);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openPdf,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          border: Border.all(color: colors.lineSoft),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: pdf.thumbnail.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: pdf.thumbnail,
                      width: 56,
                      height: 72,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _pdfPlaceholder(),
                    )
                  : _pdfPlaceholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pdf.name,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          fontFamily: 'DMSans',
                          color: colors.ink900)),
                  if (pdf.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(pdf.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'DMSans',
                            color: colors.ink600)),
                  ],
                  const SizedBox(height: 8),
                  Text('Open PDF →',
                      style: TextStyle(
                          fontSize: 12,
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
  }

  Widget _pdfPlaceholder() => Container(
        width: 56,
        height: 72,
        color: colors.surfaceTertiary,
        child: Icon(Icons.picture_as_pdf_outlined,
            color: colors.ink400, size: 28),
      );
}

// ── Shared shimmer + error helpers ────────────────────────────────────────────

class _ShimmerList extends StatelessWidget {
  const _ShimmerList({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: colors.surfaceTertiary,
      highlightColor: colors.surfaceCard,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          height: 64,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _ShimmerGrid extends StatelessWidget {
  const _ShimmerGrid({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: colors.surfaceTertiary,
      highlightColor: colors.surfaceCard,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
            childAspectRatio: 16 / 10),
        itemCount: 6,
        itemBuilder: (_, __) => ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(color: Colors.white),
        ),
      ),
    );
  }
}

class _RetryError extends StatelessWidget {
  const _RetryError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message,
              style: const TextStyle(fontFamily: 'DMSans', fontSize: 14)),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: Text('Retry',
                style: TextStyle(
                    color: Theme.of(context)
                        .extension<AppColorScheme>()!
                        .goldPrimary)),
          ),
        ],
      ),
    );
  }
}
