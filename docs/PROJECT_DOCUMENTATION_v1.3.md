# Travel World Online — Product & Design Documentation

> **Version 1.3** — June 2026. Supersedes v1.2.
>
> **What changed from v1.2:**
> 1. Bottom nav changed from 4 tabs (Home/Browse/TV/Account) to **5 tabs (Home/Marketplace/Associations/Services/Account)**
> 2. **TV removed from bottom nav** — becomes a conditional LIVE widget on Home
> 3. **"B2B" label eliminated** — broken into Marketplace, Associations, Services (each with their own tab)
> 4. **"Browse" tab eliminated** — the 5 specific tabs replace the generic directory
> 5. **Hamburger drawer eliminated** — no content justified it; secondary modules live on Home icon row; utility items move to Account
> 6. **Radio stays as persistent mini-player** above bottom nav (unchanged from v1.2)
> 7. **Home simplified** — deals carousel + TV widget + icon row (5 secondary modules) + news section
> 8. **DTN future modules deferred** — Religious Travel, Budget Packages, Earn Commission, My Business Dashboard are documented but not designed in this version

---

## 1. Navigation Architecture (LOCKED)

### Bottom Navigation — 5 Tabs

```
  🏠           🛒              🤝              📋           👤
 Home      Marketplace    Associations     Services      Account
```

| Tab | What it holds | Mode |
|---|---|---|
| **Home** | Daily dashboard: deals, TV LIVE widget, icon row for secondary modules, news | Both modes |
| **Marketplace** | Holiday deals: Package/Hotel/Trains/Cruise/Cabs/Flights, search, Post a Deal | Both modes |
| **Associations** | Gated list of 9+ orgs (National/Regional/International/DMC filter), Sign In per org → Dashboard | Light only |
| **Services** | Insurance wizard, Visa form, Forex (Coming Soon) | Light only |
| **Account** | Profile, Membership, Preferences, Support, Logout/Delete | Light only |

### No Drawer

The hamburger drawer is eliminated. Reasons:
- My Activity (Bookings, Enquiries) doesn't exist in the current app
- Support items (Help, Privacy, Refund) move to Account tab
- Dark Mode toggle moves to Account > Preferences
- The only remaining items (Video, Campus, PPP, Jobs) live on Home's icon row
- A drawer with 4 items feels empty and unfinished

### No Browse Tab

With 5 specific tabs, there's nothing generic left to browse. Each tab IS a destination. The old "Browse" was a directory of modules — those modules now have direct tabs.

### App Bar Pattern

Every screen uses the same app bar:

**Home tab:** `[Avatar photo] Wednesday, 10 June · Good Morning, Rakesh [🔔]`
- Left: user's circular profile photo (tapping goes to Account tab)
- Centre: date + greeting
- Right: notification bell (with red dot when unread)

**Other tabs:** `[← back] Tab Title [action icon]`
- Standard sub-screen header

### Radio Mini-Player

Unchanged from v1.2. A 60px strip pinned above the bottom nav when audio is playing. Persists across all screens. Tapping expands to full Radio player.

---

## 2. Home Tab — Screen Specification

**Purpose:** Daily dashboard. The 3 things an agent checks every time they open the app: deals, live TV, and news.

### Layout (top to bottom)

**1. App Bar**
```
[👤 avatar]  Wednesday, 10 June              [🔔]
             Good Morning, Rakesh
```
- Avatar: 36px circular, gold 2px border, links to Account tab
- Date: DM Sans 11px, ink-600, uppercase tracking
- Greeting: DM Sans 17px, font-weight 600, ink-900
- Notification bell: with conditional red dot

**2. Deals Carousel**
- Horizontal scroll, full-width cards (280px wide, 5:3 aspect ratio)
- Each card: background photo + gradient overlay + "Hot Deal" gold tag (top-left) + "X Day" glass chip (top-right) + deal name (Playfair 18px) + gold price + location
- Scroll-snap alignment, 3+ cards
- Gold pagination dots below (optional)

