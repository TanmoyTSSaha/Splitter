# Splitr — Creative Direction

**Owner:** Creative Director Agent  
**Consumers:** Storyboard Director, Motion Director, UI/UX Director, Developer, Experience QA  
**Upstream inputs:** `product-description.md`, `react-website-development-details.md`, `motion-library.md`  
**Last updated:** 2026-07-27 (loop stopped by user)  
**Status:** Spec frozen — loop **stopped**; awaiting dev B1 or tone/comparison confirm

### Executive digest (read this first)

| Item | Value |
|------|-------|
| **North star** | Control — *"I finally know who owes what"* |
| **Arc** | Uncertainty → Map → Command → Settle (9 scenes) |
| **Pins** | Hero (01+02) + Scene 03 mechanism |
| **QA min moments** | Chaos drift (02) · Grid snap (03) · Install pulse (09) |
| **Banned** | Fade-in sections, emoji trust, generic 3-card grids |
| **P0 build** | Hero pin → Scene 03 pin → kill template motion |
| **Bottleneck** | `storyboard.md` Scenes 04–09 still Pending |
| **Ship gap** | **B1 spec ready** (`useHeroScrollMotion` package) — **not yet in code**; Scene 04 tilt partial |

---

## Project Vision

Splitr website is not a landing page. It is an **interactive product experience** — a scroll-driven story where the visitor travels from shared-money uncertainty to **command of the ledger**.

The visitor should leave remembering **how it felt**, not which sections they read.

**North star feeling (validated):** **Control** — *"I finally know who owes what."*

Control is not rigidity. It is the calm of a clear balance sheet — every rupee accounted for, every debt visible, every settle path obvious. Relief and cleverness serve control; they are not the headline.

**Domain:** `https://splitr.money`  
**Primary conversion:** Android app install (Play Store)  
**Secondary conversion:** Sign in to web (read-only v1)

---

## Creative Philosophy

1. **Emotion before information** — every scene answers "what should they feel?" before "what should we show?"
2. **Story, not sections** — no hero/features/pricing mental model; only chapters in one continuous narrative
3. **Travel, not scroll** — scrolling is the mechanism; the experience is movement through a world
4. **Purpose over polish** — motion teaches product truth (money flows, debts simplify, UPI settles); decoration is cut
5. **India-native confidence** — UPI, rupees, shared meals, roommates, trips — universal human moments, locally grounded
6. **Never generic SaaS** — if it could be any fintech template, redesign the scene

### What we study (mechanism, never copy)

| Reference class | Why effective | Splitr lesson |
|-----------------|---------------|---------------|
| CRED | Rewards attention; fintech can feel premium | Chapter structure — one idea per beat |
| Stripe | Invisible infrastructure made tangible | Animate **flows**, not boxes fading in |
| Linear | Precision signals trust | Restraint — motion on intent only |
| Apple | Product as protagonist | User "holds" the app through scroll |
| Nothing | Glyph as character | Brand accent (`#18c595`) pulses along split paths |
| Inngest | Complex process made legible | Step graph lights in sequence |
| Razorpay | India-scale trust | Real product surfaces, not abstract blobs |

---

## Brand Personality

**Draft (pending validation):**

| Axis | Position | Rationale |
|------|----------|-----------|
| Playful ↔ Premium | **Premium-warm** (CRED-adjacent, not childish) | Money is serious; tone can still delight |
| Clever ↔ Obvious | **Obvious-precision** | Control = clarity, not puzzles; user feels capable, not tricked |
| Loud ↔ Quiet | **Confident-quiet** | NeoPOP energy in accents, not noise |
| Human ↔ Corporate | **Human-first** | Friends, trips, roommates — not "enterprise expense management" |

**Voice:** Direct, warm, slightly witty. Never preachy. Never startup-bro.

**Tagline territory (not final copy):** Split. Track. Settle. *(app already uses this cluster)*

**Paywall philosophy (from product):** *"Charge for convenience, not your right to split."* — honesty builds trust in monetization scenes.

---

## Visitor Persona

**Primary — "The Ledger Keeper"** *(was: Awkward Splitter)*

| Attribute | Detail |
|-----------|--------|
| Who | 22–35, urban India, shares expenses with friends/roommates/partner |
| Why visiting | Friend shared link, Play Store search "splitwise alternative", saw ad, curiosity after group trip |
| Knows already | Splitwise exists; maybe tried it; UPI is daily life |
| Worries | Not knowing who owes whom, mental math in group chats, losing track across trips/rent, app complexity, data privacy |
| Excites | One dashboard for all balances, debt simplification, one-tap UPI settle, no ads, India-first |
| Leaves remembering | *"I finally know who owes what — and I can settle it in one tap."* |

