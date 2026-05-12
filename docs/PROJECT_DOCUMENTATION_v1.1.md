# Travel World Online — Full Product & Design Documentation

> **Version 1.1** — May 2026. Supersedes v1.0.
> **What changed in this version:**
> 1. Colour palette updated — gold is now used sparingly (CTAs and active states only)
> 2. Typography rules refined — Playfair Display restricted to 18px and above
> 3. Bottom navigation locked at 4 tabs (Home / Discover / My Space / Profile)
> 4. Splash and onboarding direction changed from "tourism collage" to "editorial photography"
> 5. Three states (loading / empty / error) made mandatory for every data screen
> 6. Gold-usage rules per screen documented explicitly

> **Purpose of this document:** Written for any LLM, designer, or developer who needs to fully understand the Travel World Online app — what it does, who it serves, how every module works, and exactly how it should be built. This is a product-first, design-first document.

---

## 1. Product Identity

**App Name:** Travel World Online (also marketed as "Travel Business")
**Category:** B2B Travel Industry Platform
**Platforms:** iOS, Android (primary), Web (secondary)
**Current Version:** 2026.2.24

### What This App Is

Travel World Online is a super-app for Indian travel agents and travel associations. It is **not** a consumer booking app — it is a professional tool. Think of it as the Bloomberg Terminal of the Indian travel trade: news, deals, learning, networking, booking tools, and association management all in one place.

A travel agent opens this app to:
- Read the latest industry news
- Post or discover B2B deals (hotels, packages, transport, villas)
- Connect with their travel association
- Book insurance, visa, flights, cabs, luxury products for clients
- Learn and upskill through campus content
- Chat with peers and post/find jobs

### Who Uses This App

| User Type | Who They Are | What They Need |
|---|---|---|
| **Travel Agent** | Independent agent or small agency owner | News, B2B deals, bookings, jobs |
| **Association Member** | Agent who belongs to a trade association (TAAI, TAFI, etc.) | Association circulars, B2B within their association, live TV |
| **Association Admin** | Runs an association's digital presence | Post circulars, manage members, publish deals |
| **Destination Specialist** | Upskilling agent | Campus videos, advisory board content |
| **Job Seeker / Recruiter** | Travel professional looking for work or talent | Job board |
| **Luxury Product Seller** | Hotels, cruise lines, transport operators | Post luxury deals |

---

## 2. Design Vision

### The Redesign Mandate

The current app has no coherent design system. It uses mismatched colours, inconsistent font sizes, poor spacing, no animations, and a dark theme that feels oppressive rather than premium. It cannot be shown to a client or partner without embarrassment.

The redesign goal: **Make every screen feel like it belongs in a ₹10 lakh/year enterprise product.**

### Design Aesthetic: Premium & Restrained

Reference brands: Emirates App, Airbnb, Amex Platinum, Condé Nast Traveller digital.

The feeling when a user opens the app should be: *"This was built for serious professionals."*

**The core aesthetic principle (new in v1.1):** Premium does NOT mean "lots of gold". Premium means rare gold, generous whitespace, considered typography, and excellent photography. Restraint is the brand. If gold is on every button, it stops feeling like gold and starts feeling like decoration.

---

## 3. Design System

### 3.1 Colour Palette (Updated in v1.1)

#### Light Mode

| Token | Hex | Used For | Where It Appears |
|---|---|---|---|
| `surface-primary` | `#FAF8F3` | Main page background | All light-mode page backgrounds |
| `surface-card` | `#FFFFFF` | Card backgrounds | All cards, modals, sheets |
| `surface-tertiary` | `#EFEDE6` | Dividers, skeleton loaders, subtle containers | Skeletons, secondary containers |
| `gold-primary` | `#C9A84C` | **PRIMARY CTAs ONLY + active tab indicator** | Login button, Send Enquiry, Search Flights, active bottom-nav icon, deal price emphasis |
| `gold-accent` | `#E8D08A` | Premium badges, "BEST VALUE" chips | Max once per screen — sparingly |
| `ink-900` | `#1A1A1A` | Headings, page titles | All headlines, primary text |
| `ink-600` | `#5E5E5E` | Subtext, descriptions | Body copy, metadata |
| `ink-400` | `#9E9E9E` | Captions, placeholders, disabled | Timestamps, hint text |
| `navy-deep` | `#0D1B2A` | Dark accents on light screens | Section dividers, key data emphasis |
| `success` | `#2D7A4F` | Confirmed bookings, success states | "Confirmed" chip, success toasts |
| `warning` | `#B45309` | Alerts, pending states | "Pending" chip, warning toasts |
| `error` | `#C0392B` | Errors, cancellations | "Cancelled" chip, error toasts |
| `line-soft` | `#E8E5DC` | Card borders, input borders, dividers | Form fields, card outlines |

#### Dark Mode

| Token | Hex | Used For | Where It Appears |
|---|---|---|---|
| `surface-primary` | `#0D1117` | Main page background (deep ink, NOT pure black) | All dark-mode page backgrounds |
| `surface-card` | `#161B22` | Cards, elevated containers | All cards on dark screens |
| `surface-tertiary` | `#21262D` | Chips, tabs, subtle containers | Filter chips, tab backgrounds |
| `gold-primary` | `#D4AF37` | **PRIMARY CTAs ONLY + active tab indicator** | Slightly brighter in dark mode for legibility |
| `gold-accent-dim` | `#8B6914` | Muted gold for secondary accents | Premium badges in dark |
| `ink-100` | `#E6EDF3` | Headings, page titles | All headlines, primary text |
| `ink-300` | `#8B949E` | Subtext, descriptions | Body copy, metadata |
| `ink-500` | `#484F58` | Captions, placeholders, disabled | Timestamps, hint text |
| `navy-light` | `#58A6FF` | Links, interactive highlights | Hyperlinks, info accents |
| `success` | `#3FB950` | Success states | Confirmed booking chip |
| `warning` | `#D29922` | Pending states | Pending enquiry chip |
| `error` | `#F85149` | Error states | Cancelled chip, errors |
| `line-soft` | `#30363D` | Card borders, dividers | Form fields, card outlines |

#### When to Use Light vs Dark Mode (new in v1.1)

The app uses **both modes intentionally** — not as a user toggle alone, but as a deliberate design choice per screen type:

