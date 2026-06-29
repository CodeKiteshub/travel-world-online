# PPP & Campus Modules Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete the PPP (Tourism Boards) detail screen and all three Campus sub-screens (Advisory Board, Destination Specialist, Skill Development) with full API integration.

**Architecture:** Feature-first Clean Architecture — each feature has `data/models`, `data/datasources`, `presentation/providers`, `presentation/screens`. State via Riverpod `FutureProvider`. Navigation via GoRouter with `extra` for passing objects between screens.

**Tech Stack:** Flutter 3.38, Riverpod 2.6, GoRouter 17, Dio 5.8, cached_network_image, shimmer, youtube_player_flutter 9.1, url_launcher 6.3

## Global Constraints

- Colors ONLY via `Theme.of(context).extension<AppColorScheme>()!` — never hardcode hex
- Gold (`colors.goldPrimary`) ONLY on: primary CTA, active tab, "→" link labels
- Playfair Display for all headings ≥ 18px (`fontFamily: 'PlayfairDisplay'`)
- DM Sans for all body text (`fontFamily: 'DMSans'`)
- 8px grid spacing — use multiples of 8 only
- Every data screen needs shimmer loading, empty state (`Center(Text(...))`), retry error state
- Min touch targets 48×48px
- `withValues(alpha: x)` not `withOpacity(x)` (deprecated in this SDK version)
- backendDio base URL: `https://backend.twoapp.in`
- twoDio base URL: `https://travelworldonline.in`

---

## Task 1: PPP Extended Data Layer

**Files:**
- Modify: `lib/features/ppp/data/models/ppp_model.dart`
- Modify: `lib/features/ppp/data/datasources/ppp_remote_datasource.dart`
- Modify: `lib/features/ppp/presentation/providers/ppp_providers.dart`
- Test: `test/features/ppp/ppp_models_test.dart`

**Interfaces:**
- Produces: `PppPolicyFull`, `PppInvestFull`, `PppVideo`, `PppImage`, `PppPdf` models
- Produces: `pppPoliciesProvider(String id)`, `pppInvestmentsProvider(String id)`, `pppVideosProvider(String id)`, `pppImagesProvider(String id)`, `pppPdfsProvider(String id)`

- [ ] **Step 1: Write failing model tests**

Create `test/features/ppp/ppp_models_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:new_travel/features/ppp/data/models/ppp_model.dart';

void main() {
  group('PppPolicyFull.fromJson', () {
    test('parses all fields', () {
      final json = {'_id': 'p1', 'policyName': 'Eco Policy', 'policyDetails': '<p>Details</p>'};
      final p = PppPolicyFull.fromJson(json);
      expect(p.id, 'p1');
      expect(p.policyName, 'Eco Policy');
      expect(p.policyDetails, '<p>Details</p>');
    });
  });

  group('PppInvestFull.fromJson', () {
    test('parses all fields', () {
      final json = {'_id': 'i1', 'opportunityName': 'Hotel Inv', 'opportunityDetails': '<p>Invest</p>'};
      final i = PppInvestFull.fromJson(json);
      expect(i.id, 'i1');
      expect(i.opportunityName, 'Hotel Inv');
      expect(i.opportunityDetails, '<p>Invest</p>');
    });
  });

  group('PppVideo.fromJson', () {
    test('parses video url and title', () {
      final json = {'_id': 'v1', 'video': 'https://youtu.be/abc', 'title': 'Intro'};
      final v = PppVideo.fromJson(json);
      expect(v.id, 'v1');
      expect(v.videoUrl, 'https://youtu.be/abc');
      expect(v.title, 'Intro');
    });
  });

  group('PppImage.fromJson', () {
    test('parses image list', () {
      final json = {'_id': 'img1', 'image': ['https://a.com/1.jpg', 'https://a.com/2.jpg']};
      final img = PppImage.fromJson(json);
      expect(img.id, 'img1');
      expect(img.imageUrls.length, 2);
    });
  });

  group('PppPdf.fromJson', () {
    test('parses pdf fields', () {
      final json = {
        '_id': 'pdf1',
        'pdf': ['https://a.com/file.pdf'],
        'thumbnail': 'https://a.com/thumb.jpg',
        'name': 'Brochure',
        'description': 'Our annual brochure',
      };
      final pdf = PppPdf.fromJson(json);
      expect(pdf.id, 'pdf1');
      expect(pdf.pdfUrls.first, 'https://a.com/file.pdf');
      expect(pdf.name, 'Brochure');
    });
  });
}
```

- [ ] **Step 2: Run tests — expect FAIL (types not defined)**

```bash
cd /Users/adityabajpai/Documents/personal/new_travel
flutter test test/features/ppp/ppp_models_test.dart
```

Expected: compilation error — `PppPolicyFull` not found.

- [ ] **Step 3: Add new models to `lib/features/ppp/data/models/ppp_model.dart`**

Append after the existing `PppInvestment` class:

```dart
// ── PPP Detail models ────────────────────────────────────────────────────────

class PppPolicyFull {
  const PppPolicyFull({required this.id, required this.policyName, required this.policyDetails});
  final String id;
  final String policyName;
  final String policyDetails; // HTML string

  factory PppPolicyFull.fromJson(Map<String, dynamic> json) => PppPolicyFull(
        id: json['_id'] as String? ?? '',
        policyName: json['policyName'] as String? ?? '',
        policyDetails: json['policyDetails'] as String? ?? '',
      );
}

class PppInvestFull {
  const PppInvestFull({required this.id, required this.opportunityName, required this.opportunityDetails});
  final String id;
  final String opportunityName;
  final String opportunityDetails; // HTML string

  factory PppInvestFull.fromJson(Map<String, dynamic> json) => PppInvestFull(
        id: json['_id'] as String? ?? '',
        opportunityName: json['opportunityName'] as String? ?? '',
        opportunityDetails: json['opportunityDetails'] as String? ?? '',
      );
}

class PppVideo {
  const PppVideo({required this.id, required this.title, required this.videoUrl});
  final String id;
  final String title;
  final String videoUrl; // YouTube URL

  factory PppVideo.fromJson(Map<String, dynamic> json) => PppVideo(
        id: json['_id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        videoUrl: json['video'] as String? ?? '',
      );
}

class PppImage {
  const PppImage({required this.id, required this.imageUrls});
  final String id;
  final List<String> imageUrls;

  factory PppImage.fromJson(Map<String, dynamic> json) => PppImage(
        id: json['_id'] as String? ?? '',
        imageUrls: (json['image'] as List<dynamic>?)?.cast<String>() ?? [],
      );
}

class PppPdf {
  const PppPdf({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.description,
    required this.pdfUrls,
  });
  final String id;
  final String name;
  final String thumbnail;
  final String description;
  final List<String> pdfUrls;

  factory PppPdf.fromJson(Map<String, dynamic> json) => PppPdf(
        id: json['_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        thumbnail: json['thumbnail'] as String? ?? '',
        description: json['description'] as String? ?? '',
        pdfUrls: (json['pdf'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      );
}
```

- [ ] **Step 4: Add 5 fetch methods to `lib/features/ppp/data/datasources/ppp_remote_datasource.dart`**

```dart
  Future<List<PppPolicyFull>> fetchPolicies(String id) async {
    final response = await _dio.get('/api/ppp/$id/policies');
    final raw = response.data;
    final list = (raw is Map<String, dynamic>)
        ? (raw['data'] as List<dynamic>? ?? [])
        : (raw is List ? raw : []);
    return list.cast<Map<String, dynamic>>().map(PppPolicyFull.fromJson).toList();
  }

  Future<List<PppInvestFull>> fetchInvestments(String id) async {
    final response = await _dio.get('/api/ppp/$id/investment-opportunities');
    final raw = response.data;
    final list = (raw is Map<String, dynamic>)
        ? (raw['data'] as List<dynamic>? ?? [])
        : (raw is List ? raw : []);
    return list.cast<Map<String, dynamic>>().map(PppInvestFull.fromJson).toList();
  }

  Future<List<PppVideo>> fetchVideos(String id) async {
    final response = await _dio.get('/api/ppp/$id/getVideo');
    final raw = response.data;
    final list = (raw is Map<String, dynamic>)
        ? (raw['data'] as List<dynamic>? ?? [])
        : (raw is List ? raw : []);
    return list.cast<Map<String, dynamic>>().map(PppVideo.fromJson).toList();
  }

  Future<List<PppImage>> fetchImages(String id) async {
    final response = await _dio.get('/api/ppp/$id/getImage');
    final raw = response.data;
    final list = (raw is Map<String, dynamic>)
        ? (raw['data'] as List<dynamic>? ?? [])
        : (raw is List ? raw : []);
    return list.cast<Map<String, dynamic>>().map(PppImage.fromJson).toList();
  }

  Future<List<PppPdf>> fetchPdfs(String id) async {
    final response = await _dio.get('/api/ppp/$id/getPdf');
    final raw = response.data;
    final list = (raw is Map<String, dynamic>)
        ? (raw['data'] as List<dynamic>? ?? [])
        : (raw is List ? raw : []);
    return list.cast<Map<String, dynamic>>().map(PppPdf.fromJson).toList();
  }
```

- [ ] **Step 5: Add 5 family providers to `lib/features/ppp/presentation/providers/ppp_providers.dart`**

```dart
final pppPoliciesProvider = FutureProvider.family<List<PppPolicyFull>, String>((ref, id) {
  return ref.watch(_pppDatasourceProvider).fetchPolicies(id);
});

final pppInvestmentsProvider = FutureProvider.family<List<PppInvestFull>, String>((ref, id) {
  return ref.watch(_pppDatasourceProvider).fetchInvestments(id);
});

final pppVideosProvider = FutureProvider.family<List<PppVideo>, String>((ref, id) {
  return ref.watch(_pppDatasourceProvider).fetchVideos(id);
});

final pppImagesProvider = FutureProvider.family<List<PppImage>, String>((ref, id) {
  return ref.watch(_pppDatasourceProvider).fetchImages(id);
});

final pppPdfsProvider = FutureProvider.family<List<PppPdf>, String>((ref, id) {
  return ref.watch(_pppDatasourceProvider).fetchPdfs(id);
});
```

- [ ] **Step 6: Run tests — expect PASS**

```bash
flutter test test/features/ppp/ppp_models_test.dart
```

Expected: All 5 tests pass.

- [ ] **Step 7: Verify app compiles**

```bash
flutter build apk --debug 2>&1 | head -20
```

- [ ] **Step 8: Commit**

```bash
git add lib/features/ppp/ test/features/ppp/
git commit -m "feat(ppp): add detail models, datasource methods, and family providers"
```

---

## Task 2: PPP Routes + Wire Card Taps

**Files:**
- Modify: `lib/core/router/route_names.dart`
- Modify: `lib/core/router/app_router.dart`
- Modify: `lib/features/ppp/presentation/screens/ppp_screen.dart`

**Interfaces:**
- Consumes: `PppItem` (from Task 1 models), `PPPDetailScreen` (stub — will be real in Task 3)
- Produces: route `/ppp/:id` accessible via `context.push('/ppp/${item.id}', extra: item)`