**3. TV LIVE Widget (conditional)**
- Only visible when a live stream is active. Hides completely when nothing is live.
- Navy dark card, full width, rounded 16px
- Left: red pulsing LIVE dot + "LIVE" label
- Centre: show title ("Breaking News TWO TV")
- Right: gold play button
- Tapping opens fullscreen TV player

**4. Icon Row — Secondary Modules**
- 5 horizontally arranged icon tiles: **News · Video · Campus · PPP · Jobs**
- Each tile: 56×56px icon container (surface-card bg, line-soft border, 16px radius) + 10px label below (DM Sans 10px, font-weight 600)
- Icons are ink-900 (NOT gold)
- Tiles are evenly spaced across the width, NOT scrollable (5 fit comfortably at 380px)
- Tapping any tile navigates to that module's full screen

**5. Top Stories — News Section**
- Section header: "Top Stories" (Playfair 19px) + "See All →" (gold, DM Sans 12px 600)
- 1 hero news card: full-width image (16:10), category tag overlay (e.g., "AVIATION"), headline (DM Sans 15px 600), source + time meta
- 2 compact news cards: 80px thumbnail (left) + category eyebrow (gold caps) + headline (2-line clamp) + source/time meta

**6. Radio Mini-Player (conditional)**
- Only visible when audio is playing
- Pinned above bottom nav
- Navy dark bg, 14px radius, small shadow
- Left: gold gradient radio icon (40px)
- LIVE dot + channel name
- Right: close X + gold play/pause button

**7. Bottom Nav**
- 5 tabs: Home (active, gold) / Marketplace / Associations / Services / Account
- Ink-400 for inactive, gold-primary for active

### Total scroll height: ~1.5 screens. Fast and focused.

---

## 3. Marketplace Tab — Screen Specification

**Purpose:** The commercial heart of the app. Browse and post B2B holiday deals.

**Default mode:** Both modes supported

### Layout

**App Bar:** `[← back] Marketplace [🔍 search]`

**Filter Pills (sticky, scrollable):**
```
[Package] [Hotel] [Trains] [Cruise] [Cabs] [Flights]
```
Active pill: ink-900 bg, surface-primary text. Inactive: transparent, line-soft border.

**Search Bar** (below pills): "Search for title, details or organisation name"

**Featured Deals Section:**
- Section header: "Featured Deals" + "See All →"
- Large hero deal card (full width) with image, tag, title, price, rating
- Below: horizontal scroll of smaller deal cards

**All Deals Grid:**
- Infinite scroll vertical list
- Each card: image with category tag + heart icon + title + sub-info + gold price + struck-through original + green discount badge

**Post a Deal FAB:**
- Floating action button, bottom-right, above bottom nav
- Gold primary bg, "+" icon + "Post Deal" label
- Shadow for elevation

### Deal Detail (sub-screen)
Same design as v1.1 — image hero, info section, amenities, price breakdown, "Send Enquiry" gold CTA.

### Deal Enquiry (sub-screen)
Same form design as v1.1.

---

## 4. Associations Tab — Screen Specification

**Purpose:** The gated professional network. Each association requires separate authentication.

**Default mode:** Light only

### Layout

**App Bar:** `[← back] Associations [🔍 search]`

**Filter Pills (sticky):**
```
[National] [Regional] [International] [DMC]
```

**Association List:**
Each row:
- Association logo (56px, left)
- Association name (DM Sans 15px 600)
- Full name below (DM Sans 11px, ink-600)
- **Right side:**
  - If NOT signed in: "Sign In" outlined button
  - If signed in: "Sign Out" red outlined button + green "Active" chip

**Tapping "Sign In"** → Sign-In Modal Sheet:
- Association logo centered (large)
- Username/Email field
- Password field
- "Login" primary gold CTA
- "Get Password" secondary green button
- Red note: "Please ask your association if your email id is not registered"