**Secondary — "The Evaluator"** (comparison-minded, reads FAQ, checks privacy)

**Tertiary — "The Returning User"** (auth, web read-only — out of marketing story scope but tone must stay consistent)

---

## Emotional Journey

```
Arrival          → Curiosity        "What is this?"
Recognition      → Loss of control  "I never know who owes what."
Mechanism        → Grip returning   "Now I can see every balance."
Expansion        → Command          "One place for all of it."
Differentiation  → Confidence       "Clearer than what I use now."
Trust            → Steady ground    "My ledger is safe here."
Objections       → Full clarity     "No surprises — free core, optional Pro."
Resolution       → Ownership        "I'll take control — install / sign in."
```

### Emotional timeline (scene-mapped)

| Phase | Target emotion | Anti-emotion to avoid |
|-------|----------------|----------------------|
| Opening | Curiosity + intrigue | Confusion, template fatigue |
| Problem | Recognized tension (not fear) | Shame, alarmism |
| Mechanism | Grip returning — visible balances | Overwhelm, tutorial fatigue |
| Capability | Command — one ledger for everything | Feature dump |
| Compare | Quiet confidence in clarity | Petty competitor bashing |
| Pro | Fair value, no guilt | Hard sell, dark patterns |
| Trust | Solid calm | Legal-wall anxiety |
| Close | Momentum | Desperation |

---

## Story Structure

**Arc:** Beginning → Middle → Climax → Resolution → CTA

| Act | Story question | Product truth |
|-----|----------------|---------------|
| I — Arrival | What is Splitr? | Split, track, settle — one app |
| II — Tension | Why don't I know who owes what? | Fragmented balances, no single ledger |
| III — Mechanism | How does Splitr fix it? | Add → split → simplify → UPI settle |
| IV — Depth | What else? | Goals, lending, insights, trips |
| V — Choice | Why Splitr over others? | India-native, free core, no ads, breadth |
| VI — Trust | Can I rely on it? | Privacy, encryption, Razorpay for Pro only |
| VII — Action | What's next? | Install (primary), sign in (secondary) |

**Narrative spine (control-led):** **Uncertainty → Map → Command → Settle**  
*(Motion library: Chaos → Split → Clarity → Settle — same beats, control framing)*

**Hero execution (validated B):** Scenes 01 + 02 = **one pinned hero arc** inside F-L01. Scroll phases: Arrival (0–35%) → bridge (35–50%) → Lost Ledger (50–85%) → accent path handoff (85–100%).

**Pinned chapters (max 2–3):** Hero pin (01+02) + Scene 03 mechanism pin.

### Control pacing map (downstream sync target)

| Scene | Name | Emotion in | Emotion out | Scroll hook (unresolved) |
|-------|------|------------|-------------|--------------------------|
| 01 | Arrival | Neutral | Curiosity | Ledger grid hinted — not yet readable |
| 02 | Lost Ledger | Curiosity | Loss of control | One accent path forming — balances still scattered |
| 03 | The Split | Loss of control | Grip returning | All lines converge — settle not yet shown |
| 04 | Full Picture | Grip | Command | Toolkit opens — comparison unanswered |
| 05 | Verdict | Command | Confidence in clarity | Winner clear — cost unanswered |
| 06 | Fair Deal | Confidence | Fairness | Price known — trust not yet earned |
| 07 | Vault | Fairness | Steady ground | Locks close — one FAQ lingers |
| 08 | Last Question | Steady ground | Full clarity | Last doubt gone — action pending |
| 09 | Door | Clarity | Ownership | Install pulse — take the ledger |

### Memorable moments (QA recall — need ≥3)

Experience QA requires 3 standout moments in 24h debrief. Target these:

| # | Scene | Signature moment | Why memorable |
|---|-------|------------------|---------------|
| 1 | 02 | Numbers drift apart, won't align | Loss of control — visceral |
| 2 | 03 | Grid snap — every name, one balance | Control returns — arc payoff |
| 3 | 05 | Compare rows resolve into Splitr column | Rational climax |
| 4 | 09 | Single accent pulse on install CTA | Ownership — earned delight |

**Minimum ship set:** moments **1 + 2 + 4** (hero pin + mechanism + CTA). Moment 3 strengthens evaluator recall.

---

Abstract visuals only — no chat screenshots. Visitor should recognize **one** scenario per session (rotate or locale-default):

