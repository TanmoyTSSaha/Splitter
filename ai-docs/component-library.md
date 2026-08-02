# Splitr Website — Component Library

**Owner:** UI/UX Director Agent  
**Consumers:** Developer, Experience QA  
**Design tokens:** `design-system.md`  
**Motion references:** `motion-library.md` — per-component motion rows are **read-only refs**  
**Implementation map:** `apps/web/src/components/`  
**Last updated:** 2026-07-27 (Director tick 1)  
**Status:** Global chrome + hero/how components specified; scene 04+ pending storyboard

---

## Component index

| Component | Scene / surface | Status |
|-----------|-----------------|--------|
| `Nav` | Global marketing | Specified |
| `Footer` | Global marketing | Specified |
| `Button` | Global | Specified |
| `Logo` | Global | Specified |
| `CookieBanner` | F-C07 | Specified |
| `HeroChrome` | Scene 01–02 (`#hero`) | Specified |
| `HowItWorksSteps` | Scene 03 (`#how`) | Specified |
| `DeepLinkPreviewCard` | F-A07 | Specified |
| `TrustIcon` | F-L02 | Shipped tick 25 |
| `FeatureIcon` | F-L03 | Shipped tick 25 |
| `PlayStoreBadge` | F-L07, F-C09 | Shipped tick 26 — `FinalCta` + footer |
| `ErrorCard` | F-A03–A06 | Shipped tick 27 |
| `AppShell` | F-A02 | Deferred — app read-only; see `react-website-development-details.md` §12.2 |

---

## Button

**Purpose:** Primary conversion and navigation actions.

**Variants:** `primary` | `ghost` | `danger` (account delete flows only)

| Variant | Background | Border | Text |
|---------|------------|--------|------|
| primary | `--color-accent` | none | `--color-accent-on` |
| ghost | transparent | 1px `--color-border` | `--color-text` |
| danger | transparent | 1px error 45% | `--color-error` |

**Sizes:** Single marketing size — min-height 48px; padding 14px 24px; radius `--radius-md`.

**States:**

| State | Behaviour |
|-------|-----------|
| Hover | Brightness +4%; 150ms |
| Pressed | `scale(0.98)` 100ms — aligns Motion `Press compresses` |
| Focus | 2px accent ring, 2px offset |
| Disabled | Opacity 0.45; no pointer |
| Loading | Spinner accent; label "Loading…" |

**Responsive:** Full-width in mobile hero CTA row.

**A11y:** Visible focus; `aria-busy` when loading.

**Motion ref:** `motion-library.md` — press compress; hero Install may use magnetic hover (desktop only, Motion-owned).

**Developer notes:** `Button.tsx` + `Button.module.css`. `as="a"` for outbound Play Store.

**Acceptance:** 48px touch target; contrast AA on primary.

---

## Nav

**Purpose:** Global marketing chrome — wayfinding without stealing story focus.

**Layout:** Fixed 64px; logo left; anchor links centre (desktop); Install + Sign in right; hamburger `<1024px`.

**Variants:** `transparent` (top) | `scrolled` (blur + solid bg after 48px scroll).

**States:**

| State | Behaviour |
|-------|-----------|
| Drawer open | 280px aside right; overlay; focus trap; body scroll lock |
| Drawer closed | `inert` on aside |

**Typography:** Links Poppins 500 15px muted → text on hover.

**Spacing:** Inner `--gutter`; link gap 32px.

**Responsive:** Desktop links hidden @`<1024px`; drawer holds same links + CTAs.

**A11y:** Skip-link before nav; `aria-expanded` on menu; Escape closes; focus return to hamburger.

**Motion ref:** Nav scroll solidify 200ms — `motion-library.md` global chrome.

**Developer notes:** `Nav.tsx`, `useFocusTrap.ts`.

**Acceptance:** Install visible @390px; trap verified tick 18.

**Review notes (2026-07-27):** Focus trap ✅. Play badge text link — swap official asset (P3).

---

## Footer

**Purpose:** Compliance discovery + secondary product anchors.

**Layout:** 4-col grid → 2-col tablet → stack mobile. `--container-max`.