### Association Dashboard (after sign-in)

**App Bar:** `[← back] TAAI [LIVE badge]`

**Hero:** LIVE stream embed (YouTube player or native) — takes top ~40% of screen

**Module Grid (3 columns, 3 rows):**
```
[B2B]        [Circular]     [Updates]
[Chat]       [Job Section]  [Directory]
[Cab Section] [Admin Cab]
```
Each tile: 44px icon in dark circle + label below.

Tapping any tile opens that module scoped to the association:
- **B2B (Deals):** 3-level nested tabs — Buyers/Sellers/Last Min Deals → Offers/Create Offers/My Offers → Packages/Hotels/Transport/Flights
- **Circular:** List of PDF/document circulars with dates
- **Updates:** Association announcements feed
- **Chat:** Member-to-member messaging (Amrita Kumari, Vinay Kumar, etc.)
- **Job Section:** "Post A Job" CTA + search + job list (scoped to this association only)
- **Directory:** Member directory for this association only
- **Cab Section:** Cab driver acceptance list (Name, City, State, Vehicle Type, Accept button)
- **Admin Cab:** Admin view for managing cab network

---

## 5. Services Tab — Screen Specification

**Purpose:** Transactional booking tools for client services.

**Default mode:** Light only

### Layout

**App Bar:** `[← back] Services`

**3 Service Cards stacked vertically:**

```
┌─────────────────────────────────────┐
│  🛡️  Insurance                      │
│  Book travel insurance for clients  │
│  4-step wizard · Instant policy     │
│                          Start →    │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  📄  Visa                           │
│  Submit visa applications           │
│  Country selection · Doc upload     │
│                          Apply →    │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  💱  Forex                          │
│  Currency exchange & rates          │
│  Coming Soon                        │
│                                     │
└─────────────────────────────────────┘
```

Each card: large icon (in tinted background), service name (Playfair 18px), description, action link (gold). Forex card has a "Coming Soon" badge and is non-tappable.

### Insurance Sub-flow
4-step wizard (same as v1.2): Trip Details → Choose Plan → Traveller Details → Review & Pay

### Visa Sub-flow
Multi-step form (same as v1.2): Personal Info → Travel Details → Documents → Review & Submit

---

## 6. Account Tab — Screen Specification

**Purpose:** Everything about the user — profile, preferences, support, and exit.

**Default mode:** Light only

### Layout

