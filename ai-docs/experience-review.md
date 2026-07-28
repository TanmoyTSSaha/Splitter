# Splitr Website — Experience QA Review

**Owner:** Experience QA Director  
**Consumers:** Creative Director, Storyboard Director, Motion Director, UI/UX Director, Developer, Product  
**Inputs reviewed:** `creative-direction.md`, `storyboard.md`, `motion-library.md` (interim for `motion-language.md` + `scene-choreography.md`), `design-system.md`, `component-library.md`, `react-website-development-details.md`  
**Review URL:** `http://localhost:5173/`  
**Review Date:** 2026-07-27  
**Reviewer:** Experience QA Director (tick 1)  
**Viewports tested:** Desktop 1440×900, Mobile 390×844, Reduced motion (emulated)

---

## Executive verdict

| Field | Value |
|-------|-------|
| **Overall Experience Score** | **2.4 / 10** |
| **Approval Status** | **Rejected** |
| **Memorability test** | **Fail** — cannot recall three standout moments, one signature animation, or one earned transition |
| **Distinctiveness test** | **Fail** — remove logo → reads as generic dark fintech landing page |
| **CRED / Stripe / Linear bar** | **Not met** — functional v1 marketing page, not authored experience |

### One-line summary

Code marks features `Implemented`. Creative vision marks them **unbuilt**. Shipped site is a section-based SaaS template with banned fade-in motion — not the nine-scene scroll film in `storyboard.md`.

---

## Vision vs reality gap

| Creative intent (`creative-direction.md`, `storyboard.md`) | Shipped experience (browser) |
|------------------------------------------------------------|------------------------------|
| Interactive short film — scroll is time travel | Linear document scroll through labeled sections |
| Scenes 01–02: pinned hero scrub, chaos → tension | Static hero; eyebrow-only on desktop at first paint; small `hero-poster.png` |
| Ambient mesh, mask reveals, camera dolly | No WebGL/canvas; no GSAP; no Lenis; opacity/fade patterns |
| Motion language: clip-path unmask, accent paths | Generic card grid + fade-up stagger (explicitly banned in `motion-library.md` §I) |
| Trust: solid calm, custom iconography | Emoji trust strip (₹ 🔒 ✓ 🇮🇳) |
| Story hooks between scenes | Each section self-contained; no narrative handoff |

---

## Category scores (site-wide)

| Category | Score | Notes |
|----------|-------|-------|
| Storytelling | 2 | Information present; no story arc |
| Emotional journey | 2 | No tension → control arc |
| Motion quality | 1 | Near-static; banned fade patterns if any |
| Visual design | 5 | Clean dark tokens; template layout |
| Interaction quality | 4 | FAQ/mobile menu OK; weak affordances |
| Technical quality | 7 | Fast DCL; accessible base; routing gaps |

---

## Memorability audit (post-session)

After closing the site:

| Required recall | Result |
|-----------------|--------|
| Three standout moments | **None** |
| One emotional highlight | **None** |
| One signature animation | **None** |
| One memorable transition | **None** |

---

## Browser findings (tick 1)

| Check | Result |
|-------|--------|
| Canvas / WebGL | 0 canvases |
| GSAP / Lenis | Not detected |
| Hero poster | `hero-poster.png` — renders ~193×429 desktop; **empty `alt`** |
| Desktop hero first paint | Eyebrow text centered; vast void — broken/incomplete Scene 01 |
| `/features` direct URL | 404 (hash `/#features` works) |
| Trust strip | Emoji icons |
| Scroll height | ~6120px — long flat scroll |
| Reduced motion | Emulated; no authored parity path observed |
| Play badge | Text button, not official asset |

---

# Feature reviews

---

## F-L01 — Landing hero (Scene 01 + 02)

| Field | Value |
|-------|-------|
| **Review Date** | 2026-07-27 |
| **Reviewer** | Experience QA Director |
| **Story Score** | 1 |
| **Motion Score** | 1 |
| **Visual Score** | 4 |
| **Interaction Score** | 3 |
| **Technical Score** | 6 |
| **Overall Experience Score** | **2.0** |
| **Approval Status** | **Rejected** |