| Screen Type | Default Mode | Why |
|---|---|---|
| Splash, Onboarding, Login | Dark | Cinematic, premium first impression |
| Home | User's preference | Most-used screen — must respect user choice |
| B2B Marketplace home | Dark | Frames product photography beautifully |
| Deal Detail, Hotel Detail | Light | Information-dense, easier to read long form |
| Enquiry forms, Booking flows | Light | Forms need clarity, not atmosphere |
| Associations, Members, Bookings, Jobs, Profile | Light | Utility screens — readability first |
| Live TV, Radio, Video Player | Dark (always) | Media content reads best on dark |
| News list, Article Detail | User's preference | Reading experience |

User can override via the Dark/Light toggle in Profile, but each screen has a "natural home" mode it's designed for first.

#### Gold-Usage Rules (NEW — strictly enforced)

Gold is the brand colour. To keep it premium, it appears ONLY in these places:

✅ **Gold IS allowed on:**
- The single primary CTA button on a screen ("Login", "Send Enquiry", "Book Now", "Search Flights")
- The active tab indicator (underline) in tab bars
- The active icon in the bottom navigation
- Featured price emphasis on deal cards (e.g., "₹16,999 / person")
- Premium badges only — and only one badge per screen ("BEST VALUE", "VERIFIED", "PREMIUM")

❌ **Gold is NOT allowed on:**
- Secondary buttons (use outlined navy or ink)
- Filter chips (use cream/grey)
- Card backgrounds or borders
- Icons in general (use ink colours)
- Section dividers
- Status chips (use semantic colours — green/orange/red)
- Decorative accents around photos or illustrations
- Tab text when inactive
- Form field labels or borders

**The mental check:** If you've used gold more than 3 times on one screen, remove one. Premium is about restraint.

### 3.2 Typography (Updated in v1.1)

Two font families, with strict size rules:

**Display / Headings:** `Playfair Display` — high-contrast serif designed for digital screens. Unmistakably premium — the "Emirates business class menu" feeling. **Used only at 18px and above.** Below 18px it becomes fragile and hurts legibility.

**Body / UI:** `DM Sans` — clean, modern, purpose-built for digital screens. Same design family as Playfair. Excellent legibility at small sizes. Used for ALL body text, labels, buttons, form fields, metadata, and any text below 18px.

| Style | Font | Weight | Size | Line Height | Letter Spacing | Usage |
|---|---|---|---|---|---|---|
| `display-xl` | Playfair Display | 700 | 32px | 40px | -0.02em | Splash tagline, hero headlines |
| `display-lg` | Playfair Display | 700 | 24px | 32px | -0.01em | Page titles ("Luxury Goa Getaway") |
| `display-md` | Playfair Display | 500 | 18px | 26px | 0 | Section headers ("Featured Deals") |
| `heading` | DM Sans | 600 | 16px | 24px | -0.01em | Card titles, member names |
| `subheading` | DM Sans | 500 | 15px | 22px | 0 | Subtitles, prominent labels |
| `body` | DM Sans | 400 | 14px | 22px | 0 | Main body copy, descriptions |
| `body-sm` | DM Sans | 400 | 13px | 20px | 0 | Dense lists, secondary info |
| `label` | DM Sans | 600 | 12px | 16px | 0.04em | Buttons, chips, tab labels |
| `caption` | DM Sans | 400 | 12px | 18px | 0.01em | Timestamps, metadata |
| `overline` | DM Sans | 500 | 10px | 14px | 0.08em | Category tags (ALL CAPS) |

**Strict rule:** Never set Playfair Display below 18px. If you need a heading smaller than that, switch to DM Sans 600 weight.

### 3.3 Spacing System

All spacing uses an 8px base grid.

| Token | Value | Usage |
|---|---|---|
| `space-xs` | 4px | Tight gaps within components |
| `space-sm` | 8px | Internal component padding |
| `space-md` | 16px | Card padding, section gaps |
| `space-lg` | 24px | Between major sections |
| `space-xl` | 32px | Between page sections |
| `space-2xl` | 48px | Hero sections, large breakpoints |
| `space-3xl` | 64px | Full-page vertical rhythm |

### 3.4 Border Radius

| Token | Value | Usage |
|---|---|---|
| `radius-sm` | 6px | Input fields, small chips |
| `radius-md` | 12px | Cards, modals |
| `radius-lg` | 20px | Bottom sheets, large cards |
| `radius-xl` | 28px | Featured hero cards |
| `radius-full` | 999px | Pills, avatar frames, FABs |

### 3.5 Shadows & Elevation

Light Mode:
- `shadow-sm`: `0 1px 3px rgba(0,0,0,0.08)` — subtle card lift
- `shadow-md`: `0 4px 12px rgba(0,0,0,0.10)` — floating cards
- `shadow-lg`: `0 8px 24px rgba(0,0,0,0.12)` — modals, drawers

Dark Mode shadows use opacity-based dark overlays rather than drop shadows — depth is created through background colour differentiation between `surface-primary`, `surface-card`, and `surface-tertiary`.

### 3.6 Animation & Motion Design

**Philosophy:** Motion should feel purposeful, not decorative. Every animation communicates something — a state change, a hierarchy relationship, or a transition.

#### Animation Tokens
| Token | Duration | Easing | Usage |
|---|---|---|---|
| `anim-instant` | 100ms | linear | Hover states, checkbox toggles |
| `anim-fast` | 200ms | ease-out | Button presses, badge updates |
| `anim-normal` | 300ms | ease-in-out | Card transitions, tab switches |
| `anim-slow` | 500ms | cubic-bezier(0.22,1,0.36,1) | Page transitions, modal open |
| `anim-enter` | 400ms | ease-out | Elements entering the screen |
| `anim-exit` | 250ms | ease-in | Elements leaving the screen |

#### Motion Patterns to Implement

**Page Transitions:** Slide + fade. New page slides in from the right (forward) or from the left (back). Outgoing page fades and scales down slightly (0.96 scale).

**Card Entry (Stagger):** When a list or grid loads, cards animate in one by one with a 60ms stagger delay. Each card fades in and slides up 12px.

**Bottom Sheets:** Spring animation upward from the bottom. Backdrop fades in simultaneously.

