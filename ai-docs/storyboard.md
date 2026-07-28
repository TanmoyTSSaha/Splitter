# Splitr Website — Interactive Storyboard

**Owner:** Storyboard Director Agent  
**Consumers:** Motion Director, UI/UX Director, Developer, Experience QA  
**Upstream:** `creative-direction.md`, `product-description.md`, `motion-library.md`  
**Product map:** `react-website-development-details.md` §7 (F-L01–F-L08)  
**Last updated:** 2026-07-27 (tick 1)  
**Status:** In progress — Scenes 01–03 complete; 04–09 pending

---

## Story Overview

**Format:** Interactive short film — scroll is time travel, not section hopping.  
**Arc:** Chaos → Split → Clarity → Settle (per Creative Director + Motion Library)  
**Acts:** Arrival → Tension → Mechanism → Depth → Verdict → Fair Deal → Vault → Last Question → Door  
**Total scenes:** 9  
**Pinned chapters (max):** 2–3 — **Hero pin (Scenes 01+02 combined)** + Scene 03 mechanism

### Hero extended scrub (Scenes 01 + 02 — user decision B)

Scenes 01 and 02 are **one continuous pinned hero arc** inside `#hero` / F-L01 — not a separate section. Narrative still has two scene beats; execution is single scroll scrub.

| Scrub phase | Scene | Beat |
|-------------|-------|------|
| 0%–35% | 01 — Arrival | Brand world, wordmark, tagline, phone orbit |
| 35%–50% | Bridge | Warmth drains; chaos seeds enter from phone edge |
| 50%–85% | 02 — Awkward Truth | IOU overlap, jitter, scenario ghosts, tension peak |
| 85%–100% | 02 exit | Accent path draws; chaos dims → handoff to Scene 03 |

**Total hero scrub:** ~2.0 vh desktop / ~1.6 vh mobile (shorter than separate chapters)

### Pacing Map (full story)

| Scene | Name | Pacing | Info density | Emotion shift |
|-------|------|--------|--------------|---------------|
| 01 | The Arrival | Slow → Reveal | Low | Neutral → Curiosity |
| 02 | The Awkward Truth | Acceleration → Pause | Medium | Curiosity → Recognized tension |
| 03 | The Split | Medium → Climax | Medium | Tension → First aha |
| 04 | The Full Picture | Fast → Reveal | High | Aha → Expanding excitement |
| 05 | The Verdict | Medium | Medium | Excitement → Quiet confidence |
| 06 | The Fair Deal | Slow | Medium | Confidence → Fairness |
| 07 | The Vault | Pause → Slow | Low | Fairness → Relief |
| 08 | The Last Question | Medium | High | Relief → Clarity |
| 09 | The Door | Climax → Resolution | Low | Clarity → Action |

### Why the visitor keeps scrolling (story thread)

Each scene ends with an **unresolved visual or narrative hook** — a line emerging from chaos, a balance about to snap, a door half-open. Never a full stop.

---

## Scene 01 — The Arrival

| Field | Detail |
|-------|--------|
| **Scene Number** | 01 |
| **Scene Name** | The Arrival |
| **Purpose** | Establish Splitr as a living product experience — not a brochure — and earn the first scroll |
| **Business Goal** | Stop bounce; primary install CTA visible without banner-ad feel; `scroll_section_view` hero |
| **Narrative Goal** | Answer *"What is Splitr?"* in one felt moment before any feature language |
| **Question Being Answered** | What is Splitr? |
| **Expected User Emotion** | Curiosity, premium calm — *"This feels different."* |
| **User Thought** | *"This isn't another split-app template."* |
| **Beginning State** | Dark, deep surface. Visitor arrives mid-moment — ambient depth alive. No loading theatre. Wordmark present but not screaming. |
| **Ending State** | Brand world established. Phone orbit completes. At scrub 35%: warmth begins draining — bridge into tension (same pin, no section break). |
| **Scene Duration** | **Scrub 0%–35%** of hero extended pin (~0.7 vh desktop) |
| **Pacing** | **Slow** → **Reveal** — breathe first, then wordmark + tagline unmask |
| **Information Density** | **Low** — brand + one-line promise only; no feature list |
| **Hero weave** | **Act I** of combined F-L01 pin — see overview table |

