# Splitr Website — Design System

**Owner:** UI/UX Director Agent  
**Consumers:** Developer, Experience QA  
**Upstream:** `creative-direction.md`, `storyboard.md`  
**Motion references (read-only):** `motion-library.md` §I–II — *not owned by UI/UX Director*  
**Brand source:** `apps/mobile/lib/Constants/constants.dart`, `app_palette.dart`, `apps/mobile/assets/brand/`  
**Legacy web tokens:** `react-website-development-details.md` §11 (sync until this doc supersedes)  
**Last updated:** 2026-07-27 (Director tick 0)  
**Status:** Foundation locked; Scene UI 01–03 specified; Scenes 04–09 blocked on `storyboard.md`

---

## Input gate

| Required doc | Status |
|--------------|--------|
| `creative-direction.md` | ✅ Read |
| `storyboard.md` | ⚠️ Scenes 01–03 complete; 04–09 pending |
| `motion-language.md` | ❌ Missing — **interim:** `motion-library.md` §I |
| `scene-choreography.md` | ❌ Missing — **interim:** `motion-library.md` §II per scene |

**Rule:** UI/UX Director does not invent motion. All animation behaviour references Motion Director docs. Interface supports story; never competes with it.

**Escalation:** Product/Motion Directors should split `motion-library.md` into `motion-language.md` + `scene-choreography.md` or confirm interim mapping.

---

## Design principles

Derived from Creative Direction — interface must **disappear behind the experience**.

| Principle | Rule |
|-----------|------|
| **Story first** | UI chrome minimal during narrative beats; CTAs present, never dominant in Acts I–II |
| **Premium-quiet** | NeoPOP accent on intent only; dark canvas; no decorative fill |
| **Restraint** | Whitespace is structure; empty space is not a bug |
| **Precision** | Grid-aligned; token-based spacing; no arbitrary values |
| **India-native** | ₹ tabular nums; UPI trust without clipart |
| **Invisible craft** | Users remember control, not buttons |
| **Accessibility mandatory** | WCAG AA minimum; reduced-motion parity |

### Design dos

- One primary focus per viewport
- Sentence-case buttons; Install primary hierarchy always
- 48px minimum touch targets on mobile
- Semantic HTML; visible focus rings
- Tabular figures for currency (`font-variant-numeric: tabular-nums`)

### Design don'ts

- No stock fintech photography
- No chat screenshots in problem scenes
- No competitor logos in compare UI chrome
- No light-mode v1
- No arbitrary hex outside token table
- No motion specs in this doc — reference Motion Director only

---

## Colour system

Dark-only v1. Map 1:1 from mobile NeoPOP.

| Token | Hex | Role |
|-------|-----|------|
| `--color-bg` | `#0D0D0D` | Page canvas |
| `--color-surface` | `#333333` | Cards, nav scrolled |
| `--color-surface-elevated` | `#1E1E1E` | Modals, drawers, cookie bar |
| `--color-border` | `#323232` | Dividers, card edges |
| `--color-text` | `#FFFFFF` | Primary copy |
| `--color-text-muted` | `#8A8D8E` | Secondary, captions |
| `--color-accent` | `#18C595` | Primary CTA, links, focus, path highlights |
| `--color-accent-on` | `#000000` | Text on accent fill |
| `--color-primary` | `#FE885D` | Secondary emphasis (sparingly) |
| `--color-success` | `#4CAF50` | Settled, positive |
| `--color-error` | `#C62828` | Errors, destructive |
| `--color-warning` | `#E6A800` | Owed balances |
| `--color-yellow` | `#F9FE8A` | Badges, Pro emphasis |
| `--color-accent-fill-soft` | `rgba(24,197,149,0.10)` | Active nav, step circles |
| `--color-scrim` | `rgba(0,0,0,0.87)` | Overlays |

**Interactive states:** Hover = brightness +4% or border accent 35%. Pressed = scale 0.98 (100ms). Focus = 2px `--color-accent` ring, 2px offset. Disabled = opacity 0.45.

**Contrast:** Body on bg ≥7:1. Muted ≥4.5:1. Accent fill buttons use `--color-accent-on`.