| Scenario | Control lost looks like | User thought |
|----------|-------------------------|--------------|
| **Dinner out** | 4 names, 1 bill, 3 payment methods — totals don't match | *"Who paid Swiggy? Who owes for the extra appetizer?"* |
| **Goa trip** | Flight + hotel + cabs split unevenly across 6 people | *"I've lost track since day 2."* |
| **Flat rent** | Rent + utilities + maid — recurring splits drift monthly | *"Same argument every month."* |
| **Wedding / event** | Group gift pool + shared stays — informal IOUs multiply | *"I don't even know the full list anymore."* |

**Rule:** Numbers drift and overlap — never shame the user. Control returns in Scene 03.

---

## Scene List

> Scenes replace "sections." IDs map loosely to Product §7 features for handoff — Creative Director owns *intent*; downstream agents own *execution*.

### Scene 01 — The Arrival

| Field | Direction |
|-------|-----------|
| **Scene objective** | Answer "What is Splitr?" in one felt moment |
| **Narrative** | Visitor lands inside a living financial moment — not a headline on white |
| **Desired emotion** | Curiosity — hint that order exists beneath chaos |
| **Transition in** | Instant immersion — no loading theatre |
| **Transition out** | Scroll pulls them into fragmented balances |
| **Expected user thought** | *"Something here knows where every rupee went."* |
| **Primary visual focus** | Brand world + ledger undertone (grid, balance hint) |
| **Primary motion focus** | Ambient depth with subtle alignment — order beneath surface |
| **Story contribution** | Establishes Splitr as experience, not brochure |
| **Business goal** | Stop bounce; earn next scroll |
| **Success criteria** | User scrolls within 3s; install CTA visible without feeling like banner ad |
| **Product map** | F-L01 Hero *(combined 01+02 scrub — see Story Structure)* |

### Scene 02 — The Lost Ledger

| Field | Direction |
|-------|-----------|
| **Scene objective** | Answer "Why don't I know who owes what?" |
| **Narrative** | Shared money without a system — overlapping IOUs, group chat math, no single source of truth |
| **Desired emotion** | Loss of control (recognized, not shamed) |
| **Transition in** | Visual chaos tightens — balances fragment across surfaces |
| **Transition out** | One line converges — promise of a single ledger |
| **Expected user thought** | *"I literally don't know who owes what right now."* |
| **Primary visual focus** | Fragmented balances / scattered numbers (abstract, not chat screenshots) |
| **Primary motion focus** | `motion.tension` — drift, overlap, numbers that won't align |
| **Story contribution** | Names the control problem control solves |
| **Business goal** | Emotional hook before feature list |
| **Success criteria** | User self-identifies with scenario (India: dinner, trip, rent) |
| **Product map** | F-L01 Hero extension *(not separate §7 row — woven into hero pin per storyboard)* |

### Scene 03 — The Split

| Field | Direction |
|-------|-----------|
| **Scene objective** | Answer "How does Splitr simplify everything?" |
| **Narrative** | Expense enters → splits across people → balances resolve |
| **Desired emotion** | Grip returning — first moment of control |
| **Transition in** | Chaos condenses into one input |
| **Transition out** | Balances snap to a single truth |
| **Expected user thought** | *"There it is — everyone owes exactly this."* |
| **Primary visual focus** | Step graph / split engine (Inngest-style sequence) |
| **Primary motion focus** | `motion.clarity` — numbers snap to grid, lines resolve |
| **Story contribution** | Core mechanism taught without manual |
| **Business goal** | Teach product in <8s scrub |
| **Product map** | F-L08 How it works |

#### Scene 03 — critical path brief

This is the **climax of the control arc** — if Scene 03 fails, the site stays a template.

| Field | Direction |
|-------|-----------|
| **Pin** | Second pinned chapter (~1.2 vh desktop) — hero unpins into this |
| **Beat 1 (0–30%)** | Single expense enters — chaos from Scene 02 condenses to one line item |
| **Beat 2 (30–70%)** | Split engine runs — nodes light in sequence; amounts distribute |
| **Beat 3 (70–100%)** | Balances snap to grid — **every name has one number**; debt simplify optional hint |
| **Control moment** | User must *read* who owes what without copy — numbers are the hero |
| **UPI tease** | Accent path pulses toward settle — full UPI beat reserved for Scene 09 |
| **Exit hook** | One settled group balance zooms out → toolkit expands (Scene 04) |
| **Failure mode** | Generic 4-icon step row with fade-in = reject |

---

### Scene 04 — The Full Picture