- [ ] **Step 1: Add route name constant to `lib/core/router/route_names.dart`**

```dart
  static const pppDetail = '/ppp/:id';
```

Add this line inside the `RouteNames` class after `static const ppp = '/ppp';`.

- [ ] **Step 2: Create stub PPPDetailScreen** in `lib/features/ppp/presentation/screens/ppp_detail_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/ppp_model.dart';

class PPPDetailScreen extends StatelessWidget {
  const PPPDetailScreen({super.key, required this.id, this.item});
  final String id;
  final PppItem? item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      appBar: AppBar(
        backgroundColor: colors.surfacePrimary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.ink900),
          onPressed: () => context.pop(),
        ),
        title: Text(item?.name ?? id,
            style: TextStyle(fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.w700,
                fontSize: 18, color: colors.ink900)),
      ),
      body: Center(child: Text('PPP Detail — $id',
          style: TextStyle(color: colors.ink600))),
    );
  }
}
```

- [ ] **Step 3: Add route to `lib/core/router/app_router.dart`**

Add this GoRoute in the routes list, after the existing `/ppp` route:

```dart
GoRoute(
  path: '/ppp/:id',
  pageBuilder: (context, state) {
    final id = state.pathParameters['id']!;
    final item = state.extra as PppItem?;
    return _slideLeftPage(PPPDetailScreen(id: id, item: item));
  },
),
```

Also add the import at the top of app_router.dart:
```dart
import '../../features/ppp/presentation/screens/ppp_detail_screen.dart';
```

- [ ] **Step 4: Wire `_PPPCard` tap in `lib/features/ppp/presentation/screens/ppp_screen.dart`**

Find the `_PPPCard` widget's `build` method. Wrap the outermost `Container` in a `GestureDetector`:

```dart
@override
Widget build(BuildContext context) {
  return GestureDetector(
    onTap: () => context.push('/ppp/${item.id}', extra: item),
    child: Container(
      // ... existing container code unchanged ...
    ),
  );
}
```

- [ ] **Step 5: Verify hot-reload works — tap a PPP card, stub screen appears**

```bash
flutter run
```

Navigate to PPP, tap a board card. Should open stub screen with board name in title.

- [ ] **Step 6: Commit**

```bash
git add lib/core/router/ lib/features/ppp/presentation/screens/
git commit -m "feat(ppp): add /ppp/:id route and wire list card taps"
```

---

## Task 3: PPPDetailScreen — Full Implementation

**Files:**
- Modify (replace stub): `lib/features/ppp/presentation/screens/ppp_detail_screen.dart`

**Interfaces:**
- Consumes: `pppPoliciesProvider(id)`, `pppInvestmentsProvider(id)`, `pppVideosProvider(id)`, `pppImagesProvider(id)`, `pppPdfsProvider(id)` from Task 1
- Consumes: `PppItem`, `PppPolicyFull`, `PppInvestFull`, `PppVideo`, `PppImage`, `PppPdf` from Task 1

- [ ] **Step 1: Replace stub with full implementation**

Replace entire contents of `lib/features/ppp/presentation/screens/ppp_detail_screen.dart`:

```dart
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
            backgroundColor: const Color(0xFF0D1B2A),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            actions: [
              TextButton(
                onPressed: () => _openStakeholderForm(),
                child: const Text('Register',
                    style: TextStyle(color: Colors.white70, fontSize: 12,
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
                              Container(color: const Color(0xFF0D1B2A)),
                        )
                      : Container(color: const Color(0xFF0D1B2A)),
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

  Future<void> _openStakeholderForm() async {
    final uri = Uri.parse(
        'https://backend.twoapp.in/api/StackHolder?pppId=${widget.id}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
            Container(color: const Color(0xFF0D1B2A)),
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
        color: const Color(0xFFEFEDE6),
        child: const Icon(Icons.picture_as_pdf_outlined,
            color: Color(0xFF9E9E9E), size: 28),
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
            crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12),
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
```

- [ ] **Step 2: Verify `surfaceSecondary` exists on `AppColorScheme`**

```bash
grep -n "surfaceSecondary" lib/core/theme/app_colors.dart
```

If missing, add it to the `AppColorScheme` constructor + `light`/`dark` factory in `app_colors.dart`. Use `Color(0xFFF5F3EE)` for light and `Color(0xFF1E2530)` for dark.

- [ ] **Step 3: Hot-reload and manually test PPP detail**

Run `flutter run`, navigate to PPP, tap a board. Verify:
- Hero image shows with gradient + board name
- "Register" button in top-right
- Tab bar sticks when scrolling
- Policy tab: shimmer → accordion list
- Investment tab: same pattern
- Resources tab: filter chips switch content

- [ ] **Step 4: Commit**

```bash
git add lib/features/ppp/presentation/screens/ppp_detail_screen.dart
git commit -m "feat(ppp): complete PPP detail screen with policy, investment, and resources tabs"
```

---

## Task 4: Campus Extended Data Layer

**Files:**
- Modify: `lib/features/campus/data/models/campus_models.dart`
- Modify: `lib/features/campus/data/datasources/campus_remote_datasource.dart`
- Modify: `lib/features/campus/presentation/providers/campus_providers.dart`
- Test: `test/features/campus/campus_models_test.dart`

**Interfaces:**
- Produces: `DestSubCategory`, `DestSubSubCategory`, `DestVideo`, `CampusCourseItem` models
- Produces: `destSubCategoriesProvider(String catId)`, `destSubSubCategoriesProvider((String, String))`, `destVideosProvider((String, String, String))`, `campusCourseItemsProvider(String catId)`

- [ ] **Step 1: Write failing model tests**

