# Landing Comparison Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restyle the landing `#compare` section into a Cashify-like dark elevated comparison card with Splitr · Splitwise · Splitkaro columns, icon-first cells, and the locked feature matrix from the approved design spec.

**Architecture:** Keep `ComparisonTable` in place. Replace 4-column string arrays with typed `Column` / `Row` data (3 columns + optional `splitrNote`). Wrap the desktop table in an elevated card shell; add circular letter marks in headers/cards. Remove scan bar (DOM, CSS, animation) and checkmark scale-pop; keep mobile Splitr-card pulse only. No new packages; no unit-test harness in `apps/web` — verify with `tsc`/lint/build + visual checklist.

**Tech Stack:** React 19, CSS modules, existing GSAP `useComparisonMotion`, design tokens in `apps/web/src/styles/tokens.css`.

**Spec:** [docs/superpowers/specs/2026-08-02-landing-comparison-redesign-design.md](../specs/2026-08-02-landing-comparison-redesign-design.md)

---

## File map

| File | Role |
|------|------|
| `apps/web/src/components/landing/ComparisonTable.tsx` | Data model, logos, notes, table + mobile cards |
| `apps/web/src/components/landing/ComparisonTable.module.css` | Elevated card, header marks, note under Splitr, band |
| `apps/web/src/hooks/motion/useLandingScrollMotion.ts` | `useComparisonMotion` — remove desktop scan + checkmark pop; keep mobile Splitr pulse |
| `HomePage.tsx` | No change (already renders `ComparisonTable`) |

---

### Task 1: Data model + columns + rows

**Files:**
- Modify: `apps/web/src/components/landing/ComparisonTable.tsx`

- [ ] **Step 1: Replace column/row data with locked matrix**

Replace the top of `ComparisonTable.tsx` (through `rows`) with:

```tsx
type Cell = 'yes' | 'no' | 'partial' | 'varies'

type Column = {
  id: 'splitr' | 'splitwise' | 'splitkaro'
  name: string
  mark: string
  highlight?: boolean
}

type Row = {
  topic: string
  values: [Cell, Cell, Cell]
  splitrNote?: string
}

const columns: Column[] = [
  { id: 'splitr', name: 'Splitr', mark: 'S', highlight: true },
  { id: 'splitwise', name: 'Splitwise', mark: 'W' },
  { id: 'splitkaro', name: 'Splitkaro', mark: 'K' },
]

const rows: Row[] = [
  {
    topic: 'UPI settle-up',
    values: ['yes', 'varies', 'yes'],
    splitrNote: 'UPI-friendly settle',
  },
  { topic: 'Personal finance home', values: ['yes', 'partial', 'yes'] },
  { topic: 'P2P lending', values: ['yes', 'no', 'no'] },
  { topic: 'Financial goals', values: ['yes', 'no', 'no'] },
  { topic: 'Free core (no daily caps)', values: ['yes', 'no', 'yes'] },
  {
    topic: 'Receipt OCR (Pro)',
    values: ['yes', 'yes', 'no'],
    splitrNote: 'Pro',
  },
]
```

Keep existing `CellMark` for now. Update JSX that maps `columns` so it uses `col.id` / `col.name` / `col.highlight` instead of string columns and `i === 0`. Example header cell:

```tsx
{columns.map((col) => (
  <th
    key={col.id}
    scope="col"
    className={col.highlight ? styles.splitrCol : undefined}
  >
    {col.name}
  </th>
))}
```

And body cells:

```tsx
{row.values.map((val, i) => (
  <td
    key={columns[i].id}
    className={columns[i].highlight ? styles.splitrCol : undefined}
  >
    <CellMark value={val} />
  </td>
))}
```

Mobile cards: map `columns` with `col.highlight` → `styles.cardSplitr`; `data-motion-splitr-card` when `col.highlight`.

Update the note paragraph to:

```tsx
<p className={styles.note}>
  Factual comparison. Features checked against shipped Splitr and public competitor info.
</p>
```

- [ ] **Step 2: Typecheck**

Run from `apps/web`:

```bash
npx tsc -b --pretty false
```

Expected: exit 0 (or only pre-existing unrelated errors — fix any new errors in this file).

- [ ] **Step 3: Commit** (only if user asked for commits this session)

```bash
git add apps/web/src/components/landing/ComparisonTable.tsx
git commit -m "$(cat <<'EOF'
refactor(web): lock comparison columns to Splitr Splitwise Splitkaro

EOF
)"
```

---

### Task 2: Header marks + Splitr notes in markup

**Files:**
- Modify: `apps/web/src/components/landing/ComparisonTable.tsx`

- [ ] **Step 1: Add `ColumnMark` helper and wire header + cards**

Add above `ComparisonTable`:

