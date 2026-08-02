# Monthly Recap — Feature Spec v2 (Redesign)

**Status:** Redesign approved 2026-07-27 — **do not mark `implemented` until product + data audit passes.**  
**Prior v1:** Shipped but failed product audit (income as spend, cluttered UI, wrong share strategy).  
**Code anchor:** `apps/mobile/lib/Screen/ProfileScreen/monthly_recap_screen.dart` (~4,300 lines — **needs decomposition**).  
**Story export:** Share Pack only — 1080×1920 (9:16), safe zone Y 250–1670.  
**Month scope:** **Current calendar month only** — no history picker, no chevrons.

---

## Product audit (why v2)

| Failure | Evidence | Root cause |
| ------- | -------- | ---------- |
| Income shown as spend | “Salary” top category, ₹81,768 “TOTAL SPENT”, +2386% MoM | `getMonthlySpendAnalytics(..., personalDebitsOnly: false)` includes `salary` / `income` credits |
| Wrong share hook | Finale: “This month I spent ₹81,768” | Share card uses polluted `totalSpent` |
| Debt on social path | Lending slide ₹158k outstanding | Lending in swipe story + no share lane split |
| Clutter | 9+ beats, 3 font families, nested stat cards | Too many metrics per slide; v1 scope too wide |
| Mislabeled transactions | “Settlement payment” as biggest payment | Settlement / internal categories in expense highlights |
| Broken motion | Mirrored text on biggest-payment flip | `RecapFlipReveal` transform on readable text |
| Off-brand copy | “Better experiences, better rewards…” | Residual CRED-style strings |

**User-approved direction:** Show impressive stats with **correct labels**. Private lane = full picture. Share Pack = **praise + FOMO only** (no income, no debt, no raw spend totals by default).

---

## Confirmed product decisions (2026-07-27)

| Topic | Decision |
| ----- | -------- |
| **Lanes** | **Private story** (swipe in-app) + **Share Pack** (4 curated cards, export-only) |
| **Architecture** | **Tagged slides** (`lane: private \| share \| both`) — one payload, two render paths |
| **Private beats (max 7)** | Intro → Spend hero → Top category → Habit → Group social → Goals → Persona |
| **Share Pack (max 4)** | Persona → Settlements closed count → Spend personality (no ₹) → Goal momentum (% only) |
| **Removed** | Lending slide, biggest payment slide, month picker / history |
| **Settlement share line** | “{N} settlements closed this month” (skip beat if N = 0) |
| **Motion** | CRED bar: slow ease-out, one reveal per beat, mesh parallax, elastic ticks — no flip mirrors on text |
| **Month** | Current month only |

---

## Implementation status values

| Status | Meaning |
| ------ | ------- |
| `pending` | Not built to v2 spec. |
| `resolve-issue` | v1 code exists but fails v2 metrics, labels, motion, or lane rules. |
| `implemented` | Developer verified against v2 acceptance criteria. |
| `removed` | Deliberately dropped from v2 scope. |

`issue details` required for `resolve-issue`.

### Status summary (2026-07-27 redesign)

| Status | Features |
| ------ | -------- |
| `resolve-issue` | 1, 2, 3, 4, 5, 7, 9, 10, 11, 12, 13, 14 |
| `removed` | 6, 8 |
| `pending` | — |

---

## Design principles (v2)

| Principle | Rationale |
| --------- | --------- |
| **Two lanes** | Private = accuracy + detail. Share = identity + praise. Never the same card. |
| **One hero per beat** | Robinhood / CRED: one number or one label per screen. |
| **Correct vocabulary** | “Spent” = expenses only. Income never in spend aggregates. Settlements ≠ expenses. |
| **Share = boast, not bank statement** | Wrapped posts persona + discipline — not salary or debt. |
| **Skip empty beats** | No zero-state slides; dynamic story length. |
| **NeoPOP discipline** | Dark mesh, Albra headlines, **one** secondary font (Poppins labels). Drop Courier overload on every line. |
| **Slow CRED motion** | 800–1200ms ease-out; stagger via `Interval` on one controller per slide. |
| **Splitr edge** | Groups, settlements, split buddies — metrics Mint cannot show. |

---

## Architecture

### Lane model (approach A — tagged slides)

```
MonthlyRecapPayload
  ├── privateSlides[]   // StoryView swipe order (max 7 + intro)
  └── sharePackCards[]  // Fixed 4 cards — export + preview only

Each beat: { id, lane, metrics, skipIf, layoutVariant }
```

- **Private:** `MonthlyRecapStoryHost` — user swipes 7 beats max.
- **Share:** “Share Recap” opens **Share Pack preview** (horizontal pager or 2×2 grid) — **not** a copy of the full story.
- **Export:** `RecapShareExporter` renders **Share Pack cards only** (story PNG per card or single composite). Default copy never says “I spent ₹X”.

### Data rules (hard)