### Attention Management

| Role | Target |
|------|--------|
| **Primary Attention Target** | Brand world + subtle product surface (phone edge / UI glint) |
| **Secondary Attention Target** | Install CTA (present, not dominant) |
| **Ignore Everything Else** | Nav links, footer, secondary sign-in until after first scroll beat |

### Scroll Narrative

```
User lands (no fade-from-white)
    ↓
Ambient mesh / depth field breathes (idle + micro parallax)
    ↓
Camera: subtle dolly-in — visitor enters the world
    ↓
Wordmark (Albra) resolves from mask — not fade-in
    ↓
Tagline territory appears: "Split. Track. Settle." — one line, staggered mask
    ↓
At frame edge: phone mock / app surface catches specular highlight (orbit hint)
    ↓
Scroll cue: accent line (#18c595) pulses once along bottom edge — invitation, not button
    ↓
[scrub 35%] User continues scroll within same pin → camera tilts down; warmth drains; chaos seeds spawn from phone edge
    ↓
(continues as Scene 02 — no unpin)
```

### Transitions

| Direction | Beat |
|-----------|------|
| **Transition Into Scene** | Instant immersion — first paint is final art direction, no skeleton flash |
| **Transition Out Of Scene** | **In-scene bridge at 35% scrub** — no unpin; desaturate 5%; IOU lines bleed from phone screen edge |
| **Continue-scrolling hook** | *"The calm was a lie — something's tangled."* — chaos seeds visible before Scene 02 beat names itself |

### Interaction Opportunities

| Intent | Desktop | Mobile |
|--------|---------|--------|
| Scroll | Primary narrative driver | Primary |
| Hover | Cursor-reactive mesh depth (Linear-style glow) | — |
| Click | Install CTA, Sign in (secondary) | Tap CTAs |
| Idle | Ambient mesh drift | Ambient mesh (GPU-light) |
| Auto-play | Ambient loop only | Same |
| Tilt | Optional subtle parallax on phone edge | Device gyro if performant; else off |

### Platform Stories

**Desktop:** Wide canvas — wordmark left-third, product surface right-third orbiting slowly. Nav minimal top-right. Cursor parallax on mesh.  
**Tablet:** Stacked composition — wordmark top, product surface center, CTAs below tagline.  
**Mobile:** Vertical stack — wordmark → tagline → product peek → CTAs. Install primary full-width. No orbit; static phone with scroll-linked tilt on scrub only.

### Handoff Notes

| Agent | Notes |
|-------|-------|
| **Expected Motion Complexity** | Medium — ambient mesh + mask reveals + phone orbit on scrub 0–35% |
| **Motion Director** | `motion.ambient` mesh; `motion.clarity` for type unmask; `useHeroScrollMotion` pins full hero; specular on phone follows scrub 0–35% |
| **UI/UX Director** | NeoPOP deep surface; Albra wordmark anchor; CTA hierarchy per §6.2 — Install primary, Sign in ghost; LCP = text first; CTAs stay fixed during pin |
| **Developer** | F-L01; `#hero`; pin ~2.0 vh desktop; LCP <2.5s 4G; reduced-motion = static poster showing arrival + path; GA4 `scroll_section_view` hero |

### Acceptance Criteria

- [ ] Visitor understands "expense splitting app" feeling within 3s without reading feature list
- [ ] Install CTA visible without scroll on mobile
- [ ] No fade-in/slide-up section reveal
- [ ] Scroll within 3s on median session (analytics cross-ref)
- [ ] Reduced motion: instant final state, same story beat
- [ ] Handoff: Motion Director can animate from scroll narrative alone

