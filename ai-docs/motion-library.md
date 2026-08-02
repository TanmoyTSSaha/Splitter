# Splitr Motion Library

**Owner:** Motion Director Agent  
**Consumers:** Developer, UI/UX Director, Experience QA  
**Inputs:** `creative-direction.md` (draft), `storyboard.md` (01–02 complete), `react-website-development-details.md`  
**Last updated:** 2026-07-27 (Director tick 57)  
**Gate:** Scenes 04–09 blocked until `storyboard.md` completes each scene. Scenes 01–02 = **F-L01 extended pin** (resolved merged).

---

## I. Motion language (system behaviours)

Consistent rules — recognisable without logo.

| Behaviour | Rule | Why |
|-----------|------|-----|
| **Materials respond** | Accent `#18c595` travels along paths (split lines, UPI rings) — never static decoration | Money *moves* |
| **Camera commits** | Scroll = dolly/orbit; never section pop-in | Travel, not slides |
| **Type unmasks** | Text reveals via `clip-path` L→R or stroke-draw — never opacity fade | Legibility + craft |
| **Objects breathe** | Idle oscillation ≤6px, 6–20s — one layer per scene max | Alive, not noisy |
| **Press compresses** | Buttons `scale(0.98)` 100ms before navigation | Consequence |
| **Chaos → order** | Tension scenes overlap/jitter; clarity scenes snap to grid | Emotional arc |
| **One delight pulse** | Max one accent burst per chapter (UPI ring, CTA pulse) | Earned, not spam |
| **Reduced motion** | Same story, instant final keyframes — no parallax, no pin | Accessibility |

**Banned utilities (not experiences):** fade-in, slide-up, scale-in entrances, random float, generic parallax.

---

## II. Cinematic scene specifications

### Scene 01 — The Arrival

| Field | Spec |
|-------|------|
| **Motion Objective** | Establish living product world; earn first scroll without template fatigue |
| **Emotional Goal** | Curiosity, premium calm |
| **Narrative Purpose** | Answer *What is Splitr?* — felt before read |
| **Motion Complexity** | Medium — Act I of hero pin (scrub 0–35%) |
| **Primary Motion** | Mesh depth field breathes; wordmark mask reveal; phone orbit scrub 0–35% |
| **Secondary Motion** | Phone edge specular sweep; scroll-cue accent line pulse once |
| **Idle Motion** | Mesh drift 20s; phone float 6s ±6px (pre-pin only) |
| **Scroll Behaviour** | **Desktop:** hero pin ~2.0vh; scrub 0–35% = Scene 01; 35%+ = Scene 02 (same pin). **Mobile:** shorter pin ~1.6vh |
| **Hover Behaviour** | Mesh cursor glow (desktop); Install CTA magnetic 4px — **disabled while pinned** |
| **Touch Behaviour** | Tap CTAs only; no gyro v1 |
| **Keyboard Behaviour** | Tab order: skip-link → Install → Sign in |
| **Auto Motion** | Ambient loops only while in viewport |
| **Transition In** | Intro overlay: circle mask expand OR skip if `intro_seen` |
| **Transition Out** | **At scrub 35%** — no unpin; warmth drains; IOU seeds spawn from phone edge → Scene 02 |
| **Interaction Priority** | Scroll > Install CTA > Sign in > nav |
| **Reduced Motion Alternative** | Static poster showing arrival + resolved accent path |
| **Accessibility Notes** | LCP = H1 text; decorative visual `aria-hidden`; CTAs reachable during pin |
| **Performance Budget** | 60fps desktop; 30fps mobile floor; no WebGL above fold |
| **Developer Notes** | F-L01; `useHeroScrollMotion` pin; phases 0–35% in this scene |
| **Acceptance Criteria** | Install visible mobile; scroll within 3s; no fade-in; CTAs fixed during pin |

#### Camera direction — Scene 01

| Field | Value |
|-------|-------|
| Initial position | Z=5.0, Y=0, X=0 — slight downward tilt 3° |
| Final position (end scroll) | Z=4.6, Y=-0.15 — tilt 5° down |
| Movement path | Ease-out dolly + pitch |
| Speed | Scroll-scrubbed 0–35% of hero pin (~2.0vh desktop) |
| Acceleration / Deceleration | None (scrub) / soft ease at scene boundary |
| FOV | 45° perspective on phone container only |
| Depth of field | None v1 — sharp UI poster |
| Target object | Phone poster + mesh |
| Scroll camera | Dolly-in + pitch down |
| Hover camera | Phone ±6° toward cursor (disabled when scroll-pinned) |
| Idle camera | None — object float only |

#### Three.js scene — Scene 01

| Field | Spec |
|-------|------|
| **Purpose** | Optional v2 — poster orbit on scrub |
| **v1 strategy** | **CSS only** — `HeroVisual` poster + SVG split overlay; R3F behind `MOTION_HERO_3D` |
| **Objects** | Phone frame (CSS), screen quad (`hero-poster.png`), ambient mesh (CSS gradient) |
| **Materials** | Matte phone body; emissive accent on edge highlight |
| **Lighting** | N/A CSS v1 |
| **Exit** | Parallax lag 0.05 into Scene 02 |

#### Assets — Scene 01

| Asset | Spec |
|-------|------|
| Models | None v1 |
| SVG | Split paths + `scene02-chaos.svg` overlay in `HeroVisual` |
| Textures | `hero-poster.png` 280×606 — Groups overview when ready |
| Fonts | Display font stroke v1 (Albra when M2 licensed); Poppins body |
| Shaders | Optional mesh noise v2 |

#### Timeline — Scene 01 (`TL-Arrival-Load`)

| Step | Trigger | Duration | Sequence |
|------|---------|----------|----------|
| 1 Wordmark resolve | load / intro | 0.8s | SVG **stroke-draw** — not scale/opacity (§IV GLOBAL tick 24) |
| 2 Tagline stagger | +80ms | 0.5s | mask per line |
| 3 Mesh idle | post-load | ∞ | drift loop |
| 4 Scroll cue pulse | +2s idle | 0.4s once | accent line bottom |
| 5 Scene exit | scroll | scrub | dolly + desaturate |

**Interruption:** scroll anytime skips cue pulse  
**Replay:** intro skipped via `sessionStorage`  
**Reverse:** N/A (no pin)

#### Interaction catalogue — Scene 01

| Element | Hover | Focus | Pressed | Why |
|---------|-------|-------|---------|-----|
| Install CTA | magnetic 4px | ring | scale 0.98 | Primary conversion |
| Sign in | underline | ring | opacity 0.9 | Secondary path |
| Mesh | cursor glow | — | — | Premium craft |
| Phone | tilt ±6° | — | — | Product tangibility |

#### Physics — Scene 01

| Property | Use |
|----------|-----|
| Oscillation | Phone float sine 6s |
| Magnetism | CTA toward cursor |
| Floating | Mesh drift |

#### Performance — Scene 01

| Metric | Budget |
|--------|--------|
| Target FPS | 60 desktop / 30 mobile |
| GPU | ≤3 layers; DPR cap 1.5 |
| Mobile strategy | Static poster; CSS mesh only |
| Fallback | `hero-poster.webp` static |

**Product map:** F-L01 Hero

---

**Product map:** F-L01 Hero (Act I, scrub 0–35%)

#### Unified hero pin timeline (`TL-Hero-Extended`)

| Scrub % | Scene | Action |
|---------|-------|--------|
| 0–35% | 01 Arrival | Dolly-in; phone orbit; specular sweep; mesh calm |
| 35% | Bridge | IOU seeds from phone edge; desaturate begins — **no unpin** |
| 35–85% | 02 Awkward | Chaos layers; jitter; ₹ fragments; scenario ghosts |
| 85% | Pause | Chaos hold one beat |
| 90–100% | 02 → 03 | Accent path path-trim; chaos dims; **unpin** |
| 100% | Handoff | Path thickens → `#how` expense wire |

**Pin:** `end: '+=200%'` desktop; `+=160%` mobile. **Tilt off** while `scrollPinned`.

---

### Scene 02 — The Awkward Truth (Act II of F-L01 pin)

| Field | Spec |
|-------|------|
| **Motion Objective** | Create recognised tension — shared money is awkward |
| **Emotional Goal** | Empathy, mild anxiety (`motion.tension`) |
| **Narrative Purpose** | Answer *Why is splitting hard?* — hook before mechanism |
| **Motion Complexity** | High — continues hero pin scrub 35–100% |
| **Primary Motion** | IOU vectors spawn from phone edge; multiply + jitter |
| **Secondary Motion** | ₹ tabular fragments; 2 scenario ghosts desktop / 1 mobile |
| **Idle Motion** | Micro jitter 0.3px @ 4Hz on chaos layers |
| **Scroll Behaviour** | **Same pin as Scene 01** — scrub 35%→100%; mobile halved jitter |
| **Hover Behaviour** | IOU lines repel cursor 8px (optional, not while scrubbing) |
| **Touch Behaviour** | Scroll only |
| **Keyboard Behaviour** | Decorative layers `aria-hidden` |
| **Auto Motion** | Jitter while scrub 35–85% |
| **Transition In** | Seamless at scrub 35% inside hero — no new section |
| **Transition Out** | Unpin at 100%; path → Scene 03 `#how` wire |
| **Interaction Priority** | Scroll > emerging path |
| **Reduced Motion Alternative** | Static poster: chaos + resolved accent path |
| **Accessibility Notes** | Jitter off reduced-motion; no flash |
| **Performance Budget** | ≤12 SVG nodes desktop; ≤8 tablet |
| **Developer Notes** | **Merged F-L01** — `useHeroScrollMotion` §IV tick 25; `scene02-chaos.svg` on `HeroVisual` |
| **Acceptance Criteria** | Self-identify dinner/trip; ends accent path; no separate DOM section |

#### Camera direction — Scene 02

| Field | Value |
|-------|-------|
| Initial | Continues Scene 01 end — pitched down 5° |
| Final | Follows accent path — dolly toward path terminus |
| Path | Arc following accent line |
| Speed | Scrub; pause feel at 70% progress (~0.3vh hold) |
| FOV | 50° — slightly wider for chaos |
| Target | Accent path terminus |
| Scroll | Track path; slight roll 0→1° |
| Hover | Micro pan toward cursor on chaos field |
| Idle | Subtle handheld micro-shake on chaos group |

#### Three.js scene — Scene 02

**v1: SVG/CSS only** — no WebGL.

| Layer | Content |
|-------|---------|
| L0 | Desaturated mesh carry-over |
| L1 | IOU Bézier lines (stroke-dash, multiply) |
| L2 | Tabular ₹ amounts (Poppins nums) |
| L3 | Scenario silhouettes: plate, suitcase, key — monochrome |
| L4 | Accent path `#18c595` path-trim 0→100% |

#### Assets — Scene 02

| Asset | Spec |
|-------|------|
| SVG | `scene02-chaos.svg` — IOU paths + accent path — **asset brief:** §IV F-L01 tick 26 |
| Icons | 3 scenario silhouettes inline SVG |
| Fonts | Poppins tabular for amounts |
| Textures | None |

#### Timeline — Scene 02 (`TL-Awkward-Scrub`)

| Step | Progress | Action |
|------|----------|--------|
| 1 Chaos in | 0–0.25 | IOU lines spawn, jitter on |
| 2 Peak | 0.25–0.55 | Layers stack; desaturate max |
| 3 Pause beat | 0.55–0.65 | Hold — eye rests |
| 4 Path draw | 0.65–0.90 | Accent path trim; chaos dims along path |
| 5 Handoff | 0.90–1.0 | Path thickens; camera follows down |

**Dependencies:** Scene 01 exit desaturate  
**Completion:** path fully drawn  
**Interruption:** scrub reverse collapses path  
**Replay:** on re-enter from above, jump to final if reduced-motion

#### Physics — Scene 02

| Property | Use |
|----------|-----|
| Jitter | `motion.tension` — 0.3px noise |
| Repulsion | Cursor pushes IOU lines |
| Path constraint | Chaos opacity inverse to path progress |

#### Performance — Scene 02

| Metric | Budget |
|--------|--------|
| FPS | 60 desktop / 30 mobile |
| Draw calls | N/A SVG |
| Mobile | 1 ghost; jitter ×0.5; pin 1.6vh total |

**Product map:** F-L01 Hero (Act II, scrub 35–100%)

---

### Scene 03 — The Split

| Field | Spec |
|-------|------|
| **Motion Objective** | Teach add → split → settle without tutorial fatigue |
| **Emotional Goal** | Grip returning — **control** (`motion.clarity`); climax of control arc |
| **Narrative Purpose** | User *reads* who owes what — numbers are the hero |
| **Motion Complexity** | High desktop (pin ~1.2vh); Low–Medium mobile |
| **Primary Motion** | Expense condenses → split engine → balances snap to single truth |
| **Secondary Motion** | Step 2: amounts distribute; Step 3: tabular balances align; **UPI tease** (accent pulse only — full settle = Scene 09) |
| **Idle Motion** | Active node dormant pulse 2s loop (desktop, scrub idle) |
| **Scroll Behaviour** | **Desktop:** pin `#how` 100vh, scrub 0–33–66–100% = 3 steps. **Mobile:** no pin; connectors draw on enter |
| **Hover Behaviour** | Inactive nodes glow when scrub idle (desktop) |
| **Touch Behaviour** | Scroll; all steps visible |
| **Keyboard Behaviour** | Semantic `<ol>` focusable; graph `aria-hidden` |
| **Auto Motion** | Node pulse on active step only |
| **Transition In** | Scene 02 path thickens into expense input wire |
| **Transition Out** | Graph collapses to line → fractures into 6 card edges (Scene 04) |
| **Interaction Priority** | Active node > step copy > connectors |
| **Reduced Motion Alternative** | All 3 steps visible; static graph; no pin |
| **Accessibility Notes** | One step highlighted at a time (desktop); UPI in step 3 copy |
| **Performance Budget** | SVG + GSAP; 60fps desktop |
| **Developer Notes** | F-L08; `useHowItWorksMotion` — polish: copy mask, balance snap, UPI **tease** (not full burst) |
| **Acceptance Criteria** | Control readable without copy; reject generic 4-icon fade row; <8s scrub |

#### Camera direction — Scene 03

| Field | Value |
|-------|-------|
| Initial | Follows path from hero unpin — level horizon |
| Final | Slight pull-back as graph scales 0.92→1.0 |
| Path | Linear dolly Z 4.8→5.2 |
| Speed | Scrub-linear per step third |
| FOV | 42° |
| Target | Active step node |
| Scroll | Track active node; subtle scale on graph group |
| Hover | None on camera |
| Idle | Static |