```tsx
function ColumnMark({ mark, highlight }: { mark: string; highlight?: boolean }) {
  return (
    <span
      className={`${styles.colMark} ${highlight ? styles.colMarkSplitr : ''}`}
      aria-hidden="true"
    >
      {mark}
    </span>
  )
}
```

Header content becomes mark + name:

```tsx
<th
  key={col.id}
  scope="col"
  className={col.highlight ? styles.splitrCol : undefined}
>
  <span className={styles.colHead}>
    <ColumnMark mark={col.mark} highlight={col.highlight} />
    <span>{col.name}</span>
  </span>
</th>
```

In Splitr column cells only, when `row.splitrNote` and `columns[i].highlight`:

```tsx
<td
  key={columns[i].id}
  className={columns[i].highlight ? styles.splitrCol : undefined}
>
  <div className={styles.cellStack}>
    <CellMark value={val} />
    {columns[i].highlight && row.splitrNote ? (
      <span className={styles.splitrNote}>{row.splitrNote}</span>
    ) : null}
  </div>
</td>
```

Mobile card title:

```tsx
<h3 className={styles.cardTitle}>
  <ColumnMark mark={col.mark} highlight={col.highlight} />
  <span>{col.name}</span>
</h3>
```

Mobile Splitr list rows: under the mark when `col.highlight && row.splitrNote`, show the same muted note (small text under topic or under mark — prefer under the `CellMark` in a stacked right side).

- [ ] **Step 2: Typecheck again**

```bash
npx tsc -b --pretty false
```

Expected: exit 0 for ComparisonTable changes.

- [ ] **Step 3: Commit** (if user asked)

```bash
git add apps/web/src/components/landing/ComparisonTable.tsx
git commit -m "$(cat <<'EOF'
feat(web): add comparison column marks and Splitr cell notes

EOF
)"
```

---

### Task 3: Elevated card CSS shell

**Files:**
- Modify: `apps/web/src/components/landing/ComparisonTable.module.css`
- Modify: `apps/web/src/components/landing/ComparisonTable.tsx` (wrap table)

- [ ] **Step 1: Wrap desktop table in card**

In `ComparisonTable.tsx`, change the table wrap to:

```tsx
<div className={styles.tableWrap} data-motion-table>
  <div className={styles.cardShell}>
    <table className={styles.table}>{/* unchanged thead/tbody */}</table>
  </div>
</div>
```

Do **not** render `styles.scanLine` / `data-motion-scan`.
- [ ] **Step 2: Add CSS for shell, marks, notes**

Append / update in `ComparisonTable.module.css` (keep existing section pull-up / z-index rules intact — do not remove the `@media (min-width: 1024px)` negative margin):

```css
.cardShell {
  position: relative;
  background: var(--color-surface-elevated);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  overflow: hidden;
}

.colHead,
.cardTitle {
  display: inline-flex;
  align-items: center;
  gap: 10px;
}

.colMark {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  border-radius: 50%;
  border: 1px solid var(--color-border);
  background: color-mix(in srgb, var(--color-surface) 40%, transparent);
  font-family: var(--font-body);
  font-size: 12px;
  font-weight: 600;
  color: var(--color-text-muted);
  flex-shrink: 0;
}

.colMarkSplitr {
  border-color: var(--color-accent);
  background: var(--color-accent-fill-soft);
  color: var(--color-accent);
}

.cellStack {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}

.splitrNote {
  font-size: 11px;
  font-weight: 400;
  color: var(--color-text-muted);
  line-height: 1.2;
}

.splitrCol {
  background: var(--color-accent-fill-soft);
  border-left: 3px solid var(--color-accent);
}

.yes {
  color: var(--color-accent);
  font-weight: 700;
}

.card {
  padding: 20px;
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  background: var(--color-surface-elevated);
}

.cardSplitr {
  border-color: var(--color-accent);
  background: var(--color-accent-fill-soft);
}

.cardTitle {
  margin: 0 0 12px;
  font-family: var(--font-display);
  font-size: 1.125rem;
  font-weight: 600;
}
```

Also ensure `.table` sits cleanly inside the shell (no extra outer border required).

Delete the entire `.scanLine` rule block from this CSS file (no leftover scan bar styles).

- [ ] **Step 3: Visual check**

```bash
npm run dev
```

Open `/#compare` at ≥768px and &lt;768px. Confirm: elevated card, accent Splitr band, marks, notes only on Splitr UPI + OCR rows, 3 columns, no BillSplit*, no Offline row.

- [ ] **Step 4: Commit** (if user asked)

```bash
git add apps/web/src/components/landing/ComparisonTable.tsx apps/web/src/components/landing/ComparisonTable.module.css
git commit -m "$(cat <<'EOF'
style(web): elevate comparison table card and accent column

EOF
)"
```

