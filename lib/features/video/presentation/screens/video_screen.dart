import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/video_models.dart';
import '../providers/video_providers.dart';

class VideoScreen extends ConsumerStatefulWidget {
  const VideoScreen({super.key});

  @override
  ConsumerState<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends ConsumerState<VideoScreen> {
  static const _tabs = [
    ('News', 'news'),
    ('Interviews', 'interviews'),
    ('Destinations', 'destinations'),
  ];

  final ScrollController _scrollController = ScrollController();
  YoutubePlayerController? _playerController;

  // Tracks whether a category switch is waiting for fresh data
  bool _pendingCategoryReload = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _playerController?.pause();
    _playerController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(videoFeedProvider.notifier).loadMore();
    }
  }

  void _initPlayer(String videoId, {bool autoPlay = false}) {
    if (!mounted || videoId.isEmpty) return;
    setState(() {
      _playerController?.dispose();
      _playerController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: YoutubePlayerFlags(
          autoPlay: autoPlay,
          mute: false,
          enableCaption: true,
        ),
      );
    });
  }

  void _loadInPlayer(String videoId) {
    if (videoId.isEmpty) return;
    if (_playerController == null) {
      _initPlayer(videoId, autoPlay: true);
    } else {
      _playerController!.load(videoId);
    }
    // Scroll to top so the player is visible
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;

    // Listen for state changes to manage the player lifecycle
    ref.listen<VideoFeedState>(videoFeedProvider, (prev, next) {
      if (!mounted) return;

      // Track category switches
      if (prev != null && prev.selectedCategory != next.selectedCategory) {
        _pendingCategoryReload = true;
      }

      // When loading completes and fresh data has arrived
      final dataArrived = (prev?.isLoading ?? false) &&
          !next.isLoading &&
          next.items.isNotEmpty;
      if (!dataArrived) return;

      final firstId = next.items.first.firstVideoId;
      if (firstId.isEmpty) return;

      if (_playerController == null) {
        // First time data arrives — initialise player, no autoplay
        _initPlayer(firstId, autoPlay: false);
      } else if (_pendingCategoryReload) {
        // Category switched — load first video of new category
        _pendingCategoryReload = false;
        _playerController!.load(firstId);
      }
    });

    final feed = ref.watch(videoFeedProvider);

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _playerController ??
            YoutubePlayerController(initialVideoId: ''),
        aspectRatio: 16 / 9,
        showVideoProgressIndicator: true,
        progressIndicatorColor: const Color(0xFFC9A84C),
        progressColors: const ProgressBarColors(
          playedColor: Color(0xFFC9A84C),
          handleColor: Color(0xFFC9A84C),
        ),
      ),
      builder: (context, player) {
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
              'Video',
              style: AppTypography.titleMedium.copyWith(color: colors.ink900),
            ),
          ),
          body: feed.items.isEmpty && feed.isLoading
              ? const Center(child: CircularProgressIndicator())
              : feed.items.isEmpty && feed.error != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Failed to load videos',
                              style: TextStyle(color: colors.ink600)),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => ref
                                .read(videoFeedProvider.notifier)
                                .loadMore(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      // +3 = player + tabs + loading bar
                      itemCount: feed.items.length + 3,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _playerController != null
                              ? Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 20),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: player,
                                  ),
                                )
                              : _PlaceholderHero(
                                  video: feed.items.isNotEmpty
                                      ? feed.items.first
                                      : null,
                                  colors: colors,
                                  onTap: () {
                                    if (feed.items.isNotEmpty) {
                                      final id =
                                          feed.items.first.firstVideoId;
                                      if (id.isNotEmpty) {
                                        _initPlayer(id, autoPlay: true);
                                      }
                                    }
                                  },
                                );
                        }
                        if (index == 1) {
                          return _CategoryTabs(
                            tabs: _tabs,
                            selected: feed.selectedCategory,
                            onSelect: (cat) => ref
                                .read(videoFeedProvider.notifier)
                                .setCategory(cat),
                            colors: colors,
                          );
                        }
                        if (index == 2) {
                          return feed.isLoading
                              ? LinearProgressIndicator(
                                  minHeight: 2,
                                  backgroundColor: colors.lineSoft,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      colors.ink900),
                                )
                              : const SizedBox.shrink();
                        }
                        final itemIndex = index - 3;
                        if (itemIndex >= feed.items.length) {
                          return feed.isLoading
                              ? const Padding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 20),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                )
                              : const SizedBox(height: 80);
                        }
                        return _VideoListItem(
                          video: feed.items[itemIndex],
                          colors: colors,
                          onTap: () =>
                              _loadInPlayer(feed.items[itemIndex].firstVideoId),
                        );
                      },
                    ),
        );
      },
    );
  }
}

// ── Placeholder shown before player is initialised ─────────────────────────
class _PlaceholderHero extends StatelessWidget {
  final VideoItem? video;
  final AppColorScheme colors;
  final VoidCallback onTap;

  const _PlaceholderHero({
    required this.video,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final thumbUrl = video?.thumbnailUrl ?? '';
    final title = video?.title ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (thumbUrl.isNotEmpty)
                  Image.network(thumbUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: colors.surfaceTertiary))
                else
                  Container(color: const Color(0xFF0D1B2A)),
                Container(color: Colors.black38),
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: Colors.white70, width: 2),
                    ),
                    child: const Icon(Icons.play_arrow,
                        size: 36, color: Colors.white),
                  ),
                ),
                if (title.isNotEmpty)
                  Positioned(
                    bottom: 14,
                    left: 14,
                    right: 14,
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Playfair Display',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Category tabs ──────────────────────────────────────────────────────────
class _CategoryTabs extends StatelessWidget {
  final List<(String, String)> tabs;
  final String selected;
  final ValueChanged<String> onSelect;
  final AppColorScheme colors;

  const _CategoryTabs({
    required this.tabs,
    required this.selected,
    required this.onSelect,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: tabs.map((tab) {
          final (label, key) = tab;
          final isSelected = key == selected;
          return GestureDetector(
            onTap: () => onSelect(key),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isSelected ? colors.ink900 : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      isSelected ? colors.ink900 : colors.lineSoft,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
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
    );
  }
}

// ── Video list tile ────────────────────────────────────────────────────────
class _VideoListItem extends StatelessWidget {
  final VideoItem video;
  final AppColorScheme colors;
  final VoidCallback onTap;

  const _VideoListItem({
    required this.video,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 130,
                      height: 78,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: colors.surfaceTertiary,
                        image: video.thumbnailUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(video.thumbnailUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow,
                              size: 18, color: Colors.white),
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
                        video.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colors.ink900,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        video.timeAgo.isNotEmpty
                            ? 'Travel World Online · ${video.timeAgo}'
                            : 'Travel World Online',
                        style: TextStyle(
                            fontSize: 11, color: colors.ink400),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          indent: 20,
          endIndent: 20,
          color: colors.lineSoft,
        ),
      ],
    );
  }
}
