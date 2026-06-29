import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/data/models/article_model.dart';
import '../providers/news_providers.dart';
import '../../data/datasources/news_remote_datasource.dart';

class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({super.key});

  @override
  ConsumerState<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends ConsumerState<NewsScreen> {
  static const _categories = <String>[
    'All',
    'Hotels',
    'Associations',
    'Airlines',
    'Tourism Boards',
    'Destination',
  ];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(newsFeedProvider.notifier).loadMore();
    }
  }

  void _selectCategory(String category) {
    final catId = category == 'All'
        ? null
        : NewsRemoteDatasource.categoryIds[category];
    ref.read(newsFeedProvider.notifier).setCategory(catId);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final feed = ref.watch(newsFeedProvider);

    // Derive selected display name from state
    final selectedDisplay = feed.selectedCategory == null
        ? 'All'
        : NewsRemoteDatasource.categoryIds.entries
            .firstWhere(
              (e) => e.value == feed.selectedCategory,
              orElse: () => const MapEntry('All', ''),
            )
            .key;

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      appBar: AppBar(
        backgroundColor: colors.surfacePrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: colors.ink900,
          onPressed: () => context.pop(),
        ),
        title: Text(
          'News',
          style: AppTypography.titleMedium.copyWith(color: colors.ink900),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            color: colors.ink900,
            onPressed: () {},
          ),
        ],
      ),
      body: feed.articles.isEmpty && feed.isLoading
          ? const Center(child: CircularProgressIndicator())
          : feed.articles.isEmpty && feed.error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Failed to load news',
                          style: TextStyle(color: colors.ink600)),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () =>
                            ref.read(newsFeedProvider.notifier).loadMore(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  // +3 = hero + category pills + top loading bar slot
                  itemCount: feed.articles.length + 3,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _HeroCard(
                        article: feed.articles.isNotEmpty
                            ? feed.articles.first
                            : null,
                        colors: colors,
                      );
                    }
                    if (index == 1) {
                      return _CategoryPills(
                        categories: _categories,
                        selected: selectedDisplay,
                        onSelect: _selectCategory,
                        colors: colors,
                      );
                    }
                    if (index == 2) {
                      return feed.isLoading
                          ? LinearProgressIndicator(
                              minHeight: 2,
                              backgroundColor:
                                  colors.lineSoft,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  colors.ink900),
                            )
                          : const SizedBox.shrink();
                    }
                    final articleIndex = index - 3;
                    if (articleIndex >= feed.articles.length) {
                      return feed.isLoading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child:
                                  Center(child: CircularProgressIndicator()),
                            )
                          : const SizedBox(height: 80);
                    }
                    return _NewsCard(
                      article: feed.articles[articleIndex],
                      colors: colors,
                    );
                  },
                ),
    );
  }
}

// ── Hero (Editor's Pick) ───────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final Article? article;
  final AppColorScheme colors;

  const _HeroCard({required this.article, required this.colors});

  @override
  Widget build(BuildContext context) {
    final imgUrl = article?.firstImage ?? '';
    final title =
        article?.title ?? 'Air India Unveils Maharaja Lounge at San Francisco Airport';
    final meta = article?.sourceMeta ?? 'GNN Bureau · 2h ago';

    return GestureDetector(
      onTap: article == null
          ? null
          : () => context.push(RouteNames.newsArticleDetail, extra: article),
      child: Container(
        height: 250,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colors.surfaceTertiary,
        image: imgUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(imgUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xCC0D1B2A)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC9A84C),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "✦ Editor's Pick",
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.08,
                        color: Color(0xFF1A1A1A)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                      fontFamily: 'Playfair Display',
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: Colors.white,
                      height: 1.2),
                ),
                const SizedBox(height: 4),
                Text(meta,
                    style: const TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}

// ── Category Pills ─────────────────────────────────────────────────────────
class _CategoryPills extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelect;
  final AppColorScheme colors;

  const _CategoryPills({
    required this.categories,
    required this.selected,
    required this.onSelect,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: categories.map((cat) {
              final bool isSelected = cat == selected;
              return GestureDetector(
                onTap: () => onSelect(cat),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? colors.ink900 : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? colors.ink900 : colors.lineSoft,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected
                          ? colors.surfacePrimary
                          : colors.ink600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}

// ── Feed Card ──────────────────────────────────────────────────────────────
class _NewsCard extends StatelessWidget {
  final Article article;
  final AppColorScheme colors;

  const _NewsCard({required this.article, required this.colors});

  @override
  Widget build(BuildContext context) {
    final categoryName = article.category.name;
    final abbrev = categoryName.length > 7
        ? '${categoryName.substring(0, 6).toUpperCase()}.'
        : categoryName.toUpperCase();
    final hasAudio = article.firstAudioUrl != null;

    return GestureDetector(
      onTap: () => context.push(RouteNames.newsArticleDetail, extra: article),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surfaceSecondary,
          border: Border.all(color: colors.lineSoft),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: 88,
                  height: 74,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: colors.surfaceTertiary,
                    image: article.firstImage.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(article.firstImage),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      abbrev,
                      style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.1,
                          color: Colors.white),
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
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.38,
                        color: colors.ink900),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          article.sourceMeta,
                          style: TextStyle(fontSize: 11, color: colors.ink400),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasAudio)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.volume_up_rounded,
                                size: 11, color: colors.goldPrimary),
                            const SizedBox(width: 3),
                            Text(
                              'Listen',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: colors.goldPrimary,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