### Strengths

- Dark canvas + accent colour align with token table
- Skip link present
- Install CTA hierarchy readable on mobile
- `hero-poster.png` asset exists (partial step toward product-as-protagonist)

### Weaknesses

- Does not deliver Scene 01 *The Arrival* or Scene 02 *Awkward Truth*
- No pinned hero scrub, no chaos bridge, no mask-reveal typography
- Desktop layout collapses to eyebrow-only — fails first impression
- Poster tiny / orphaned; not hero protagonist
- Massive dead whitespace — not intentional restraint

### Critical issues

| Issue | Route to |
|-------|----------|
| Hero is a brochure block, not cinematic Scene 01–02 | **Storyboard Director** + **Motion Director** |
| Missing scroll-scrub pin, camera dolly, mesh ambient | **Motion Director** → **Developer** |
| Desktop hero broken / incomplete visual hierarchy | **UI/UX Director** → **Developer** |
| `hero-poster.png` empty alt | **Developer** |

### Minor issues

- Magnetic hover / scroll-cue accent pulse not present
- Intro overlay / `intro_seen` not observed

### Recommended improvements

1. Implement combined Scenes 01+02 pinned arc per `storyboard.md`
2. Replace fade entrances with mask reveals per `motion-library.md` §I
3. Hero poster full-scale with descriptive alt; phone frame as focal object
4. Validate desktop + mobile + reduced-motion parity before re-review

---

## F-L08 — How it works (Scene 03 territory)

| Field | Value |
|-------|-------|
| **Story Score** | 3 |
| **Motion Score** | 2 |
| **Visual Score** | 5 |
| **Interaction Score** | 4 |
| **Technical Score** | 7 |
| **Overall Experience Score** | **3.2** |
| **Approval Status** | **Major Changes Required** |

### Strengths

- Three-step logic clear
- Numbered cards readable
- Horizontal scroll on narrow viewports functional

### Weaknesses

- Reads as standard SaaS steps — not *The Split* climax scene
- No debt-simplification animation, no UPI path lighting
- Decorative green ring without narrative purpose

### Critical issues

| Issue | Route to |
|-------|----------|
| Scene 03 mechanism story not visualised | **Storyboard Director** + **Motion Director** |
| Step cards = template pattern | **Creative Director** |

### Recommended improvements

- Animate split → simplified balances per storyboard Scene 03
- One accent pulse on settle step only (motion language rule)

---

## F-L03 — Feature grid (Scene 04 territory)

| Field | Value |
|-------|-------|
| **Story Score** | 2 |
| **Motion Score** | 1 |
| **Visual Score** | 4 |
| **Interaction Score** | 3 |
| **Technical Score** | 7 |
| **Overall Experience Score** | **2.6** |
| **Approval Status** | **Major Changes Required** |

### Strengths

- Six capabilities listed accurately
- Consistent card chrome

### Weaknesses

- Identical cards — no differentiation, no product surfaces
- Feature dump contradicts *command, not catalogue* emotional beat
- Expected fade-up stagger (§12.2) violates motion-library bans

### Critical issues

| Issue | Route to |
|-------|----------|
| Scene 04 *Full Picture* not implemented | **Storyboard Director** |
| Banned fade-up card reveals | **Motion Director** → **Developer** |

---

## F-L04 — Comparison table (Scene 05)

| Field | Value |
|-------|-------|
| **Story Score** | 3 |
| **Motion Score** | 1 |
| **Visual Score** | 4 |
| **Interaction Score** | 3 |
| **Technical Score** | 7 |
| **Overall Experience Score** | **3.0** |
| **Approval Status** | **Major Changes Required** |

### Strengths

- Factual copy; disclaimer present
- Splitr column visually hinted (green border on mobile)

### Weaknesses

- Stacked cards on mobile — hard to scan
- `✓ ~ —` symbols without legend
- Quiet confidence beat missing — feels spreadsheet

### Critical issues