1. **Expense total** — personal debits + group expense shares; **exclude** `kPersonalIncomeCategories` (`income`, `salary`, `refund`, `cashback`, `reimbursement`) and `CategoryDefaults.settlement`.
2. **Top category** — highest **expense** category only; never income categories.
3. **MoM trend** — compare expense totals month-over-month (same filters).
4. **Settlements closed** — count settlement-category group transactions in month (for Share Pack beat).
5. **Goals on share** — `%` or “Goal hit” only; no ₹ contributed on export.
6. **Persona on share** — title + badge name only; optional stat labels without amounts.
7. **Implementation fix:** All recap queries use `personalDebitsOnly: true` or explicit income exclusion in `getSpendAnalytics`.

```dart
// transaction_service.dart — recap must call:
getSpendAnalytics(..., personalDebitsOnly: true)
// NOT personalDebitsOnly: false (v1 bug)
```

---

## UI layout rules (Section 2)

### Per-slide layout (private)

| Zone | Content | Max elements |
| ---- | ------- | ------------ |
| Header | `Splitr.` + close (X). **No month chevrons.** | 2 |
| Title | One headline (Albra). Optional one accent word (mint). | 1 line + sub |
| Hero | **One** primary metric OR one chart | 1 |
| Support | Up to **2** small glass chips — not 4-up grids | 2 |
| Footer | Optional one-line insight (Poppins caption) | 1 |

**Banned on private slides:** nested cards inside cards, 4-stat grids, duplicate trend + category bars on same beat, CRED marketing quotes.

### Share Pack card layout

| Card | Hero | Subtext | Never show |
| ---- | ---- | ------- | ---------- |
| Persona | Persona title + badge | One praise line | ₹ amounts |
| Settlements | “{N} settlements closed” | “This month on Splitr” | Open balances |
| Spend personality | Top **spend** category name + habit label | e.g. “Weekend Splurger” | ₹, % of wallet |
| Goal momentum | Ring at % or “Goal hit” | Goal name (short) | ₹ contributed |

**Share card footer:** `Powered by Splitr` + QR / `#SplitrApp` — no user spend total.

### Typography (v2)

- **Headlines:** Albra only.
- **Labels / captions:** Poppins (`splitrFontCaption`).
- **Micro IDs:** Poppins — **not** Courier on every stat (Courier only for optional ledger-style accents if needed).
- **Numbers:** Albra for hero amounts (private spend hero only).

### Safe zone

Story export 1080×1920; keep hero text inside Y 250–1670. Share Pack preview matches export layout 1:1.

---

## Motion spec (CRED bar)

| Element | Duration | Curve | Notes |
| ------- | -------- | ----- | ----- |
| Slide enter | 300ms | `AppMotion.nav` | Story horizontal |
| Mesh parallax | continuous | slow drift | ±8px on slide change |
| Hero reveal | 900–1200ms | `Curves.easeOutCubic` | one element per beat |
| Stagger children | 80ms | `Interval` on parent controller | max 3 children |
| Count-up | 1000ms | easeOutCubic | **private spend hero only** |
| Badge Lottie | ≤1.2s | once | persona share card |
| Elastic tick | 1500ms | `Curves.elasticOut` | settlement / goal hit |
| CTA pulse | 1.5s loop | small scale | Share Recap button only |

**Banned:** `RecapFlipReveal` on readable text; mirror transforms; simultaneous 5+ animations per slide.

**Haptics:** light on hero land; medium on badge unlock only.

---

## Private story — slide order

| # | Beat | Skip when | Lane tag |
| - | ---- | --------- | -------- |
| 1 | Intro — name + “Your {Month} Recap” | never | `private` |
| 2 | Spend hero — **total expenses** + MoM % | `expenseTotal == 0` → soft empty state | `private` |
| 3 | Top spend category — name + % of expenses | no expense categories | `private` |
| 4 | Habit — weekday pattern label | `< 5` expense txns in month | `private` |
| 5 | Group social — groups + top buddy | no group activity | `private` |
| 6 | Goals — ring, ₹ contributed OK here | no goals activity | `private` |
| 7 | Persona + monthly badge | never (fallback Quiet Month) | `both` |
| — | Finale CTA — “Share Recap” opens Share Pack preview | never | `private` |

**Removed from private:** biggest payment (F6), lending (F8), month picker, multi-card trend dumps on spend hero.

---

## Share Pack — card order

| # | Beat | Skip when |
| - | ---- | --------- |
| 1 | Persona + badge | never |
| 2 | Settlements closed count | `settlementsClosed == 0` |
| 3 | Spend personality — category name + habit label | no expense data |
| 4 | Goal momentum — % or hit | no goals activity |

Export: story PNG per card or user picks one card; square crop optional. Web link payload: persona, habit label, goal highlight name — **no `totalSpent`**.

---

## Feature 1 — Story shell

**Implementation status** — `resolve-issue`

**Issue details** — v1 has month chevrons + 10+ beats. v2: current month only, max 7 private beats, progress segments match dynamic count. Remove header clutter (back + X redundancy).

**Acceptance** — Story segments = active private beats; no month nav; tap zones work; intro auto-advance once (F13) unchanged.

---

## Feature 2 — Intro reveal

**Implementation status** — `resolve-issue`

**Issue details** — v1 tease card previews polluted `totalSpent` on intro. v2: intro **no money teaser** — name + month + subtitle only. CRED slow stagger reveal.

