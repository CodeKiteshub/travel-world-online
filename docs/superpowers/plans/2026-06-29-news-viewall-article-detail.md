# News View-All + Article Detail Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wire the Home "See All" button to `NewsScreen`, make every news card tappable, and build the `NewsArticleDetailScreen` with a gold FAB (idle) that transforms into a dark reading bar (listening) matching the HTML spec in `docs/15-news-viewall-detail.html`.

**Architecture:** Three-layer change — (1) data model gains `content`+`audioUrls` fields; (2) new detail screen with local `AudioPlayer` lifecycle; (3) nav wiring in home + news list screens. Audio state is screen-scoped (disposed on pop), no cross-screen persistence needed.

**Tech Stack:** Flutter/Riverpod, `go_router`, `just_audio` (new dep), `cached_network_image`, `flutter_widget_from_html_core`, existing `AppColorScheme`/`AppTypography`.

## Global Constraints

- Font for article titles: `'PlayfairDisplay'` (asset registered) — minimum 18 px per design system rule.
- Gold accent: `colors.goldPrimary` = `Color(0xFFC9A84C)`.
- Reading-bar navy background: `const Color(0xFF0D1B2A)` (not in AppColors, hardcode it).
- `CachedNetworkImage` for all network images (already in pubspec).
- `HtmlWidget` from `flutter_widget_from_html_core` for article body HTML (already in pubspec).
- No placeholder TBD code — every step contains actual Dart.
- Keep changes inside `lib/features/news/` and `lib/features/home/` except for router files.

---

### Task 1: Extend Article model with `content` + `audioUrls`

**Files:**
- Modify: `lib/features/home/data/models/article_model.dart`

**Interfaces:**
- Produces: `Article.content` (String, HTML body), `Article.audioUrls` (List<String>), `Article.firstAudioUrl` (String? getter)

- [ ] **Step 1: Open the file and understand current shape**

Read `lib/features/home/data/models/article_model.dart` — it currently has `id`, `title`, `author`, `category`, `images`, `addedAt`. No `content` or audio.

- [ ] **Step 2: Add fields and update `fromJson`**

Replace the entire `Article` class with:

```dart
class Article {
  const Article({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.images,
    required this.addedAt,
    this.content = '',
    this.audioUrls = const [],
  });

  final String id;
  final String title;
  final String author;
  final ArticleCategory category;
  final List<String> images;
  final DateTime addedAt;
  final String content;
  final List<String> audioUrls;

  String get firstImage => images.isNotEmpty ? images.first : '';
  String? get firstAudioUrl => audioUrls.isNotEmpty ? audioUrls.first : null;

  String get timeAgo {
    final diff = DateTime.now().difference(addedAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  String get sourceMeta => '${author.isNotEmpty ? author : 'Travel World'} · $timeAgo';

  factory Article.fromJson(Map<String, dynamic> json) => Article(
        id: json['_id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        author: json['author'] as String? ?? '',
        category: ArticleCategory.fromJson(
            json['category'] as Map<String, dynamic>? ?? {}),
        images: (json['urlToImage'] as List<dynamic>?)?.cast<String>() ?? [],
        addedAt: DateTime.tryParse(json['addedAt'] as String? ?? '') ??
            DateTime.now(),
        content: json['content'] as String? ?? '',
        audioUrls: (json['audio'] as List<dynamic>?)?.cast<String>() ?? [],
      );
}
```

- [ ] **Step 3: Verify no compile errors**

Run: `flutter analyze lib/features/home/data/models/article_model.dart`

Expected: No errors. The new fields have default values, so no existing callers break.

- [ ] **Step 4: Commit**

```bash
git add lib/features/home/data/models/article_model.dart
git commit -m "feat(news): add content and audioUrls to Article model"
```

---

### Task 2: Add `just_audio` dependency

**Files:**
- Modify: `pubspec.yaml`

**Interfaces:**
- Produces: `AudioPlayer` from `package:just_audio/just_audio.dart` available in the project

- [ ] **Step 1: Add just_audio under the `# UI` section in pubspec.yaml**

In `pubspec.yaml`, under the `dependencies:` section, add after `flutter_animate: ^4.5.0`:

```yaml
  # Audio
  just_audio: ^0.9.42
```

- [ ] **Step 2: Fetch packages**

Run: `flutter pub get`

Expected: Resolves successfully. `just_audio` v0.9.x appears in `pubspec.lock`.

- [ ] **Step 3: iOS audio session config (required for just_audio to play on iOS)**

Open `ios/Runner/Info.plist`. Add before the closing `</dict>`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is not used by this app.</string>
```

Also open `ios/Runner/AppDelegate.swift` and ensure it already has `import Flutter`. If it doesn't have `AVAudioSession` config, just_audio handles it internally via its plugin — no additional Swift code needed.

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock ios/Runner/Info.plist
git commit -m "chore: add just_audio dependency for article read-aloud feature"
```