| Field | Direction |
|-------|-----------|
| **Scene objective** | Answer "What makes Splitr different?" (breadth) |
| **Narrative** | Split is the door; goals, lending, trips, insights are the room |
| **Desired emotion** | Command — one ledger for split, goals, lending, trips |
| **Transition in** | Single settled balance opens into full toolkit |
| **Transition out** | Focus narrows to comparison |
| **Expected user thought** | *"I wouldn't need three apps to stay on top of this."* |
| **Primary visual focus** | Product surfaces orbit or unfold — real UI, not icons |
| **Primary motion focus** | `motion.flow` — depth parallax, chapter unlock |
| **Story contribution** | Differentiation by capability, not claims |
| **Business goal** | Widen perceived value |
| **Product map** | F-L03 Feature grid |

#### Scene 04 — storyboard brief

| Field | Direction |
|-------|-----------|
| **Entry** | Scene 03 exit line fractures into 4–6 product surface cards (real UI screenshots) |
| **Beat** | Cards orbit or fan — each capability = one ledger dimension (split, goals, lending, trips, insights) |
| **Control metaphor** | User sees **one command center**, not feature spam |
| **Pin** | No pin — horizontal scroll or parallax fan on desktop; vertical stack mobile |
| **Exit hook** | Cards align into compare columns → Scene 05 |
| **Failure mode** | 3-column icon grid with equal cards |
| **Memorable moment** | Optional — toolkit unfold (not required for QA min set) |

### Scene 05 — The Verdict

| Field | Direction |
|-------|-----------|
| **Scene objective** | Answer "Why Switch?" |
| **Narrative** | Honest comparison — factual, not petty |
| **Desired emotion** | Confidence in clarity — Splitr shows more, hides less |
| **Transition in** | Side-by-side ledger clarity |
| **Transition out** | Soft landing toward value exchange |
| **Expected user thought** | *"I can actually see my balances — not buried in menus."* |
| **Primary visual focus** | Comparison as story beat, not table dump |
| **Primary motion focus** | Rows resolve in Splitr's favor through motion, not color alone |
| **Story contribution** | Climax of rational decision |
| **Business goal** | Capture evaluator persona |
| **Product map** | F-L04 Comparison |

#### Scene 05 — storyboard brief

| Field | Direction |
|-------|-----------|
| **Tone** | Clinical copy + bold visual — rows **resolve** on Splitr side |
| **Beat** | Evaluator scans; Splitr column stays sharp, competitors soften/blur depth |
| **Control metaphor** | Visibility of balances = differentiation |
| **Motion** | Row-by-row snap alignment — not checkmark animation |
| **Exit hook** | Last row settles → price question emerges (Scene 06) |
| **Memorable moment** | **#3** — compare rows resolve (QA recall target) |

### Scene 06 — The Fair Deal

| Field | Direction |
|-------|-----------|
| **Scene objective** | Answer "What does Pro cost — and is core free?" |
| **Narrative** | Core splitting is yours; Pro is power tools for people who want them |
| **Desired emotion** | Fairness — control without paywall on core ledger |
| **Transition in** | Value exchange framed as choice |
| **Transition out** | Soften into trust |
| **Expected user thought** | *"The ledger stays free. Pro is optional power."* |
| **Primary visual focus** | ₹ pricing anchored to real features (OCR, export, insights) |
| **Primary motion focus** | `motion.trust` — stable, slow |
| **Story contribution** | Monetization without betrayal of free-core promise |
| **Business goal** | Pro awareness without blocking install |
| **Product map** | F-L05 Pro pricing |

#### Scene 06 — storyboard brief

| Field | Direction |
|-------|-----------|
| **Beat** | Free core ledger front and center; Pro floats as optional layer |
| **Control metaphor** | User keeps control of free tier — Pro adds power, not access |
| **Visual** | ₹89/mo · ₹799/yr anchored to OCR, export, insights — not vanity features |
| **Exit hook** | "Your data" question lingers → Scene 07 |

### Scene 07 — The Vault

| Field | Direction |
|-------|-----------|
| **Scene objective** | Answer "Can I trust it?" |
| **Narrative** | Money and data handled with care — India payments, privacy, no ads |
| **Desired emotion** | Steady ground — ledger is safe, not exciting |
| **Transition in** | Visual temperature cools to stable |
| **Transition out** | Open for questions |
| **Expected user thought** | *"My balances and data stay mine — no ads, no selling me."* |
| **Primary visual focus** | Trust signals as environment, not badge row |
| **Primary motion focus** | `motion.trust` — horizon stable, locks close |
| **Story contribution** | Fintech credibility before CTA |
| **Business goal** | Reduce privacy objection |
| **Product map** | F-L02 Trust strip + F-L06 FAQ (split across two beats) |