#### Three.js scene — Scene 03

**None v1** — SVG graph + CSS accent tease.

| Layer | Content |
|-------|---------|
| L0 | Clean dark surface |
| L1 | Connector lines (stroke-dash) |
| L2 | Nodes 1–3 with emissive filter on active |
| L3 | Step copy panels — **mask reveal** not opacity |
| L4 | Step 3: **tabular balance numbers** snap to grid; accent path pulse toward settle (tease) |

#### Assets — Scene 03

| Asset | Spec |
|-------|------|
| SVG | Graph in `HowItWorks.tsx` — extend with people orbit icons step 2 |
| Icons | 3 node glyphs: +, split, UPI |
| Fonts | Poppins step copy |
| Shaders | None |

#### Timeline — Scene 03 (`TL-Split-Scrub`)

| Scrub % | Action |
|---------|--------|
| 0–30% | Beat 1: expense enters; chaos condenses to one line; Node 1 |
| 30–70% | Beat 2: split engine; amounts distribute along paths |
| 70–90% | Beat 3: balances snap to grid — **one number per name**; accent path tease pulse |
| 90–100% | Settled group balance zooms out → fractures toward Scene 04 |

**Trigger:** `#how` top hits viewport; pin desktop ≥1024px  
**Interruption:** scrub reverse dims nodes in order  
**Replay:** reduced-motion = final state on enter

#### Physics — Scene 03

| Property | Use |
|----------|-----|
| Spring | Balance numbers snap `back.out(1.2)` |
| Orbit | Step 2 distribution along paths |
| Snap | Grid alignment step 3 — control moment |

#### Performance — Scene 03

| Metric | Budget |
|--------|--------|
| FPS | 60 desktop / 30 mobile |
| Mobile | No pin; draw connectors once @ 70% viewport |
| Fallback | Static numbered list |

**Product map:** F-L08 How it works

#### Scene 03 — Developer polish (`TL-Split-Polish`)

**Copy mask** — active step body only:

```css
.step[data-active='true'] .stepBody {
  animation: maskReveal 400ms cubic-bezier(0.16, 1, 0.3, 1);
}
@keyframes maskReveal {
  from { clip-path: inset(0 100% 0 0); }
  to { clip-path: inset(0 0 0 0); }
}
```

**UPI tease** — step 3 only, accent path 1px pulse (not full ring):

```css
.node[data-step='3'][data-tease='true']::after {
  animation: upiTease 400ms ease-out once;
}
@keyframes upiTease {
  from { stroke-opacity: 1; stroke-width: 2; }
  to { stroke-opacity: 0; stroke-width: 6; }
}
```

Set `data-tease` when `progress > 0.7`. **Full UPI settle reserved for Scene 09.**

**Implementation:** drop-in spec in §IV F-L08 B4 (Motion Design tick 17) — DOM + `onUpdate` hooks.

**Exit fracture** — graph `scale(0.85)` + horizontal line `scaleX(0→1)` seeds Scene 04 — see **§II.I** handoff contract.

---

### Scene 04 — The Full Picture *(DRAFT — storyboard pending)*

| Field | Intent (from `creative-direction.md` only) |
|-------|---------------------------------------------|
| **Motion Objective** | Toolkit expands from one settled balance — breadth without feature dump |
| **Emotional Goal** | Command — one ledger for split, goals, lending, trips |
| **Primary Motion** | 6 product surfaces unfold from fracture line (not icon fade grid) |
| **Motion token** | `motion.flow` — depth parallax, chapter unlock |
| **Transition In** | Scene 03 balance zooms out → cards peel from line |
| **Failure mode** | Generic 3×2 fade-up card grid = reject |
| **Product map** | F-L03 |

#### Scene 04 — DRAFT timeline (`TL-Toolkit-Unfold`)

| Step | Trigger | Action |
|------|---------|--------|
| 1 Fracture in | Scene 03 exit | Horizontal line visible across `#features` top |
| 2 Peel | scroll 25% | 6 card top-edges emerge from line — `rotateX(12°→0)` stagger 60ms |
| 3 Depth | +100ms | Each card shows **UI crop** not icon — parallax 0.05 on hover |
| 4 Settle | complete | Grid static; `useFeatureCardTilt` ≤4° (spec 2°); `FeatureIcon` stroke icons shipped; hover trail per §II.B |

**Camera:** Pull back Z 5.2→5.6 as cards peel. **Assets:** 6 UI screenshot crops (groups, goals, lending, friends, UPI, insights) — icons are interim. **Pin:** none — parallax fan desktop; stack mobile.

**Creative brief (interim):** One command center; cards fan from fracture; exit aligns into compare columns.

**Implementation:** fracture line drop-in in §IV F-L03 tick 18 — wires §II.I 03→04 v1 shortcut (`HomePage` bridge).

*Full cinematic spec blocked until `storyboard.md` Scene 04 complete.*

---

### Scene 05 — The Verdict *(DRAFT — storyboard pending)*

| Field | Intent |
|-------|--------|
| **Motion Objective** | Evaluator sees Splitr column **resolve** — clarity not petty wins |
| **Emotional Goal** | Confidence in visibility — balances not buried |
| **Primary Motion** | Row-by-row snap alignment; Splitr sharp, competitors soften depth |
| **Motion token** | `motion.clarity` |
| **Transition In** | Scene 04 cards flatten to table rows |
| **Failure mode** | Checkmark scale pop + green column only |
| **Memorable moment** | QA recall #3 — compare rows resolve |
| **Product map** | F-L04 |

#### Scene 05 — DRAFT timeline (`TL-Compare-Resolve`)

| Step | Action |
|------|--------|
| 1 | `#features` `data-exit-align` — cards baseline before scan (§IV F-L03→F-L04 tick 21) |
| 2 | Scan line sweeps L→R (shipped) |
| 3 | Per row: Splitr cell snaps to grid; competitor cells blur 2px depth |
| 4 | Checkmarks **stroke-draw** not scale pop |
| 5 | `data-verdict-settled` on `#compare` + Splitr column hold 400ms → pricing (§IV tick 22) |

**Code today:** scan + mobile pulse shipped. **Gaps:** `data-exit-align` (tick 21); stroke-draw; depth soften; `data-verdict-settled` (tick 22).

*Full spec blocked until `storyboard.md` Scene 05 complete.*

---

### Scene 06 — The Fair Deal *(DRAFT — storyboard pending)*

| Field | Intent |
|-------|--------|
| **Motion Objective** | Free core ledger dominates; Pro floats as optional power layer |
| **Emotional Goal** | Fairness — control without paywall on core |
| **Primary Motion** | Free tier anchored; Pro card depth lift — no bounce |
| **Motion token** | `motion.trust` — stable, slow |
| **Transition In** | Scene 05 `data-verdict-settled` → `free-anchor` visible before Pro lift (§IV tick 22) |
| **Failure mode** | Pro card larger/brighter than free — demotes core promise |
| **Exit hook** | "Your data" lingers → Scene 07 |
| **Product map** | F-L05 |

#### Scene 06 — DRAFT timeline (`TL-Pricing-Fair`)

| Step | Action |
|------|--------|
| 1 | `[data-motion="free-anchor"]` static callout — **no** animation delay (§IV F-L05 tick 21) |
| 2 | Pro card lift — **only after** `free-anchor` in view (§IV F-L04→F-L05 tick 22) |
| 3 | Annual toggle highlight `phys.snap` — not flash |
| 4 | ₹89/mo · ₹799/yr tied to OCR, export, insights copy — factual anchor |

**Code today:** annual lift shipped. **Gaps:** `free-anchor` missing (tick 21); Pro lift not gated on verdict settle (tick 22); Q10 fail.

*Full spec blocked until `storyboard.md` Scene 06 complete.*

---

### Scene 07 — The Vault *(DRAFT — storyboard pending)*

| Field | Intent |
|-------|--------|
| **Motion Objective** | Trust as environment — ledger vaulted, not badge row |
| **Emotional Goal** | Steady ground — safe to store balances |
| **Primary Motion** | Temperature cools; horizon stable; locks close |
| **Motion token** | `motion.trust` |
| **Transition In** | Warmth from pricing cools to neutral-stable |
| **Failure mode** | Emoji badges; animated shield bounce |
| **Exit hook** | One FAQ ghost line visible → Scene 08 |
| **Product map** | F-L02 |

#### Scene 07 — DRAFT timeline (`TL-Trust-Vault`)

| Step | Action |
|------|--------|
| 1 | Section enter: `steps(3)` stamp on icons (shipped) |
| 2 | `data-vault-cool` on `#trust` — background/border cool 600ms (§IV F-L02 tick 20) |
| 3 | Icons: `TrustIcon` stroke SVGs shipped — lock, UPI, check, India |
| 4 | Signals factual only: encryption, no ads, UPI-native, India-first |

**Code today:** stamp + `TrustIcon` shipped. **Gap:** `data-vault-cool` not wired — drop-in spec ready (§IV F-L02 tick 20).

*Full spec blocked until `storyboard.md` Scene 07 complete.*

---

### Scene 08 — The Last Question *(DRAFT — storyboard pending)*

| Field | Intent |
|-------|--------|
| **Motion Objective** | Dissolve objections — clarity over animation |
| **Emotional Goal** | Full clarity — last unknowns resolved |
| **Primary Motion** | Accordion expand reveals content; no bounce |
| **Motion token** | Minimal — content wins |
| **Transition In** | Questions emerge from Scene 07 trust |
| **Failure mode** | Bouncy accordion; legal-wall density |
| **Exit hook** | Final item closes → empty beat → Scene 09 install magnet |
| **Product map** | F-L06 |

#### Scene 08 — DRAFT timeline (`TL-FAQ-Clarity`)

| Step | Action |
|------|--------|
| 1 | User opens item — `grid-template-rows` expand 250ms ease-out (shipped) |
| 2 | Chevron rotates 45° on expand — cosmetic; 180° optional |
| 3 | Copy topics: web vs app, data, free vs Pro — dialogue not legalese |
| 4 | Last panel close → `data-exit-breath` 200ms padding (§IV F-L06 tick 19) → CTA wipe |

**Code today:** CSS accordion shipped. **Gap:** `data-exit-breath` not wired — drop-in spec ready (§IV F-L06 tick 19).

*Full spec blocked until `storyboard.md` Scene 08 complete.*

---

### Scenes 05–09

| Scene | Storyboard | Motion spec |
|-------|------------|-------------|
| 05 Verdict | Pending | **DRAFT** (`TL-Compare-Resolve`) |
| 06 Fair Deal | Pending | **DRAFT** (`TL-Pricing-Fair`) |
| 07 Vault | Pending | **DRAFT** (`TL-Trust-Vault`) |
| 08 Last Question | Pending | **DRAFT** (`TL-FAQ-Clarity`) |
| 09 Door | Pending | **DRAFT** (`TL-Install-Door` — partial ship) |

### Scene 09 — The Door *(DRAFT — storyboard pending)*

| Field | Intent |
|-------|--------|
| **Motion Objective** | Story resolution — **full UPI settle** earns Scene 03 tease |
| **Emotional Goal** | Ownership — user takes the ledger (`motion.delight` once) |
| **Primary Motion** | Concentric UPI rings from CTA; balances visually **settled** |
| **Secondary Motion** | CTA magnetic 6px; band mask wipe up on enter |
| **Scroll Behaviour** | One-shot enter @ 60% viewport; rings loop while `data-in-view` |
| **Transition In** | FAQ collapses; warmth returns; accent pulse completes arc |
| **Reduced Motion** | Static band + CTA; no rings |
| **Performance** | CSS pseudo-elements only; pause rings off-screen |
| **Product map** | F-L07 |
| **Acceptance Criteria** | Only scene with full UPI ring burst; `cta_install_click` fires; QA recall **#4** install pulse |

#### Scene 09 — DRAFT timeline (`TL-Install-Door`)

| Step | Action |
|------|--------|
| 1 | FAQ `data-exit-breath` completes (§II.I) — then band mask wipe up (shipped) |
| 2 | Settled-balance visual — `[data-motion="settled-balance"]` above `#download-heading` (see F-L07 §IV tick 16); `phys.snap` to zero debt |
| 3 | UPI rings emanate from Install badge — full burst (Scene 03 was tease only) |
| 4 | One `motion.delight` accent pulse on primary CTA — then static |
| 5 | Footer epilogue — legal static, no motion |

