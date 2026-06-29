import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/data/models/article_model.dart';

class NewsArticleDetailScreen extends ConsumerStatefulWidget {
  const NewsArticleDetailScreen({super.key, required this.article});
  final Article article;

  @override
  ConsumerState<NewsArticleDetailScreen> createState() =>
      _NewsArticleDetailScreenState();
}

class _NewsArticleDetailScreenState
    extends ConsumerState<NewsArticleDetailScreen> {
  late final AudioPlayer _player;
  StreamSubscription<PlayerState>? _playerSub;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _playerSub = _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed && mounted) {
        setState(() => _isListening = false);
        _player.seek(Duration.zero);
      }
    });
  }

  @override
  void dispose() {
    _playerSub?.cancel();
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
    final url = widget.article.firstAudioUrl;
    if (url == null || url.isEmpty) return;
    try {
      await _player.setUrl(url);
      await _player.play();
      if (mounted) setState(() => _isListening = true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load audio')),
        );
      }
    }
  }

  void _stopListening() {
    _player.stop();
    setState(() => _isListening = false);
  }

  void _shareArticle() {
    final url = 'https://twoapp.in/news/${widget.article.id}';
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final a = widget.article;

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      appBar: AppBar(
        backgroundColor: colors.surfacePrimary,
        elevation: 0,
        leading: _CircleIconButton(
          icon: Icons.arrow_back,
          colors: colors,
          onTap: () => context.pop(),
        ),
        titleSpacing: 0,
        title: Text(
          'News',
          style: AppTypography.titleMedium.copyWith(color: colors.ink900),
        ),
        actions: [
          _CircleIconButton(
            icon: Icons.share_outlined,
            colors: colors,
            onTap: _shareArticle,
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Stack(
        children: [
          _ArticleBody(article: a, colors: colors, isListening: _isListening),
          if (a.firstAudioUrl != null)
            _isListening
                ? _ReadingBar(
                    player: _player,
                    title: a.title,
                    colors: colors,
                    onStop: _stopListening,
                  )
                : _ListenFab(colors: colors, onTap: _startListening),
        ],
      ),
    );
  }
}

// ── Article body ──────────────────────────────────────────────────────────────

class _ArticleBody extends StatelessWidget {
  const _ArticleBody({
    required this.article,
    required this.colors,
    required this.isListening,
  });
  final Article article;
  final AppColorScheme colors;
  final bool isListening;

  @override
  Widget build(BuildContext context) {
    final a = article;
    final byline =
        '${a.author.isNotEmpty ? a.author : 'Travel World'} · ${_formatDate(a.addedAt)}';

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: isListening ? 100 : 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero image
          AspectRatio(
            aspectRatio: 16 / 10,
            child: a.firstImage.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: a.firstImage,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: colors.surfaceTertiary),
                    errorWidget: (_, __, ___) =>
                        Container(color: colors.surfaceTertiary),
                  )
                : Container(color: colors.surfaceTertiary),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category tag
                Text(
                  a.category.name.toUpperCase(),
                  style: AppTypography.overline.copyWith(
                    color: colors.goldPrimary,
                    fontSize: 10,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),

                // Article title — Playfair Display
                Text(
                  a.title,
                  style: AppTypography.displayMd.copyWith(
                    fontSize: 23,
                    height: 1.3,
                    color: colors.ink900,
                  ),
                ),
                const SizedBox(height: 14),

                // Byline
                Text(
                  byline,
                  style: AppTypography.caption.copyWith(color: colors.ink400),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(height: 1),
                ),

                // Article content (HTML)
                if (a.content.isNotEmpty)
                  HtmlWidget(
                    a.content,
                    textStyle: AppTypography.body.copyWith(
                      color: colors.ink600,
                      fontSize: 14,
                      height: 1.78,
                    ),
                  )
                else
                  Text(
                    'Full article not available.',
                    style: AppTypography.body.copyWith(color: colors.ink400),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $h:$m $ampm';
  }
}

// ── Gold FAB (idle state) ─────────────────────────────────────────────────────

class _ListenFab extends StatelessWidget {
  const _ListenFab({required this.colors, required this.onTap});
  final AppColorScheme colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      right: 20,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colors.goldPrimary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: colors.goldPrimary.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.volume_up_rounded,
              color: Color(0xFF1A1A1A), size: 22),
        ),
      ),
    );
  }
}

// ── Reading bar (listening state) ─────────────────────────────────────────────

class _ReadingBar extends StatelessWidget {
  const _ReadingBar({
    required this.player,
    required this.title,
    required this.colors,
    required this.onStop,
  });
  final AudioPlayer player;
  final String title;
  final AppColorScheme colors;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        color: const Color(0xFF0D1B2A),
        child: Row(
          children: [
            // Gold icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFC9A84C), Color(0xFF8B6914)],
                ),
              ),
              child: const Icon(Icons.volume_up_rounded,
                  color: Color(0xFF1A1A1A), size: 18),
            ),
            const SizedBox(width: 12),

            // Text + progress
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NOW READING ALOUD',
                    style: AppTypography.overline.copyWith(
                      color: Colors.white54,
                      fontSize: 10,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label.copyWith(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _ProgressTrack(player: player),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Controls
            Row(
              children: [
                StreamBuilder<PlayerState>(
                  stream: player.playerStateStream,
                  builder: (context, snapshot) {
                    final isPlaying = snapshot.data?.playing ?? false;
                    return GestureDetector(
                      onTap: () =>
                          isPlaying ? player.pause() : player.play(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFFC9A84C),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: const Color(0xFF1A1A1A),
                          size: 18,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onStop,
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white54, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressTrack extends StatelessWidget {
  const _ProgressTrack({required this.player});
  final AudioPlayer player;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: player.positionStream,
      builder: (context, posSnap) {
        final pos = posSnap.data ?? Duration.zero;
        final dur = player.duration ?? Duration.zero;
        final pct = dur.inMilliseconds > 0
            ? pos.inMilliseconds / dur.inMilliseconds
            : 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: pct.clamp(0.0, 1.0),
                backgroundColor: Colors.white24,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFFC9A84C)),
                minHeight: 3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_fmt(pos)} of ${_fmt(dur)}',
              style: const TextStyle(fontSize: 9, color: Colors.white54),
            ),
          ],
        );
      },
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

// ── Shared circle icon button ─────────────────────────────────────────────────

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.colors,
    required this.onTap,
  });
  final IconData icon;
  final AppColorScheme colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          shape: BoxShape.circle,
          border: Border.all(color: colors.lineSoft),
        ),
        child: Icon(icon, size: 18, color: colors.ink900),
      ),
    );
  }
}