---

## Typography scale

| Role | Family | Weight | Desktop | Mobile | Line height | Max width |
|------|--------|--------|---------|--------|-------------|-----------|
| Display | Albra* | 700 | 56px | 40px | 1.05 | 12ch/line |
| H1 | Albra* | 600 | 48px | 36px | 1.1 | — |
| H2 | Albra* / Poppins | 600 | 36px | 28px | 1.15 | — |
| H3 | Poppins | 600 | 20px | 18px | 1.2 | — |
| Body | Poppins | 400 | 16px | 16px | 1.5 | 65ch |
| Body small | Poppins | 400 | 14px | 14px | 1.45 | — |
| Caption | Poppins | 400 | 12px | 12px | 1.4 | — |
| Overline | Poppins | 600 | 12px | 12px | 1.2 | uppercase 0.08em tracking |
| Button | Poppins | 600 | 16px | 16px | 1 | — |
| Label | Poppins | 500 | 14px | 14px | 1.3 | — |
| Data / ₹ | Courier / `ui-monospace` | 400 | 16–32px | 14–28px | 1.4 | tabular-nums |

\*Albra pending web licence — Poppins fallback per Product §9.2 until cleared.

**Responsive scaling:** `clamp()` for display/H2 in marketing scenes. Never below 16px body on mobile.

---

## Spacing scale

| Token | Value | Usage |
|-------|-------|-------|
| `--space-1` | 4px | Micro gaps |
| `--space-2` | 8px | List items, icon gaps |
| `--space-3` | 12px | Tight groups |
| `--space-4` | 16px | Mobile gutter min |
| `--space-5` | 24px | Card padding, grid gap |
| `--space-6` | 32px | Section internal |
| `--space-7` | 48px | Trust strip vertical |
| `--space-8` | 64px | Section padding mobile |
| `--space-9` | 96px | Section padding desktop |
| `--gutter` | 24px / 16px | Container horizontal |
| `--section-y` | 96px / 64px | Between story chapters |

**Rhythm:** Section title → content = `--space-6`. Card internal = `--space-5`.

---

## Grid & containers

| Token | Value |
|-------|-------|
| `--container-max` | 1200px |
| `--container-narrow` | 720px |
| `--container-app` | 1280px |

| Breakpoint | Columns | Gap | Margin |
|------------|---------|-----|--------|
| ≥1280px | 12 | 24px | auto centre |
| 768–1279px | 8 | 16px | `--gutter` |
| <768px | 4 (implicit stack) | 16px | `--gutter` |

**Alignment:** Marketing copy left-aligned in hero; centred for chapter titles (Scenes 04+). Legal prose centred column.

**Nested grids:** Feature grid 3×2 desktop; comparison table scroll wrapper mobile.

---

## Elevation, shadow, blur

| Level | Rule |
|-------|------|
| Flat | Default cards — 1px border only |
| Raised | Featured pricing — accent border + soft shadow |
| Nav scrolled | `backdrop-filter: blur(12px)`; bg 90% opacity |
| Drawer | `--color-surface-elevated`; overlay scrim 40% black |
| Cookie bar | Top shadow `0 -4px 24px rgba(0,0,0,0.4)` |

No heavy drop shadows. Depth via border + subtle glow on accent paths (motion-owned).

---

## Border radius

| Token | Value | Usage |
|-------|-------|-------|
| `--radius-sm` | 8px | Inputs, chips |
| `--radius-md` | 12px | Buttons |
| `--radius-lg` | 20px | Cards, phone frame |
| `--radius-full` | 9999px | Pills, step circles |

---

## Icon & illustration rules

- Stroke icons 24px default; `--color-accent` on dark
- Trust strip: stroke icons only — no emoji in final spec (current implementation flagged)
- Scenario ghosts (Scene 02): monochrome silhouettes, peripheral, max 2 desktop / 1 mobile
- Phone poster: real product UI crop; decorative layers `aria-hidden`
- No illustrative mascots v1

---

## Responsive breakpoints