**Partial ship (code):** `FinalCta` — mask wipe, `ringPulse` CSS, `useMagneticHover(6)`, `data-in-view` pause. **Gap:** no `[data-motion="settled-balance"]` DOM; rings ambient not narrative payoff; install pulse not isolated (QA #4).

*Full spec blocked until storyboard Scene 09 complete.*

---

## II.F Implementation fidelity matrix (Director view)

| Scene | Product | Cinematic spec | Code status | Gap |
|-------|---------|----------------|-------------|-----|
| 01+02 | F-L01 | §II Scenes 01–02 | Partial | B1 package ready (§IV tick 25); poster/tilt shipped; pin + chaos SVG not built |
| 03 | F-L08 | §II Scene 03 | Partial | B4 drop-in spec ready (§IV tick 17); mask/tease/snap + exit fracture |
| 04 | F-L03 | DRAFT | Partial | Unfold + icons + tilt shipped; fracture spec ready (§IV tick 18); UI crops missing |
| 05 | F-L04 | DRAFT | Partial | Scan ok; exit-align + stroke-draw + `data-verdict-settled` gaps |
| 06 | F-L05 | DRAFT | Partial | Annual lift ok; `free-anchor` + verdict gate (ticks 21–22) |
| 07 | F-L02 | DRAFT | Partial | Stamp + `TrustIcon` shipped; `data-vault-cool` spec ready (§IV tick 20) |
| 08 | F-L06 | DRAFT | Partial | Accordion ok; `data-exit-breath` spec ready (§IV tick 19) |
| 09 | F-L07 | DRAFT | Partial | Wipe + rings + magnetic; `[data-motion="settled-balance"]` + install pulse (QA #4) |

**Critical path:** B1 (hero pin) unlocks Scenes 01–02 → makes Scene 03 handoff legible.

---

## II.G Physics & lighting (globals)

### Physics vocabulary

| Token | When | Parameters |
|-------|------|------------|
| `phys.snap` | Numbers align, balances resolve | `back.out(1.2–1.4)` |
| `phys.orbit` | Distribution, people, phone | circular path, linear scrub |
| `phys.jitter` | Chaos only (Scene 02) | ≤0.3px, 4Hz, off reduced-motion |
| `phys.magnet` | Primary CTAs | ≤6px toward cursor |
| `phys.float` | Idle breathe | sine 6–20s, ≤6px |
| `phys.compress` | Button press | scale 0.98, 100ms |

### Lighting (CSS v1 / R3F v2)

| Context | Key | Fill | Rim | Notes |
|---------|-----|------|-----|-------|
| Hero phone | — | ambient `#0d0d0d` | accent specular on scroll 0–35% | CSS gradient v1 |
| Chaos | cool | desaturate 8% | none | Scene 02 only |
| Clarity beats | neutral | `--color-bg` | accent node glow | Scenes 03, 05 |
| Trust / Pro | warm-stable | flat | none | Scenes 06–07 |
| CTA climax | warm return | gradient band | UPI ring emissive | Scene 09 only |

No R3F lighting v1. `MOTION_HERO_3D` adds: `AmbientLight 0.4`, `DirectionalLight` follow camera, emissive accent on UPI ring.

### Developer priority stack

| Priority | Work | Unblocks |
|----------|------|----------|
| P0 | B1 hero extended pin | Scenes 01–02 narrative |
| P1 | B4 Scene 03 polish | Control arc climax |
| P2 | B2 intro SVG stroke (§IV tick 24) | Scene 01 wordmark; brand first beat |
| P3 | Scene 04 fracture unfold | Breadth chapter — **deps:** B4 exit + F-L03 tick 18 |
| P4 | B3 auth `formSwap` (§IV tick 23) | Auth polish — ~30m |
| P5 | Scene 09 settle visual + install pulse | UPI payoff (QA #4) |
| P6 | F-L06 `data-exit-breath` | Scene 08→09 handoff — **no storyboard blocker** |
| P7 | F-L02 `data-vault-cool` | Scene 06→07 tone shift — **no storyboard blocker** |

---

## II.J Build-ready specs (no storyboard blocker)

Drop-in work documented in §IV — can ship before `storyboard.md` Scenes 04–09 complete:

| ID | Spec location | Unblocks |
|----|---------------|----------|
| B1 | §IV F-L01 tick 25 (`useHeroScrollMotion`) | QA #1, Scenes 01–02 |
| B4 | §IV F-L08 tick 17 | QA #2, Scene 03 climax |
| Fracture | §IV F-L03 tick 18 + §II.I 03→04 | Scene 04 peel axis |
| Compare | §IV F-L04 tick 15 | QA #3, Scene 05 |
| Cards align | §IV F-L03→F-L04 tick 21 + §II.I 04→05 | Scene 05 entry rhythm |
| Free anchor | §IV F-L05 tick 21 + §II Scene 06 | Q10 |
| Verdict settle | §IV F-L04→F-L05 tick 22 + §II.I 05→06 | Scene 06 entry |
| FAQ breath | §IV F-L06 tick 19 + §II.I 08→09 | Q12, Scene 09 entry |
| CTA settle | §IV F-L07 tick 16 | QA #4, Scene 09 payoff |
| Vault cool | §IV F-L02 tick 20 + §II.I 06→07 | Q11, Scene 07 |
| B2 | §IV GLOBAL tick 24 (SVG stroke wordmark) | Scene 01 brand beat |
| B3 | §IV F-A01 tick 23 (`formSwap` clip-path) | Auth polish — ~30m |

---

## II.K Recommended build sequence (landing film)

Single ordered pass for Developer — each step references §II.J + §II.I handoffs.

| Step | Work | Spec |
|------|------|------|
| 1 | Hero extended pin | B1 — §IV F-L01 tick 25 |
| 2 | Scene 03 B4 polish | §IV F-L08 tick 17 |
| 3 | Intro SVG stroke | B2 — §IV GLOBAL tick 24 (M2 Albra defer) |
| 4 | Fracture line + Scene 03 exit | §IV F-L03 tick 18 + §II.I 03→04 |
| 5 | Features exit-align | §IV F-L03→F-L04 tick 21 |
| 6 | Compare stroke-draw + depth | §IV F-L04 tick 15 |
| 7 | Verdict settle | §IV F-L04→F-L05 tick 22 |
| 8 | Free anchor + Pro lift gate | §IV F-L05 ticks 21–22 |
| 9 | Vault cool | §IV F-L02 tick 20 |
| 10 | FAQ exit breath | §IV F-L06 tick 19 |
| 11 | CTA settle + install pulse | §IV F-L07 tick 16 |
| 12 | Auth tab cross-fade | B3 — §IV F-A01 tick 23 (off-film; parallel ok) |

**Minimum ship (QA §II.H):** steps 1–2 + 11. Steps 4–10 strengthen mid-film; step 12 auth-only.

---

## II.L Documentation milestone (tick 20)

Agent-loop spec pass **complete** for developer handoff:

| Area | Status |
|------|--------|
| Scenes 01–03 | Full cinematic specs + §IV drop-ins |
| Scenes 04–09 | DRAFT timelines + §IV drop-ins (storyboard pending for full spec) |
| §II.I handoffs | Intro→01 through 08→09 documented |
| §II.J build-ready | 12 items — all have §IV implementation notes |
| §II.K sequence | 12-step ordered build pass |
| §IV §4.2 map | Audit rows ↔ §II.K steps (Design tick 26) |
| Production code | **None from agent loops** — Developer Agent executes §II.K |

**Next gate:** `storyboard.md` Scenes 04–09 for full cinematic promotion. **Next build:** §II.K step 1 (B1 tick 25).

**Maintenance (ticks 21+):** Design tick 66 / Director tick 57 — no code drift; §II.F unchanged. Agent loops hold until Developer or storyboard moves.

---

## II.H Memorable moments — QA recall map

24h debrief target: **≥3** standout moments. Minimum ship set: **#1 + #2 + #4**.

| # | Scene | Signature moment | Ship status |
|---|-------|------------------|-------------|
| 1 | 02 | Numbers drift apart, won't align | **Spec ready** — B1 §IV tick 25 not built |
| 2 | 03 | Grid snap — every name, one balance | **Partial** — pin ok; snap polish needs B4 |
| 3 | 05 | Compare rows resolve into Splitr column | **Partial** — scan ok; stroke-draw + depth soften |
| 4 | 09 | Single accent pulse on install CTA | **Partial** — rings ambient; pulse + settle DOM missing |

Moment **#3** strengthens evaluator recall — not required for minimum ship.

---

## II.I Scene handoff contracts

Cross-scene bridges — developer wires these so scroll feels continuous, not section jumps.

### Intro → 01 (`stroke-to-arrival`)

| Phase | Action |
|-------|--------|
| GLOBAL | SVG wordmark stroke-draw 0.8s — **spec:** §IV GLOBAL tick 24 |
| Handoff | Circle mask expand reveals hero — shipped `IntroOverlay` |
| Scene 01 | H1 mask reveal (`useHeroMotion`) begins as overlay unmounts |
| Failure mode | Wordmark `scale`+`opacity` pop — template tell; B2 open |

**M2:** Albra `<path>` swap when licensed — stroke timing unchanged.

### 02 → 03 (`path-to-wire`)

| Phase | Action |
|-------|--------|
| Scene 02 @ 90–100% | `[data-motion-accent-path]` path-trim completes (B1 §IV tick 25) |
| Unpin | Hero releases; path Y aligns with `#how` connector top |
| Scene 03 enter | First `[data-motion-connector]` continues accent stroke — visual continuity |
| Failure mode | Hard cut between hero and how-it-works — breaks control arc |

**Spec:** B1 `onUpdate` accent trim must match `#how` SVG connector start coordinates. **Detail:** §IV F-L01 tick 26 (path terminus → `#how` `y=24`).

### 03 → 04 (`fracture-line`)

| Phase | Element | Action |
|-------|---------|--------|
| Scene 03 @ 95% scrub | `#how [data-motion="fracture-line"]` | 2px accent line spans graph width; graph `scale(0.85)` |
| Unpin / scroll | Line persists fixed to viewport bottom of `#how` | `position: absolute; bottom: 0` |
| Scene 04 enter | `#features [data-motion="fracture-line"]` | Same line — or FLIP from 03 exit if both in DOM |
| Scene 04 step 2 | Line is peel axis | Card `rotateX` pivots from line Y |

**v1 shortcut:** single shared `[data-motion="fracture-line"]` in `HomePage` between `#how` and `#features` — avoids FLIP complexity. **Spec:** §IV F-L03 tick 18.

### 04 → 05 (`cards-to-rows`)

| Phase | Action |
|-------|--------|
| Scene 04 exit | Feature cards lose tilt; align to single baseline |
| Scroll bridge | `#features` bottom margin breathes 8vh — evaluator pauses |
| Scene 05 enter | `#compare` table rows share column widths with card grid above |
| Scan line | Starts only after rows visually aligned — not on card fade |

**Spec:** §IV F-L03→F-L04 tick 21 (`data-exit-align` on `#features`).

**Failure mode:** Feature grid scrolls away; compare table fades in independently — breaks "verdict" narrative.

### 05 → 06 (`verdict-to-fair`)

| Phase | Action |
|-------|--------|
| Scene 05 exit | Scan + checks complete → `#compare` `data-verdict-settled="true"` |
| Hold | Splitr column accent background 400ms — rational pause |
| Scene 06 enter | `#pricing` `free-anchor` static in first paint — no delay |
| Pro motion | `usePricingMotion` fires only after anchor visible — **spec:** §IV F-L04→F-L05 tick 22 |

**Failure mode:** Pro cards animate before user reads free-core message — Q10 fail.

### 06 → 07 (`warm-to-vault`)

| Phase | Action |
|-------|--------|
| Scene 06 exit | Pro card lift settles; warmth holds briefly |
| Scroll bridge | `#pricing` → `#trust` — no new motion |
| Scene 07 enter | `#trust` sets `data-vault-cool="true"` after stamp — **spec:** §IV F-L02 tick 20 |
| Tone | Pricing = choice; trust = safety — temperature drops |

**Failure mode:** Trust strip same visual weight as pricing — feels like another sales beat.

### 08 → 09 (`faq-cta-breath`)

| Phase | Action |
|-------|--------|
| Last FAQ closes | 200ms `data-exit-breath` on `#faq` — **spec:** §IV F-L06 tick 19 |
| Scene 09 enter | CTA band mask wipe up (shipped) |
| Warmth | Background returns from Scene 07 cool to accent band |

**Failure mode:** FAQ accordion immediately stacks into CTA with no pause — feels rushed.

---

## II.E Experience QA gate

### Scenes 01–03 (shippable gate)

| # | Test | Pass when |
|---|------|-----------|
| Q1 | LCP | H1 paints <2.5s 4G; intro doesn't block |
| Q2 | Reduced motion | Same story beats; no pin/jitter/tilt |
| Q3 | Hero pin | Desktop scrub 0→100% without jank; CTAs reachable |
| Q4 | Control arc | Scene 03: user reads balances without reading all copy |
| Q5 | No template tells | No fade-in section reveals anywhere in 01–03 |
| Q6 | UPI discipline | Tease only in Scene 03; no full ring before Scene 09 |
| Q7 | Mobile | Hero shorter pin; how-it-works without pin; story intact |

### Scenes 04–09 (DRAFT gate — pending storyboard)

| # | Test | Pass when |
|---|------|-----------|
| Q8 | Toolkit unfold | Scene 04: cards peel from fracture — not fade grid |
| Q9 | Compare resolve | Scene 05: QA recall #3 — rows snap; no scale pop checks |
| Q10 | Free-first pricing | Scene 06: free tier visually primary; Pro optional lift only |
| Q11 | Trust environment | Scene 07: cool stable tone — not emoji badge bounce |
| Q12 | FAQ clarity | Scene 08: accordion minimal; exit beat before CTA |
| Q13 | UPI payoff | Scene 09: full ring burst + settled balance; Scene 03 tease earned |
| Q14 | Delight budget | ≤1 accent pulse per chapter; install pulse = QA #4 only |

---

## II.B Sitewide interaction catalogue

Global rules — every interactive element inherits unless scene overrides.

| Element | Hover | Focus | Pressed | Drag/Tilt | Idle | Why |
|---------|-------|-------|---------|-----------|------|-----|
| **Primary CTA** | magnetic ≤6px | 2px accent ring | scale 0.98 100ms | — | — | Commitment |
| **Ghost CTA** | underline L→R | ring | opacity 0.9 | — | — | Secondary path |
| **Nav links** | underline | ring | — | — | — | Orientation |
| **Cards (feature)** | border accent trail | ring if focusable | — | tilt ≤2° desktop | — | Depth hint |
| **Accordion** | question brightens | ring on trigger | — | — | — | Disclosure |
| **Inputs** | border accent 35% | ring | — | — | — | Form clarity |
| **Phone mock** | tilt ±6° | — | — | scroll orbit | float 6s | Product tangibility |
| **Comparison row** | bg soft fill | — | — | — | — | Scan aid |
| **Trust icon** | stroke brighten | — | stamp on enter | — | — | Authority |
| **404 digits** | — | — | — | drift ±12px | sine 4s | Disorientation |
| **Loaders** | — | — | — | — | stroke-dash loop | Patience |

**Keyboard:** all catalogue items tabbable; Escape closes drawers/modals.  
**Touch:** 44px min; no hover-only information.  
**Reduced motion:** pressed scale only; no magnetic/tilt/drift.

---

## II.C Master scroll choreography (full film)

Scroll % is approximate desktop journey. Pins consume vertical space.

```
[0%]     GLOBAL intro mask (optional, once)
[0–18%]  SCENE 01+02  F-L01 hero pin — arrival → chaos → accent path (TL-Hero-Extended)
[18%]    UNPIN → path becomes expense wire
[18–28%] SCENE 03     F-L08 how — pin; 3-step graph scrub (TL-Split-Scrub)
[28–38%] SCENE 04     F-L03 features — toolkit unfold from fracture line  [storyboard pending]
[38–48%] SCENE 05     F-L04 compare — ledger scan                       [pending]
[48–56%] SCENE 06     F-L05 pricing — depth lift                        [pending]
[56–62%] SCENE 07     F-L02 trust — stamp + cool horizon                [pending]
[62–75%] SCENE 08     F-L06 FAQ — unfold objections                    [pending]
[75–88%] SCENE 09     F-L07 CTA — UPI pulse → install                  [pending]
[88%+]   Footer epilogue — static trust, legal
```

### Scene transition matrix

| From → To | Visual bridge | Camera | Duration feel |
|-----------|---------------|--------|---------------|
| Intro → 01 | Wordmark stroke-draw → circle mask → H1 | Push through | 0.8s — §IV tick 24 |
| 01 → 02 | IOU bleed @ 35% scrub | Same pin | continuous |
| 02 → 03 | Path → input wire | Dolly down | 0.3vh |
| 03 → 04 | Graph line fractures → 6 card edges | Pull back | 0.2vh |
| 04 → 05 | Cards flatten to table rows | Level | scroll |
| 05 → 06 | Scan line exits → price cards rise | Slow | scroll |
| 06 → 07 | Warmth cools; locks close | Stable | scroll |
| 07 → 08 | Trust icons fade; questions emerge | Static | scroll |
| 08 → 09 | Last answer collapses; CTA band wipe up | Push in | 0.6s |

**Emotion through-line:** curiosity → loss of control → **grip returns** → command → confidence → fairness → relief → clarity → **ownership**

---

## III. Director changelog

| Tick | Date | Work |
|------|------|------|
| 0 | 2026-07-27 | Motion Director charter; language behaviours; Scene 01–02 cinematic specs |
| 1 | 2026-07-27 | Storyboard sync: 01+02 merged hero pin; Scene 03 full spec; `TL-Hero-Extended` timeline |
| 2 | 2026-07-27 | Scene 04 blocked (storyboard pending); Scene 03 polish CSS; §II.B sitewide interaction catalogue |
| 3 | 2026-07-27 | §II.C master scroll choreography + scene transition matrix (04–09 intent only) |
| 4 | 2026-07-27 | Scene 03 synced to creative control arc; UPI tease not burst; Scene 04 DRAFT intent |
| 5 | 2026-07-27 | Scene 09 DRAFT (full UPI settle); §II.E QA gate Scenes 01–03; emotion through-line → control |
| 6 | 2026-07-27 | §II.F fidelity matrix; Scene 09 partial-ship notes from `FinalCta` |
| 7 | 2026-07-27 | Scene 04 `TL-Toolkit-Unfold` DRAFT; §II.G physics/lighting; developer priority stack |
| 8 | 2026-07-27 | Scene 04/05 DRAFTs from creative briefs; synced F-L03 partial ship; `TL-Compare-Resolve` |
| 9 | 2026-07-27 | Scene 06 `TL-Pricing-Fair` + Scene 07 `TL-Trust-Vault` DRAFTs; §II.F fidelity sync |
| 10 | 2026-07-27 | Scene 08 `TL-FAQ-Clarity` DRAFT; Scene 09 `TL-Install-Door` timeline; Scene 05 ↔ Design tick 15 sync |
| 11 | 2026-07-27 | §II.H memorable moments map; §II.E expanded Q8–Q14; Scene 09 ↔ Design tick 16 DOM contract |
| 12 | 2026-07-27 | §II.I handoff contracts (03→04 fracture, 08→09 breath); Scene 03 ↔ Design tick 17 B4 cross-ref |
| 13 | 2026-07-27 | §II.I 04→05 `cards-to-rows` handoff; Scene 04 ↔ Design tick 18 fracture; P3 dep chain |
| 14 | 2026-07-27 | §II.J build-ready index; Scene 08/09 ↔ Design tick 19 `data-exit-breath`; P6 priority |
| 15 | 2026-07-27 | §II.I 06→07 `warm-to-vault`; Scene 07 ↔ Design tick 20 `data-vault-cool`; §II.J + P7 |
| 16 | 2026-07-27 | Scene 05/06 ↔ Design tick 21 (`data-exit-align`, `free-anchor`); §II.J expanded; §II.F sync |
| 17 | 2026-07-27 | §II.I 05→06 `verdict-to-fair`; Scene 05/06 ↔ Design tick 22; §II.J + §II.F sync |
| 18 | 2026-07-27 | §II.K recommended build sequence; B3 ↔ Design tick 23 `formSwap` spec |
| 19 | 2026-07-27 | §II.I Intro→01 `stroke-to-arrival`; Scene 01 ↔ Design tick 24 B2; §II.J/P2 sync |
| 20 | 2026-07-27 | §II.L doc milestone; §II.I 02→03 `path-to-wire`; B1 ↔ Design tick 25 package |
| 21 | 2026-07-27 | §II.L ↔ Design tick 26 §4.2 map; Scene 02 chaos asset brief cross-ref; maintenance mode |
| 22 | 2026-07-27 | Maintenance — Design tick 27 no drift; storyboard 04–09 still Pending; §II.F unchanged |
| 23 | 2026-07-27 | Maintenance — Design tick 28 no drift; §II.L hold; no storyboard movement |
| 24 | 2026-07-27 | Maintenance — Design tick 29 no drift; §II.F + storyboard unchanged |
| 25 | 2026-07-27 | Maintenance — Design tick 30 milestone (30 ticks); no drift; §II.L hold |
| 26 | 2026-07-27 | Maintenance — Design tick 31 no drift; storyboard 04–09 Pending |
| 27 | 2026-07-27 | Maintenance — Design tick 32 no drift; §II.L hold |
| 28 | 2026-07-27 | Maintenance — Design tick 33 no drift; storyboard 04–09 Pending |
| 29 | 2026-07-27 | Maintenance — Design tick 34 no drift; §II.L hold |
| 30 | 2026-07-27 | Milestone (30 ticks) — Design tick 35 no drift; storyboard 04–09 Pending; §II.L hold |
| 31 | 2026-07-27 | Maintenance — Design tick 36 no drift; §II.L hold |
| 32 | 2026-07-27 | Maintenance — Design tick 37 no drift; storyboard 04–09 Pending |
| 33 | 2026-07-27 | Maintenance — Design tick 38 no drift; §II.L hold |
| 34 | 2026-07-27 | Maintenance — Design tick 39 no drift; storyboard 04–09 Pending |
| 35 | 2026-07-27 | Maintenance — Design tick 40 milestone (40 ticks); no drift; §II.L hold |
| 36 | 2026-07-27 | Maintenance — Design tick 41 no drift; storyboard 04–09 Pending |
| 37 | 2026-07-27 | Maintenance — Design tick 42 no drift; §II.L hold |
| 38 | 2026-07-27 | Maintenance — Design tick 43 no drift; storyboard 04–09 Pending |
| 39 | 2026-07-27 | Maintenance — Design tick 44 no drift; §II.L hold |
| 40 | 2026-07-27 | Maintenance — Design tick 45 no drift; storyboard 04–09 Pending |
| 41 | 2026-07-27 | Maintenance — Design tick 46 no drift; §II.L hold |
| 42 | 2026-07-27 | Maintenance — Design tick 47 no drift; storyboard 04–09 Pending |
| 43 | 2026-07-27 | Maintenance — Design tick 48 no drift; §II.L hold |
| 44 | 2026-07-27 | Maintenance — Design tick 49 no drift; storyboard 04–09 Pending |
| 45 | 2026-07-27 | Maintenance — Design tick 50 milestone (50 ticks); no drift; §II.L hold |
| 46 | 2026-07-27 | Maintenance — Design tick 51 no drift; storyboard 04–09 Pending |
| 47 | 2026-07-27 | Maintenance — Design tick 52 no drift; §II.L hold |
| 48 | 2026-07-27 | Maintenance — Design tick 53 no drift; storyboard 04–09 Pending |
| 49 | 2026-07-27 | Maintenance — Design tick 54 no drift; §II.L hold |
| 50 | 2026-07-27 | Milestone (50 ticks) — Design tick 55 no drift; storyboard 04–09 Pending; §II.L hold |
| 51 | 2026-07-27 | Maintenance — Design tick 56 no drift; storyboard 04–09 Pending |
| 52 | 2026-07-27 | Maintenance — Design tick 57 no drift; §II.L hold |
| 53 | 2026-07-27 | Maintenance — Design tick 58 no drift; storyboard 04–09 Pending |
| 54 | 2026-07-27 | Maintenance — Design tick 59 no drift; §II.L hold |
| 55 | 2026-07-27 | Maintenance — Design tick 60 milestone (60 ticks); no drift; §II.L hold |
| 56 | 2026-07-27 | Maintenance — Design tick 61 no drift; storyboard 04–09 Pending |
| 57 | 2026-07-27 | Maintenance — Design tick 62 no drift; §II.L hold |

---

## IV. Developer implementation reference (legacy)

> Feature-level specs below remain valid for shipped code. Cinematic scenes supersede where they conflict.

**Owner (legacy):** Motion Design Agent  

---

## 0. Research synthesis — why motion exists

Patterns studied (mechanism only — **never copy visuals**): CRED, Razorpay, Inngest, Sensiq, Stripe, Apple, Nothing, Linear, Vercel, Awwwards, CSS Design Awards.

| Site class | Why they animate | Mechanism (abstract) | Splitr takeaway |
|------------|------------------|----------------------|-----------------|
| **Stripe** | Prove infrastructure is alive; demystify invisible money flow | Gradient mesh depth, scroll-scrubbed product demos, typographic rhythm tied to section pins | Money **flows** — animate paths, not boxes appearing |
| **Linear** | Signal precision + speed; reduce perceived latency | Sparse layout, cursor-reactive glow, micro spring on interactive affordances | Restraint; motion only on **intent** (hover, focus, scroll chapter breaks) |
| **CRED** | Reward attention; emotional premium for fintech | Chapter scroll, bold type masks, haptic-feeling transitions | **Chapter** structure — each scroll beat = one idea |
| **Razorpay** | Trust at scale; India-native confidence | Product UI in situ, marquee trust signals, dashboard depth | Show **real product surfaces** in 3D/parallax, not abstract blobs |
| **Apple** | Product as hero; camera orbits object | Pin + scrub rotates device; specular highlights follow scroll | **Orbit** the phone mock on hero scrub — user "holds" the app |
| **Nothing** | Brand glyph as character; dot-matrix personality | Glyph morphs, grid reveals, monochrome + one accent pulse | Accent `#18c595` as **pulse** along split paths |
| **Vercel** | Speed + craft; developer trust | Shader grids, edge glow, deploy timeline | Grid **snap** when sections lock — precision metaphor |
| **Inngest** | Explain async orchestration | Step timeline scrubs with scroll; nodes light in sequence | **Step graph** for How it works — nodes activate in order |
| **Sensiq / award sites** | Memorable art direction | WebGL scenes, SVG morph, clip-path masks, physics | Prefer **mask + morph** over opacity fades |
| **Awwwards / CSSDA** | Portfolio wow — filter for **purpose** | Scroll hijack only when narrative earns it | If animation doesn't teach product → cut it |

### Anti-patterns (default ban)

| Pattern | Why banned | Allowed exception |
|---------|------------|-------------------|
| Fade in | Invisible, forgettable | Opacity-only for cross-fades **between two states** (route, modal overlay) — max 200ms |
| Slide up | Template SaaS noise | Vertical **mask reveal** with content already in final position |
| Scale pop | Cheap emphasis | Scale only on **press** (0.98) per §11.5 — not entrance |
| Stagger fade grid | Decoration | Stagger **stroke-draw** or **path-trim** on icons |

---

## 1. Splitr motion language

### 1.1 Narrative arc (landing)

One scroll story: **Chaos → Split → Clarity → Settle**

```
[Hero]        Shared bill arrives (tension)
[How]         Split engine runs (mechanism)
[Features]    Full toolkit expands (capability)
[Compare]     Splitr wins the ledger (differentiation)
[Pricing]     Pro unlocks depth (monetization)
[Trust]       Locks close (safety)
[FAQ]         Objections dissolve (transparency)
[CTA]         Pulse to UPI settle (action)
```

### 1.2 Emotion palette

| Token | Emotion | Motion expression |
|-------|---------|-------------------|
| `motion.tension` | Mild anxiety of shared money | Slight jitter, overlapping layers, desaturated |
| `motion.clarity` | Relief of known balances | Lines snap to grid, type unmasks |
| `motion.flow` | Money moving correctly | Bezier paths, particle trails along UPI axis |
| `motion.trust` | Solid, bank-grade | Slow parallax, stable horizon, no bounce |
| `motion.delight` | NeoPOP energy | Accent pulse, spring on settle — **once per chapter max** |

### 1.3 Timing tokens

| Token | Duration | Easing | Use |
|-------|----------|--------|-----|
| `motion.micro` | 100–150ms | `cubic-bezier(0.4, 0, 0.2, 1)` | Press, toggle |
| `motion.ui` | 200–300ms | `cubic-bezier(0.16, 1, 0.3, 1)` | Nav, drawer, accordion |
| `motion.chapter` | 400–800ms scrub | linear (scroll-linked) | Pinned sections |
| `motion.ambient` | 12–30s loop | linear / sine | Mesh drift, idle glow — **GPU only** |

### 1.4 Spatial tokens

| Token | Value |
|-------|-------|
| `motion.depth.near` | translateZ 40px equivalent (parallax 0.15) |
| `motion.depth.mid` | parallax 0.08 |
| `motion.depth.far` | parallax 0.03 |
| `motion.camera.hero` | FOV 45°, orbit ±12° Y on full hero scrub |
| `motion.camera.product` | orthographic feel — no perspective warp on UI cards |

### 1.5 Tech stack (add at implementation)

| Package | Role | Load strategy |
|---------|------|---------------|
| `gsap` + `ScrollTrigger` | Pin, scrub, typography masks | Sync import on marketing routes |
| `@react-three/fiber` + `three` + `@react-three/drei` | Hero ledger scene, UPI pulse | `React.lazy` + IntersectionObserver; static PNG fallback |
| `lenis` (optional) | Smooth scroll desktop | Disable if `prefers-reduced-motion` |

**ponytail:** No motion lib in `package.json` yet — add only when Developer implements first pinned section.

### 1.6 Global reduced motion

```css
@media (prefers-reduced-motion: reduce) {
  /* All scroll scrub → instant final state */
  /* All ambient loops → static poster frame */
  /* All parallax → 0 */
  /* Accordion/drawer → instant toggle */
}
```

Hook: `useReducedMotion()` returns boolean; GSAP timelines call `.progress(1)` on mount when true.

### 1.7 Performance budgets (sitewide)

| Metric | Budget |
|--------|--------|
| LCP element | H1 text — **no WebGL above fold blocking paint** |
| TBT from motion JS | < 50ms after lazy R3F chunk |
| Scroll jank | 60fps desktop; 30fps floor mobile — degrade particles first |
| GPU layers | ≤ 8 promoted layers per viewport |
| R3F draw calls | ≤ 24 hero scene |

---

## 2. Feature motion specs

> Each block uses the Motion Design Agent template. Cross-ref product: `react-website-development-details.md` §7 + §12.

---

### GLOBAL — Initial page load & route transition

| Field | Spec |
|-------|------|
| **Motion Goal** | Brand recognition before content; no spinner |
| **Emotion** | `motion.trust` — confident, brief |
| **Narrative** | Wordmark draws itself → world opens |
| **User Attention Goal** | Eyes to logo stroke → H1 |
| **Animation Density** | Low (1 beat) |
| **Scene Breakdown** | (1) Full viewport `#0d0d0d` (2) SVG wordmark stroke-dashoffset 0→100% (3) Clip-path circle expand from centre reveals hero |
| **Timeline** | 0–0.8s stroke draw; 0.6–1.2s mask expand; hero scene fades **via mask only** |
| **Camera Movement** | None |
| **Three.js Objects** | None — SVG + CSS `clip-path` |
| **GSAP Timeline** | `tl.to(wordmark, { strokeDashoffset: 0, duration: 0.8 })` → `tl.to(reveal, { clipPath: 'circle(150% at 50% 50%)', duration: 0.6 }, '-=0.2')` |
| **Trigger** | `window.load` once per session; `sessionStorage.splitr_intro_seen` skips on repeat visit |
| **Scroll Behaviour** | N/A |
| **Entry** | Mask expand from centre |
| **Exit** | Hand off to hero idle — no fade to black |
| **Hover** | N/A |
| **Idle Animation** | None post-handoff |
| **Mouse Behaviour** | N/A |
| **Touch Behaviour** | Same; skip if `intro_seen` |
| **Reduced Motion Alternative** | Instant hero; no stroke animation |
| **Performance Budget** | < 1.2s total; SVG only |
| **GPU Budget** | clip-path on one layer |
| **Implementation Notes** | `IntroOverlay` component; cross-ref Director §II.K step 3; Scene 01 = F-L01 + GLOBAL |

#### GLOBAL intro — Shipped implementation + B2 stroke-draw (tick 24)

| Item | Status |
|------|--------|
| Session skip | Shipped — `sessionStorage.splitr_intro_seen` |
| Pathname guard | Shipped — `/` only; route change dismisses |
| Circle reveal | Shipped — `clipPath` expand 0.6s |
| Reduced motion | Shipped — skips overlay entirely |
| Wordmark | **Gap** — `opacity` + `scale` tween (B2); banned per §I |

**B2 drop-in (`IntroOverlay.tsx`):** replace `<p className={styles.wordmark}>` with SVG stroke text (v1 — display font, not Albra until M2 license):

```tsx
<svg className={styles.wordmarkSvg} viewBox="0 0 160 40" aria-hidden="true">
  <text
    x="0"
    y="32"
    className={styles.wordmarkStroke}
    fill="none"
    stroke="currentColor"
    strokeWidth="2"
  >
    Splitr
  </text>
</svg>
```

```ts
const text = wordmark.querySelector('text')
const length = text?.getComputedTextLength?.() ?? 120
gsap.set(text, { strokeDasharray: length, strokeDashoffset: length })
tl.to(text, { strokeDashoffset: 0, duration: 0.8 })
  .fromTo(reveal, { clipPath: 'circle(0% at 50% 50%)' }, { clipPath: 'circle(150% at 50% 50%)', duration: 0.6 }, '-=0.2')
```

Remove `opacity` + `scale` on wordmark. **M2:** swap `<path d="...">` when Albra licensed.

**Effort:** ~1h (ship blocker B2).

---

### F-C08 — Global navigation

| Field | Spec |
|-------|------|
| **Motion Goal** | Orient user in scroll journey; reinforce install CTA |
| **Emotion** | `motion.trust` |
| **Narrative** | Chrome solidifies as user commits scroll |
| **User Attention Goal** | Logo anchor; CTA persistent |
| **Animation Density** | Micro |
| **Scene Breakdown** | Transparent bar → frosted solid after 48px scroll |
| **Timeline** | 200ms bg opacity + backdrop-filter |
| **Camera Movement** | None |
| **Three.js Objects** | None |
| **GSAP Timeline** | CSS transition preferred; ScrollTrigger toggles `.nav--scrolled` class |
| **Trigger** | `scrollY > 48` |
| **Scroll Behaviour** | Class toggle — no scrub |
| **Entry** | N/A (always visible) |
| **Exit** | N/A |
| **Hover** | Link underline grows L→R 150ms; Install btn brightness +4% |
| **Idle Animation** | None |
| **Mouse Behaviour** | N/A |
| **Touch Behaviour** | Drawer: `translateX(100%→0)` 300ms spring |
| **Reduced Motion Alternative** | Instant bg swap; instant drawer |
| **Performance Budget** | `backdrop-filter` only when scrolled — avoid on mobile low-end |
| **GPU Budget** | 1 blurred layer |
| **Implementation Notes** | Match §12.2 F-C08. Focus trap in drawer unchanged. |

---

### F-L01 — Hero (`#hero`)

| Field | Spec |
|-------|------|
| **Motion Goal** | Hook: shared money is messy; Splitr brings order — **show the app orbiting in 3D** |
| **Emotion** | `motion.tension` → `motion.clarity` |
| **Narrative** | Bill card floats in chaos → splits into friend nodes → UPI pulse settles |
| **User Attention Goal** | H1 read first (LCP), then visual proves product is real |
| **Animation Density** | High desktop / Low mobile |
| **Scene Breakdown** | **Desktop:** Pin ~2.0vh (`+=200%`). Scenes 01+02 merged — see §II `TL-Hero-Extended`. Layers: mesh, phone poster, split paths, `scene02-chaos.svg` IOU overlay, accent path. **Mobile:** pin ~1.6vh |
| **Timeline** | 0–35% arrival orbit; 35–85% chaos+jitter; 85% pause; 90–100% accent path trim + unpin → `#how` |
| **Camera Movement** | Orbit Y: -12° → +8°; dolly Z: 4.2 → 3.6; slight roll 0 → 2° for NeoPOP tilt |
| **Three.js Objects** | `PhoneFrame` (box + rounded mask), `ScreenQuad` (app screenshot), `BillParticle` ×4 (thin boxes w/ ₹ texture), `UpiPulse` (torus ring, accent emissive), `AmbientLight` + `DirectionalLight` |
| **GSAP Timeline** | `ScrollTrigger.create({ pin: true, scrub: 1, end: '+=120%' })` drives `camera.position` + `pathDashoffset` + `particle.position` via unified `progress` uniform |
| **Trigger** | Page load idle + scroll into pin zone |
| **Scroll Behaviour** | Pin + scrub desktop ≥1024px; mobile: no pin |
| **Entry** | H1 **mask reveal** L→R `clip-path: inset(0 100% 0 0)` → `inset(0 0 0 0)` 600ms — **not** translateY |
| **Exit** | Pin releases → parallax lag on phone 0.05 as How section rises |
| **Hover** | Primary CTA: magnetic pull 4px max toward cursor (desktop only) |
| **Idle Animation** | Pre-scroll: mesh shader slow noise 20s; phone float `sin(t)*0.02` |
| **Mouse Behaviour** | Parallax tilt phone ±3° toward cursor (desktop, inside hero visual) |
| **Touch Behaviour** | No tilt; tap CTA only |
| **Reduced Motion Alternative** | Static poster image `hero-poster.webp`; H1 visible immediately; no pin |
| **Performance Budget** | R3F lazy after FCP; fallback image < 80KB |
| **GPU Budget** | 1 canvas ≤ 360×360 CSS px; DPR cap `min(devicePixelRatio, 1.5)` |
| **Implementation Notes** | LCP = H1. Canvas `pointer-events: none`. Screenshot from real app — update per release. Ref §12 F-L01 — replaces fade+translateY spec |

#### F-L01 — GSAP implementation reference (P1)

Hook: `useHeroScrollMotion(heroRef, visualRef)` in `apps/web/src/hooks/`. Guard: `useReducedMotion()` + `matchMedia('(min-width: 1024px)')`.

```ts
// ponytail: CSS poster + parallax first; lazy R3F behind flag MOTION_HERO_3D
const gsap = ensureGsap()
const mm = gsap.matchMedia()

mm.add('(min-width: 1024px)', () => {
  const tl = gsap.timeline({
    scrollTrigger: {
      trigger: heroRef.current,
      start: 'top top',
      end: '+=200%', // mobile: '+=160%'
      pin: true,
      scrub: 1,
      invalidateOnRefresh: true,
    },
  })

  // 0–35% Scene 01: phone orbit + split paths
  tl.to(visualRef.current, { rotateY: 8, ease: 'none' }, 0)
  // 35–85% Scene 02: chaos opacity + jitter (CSS class toggle on progress)
  tl.to('.chaos-layer', { opacity: 1, ease: 'none' }, 0.35)
  // 90–100%: accent path trim; chaos dims
  tl.to('[data-motion-accent-path]', { strokeDashoffset: 0, ease: 'none' }, 0.9)

  return () => tl.scrollTrigger?.kill()
})
```

**M4 resolved (tick 2):** v1 = CSS poster card + SVG paths + scroll scrub. R3F phone deferred behind `MOTION_HERO_3D` env flag.

**Code drift (fix):** `IntroOverlay.tsx` uses `scale` + `opacity` on wordmark — replace with SVG stroke-dashoffset per GLOBAL intro spec.

**Shipped (P0 + partial P1):** `useReducedMotion`, `IntroOverlay`, `useHeroMotion` (H1 mask), `ensureGsap` + ScrollTrigger, `HeroVisual` + `/hero-poster.png`, `useHeroVisualTilt` (±6°), `useMagneticHover` on Install CTA, phone float + mesh drift CSS.

#### F-L01 — `useHeroScrollMotion` DOM contract (P1 — not yet wired)

Add to `HeroVisual.tsx` inside `.wrap`:

```tsx
<svg className={styles.splitGraph} viewBox="0 0 200 200" aria-hidden="true">
  <path data-motion-split-path d="M100,100 L40,60" className={styles.splitPath} />
  <path data-motion-split-path d="M100,100 L160,60" className={styles.splitPath} />
  <path data-motion-split-path d="M100,100 L100,160" className={styles.splitPath} />
  <circle data-motion-node className={styles.billNode} cx="100" cy="100" r="8" />
  <circle data-motion-node className={styles.billNode} cx="40" cy="60" r="6" />
  <circle data-motion-node className={styles.billNode} cx="160" cy="60" r="6" />
  <circle data-motion-node className={styles.billNode} cx="100" cy="160" r="6" />
  <circle data-motion-upi-ring className={styles.upiRing} cx="100" cy="100" r="72" />
</svg>
<svg className={styles.chaosLayer} viewBox="0 0 200 200" aria-hidden="true" data-motion-chaos>
  {/* scene02-chaos.svg — IOU paths, ₹ labels, scenario ghosts */}
  <path data-motion-accent-path className={styles.accentPath} d="M20,180 Q100,40 180,180" />
</svg>
```

**Hook signature:** `useHeroScrollMotion(sectionRef, visualRef)` — pin `#hero` section, scrub visual per §F-L01 GSAP ref. Pass `sectionRef` from `HomePage` (`ref` on `.hero`).

**Conflict note:** Scroll scrub `rotateY` on visual fights `useHeroVisualTilt` mouse tilt — disable tilt while `ScrollTrigger.isScrolling` or when pin active.

**M1 partial:** `hero-poster.png` in use — replace with Groups overview screenshot when asset ready; keep dimensions 280×606.

#### F-L01 — Drop-in hook `useHeroScrollMotion.ts` (tick 6)

Create `apps/web/src/hooks/motion/useHeroScrollMotion.ts` — use async pattern:

```ts
void createMotionContext().then((ctx) => {
  const { gsap } = ctx
  // ... ScrollTrigger timeline; see TL-Hero-Extended scrub phases
  ctx.track(tl.scrollTrigger!)
})
```

Or wrap in `useMotionEffect` like `useHowItWorksMotion`.

**Wire in `HomePage.tsx`:** `sectionRef` on `<section className={styles.hero}>`, pass `visualRef` from `HeroVisual` via `forwardRef`. **`useHeroVisualTilt`:** skip when `visual.dataset.scrollPinned === 'true'`.

**CSS additions (`HeroVisual.module.css`):** `.splitGraph { position:absolute; inset:0; z-index:2; pointer-events:none }` `.splitPath { stroke: var(--color-accent); fill:none; stroke-width:2 }` `.upiRing { fill:none; stroke:var(--color-accent); stroke-width:1; opacity:0 }`

#### F-L01 — B1 implementation package (tick 25)

**Ship blocker B1** — §II.K step 1; QA recall **#1**. File does not exist yet.

| Item | Status |
|------|--------|
| H1 mask | Shipped — `useHeroMotion` |
| Poster + mesh + float | Shipped — `HeroVisual.tsx` |
| Mouse tilt | Shipped — `useHeroVisualTilt` ±6° |
| Magnetic CTA | Shipped — `useMagneticHover(4)` |
| Extended pin + scrub | **Gap** — no `useHeroScrollMotion.ts` |
| Split SVG + chaos layer | **Gap** — `HeroVisual` poster only |
| `scene02-chaos.svg` | **Gap** — asset + `data-motion-chaos` |
| Tilt vs pin | **Gap** — need `data-scroll-pinned` guard |

**Create** `apps/web/src/hooks/motion/useHeroScrollMotion.ts`:

```ts
export function useHeroScrollMotion(
  sectionRef: RefObject<HTMLElement | null>,
  visualRef: RefObject<HTMLElement | null>,
): void {
  const reduced = useReducedMotion()
  useMotionEffect(reduced, (ctx) => {
    const section = sectionRef.current
    const visual = visualRef.current
    if (!section || !visual || !isDesktopMotion()) return
    const { gsap } = ctx
    const chaos = visual.querySelector<HTMLElement>('[data-motion-chaos]')
    const accent = visual.querySelector<SVGPathElement>('[data-motion-accent-path]')
    const paths = visual.querySelectorAll<SVGPathElement>('[data-motion-split-path]')

    paths.forEach((p) => {
      const len = p.getTotalLength()
      gsap.set(p, { strokeDasharray: len, strokeDashoffset: len })
    })
    if (accent) {
      const len = accent.getTotalLength()
      gsap.set(accent, { strokeDasharray: len, strokeDashoffset: len })
    }

    ctx.track(
      ctx.ScrollTrigger.create({
        trigger: section,
        start: 'top top',
        end: '+=200%',
        pin: true,
        scrub: 1,
        onToggle: (self) => {
          visual.dataset.scrollPinned = self.isActive ? 'true' : 'false'
        },
        onUpdate: (self) => {
          const p = self.progress
          // 0–35% Scene 01
          gsap.set(visual, { rotateY: p < 0.35 ? -12 + (p / 0.35) * 20 : 8 })
          // 35–85% Scene 02
          if (chaos) chaos.style.opacity = p >= 0.35 && p < 0.9 ? '1' : '0'
          // 90–100% accent trim
          if (accent && p > 0.9) {
            const len = accent.getTotalLength()
            const local = (p - 0.9) / 0.1
            gsap.set(accent, { strokeDashoffset: len * (1 - local) })
          }
        },
      }),
    )
  }, [sectionRef, visualRef])
}
```

**Wire `HomePage.tsx`:** `heroRef` on `<section>`, `forwardRef` on `HeroVisual`. **`useHeroVisualTilt`:** return early if `visual.dataset.scrollPinned === 'true'`.

**Assets:** add `apps/web/public/scene02-chaos.svg` — see asset brief below. **Effort:** ~4h.

**02→03 path alignment (§II.I):** accent path terminus must visually meet `#how` first connector. Target: path end ≈ centre-bottom of hero visual → `#how` graph `y=24` on scroll unpin.

#### `scene02-chaos.svg` asset brief (tick 26)

Inline or external SVG inside `[data-motion-chaos]`. Monochrome + accent only.

| Layer | Content | Motion (B1 scrub 35–85%) |
|-------|---------|--------------------------|
| L1 | 3–5 IOU Bézier curves from phone edge | `stroke-dashoffset` optional; opacity 1 |
| L2 | Tabular ₹ amounts (`₹240`, `₹1,850`) | `phys.jitter` CSS 0.3px — off reduced-motion |
| L3 | 1–2 scenario ghosts (plate, suitcase) | opacity 0.4; desktop only |
| L4 | `[data-motion-accent-path]` | hidden until scrub 90%; path-trim 90–100% |

```svg
<!-- Minimal inline stub — expand art; viewBox="0 0 200 200" -->
<g data-motion-chaos-layer>
  <path d="M120,80 Q160,40 180,70" stroke="currentColor" fill="none" opacity="0.5"/>
  <text x="150" y="65" font-size="10" fill="currentColor">₹240</text>
  <path data-motion-accent-path d="M30,170 Q100,50 170,170"
    stroke="#18c595" fill="none" stroke-width="2"/>
</g>
```

**Acceptance:** QA #1 — user feels numbers won't align at scrub 50%.

---

### F-L08 — How it works (`#how`)

| Field | Spec |
|-------|------|
| **Motion Goal** | Teach 3-step mechanism without reading every word |
| **Emotion** | `motion.flow` |
| **Narrative** | Inngest-style step graph lights up as user scrolls |
| **User Attention Goal** | Active step highlighted; inactive dimmed |
| **Animation Density** | Medium desktop / static mobile |
| **Scene Breakdown** | Pinned 100vh. Centre: SVG node graph (Create → Split → Settle). Left/right: step copy panels cross-fade via **horizontal mask** not opacity-only |
| **Timeline** | 0–0.33 Step 1 node emissive pulse + copy mask reveal; 0.33–0.66 Step 2; 0.66–1.0 Step 3 + UPI icon particle burst |
| **Camera Movement** | 2.5D — graph scales 0.92 → 1.0 subtle |
| **Three.js Objects** | Optional: `UPIBurst` particles on step 3 only — can be CSS `@keyframes` instead (ponytail: CSS first) |
| **GSAP Timeline** | `ScrollTrigger` pin; `tl.to(activeNode, { filter: 'drop-shadow(...)' })` per chapter |
| **Trigger** | Section top hits 20% viewport |
| **Scroll Behaviour** | Pin scrub desktop ≥1024px |
| **Entry** | Connector lines draw-on via `stroke-dashoffset` |
| **Exit** | Graph collapses to single line → feeds Feature grid |
| **Hover** | Step nodes: glow on hover desktop (non-scrub idle) |
| **Idle Animation** | Dormant pulse on current step node 2s loop |
| **Mouse Behaviour** | N/A |
| **Touch Behaviour** | Vertical stack; steps visible without scroll magic |
| **Reduced Motion Alternative** | All 3 steps visible; numbered list only |
| **Performance Budget** | SVG + GSAP only — no WebGL required |
| **GPU Budget** | SVG filters ≤ 2 |
| **Implementation Notes** | Keep semantic `<ol>` in DOM; graph is decorative `aria-hidden` duplicate |

#### F-L08 — Shipped implementation (tick 3 sync)

**File:** `apps/web/src/hooks/motion/useLandingScrollMotion.ts` → `useHowItWorksMotion`

| Spec field | Code reality |
|------------|--------------|
| Pin + scrub desktop | `pin: true`, `scrub: 1`, `end: '+=100%'`, `start: 'top 20%'` |
| Connector draw | `strokeDashoffset` per segment on `onUpdate` |
| Active step | `data-active` on `[data-motion-step]` + `[data-motion-node]` |
| Mobile | One-shot connector draw @ `top 70%`; all steps visible |
| Missing | Horizontal mask on copy panels; balance snap; UPI **tease** on step 3 (full settle = Scene 09) |

**Polish backlog (B4):** Copy mask; tabular balance snap; `@keyframes upiTease` when `progress > 0.7` — per §II Scene 03.

#### F-L08 — B4 drop-in spec (tick 17)

**QA recall #2** — grid snap is minimum ship moment per §II.H.

**DOM additions (`HowItWorks.tsx`):**

```tsx
<li className={styles.step} data-motion-step>
  ...
  <p className={styles.stepBody}>{step.body}</p>  {/* mask target */}
</li>
```

Step 3 only — balance grid:

```tsx
<div data-motion="balance-grid" aria-hidden="true">
  <span data-balance>Rahul ₹0</span>
  <span data-balance>Priya ₹0</span>
  ...
</div>
```

**`useHowItWorksMotion` `onUpdate` additions:**

```ts
// after setActiveStep(index)
if (self.progress > 0.7) {
  nodes[2]?.setAttribute('data-tease', 'true')
}
// balance snap once @ progress > 0.85
if (self.progress > 0.85 && !sectionEl.dataset.snapped) {
  sectionEl.dataset.snapped = 'true'
  gsap.from('[data-balance]', { y: 8, opacity: 0, stagger: 0.06, ease: 'back.out(1.3)' })
}
```

**CSS:** copy `maskReveal` + `upiTease` from §II Scene 03 `TL-Split-Polish`. Inactive steps: `opacity: 0.35` → replace with `clip-path` mask on `.stepBody` only.

**Exit fracture (seeds Scene 04):** @ `progress > 0.95`, `gsap.to(graphEl, { scale: 0.85, duration: 0.2 })` — horizontal line hook for `#features`.

---

### F-L03 — Feature grid (`#features`)

| Field | Spec |
|-------|------|
| **Motion Goal** | Expand perception of product breadth — cards **unfold** like ledger tabs |
| **Emotion** | `motion.delight` |
| **Narrative** | Toolkit fans out from centre |
| **User Attention Goal** | Scan grid in Z-pattern |
| **Animation Density** | Medium |
| **Scene Breakdown** | Section enters; 6 cards use 3D `rotateX(12deg)` → `0` with stagger 60ms — pivot top edge |
| **Timeline** | On enter viewport 25%: 0.5s total staggered unfold |
| **Camera Movement** | None — CSS `perspective: 800px` on grid |
| **Three.js Objects** | None |
| **GSAP Timeline** | `ScrollTrigger.batch('.feature-card', { onEnter: unfold })` |
| **Trigger** | Intersection 25% |
| **Scroll Behaviour** | One-shot enter — no pin |
| **Entry** | 3D unfold + icon stroke-draw 400ms |
| **Exit** | N/A |
| **Hover** | Card: border accent trail follows cursor (conic-gradient mask) desktop |
| **Idle Animation** | None |
| **Mouse Behaviour** | Subtle card tilt max 2° toward cursor |
| **Touch Behaviour** | No tilt |
| **Reduced Motion Alternative** | Cards visible; icons static |
| **Performance Budget** | `transform` only |
| **GPU Budget** | 6 layers max |
| **Implementation Notes** | Replaces stagger fade-up in §12; cross-ref Director §II Scene 04 + §II.I fracture handoff |

#### F-L03 — Shipped implementation + fracture handoff (tick 18)

| Item | Status |
|------|--------|
| Card unfold | Shipped — `rotateX(12°→0)` stagger 60ms @ `top 75%` |
| Icons | Shipped — `FeatureIcon` stroke SVGs (interim vs UI crops) |
| Tilt | Shipped — `useFeatureCardTilt` 4° desktop |
| Fracture line | **Gap** — generic unfold; no peel axis per Scene 04 DRAFT |

**Drop-in (`HomePage.tsx` between `<HowItWorks />` and `<FeatureGrid />`):**

```tsx
<div data-motion="fracture-line" className={styles.fractureLine} aria-hidden="true" />
```

**CSS (`HomePage.module.css`):**

```css
.fractureLine {
  height: 2px;
  background: var(--color-accent);
  transform: scaleX(0);
  transform-origin: center;
}
.fractureLine[data-visible='true'] {
  transform: scaleX(1);
  transition: transform 400ms cubic-bezier(0.16, 1, 0.3, 1);
}
```

**Wire-up:**
1. `useHowItWorksMotion` @ `progress > 0.95` → set `fracture-line` `data-visible="true"` (shared ref or `document.querySelector`)
2. `useFeatureGridMotion` — trigger on fracture line not grid; `transformOrigin: 'top center'` on cards already correct; line must sit flush above `#features` grid top

See Director **§II.I** 03→04 contract. Depends on B4 exit fracture in F-L08 tick 17.

---

### F-L04 — Comparison table (`#compare`)

| Field | Spec |
|-------|------|
| **Motion Goal** | Splitr column **wins** the eye — factual, not flashy |
| **Emotion** | `motion.clarity` |
| **Narrative** | Ledger scan left-to-right; Splitr column locks in |
| **User Attention Goal** | Splitr column first on mobile cards |
| **Animation Density** | Low–medium |
| **Scene Breakdown** | Desktop: horizontal **scan line** (accent 2px) sweeps table L→R; cells under line flip checkmark draw. Mobile: cards stack with Splitr card border pulse once |
| **Timeline** | Scan 1.2s on enter; checks draw 150ms each trailing scan |
| **Camera Movement** | None |
| **Three.js Objects** | None |
| **GSAP Timeline** | `tl.to('.scan-line', { x: '100%' })` + check `strokeDashoffset` |
| **Trigger** | Intersection 30% |
| **Scroll Behaviour** | One-shot |
| **Entry** | Scan line — **not** row fade |
| **Exit** | N/A |
| **Hover** | Row highlight bg `--color-accent-fill-soft` 150ms |
| **Idle Animation** | None |
| **Mouse Behaviour** | N/A |
| **Touch Behaviour** | Horizontal scroll with edge fade mask |
| **Reduced Motion Alternative** | Full table visible; Splitr column pre-highlighted |
| **Performance Budget** | Table ≤ 6 rows — DOM ok |
| **GPU Budget** | Scan line 1 layer |
| **Implementation Notes** | Sync §11.11.4 mobile card order; cross-ref Director §II Scene 05 `TL-Compare-Resolve` |

#### F-L04 — Shipped implementation (tick 15 sync)

| Item | Status |
|------|--------|
| Scan line | Shipped — `data-motion-scan`, 1.2s L→R @ `top 70%` |
| Mobile Splitr card | Shipped — border pulse via `data-motion-splitr-card` |
| Checkmarks | **Gap** — text `✓` + `scale: 0.6` pop (`useComparisonMotion` L183–189) |
| Competitor depth | **Gap** — no blur/soften on non-Splitr columns |
| Verdict settle | **Gap** — no `data-verdict-settled` → pricing handoff (tick 22) |

**Migration (Scene 05):** Replace `CellMark` yes glyph with inline SVG `<path stroke-dasharray>`; animate `strokeDashoffset` 100→0 stagger 150ms trailing scan. Add `filter: blur(2px)` or `opacity: 0.7` on competitor `td` after row snap. Remove `scale` + `back.out` — banned per §I.

#### F-L03 → F-L04 handoff — `cards-to-rows` (tick 21)

Per Director **§II.I 04→05**. `#features` exits before `#compare` scan.

| Step | Action |
|------|--------|
| 1 | On `#features` leave (bottom 80% viewport): set `data-exit-align="true"` |
| 2 | Reset card tilt — `useFeatureCardTilt` off; all cards `rotateX(0)` |
| 3 | `margin-bottom: min(8vh, 64px)` breathing room |
| 4 | `#compare` scan fires only after exit-align OR shares column rhythm with feature grid |

**Drop-in (`useFeatureGridMotion` or sibling hook):**

```ts
ctx.ScrollTrigger.create({
  trigger: grid,
  start: 'bottom 80%',
  onEnter: () => { grid.dataset.exitAlign = 'true' },
  onLeaveBack: () => { delete grid.dataset.exitAlign },
})
```

```css
#features[data-exit-align='true'] {
  margin-bottom: min(8vh, 64px);
  transition: margin-bottom 300ms ease-out;
}
```

**Pass criteria:** Q9 prep — compare feels like verdict on toolkit above, not new section.

---

### F-L05 — Pro pricing (`#pricing`)

| Field | Spec |
|-------|------|
| **Motion Goal** | Annual plan feels like **unlocking** depth |
| **Emotion** | `motion.delight` + `motion.trust` |
| **Narrative** | Monthly = surface; Yearly = deeper layer rises |
| **User Attention Goal** | Annual card elevation |
| **Animation Density** | Low |
| **Scene Breakdown** | Two cards; annual translates Z via `translateY(-8px)` + shadow spread on enter |
| **Timeline** | 400ms spring on enter |
| **Camera Movement** | None |
| **Three.js Objects** | None |
| **GSAP Timeline** | `fromTo(annualCard, { y: 24, boxShadow: '...' }, { y: -8, ... })` |
| **Trigger** | Intersection 40% |
| **Scroll Behaviour** | One-shot |
| **Entry** | Depth lift — **not** fade |
| **Exit** | N/A |
| **Hover** | Border accent 35% opacity |
| **Idle Animation** | Subtle shadow breathe 4s on annual only |
| **Mouse Behaviour** | N/A |
| **Touch Behaviour** | Annual card first in DOM |
| **Reduced Motion Alternative** | Static layout; annual border pre-applied |
| **Performance Budget** | box-shadow animate sparingly — prefer transform |
| **GPU Budget** | 2 cards |
| **Implementation Notes** | No price count-up — distracting; cross-ref Director §II Scene 06 `TL-Pricing-Fair` |

#### F-L05 — Shipped implementation + free-core anchor (tick 21)

| Item | Status |
|------|--------|
| Annual lift | Shipped — `translateY(-8px)` + `back.out(1.4)` @ `top 60%` |
| Monthly enter | Shipped — subtle `y: 16→0` (same trigger) |
| Annual breathe | Shipped — CSS `annualBreathe` 4s on `.featured` |
| Free-core anchor | **Gap** — section is Pro-only; Scene 06 needs free ledger visually primary |

**Scene 06 fix (content + motion):** Add static free-tier callout **above** Pro grid — no animation delay:

```tsx
<p className={styles.freeCore} data-motion="free-anchor">
  Core splitting, groups &amp; UPI settle-up — <strong>free forever</strong>.
</p>
```

Pro cards animate only after free anchor visible. **Failure mode:** annual card larger/brighter than free message — demotes free-core promise (Q10).

#### F-L04 → F-L05 handoff — `verdict-to-fair` (tick 22)

Scene 05 exit → Scene 06 entry. Director **§II Scene 05** step 5 + **Scene 06** step 1.

| Step | Action |
|------|--------|
| 1 | Compare scan + checks complete → `#compare` `data-verdict-settled="true"` |
| 2 | Splitr column holds accent highlight 400ms — rational climax pause |
| 3 | User scrolls to `#pricing` — `free-anchor` static, already painted |
| 4 | Pro card lift runs **after** anchor intersects — never before |

**Drop-in (`useComparisonMotion` `onEnter` tail):**

```ts
gsap.delayedCall(1.35, () => {
  sectionEl.dataset.verdictSettled = 'true'
})
```

**Drop-in (`usePricingMotion`):** gate Pro animation on anchor visibility:

```ts
const anchor = sectionEl.querySelector('[data-motion="free-anchor"]')
if (!anchor) return // until tick 21 DOM lands
// start: 'top 60%' on section — anchor must be in first paint
```

```css
#compare[data-verdict-settled='true'] .splitrCol {
  background: var(--color-accent-fill-soft);
  transition: background 400ms ease-out;
}
```

**Pass criteria:** Q10 — free message read before Pro motion draws eye.

---

### F-L02 — Trust strip (`#trust`)

| Field | Spec |
|-------|------|
| **Motion Goal** | Trust seals **stamp** in — authority |
| **Emotion** | `motion.trust` |
| **Narrative** | Compliance ink stamp |
| **User Attention Goal** | Icons + labels scan L→R |
| **Animation Density** | Low |
| **Scene Breakdown** | 4 icons: scale from 1.15 → 1 with `steps(3)` easing — stamp feel |
| **Timeline** | 80ms stagger per item, 200ms each |
| **Camera Movement** | None |
| **Three.js Objects** | None |
| **GSAP Timeline** | `gsap.from(icon, { scale: 1.15, ease: 'steps(3)', duration: 0.2 })` |
| **Trigger** | Intersection 50% |
| **Scroll Behaviour** | One-shot |
| **Entry** | Stamp scale — **not** fade |
| **Exit** | N/A |
| **Hover** | Icon stroke brightens |
| **Idle Animation** | None |
| **Mouse Behaviour** | N/A |
| **Touch Behaviour** | 2×2 grid static |
| **Reduced Motion Alternative** | All visible |
| **Performance Budget** | 4 icons SVG |
| **GPU Budget** | Minimal |
| **Implementation Notes** | `TrustIcon` stroke SVGs shipped; cross-ref Director §II Scene 07 `TL-Trust-Vault` |

#### F-L02 — Shipped implementation + vault cool-down (tick 20)

| Item | Status |
|------|--------|
| Icon stamp | Shipped — `steps(3)` scale 1.15→1, 80ms stagger @ `top 50%` |
| Stroke icons | Shipped — `TrustIcon` (UPI, lock, check, India) |
| Environmental cool | **Gap** — Scene 07 vault tone; pricing warmth doesn't cool |

**Drop-in (`TrustStrip.module.css` + `useTrustStripMotion`):**

```css
.strip {
  transition: background-color 600ms ease-out, border-color 600ms ease-out;
}
.strip[data-vault-cool='true'] {
  background: color-mix(in srgb, var(--color-bg) 92%, #1a2a35);
  border-color: color-mix(in srgb, var(--color-border) 80%, transparent);
}
```

```ts
// useTrustStripMotion onEnter — after stamp
sectionEl.dataset.vaultCool = 'true'
```

**Pass criteria:** Q11 (§II.E) — section feels stable/vaulted, not celebratory. No animation on icons beyond stamp.

---

### F-L06 — FAQ (`#faq`)

| Field | Spec |
|-------|------|
| **Motion Goal** | Answers **unfold** — transparency metaphor |
| **Emotion** | `motion.clarity` |
| **Narrative** | Objections peel open |
| **User Attention Goal** | Expanded panel content |
| **Animation Density** | Micro per interaction |
| **Scene Breakdown** | Accordion: `grid-template-rows 0fr→1fr` + chevron rotate 180° |
| **Timeline** | 250ms ease-out expand |
| **Camera Movement** | None |
| **Three.js Objects** | None |
| **GSAP Timeline** | Prefer CSS `grid` transition — GSAP optional |
| **Trigger** | Click / Enter / Space |
| **Scroll Behaviour** | N/A |
| **Entry** | N/A |
| **Exit** | Collapse symmetric |
| **Hover** | Question text full white |
| **Idle Animation** | None |
| **Mouse Behaviour** | N/A |
| **Touch Behaviour** | 44px min target |
| **Reduced Motion Alternative** | Instant toggle |
| **Performance Budget** | No height JS measure — use CSS grid trick |
| **GPU Budget** | N/A |
| **Implementation Notes** | `aria-controls` + `id` wired; chevron 45°; cross-ref Director §II Scene 08 + §II.I `faq-cta-breath` |

#### F-L06 — Shipped implementation + exit breath (tick 19)

| Item | Status |
|------|--------|
| Accordion expand | Shipped — CSS `grid-template-rows` 250ms ease-out |
| Chevron | Shipped — 45° rotate (spec 180° — cosmetic) |
| FAQ topics | Shipped — free, Pro, data, web vs app, UPI |
| Exit breath | **Gap** — no pause before `#download`; §II.I 08→09 |

**Drop-in (`FaqSection.tsx`):**

```tsx
const sectionRef = useRef<HTMLElement>(null)
const lastIndex = faqs.length - 1

const onToggle = (i: number) => {
  const closingLast = open === lastIndex && i === lastIndex
  setOpen(open === i ? null : i)
  if (closingLast && sectionRef.current) {
    sectionRef.current.dataset.exitBreath = 'true'
    window.setTimeout(() => {
      delete sectionRef.current?.dataset.exitBreath
    }, 200)
  }
}
```

**CSS (`FaqSection.module.css`):**

```css
.section[data-exit-breath='true'] {
  padding-bottom: min(24vh, 160px);
  transition: padding-bottom 200ms ease-out;
}
```

**Pass criteria:** Q12 (§II.E) — user feels beat between last answer and CTA wipe. No GSAP required.

---

### F-L07 — Final CTA (`#download`)

| Field | Spec |
|-------|------|
| **Motion Goal** | **Pulse to action** — UPI settle metaphor |
| **Emotion** | `motion.flow` + `motion.delight` |
| **Narrative** | Story ends where money moves — install opens app |
| **User Attention Goal** | Primary Install button |
| **Animation Density** | Medium ambient |
| **Scene Breakdown** | Full-bleed band; concentric UPI rings emanate from CTA behind (`mix-blend-mode: screen`) |
| **Timeline** | Rings loop 3s; CTA scale breathe 1 → 1.02 → 1 over 2s once on enter |
| **Camera Movement** | None |
| **Three.js Objects** | None — CSS `::before` rings |
| **GSAP Timeline** | Optional ring `scale` loop |
| **Trigger** | Intersection 60% |
| **Scroll Behaviour** | Ambient loop while in view; `IntersectionObserver` pauses off-screen |
| **Entry** | Band **wipe** upward via mask |
| **Exit** | N/A |
| **Hover** | CTA magnetic 6px |
| **Idle Animation** | Ring pulse — pause off-screen |
| **Mouse Behaviour** | N/A |
| **Touch Behaviour** | Full-width CTA |
| **Reduced Motion Alternative** | Static band; no ring |
| **Performance Budget** | CSS only |
| **GPU Budget** | 2 pseudo-elements |
| **Implementation Notes** | Match hero CTA styling; cross-ref Director §II Scene 09 `TL-Install-Door` |

#### F-L07 — Shipped implementation (tick 16 sync)

| Item | Status |
|------|--------|
| Band wipe | Shipped — `clipPath` mask @ `top 60%` (`useFinalCtaMotion`) |
| UPI rings | Shipped — CSS `ringPulse` via `data-in-view` on section |
| Magnetic CTA | Shipped — `useMagneticHover(ctaRef, 6)` |
| Analytics | Shipped — `trackInstallClick('final_cta')` |
| Settled balance | **Gap** — no `[data-motion="settled-balance"]` DOM; Scene 03 tease never pays off |
| Install pulse | **Gap** — rings loop ambient; no one-shot `motion.delight` on CTA enter (QA #4) |
| CTA breathe | **Gap** — spec says scale 1→1.02 once; not implemented |

**DOM contract (Scene 09):** Insert above `#download-heading`:

```html
<div data-motion="settled-balance" aria-hidden="true">
  <!-- e.g. ₹0 owed · all settled -->
</div>
```

On enter: `phys.snap` number align; then UPI rings burst from Install badge; single accent pulse on `.cta` — rings pause after pulse per §I delight budget.

---

### F-C07 — Cookie consent

| Field | Spec |
|-------|------|
| **Motion Goal** | Inform without blocking narrative |
| **Emotion** | `motion.trust` |
| **Narrative** | Floor rises — decision point |
| **User Attention Goal** | Accept / Reject |
| **Animation Density** | Low |
| **Scene Breakdown** | Bar slides from below viewport |
| **Timeline** | 300ms enter |
| **Camera Movement** | None |
| **Three.js Objects** | None |
| **GSAP Timeline** | CSS `transform: translateY(100%→0)` |
| **Trigger** | Delay 1s after load if no preference |
| **Scroll Behaviour** | Fixed bottom |
| **Entry** | Slide up — functional, allowed |
| **Exit** | 200ms slide down on dismiss |
| **Hover** | Button states per §11.5 |
| **Idle Animation** | None |
| **Mouse Behaviour** | N/A |
| **Touch Behaviour** | 48px buttons |
| **Reduced Motion Alternative** | Instant show/hide |
| **Performance Budget** | No GA until accept |
| **GPU Budget** | 1 layer |
| **Implementation Notes** | §11.11.3 unchanged |

---

### F-C01–F-C06 — Legal / compliance pages

| Field | Spec |
|-------|------|
| **Motion Goal** | Readability — motion must not compete with legal text |
| **Emotion** | `motion.trust` |
| **Narrative** | None |
| **User Attention Goal** | Prose content |
| **Animation Density** | None |
| **Scene Breakdown** | Static |
| **Timeline** | Route transition 200ms mask only |
| **Camera Movement** | None |
| **Three.js Objects** | None |
| **GSAP Timeline** | `page-transition` 200ms horizontal mask between marketing routes |
| **Trigger** | Route change |
| **Scroll Behaviour** | Native; smooth anchor 400ms |
| **Entry** | Optional: heading underline draw 300ms — single element only |
| **Exit** | N/A |
| **Hover** | Link underline |
| **Idle Animation** | None |
| **Mouse Behaviour** | N/A |
| **Touch Behaviour** | N/A |
| **Reduced Motion Alternative** | Instant route |
| **Performance Budget** | Zero WebGL |
| **GPU Budget** | 0 |
| **Implementation Notes** | TOC smooth scroll per §12.2 |

---

### GLOBAL — 404 (`NotFoundPage`)

| Field | Spec |
|-------|------|
| **Motion Goal** | Disorientation → path home |
| **Emotion** | `motion.tension` → `motion.clarity` |
| **Narrative** | Lost bill floats; snaps to home CTA |
| **User Attention Goal** | Home CTA |
| **Animation Density** | Low |
| **Scene Breakdown** | "404" glyphs drift apart slowly; on CTA hover they **magnet** back together |
| **Timeline** | Idle drift 8s loop; hover snap 300ms |
| **Camera Movement** | None |
| **Three.js Objects** | None — split typography CSS |
| **GSAP Timeline** | `gsap.to('.digit', { x: random, y: random, duration: 4, yoyo: true })` |
| **Trigger** | Page load |
| **Scroll Behaviour** | N/A |
| **Entry** | Digits already separated — no fade |
| **Exit** | N/A |
| **Hover** | CTA hover pulls digits |
| **Idle Animation** | Drift |
| **Mouse Behaviour** | Cursor repulsion on digits optional |
| **Touch Behaviour** | Static |
| **Reduced Motion Alternative** | Static 404 text |
| **Performance Budget** | 3 DOM nodes |
| **GPU Budget** | Minimal |
| **Implementation Notes** | §11.9 pattern |

---

### F-A01 — Auth (sign in / sign up)

| Field | Spec |
|-------|------|
| **Motion Goal** | Gate feels secure, fast |
| **Emotion** | `motion.trust` |
| **Narrative** | Door opens to account |
| **User Attention Goal** | OAuth + email form |
| **Animation Density** | Low |
| **Scene Breakdown** | Card enters via **depth** `rotateX(4deg)→0` 200ms; tab switch = horizontal mask slide |
| **Timeline** | 200ms enter; 150ms tab |
| **Camera Movement** | None |
| **Three.js Objects** | None |
| **GSAP Timeline** | Optional — CSS ok |
| **Trigger** | Route enter |
| **Scroll Behaviour** | N/A |
| **Entry** | 3D card unfold — **not** fade |
| **Exit** | Reverse on leave |
| **Hover** | OAuth button lift 1px |
| **Idle Animation** | None |
| **Mouse Behaviour** | N/A |
| **Touch Behaviour** | Full-width card |
| **Reduced Motion Alternative** | Instant |
| **Performance Budget** | No scroll libraries |
| **GPU Budget** | 1 card |
| **Implementation Notes** | §12 F-A01 |

#### F-A01 — Shipped implementation + tab cross-fade (tick 23)

| Item | Status |
|------|--------|
| Card enter | Shipped — `AuthLayout.module.css` `rotateX(4°→0)` 200ms |
| Tab buttons | Shipped — instant class swap; no form transition |
| Form swap | **Gap** — B3; `LoginPage.tsx` L41 hard conditional |

**Drop-in (`LoginPage.tsx`):**

```tsx
<div
  key={mode}
  role="tabpanel"
  className={styles.formSwap}
  aria-labelledby={mode === 'signin' ? 'tab-signin' : 'tab-signup'}
>
  {mode === 'signin' ? <LoginForm /> : <RegisterForm />}
</div>
```

Add `id="tab-signin"` / `id="tab-signup"` on tab buttons. On mode change, focus first input via `useEffect` + `querySelector('input')`.

**CSS (`AuthForm.module.css`):**

```css
.formSwap {
  animation: tabReveal 150ms cubic-bezier(0.16, 1, 0.3, 1);
}
@keyframes tabReveal {
  from { clip-path: inset(0 0 0 8%); }
  to { clip-path: inset(0 0 0 0); }
}
@media (prefers-reduced-motion: reduce) {
  .formSwap { animation: none; }
}
```

**Banned:** opacity-only cross-fade — use `clip-path` per §I. Tab border swap can stay instant.

**Effort:** ~30m (ship blocker B3).

---

## 3. Scroll map (desktop ≥1024px)

> **Superseded by §II.C** (cinematic full-film map). Below = legacy shipped implementation order.

```
0%     [GLOBAL intro mask] → hero pin begins
0–15%  F-L01 Hero scrub (3D orbit + split paths)
15–30% F-L08 How it works pin (step graph)
30–45% F-L03 Feature unfold
45–55% F-L04 Comparison scan
55–65% F-L05 Pricing lift
65–72% F-L02 Trust stamp
72–85% F-L06 FAQ (interaction only)
85–95% F-L07 CTA pulse
95%+   Footer
```

Mobile `<1024px`: **no pins** — one-shot intersection animations only.

---

## 4. Implementation order (for Developer Agent)

> **Build order:** use Director **§II.K** (12 steps). Legacy phases below = historical; §4.2 maps audit rows to §II.K.

| Phase | Features | Deps |
|-------|----------|------|
| P0 | `useReducedMotion`, intro mask, nav scroll | None |
| P1 | F-L01 hero mask + lazy R3F | P0 |
| P2 | F-L08 pinned step graph | GSAP ScrollTrigger |
| P3 | F-L03, F-L04, F-L05, F-L02 enters | P2 |
| P4 | F-L07 ambient, 404 drift, auth card | P0 |
| P5 | Performance pass + poster fallbacks | All |

### 4.1 Implementation audit (code vs spec)

> Scene-level view: see **§II.F** (Director fidelity matrix). Below = file-level detail.

| Feature | Hook / file | Status | Gaps vs spec |
|---------|-------------|--------|--------------|
| GLOBAL intro | `IntroOverlay.tsx` | Partial | Circle reveal + guards shipped; B2 SVG stroke-draw tick 24 (§II.K step 3) |
| F-C08 nav | CSS `Nav.module.css` | Shipped | — |
| F-L01 hero | `useHeroMotion`, `HeroVisual`, `useHeroVisualTilt`, `useMagneticHover` | Partial | Poster/tilt shipped; B1 package tick 25 — pin/scrub + chaos SVG |
| F-L08 how | `useHowItWorksMotion` | Partial | Pin + scrub shipped; B4 mask/snap/tease + exit fracture per tick 17 spec |
| F-L03 features | `useFeatureGridMotion`, `FeatureIcon`, `useFeatureCardTilt` | Partial | Unfold + icons + tilt shipped; fracture line drop-in spec tick 18 (§II.I) |
| F-L04 compare | `useComparisonMotion` | Partial | Scan shipped; stroke-draw + depth soften + verdict handoff (tick 22) |
| F-L05 pricing | `usePricingMotion` | Partial | Annual lift shipped; `free-anchor` + verdict gate per ticks 21–22 |
| F-L02 trust | `useTrustStripMotion`, `TrustIcon` | Partial | Stamp + stroke icons shipped; `data-vault-cool` env gap per Scene 07 |
| F-L06 FAQ | `FaqSection.module.css` | Partial | Accordion shipped; `data-exit-breath` gap per §II.I tick 19 |
| F-L07 CTA | `useFinalCtaMotion`, `useMagneticHover(6)` | Partial | Wipe + rings + magnetic shipped; settled balance + install pulse per `TL-Install-Door` |
| GLOBAL 404 | `useNotFoundMotion` | Shipped | Drift + CTA hover snap match spec |
| F-A01 auth | `AuthLayout.module.css`, `LoginPage.tsx` | Partial | Card enter shipped; `formSwap` clip-path tab cross-fade — B3 tick 23 |

Shared infra: `createMotionContext()` **async** via `loadGsap()`; `useMotionEffect` wrapper in `useLandingScrollMotion.ts`; `isDesktopMotion()` @ 1024px; `useReducedMotion()` everywhere.

### 4.2 Audit → §II.K build map (tick 26)

Post-milestone index — see Director **§II.L**. Each gap links to documented drop-in spec.

| §II.K step | §4.1 row | Spec tick | Shipped today |
|------------|----------|-----------|---------------|
| 1 | F-L01 | 25 | H1 mask, poster, tilt, magnetic |
| 2 | F-L08 | 17 | Pin + scrub |
| 3 | GLOBAL intro | 24 | Circle reveal, guards |
| 4 | F-L08 exit + F-L03 | 17–18 | — |
| 5 | F-L03 | 21 | Unfold, icons, tilt |
| 6 | F-L04 | 15 | Scan, mobile pulse |
| 7–8 | F-L04 + F-L05 | 21–22 | Annual lift only |
| 9 | F-L02 | 20 | Stamp, TrustIcon |
| 10 | F-L06 | 19 | Accordion |
| 11 | F-L07 | 16 | Wipe, rings, magnetic |
| 12 | F-A01 | 23 | Card enter |

**Shipped count:** 2 full (nav, 404) + partial on all landing features. **Agent loop:** spec maintenance only until Developer picks up §II.K.

---

## 5. Agent tick log

| Tick | Date | Work |
|------|------|------|
| 1 | 2026-07-27 | Created motion library; research synthesis; full specs all landing + global features; scroll map; implementation order |
| 2 | 2026-07-27 | Synced P0 code status; F-L01 GSAP ref; M4 resolved (CSS v1); flagged IntroOverlay scale drift |
| 3 | 2026-07-27 | Full implementation audit §4.1; F-L08 shipped sync; P1 hero pin remains top gap |
| 4 | 2026-07-27 | Hero visual shipped sync; `useHeroScrollMotion` DOM contract + tilt/scroll conflict note |
| 5 | 2026-07-27 | F-L06 + F-A01 audit sync; IntroOverlay SVG stroke-draw implementation spec |
| 6 | 2026-07-27 | Drop-in `useHeroScrollMotion` hook; auth tab CSS spec; §7 ship blockers |
| 7 | 2026-07-27 | No code drift; B5 Scene 02 gap flagged; Scene 01 ↔ Director §II cross-linked |
| 8 | 2026-07-27 | F-L01 legacy spec synced to `TL-Hero-Extended`; hook + DOM updated for Scene 02 chaos phases |
| 9 | 2026-07-27 | Code sync: async `createMotionContext` + `useMotionEffect`; B1–B4 still open; Scene 03 polish CSS in §II |
| 10 | 2026-07-27 | IntroOverlay `pathname === '/'` guard shipped; B1–B4 unchanged; §II.C supersedes legacy §3 scroll map |
| 11 | 2026-07-27 | F-L08 legacy synced to Director Scene 03 (UPI tease, balance snap); no code drift |
| 12 | 2026-07-27 | F-L07 audit: magnetic CTA + UPI rings shipped; Scene 09 narrative polish gap noted |
| 13 | 2026-07-27 | No code drift; §4.1 cross-linked to §II.F fidelity matrix |
| 14 | 2026-07-27 | F-L03: `FeatureIcon` + `useFeatureCardTilt` shipped; Scene 04 partial progress |
| 15 | 2026-07-27 | F-L04 shipped audit + Scene 05 migration spec (`TL-Compare-Resolve`); status → Partial |
| 16 | 2026-07-27 | F-L07 shipped audit + `TL-Install-Door` DOM contract; settled balance + install pulse gaps |
| 17 | 2026-07-27 | F-L08 B4 drop-in spec (mask, balance snap, UPI tease, exit fracture); status → Partial; QA #2 |
| 18 | 2026-07-27 | F-L03 fracture-line drop-in spec; HomePage bridge per §II.I; depends on B4 exit |
| 19 | 2026-07-27 | F-L06 `data-exit-breath` drop-in spec; §II.I 08→09 handoff; status → Partial |
| 20 | 2026-07-27 | F-L02 `data-vault-cool` drop-in spec (Scene 07); `TrustIcon` sync; milestone — see Director §II.J build-ready index |
| 21 | 2026-07-27 | F-L03→F-L04 `cards-to-rows` handoff (§II.I); F-L05 free-core anchor spec; status → Partial |
| 22 | 2026-07-27 | F-L04→F-L05 `verdict-to-fair` handoff; `data-verdict-settled` + Pro lift gate |
| 23 | 2026-07-27 | F-A01 B3 drop-in spec — `formSwap` clip-path, tabpanel a11y, focus handoff |
| 24 | 2026-07-27 | GLOBAL B2 drop-in spec — SVG stroke wordmark; shipped audit; M2 Albra defer path |
| 25 | 2026-07-27 | F-L01 B1 implementation package — full `useHeroScrollMotion` + wire-up; §II.K step 1; QA #1 |
| 26 | 2026-07-27 | Post-§II.L consolidation — §4.2 audit map; `scene02-chaos.svg` asset brief; 02→03 path note |
| 27 | 2026-07-27 | Maintenance — no code drift; §4.1/§II.K gaps unchanged; B1–B4 + drop-ins still open |
| 28 | 2026-07-27 | Maintenance — no code drift; §II.L hold continues |
| 29 | 2026-07-27 | Maintenance — no code drift; B1–B4 + §II.K drop-ins still open |
| 30 | 2026-07-27 | Milestone (30 ticks) — maintenance; no drift; §II.L spec complete; Developer owns §II.K |
| 31 | 2026-07-27 | Maintenance — no code drift; §II.L hold |
| 32 | 2026-07-27 | Maintenance — no code drift; B1–B4 still open |
| 33 | 2026-07-27 | Maintenance — no code drift; §II.L hold |
| 34 | 2026-07-27 | Maintenance — no code drift; B1–B4 still open |
| 35 | 2026-07-27 | Maintenance — no code drift; §II.L hold |
| 36 | 2026-07-27 | Maintenance — no code drift; B1–B4 still open |
| 37 | 2026-07-27 | Maintenance — no code drift; §II.L hold |
| 38 | 2026-07-27 | Maintenance — no code drift; B1–B4 still open |
| 39 | 2026-07-27 | Maintenance — no code drift; §II.L hold |
| 40 | 2026-07-27 | Milestone (40 ticks) — maintenance; no drift; §II.L spec complete; Developer owns §II.K |
| 41 | 2026-07-27 | Maintenance — no code drift; B1–B4 still open |
| 42 | 2026-07-27 | Maintenance — no code drift; §II.L hold |
| 43 | 2026-07-27 | Maintenance — no code drift; B1–B4 still open |
| 44 | 2026-07-27 | Maintenance — no code drift; §II.L hold |
| 45 | 2026-07-27 | Maintenance — no code drift; B1–B4 still open |
| 46 | 2026-07-27 | Maintenance — no code drift; §II.L hold |
| 47 | 2026-07-27 | Maintenance — no code drift; B1–B4 still open |
| 48 | 2026-07-27 | Maintenance — no code drift; §II.L hold |
| 49 | 2026-07-27 | Maintenance — no code drift; B1–B4 still open |
| 50 | 2026-07-27 | Milestone (50 ticks) — maintenance; no drift; §II.L spec complete; Developer owns §II.K |
| 51 | 2026-07-27 | Maintenance — no code drift; B1–B4 still open |
| 52 | 2026-07-27 | Maintenance — no code drift; §II.L hold |
| 53 | 2026-07-27 | Maintenance — no code drift; B1–B4 still open |
| 54 | 2026-07-27 | Maintenance — no code drift; §II.L hold |
| 55 | 2026-07-27 | Maintenance — no code drift; B1–B4 still open |
| 56 | 2026-07-27 | Maintenance — no code drift; §II.L hold |
| 57 | 2026-07-27 | Maintenance — no code drift; B1–B4 still open |
| 58 | 2026-07-27 | Maintenance — no code drift; §II.L hold |
| 59 | 2026-07-27 | Maintenance — no code drift; B1–B4 still open |
| 60 | 2026-07-27 | Milestone (60 ticks) — maintenance; no drift; §II.L spec complete; Developer owns §II.K |
| 61 | 2026-07-27 | Maintenance — no code drift; B1–B4 still open |
| 62 | 2026-07-27 | Maintenance — no code drift; §II.L hold |
| 63 | 2026-07-27 | Maintenance — no code drift; B1–B4 still open |
| 64 | 2026-07-27 | Maintenance — no code drift; §II.L hold |
| 65 | 2026-07-27 | Maintenance — no code drift; B1–B4 still open |
| 66 | 2026-07-27 | Maintenance — no code drift; §II.L hold |

---

## 6. Open questions (→ Product / UI/UX)

| # | Question | Blocks |
|---|----------|--------|
| M1 | Real app screenshot for hero — **using `hero-poster.png` v1**; swap Groups overview when ready | F-L01 texture |
| M2 | Albra font licence for animated stroke wordmark? | GLOBAL intro |
| M3 | Lenis smooth scroll — **defer v1** (native scroll + scrub ok) | — |
| M4 | ~~Phone mock 3D vs flat~~ | **Resolved:** CSS poster v1; R3F behind flag |

---

## 7. Ship blockers (motion v1 done when cleared)

| # | Blocker | Owner | Effort |
|---|---------|-------|--------|
| B1 | Wire `useHeroScrollMotion` + split SVG + `scene02-chaos.svg` in `HeroVisual` (Scenes 01–02, `TL-Hero-Extended`) | Developer | ~4h |
| B2 | IntroOverlay SVG stroke-draw | Developer | ~1h |
| B3 | Auth tab `formSwap` cross-fade | Developer | ~30m |
| B4 | Scene 03 polish: copy mask + balance snap + UPI tease (full settle = Scene 09) | Developer | ~1h |

**B5 merged into B1** (Scene 02 woven into hero pin per Director tick 1).

**Scene 01 alignment:** Director §II Scene 01 = F-L01 + GLOBAL intro. Implement B1 + B2 to match cinematic spec.

All other landing sections **shipped** per §4.1.