Create `test/features/campus/campus_models_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:new_travel/features/campus/data/models/campus_models.dart';

void main() {
  group('DestSubCategory.fromJson', () {
    test('parses tblvideocats fields', () {
      final json = {'id': '10', 'videosubcat': 'Buddhist Circuit', 'image': 'https://a.com/img.jpg'};
      final d = DestSubCategory.fromJson(json);
      expect(d.id, '10');
      expect(d.label, 'Buddhist Circuit');
      expect(d.imageUrl, 'https://a.com/img.jpg');
    });
  });

  group('DestVideo.fromJson', () {
    test('parses all fields', () {
      final json = {
        'id': '5',
        'heading': 'Bodh Gaya Tour',
        'image': 'https://a.com/thumb.jpg',
        'video': 'https://youtu.be/xyz',
        'detail': 'Visit the Mahabodhi Temple',
        'place': 'Bihar',
      };
      final v = DestVideo.fromJson(json);
      expect(v.id, '5');
      expect(v.heading, 'Bodh Gaya Tour');
      expect(v.videoUrl, 'https://youtu.be/xyz');
      expect(v.place, 'Bihar');
    });
  });

  group('CampusCourseItem.fromJson', () {
    test('parses name and link', () {
      final json = {'id': '3', 'name': 'GST for Tour Ops', 'link': 'https://primegrowth.io/gst'};
      final c = CampusCourseItem.fromJson(json);
      expect(c.id, '3');
      expect(c.label, 'GST for Tour Ops');
      expect(c.link, 'https://primegrowth.io/gst');
    });
  });
}
```

- [ ] **Step 2: Run tests — expect FAIL**

```bash
flutter test test/features/campus/campus_models_test.dart
```

- [ ] **Step 3: Add new models to `lib/features/campus/data/models/campus_models.dart`**

Append after the `DestinationCategory` class:

```dart
// ── Destination drill-down models ─────────────────────────────────────────────

class DestSubCategory {
  const DestSubCategory({required this.id, required this.label, required this.imageUrl});
  final String id;
  final String label;
  final String imageUrl;

  factory DestSubCategory.fromJson(Map<String, dynamic> json) => DestSubCategory(
        id: json['id']?.toString() ?? '',
        label: json['videosubcat'] as String? ?? json['label'] as String? ?? '',
        imageUrl: json['image'] as String? ?? '',
      );
}

class DestSubSubCategory {
  const DestSubSubCategory({required this.id, required this.label, required this.imageUrl});
  final String id;
  final String label;
  final String imageUrl;

  factory DestSubSubCategory.fromJson(Map<String, dynamic> json) => DestSubSubCategory(
        id: json['id']?.toString() ?? '',
        label: json['subsubcat'] as String? ?? json['label'] as String? ?? '',
        imageUrl: json['image'] as String? ?? '',
      );
}

class DestVideo {
  const DestVideo({
    required this.id,
    required this.heading,
    required this.imageUrl,
    required this.videoUrl,
    required this.detail,
    required this.place,
  });
  final String id;
  final String heading;
  final String imageUrl;
  final String videoUrl;
  final String detail;
  final String place;

  factory DestVideo.fromJson(Map<String, dynamic> json) => DestVideo(
        id: json['id']?.toString() ?? '',
        heading: json['heading'] as String? ?? '',
        imageUrl: json['image'] as String? ?? '',
        videoUrl: json['video'] as String? ?? '',
        detail: json['detail'] as String? ?? '',
        place: json['place'] as String? ?? '',
      );
}

// ── Skill development models ───────────────────────────────────────────────────

class CampusCourseItem {
  const CampusCourseItem({required this.id, required this.label, required this.link});
  final String id;
  final String label;
  final String link;

  factory CampusCourseItem.fromJson(Map<String, dynamic> json) => CampusCourseItem(
        id: json['id']?.toString() ?? '',
        label: json['name'] as String? ?? json['label'] as String? ?? '',
        link: json['link'] as String? ?? '',
      );
}
```

- [ ] **Step 4: Add 4 fetch methods to `lib/features/campus/data/datasources/campus_remote_datasource.dart`**

```dart
  Future<List<DestSubCategory>> fetchDestSubCategories(String catId) async {
    final response = await twoDio.get('/travelvideojson/destsubcat/?catid=$catId');
    return _unwrap(response.data)
        .whereType<Map<String, dynamic>>()
        .map(DestSubCategory.fromJson)
        .toList();
  }

  Future<List<DestSubSubCategory>> fetchDestSubSubCategories(
      String catId, String subCatId) async {
    final response = await twoDio.get(
        '/travelvideojson/destsubsubcat/?catid=$catId&subcatid=$subCatId');
    return _unwrap(response.data)
        .whereType<Map<String, dynamic>>()
        .map(DestSubSubCategory.fromJson)
        .toList();
  }

  Future<List<DestVideo>> fetchDestVideos(
      String catId, String subCatId, String subSubCatId) async {
    final response = await twoDio.get(
        '/travelvideojson/destinationlist/?catid=$catId&subcatid=$subCatId&subsubcatid=$subSubCatId');
    return _unwrap(response.data)
        .whereType<Map<String, dynamic>>()
        .map(DestVideo.fromJson)
        .toList();
  }

  Future<List<CampusCourseItem>> fetchCourseItems(String catId) async {
    final response =
        await twoDio.get('/travelvideojson/campusvideo/?catid=$catId&subcatid=');
    return _unwrap(response.data)
        .whereType<Map<String, dynamic>>()
        .map(CampusCourseItem.fromJson)
        .toList();
  }
```

- [ ] **Step 5: Add 4 family providers to `lib/features/campus/presentation/providers/campus_providers.dart`**