---

### Task 3: Add `newsArticleDetail` route

**Files:**
- Modify: `lib/core/router/route_names.dart`
- Modify: `lib/core/router/app_router.dart`

**Interfaces:**
- Produces: `RouteNames.newsArticleDetail = '/news/article'`; navigated via `context.push(RouteNames.newsArticleDetail, extra: article)` where `article` is an `Article` object.

- [ ] **Step 1: Add route name**

In `lib/core/router/route_names.dart`, add after `static const news = '/news';`:

```dart
  static const newsArticleDetail = '/news/article';
```

- [ ] **Step 2: Register route in app_router.dart**

In `lib/core/router/app_router.dart`, add the import at the top:

```dart
import '../../features/news/presentation/screens/news_article_detail_screen.dart';
```

Then add the route after the existing `RouteNames.news` GoRoute (around line 213):

```dart
GoRoute(
  path: RouteNames.newsArticleDetail,
  pageBuilder: (_, state) =>
      _slideLeftPage(NewsArticleDetailScreen(article: state.extra as Article)),
),
```

- [ ] **Step 3: Verify**

Run: `flutter analyze lib/core/router/`

Expected: No errors (the import for `NewsArticleDetailScreen` will resolve once Task 4 creates the file — run analyze after Task 4 if analyzing now gives a missing-file error).

- [ ] **Step 4: Commit**

```bash
git add lib/core/router/route_names.dart lib/core/router/app_router.dart
git commit -m "feat(news): add newsArticleDetail route"
```

---

### Task 4: Create `NewsArticleDetailScreen`

**Files:**
- Create: `lib/features/news/presentation/screens/news_article_detail_screen.dart`

**Interfaces:**
- Consumes: `Article` (from Task 1) — `article.firstImage`, `article.category.name`, `article.title`, `article.author`, `article.addedAt`, `article.content`, `article.firstAudioUrl`
- Produces: Screen accessible at `RouteNames.newsArticleDetail` with `extra: Article`

This screen has two sub-states:
- **Idle**: gold circular FAB at bottom-right (56×56, `colors.goldPrimary`, speaker icon).
- **Listening**: reading bar replaces FAB — dark navy bar at bottom with gold icon, title, progress track, pause button, close button.

- [ ] **Step 1: Create the file**

Create `lib/features/news/presentation/screens/news_article_detail_screen.dart`:

```dart
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
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
  }

  @override
  void dispose() {
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
                    placeholder: (_, __) => Container(color: colors.surfaceTertiary),
                    errorWidget: (_, __, ___) => Container(color: colors.surfaceTertiary),
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
                color: colors.goldPrimary.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.volume_up_rounded, color: Color(0xFF1A1A1A), size: 22),
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
                      onTap: () => isPlaying ? player.pause() : player.play(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC9A84C),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
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
              style: const TextStyle(
                  fontSize: 9, color: Colors.white54),
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
```

- [ ] **Step 2: Verify compile**

Run: `flutter analyze lib/features/news/presentation/screens/news_article_detail_screen.dart`

Expected: No errors. If `AppTypography.titleMedium` is missing, use `AppTypography.displayMd.copyWith(fontSize: 19)` instead.

- [ ] **Step 3: Check `AppTypography.titleMedium` exists**

Run: `grep -n "titleMedium" lib/core/theme/app_typography.dart`

If it returns no results, in the detail screen replace:
```dart
AppTypography.titleMedium.copyWith(color: colors.ink900)
```
with:
```dart
AppTypography.displayMd.copyWith(fontSize: 19, color: colors.ink900)
```

Also verify `AppTypography.label` and `AppTypography.caption` exist:
`grep -n "static.*label\|static.*caption" lib/core/theme/app_typography.dart`

If missing, replace with `TextStyle(fontFamily: 'DMSans', ...)` equivalents at the appropriate font sizes.

- [ ] **Step 4: Commit**

```bash
git add lib/features/news/presentation/screens/news_article_detail_screen.dart
git commit -m "feat(news): add NewsArticleDetailScreen with FAB and reading bar"
```

---

### Task 5: Wire card taps in `NewsScreen` + add listen badge

**Files:**
- Modify: `lib/features/news/presentation/screens/news_screen.dart`

**Interfaces:**
- Consumes: `RouteNames.newsArticleDetail` (Task 3), `Article.firstAudioUrl` (Task 1)
- Produces: Tappable hero card and feed cards; listen badge on cards with audio

- [ ] **Step 1: Make `_HeroCard` tappable**

In `_HeroCard.build`, wrap the outermost `Container` with `GestureDetector`:

```dart
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
      // ... existing Container code unchanged ...
```

Add the `go_router` import at the top of `news_screen.dart` (already present — `go_router` import exists).
Also add the route import: `import '../../../../core/router/route_names.dart';` (already imported).

- [ ] **Step 2: Make `_NewsCard` tappable and add listen badge**

Replace the `_NewsCard` class entirely:

```dart
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
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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
```

- [ ] **Step 3: Verify analyze**

Run: `flutter analyze lib/features/news/presentation/screens/news_screen.dart`

Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add lib/features/news/presentation/screens/news_screen.dart
git commit -m "feat(news): make NewsScreen cards tappable with article detail navigation"
```

---

### Task 6: Wire home "See All" + home news card taps

**Files:**
- Modify: `lib/features/home/presentation/screens/home_screen.dart`

**Interfaces:**
- Consumes: `RouteNames.news`, `RouteNames.newsArticleDetail`, `Article` passed as extra
- Produces: "See All →" navigates to `/news`; each home news card navigates to `/news/article`

- [ ] **Step 1: Wire the "See All" onViewAll callback**

Find the `_SectionRow` call in `HomeScreen.build` (around line 57):

```dart
_SectionRow(
  heading: 'Top Stories',
  colors: colors,
  onViewAll: () {},
),
```

Change `onViewAll: () {}` to:

```dart
onViewAll: () => context.push(RouteNames.news),
```

- [ ] **Step 2: Add `article` param + onTap to home `_NewsCard`**

The home `_NewsCard` widget (around line 740) currently takes `eyebrow`, `title`, `meta`, `imageUrl`, `colors`. Add `onTap`:

Replace the class signature and build:

```dart
class _NewsCard extends StatelessWidget {
  const _NewsCard({
    required this.eyebrow,
    required this.title,
    required this.meta,
    required this.imageUrl,
    required this.colors,
    required this.onTap,
  });
  final String eyebrow;
  final String title;
  final String meta;
  final String imageUrl;
  final AppColorScheme colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // ... existing Container + Row content unchanged, just wrapped ...
```

Close the `GestureDetector` after the existing `Container` closing brace.

- [ ] **Step 3: Pass `onTap` at each call site**

In `HomeScreen.build`, the news section maps over `articles`. Change:

```dart
child: _NewsCard(
  eyebrow: a.category.name.toUpperCase(),
  title: a.title,
  meta: a.sourceMeta,
  imageUrl: a.firstImage,
  colors: colors,
),
```

To:

```dart
child: _NewsCard(
  eyebrow: a.category.name.toUpperCase(),
  title: a.title,
  meta: a.sourceMeta,
  imageUrl: a.firstImage,
  colors: colors,
  onTap: () => context.push(RouteNames.newsArticleDetail, extra: a),
),
```

Note: `context` is available here because the map callback is inside `HomeScreen.build(BuildContext context, WidgetRef ref)`. If the card is built in a helper widget without context, pass it via the constructor instead.

- [ ] **Step 4: Verify analyze**

Run: `flutter analyze lib/features/home/presentation/screens/home_screen.dart`

Expected: No errors.

- [ ] **Step 5: Commit**

```bash
git add lib/features/home/presentation/screens/home_screen.dart
git commit -m "feat(home): wire See All to NewsScreen and news cards to article detail"
```

---

## Self-Review Checklist

**Spec coverage:**
- [x] Home "See All" → NewsScreen (`/news`)
- [x] Home card tap → article detail
- [x] NewsScreen hero + feed cards tappable → article detail
- [x] Article detail: hero image, category, title (Playfair Display), byline, HTML body
- [x] Article detail: gold FAB (idle state) when audio available
- [x] Article detail: reading bar (listening state) with progress, pause/play, close
- [x] Listen badge on NewsScreen cards
- [x] Article model extended with `content` + `audioUrls`

**Placeholder scan:** None found.

**Type consistency:**
- `Article.firstAudioUrl` → `String?` getter → used in detail screen as null check ✓
- `context.push(RouteNames.newsArticleDetail, extra: article)` → router reads `state.extra as Article` ✓
- `_NewsCard` in `news_screen.dart` changed from positional fields to `article: Article` — verify call site at the `itemBuilder` in `NewsScreen` (index mapping, `feed.articles[articleIndex]`) still compiles ✓

**Gap:** The `_NewsCard` in `news_screen.dart` Task 5 changes the constructor from individual fields to `article: Article`. The existing `itemBuilder` code `_NewsCard(article: feed.articles[articleIndex], colors: colors)` will match. ✓

**iOS Info.plist note:** If the project already has `NSMicrophoneUsageDescription`, the Task 2 edit would duplicate it — check before adding.