#### Scene 07 — storyboard brief

| Field | Direction |
|-------|-----------|
| **Beat** | Environment cools — locks, horizon, authored icons (no emoji) |
| **Signals** | Encryption, no ads, UPI-native, India-first — factual only |
| **Control metaphor** | Ledger is **vaulted** — safe to store balances |
| **Exit hook** | One FAQ ghost line visible → Scene 08 |

### Scene 08 — The Last Question

| Field | Direction |
|-------|-----------|
| **Scene objective** | Dissolve remaining objections |
| **Narrative** | Transparent FAQ — web vs app, data, free vs Pro |
| **Desired emotion** | Full clarity — last unknowns resolved |
| **Transition in** | Questions emerge from prior trust |
| **Transition out** | Momentum into action |
| **Expected user thought** | *"I know exactly what I'm getting — web, app, free, Pro."* |
| **Primary visual focus** | Accordion as conversation, not legal wall |
| **Primary motion focus** | Minimal — content clarity over animation |
| **Story contribution** | Resolution of doubt |
| **Business goal** | FAQ SEO + objection handling |
| **Product map** | F-L06 FAQ |

#### Scene 08 — storyboard brief

| Field | Direction |
|-------|-----------|
| **Beat** | Accordion as dialogue — web vs app, data, free vs Pro |
| **Motion** | Minimal — expand reveals clarity, not bounce |
| **Exit hook** | Final item closes → empty space → install magnet (Scene 09) |

### Scene 09 — The Door

| Field | Direction |
|-------|-----------|
| **Scene objective** | Answer "Let's get started." |
| **Narrative** | Install is the natural next step — sign in for those already in |
| **Desired emotion** | Ownership — user takes the ledger |
| **Transition in** | UPI pulse / settle metaphor completes |
| **Transition out** | Footer as quiet epilogue (legal, links) |
| **Expected user thought** | *"I'm downloading — I want this level of control."* |
| **Primary visual focus** | Play Store badge + device; single clear primary action |
| **Primary motion focus** | `motion.delight` — one accent pulse on CTA |
| **Story contribution** | Story resolution |
| **Business goal** | `cta_install_click` |
| **Product map** | F-L07 Final CTA |

#### Scene 09 — storyboard brief

| Field | Direction |
|-------|-----------|
| **Beat** | UPI settle metaphor completes — accent pulse on Install (one delight per chapter rule) |
| **Control metaphor** | Download = take ledger with you |
| **CTA hierarchy** | Install primary · Sign in secondary — same as hero |
| **Memorable moment** | **#4** — install pulse (QA recall target) |
| **Epilogue** | Footer legal — quiet, no motion |

---

## Creative Principles

1. One scene = one question = one emotion shift toward **control**
2. Every motion must teach ledger truth — numbers align, debts simplify, paths resolve
3. No fade-in sections — mask reveals, path draws, pin scrubs only
4. Product UI is a character — show real balances and surfaces, not generic phones
5. India context is default, not a localization footnote
6. Comparison is honest — credibility beats aggression
7. Free core is a trust asset — never visually demoted
8. Repeat CTA only when emotion supports it (after trust, not after hero)
9. Reduced motion = same story, instant final states

---

## Visual Inspiration (mood, not mockups)

| Source | Extract |
|--------|---------|
| CRED | Chapter boldness, premium dark surfaces |
| Stripe | Gradient depth, typographic confidence |
| Linear | Sparse precision, glow on intent |
| Apple | Product orbit, specular craft |
| Nothing | Monochrome + single accent pulse |
| Razorpay | Dashboard realism, India scale |

**Splitr visual world (draft):** NeoPOP mobile palette extended to web — deep surfaces, `#18c595` accent as **control thread** (travels along resolving split paths), Albra wordmark as anchor. Precision over decoration — Linear/Razorpay dashboard legibility, not illustration overload.

### Comparison scene — creative brief (draft)

| Field | Direction |
|-------|-----------|
| **Tone** | Clinical-factual copy + **bold visual confidence** — Splitr rows show balances clearly; competitors blur or hide depth |
| **Emotion** | User feels informed, not sold to |
| **Avoid** | Snark, fake checkmarks, competitor logos without legal review |
| **Motion** | Rows **resolve** into alignment on Splitr column — control metaphor |
| **Success** | Evaluator recalls *"I could see my balances on Splitr's side"* |