| Name | Min width | Notes |
|------|-----------|-------|
| Mobile | 0 | Single column; bottom tabs in app shell |
| Tablet | 768px | 2-col grids; hamburger nav |
| Laptop | 1024px | Sidebar app shell; desktop nav links |
| Desktop | 1280px | Full 12-col marketing |

**Landscape mobile:** Hero CTAs remain above fold; reduce hero pin height 20%.

---

## Accessibility rules

- Skip link first focusable
- Focus visible on all interactives
- Min 44×44px touch targets
- `prefers-reduced-motion`: instant UI states; story content preserved (Motion Director)
- Single H1 per route; logical heading order
- Live regions for auth errors (`role="alert"`)
- Drawer: focus trap, Escape, `aria-modal`, `inert` when closed

---

## Scene UI handoff (storyboard-complete only)

Motion behaviour: see `motion-library.md` per scene. UI defines **layout, hierarchy, tokens, states** only.

### Scene 01 — The Arrival

| Field | Spec |
|-------|------|
| **Primary objective** | Brand world + Install without banner fatigue |
| **Primary focus** | Wordmark + tagline block (left/top) |
| **Secondary focus** | Phone visual (right/below) |
| **Ignore zone** | Nav anchor links until post-scrub |
| **Layout** | 12-col: copy cols 1–6, visual 7–12 desktop; stack mobile |
| **Container** | `--container-max`; hero min-height `calc(100vh - 64px)` |
| **Typography** | Overline optional; Display H1; body subtitle muted |
| **CTA hierarchy** | Install primary; Sign in ghost; tertiary text links caption |
| **Spacing** | H1→subtitle 16px; subtitle→CTAs 32px |
| **Interaction priority** | Scroll > Install > Sign in |
| **Responsive** | Install full-width mobile; visual below copy |
| **A11y** | LCP = H1; visual decorative; CTAs 48px |
| **Motion ref** | `motion-library.md` Scene 01 |
| **Acceptance** | Install visible @390px; no section fade-in; story felt in 3s |

### Scene 02 — The Awkward Truth (hero scrub II)

| Field | Spec |
|-------|------|
| **Primary objective** | Tension recognition — abstract ledger chaos |
| **Primary focus** | Chaos overlay on hero visual |
| **Secondary focus** | Emerging accent path at scrub 90%+ |
| **Ignore zone** | CTAs de-emphasized but **remain reachable** during pin |
| **Layout** | Same `#hero` DOM — overlay layers only |
| **Typography** | ₹ amounts tabular monospace 14–18px; no paragraph copy |
| **Colour** | Desaturated overlay; accent path `#18C595` only colour pop |
| **Responsive** | Mobile: 1 ghost, halved visual noise |
| **A11y** | Chaos decorative `aria-hidden`; amounts not announced |
| **Motion ref** | `motion-library.md` Scene 02 |
| **Acceptance** | No chat screenshots; no shame copy; inside `#hero` only |

### Scene 03 — The Split (`#how`)

| Field | Spec |
|-------|------|
| **Primary objective** | Mechanism clarity — 3 steps |
| **Primary focus** | Active step node on graph |
| **Secondary focus** | Step title + one-line body |
| **Ignore zone** | Feature grid below fold |
| **Layout** | Desktop: pinned graph centre; copy alternates L/R. Mobile: graph compact + vertical `<ol>` |
| **Container** | `--container-max`; `id="how"` |
| **Typography** | H2 section title; H3 step 18px; body 15px muted |
| **Components** | `HowItWorks` — see `component-library.md` |
| **Spacing** | H2→graph 40px; step gap 24px mobile |
| **Responsive** | No pin mobile; all steps visible |
| **A11y** | Semantic `<ol>`; graph `aria-hidden`; step numbers decorative |
| **Motion ref** | `motion-library.md` Scene 03 |
| **Acceptance** | UPI in step 3; factual mobile parity; non-interactive v1 |

### Scenes 04–09

**Blocked** until `storyboard.md` completes each scene. Stubs map to F-L03–F-L07 — no UI spec until narrative handoff lands.

---

## Changelog

| Date | Tick | Change |
|------|------|--------|
| 2026-07-27 | 0 | Foundation tokens; principles; Scene UI 01–03; input gate documented |
