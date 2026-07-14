# Homepage Redesign — Full Dashboard (approved 2026-07-14)

## Goal

The v1.3 home screen was never finished (only app bar + deals carousel + 4-icon row).
Redesign it as a full dashboard that surfaces every live module in the app, using
only existing providers/models/routes — no new packages, no new endpoints.

## Layout (top → bottom)

| # | Section | Data source | Tap targets |
|---|---------|-------------|-------------|
| 1 | App bar (avatar, date, greeting) | unchanged | avatar → Account |
| 2 | Deals carousel | `featuredDealsProvider` | unchanged |
| 3 | Icon row — **5 tiles**: News · Video · Campus · PPP · Jobs | static | each pushes its module route |
| 4 | Quick Actions — Insurance + Visa cards | static | `/services/insurance`, `/services/visa` |
| 5 | Top Stories — 1 hero + 2 compact cards, gold "See All" | `newsProvider` (home feature) | article → `/news/article`, See All → `/news` |
| 6 | Luxury Stays — horizontal image cards | `luxuryHotelsProvider` | card → hotel detail, See All → Marketplace tab |
| 7 | Latest Videos — horizontal YouTube-thumb cards | `videoFeedProvider` | card/See All → `/video` |
| 8 | Open Jobs — 2 compact rows | `jobsProvider` | See All → `/jobs` |
| 9 | Your Associations — horizontal logo chips | `associationsProvider` | chip/See All → Associations tab |

## Deliberately skipped

- **Notification bell** — no notifications backend exists; dead button. Add when one does.
- **TV LIVE widget** — no live-stream API anywhere in the codebase; spec says it hides
  when nothing is live, and nothing can ever be live yet.
- **Radio mini-player** — same; no radio backend.

## Behavior rules

- Loading: flat `surfaceTertiary` skeleton per section (existing home pattern).
- Error or empty data: the section **collapses entirely** (`SizedBox.shrink`).
  Full error/empty states live on the module screens, per hard rules.
- All tokens from `lib/core/theme/`; gold only on See-All links + HOT DEAL badge.
- Section headers: Playfair (displayMd) ~19px + gold DM Sans "See All →".

## Structure

- `home_screen.dart` keeps scaffold + app bar + carousel + icon row (News tile added).
- New `lib/features/home/presentation/widgets/home_sections.dart` holds the section
  widgets (header, quick actions, top stories, stays, videos, jobs, associations).