---

### Task 4: Remove scan bar and desktop enter motion

**Files:**
- Modify: `apps/web/src/hooks/motion/useLandingScrollMotion.ts` (`useComparisonMotion`)
- Modify: `apps/web/src/components/landing/ComparisonTable.tsx` (ensure no scan DOM — if still present after Task 3)
- Modify: `apps/web/src/components/landing/ComparisonTable.module.css` (delete `.scanLine` if still present)

- [ ] **Step 1: Strip desktop scan + checkmark animation from the hook**

Replace `useComparisonMotion` body so desktop does nothing; mobile keeps Splitr-card pulse:

```tsx
export function useComparisonMotion(sectionRef: RefObject<HTMLElement | null>): void {
  const reduced = useReducedMotion()

  useMotionEffect(
    reduced,
    (ctx) => {
      const sectionEl = sectionRef.current
      if (!sectionEl) return
      if (isDesktopMotion()) return

      const splitrCard = sectionEl.querySelector<HTMLElement>('[data-motion-splitr-card]')
      if (!splitrCard) return
      const { gsap } = ctx

      ctx.track(
        ctx.ScrollTrigger.create({
          trigger: splitrCard,
          start: 'top 80%',
          once: true,
          onEnter: () => {
            gsap.fromTo(
              splitrCard,
              { boxShadow: '0 0 0 0 color-mix(in srgb, var(--color-accent) 0%, transparent)' },
              {
                boxShadow: '0 0 0 4px color-mix(in srgb, var(--color-accent) 35%, transparent)',
                duration: 0.4,
                yoyo: true,
                repeat: 1,
              },
            )
          },
        }),
      )
    },
    [sectionRef],
  )
}
```

- [ ] **Step 2: Confirm scan markup/CSS gone**

In `ComparisonTable.tsx`: no `data-motion-scan`, no `styles.scanLine`.

In `ComparisonTable.module.css`: no `.scanLine` rule.

Optional: drop `comparison-yes` class from `CellMark` (unused after motion removal).

- [ ] **Step 3: Typecheck**

```bash
npx tsc -b --pretty false
```

- [ ] **Step 4: Commit** (if user asked)

```bash
git add apps/web/src/hooks/motion/useLandingScrollMotion.ts \
  apps/web/src/components/landing/ComparisonTable.tsx \
  apps/web/src/components/landing/ComparisonTable.module.css
git commit -m "$(cat <<'EOF'
refactor(web): remove comparison scan bar and desktop enter motion

EOF
)"
```

---

### Task 5: Acceptance pass

**Files:** none (verify only)

- [ ] **Step 1: Lint + production build**

From `apps/web`:

```bash
npm run lint
npm run build
```

Expected: lint clean for touched files; build succeeds.

- [ ] **Step 2: Manual acceptance checklist**

- [ ] 3 columns only: Splitr, Splitwise, Splitkaro  
- [ ] 6 rows: UPI, personal finance, lending, goals, free core, OCR Pro  
- [ ] Offline / BillSplit / BillSplitzer gone  
- [ ] Dark elevated `#1e1e1e` card; Splitr accent band; Albra heading / Poppins body  
- [ ] Icon-first; Splitr notes only on UPI + OCR  
- [ ] Mobile stacked cards; Splitr first with accent  
- [ ] No scan bar on desktop; no checkmark pop; reduced-motion → no mobile pulse  
- [ ] Tour → `#compare` pull-up / z-index still OK (no phone over table)

- [ ] **Step 3: Final commit** (if user asked)

```bash
git add apps/web/src/components/landing/ComparisonTable.tsx \
  apps/web/src/components/landing/ComparisonTable.module.css \
  apps/web/src/hooks/motion/useLandingScrollMotion.ts \
  docs/superpowers/specs/2026-08-02-landing-comparison-redesign-design.md \
  docs/superpowers/plans/2026-08-02-landing-comparison-redesign.md
git commit -m "$(cat <<'EOF'
feat(web): ship Cashify-style landing comparison redesign

EOF
)"
```

---

## Spec coverage self-check

| Spec requirement | Task |
|------------------|------|
| 3 columns Splitr/Splitwise/Splitkaro | 1 |
| 6 rows + verified cells | 1 |
| Heading + factual sub | 1 |
| Icon-first + Splitr notes | 2 |
| Elevated card + accent band + logos | 2–3 |
| Mobile cards | 1–3 (existing structure restyled) |
| No scan bar; no desktop enter motion; mobile pulse only | 4 |
| A11y table + aria-labels | preserved in 1–2 |
| Tour overlap regression check | 5 |
| No new packages / greenfield component | all |

No placeholders left in tasks. No test runner in `apps/web` — verification is tsc/lint/build + checklist.