**Skeleton Loading:** Shimmer animation from left to right (gradient sweep) on content placeholders. All major content areas show a skeleton before data loads.

**Pull to Refresh:** Lottie animation (custom travel-themed spinner — plane icon or globe) instead of default spinner.

**Hero Parallax:** On the Home screen, the banner/carousel has a subtle parallax effect as the user scrolls.

**Micro-interactions:**
- Favourite/bookmark: Heart icon pops with a scale bounce (1.0 → 1.4 → 1.0) and fills with gold
- Like / reaction: Particle burst animation
- Tab switch: Active indicator slides horizontally with spring physics
- Form submit button: Morphs from button to loading spinner, then to checkmark on success
- Gold premium badge: Shimmers periodically (every 8 seconds) with a light sweep — only on the badge, not other gold elements

---

## 4. Navigation Architecture (LOCKED in v1.1)

### Global Navigation Shell

The app uses a **persistent bottom navigation bar** with exactly **4 primary destinations**:

```
[ Home ]   [ Discover ]   [ My Space ]   [ Profile ]
```

| Tab | What It Contains |
|---|---|
| **Home** | News feed, featured deals carousel, category quick-access grid, TV/Radio mini-player |
| **Discover** | B2B Marketplace, Associations, Luxury (Hotels/Cruise/Train/Transport), Deals, Directory |
| **My Space** | Bookings, Enquiries, Jobs, Campus, Chat, Insurance, Visa, Flights |
| **Profile** | Account, settings, dark/light toggle, about, logout |

**No "More" tab.** ChatGPT's screenshot suggested a 5-tab nav with a "More" menu — this is rejected. Modules redistribute:

| Module | Lives In |
|---|---|
| Insurance | My Space |
| Visa | My Space |
| Flights | My Space |
| Hotels (luxury) | Discover → Luxury |
| Cabs / Taxi | Discover → B2B → Transport tab |
| Luxury (Cruise, Train, Transport) | Discover → Luxury |
| Events | Discover |
| Directory | Discover |
| Wallet | Profile |
| Notifications | App bar bell icon (top-right, persistent) |

### Side Drawer

A slide-out drawer (triggered by hamburger on Home) provides secondary navigation:
- Privacy Policy
- Refund Policy
- Notifications history
- About Us
- Share App
- Rate App
- Help & Support

### Modal Layers

Full-screen modals for: Booking flows (Insurance, Visa, Cruise, Train), Association login, Job application forms, Deal creation.

---

## 5. Module Documentation

Each module below includes: purpose, who uses it, complete user flow, screen descriptions, and UX redesign notes.

---

### MODULE 1: Onboarding & Authentication (Updated in v1.1)

**Purpose:** Get a new user registered or an existing user signed in, then route them to the main app.

**Users:** All users (first-time and returning)

#### User Flow

```
App Launch
    │
    ▼
Splash Screen (3-4 seconds — NOT 6-8 as before)
    │
    ├──► User is already signed in + email verified
    │         │
    │         ▼
    │    Bottom Navigation Shell (Home)
    │
    ├──► User is signed in but email NOT verified
    │         │
    │         ▼
    │    Verify Email Screen
    │         │
    │         ├──► "I've verified" button → re-check → Home
    │         └──► Sign Out → Welcome Screen
    │
    └──► No user signed in
              │
              ▼
         Welcome / Onboarding Carousel (3 slides)
              │
              ├──► "Sign In" → Sign In Screen
              │         │
              │         ├──► Email + Password → Verify → Home
              │         ├──► Google Sign-In → Home
              │         └──► "Forgot Password" → Reset Email Sent Screen
              │
              └──► "Create Account" → Register Screen
                        │
                        ├──► Fill name, email, password
                        ├──► Submit → Verification email sent
                        └──► Verify Email Screen → Home
```

#### Screen Descriptions (Updated in v1.1)

**Splash Screen:** Deep navy (`#0D1B2A`) full-screen background. Centred logo in cream. One-line tagline below in Playfair Display 24px ("Travel Business. Elevated."). Thin gold progress line at the bottom (1px height, full width, fills left-to-right over 3-4 seconds).

**REJECTED for splash:** the tourism-collage style (Taj Mahal + Eiffel Tower + hot-air-balloon). This is consumer-app energy and undermines the B2B positioning.

**Onboarding (3 slides — editorial photography only):**

- **Slide 1 — Connect:** Full-bleed photo of a single travel-trade scene (e.g., aerial of an airport runway at dusk, or a half-shadowed leather luggage tag). Bottom card (cream, 40% height): Playfair "Connect with Associations & Peers" + DM Sans body line + dots indicator + "Next" gold button.
- **Slide 2 — Discover:** Full-bleed photo (e.g., cinematic close-up of a boarding pass on dark marble). Card: "Discover B2B Deals & Opportunities".
- **Slide 3 — Grow:** Full-bleed photo (e.g., a globe lit from inside on a dark desk). Card: "Learn, Book, and Expand Your Business". Final CTA: "Get Started" gold button → Welcome.

No floating illustrated luggage. No multi-image collages. One image, one message, one CTA per slide.

**Welcome Screen:** Two-thirds of the screen is a stunning full-bleed travel photograph (editorial, not tourist). Bottom third is a cream card with: app logo, tagline, two buttons — Sign In (gold, filled) and Create Account (outlined navy, transparent).

**Sign In Screen:** Light mode. App logo top-centre. Mobile Number field (with +91 prefix), Password field (with show/hide toggle), gold "Login" button, "Forgot Password?" text link, divider with "or continue with", three social sign-in buttons (Google, Apple, Microsoft) in circular outlined buttons, "Don't have an account? Sign Up" link at bottom.

**Register Screen:** First name, last name, email, password, confirm password. Terms checkbox. Gold "Create Account" CTA.

**Verify Email Screen:** Full-screen calm illustration (envelope with stars, line-art style, navy strokes on cream background — not gold). Clear message. "I Have Verified" gold button. "Resend Email" outlined button. Sign Out text link.

#### UX Redesign Notes
- Remove OTP screen entirely or simplify — currently causes drop-off
- Add light haptic feedback on all button taps
- Auto-advance to Home if Firebase detects email verification without user tapping
- Show a welcome animation (Lottie) on first successful login only — subtle, 1.5 seconds max