---

## Motion Inspiration

See `motion-library.md` for implementation tokens. Creative intent:

| Story beat | Motion token | Feeling |
|------------|--------------|---------|
| Chaos | `motion.tension` | Loss of control — numbers drift, won't align |
| Split engine | `motion.clarity` | Grip returning — grid snap, one truth |
| Money movement | `motion.flow` | Command — paths resolve correctly |
| Trust / Pro | `motion.trust` | Steady ground — horizon stable |
| CTA | `motion.delight` | Ownership — one earned pulse on install |

---

## Voice & copy tone (premium-warm draft)

| Context | Do | Don't |
|---------|-----|-------|
| Headlines | Short, declarative — state control gained | Hype ("revolutionary", "game-changing") |
| Problem beats | Name the feeling — *"Who owes what?"* | Shame (*"You're bad with money"*) |
| Mechanism | Show outcome first, label second | Feature lists without balances |
| Pro | Optional power — user stays in control | Urgency timers, guilt |
| Trust | Plain facts — encryption, no ads | Fear-based security theatre |

**Sample thought-lines (not final copy):** *"One ledger. Every balance."* · *"See who owes what — then settle."* · *"Your splits. Your numbers. Your call."*

---

## Off-landing tone (legal, auth, app)

Marketing story ends at Scene 09. Other pages = **same book, quieter chapter**:

| Page class | Emotion | Rule |
|------------|---------|------|
| Legal (privacy, terms) | Steady ground | No motion theatre; typography + clarity |
| Auth (login, register) | Ownership | User enters their ledger — not a form in a void |
| App surfaces (read-only) | Command | Balances first; blocked writes → install without breaking control feeling |
| 404 | Calm redirect | One line + path home — no joke pages |

---

## Interaction Philosophy

- Scroll = time travel through one continuous world
- Hover / cursor = optional depth on desktop (Linear-style), never required to understand
- Click = commitment — CTAs feel consequential, not noisy
- Auth / app routes = different chapter of same book (tone continuity)
- No scroll hijacking unless narrative earns it (pinned scenes max ~2–3 on landing)

---

## Things To Avoid

- Large centred headline + lone button hero
- Three equal feature cards in a row
- Random floating phone with no scroll purpose
- Pricing immediately after hero
- Fake testimonials or user counts
- Fade-in / slide-up section reveals
- Repeated card grid layouts
- Generic gradient blob with no product meaning
- Competitor mockery
- Dark-pattern Pro upsell

---

## Experience QA bar (creative approval)

Minimum to pass **memorability + distinctiveness** tests (`experience-review.md`):

| Gate | Creative requirement |
|------|---------------------|
| Hero | Pinned 01+02 scrub live — loss of control visible at 50–85% |
| Arc | Visitor can name emotion shift: confusion → clarity → ownership |
| Motion | Zero banned fade-in section reveals; accent path on at least one chapter |
| Trust | No emoji trust strip — authored iconography or product UI |
| Handoff | Scene N exit hook visible entering Scene N+1 |
| Recall | 3 standout moments identifiable in 24h debrief |

**Current shipped score:** 2.4/10 — rejected. Critical path: hero pin + Scene 03 mechanism.

### Post-session debrief script (Experience QA)

Ask within 24h of visit:

1. *"What word describes how the site felt?"* → Target: control / clarity / ledger
2. *"What stuck with you visually?"* → Target: numbers aligning, split moment, or install pulse
3. *"Could you tell who owes what from the story?"* → Target: yes, before reading features
4. *"Did it feel like every other fintech site?"* → Target: no

Pass: 3/4 aligned with control arc. Fail: generic SaaS or feature-list recall only.

---

## Success Metrics (creative, not analytics)

| Signal | Indicator |
|--------|-----------|
| Memorability | User says "control" / "I know who owes what" — not feature list |
| Non-template | Stakeholder cannot name which React template it resembles |
| Handoff clarity | Motion/UI/Dev agents quote scene emotion without asking |
| Scroll completion | `scroll_section_view` through compare + trust (analytics cross-ref §6.7) |
| Conversion quality | Install clicks from final CTA + post-trust, not bounce from hero |

---

## Creative Risks

| Risk | Mitigation |
|------|------------|
| Too artistic, unclear product | Scene 03 mechanism is non-negotiable clarity beat |
| Too literal, feels like Splitwise clone | Scene 02 + 04 emotional differentiation |
| Motion performance on mid Android browsers | Static poster frames; R3F lazy per motion-library |
| Product spec gaps (Scene 02) | Resolved — woven into F-L01 hero pin (option B) |
| Agent conflict (Product sections vs scenes) | This doc is emotional source of truth; Product §7 maps via scene table |