---

## Feature 3 — Spend hero (expenses only)

**Implementation status** — `resolve-issue`

**Issue details** — **P0 data bug:** income in spend total. v2: label “Total spent” = expenses only; MoM on same basis. One hero number + one MoM pill + optional sparkline — **no** nested trend card on same slide.

**Acceptance** — User with salary logged: spend hero ≠ salary amount; top category ≠ Salary.

---

## Feature 4 — Top spend category

**Implementation status** — `resolve-issue`

**Issue details** — v1 showed Salary as favourite category. v2: expense categories only; one donut or bar; dynamic quip; no static `#1` badge.

---

## Feature 5 — Spending habit

**Implementation status** — `resolve-issue`

**Issue details** — v1 hardcoded Weekend Warrior; cluttered trend section. v2: computed habit from weekday pattern; one chart OR one insight — not both full-width.

---

## Feature 6 — Biggest payment

**Implementation status** — `removed`

**Reason** — Settlement payments mislabeled; flip animation broke text; not in v2 private lineup.

---

## Feature 7 — Group & split social

**Implementation status** — `resolve-issue`

**Issue details** — Private only (not in Share Pack). v2: groups count, top group, top buddy name, payer ratio — **private lane can show ₹** for group context. Share lane uses settlement count beat separately.

---

## Feature 8 — Lending pulse

**Implementation status** — `removed`

**Reason** — User decision: loans stay in Lending tab; debt inappropriate for recap story.

---

## Feature 9 — Goals momentum

**Implementation status** — `resolve-issue`

**Issue details** — Private: ring + ₹ contributed OK. Share Pack variant: % only, confetti on hit. Split layouts by `lane`.

---

## Feature 10 — Persona + badge

**Implementation status** — `resolve-issue`

**Issue details** — v2: `RecapGlitchReveal` OK on persona title; two layouts — full stats private, title+badge share. PersonaEngine unchanged; share gradient via `RecapPersonaTheme`.

---

## Feature 11 — Share Pack + export

**Implementation status** — `resolve-issue`

**Issue details** — v1 exported “spent ₹X” finale. v2: Share Pack preview sheet; 4 praise cards; default export copy **never** total spend; optional opt-in “include my spend” toggle (default off). Square + story PNG + web link. Web reader: persona/habit/goal — no amount fields.

**Acceptance** — Default share text is boast-friendly, not bank statement.

---

## Feature 12 — MonthlyRecapAggregator (data layer)

**Implementation status** — `resolve-issue`

**Issue details** — v1 `personalDebitsOnly: false`. v2 payload adds: `expenseTotal`, `expenseByCategory`, `settlementsClosedCount`, `habitType`, lane-tagged slide list, `sharePackCards`. Tests: salary month → `expenseTotal` excludes salary; `topCategory` ≠ Salary.

---

## Feature 13 — Discovery drop

**Implementation status** — `resolve-issue`

**Issue details** — Drop promo opens **current month** recap only. Revisit copy: “Your month so far” vs “January recap ready”. Keep shimmer, dot, push, intro auto-advance.

---

## Feature 14 — Theme + de-clutter

**Implementation status** — `resolve-issue`

**Issue details** — Reduce `monthly_recap_screen.dart` into slide widgets; one scaffold; remove light `#FAFAFA` slides; remove CRED copy; max 2 glass chips per slide.

---

## Implementation priority (v2)

1. **P0 — Data:** F12 expense-only analytics + tests (unblocks F3, F4, F11).
2. **P0 — Lanes:** F11 Share Pack preview + export copy; strip spend from default share.
3. **P1 — Private slides:** F2–F5, F7, F9, F10 — simplify layout per UI rules.
4. **P1 — Shell:** F1 remove month picker; dynamic beat count.
5. **P2 — Polish:** F13 discovery copy; F14 file split; motion pass CRED bar.
6. **P2 — Delete:** F6, F8 code paths from story builder.

---

## Dependencies & risks

| Risk | Mitigation |
| ---- | ---------- |
| Income misclassification persists | Unit tests with salary txn fixtures; gate recap on `personalDebitsOnly: true` |
| Share still leaks amounts | Share Pack renderer separate widget; no reuse of private spend hero |
| 4300-line screen | Split into `slides/private/`, `slides/share_pack/`, thin orchestrator |
| Low activity month | Skip beats; persona fallback; Share Pack may be 2–3 cards |

---

## References

- CRED NeoPOP motion: slow ease-out, one focus per screen — [cred.club/design](https://cred.club/design)
- Robinhood: haptic + celebration on wins, not balances — GoodUX haptic case study
- Spotify Wrapped: identity labels drive shares, not transaction dumps
- Splitr: `kPersonalIncomeCategories` in `constants.dart`; `getSpendAnalytics` in `transaction_service.dart`

---

## Changelog

| Date | Change |
| ---- | ------ |
| 2026-07-26 | v1 spec — 14 features shipped; later marked all `implemented` |
| 2026-07-27 | **v2 redesign** — product audit; two-lane model; expense-only data rules; F6/F8 removed; all active features → `resolve-issue`; user decisions from brainstorming session |