**Content blocks:** Brand + tagline | Product anchors | Legal (5 links) | Contact + Play.

**Typography:** Column heads 12px uppercase muted; links 14px.

**States:** Static — link hover → accent.

**A11y:** `role="contentinfo"`; H3 column titles.

**Developer notes:** `Footer.tsx`, `LEGAL_ROUTES` in `site.ts`.

**Acceptance:** All legal URLs resolve; Play outbound works.

---

## Logo

**Purpose:** Brand anchor — wordmark SVG from `assets/brand/master/`.

**Sizes:** Nav 32px height; footer 28px.

**States:** Default only; no animation on logo itself (scene motion may mask reveal wordmark separately).

**A11y:** Link to `/`; alt "Splitr".

---

## CookieBanner

**Purpose:** GA4 consent gate (F-C07).

**Layout:** Fixed bottom; message + Accept + Reject; stack mobile.

**States:** Entry slide-up 300ms; dismiss fade 200ms; Reject blocks GA4.

**A11y:** `role="dialog"`; Privacy link in body; Accept first tab stop in banner.

**Motion ref:** `motion-library.md` / §F-C07 — reduced-motion instant.

**Developer notes:** `CookieBanner.tsx`, `lib/analytics.ts`.

---

## HeroChrome

**Purpose:** Scene 01–02 container — copy, CTAs, `HeroVisual`, scrub overlay mount points.

**Usage:** Single `#hero` section — **not** separate sections for Acts I–II.

**Layout:**

| Breakpoint | Copy | Visual | CTAs |
|------------|------|--------|------|
| Desktop | Cols 1–6 | Cols 7–12 | Below subtitle |
| Mobile | Stack top | Below CTAs or between | Full-width Install |

**Components inside:** Overline, Display H1, subtitle, CTA row, tertiary links, `HeroVisual`.

**Visual hierarchy:**

| Priority | Element |
|----------|---------|
| 1 | H1 + tagline (Scene 01) |
| 2 | Phone poster (Scene 01) |
| 3 | Chaos layer (Scene 02 scrub) |
| 4 | Install CTA |
| 5 | Sign in |

**Interaction:** CTAs stay clickable during hero pin. Nav remains usable.

**Empty / loading:** Poster `loading="eager"`; no skeleton flash on first paint.

**A11y:** H1 is LCP; `HeroVisual` `aria-hidden`; poster `alt=""` decorative.

**Motion ref:** `motion-library.md` Scenes 01–02; `useHeroMotion`, `useHeroCopyMotion`, `useHeroVisualTilt`, `useMagneticHover` — Motion-owned.

**Developer notes:** `HomePage.tsx`, `HeroVisual.tsx`, hero pin hooks.

**Acceptance:** Scene 01 + 02 storyboard criteria; Install above fold mobile.

**Review notes:** HeroVisual + magnetic hover tick 17. Copy stagger tick 23. Mesh drift 20s verified tick 24. §8.1 implementation complete — post-deploy QA only.

---

## HowItWorksSteps

**Purpose:** Scene 03 — three-step mechanism (`#how`).

**Layout:**

| Breakpoint | Graph | Steps |
|------------|-------|-------|
| Desktop | Horizontal SVG connectors; optional pin | Numbered list beside/alternating |
| Mobile | Compact graph above | Vertical stack |

**Typography:** H2 32px; step H3 18px; body 15px muted.

**Spacing:** Step circle 40px; internal 16px to copy.

**States:** Non-interactive v1 — `data-active` on step for motion sync only.

**Empty:** N/A — static content.

**Responsive:** Mobile no pin; all steps visible.

**A11y:** `<ol>` semantic; circles `aria-hidden`; H2 `id="how-heading"`.

**Motion ref:** `motion-library.md` Scene 03; `useHowItWorksMotion`.

**Developer notes:** `HowItWorks.tsx`.

**Acceptance:** 3 steps; UPI step 3; `id="how"`.

**Review notes:** GSAP motion exceeds minimal §8.1 — OK if storyboard-aligned. `scroll_section_view` wired tick 22.