---

## Future Ideas (post-v1)

- Personalized scene entry by referrer (invite link → "your friend uses Splitr")
- Monthly recap share reader as marketing epilogue
- Seasonal story variant (trip season, festival splits)
- Web authenticated experience as "Scene 10 — Your Ledger"

---

## Validated Decisions

| Decision | Choice | Date |
|----------|--------|------|
| North star feeling | **Control** — "I finally know who owes what" | 2026-07-27 |
| Scene 02 placement | **B — hero combined pin** (0–35% arrival, 50–85% lost ledger) | 2026-07-27 |

---

## Working assumptions (pending user confirm)

| Topic | Draft assumption | Rationale |
|-------|------------------|-----------|
| Tone | **Premium-warm** — CRED restraint, not playful | Control axis; user pending |
| Comparison | **Clinical factual + bold visual** | User pending |

---

---

## Scene ↔ Product map (handoff)

| Scene | Name | Product §7 | Pin? |
|-------|------|------------|------|
| 01 | Arrival | F-L01 Hero | Yes (with 02) |
| 02 | Lost Ledger | F-L01 extension | Yes (with 01) |
| 03 | The Split | F-L08 How it works | Yes |
| 04 | Full Picture | F-L03 Features | No |
| 05 | Verdict | F-L04 Comparison | No |
| 06 | Fair Deal | F-L05 Pro pricing | No |
| 07 | Vault | F-L02 Trust | No |
| 08 | Last Question | F-L06 FAQ | No |
| 09 | Door | F-L07 Final CTA | No |

---

## Spec self-review (tick 8)

| Check | Result |
|-------|--------|
| Placeholders / TBD | None in scene list — tone assumptions marked pending |
| Internal consistency | Control axis threads 01→09; motion tokens aligned |
| Scope | Single landing story — legal/auth covered in off-landing tone |
| Ambiguity | Premium-warm vs playful; comparison boldness — user gate |

**Verdict:** Ready for user review. After tone locks → Storyboard 04–09 expansion is critical path.

### Implementation gap audit (tick 10 — `apps/web`)

| Creative requirement | Shipped state | Gap |
|---------------------|---------------|-----|
| Hero pin 01+02 (~2vh scrub) | `useHeroMotion` — clip-path on load only | **No ScrollTrigger pin** |
| Scene 02 lost ledger (50–85%) | Not present | **No chaos beat** |
| Scene 03 pin + grid snap | `useLandingScrollMotion` — section fades | **Not pinned mechanism** |
| Mask reveals (allowed) | Hero title/eyebrow clip-path | Partial ✓ |
| Banned fade-in sections | Landing sections still fade-up | **Violates motion language** |
| Memorable moment #1 (chaos drift) | Missing | **Not built** |
| Memorable moment #2 (grid snap) | Missing | **Not built** |

**Creative Director note:** Dev should treat `creative-direction.md` + `storyboard.md` Scenes 01–03 as build spec — not current `useLandingScrollMotion` fade patterns.

---

## Sync log (loop ticks)

| Tick | `storyboard.md` | `apps/web` hero pin | User tone input | Action |
|------|-----------------|---------------------|-----------------|--------|
| 8–10 | 04–09 Pending | Not built | Pending | Gap audit + handoff |
| 11 | No change | No change | Pending | **No doc delta** — skip repeat audits until movement |
| 12 | No change | No change | Pending | **No doc delta** |
| 13 | No change | No change | Pending | Motion tick 10 — Scene 03 control; 04/09 DRAFT |
| 14 | No change | Partial (04 tilt) | Pending | Motion tick 11–17; B1 hero pin open |
| 15 | No change | No change | Pending | Motion tick 18 — F-L03 fracture bridge |
| 16 | No change | No change | Pending | Motion tick 19 — FAQ 08→09 handoff |
| 17 | No change | No change | Pending | Motion tick 20 — Scene 07 vault + build-ready index |
| 18 | No change | No change | Pending | Motion tick 21 — 04→05 handoff + F-L05 free-core |
| 19 | No change | No change | Pending | Motion tick 22 — 05→06 handoff |
| 20 | No change | No change | Pending | Motion tick 23 — auth formSwap |
| 21 | No change | No change | Pending | Motion tick 24 — intro wordmark stroke |
| 22 | No change | B1 spec only | Pending | Motion tick 25 — `useHeroScrollMotion` package |
| 23 | No change | Not wired | Pending | Motion tick 26 — Scene 02 chaos asset |
| 24 | No change | Not wired | Pending | No delta |
| 25 | No change | Not wired | Pending | Motion tick 28 maintenance |
| 26 | No change | Not wired | Pending | 3rd idle tick |
| 27 | No change | Not wired | Pending | Motion 30-tick milestone |
| 28–30 | No change | Not wired | Pending | **Creative Director 30-tick milestone** — spec frozen; dev B1 is gate |