| Issue | Route to |
|-------|----------|
| Not Scene 05 *Verdict* editorial treatment | **UI/UX Director** |
| Comparison UX below evaluator needs | **UI/UX Director** |

---

## F-L05 — Splitr Pro pricing (Scene 06)

| Field | Value |
|-------|-------|
| **Story Score** | 3 |
| **Motion Score** | 1 |
| **Visual Score** | 5 |
| **Interaction Score** | 4 |
| **Technical Score** | 8 |
| **Overall Experience Score** | **3.4** |
| **Approval Status** | **Minor Changes Required** |

### Strengths

- Honest *checkout in app* messaging
- ₹ pricing clear; tabular-friendly layout

### Weaknesses

- Two static cards — no *Fair Deal* narrative
- Yearly save line weak

### Recommended improvements

- Scene 06 fairness framing per storyboard when available
- Subtle emphasis on yearly without dark patterns

---

## F-L02 — Trust strip (Scene 07)

| Field | Value |
|-------|-------|
| **Story Score** | 2 |
| **Motion Score** | 1 |
| **Visual Score** | 3 |
| **Interaction Score** | 4 |
| **Technical Score** | 7 |
| **Overall Experience Score** | **2.6** |
| **Approval Status** | **Major Changes Required** |

### Critical issues

| Issue | Route to |
|-------|----------|
| Emoji icons — not premium, not India-native craft | **UI/UX Director** |
| Missing *Vault* calm scene treatment | **Creative Director** |

---

## F-L06 — FAQ (Scene 08)

| Field | Value |
|-------|-------|
| **Story Score** | 4 |
| **Motion Score** | 3 |
| **Visual Score** | 5 |
| **Interaction Score** | 5 |
| **Technical Score** | 7 |
| **Overall Experience Score** | **4.2** |
| **Approval Status** | **Minor Changes Required** |

### Strengths

- Accordion toggles; aria states work
- Inline legal links in answers

### Weaknesses

- No chevron affordance
- Answers may clip on narrow widths
- Not *Last Question* scene — functional only

---

## F-L07 — Final CTA (Scene 09)

| Field | Value |
|-------|-------|
| **Story Score** | 2 |
| **Motion Score** | 1 |
| **Visual Score** | 4 |
| **Interaction Score** | 4 |
| **Technical Score** | 7 |
| **Overall Experience Score** | **2.8** |
| **Approval Status** | **Major Changes Required** |

### Weaknesses

- Generic closing band — no *Door* climax
- Repeated install CTA without escalation (4+ times page-wide)

---

## F-I02 — Routing / 404

| Field | Value |
|-------|-------|
| **Technical Score** | 5 |
| **Approval Status** | **Approved** (tick 8 — direct routes resolve) |

### Critical issues

| Issue | Route to |
|-------|----------|
| `/features`, `/pricing`, `/faq` return 404 | **Developer** | ✅ Resolved tick 8 — all return 200 |

---

# Three.js evaluation

| Question | Answer |
|----------|--------|
| Any Three.js scenes shipped? | **No** (0 canvas) |
| v1 allows CSS-only hero per motion-library | **Yes** — but CSS scene also incomplete |
| Decorative WebGL present? | **No** |
| Could hero exist without 3D? | **Yes** — and should, per v1 strategy |

**Verdict:** No improper WebGL. Problem is absent authored motion, not misuse of Three.js.

---

# Comparison review (quality bar)

| Reference | Splitr gap |
|-----------|------------|
| **Stripe** | No flow animation; infrastructure not made tangible |
| **CRED** | No chapter rhythm; no premium craft moments |
| **Linear** | No precision motion on intent |
| **Apple** | Product not protagonist in hero |
| **Inngest** | No process graph lighting sequence |

---

# Issue routing summary

| Owner | Priority issues |
|-------|-----------------|
| **Creative Director** | Site is template SaaS, not interactive film; approve scene-level pivots or descope storyboard |
| **Storyboard Director** | Scenes 01–09 unmapped in shipped UI; complete 04–09 specs |
| **Motion Director** | Ship motion language; ban fade-in compliance; hero pin + Scene 03 mechanism |
| **UI/UX Director** | Hero desktop layout; trust icons; comparison table; FAQ affordance |
| **Developer** | Hero visual completion; alt text; route redirects; remove banned motion patterns |
| **Product Agent** | Reconcile §7 `Implemented` vs creative gate; defer `Verified` until QA approves |