---

### MODULE 2: Home

**Purpose:** The nerve centre of the app. Surfaces the most important content and provides quick access to all modules.

**Users:** All signed-in users

#### User Flow

```
Home Tab
    │
    ▼
Home Screen
    │
    ├──► Pull to refresh → reload news + deals
    │
    ├──► Personalised greeting ("Hello, Rakesh 👋 — Good Morning")
    │
    ├──► Search bar (deals, news, people)
    │
    ├──► Featured Deals Carousel (swipeable banner)
    │         └──► Tap deal → Deal Detail
    │
    ├──► Category Quick-Access Grid (5 tiles + More)
    │         │
    │         ├──► B2B Deals → B2B Marketplace
    │         ├──► Associations → Association List
    │         ├──► Bookings → Bookings List
    │         ├──► Campus → Campus Module
    │         ├──► Jobs → Jobs Module
    │         └──► MORE → Full module list (bottom sheet, not new tab)
    │
    ├──► Top Stories section
    │         └──► Tap article → Article Detail Screen
    │
    └──► Live TV / Radio mini-player (persistent bottom strip, above bottom nav)
              └──► Tap → Expand to full TV or Radio screen
```

#### Screen Descriptions

**Home Screen Layout (top to bottom):**
1. **App bar** — Greeting text left ("Hello, Rakesh 👋" in heading + "Good Morning" in caption below), notification bell right (with red dot for unread)
2. **Search bar** — Full-width, rounded, cream background with search icon left and filter icon right
3. **Featured Deals Carousel** — Full-width cards (aspect 16:9), auto-advancing every 5 seconds, gold pagination dots, each card has a gradient overlay with deal title in Playfair and a small gold "Register Now" or "View Deal" chip
4. **Category Quick-Access Grid** — 5 icon-label tiles in a row + More. Each tile: 56×56 rounded square in `surface-card`, icon in navy (NOT gold — only the active state is gold), label in DM Sans caption below
5. **Top Stories** — Compact card list (image left, text right). Each card: category overline tag, headline in heading style, source + time-ago in caption

#### UX Redesign Notes (Updated v1.1)
- The current home is just a list with no visual hierarchy. The redesign prioritises the carousel as hero content.
- Add personalisation: "Based on your association" section showing association-specific circulars
- TV and Radio are moved out of bottom nav — they appear as a mini-player strip at bottom of Home, tappable to expand
- News feed should paginate smoothly (load 10 at a time, show skeleton on next-page load)
- Category quick-access tiles use neutral icons (navy on cream), NOT all-gold icons. Only the currently active section glows gold.

---

### MODULE 3: B2B Marketplace

**Purpose:** The core commercial engine. Travel agents post and discover hotels, packages, transport, and villa deals. Think of it as a private marketplace for travel trade only.

**Users:** Agents (buyers and sellers), Association members

#### User Flow

```
B2B Entry
    │
    ▼
B2B Home Screen
    │
    ├──► Tab Bar: [ All ] [ Hotels ] [ Packages ] [ Transport ] [ Villas ] [ Tailor Made ] [ Cabs ] [ Luxury ] [ DMC ]
    │
    ├──► ALL TAB (default)
    │         │
    │         ├──► Featured Deals section (full-width card)
    │         ├──► Best Offers for You section (horizontal scroll)
    │         ├──► All deals grid below
    │         │
    │         └──► Tap deal card → Deal Detail Screen
    │                   │
    │                   ├──► View images, description, pricing
    │                   ├──► Tap "Favourite" → saved to My Favourites
    │                   ├──► Tap "Contact Seller" → open chat or dial
    │                   ├──► Tap "Request Deal" (gold CTA) → Deal Enquiry form
    │                   └──► Share deal
    │
    ├──► HOTELS TAB
    │         │
    │         ├──► Hotel listings (card grid)
    │         ├──► Tap hotel → Hotel Detail
    │         │         │
    │         │         ├──► Images gallery, amenities, pricing
    │         │         ├──► "Book / Enquire" button
    │         │         └──► Share
    │         │
    │         └──► "+ List My Hotel" (seller action)
    │
    ├──► PACKAGES TAB (same flow as Hotels)
    │
    ├──► TRANSPORT TAB (same flow as Hotels)
    │
    ├──► VILLAS TAB (same flow as Hotels)
    │
    ├──► TAILOR MADE TAB
    │         │
    │         └──► Submit a custom travel requirement form → sellers respond
    │
    ├──► DMC TAB
    │         │
    │         ├──► List of Destination Management Companies
    │         ├──► Tap DMC card → DMC Profile
    │         │         ├──► Services offered, destinations covered
    │         │         └──► Contact / Register interest
    │         │
    │         └──► "Register as DMC" form
    │
    ├──► MY ENQUIRIES (sub-section, accessed via top-right icon)
    │         │
    │         ├──► Filters: [All] [Pending] [Responded] [Closed]
    │         └──► List of enquiries with status chip
    │
    ├──► MY DEALS (sub-section)
    │         └──► All deals posted by the logged-in user
    │
    └──► MY FAVOURITES (sub-section)
              └──► All deals saved as favourite
```

#### Screen Descriptions

**B2B Home (dark mode default):** Top section shows search bar. Below: horizontal tab bar (max 5 visible at a time, scrollable). "Featured Deals" section heading in Playfair. One large featured deal card (full-width, image with gradient overlay, title, sub-info, price tag — price in gold, everything else cream). "Best Offers for You" heading. Horizontal-scroll row of smaller deal cards (2.2 visible at a time). Bottom nav persistent.

**Deal Card (standard):** Image (3:2 ratio) with cream-on-dark "HOTEL" / "PACKAGE" overline chip top-left (NOT gold), title in heading, "5★ Resort • 3D/2N" subtitle, location with pin icon, star rating (gold star, ink-coloured number), price in gold heading + struck-through original price + green percentage off chip, heart icon top-right.

**Deal Detail Screen (light mode):** Full-screen image carousel at top with floating back + share buttons. Below: HOTEL overline chip, title in Playfair display-lg, "5★ Resort • 3 Days 2 Nights" subtitle, location pin + rating row, price block (gold large + struck original + green discount %), "Deal Includes" section with checkmark list (2 Nights Stay, Daily Breakfast & Dinner, Airport Transfers, Free Resort Activities), bottom-fixed gold "Request Deal" button with chat + call icons on its left.

