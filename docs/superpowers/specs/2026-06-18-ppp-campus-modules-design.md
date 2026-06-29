# PPP & Campus Modules — Design Spec

**Date:** 2026-06-18  
**Branch:** feature/secondary-modules  
**Status:** Approved by user

---

## 1. Scope

Complete the PPP (Tourism Boards) and Campus modules in the new_travel Flutter app.
Both modules already have a landing screen and partial data layer; this spec covers
everything still missing: PPP detail, and all three Campus sub-sections with full
navigation and API integration.

---

## 2. PPP Module

### 2.1 What exists

| File | State |
|---|---|
| `lib/features/ppp/presentation/screens/ppp_screen.dart` | ✅ List screen (International/Domestic toggle, search, cards) |
| `lib/features/ppp/data/datasources/ppp_remote_datasource.dart` | Partial — only `fetchAll()` |
| `lib/features/ppp/data/models/ppp_model.dart` | Partial — `PppItem`, `PppPolicy` (no details), `PppInvestment` (no details) |
| `lib/features/ppp/presentation/providers/ppp_providers.dart` | Only `pppAllProvider` |

### 2.2 PPP API endpoints (from old app)

| Method | Endpoint | Used for |
|---|---|---|
| GET | `/api/ppp` | All tourism boards (already wired) |
| GET | `/api/ppp/:id/policies` | Tourism policy list with HTML details |
| GET | `/api/ppp/:id/investment-opportunities` | Investment opportunity list with HTML details |
| GET | `/api/ppp/:id/getVideo` | Resource videos (`[{Imageurl, Url, ...}]`) |
| GET | `/api/ppp/:id/getImage` | Resource images (`[{Url, ...}]`) |
| GET | `/api/ppp/:id/getPdf` | Resource e-brochures (`[{Imageurl, Url, ...}]`) |

### 2.3 New models

```
PppPolicyFull   { id, policyName, policyDetails(HTML) }
PppInvestFull   { id, opportunityName, opportunityDetails(HTML) }
PppVideo        { id, imageUrl, videoUrl }
PppImage        { id, imageUrl }
PppPdf          { id, imageUrl, pdfUrl }
```

### 2.4 New providers (family providers — keyed by board id)

```
pppPoliciesProvider(String id)     → FutureProvider<List<PppPolicyFull>>
pppInvestmentsProvider(String id)  → FutureProvider<List<PppInvestFull>>
pppVideosProvider(String id)       → FutureProvider<List<PppVideo>>
pppImagesProvider(String id)       → FutureProvider<List<PppImage>>
pppPdfsProvider(String id)         → FutureProvider<List<PppPdf>>
```

### 2.5 PPPDetailScreen layout

```
CustomScrollView
├── SliverAppBar (expandedHeight 240, pinned)
│   ├── Hero image (CachedNetworkImage, BoxFit.cover)
│   ├── Gradient overlay bottom → transparent
│   ├── Board name (Playfair Display 22, white, bottom-left)
│   ├── Type badge pill (Domestic/International, bottom-right)
│   ├── Back icon button (top-left, white)
│   └── Actions: Directory icon + Register text button (top-right, white)
├── SliverPersistentHeader (pinned) — 3-tab pill bar
│   └── Policy | Investment | Resources
│       AnimatedContainer highlight slides between tabs
└── SliverFillRemaining
    └── TabBarView (NeverScrollableScrollPhysics)
        ├── PolicyTab
        │   └── FutureProvider → shimmer / error / ExpansionTile list
        │       Each tile: policyName header, HtmlWidget body
        ├── InvestmentTab
        │   └── Same pattern, opportunityName / opportunityDetails
        └── ResourcesTab
            ├── FilterChips row: Videos · Photos · E-Brochures
            └── AnimatedSwitcher → content grid per chip
                Videos:  2-col thumbnail grid, navy play overlay → video player
                Photos:  2-col CachedNetworkImage grid → tap → full-screen Dialog
                PDFs:    vertical list of tiles (thumbnail + title) → PDF viewer
```

### 2.6 Navigation changes

- `_PPPCard.onTap` → `context.push(RouteNames.pppDetail, extra: item)`
- New route in `app_router.dart`:
  - `/ppp/:id` → `PPPDetailScreen` (slideLeft transition)
- `RouteNames.pppDetail = '/ppp/:id'` added to `route_names.dart`

---

## 3. Campus Module

### 3.1 What exists