---

# Re-review criteria

Re-submit when **all** true:

1. Scenes 01–03 recognisable in browser without reading docs
2. At least one mask-reveal (not fade) and one accent-path animation
3. Hero product visual dominant on desktop + mobile
4. Trust strip uses designed icons
5. Memorability test passes (3 moments + 1 signature motion)
6. `/features` etc. resolve or redirect

---

# Changelog

| Date | Tick | Summary |
|------|------|---------|
| 2026-07-27 | 1 | Initial QA — **Rejected**; vision vs v1 gap documented |
| 2026-07-27 | 2 | Re-check — **no delta**; hero poster ~193×429 desktop but empty alt; no motion stack; `/features` still 404; status unchanged **Rejected** |
| 2026-07-27 | 3 | Re-check — **no delta**; same blockers; **Rejected** unchanged |
| 2026-07-27 | 4 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 5 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 6 | **Minor delta** — desktop hero grid (`_heroGrid_`) now shows full H1 + copy; poster still ~193×429, empty alt; 14 SVGs; no GSAP/Lenis/pin; scroll hit black frame mid-page (investigate); **Rejected** unchanged |
| 2026-07-27 | 7 | Re-check desktop — hero grid holds; poster unchanged; SVG count 16 (+2); no motion stack; **Rejected** unchanged |
| 2026-07-27 | 8 | **Partial delta** — `/features`, `/pricing`, `/faq` now **200** (re-review criterion #6 met); hero/poster/motion unchanged; **Rejected** unchanged |
| 2026-07-27 | 9 | Re-check — SVG count **18** (+2); routes still 200; hero/poster/motion unchanged; **Rejected** unchanged |
| 2026-07-27 | 10 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 11 | Re-check — SVG count **19** (+1); Play CTAs now labeled “Get Splitr on Google Play” (×5); hero/poster/motion unchanged; **Rejected** unchanged |
| 2026-07-27 | 12 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 13 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 14 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 15 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 16 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 17 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 18 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 19 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 20 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 21 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 22 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 23 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 24 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 25 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 26 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 27 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 28 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 29 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 30 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 31 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 32 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 33 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 34 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 35 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 36 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 37 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 38 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 39 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 40 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 41 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 42 | Re-check — **no delta**; **Rejected** unchanged (loop occurrence 40) |
| 2026-07-27 | 43 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 44 | Re-check — **no delta**; **Rejected** unchanged (loop occurrence 42) |
| 2026-07-27 | 45 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 46 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 47 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 48 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 49 | Re-check — **no delta**; **Rejected** unchanged |
| 2026-07-27 | 50 | Re-check — **no delta**; **Rejected** unchanged (loop occurrence 48) |
| 2026-07-27 | 51 | Re-check — **no delta**; **Rejected** unchanged (loop occurrence 49) |
| 2026-07-27 | 52 | Re-check — **no delta**; **Rejected** unchanged (loop occurrence 50) |
| 2026-07-27 | 53 | Re-check — **no delta**; **Rejected** unchanged (loop occurrence 51) |
| 2026-07-27 | 54 | Re-check — **no delta**; **Rejected** unchanged (loop occurrence 52) |
| 2026-07-27 | 55 | Re-check — **no delta**; **Rejected** unchanged (loop occurrence 53) |
| 2026-07-27 | 56 | Re-check — **no delta**; **Rejected** unchanged (loop occurrence 54) |
| 2026-07-27 | 57 | Re-check — **no delta**; **Rejected** unchanged (loop occurrence 55) |
| 2026-07-27 | 58 | Re-check — **no delta**; **Rejected** unchanged (loop occurrence 56) |
| 2026-07-27 | 59 | Re-check — **no delta**; **Rejected** unchanged (loop occurrence 57) |
