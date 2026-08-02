# Splitr landing comparison table redesign

**Date:** 2026-08-02  
**Status:** Approved  
**Scope:** Marketing landing `#compare` section only (`ComparisonTable`)  
**Approach:** Restyle in place (Cashify-like structure × Splitr dark theme)

## Goal

After the phone tour, the comparison section must do both:

1. **Switcher proof** — why leave Splitwise (esp. India / free-tier friction)
2. **Unique stack** — personal finance, lending, goals — not “just another split app”

Visual model: Cashifybot-style elevated comparison card (logos, highlighted own column, clear grid) adapted to Splitr tokens — not a light SaaS clone.

## Decisions (locked)

| Decision | Choice |
|----------|--------|
| Section job | Both switcher + unique features |
| Columns | Splitr · Splitwise · Splitkaro (3) |
| Cell style | Icon-first; optional one-line note under Splitr only |
| Rows | UPI · Personal finance · Lending · Goals · Free core (no caps) · OCR Pro |
| Visual shell | Dark elevated card + logos + accent column band |
| Implementation | Restyle existing `ComparisonTable` (not greenfield component) |

## Content

### Copy

- **Heading:** `How Splitr compares` (Albra / `--font-display`)
- **Sub:** `Factual comparison. Features checked against shipped Splitr and public competitor info.`
- No Cashify-style hype headline (“Your Best Choice…”). Stay clinical.

### Columns

1. **Splitr** — highlighted  
2. **Splitwise** — global switcher target  
3. **Splitkaro** — India rival with meaningful scale (vs BillSplit / BillSplitzer)

### Rows (icon-first)

| Feature | Splitr | Splitwise | Splitkaro | Splitr note (optional) |
|---------|--------|-----------|-----------|-------------------------|
| UPI settle-up | yes | varies | yes | “UPI-friendly settle” |
| Personal finance home | yes | partial | yes | — |
| P2P lending | yes | no | no | — |
| Financial goals | yes | no | no | — |
| Free core (no daily caps) | yes | no | yes | — |
| Receipt OCR (Pro) | yes | yes | no | “Pro” |

**Verification notes (2026-08-02):** Splitwise free has a documented daily expense limit ([Splitwise helpdesk](https://splitwise.uservoice.com/knowledgebase/articles/2010350-why-am-i-seeing-an-expense-limit)); Pro unlocks receipt scanning. Splitwise has no native UPI settle → `varies`. Splitkaro markets UPI add-from-apps, personal expense tracking, and unlimited expenses on free; no P2P lending product, no dedicated financial-goals product, no receipt OCR (auto-fetch ≠ OCR) → those cells `no`.

**Cell vocabulary:** `yes` (✓) · `no` (—) · `partial` (~) · `varies` (label “Varies”)

**Dropped vs current table:** BillSplit, BillSplitzer columns; Offline group reads row.

## Visual design

### Theme mapping (Cashify → Splitr)

| Cashify | Splitr |
|---------|--------|
| White raised card | `#1e1e1e` elevated card, `#323232` border, `--radius-lg` |
| Light page gray | Page stays `#0d0d0d` |
| Pale green own column | `--color-accent-fill-soft` + left bar `#18c595` |
| Green checks | Accent ✓ |
| Sans body | Poppins (`--font-body`) |
| Bold title | Albra H2 (`--font-display`) |

### Layout

- **Desktop (≥768):** Card wrapping a semantic `<table>`; header cells with circular logo mark + name; Splitr column band.
- **Mobile (&lt;768):** Hide wide table; stacked cards (Splitr first with accent border), same facts.
- **Logos:** Splitr brand mark; Splitwise / Splitkaro use letter or simple mark if licensed assets unavailable. Marks `aria-hidden` when name is visible in text.

### Motion

- **No scan bar** — remove enter scan line DOM, CSS, and animation.
- No checkmark scale-pop spam.
- Mobile only: optional light Splitr-card pulse (`useComparisonMotion`); desktop table static on enter.
- `prefers-reduced-motion`: static table/cards (no pulse).

### Out of scope

- Light theme
- Fake user counts / testimonials
- New pinned scroll chapter
- Changing tour → compare gap behavior (keep current unless card padding conflicts)

## Technical design

### Touchpoints

- [`apps/web/src/components/landing/ComparisonTable.tsx`](apps/web/src/components/landing/ComparisonTable.tsx) — data model, header logos, notes, mobile cards
- [`apps/web/src/components/landing/ComparisonTable.module.css`](apps/web/src/components/landing/ComparisonTable.module.css) — card, band, type, responsive
- [`apps/web/src/hooks/motion/useLandingScrollMotion.ts`](apps/web/src/hooks/motion/useLandingScrollMotion.ts) — `useComparisonMotion`: drop desktop scan/pop; keep mobile Splitr pulse only

### Data shape

```ts
type Cell = 'yes' | 'no' | 'partial' | 'varies'

type Column = {
  id: 'splitr' | 'splitwise' | 'splitkaro'
  name: string
  highlight?: boolean
}

type Row = {
  topic: string
  values: [Cell, Cell, Cell] // Splitr, Splitwise, Splitkaro
  splitrNote?: string
}
```

### Accessibility

- Desktop: real `<table>` with `scope`
- Mobile cards expose same information
- Icon cells keep `aria-label`
- Section retains `id="compare"` and labelled heading

### Verification gate (before merge)

Confirm against public sources:

1. Splitkaro — UPI, free tier / premium gates, lending, goals, OCR  
2. Splitwise — UPI availability, free daily caps, Pro OCR  

Update cells if claims are wrong.

### Acceptance

- [ ] 3 columns only: Splitr, Splitwise, Splitkaro  
- [ ] 6 rows as specified; Offline / BillSplit* gone  
- [ ] Dark elevated card; Splitr accent column; Albra/Poppins/tokens  
- [ ] Icon-first; Splitr notes only where defined  
- [ ] Mobile stacked cards work  
- [ ] No scan bar; reduced-motion OK (no pulse)  
- [ ] Competitor cells verified or marked conservative  
- [ ] No phone-tour overlap regression into `#compare`

## Non-goals

- Redesigning Pricing / FAQ / tour  
- Scene 03 rebuild  
- Competitor trademark-accurate logos if assets unavailable

## Open follow-ups (implementation, not design blockers)

- Letter-circle marks for Splitwise / Splitkaro (no licensed assets in repo)