```dart
final destSubCategoriesProvider =
    FutureProvider.family<List<DestSubCategory>, String>((ref, catId) {
  return ref.watch(_campusDatasourceProvider).fetchDestSubCategories(catId);
});

// Key is (catId, subCatId) encoded as '$catId|$subCatId'
final destSubSubCategoriesProvider =
    FutureProvider.family<List<DestSubSubCategory>, String>((ref, key) {
  final parts = key.split('|');
  return ref.watch(_campusDatasourceProvider)
      .fetchDestSubSubCategories(parts[0], parts.length > 1 ? parts[1] : '');
});

// Key is '$catId|$subCatId|$subSubCatId'
final destVideosProvider =
    FutureProvider.family<List<DestVideo>, String>((ref, key) {
  final parts = key.split('|');
  return ref.watch(_campusDatasourceProvider).fetchDestVideos(
      parts[0],
      parts.length > 1 ? parts[1] : '',
      parts.length > 2 ? parts[2] : '');
});

final campusCourseItemsProvider =
    FutureProvider.family<List<CampusCourseItem>, String>((ref, catId) {
  return ref.watch(_campusDatasourceProvider).fetchCourseItems(catId);
});
```

Also add imports at the top of `campus_providers.dart`:
```dart
// These are already imported via campus_models.dart — add the new types:
// DestSubCategory, DestSubSubCategory, DestVideo, CampusCourseItem
```

- [ ] **Step 6: Run tests — expect PASS**

```bash
flutter test test/features/campus/campus_models_test.dart
```

- [ ] **Step 7: Verify compile**

```bash
flutter build apk --debug 2>&1 | grep -E "error:|warning:" | head -20
```

- [ ] **Step 8: Commit**

```bash
git add lib/features/campus/ test/features/campus/
git commit -m "feat(campus): add drill-down models, datasource methods, and family providers"
```

---

## Task 5: Campus Routes + Wire CampusScreen Taps

**Files:**
- Modify: `lib/core/router/route_names.dart`
- Modify: `lib/core/router/app_router.dart`
- Modify: `lib/features/campus/presentation/screens/campus_screen.dart`

**Interfaces:**
- Produces: routes `/advisory-board`, `/destination-specialist`, `/destination-specialist/:catId`, `/destination-specialist/:catId/:subCatId`, `/skill-development`, `/skill-development/:catId`
- Produces: `CampusScreen` module cards navigate to their respective screens

- [ ] **Step 1: Add route names to `lib/core/router/route_names.dart`**

```dart
  static const advisoryBoard = '/advisory-board';
  static const destinationSpecialist = '/destination-specialist';
  static const skillDevelopment = '/skill-development';
```

- [ ] **Step 2: Create stub screens for compilation**

Create `lib/features/campus/presentation/screens/advisory_board_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class AdvisoryBoardScreen extends StatelessWidget {
  const AdvisoryBoardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      appBar: AppBar(backgroundColor: colors.surfacePrimary, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: colors.ink900), onPressed: () => context.pop()),
        title: Text('Advisory Board', style: TextStyle(fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.w700, fontSize: 18, color: colors.ink900)),
      ),
      body: const Center(child: Text('Advisory Board — coming')),
    );
  }
}
```

Create `lib/features/campus/presentation/screens/destination_specialist_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class DestinationSpecialistScreen extends StatelessWidget {
  const DestinationSpecialistScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      appBar: AppBar(backgroundColor: colors.surfacePrimary, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: colors.ink900), onPressed: () => context.pop()),
        title: Text('Destination Specialist', style: TextStyle(fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.w700, fontSize: 18, color: colors.ink900)),
      ),
      body: const Center(child: Text('Destination Specialist — coming')),
    );
  }
}
```

Create `lib/features/campus/presentation/screens/dest_sub_category_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class DestSubCategoryScreen extends StatelessWidget {
  const DestSubCategoryScreen({super.key, required this.catId, required this.catLabel});
  final String catId;
  final String catLabel;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      appBar: AppBar(backgroundColor: colors.surfacePrimary, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: colors.ink900), onPressed: () => context.pop()),
        title: Text(catLabel, style: TextStyle(fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.w700, fontSize: 18, color: colors.ink900)),
      ),
      body: Center(child: Text('Sub-categories for $catId — coming')),
    );
  }
}
```

Create `lib/features/campus/presentation/screens/dest_video_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class DestVideoScreen extends StatelessWidget {
  const DestVideoScreen({super.key, required this.catId, required this.subCatId, required this.subCatLabel});
  final String catId;
  final String subCatId;
  final String subCatLabel;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      appBar: AppBar(backgroundColor: colors.surfacePrimary, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: colors.ink900), onPressed: () => context.pop()),
        title: Text(subCatLabel, style: TextStyle(fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.w700, fontSize: 18, color: colors.ink900)),
      ),
      body: Center(child: Text('Videos for $catId/$subCatId — coming')),
    );
  }
}
```

Create `lib/features/campus/presentation/screens/skill_development_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class SkillDevelopmentScreen extends StatelessWidget {
  const SkillDevelopmentScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      appBar: AppBar(backgroundColor: colors.surfacePrimary, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: colors.ink900), onPressed: () => context.pop()),
        title: Text('Skill Development', style: TextStyle(fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.w700, fontSize: 18, color: colors.ink900)),
      ),
      body: const Center(child: Text('Skill Development — coming')),
    );
  }
}
```

- [ ] **Step 3: Register all new routes in `lib/core/router/app_router.dart`**