---

## DeepLinkPreviewCard

**Purpose:** F-A07 join/friend invite landing UI.

**Layout:** Centred card max 480px; marketing shell.

**Variants:** `logged-out` | `logged-in` | `invalid` | `loading`

| Variant | Title | CTAs |
|---------|-------|------|
| logged-out | Group/inviter name when API allows | Install primary; Sign in ghost |
| logged-in | Name + context | Open in app primary |
| invalid | Error message | Install fallback |
| loading | Skeleton | — |

**Typography:** Title 32px display; body 16px muted.

**States:** Error border `--color-error`; 300ms card fade-in (Motion).

**A11y:** H1 title; error `role="alert"`.

**Developer notes:** `DeepLinkPreviewCard.tsx`, `deepLinkData.ts`.

**Acceptance:** Logged-out valid token shows name via `preview-invite`; invalid unchanged. **Product Option A (tick 20)** — see `react-website-development-details.md` §12.2 F-A07 UI states table.

**Review notes (tick 21):** UI pass — logged-out title from `preview-invite` when function returns valid. Prod QA after deploy.

---

## TrustIcon

**Purpose:** F-L02 trust strip stroke icons (UPI, lock, check, India).

**Layout:** 22×22 SVG in `iconWrap` beside label.

**Variants:** `upi` | `lock` | `check` | `india`

**States:** Decorative — `aria-hidden` on SVG.

**Motion ref:** `useTrustStripMotion` — icon scale stagger on scroll.

**Developer notes:** `TrustIcon.tsx`, `TrustStrip.tsx`.

**Acceptance:** Stroke icons only — no emoji; accent color via `currentColor`.

**Review notes (tick 25):** Shipped — §11.12 P3 cleared.

---

## FeatureIcon

**Purpose:** F-L03 feature card icon in accent circle.

**Layout:** 32×32 stroke SVG inside 48×48 circle `--color-accent-fill-soft`.

**Variants:** `groups` | `personal` | `upi` | `friends` | `lending` | `goals`

**Developer notes:** `FeatureIcon.tsx`, `FeatureGrid.tsx`.

**Acceptance:** One icon per card; circle matches §12.2 F-L03 spec.

**Review notes (tick 25):** Shipped — §11.12 P3 cleared.

---

## PlayStoreBadge

**Purpose:** Official-style Google Play badge for install CTAs.

**Layout:** SVG/badge image; min touch target 48px height.

**States:** Hover brightness; tracks `cta_install_click` via parent `onClick`.

**Developer notes:** `PlayStoreBadge.tsx` — `FinalCta.tsx` + `Footer.tsx`. Nav keeps text Install button.

**Acceptance:** Footer + download band use badge; nav text OK v1.

**Review notes (tick 26):** Shipped footer + final CTA — §11.12 P3 cleared.

---

## ErrorCard

**Purpose:** Shared app-shell error + retry UI.

**Variants:** `card` (default bordered) | `plain` (detail pages)

**A11y:** `role="alert"`; optional Retry `Button`.

**Developer notes:** `ErrorCard.tsx` — wired on Overview, Groups, Friends, Account, detail pages.

**Review notes (tick 27):** Shipped — §11.12 ErrorCard item cleared.

---

## Changelog

| Date | Tick | Change |
|------|------|--------|
| 2026-07-27 | 2 | ErrorCard indexed tick 27 |
| 2026-07-27 | 1 | TrustIcon, FeatureIcon, PlayStoreBadge indexed; tick 25 polish sync |
| 2026-07-27 | 5 | §8.1 hero motion code complete verified tick 24 |
| 2026-07-27 | 4 | Hero copy stagger verified tick 23 |
| 2026-07-27 | 3 | P2 GA4 section views + pricing mobile order verified tick 22 |
| 2026-07-27 | 2 | F-A07 logged-out preview UI verified tick 21 |
| 2026-07-27 | 1 | F-A07 Option A UI acceptance synced with Product tick 20 |
| 2026-07-27 | 0 | Global chrome + HeroChrome + HowItWorksSteps + DeepLinkPreviewCard |