**Deal Enquiry Screen (light mode):** Top: small thumbnail of the deal + title + price summary. Form fields: "Enquiry For" dropdown (My Client / Self), Travel Date picker, Travellers count, Free-text "Your Message". Bottom gold "Send Enquiry" CTA.

**My Enquiries Screen (light mode):** Filter tabs at top (All / Pending / Responded / Closed). List of enquiry cards: thumbnail left, deal title + meta, status chip (Pending = warning orange, Responded = success green, Closed = grey), enquiry date below, chevron right.

#### UX Redesign Notes (Updated v1.1)
- Current B2B has all tabs visible as horizontal scroll which is overwhelming — redesign uses a tab bar with icons + labels, max 5 visible, rest in "More" overflow
- Add filter/sort sheet (bottom modal) on listing screens
- Add a "Buyer Mode / Seller Mode" toggle at the top of B2B home for context-aware UI
- Cards should show verified badge (gold checkmark) for trusted sellers — this is ONE of the permitted gold uses
- Status chips use semantic colours (orange/green/grey), NOT gold

---

### MODULE 4: Association

**Purpose:** Every major travel trade association in India (TAAI, TAFI, IATA, etc.) has a presence here. Members can log in to access their association's private circulars, member list, live TV, and B2B deals.

**Users:** Association members, Association admins

#### User Flow

```
Association Entry (from Discover tab OR Home category tile)
    │
    ▼
Association Hub Screen
    │
    ├──► "My Associations" section (if member)
    │         └──► Card showing the user's primary association with quick actions
    │
    ├──► Quick Action Tiles: [ Circulars ] [ Members ] [ Events ] [ Deals ]
    │
    ├──► "Latest Circulars" feed (chronological)
    │
    └──► Tap "View All" → Association List
              │
              ▼
         Association List Screen
              │
              ├──► Search bar (search by association name)
              ├──► Grid of association logo cards
              │
              └──► Tap Association Card
                        │
                        ▼
                   Association Detail Screen
                        │
                        ├──► Tabs: [ About ] [ Members ] [ Circulars ] [ B2B ] [ Live TV ] [ Community ]
                        │
                        ├──► CIRCULARS TAB
                        │         ├──► List of official circulars
                        │         └──► Tap circular → Full circular viewer (PDF or HTML)
                        │                   │
                        │                   ├──► Header: title, author/source, date
                        │                   ├──► Embedded PDF preview card
                        │                   ├──► "Read More" expand
                        │                   ├──► Bookmark + Reply CTAs at bottom
                        │
                        ├──► MEMBERS TAB
                        │         └──► Searchable list of members (avatar, name, "Active Member" chip, email/agency)
                        │
                        ├──► COMMUNITY TAB
                        │         │
                        │         ├──► "Share an update..." input + camera icon at top
                        │         ├──► Filter tabs: [All] [Following] [Associations]
                        │         └──► Feed of posts (avatar, name, association tag, time, body, image, like/comment/share counts)
                        │
                        ├──► B2B TAB (filtered to this association)
                        └──► LIVE TV TAB (embedded live stream)
```

#### Screen Descriptions

**Association Hub (light mode):** Top: page title in display-lg. "My Associations" section with one large card showing logo + name + "Active Member" chip. Four quick-action tiles in a row (Circulars, Members, Events, Deals — neutral icons, no gold). "Latest Circulars" section heading. List of circular cards (PDF icon, title, date, optional "New" red dot).

**Circular Viewer Screen:** Title in Playfair display-lg, author/source row with avatar, date + time meta. Embedded image of circular (or PDF preview tile). Body text with "Read More" expand. Attachment chip ("Schengen_Visa_Advisory.pdf · 1.2 MB"). Bottom: Bookmark icon (outline) + gold "Reply" button.

**Members Screen:** Search bar with filter icon. List of member rows: avatar (circular), name in heading, "Active Member" chip in success green + email below, chevron.

**Community Feed Screen:** Post composer at top (avatar + "Share an update..." placeholder + camera). Filter tabs. Post cards: avatar + name + association in heading row, time-ago, body text, optional image (full-width, rounded), reaction icons (heart/comment/share) with counts.

#### UX Redesign Notes (Updated v1.1)
- The login dialog is currently very abrupt — redesign it as a smooth bottom sheet
- Add "My Association" shortcut on the Profile tab
- Association Live TV should auto-detect if a stream is available and show/hide the tab accordingly
- The "Active Member" chip uses success green, NOT gold
- Quick-action tile icons are navy/ink, NOT all-gold

---

### MODULE 5: Campus

**Purpose:** Upskilling and education for travel professionals. Three sub-sections: Advisory Board (industry experts), Destination Specialist Program (country-specific training), and Skill Development (video courses).

**Users:** Agents wanting to learn, trainers uploading content, admins managing the board

#### User Flow

```
Campus Entry (from My Space tab or Home tile)
    │
    ▼
Campus Home Screen
    │
    ├──► Search bar ("Search courses, videos…")
    │
    ├──► Featured Course (hero card with image + title + gold "Watch Now" button)
    │
    ├──► Categories (icon-label row): [ All ] [ Destination ] [ Sales ] [ Marketing ] [ More ]
    │
    ├──► Latest Videos section
    │         └──► Video card: thumbnail (with play overlay), title, duration · author
    │
    ├──► Section: Our Advisory Board
    │         │
    │         ▼
    │    Advisory Board Screen
    │         │
    │         ├──► Grid of expert profiles (photo, name, country, expertise)
    │         └──► Tap profile → Expert Detail
    │                   │
    │                   ├──► Bio, credentials, courses they teach
    │                   └──► Video lessons by this expert
    │
    ├──► Section: Destination Specialist Program
    │         │
    │         ▼
    │    Country List Screen → Country Learning Hub → Lesson
    │
    └──► Section: Skill Development
              │
              └──► Course Category List → Course list → Course Detail → Lesson
```

#### Screen Descriptions (Updated)

**Campus Home:** Search bar at top. Featured Course hero card (full-width, dark image with cream text overlay — Playfair title, body subtitle, single gold "Watch Now" pill button). Categories horizontal row. "Latest Videos" section with video rows (thumbnail left, title + meta right).