**Product map:** F-L01 Hero

---

## Scene 02 — The Awkward Truth

| Field | Detail |
|-------|--------|
| **Scene Number** | 02 |
| **Scene Name** | The Awkward Truth |
| **Purpose** | Create emotional problem worth solving — shared money is awkward before Splitr enters |
| **Business Goal** | Emotional hook inside hero pin; increase scroll depth past 50% scrub |
| **Narrative Goal** | Answer *"Why is splitting money difficult?"* — recognition, not fear |
| **Question Being Answered** | Why is splitting money frustrating? |
| **Expected User Emotion** | Recognized tension → empathy — *"That's literally last weekend."* |
| **User Thought** | *"Yeah… dinner / trip / rent math is the worst."* |
| **Beginning State** | Scrub 35%: Scene 01 calm cracks — IOU lines bleed from phone screen, desaturation begins |
| **Ending State** | Scrub 100%: chaos peaks; **one accent path emerges**; hero unpins → Scene 03 input materializes |
| **Scene Duration** | **Scrub 35%–100%** of hero extended pin (~1.3 vh desktop / ~1.0 vh mobile) |
| **Pacing** | **Acceleration** → **Pause** at 85% scrub (path emergence) |
| **Information Density** | **Medium** — 2 scenario ghosts desktop (dinner, trip); mobile: 1 ghost only |
| **Hero weave** | **Act II** of combined F-L01 pin — **resolved: woven, not separate section** |

### Attention Management