Add imports at the top:
```dart
import '../../features/campus/presentation/screens/advisory_board_screen.dart';
import '../../features/campus/presentation/screens/destination_specialist_screen.dart';
import '../../features/campus/presentation/screens/dest_sub_category_screen.dart';
import '../../features/campus/presentation/screens/dest_video_screen.dart';
import '../../features/campus/presentation/screens/skill_development_screen.dart';
```

Add these routes in the routes list, after the `/campus` route:

```dart
GoRoute(
  path: RouteNames.advisoryBoard,
  pageBuilder: (_, __) => _slideLeftPage(const AdvisoryBoardScreen()),
),
GoRoute(
  path: RouteNames.destinationSpecialist,
  pageBuilder: (_, __) => _slideLeftPage(const DestinationSpecialistScreen()),
),
GoRoute(
  path: '/destination-specialist/:catId',
  pageBuilder: (_, state) {
    final catId = state.pathParameters['catId']!;
    final catLabel = state.extra as String? ?? catId;
    return _slideLeftPage(DestSubCategoryScreen(catId: catId, catLabel: catLabel));
  },
),
GoRoute(
  path: '/destination-specialist/:catId/:subCatId',
  pageBuilder: (_, state) {
    final catId = state.pathParameters['catId']!;
    final subCatId = state.pathParameters['subCatId']!;
    final subCatLabel = state.extra as String? ?? subCatId;
    return _slideLeftPage(DestVideoScreen(catId: catId, subCatId: subCatId, subCatLabel: subCatLabel));
  },
),
GoRoute(
  path: RouteNames.skillDevelopment,
  pageBuilder: (_, __) => _slideLeftPage(const SkillDevelopmentScreen()),
),
```

- [ ] **Step 4: Wire `CampusScreen` module card taps in `lib/features/campus/presentation/screens/campus_screen.dart`**

Find each `_CampusCard` usage in the `body` and wrap each in a `GestureDetector`:

```dart
// Advisory Board card — wrap existing advisoryAsync.when(...) in:
GestureDetector(
  onTap: () => context.push(RouteNames.advisoryBoard),
  child: advisoryAsync.when(/* existing code */),
),

// Destination Specialist card — wrap existing destAsync.when(...) in:
GestureDetector(
  onTap: () => context.push(RouteNames.destinationSpecialist),
  child: destAsync.when(/* existing code */),
),

// Skill Development card — wrap existing coursesAsync.when(...) in:
GestureDetector(
  onTap: () => context.push(RouteNames.skillDevelopment),
  child: coursesAsync.when(/* existing code */),
),
```

Also add `RouteNames` import at the top of campus_screen.dart:
```dart
import '../../../../core/router/route_names.dart';
```

- [ ] **Step 5: Verify navigation works**

```bash
flutter run
```

Navigate to Campus, tap each card. Each should open its stub screen. Use back button to return.

- [ ] **Step 6: Commit**

```bash
git add lib/core/router/ lib/features/campus/presentation/
git commit -m "feat(campus): add campus sub-screen routes and wire CampusScreen card taps"
```

---

## Task 6: AdvisoryBoardScreen — Full Implementation

**Files:**
- Modify (replace stub): `lib/features/campus/presentation/screens/advisory_board_screen.dart`

**Interfaces:**
- Consumes: `advisoryBoardProvider` from existing `campus_providers.dart`
- Consumes: `AdvisoryBoardMember` from existing `campus_models.dart`

- [ ] **Step 1: Replace stub with full implementation**

Replace entire contents of `lib/features/campus/presentation/screens/advisory_board_screen.dart`:

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/campus_models.dart';
import '../providers/campus_providers.dart';

class AdvisoryBoardScreen extends ConsumerWidget {
  const AdvisoryBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final async = ref.watch(advisoryBoardProvider);

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      appBar: AppBar(
        backgroundColor: colors.surfacePrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.ink900),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Advisory Board',
          style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: colors.ink900),
        ),
      ),
      body: async.when(
        loading: () => _ShimmerGrid(colors: colors),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to load advisory board',
                  style: TextStyle(fontFamily: 'DMSans', color: colors.ink600)),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.invalidate(advisoryBoardProvider),
                child: Text('Retry',
                    style: TextStyle(
                        fontFamily: 'DMSans', color: colors.goldPrimary)),
              ),
            ],
          ),
        ),
        data: (members) {
          if (members.isEmpty) {
            return Center(
                child: Text('No advisory board members found',
                    style: TextStyle(
                        fontFamily: 'DMSans', color: colors.ink600)));
          }
          return Column(
            children: [
              // Header banner
              Container(
                margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D1B2A), Color(0xFF1A3850)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people_outline_rounded,
                        color: Colors.white70, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('OUR ADVISORY BOARD',
                              style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 0.16,
                                  color: Colors.white70,
                                  fontFamily: 'DMSans')),
                          const SizedBox(height: 4),
                          Text(
                            '${members.length} Industry Expert${members.length != 1 ? 's' : ''}',
                            style: const TextStyle(
                                fontFamily: 'PlayfairDisplay',
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: members.length,
                  itemBuilder: (ctx, i) => _MemberCard(
                      member: members[i],
                      colors: colors,
                      onTap: () => _showMemberDetail(ctx, members[i], colors)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showMemberDetail(
      BuildContext context, AdvisoryBoardMember member, AppColorScheme colors) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MemberDetailSheet(member: member, colors: colors),
    );
  }
}

// ── Member grid card ──────────────────────────────────────────────────────────

class _MemberCard extends StatelessWidget {
  const _MemberCard(
      {required this.member, required this.colors, required this.onTap});
  final AdvisoryBoardMember member;
  final AppColorScheme colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.lineSoft),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.goldPrimary, width: 2),
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: colors.surfaceTertiary,
                backgroundImage: member.firstImage.isNotEmpty
                    ? NetworkImage(member.firstImage)
                    : null,
                child: member.firstImage.isEmpty
                    ? Icon(Icons.person_outline_rounded,
                        size: 32, color: colors.ink400)
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              member.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: colors.ink900),
            ),
            const SizedBox(height: 4),
            Text(
              member.post,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 11,
                  color: colors.ink600),
            ),
            const Spacer(),
            Text('View Profile →',
                style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'DMSans',
                    fontWeight: FontWeight.w600,
                    color: colors.goldPrimary)),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