| File | State |
|---|---|
| `lib/features/campus/presentation/screens/campus_screen.dart` | ✅ Hub screen (3 module cards, counts from API) |
| `lib/features/campus/data/datasources/campus_remote_datasource.dart` | `fetchAdvisoryBoard()`, `fetchSkillCourses()`, `fetchDestinations()` |
| `lib/features/campus/data/models/campus_models.dart` | `AdvisoryBoardMember`, `SkillCourse`, `DestinationCategory` |
| `lib/features/campus/presentation/providers/campus_providers.dart` | `advisoryBoardProvider`, `skillCoursesProvider`, `destinationsProvider` |

### 3.2 Campus API endpoints (from old app)

All `twoDio` calls use base URL `travelworldonline.in`. Response shape: `[{"tblvideocats": [...]}]`.  
All `backendDio` calls use the main backend.

| Method | Endpoint | Dio | Used for |
|---|---|---|---|
| GET | `/api/advisoryBoard/getAdvisoryBoard` | backendDio | Advisory board member list |
| GET | `/travelvideojson/courselist/` | twoDio | Skill course categories |
| GET | `/travelvideojson/coursevideolist/?catid=:catId` | twoDio | Courses in a category |
| GET | `/travelvideojson/destcat/` | twoDio | Destination top-level categories |
| GET | `/travelvideojson/destsubcat/?catid=:catId` | twoDio | Destination sub-categories |
| GET | `/travelvideojson/destsubsubcat/?catid=:catId&subcatid=:subCatId` | twoDio | Destination sub-sub-categories |
| GET | `/travelvideojson/destinationlist/?catid=:catId&subcatid=:subCatId&subsubcatid=:subSubCatId` | twoDio | Destination videos |

### 3.3 New models

```
CampusCourseItem     { id, name, link, imageUrl? }        — course within a category
DestSubCategory      { id, label, imageUrl }               — destination sub-cat
DestSubSubCategory   { id, label, imageUrl }               — destination sub-sub-cat
DestVideo            { id, heading, imageUrl, videoUrl, detail, place }
```

### 3.4 New providers (family providers — keyed by id)

```
campusCourseItemsProvider(String catId)                          → FutureProvider<List<CampusCourseItem>>
destSubCategoriesProvider(String catId)                          → FutureProvider<List<DestSubCategory>>
destSubSubCategoriesProvider(String catId, String subCatId)      → FutureProvider<List<DestSubSubCategory>>
destVideosProvider(String catId, String subCatId, String sscId)  → FutureProvider<List<DestVideo>>
```

### 3.5 Screen designs

#### AdvisoryBoardScreen (`/advisory-board`)
```
Scaffold
├── AppBar: "Advisory Board", back button
└── body: FutureProvider → shimmer / error / GridView.builder (crossAxisCount 2)
    Each MemberCard:
      ClipRRect(radius 16)
      ├── Image.network (CachedNetworkImage, 1:1 aspect, cover)
      ├── Gold ring border (Container decoration)
      ├── Name (DM Sans 13 bold, 2 lines max)
      └── Post (DM Sans 11, ink600, 1 line)
    onTap → showModalBottomSheet
      ModalSheet:
        ├── Drag handle
        ├── CircleAvatar (radius 48, gold border)
        ├── Name (Playfair Display 22)
        ├── Post badge pill
        ├── Divider
        └── About text (DM Sans 14, scrollable)
```

#### DestinationSpecialistScreen (`/destination-specialist`)
```
Scaffold
├── AppBar: "Destination Specialist", back button
└── body: FutureProvider (destinationsProvider) → ListView of DestCategoryCard
    DestCategoryCard:
      Container(margin 16h 8v, radius 16, surfaceSecondary + lineSoft border)
      ├── CachedNetworkImage (16:9, top rounded)
      ├── Name (Playfair Display 18)
      └── "Explore →" (gold, 12)
    onTap → push /destination-specialist/:catId
```

#### DestSubCategoryScreen (`/destination-specialist/:catId`)
```
Same scaffold pattern, fetches destSubCategoriesProvider(catId)
Cards show sub-category name + image
onTap → push /destination-specialist/:catId/:subCatId
```

#### DestSubSubCategoryScreen (`/destination-specialist/:catId/:subCatId`)
```
Fetches destSubSubCategoriesProvider(catId, subCatId)
If empty list → go directly to DestVideoScreen (pass catId + subCatId + '')
Else show list → onTap → DestVideoScreen
```