**Loop policy (tick 11+):** Only update when storyboard, motion-library, `apps/web`, or user validates tone/comparison.

---

## Agent Handoff (tick 14)

| Agent | Status | Next action |
|-------|--------|-------------|
| **Motion** | Tick 17 — extensive specs | Scene 02 → Lost Ledger rename still open |
| **Developer** | Partial | **B1 hero pin** still top blocker; 04 tilt shipped |
| **Storyboard** | Stalled tick 1 | 04–09 narrative specs still Pending |
| **User** | Blocking | Tone A/B + comparison |

**Tick 14 note:** Motion + code moving on Scenes 04–09 periphery; **control arc core (01–03 pin) still unbuilt**.

---

## Open Questions (for user)

1. **Premium-warm vs playful-warm** — draft: premium-warm. Override?
2. **Scene 02 placement** — ~~draft: B~~ **validated**
3. **Comparison tone** — draft: clinical factual + bold visual. Override?

---

## Changelog

| Date | Tick | Change |
|------|------|--------|
| 2026-07-27 | — | **Loop stopped** by user (PID 33752 killed) |
| 2026-07-27 | 30 | Creative Director 30-tick milestone; no movement |
| 2026-07-27 | 29 | No delta (idle) |
| 2026-07-27 | 28 | No delta |
| 2026-07-27 | 27 | Motion 30-tick milestone; no code/storyboard movement |
| 2026-07-27 | 26 | No delta (motion tick 29 maintenance) |
| 2026-07-27 | 25 | No delta (motion tick 28 maintenance) |
| 2026-07-27 | 24 | No delta (motion tick 27 maintenance) |
| 2026-07-27 | 23 | Motion tick 26 — Scene 02 chaos asset brief |
| 2026-07-27 | 22 | Motion tick 25 — B1 hero pin implementation package ready; code not wired |
| 2026-07-27 | 21 | Motion tick 24 — intro wordmark stroke spec |
| 2026-07-27 | 20 | Motion tick 23 — auth formSwap spec (off-landing tone) |
| 2026-07-27 | 19 | Motion tick 22 — Scene 05→06 handoff spec |
| 2026-07-27 | 18 | Motion tick 21 — Scene 04→05 handoff + Pro free-core spec |
| 2026-07-27 | 17 | Motion tick 20 — Scene 07 vault spec + build-ready index |
| 2026-07-27 | 16 | Motion tick 19 noted; no other delta |
| 2026-07-27 | 15 | Motion tick 18 noted; no other delta |
| 2026-07-27 | 14 | Motion tick 11–17 + partial code sync; hero pin still P0 |
| 2026-07-27 | 13 | Motion-library tick 10 sync noted; Scene 02 rename gap flagged |
| 2026-07-27 | 12 | Sync check — no delta (maintenance) |
| 2026-07-27 | 11 | Sync check — no delta; loop maintenance policy |
| 2026-07-27 | 10 | Implementation gap audit (`apps/web` vs creative spec) |
| 2026-07-27 | 9 | Executive digest; Experience QA debrief script |
| 2026-07-27 | 8 | Spec self-review; scene↔product map; storyboard 04–09 flagged critical |
| 2026-07-27 | 7 | Scenes 04–09 storyboard briefs; fixed Scene 04 header; handoff cleanup |
| 2026-07-27 | 6 | Memorable moments map; India scenario bank; draft-complete status |
| 2026-07-27 | 5 | Scene 03 critical path; voice/off-landing tone; Scene 02 B validated |
| 2026-07-27 | 4 | QA approval bar; comparison brief; scenes 06–08 control align; working assumptions |
| 2026-07-27 | 3 | Control pacing map + scroll hooks; motion emotion table; handoff tick 3 |
| 2026-07-27 | 2 | Loop sync: hero pin provisional B; agent handoff table; downstream gap flags |
| 2026-07-27 | 1 | North star locked: **Control**; persona → Ledger Keeper; scenes reframed |
| 2026-07-27 | 0 | Foundation: vision, persona, 9 scenes, principles, gaps flagged |