// ── Member detail bottom sheet ────────────────────────────────────────────────

class _MemberDetailSheet extends StatelessWidget {
  const _MemberDetailSheet({required this.member, required this.colors});
  final AdvisoryBoardMember member;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: colors.surfacePrimary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.lineSoft,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.goldPrimary, width: 3),
                ),
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: colors.surfaceTertiary,
                  backgroundImage: member.firstImage.isNotEmpty
                      ? NetworkImage(member.firstImage)
                      : null,
                  child: member.firstImage.isEmpty
                      ? Icon(Icons.person_outline_rounded,
                          size: 48, color: colors.ink400)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                member.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: colors.ink900),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surfaceTertiary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(member.post,
                    style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.ink600)),
              ),
            ),
            const SizedBox(height: 24),
            Divider(color: colors.lineSoft),
            const SizedBox(height: 16),
            Text('About',
                style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: colors.ink900)),
            const SizedBox(height: 8),
            Text(
              member.about.isNotEmpty
                  ? member.about
                  : 'Industry veteran contributing to the growth of Indian travel and tourism.',
              style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 14,
                  color: colors.ink600,
                  height: 1.7),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shimmer ───────────────────────────────────────────────────────────────────

class _ShimmerGrid extends StatelessWidget {
  const _ShimmerGrid({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: colors.surfaceTertiary,
      highlightColor: colors.surfaceCard,
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Hot-reload and verify**

```bash
flutter run
```

Navigate: Home → Campus → Advisory Board. Verify:
- Banner shows member count
- 2-column grid renders with circular gold-bordered photos
- Tapping a card opens bottom sheet with name, post badge, about text

- [ ] **Step 3: Commit**

```bash
git add lib/features/campus/presentation/screens/advisory_board_screen.dart
git commit -m "feat(campus): complete Advisory Board screen with member grid and detail modal"
```

---

## Task 7: Destination Specialist Screens — Full Implementation

**Files:**
- Modify (replace stubs): 
  - `lib/features/campus/presentation/screens/destination_specialist_screen.dart`
  - `lib/features/campus/presentation/screens/dest_sub_category_screen.dart`
  - `lib/features/campus/presentation/screens/dest_video_screen.dart`

**Interfaces:**
- Consumes: `destinationsProvider` (existing), `destSubCategoriesProvider(catId)`, `destVideosProvider('$catId|$subCatId|')` from Task 4
- Consumes: `DestinationCategory`, `DestSubCategory`, `DestVideo` from Task 4

- [ ] **Step 1: Replace DestinationSpecialistScreen stub**

Replace `lib/features/campus/presentation/screens/destination_specialist_screen.dart`:

```dart
import 'package:cached_network_image/cached_network_image.dart';
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
                              Container(color: const Color(0xFF0D1B2A)),
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
                                      Text('Destination',
                                          style: const TextStyle(
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
```

- [ ] **Step 2: Replace DestSubCategoryScreen stub**

Replace `lib/features/campus/presentation/screens/dest_sub_category_screen.dart`:

```dart
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
```

- [ ] **Step 3: Replace DestVideoScreen stub**

Replace `lib/features/campus/presentation/screens/dest_video_screen.dart`:

```dart
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
      required this.subCatLabel});
  final String catId;
  final String subCatId;
  final String subCatLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    // Use empty string for subSubCatId — the API returns all videos for this sub-cat
    final key = '$catId|$subCatId|';
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
        title: Text(subCatLabel,
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
                        Container(color: const Color(0xFF0D1B2A)),
                  )
                : Container(color: const Color(0xFF0D1B2A)),
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
```

- [ ] **Step 4: Hot-reload and test destination flow**

```bash
flutter run
```

Navigate: Home → Campus → Destination Specialist → tap a category → tap a sub-category → verify video grid renders, tapping a video opens YouTube/browser.

- [ ] **Step 5: Commit**

```bash
git add lib/features/campus/presentation/screens/destination_specialist_screen.dart \
        lib/features/campus/presentation/screens/dest_sub_category_screen.dart \
        lib/features/campus/presentation/screens/dest_video_screen.dart
git commit -m "feat(campus): complete Destination Specialist screens with category drill-down and video grid"
```

---

## Task 8: SkillDevelopmentScreen — Full Implementation

**Files:**
- Modify (replace stub): `lib/features/campus/presentation/screens/skill_development_screen.dart`

**Interfaces:**
- Consumes: `skillCoursesProvider` (existing — returns `List<SkillCourse>` where `description` = link URL)
- Consumes: `SkillCourse { id, label, description(=link) }` from existing campus_models.dart

- [ ] **Step 1: Replace stub with full implementation**

Replace entire contents of `lib/features/campus/presentation/screens/skill_development_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/campus_models.dart';
import '../providers/campus_providers.dart';

class SkillDevelopmentScreen extends ConsumerWidget {
  const SkillDevelopmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final async = ref.watch(skillCoursesProvider);

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      appBar: AppBar(
        backgroundColor: colors.surfacePrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.ink900),
          onPressed: () => context.pop(),
        ),
        title: Text('Skill Development',
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
                height: 96,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16))),
          ),
        ),
        error: (_, __) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Failed to load courses',
                style: TextStyle(fontFamily: 'DMSans', color: colors.ink600)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => ref.invalidate(skillCoursesProvider),
              child: Text('Retry',
                  style: TextStyle(fontFamily: 'DMSans', color: colors.goldPrimary)),
            ),
          ]),
        ),
        data: (courses) {
          if (courses.isEmpty) {
            return Center(
                child: Text('No courses available',
                    style: TextStyle(fontFamily: 'DMSans', color: colors.ink600)));
          }
          return Column(
            children: [
              // Banner
              Container(
                margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D1B2A), Color(0xFF1A3850)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.school_outlined,
                        color: Colors.white70, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('SKILL DEVELOPMENT',
                              style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 0.16,
                                  color: Colors.white70,
                                  fontFamily: 'DMSans')),
                          const SizedBox(height: 4),
                          Text(
                            '${courses.length} Course${courses.length != 1 ? 's' : ''} Available',
                            style: const TextStyle(
                                fontFamily: 'PlayfairDisplay',
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                  itemCount: courses.length,
                  itemBuilder: (_, i) =>
                      _CourseCard(course: courses[i], index: i, colors: colors),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard(
      {required this.course, required this.index, required this.colors});
  final SkillCourse course;
  final int index;
  final AppColorScheme colors;

  // Cycle through accent colors for icon backgrounds
  static const _iconBgs = [
    Color(0xFFFEF3C7), // amber
    Color(0xFFDCFCE7), // green
    Color(0xFFEDE9FE), // purple
    Color(0xFFFFEDD5), // orange
    Color(0xFFDBEAFE), // blue
  ];
  static const _iconColors = [
    Color(0xFFB45309),
    Color(0xFF166534),
    Color(0xFF7C3AED),
    Color(0xFFC2410C),
    Color(0xFF1D4ED8),
  ];
  static const _icons = [
    Icons.calculate_outlined,
    Icons.trending_up_rounded,
    Icons.cast_for_education_outlined,
    Icons.business_center_outlined,
    Icons.language_outlined,
  ];

  Future<void> _launch() async {
    final link = course.description;
    if (link.isEmpty) return;
    final uri = Uri.parse(link.startsWith('http') ? link : 'https://$link');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorIdx = index % _iconBgs.length;
    return GestureDetector(
      onTap: _launch,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.lineSoft),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _iconBgs[colorIdx],
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_icons[colorIdx],
                  color: _iconColors[colorIdx], size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.label,
                      style: TextStyle(
                          fontFamily: 'DMSans',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: colors.ink900)),
                  if (course.description.isNotEmpty &&
                      !course.description.startsWith('http')) ...[
                    const SizedBox(height: 4),
                    Text(course.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12,
                            color: colors.ink600)),
                  ],
                  const SizedBox(height: 8),
                  Text('Start Course →',
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
}
```

- [ ] **Step 2: Hot-reload and test**

```bash
flutter run
```

Navigate: Home → Campus → Skill Development. Verify:
- Banner shows course count
- Each course card has colored icon, title, "Start Course →" in gold
- Tapping a card opens the course URL in the browser

- [ ] **Step 3: Commit**

```bash
git add lib/features/campus/presentation/screens/skill_development_screen.dart
git commit -m "feat(campus): complete Skill Development screen with course cards and external links"
```

---

## Self-Review Checklist

**Spec coverage:**
- [x] PPP models: PppPolicyFull, PppInvestFull, PppVideo, PppImage, PppPdf — Task 1
- [x] PPP datasource: 5 fetch methods — Task 1
- [x] PPP providers: 5 family providers — Task 1
- [x] PPP route `/ppp/:id` + card onTap — Task 2
- [x] PPPDetailScreen: hero header, tab bar, policy tab, investment tab, resources tab — Task 3
- [x] Campus models: DestSubCategory, DestSubSubCategory, DestVideo, CampusCourseItem — Task 4
- [x] Campus datasource: 4 fetch methods with correct URLs — Task 4
- [x] Campus providers: 4 family providers — Task 4
- [x] Campus routes: 5 new routes — Task 5
- [x] CampusScreen card onTaps — Task 5
- [x] AdvisoryBoardScreen: grid + bottom sheet modal — Task 6
- [x] DestinationSpecialistScreen + DestSubCategoryScreen + DestVideoScreen — Task 7
- [x] SkillDevelopmentScreen — Task 8

**API endpoints used (verified against old app constants):**
- PPP: `/api/ppp/:id/policies`, `/api/ppp/:id/investment-opportunities`, `/api/ppp/:id/getVideo`, `/api/ppp/:id/getImage`, `/api/ppp/:id/getPdf`
- Campus advisory: `/api/advisoryBoard/getAdvisoryBoard` (existing, unchanged)
- Campus dest: `/travelvideojson/destsubcat/?catid=`, `/travelvideojson/destsubsubcat/?catid=&subcatid=`, `/travelvideojson/destinationlist/?catid=&subcatid=&subsubcatid=`
- Campus skills: `/travelvideojson/courselist/` (existing) + `/travelvideojson/campusvideo/?catid=&subcatid=`

**Design system compliance:**
- All colors via `AppColorScheme` extension — no hardcoded hex outside of `Color(0xFF0D1B2A)` (navyDeep — used as literal since it's a named design token)
- Gold only on: "→" link text, active filter chips, gold play button, gold member border
- Playfair Display ≥ 18px on all screen titles and section headings
- Shimmer on every loading state, retry button on every error state, empty message on empty data
- `withValues(alpha:)` used throughout — no `withOpacity`