**App Bar:** `Account [⚙️ settings gear]` (no back arrow — it's a root tab)

**Profile Header Card:**
- Avatar (64px, gold border) + Name (Playfair 19px) + email + phone + edit icon

**Membership Card:**
- Navy gradient with gold radial glow
- "Active Membership" label + org name (Playfair 18px) + Member ID
- Green "Active" status chip

**Preferences Section:**
- Dark Mode toggle
- Notifications toggle
- Language selector (English default)

**Support Section:**
- Help & Support
- About (with version number)
- Privacy Policy
- Refund Policy
- Share App
- Rate App

**Destructive Section (bottom):**
- Logout (red text + icon)
- Delete Account (red, requires confirmation modal)

---

## 7. Secondary Modules (reached via Home icon row)

### News
**Reached via:** Home icon row → "News"
**7 category tabs:** Hotels / Associations / Airlines / Tourism Boards / Others / Destination / Travel Agents-Tour Operators
**Layout:** Tab bar (gold underline active) + scrollable news card list
**Article Detail:** Hero image + headline (Playfair) + source/date + body text + share

### Video
**Reached via:** Home icon row → "Video"
**3 tabs:** News / Interviews / Destinations
**Layout:** Featured video at top + video list below (thumbnail + title + duration)
**Mode:** Dark for player, both modes for list

### Campus
**Reached via:** Home icon row → "Campus"
**3 sub-modules:**
- Our Advisory Board → expert list → expert detail (B&W photo + bio)
- Destination Specialist Program → country list → circuit/destination content
- Skill Development → course list → course detail with video
**Mode:** Both modes for hub, light for detail pages

### PPP (Tourism Boards)
**Reached via:** Home icon row → "PPP"
**Top tabs:** PPP / Directory / Stakeholder Registration
**Toggle:** International Tourism Boards / Domestic Tourism Boards
**Board Detail:** YouTube embed + 3 tiles (Tourism Policy / Investment / Resources) + sub-tabs (About Us / Photographs / E-brochures / Hotels / Connectivity / Adventure Parks / Film Tourism)
**Mode:** Light only (information-dense)

### Jobs
**Reached via:** Home icon row → "Jobs"
**Toggle:** Job Available / Post Resume
**Search bar + filter chips**
**Job list:** title, company, location, time-ago, salary (gold)
**Mode:** Light only

---

## 8. Module Location Map (definitive)

```
APP
│
├─ AUTH (out of nav)
│  └─ Splash → Onboarding → Sign In/Register → Verify Email → Home
│
└─ MAIN APP (5-tab bottom nav)
   │
   ├─ TAB 1: HOME
   │  ├─ App bar (avatar → Account, date/greeting, notification bell)
   │  ├─ Deals carousel
   │  ├─ TV LIVE widget (conditional)
   │  ├─ Icon row → News, Video, Campus, PPP, Jobs
   │  ├─ Top Stories (news section)
   │  └─ Radio mini-player (conditional)
   │
   ├─ TAB 2: MARKETPLACE
   │  ├─ Filter: Package / Hotel / Trains / Cruise / Cabs / Flights
   │  ├─ Search bar
   │  ├─ Featured Deals
   │  ├─ All Deals (infinite scroll)
   │  ├─ Post a Deal FAB
   │  └─ Deal Detail → Deal Enquiry → Confirmation
   │
   ├─ TAB 3: ASSOCIATIONS
   │  ├─ Filter: National / Regional / International / DMC
   │  ├─ Association list (9+ orgs, each with Sign In)
   │  └─ [After Sign In] Association Dashboard
   │     ├─ LIVE stream
   │     ├─ B2B Deals (Buyers/Sellers/Last Min → 3-level tabs)
   │     ├─ Circulars
   │     ├─ Updates
   │     ├─ Chat (member list → messaging)
   │     ├─ Job Section
   │     ├─ Directory
   │     ├─ Cab Section
   │     └─ Admin Cab
   │
   ├─ TAB 4: SERVICES
   │  ├─ Insurance → 4-step wizard → Payment → Confirmation
   │  ├─ Visa → Multi-step form → Submission
   │  └─ Forex → Coming Soon placeholder
   │
   └─ TAB 5: ACCOUNT
      ├─ Profile header + edit
      ├─ Membership card
      ├─ Preferences (Dark Mode, Notifications, Language)
      ├─ Support (Help, About, Privacy, Refund, Share, Rate)
      └─ Logout / Delete Account

SECONDARY MODULES (reached via Home icon row):
├─ News → 7 category tabs → article list → article detail
├─ Video → 3 tabs (News/Interviews/Destinations) → video player
├─ Campus → 3 sub-modules (Advisory Board/Destination Specialist/Skill Dev)
├─ PPP → Tourism Boards directory → board detail with policy/investment/resources
└─ Jobs → Job Available / Post Resume → job detail → apply

PERSISTENT ELEMENTS:
├─ Radio mini-player (above bottom nav, when audio is playing)
└─ TV LIVE widget on Home (when live stream is active)
```

---

## 9. Design System (unchanged from v1.1/v1.2)

**Light tokens:** surface-primary #FAF8F3, surface-card #FFFFFF, gold-primary #C9A84C, ink-900 #1A1A1A, ink-600 #5E5E5E, ink-400 #9E9E9E, line-soft #E8E5DC, navy-deep #0D1B2A, success #2D7A4F, warning #B45309, error #C0392B

**Dark tokens:** surface-primary #0D1117, surface-card #161B22, gold-primary #D4AF37, ink-900 #E6EDF3, ink-600 #8B949E, line-soft #30363D

**Typography:** Playfair Display 700 for titles 18px+ ONLY. DM Sans for everything else.

**Gold rule:** Gold ONLY on single primary CTA per screen, active tab/nav indicator, featured prices, one premium badge per screen max.

**Tint blue:** #E8EEF5 light / rgba(88,166,255,0.12) dark — for informational elements, association badges, info icons.

---

## 10. Light vs Dark Mode Rules (v1.3)

| Screen | Mode |
|---|---|
| Auth screens (Splash, Login, Register, Verify) | Light only |
| Home | Both modes |
| Marketplace | Both modes |
| Deal Detail | Light only |
| Deal Enquiry form | Light only |
| Associations list | Light only |
| Association Sign-In modal | Dark (matches current app) |
| Association Dashboard | Light only |
| Services landing | Light only |
| Insurance/Visa/Forex forms | Light only |
| Account | Light only |
| News list + Article Detail | Both modes |
| Video list | Both modes |
| Video Player | Dark always |
| Campus hub | Both modes |
| Campus detail pages | Light only |
| PPP all screens | Light only |
| Jobs all screens | Light only |
| TV Player (fullscreen) | Dark always |
| Radio Player (fullscreen) | Dark always |
| Radio mini-player | Dark always (navy bg) |

---

## 11. Implementation Priority (v1.3)

| # | What to Build | Status |
|---|---|---|
| 1 | Design System | ✅ Done (01-design-system.html) |
| 2 | Auth Flow | ✅ Done (02-auth-flow.html) — user has coded this |
| 3 | **Home (new 5-tab, icon row, TV widget)** | 🔨 Next |
| 4 | **Marketplace tab landing** | 🔨 Next |
| 5 | **Associations tab landing + Sign-In modal** | 🔨 Next |
| 6 | **Services tab landing** | 🔨 Next |
| 7 | **Account tab** | 🔨 Next |
| 8 | Deal Detail + Deal Enquiry | ✅ Partially done (03-commercial-core.html — needs updated bottom nav) |
| 9 | Insurance 4-step wizard | To build |
| 10 | Association Dashboard (post-sign-in) | To build |
| 11 | News module (7 tabs) + Article Detail | To build |
| 12 | TV fullscreen player | To build |
| 13 | Radio mini-player + full player | To build |
| 14 | Video module (3 tabs) | To build |
| 15 | PPP module | To build |
| 16 | Campus module (3 sub-modules) | To build |
| 17 | Jobs module | To build |
| 18 | Visa form | To build |

---

## 12. Files Status

| File | Status in v1.3 |
|---|---|
| 01-design-system.html | ✅ Still valid |
| 02-auth-flow.html | ✅ Still valid (user coded) |
| 03-commercial-core.html | ⚠️ Partially valid — Deal Detail + Enquiry screens reusable, Home/B2B screens obsolete |
| 04-bottom-nav-landings.html | ❌ Obsolete (old 4-tab Discover/MySpace/Profile) |
| 05-associations.html | ⚠️ Partially valid — Hub/Detail/Circular/Community need rework for gated model |
| 06-my-space-subscreens.html | ❌ Obsolete (My Space tab eliminated) |
| 07-ia-foundation.html | ❌ Obsolete (old 4-tab Home/Browse/Drawer) |
| PROJECT_DOCUMENTATION_v1.1.md | ❌ Superseded |
| PROJECT_DOCUMENTATION_v1.2.md | ❌ Superseded |

---

*End of Document. Version 1.3 — June 2026. Based on live app video analysis, DTN screenshot review, and iterative architecture decisions.*