**Video Player Screen:** Full-screen landscape or inline portrait player. Below: title in Playfair, instructor name, description, related lessons list.

#### UX Redesign Notes
- Add progress tracking — show "X of Y lessons completed" per course with a gold progress bar (one of the permitted gold uses)
- Add certificates (downloadable PDF) on course completion
- Admin users see an "+ Add Content" floating button; regular users do not

---

### MODULE 6: News

**Purpose:** Latest travel industry news — domestic and international, B2B-focused.

**Users:** All users

#### User Flow

```
News Entry
    │
    ▼
News List Screen
    │
    ├──► Category Tab Bar: [ Top News ] [ Industry ] [ Destinations ] [ More ]
    ├──► Each tab shows paginated news cards
    │
    └──► Tap news card → Article Detail Screen
              │
              ├──► Full article (HTML rendered)
              ├──► Share button
              ├──► Related articles at bottom
              └──► Back to list
```

#### Screen Descriptions

**News List (light mode default, dark mode supported):** Sticky tab bar at top with active tab indicator (gold underline). Featured article at top — large card, full-width image, headline in Playfair display-md, source + time-ago in caption. Below: compact cards (image left small, text right). Each compact card: category overline, headline in heading, source + time.

**Article Detail:** Hero image full-width. Floating back + share buttons on image. Below: category chip, headline in Playfair display-lg, date + author meta, divider, full HTML article body in DM Sans body, share row at bottom, related articles section.

#### UX Redesign Notes
- Add "Save for later" bookmark on each article card
- Add read-time indicator
- Swipe left/right to go to previous/next article in the same category

---

### MODULE 7: Media — Live TV & Radio

**Purpose:** Live travel industry TV broadcasts and radio streaming.

**Users:** All users

#### User Flow

```
Media Access
    │
    ├──► FROM HOME: Mini-player strip at bottom of Home tab
    │         └──► Tap "▶ LIVE" → expand to full TV/Radio screen
    │
    └──► FROM DISCOVER TAB or direct entry: TV/Radio screen
              │
              ├──► Top tabs: [ TV ] [ Radio ] [ Podcasts ]
              │
              ├──► LIVE TV
              │         │
              │         ├──► "Live TV" section heading
              │         ├──► Channel list cards (logo, channel name, "Live" red chip / "Watching" green chip)
              │         └──► Tap channel → Full-screen video player
              │
              ├──► RADIO
              │         │
              │         ├──► Single stream (Travel Maska Radio) full-screen audio player
              │         └──► Background playback continues when app minimised
              │
              └──► PODCASTS
                        └──► On-demand episode list with play action
```

#### Screen Descriptions

**TV Screen (dark mode always):** Top tabs in cream-on-dark. "Live TV" section heading in Playfair display-md. Channel cards: rounded thumbnail left (channel logo on coloured background), channel name in heading, channel description in caption, status chip right ("Live" in red dot + text / "Watching" in success green). "Featured Shows" section below with horizontal-scroll cards (show thumbnail, title overlay).