| Role | Target |
|------|--------|
| **Primary Attention Target** | Abstract ledger chaos — overlapping lines, conflicting balances |
| **Secondary Attention Target** | Single emerging green path (#18c595) at scene end |
| **Ignore Everything Else** | Competitor names, product UI, pricing, CTAs |

### Scroll Narrative

```
[scrub 35%] IOU lines spawn from phone screen edge — same pin, no section break
    ↓
[scrub 45%] Overlapping IOU vectors multiply — slight jitter (`motion.tension`)
    ↓
[scrub 55%] Rupee fragments: ₹450, ₹1,200 — abstract tabular nums, not chat screenshots
    ↓
[scrub 60%] Scenario ghosts fade in periphery: dinner plate, suitcase (desktop); dinner only (mobile)
    ↓
[scrub 70%] Desaturation peaks; layers stack; mild overlap anxiety
    ↓
[scrub 85%] Pause beat — chaos holds one frame-feel
    ↓
[scrub 90%] Accent path path-trims through mess — not fade
    ↓
[scrub 100%] Chaos dims along path; hero unpins
    ↓
Camera follows path into Scene 03 — expense input wire materializes
```

### Transitions

| Direction | Beat |
|-----------|------|
| **Transition Into Scene** | Seamless at scrub 35% — warmth drains inside hero pin; no new section |
| **Transition Out Of Scene** | Hero unpin at 100%; accent path thickens into expense wire → Scene 03 |
| **Continue-scrolling hook** | *"What if one line could fix all of this?"* — path terminus glows |

### Interaction Opportunities

| Intent | Desktop | Mobile |
|--------|---------|--------|
| Scroll | Tightens chaos → reveals path | Same |
| Hover | IOU lines subtly repel cursor (optional) | — |
| Drag | — | — |
| Touch | — | Scroll only v1 |
| Idle | Micro jitter on overlapping layers | Reduced jitter |

### Platform Stories

**Desktop:** Chaos overlays hero visual; 2 scenario silhouettes peripheral; path draws center-left to bottom-right.  
**Tablet:** Same scrub phases; fewer IOU layers (max 8 vs 12).  
**Mobile:** Shorter hero pin (~1.6 vh total); 1 scenario ghost; path top-to-bottom; jitter amplitude halved.

### Handoff Notes

| Agent | Notes |
|-------|-------|
| **Expected Motion Complexity** | High — hero pin continues; SVG chaos layers on `HeroVisual` |
| **Motion Director** | `motion.tension` scrub 35–85%; path-trim 90–100%; `useHeroScrollMotion` timeline extends; disable mouse tilt while pinned |
| **UI/UX Director** | Abstract only — no chat screenshots; tabular ₹ nums; silhouettes monochrome; CTAs remain reachable during pin |
| **Developer** | **Merged into F-L01** — extend `useHeroScrollMotion` scrub phases; `scene02-chaos.svg` overlay in `HeroVisual`; no new `#section` |

### Acceptance Criteria

- [ ] User self-identifies with shared-expense awkwardness (India: dinner, trip, rent)
- [ ] No shame/alarmism — tension only
- [ ] Scene ends with single clear visual hook (accent path)
- [ ] Mobile: 1 scenario ghost, halved jitter, shorter pin
- [ ] Does not answer "how Splitr works" — that's Scene 03
- [ ] No separate DOM section — all inside `#hero` scrub

**Product map:** F-L01 Hero (extended scrub act II)

---

## Scene 03 — The Split

| Field | Detail |
|-------|--------|
| **Scene Number** | 03 |
| **Scene Name** | The Split |
| **Purpose** | Teach core mechanism — add → split → settle — without tutorial fatigue |
| **Business Goal** | Mechanism clarity before feature breadth; `scroll_section_view` how |
| **Narrative Goal** | Answer *"How does Splitr simplify everything?"* — first aha |
| **Question Being Answered** | How does Splitr simplify everything? |
| **Expected User Emotion** | Understanding → relief — *"Oh — it just… works."* |
| **User Thought** | *"Add expense, split, UPI settle — that's the whole thing."* |
| **Beginning State** | Accent path from hero thickens into expense input wire; chaos gone; clean dark surface |
| **Ending State** | Three-step graph complete; balances snap to zero; UPI ring pulses once — settled |
| **Scene Duration** | ~1.0 vh pinned (desktop); ~0.8 vh scroll-linked (mobile, no pin) |
| **Pacing** | **Medium** → **Climax** at step 3 settle → brief **Resolution** |
| **Information Density** | **Medium** — 3 steps only; one line copy per step |

### Attention Management

| Role | Target |
|------|--------|
| **Primary Attention Target** | Active step node on centre graph (Create → Split → Settle) |
| **Secondary Attention Target** | Step copy panel (left/right desktop; below node mobile) |
| **Ignore Everything Else** | Feature grid preview, pricing, comparison — not yet |

### Scroll Narrative

```
Hero unpin completes; accent path lands as expense input wire
    ↓
Section `#how` enters viewport — graph skeleton visible, connectors undrawn
    ↓
[pin desktop] Scroll scrubs 0–33%: Node 1 "Add" lights — emissive pulse + copy mask L→R
    ↓
Connector 1→2 draws via stroke-dashoffset
    ↓
[scrub 33–66%] Node 2 "Split" — people icons orbit out; amounts divide along paths
    ↓
Connector 2→3 draws
    ↓
[scrub 66–100%] Node 3 "Settle" — balances collapse to zero; UPI ring expands once (`motion.delight`)
    ↓
Graph scales down subtly; single line exits frame bottom → feeds Scene 04 toolkit
    ↓
Unpin — visitor scrolls into breadth chapter
```

### Transitions

| Direction | Beat |
|-----------|------|
| **Transition Into Scene** | Path from Scene 02 becomes input field — cause → effect |
| **Transition Out Of Scene** | Graph collapses to horizontal line; line fractures into 6 card edges (Scene 04) |
| **Continue-scrolling hook** | *"But that's just the beginning — what else is in here?"* |

### Interaction Opportunities

| Intent | Desktop | Mobile |
|--------|---------|--------|
| Scroll | Pin + scrub drives step activation | Vertical stack; all steps visible; connector draw on enter |
| Hover | Inactive nodes glow on hover when scrub idle | — |
| Click | Non-interactive v1 | — |
| Idle | Dormant pulse on active node 2s loop | — |
| Keyboard | Semantic `<ol>` focusable; graph decorative `aria-hidden` | Same |

### Platform Stories

**Desktop:** Pinned 100vh centre graph; step copy alternates left/right; horizontal mask reveal on active copy.  
**Tablet:** Pin optional — if perf <30fps, fall back to scroll-linked. Graph centre; copy below each node.  
**Mobile:** **No pin** — numbered list + compact graph above; connector draws once at 70% viewport; UPI burst on step 3 enter.

### Handoff Notes

| Agent | Notes |
|-------|-------|
| **Expected Motion Complexity** | High desktop (pin + scrub); Low–Medium mobile |
| **Motion Director** | `motion.clarity` + `motion.flow`; `useHowItWorksMotion` / F-L08 GSAP ref; UPI burst CSS `@keyframes`; graph scale 0.92→1.0 |
| **UI/UX Director** | 3 steps: Add expense → Split across people → Settle via UPI; India context in step 3; semantic list for a11y |
| **Developer** | F-L08 `#how`; `useLandingScrollMotion`; reduced-motion = all steps visible instantly; polish backlog: copy mask, UPI burst |

### Acceptance Criteria

- [ ] User understands 3-step flow in <8s scrub without reading every word
- [ ] Only one step highlighted at a time (desktop scrub)
- [ ] UPI mentioned in settle step — India-native
- [ ] No fade-in card entrances
- [ ] Mobile: full story without pin
- [ ] Reduced motion: numbered list, static graph, same information
- [ ] Factual match to mobile flows per Product §7 F-L08

**Product map:** F-L08 How it works

---

## Scene 04 — The Full Picture

> **Status:** Pending

**Question:** What makes Splitr different? (breadth)  
**Product map:** F-L03 Feature grid

---

## Scene 05 — The Verdict

> **Status:** Pending

**Question:** Why switch?  
**Product map:** F-L04 Comparison

---

## Scene 06 — The Fair Deal

> **Status:** Pending

**Question:** What does Pro cost — and is core free?  
**Product map:** F-L05 Pro pricing

---

## Scene 07 — The Vault

> **Status:** Pending

**Question:** Can I trust it?  
**Product map:** F-L02 Trust strip

---

## Scene 08 — The Last Question

> **Status:** Pending

**Question:** What about my objections?  
**Product map:** F-L06 FAQ

---

## Scene 09 — The Door

> **Status:** Pending

**Question:** Let's get started.  
**Product map:** F-L07 Final CTA

---

## Story Quality Checklist (rolling)

| Check | 01 | 02 | 03 | 04–09 |
|-------|----|----|-----|-------|
| Advances story | ✓ | ✓ | ✓ | — |
| Creates curiosity | ✓ | ✓ | ✓ | — |
| One primary focus | ✓ | ✓ | ✓ | — |
| Scroll feels rewarding | ✓ | ✓ | ✓ | — |
| Removal would hurt | ✓ | ✓ | ✓ | — |

---

## Open Questions (blocking finer detail)

1. ~~**Scene 02 placement**~~ — **Resolved: B — woven into hero extended scrub (F-L01)**
2. **Premium-warm vs playful-warm** — affects copy tone in scroll text beats, not structure
3. **Memorable feeling word** — relief vs control vs cleverness — calibrates Scene 03 climax weight
4. **Comparison tone** — clinical vs bold — affects Scene 05 scroll narrative

---

## Changelog

| Date | Tick | Change |
|------|------|--------|
| 2026-07-27 | 0 | Foundation: overview, pacing map, Scenes 01–02 full spec, 03–09 stubs |
| 2026-07-27 | 1 | User B: Scenes 01+02 merged into hero extended scrub; Scene 03 full spec |
