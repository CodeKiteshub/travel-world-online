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
| 3 | **Associations — flagship module, first section**: horizontal cards (logo, name, type) | `associationsProvider` | card/See All → Associations tab |
| 4 | Icon row — 4 tiles: Video · Campus · PPP · Jobs | static | each pushes its module route |
| 5 | Quick Actions — Insurance + Visa cards | static | `/services/insurance`, `/services/visa` |
| 6 | Luxury Stays — horizontal image cards | `luxuryHotelsProvider` | card → hotel detail, See All → Marketplace tab |
| 7 | Open Jobs — 2 compact rows | `jobsProvider` | See All → `/jobs` |

## Deliberately skipped (per user, 2026-07-14)

- **News tile + Top Stories section** — user removed the News module from home;
  code kept commented out in `home_screen.dart` / `home_sections.dart` for easy restore.
- **Latest Videos section** — user removed it (Video stays reachable via icon row);
  section widget kept in `home_sections.dart`, usage commented out.
- **Notification bell** — removed by user; also no notifications backend exists.
- **TV LIVE widget** — removed by user; no live-stream API anywhere in the codebase.
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