#### DestVideoScreen (`/destination-specialist/:catId/:subCatId/:subSubCatId`)
```
Scaffold
├── AppBar: sub-sub-cat name or sub-cat name
└── body: FutureProvider → 2-col GridView
    VideoThumbnailCard:
      Stack
      ├── CachedNetworkImage (cover)
      ├── Navy gradient overlay bottom
      ├── Play button overlay (center)
      └── Heading text (bottom, white, 11, 2 lines)
    onTap → push /video-player (or open YouTube)
```

#### SkillDevelopmentScreen (`/skill-development`)
```
Scaffold
├── AppBar: "Skill Development", back button
└── body: FutureProvider (skillCoursesProvider) → ListView of SkillCategoryCard
    SkillCategoryCard:
      Container(margin 16h 8v, radius 16, padding 20)
      ├── Row: icon square (warningBg) + title (Playfair 18) + count
      ├── Description text (ink600, 12)
      └── "Explore Courses →" (gold, 12)
    onTap → push /skill-development/:catId
```

#### CourseListScreen (`/skill-development/:catId`)
```
Scaffold
├── AppBar: category label
└── body: FutureProvider (campusCourseItemsProvider(catId))
    ListView of CourseCard:
      Container(radius 16, surfaceSecondary, padding 16)
      ├── Course name (DM Sans 15 bold)
      ├── Link preview (ink400, 12, max 2 lines)
      └── "Start Course →" TextButton (gold) → url_launcher
```

### 3.6 Navigation changes

- `CampusScreen` module cards each get `onTap`:
  - Advisory Board → `context.push(RouteNames.advisoryBoard)`
  - Destination Specialist → `context.push(RouteNames.destinationSpecialist)`
  - Skill Development → `context.push(RouteNames.skillDevelopment)`
- New routes added to `app_router.dart` (all slideLeft):
  - `/advisory-board`
  - `/destination-specialist`
  - `/destination-specialist/:catId`
  - `/destination-specialist/:catId/:subCatId`
  - `/destination-specialist/:catId/:subCatId/:subSubCatId`
  - `/skill-development`
  - `/skill-development/:catId`
- `route_names.dart` gets all new constants

---

## 4. Design System Rules Applied

- Colors: `Theme.of(context).extension<AppColorScheme>()!` — no hardcoded hex
- Typography: Playfair Display for titles (min 18px), DM Sans for body
- Spacing: 8px grid (multiples of 4/8/16/24/32)
- Gold ONLY on: primary CTA, active tab, "→" link labels, featured price
- Every data screen: shimmer loading state, empty state widget, retry error state
- Min touch targets 48×48px
- Animations: Transform/Opacity only, `AppAnimations` durations
- Haptic: light on card tap, medium on tab switch

---

## 5. Files to Create / Modify

### New files
```
lib/features/ppp/presentation/screens/ppp_detail_screen.dart
lib/features/campus/presentation/screens/advisory_board_screen.dart
lib/features/campus/presentation/screens/destination_specialist_screen.dart
lib/features/campus/presentation/screens/dest_sub_category_screen.dart
lib/features/campus/presentation/screens/dest_sub_sub_category_screen.dart  (or merged)
lib/features/campus/presentation/screens/dest_video_screen.dart
lib/features/campus/presentation/screens/skill_development_screen.dart
lib/features/campus/presentation/screens/course_list_screen.dart
```

### Modified files
```
lib/features/ppp/data/models/ppp_model.dart            — add PppPolicyFull, PppInvestFull, PppVideo, PppImage, PppPdf
lib/features/ppp/data/datasources/ppp_remote_datasource.dart  — add 5 new fetch methods
lib/features/ppp/presentation/providers/ppp_providers.dart    — add 5 family providers
lib/features/ppp/presentation/screens/ppp_screen.dart         — add onTap to _PPPCard
lib/features/campus/data/models/campus_models.dart            — add CampusCourseItem, DestSubCategory, DestSubSubCategory, DestVideo
lib/features/campus/data/datasources/campus_remote_datasource.dart  — add 4 new fetch methods
lib/features/campus/presentation/providers/campus_providers.dart    — add 4 family providers
lib/features/campus/presentation/screens/campus_screen.dart         — add onTap to module cards
lib/core/router/app_router.dart                        — add 8 new routes
lib/core/router/route_names.dart                       — add 8 new route name constants
```