**Radio Screen:** Full-screen immersive design. Animated circular waveform visualizer (gold rings pulsing to audio — this IS a permitted gold use because it's the primary content focus). Station logo centred. Controls at bottom. Dark mode always for Radio.

#### UX Redesign Notes
- Add PiP (picture-in-picture) for Live TV so agents can multitask
- Background playback for Radio is a critical feature — must persist across app navigation
- Show "LIVE" red badge when a stream is actually live vs a recording (red, not gold — "LIVE" needs to feel urgent, not premium)

---

### MODULE 8: Chat

**Purpose:** Real-time messaging between travel professionals.

**Users:** All signed-in users

#### User Flow

```
Chat Entry (My Space Tab)
    │
    ▼
Chat Home Screen
    │
    ├──► List of recent conversations (sorted by last message time)
    ├──► Search bar to find a user
    │
    └──► Tap conversation OR tap "New Chat" FAB
              │
              ▼
         Chat Screen
              │
              ├──► Message bubbles (sent right, received left)
              ├──► Text input + emoji + send button
              ├──► File/image attachment
              └──► Delivered / Read receipts (double tick)
```

#### Screen Descriptions

**Chat Home:** Conversation list. Each row: avatar (circular), user name in heading, last message preview in body-sm, timestamp in caption, unread count badge (gold pill — permitted use, it's a status indicator). New Chat FAB (gold circle with edit icon, bottom-right above bottom nav).

**Chat Screen:** Standard messaging UI. Sent messages: navy-deep bubble right with cream text. Received: surface-card bubble left with ink text. Timestamps shown in groups. Emoji picker slides up as bottom sheet.

#### UX Redesign Notes
- Add typing indicator ("User is typing...")
- Add message reactions (long-press message)
- Group chat support as a future enhancement

---

### MODULE 9: Jobs

**Purpose:** A job board specifically for the Indian travel industry. Agents can post vacancies, look for jobs, or apply for positions.

**Users:** Job posters (agencies/employers), Job seekers (agents looking for work)

#### User Flow

```
Jobs Entry (My Space Tab)
    │
    ▼
Jobs Home Screen
    │
    ├──► Search bar
    ├──► Tab Bar: [ All Jobs ] [ My Applications ] [ Saved ]
    │
    ├──► ALL JOBS
    │         │
    │         ├──► Searchable, filterable job list
    │         ├──► Filter: location, job type, salary range, experience (filter icon top-right)
    │         └──► Tap job card → Job Detail Screen
    │                   │
    │                   ├──► Role, company, location, salary, description
    │                   └──► "Apply Now" (gold CTA) → Application Form
    │                             │
    │                             ├──► Name, contact, resume upload, cover note
    │                             └──► Submit → "Application Sent" confirmation
    │
    ├──► POST A JOB (FAB)
    │         │
    │         └──► Job Posting Form
    │
    ├──► MY APPLICATIONS
    │         └──► List of jobs applied to with status (Pending / Shortlisted / Rejected)
    │
    └──► SAVED
              └──► Saved job listings
```

#### Screen Descriptions

**Jobs Home (light mode):** Search bar. Tab bar (active tab in gold underline). Job cards: title in heading ("Tour Operations Manager"), company + location row in body-sm, time-ago in caption, chevron right. No image — text-only list for density.

#### UX Redesign Notes
- Job cards show role, company, location, salary range (if disclosed), time-ago
- Add a "Job Alert" toggle — notify when new jobs matching saved search are posted
- Application status uses semantic chips (orange = pending, green = shortlisted, red = rejected)

---

### MODULE 10: Travel Insurance

**Purpose:** Help agents book travel insurance for their clients through a structured 4-step booking flow.

**Users:** Travel agents booking for clients

#### User Flow

```
Insurance Entry (My Space Tab)
    │
    ▼
Insurance Home Screen
    │
    ├──► "Book Insurance" gold CTA button
    ├──► "My Bookings" — previous insurance bookings
    │
    └──► Tap "Book Insurance"
              │
              ▼
    Step 1 — Trip Details → Step 2 — Choose Plan → Step 3 — Traveller Details → Step 4 — Review & Pay
              │
              ▼
         Confirmation: Policy number, downloadable PDF, share
```

#### Screen Descriptions

**Step Progress Bar:** Persistent top bar showing 4 steps. Active and completed steps in gold; upcoming in ink-400. Step number + label below.

**Plan Cards (Step 2):** Side-scrolling vertical cards. Recommended plan has a gold "BEST VALUE" banner (one of the permitted gold uses). Each card: plan name in heading, key coverage points (bullet list with check icons), price per person (large, gold), outlined "Select" button (turns gold + filled when selected).

**Confirmation Screen:** Full-screen success state. Lottie animation (checkmark with subtle confetti). Policy number, coverage dates. "Download PDF" gold button and "Share" outlined button.

#### UX Redesign Notes
- Current implementation is disjointed — strict step wizard with persistent progress indicator
- Never show a blank/empty screen between steps — use skeleton loaders
- Save partial progress so if a user exits mid-flow they can resume

---

### MODULE 11: Visa

**Purpose:** Agents submit visa applications for their clients.

**Users:** Travel agents

#### User Flow

```
Visa Entry (My Space Tab)
    │
    ▼
Visa Home Screen
    │
    ├──► "Apply for Visa" gold CTA
    ├──► "My Applications" list
    │
    └──► Tap "Apply for Visa"
              │
              ▼
         Visa Application Form
              │
              ├──► Destination country (searchable picker)
              ├──► Visa type (Tourist / Business / Student)
              ├──► Applicant details
              ├──► Travel dates
              ├──► Document upload
              └──► Submit → "Application Submitted" screen
                        └──► Status tracking timeline (Submitted → Processing → Approved/Rejected)
```

#### UX Redesign Notes
- Add document checklist per country — tell the agent exactly what is needed before they start
- Status tracking uses a visual timeline (vertical dots connected by line, gold for completed nodes, ink for upcoming)
- Push notification when visa status updates

---

### MODULE 12: Flights

**Purpose:** Agents submit flight inquiries for client bookings. Currently a basic inquiry form — not a live GDS search.

**Users:** Travel agents

#### User Flow

```
Flights Entry
    │
    ▼
Flight Inquiry Screen
    │
    ├──► Trip type tabs: [ Round Trip ] [ One Way ] [ Multi City ]
    ├──► From city (searchable, with swap icon between)
    ├──► To city (searchable)
    ├──► Departure date / Return date (date picker)
    ├──► Travellers + class (combined picker)
    │
    ├──► Gold "Search Flights" CTA
    │
    └──► Recent Searches section below
              └──► One-tap re-search
```

#### UX Redesign Notes
- Add a city-to-city autocomplete (IATA airport codes in the background, city names in front)
- Show the agent's previous inquiries so they don't re-submit duplicates
- Future: integrate a live fare search API (Amadeus or Sabre)

---

### MODULE 13: Taxi / Cab Booking

**Purpose:** Agents book or list cab services for client ground transport.

**Users:** Agents (booking for clients), Cab operators (listing their service)

(Flow and screens unchanged from v1.0)

---

### MODULE 14: Luxury Hotels

**Purpose:** Showcase and inquire about luxury hotel properties.

**Users:** Agents looking for upscale hotel options for high-value clients

(Flow and screens unchanged from v1.0)

#### UX Redesign Notes (Updated)
- Photography is everything in luxury — full-bleed images, no compression, editorial styling
- Add a "Virtual Tour" button if 360° images are available
- Show accolades/awards (e.g., Forbes 5-Star, Condé Nast Top 100) — these can use the gold "VERIFIED" / "PREMIUM" badge (one permitted gold use, one badge per screen)

---

### MODULE 15: Luxury Cruise

(Unchanged from v1.0. The most complex module — full cruise booking for HAL, Arosa, plus Alamo car rental at ports.)

---

### MODULE 16: Luxury Train

(Unchanged from v1.0.)

---

### MODULE 17: Luxury Transport

(Unchanged from v1.0.)

---

### MODULE 18: PPP (Public-Private Partnership)

(Unchanged from v1.0.)

---

### MODULE 19: Deals

(Unchanged from v1.0. Same deal card and detail patterns as B2B.)

---

### MODULE 20: Directory

(Unchanged from v1.0.)

---

### MODULE 21: Interviews & YouTube Videos

(Unchanged from v1.0.)

---

### MODULE 22: Profile & Settings

**Purpose:** User account management, preferences, and app settings.

**Users:** All signed-in users

#### User Flow

```
Profile Tab
    │
    ▼
Profile Screen
    │
    ├──► User header: avatar + name + phone + edit icon
    │
    ├──► Membership card (e.g., "TAAI Member · Member ID: TAAI12345" with "Active" chip)
    │
    ├──► Quick links list:
    │         ├──► My Profile
    │         ├──► My Documents
    │         ├──► Saved Deals
    │         ├──► My Enquiries
    │         ├──► My Bookings
    │         └──► Settings
    │
    ├──► SETTINGS SECTION
    │         ├──► Dark Mode / Light Mode toggle (with instant preview)
    │         ├──► Notification preferences
    │         └──► Language (future)
    │
    ├──► ACCOUNT SECTION
    │         ├──► Edit Profile
    │         ├──► Change Password
    │         └──► Delete Account (destructive, requires confirmation)
    │
    ├──► SUPPORT SECTION
    │         ├──► Privacy Policy (opens in browser)
    │         ├──► Refund Policy (opens in browser)
    │         ├──► Help & Support
    │         ├──► About Us
    │         └──► Share App
    │
    └──► LOGOUT (subtle text link at very bottom)
```

#### UX Redesign Notes (Updated)
- Dark/light mode toggle animates — the sun/moon icon morphs with a smooth rotation (300ms)
- Profile screen feels personal — show the user's stats: deals saved, associations followed, courses completed
- Membership "Active" chip uses success green, NOT gold
- List item icons are navy/ink, NOT gold

---

## 6. Global UX Principles

### Empty / Loading / Error States (MANDATORY in v1.1)

Every screen that loads data MUST have three states, designed and built:

| State | Design |
|---|---|
| **Loading** | Shimmer skeleton matching the content layout. Same shape as the populated card, grey fill, left-to-right gradient sweep at 1.5s loop. |
| **Empty** | Single line illustration (navy strokes on cream — NOT gold), heading in heading style ("No bookings yet"), one body line ("Your bookings will appear here"), one outlined CTA button ("Explore Deals"). Centred vertically. |
| **Error** | Same shape as empty, but with "Something went wrong" + "We couldn't load your data" + a gold "Try Again" button. |

In code/Figma, these are component variants of the screen — never separate frames or one-off designs.

### Haptic Feedback
- Light haptic: all button taps, tab switches
- Medium haptic: favouriting a deal, completing a form step
- Heavy haptic: payment success, booking confirmation

### Toast Notifications
- Position: top of screen (bottom nav is there)
- Success: green left border, checkmark icon
- Error: red left border, X icon
- Info: gold left border, info icon (the ONE place info-toast uses gold)
- Duration: 3 seconds, swipe to dismiss

### Pull to Refresh
Every list screen supports pull-to-refresh. Use a custom Lottie animation (travel-themed — small plane drawing a circle).

### Offline States
Persistent non-intrusive banner at top: "You're offline — showing cached content."

---

## 7. Production-Grade Requirements

### Performance
- Cached network images. Server-side compression. Progressive loading (blur-up).
- Virtual/lazy rendering on all infinite-scroll lists.
- Controllers use `fenix: true` — persist through navigation.
- API client has 5-minute GET caching. `forceRefresh: true` on pull-to-refresh.

### Security
- Tokens in `SecureStorageService` (Keychain / EncryptedSharedPreferences)
- Firebase App Check active in production
- HTTPS only
- No hardcoded API keys

### Error Handling
- Every API call handles: network timeout, 401, 404, 500, exceptions
- `ApiResult<T>` for all new API methods — never return null on failure
- `AppLogger.error()` with stack traces in debug

### Notifications
- FCM for push
- `flutter_local_notifications` for foreground
- Categories: News, Deal, Application status, Circular, Chat — each independently toggleable

### App Updates
- `upgrader` package for forced updates with grace period
- Critical security updates force-update immediately

### Analytics
- Firebase Analytics: screen views, feature usage, booking funnel drop-offs, search queries
- Key events: `login`, `deal_viewed`, `deal_favourited`, `booking_started`, `booking_completed`, `share_tapped`

### Accessibility
- Minimum touch target: 48×48px
- Semantic labels for screen readers on all interactive elements
- Colour contrast: 4.5:1 body, 3:1 large text
- Support system font scaling

---

## 8. Redesign Priorities (Implementation Order)

| Priority | What to Build | Why |
|---|---|---|
| 1 | Design System (tokens, typography, colours, components) | Everything else depends on this |
| 2 | Navigation Shell (bottom nav, drawer) | Every screen uses this |
| 3 | Authentication screens | First thing users see |
| 4 | Home Screen | Most-used screen |
| 5 | B2B Marketplace | Core commercial feature |
| 6 | Association Module | Differentiating feature |
| 7 | News + Media | High-frequency use |
| 8 | Insurance + Visa + Flights | Booking revenue features |
| 9 | Campus | Engagement/retention feature |
| 10 | Chat + Jobs | Community features |
| 11 | Luxury products (Hotel, Cruise, Train, Transport) | Premium revenue features |
| 12 | Profile + Settings | Last to redesign |

---

## 9. What "Production Grade" Means for This App

A screen is production grade when it satisfies ALL of the following:
- [ ] Has loading skeleton that matches the content layout
- [ ] Has error state with a retry action
- [ ] Has empty state with an illustration and CTA
- [ ] Supports both light mode and dark mode correctly
- [ ] Uses design system tokens only (no hardcoded colours or font sizes)
- [ ] Follows gold-usage rules (gold ONLY on primary CTAs, active tabs, premium badges, status indicators)
- [ ] Uses Playfair Display only at 18px and above; DM Sans for everything else
- [ ] Animations are present and feel natural (no jarring snaps)
- [ ] All touch targets are ≥ 48×48px
- [ ] Text scales correctly at 1.5× system font size without overflow
- [ ] No data is refetched unnecessarily (caching works)
- [ ] Haptic feedback is present on primary actions
- [ ] Screen is tracked in Firebase Analytics
- [ ] Uses the correct default mode (light or dark) per the table in Section 3.1

---

## 10. Summary of Changes from v1.0 to v1.1

For anyone migrating from the previous documentation:

| Area | v1.0 | v1.1 |
|---|---|---|
| Gold usage | Used broadly across CTAs, accents, dividers, badges, chips | Restricted to primary CTAs + active tabs + premium badges + status indicators + featured prices |
| Playfair Display | No minimum size specified | Minimum 18px (use DM Sans below) |
| Bottom nav | "4 primary destinations" (Home / Discover / My Space / Profile) — vague | LOCKED at exactly 4: Home / Discover / My Space / Profile. No "More" tab. |
| Splash | Implied colourful collage | Single editorial photo or dark background with logo + thin gold progress line |
| Onboarding | Not specified in detail | 3 slides, each with a single editorial photo + one value-prop + one CTA |
| Light/Dark mode | User-toggle only | Per-screen default mode chosen by design, user-toggle override |
| Loading/Empty/Error states | Listed once | Made strictly mandatory; defined visual spec |
| Gold-usage rules | Implicit | Explicit "allowed" and "not allowed" lists |

---

*End of Document. Version 1.1 — May 2026.*
