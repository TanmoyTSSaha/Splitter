# SplitO — Product Enhancement & Differentiation Strategy

> A research-backed plan to make **SplitO** stand out in the expense-splitting segment, benchmarked against Splitwise, Tricount, Settle Up, Splid, SplitterUp, KipEven, and inspired by the design philosophy of CRED.

---

## 1. The Opportunity: Why Now?

Splitwise — the segment leader — has alienated a massive user base with aggressive paywalling (3–5 free entries/day), unskippable 10-second ads, and a ₹2,999/yr subscription for features that were once free. Reddit threads are flooded with users actively seeking alternatives.

**SplitO's window**: Ship a polished, generous free-tier app with premium UX and features that Splitwise charges for. Think of it as the "Telegram moment" for expense splitting.

| Splitwise Pain Point (Source: Reddit 2025) | SplitO's Answer |
|---|---|
| Daily transaction limits on free tier | **Unlimited free transactions** |
| Unskippable ads before every expense | **No ads, ever** (monetize differently) |
| Clunky multi-currency handling | **Smart currency engine** with auto-conversion |
| No item-level bill splitting | **AI-powered receipt scanner** with per-item assignment |
| Basic, dated UI | **CRED-grade NeoPop dark UI** with micro-animations |
| No offline mode | **Offline-first architecture** with background sync |

---

## 2. UX & Visual Identity — Standing Out at First Glance

### 2.1 Evolve the NeoPop Design Language
**Current state**: The app uses NeoPop buttons and a dark palette (`#0D0D0D` bg, `#FE885D` primary, `#18C595` accent). This is a strong foundation — but competitors are catching up on dark mode.

**Enhancements** (based on 2025 mobile design trends):

| Enhancement | Rationale | Implementation |
|---|---|---|
| **Glassmorphism card layers** | Creates visual depth; see CRED's Copper-era frosted panels. No competitor in this segment uses it. | Use `BackdropFilter` with `ImageFilter.blur(sigmaX: 15, sigmaY: 15)` on group/transaction cards over a gradient mesh background |
| **Ambient gradient mesh backgrounds** | Apple, Linear, and CRED use mesh gradients for premium feel. Static dark bg feels flat. | Animated gradient meshes on home/group screens using a `CustomPainter` or `shader_mask` |
| **Haptic typography hierarchy** | Albra serif for headlines + Poppins for body is good. Add weight-based hierarchy with letter-spacing refinements. | Refine `constants.dart` typography: tighter letter-spacing on headlines (-0.5px), loose on captions (+0.3px) |
| **Contextual micro-animations** | CRED's "Form is Function" philosophy — every interaction should have motion feedback. | Staggered list animations on transaction feeds, spring-physics pull-to-refresh, Lottie success/error states |
| **Avatar system with AI-generated identicons** | Current avatars use generic URLs. Unique per-user visual identities increase social trust. | Generate deterministic gradient avatars from user IDs (no external URL dependency) |

### 2.2 Signature Interaction: The "Swipe to Settle" Gesture
No competitor has a gesture-based settlement flow. CRED's swipe-to-pay is its most iconic interaction.

- Build a custom `GestureDetector` with haptic feedback + confetti animation on swipe completion
- The gesture should feel *heavy* and *intentional* — spring physics with overshoot damping
- This becomes SplitO's brand signature (like Tinder's swipe)

### 2.3 Onboarding Experience
**Current state**: Session-based routing dumps users into login. No onboarding.

- **3-screen animated onboarding** with parallax illustrations showing: (1) Add expense → (2) Split instantly → (3) Settle with a swipe
- Skip for returning users via session check (already in place)
- Social proof: "Join 10,000+ groups splitting smarter" (even if aspirational early on)

---

## 3. Core Feature Gaps — Complete What's Built

These are features already stubbed or partially built in the codebase. Completing them is the highest-ROI work.

### 3.1 Complete Splitting Modes
**Current state**: `SharingMode` enum has `byPercentage` and `byShares`, but only even/uneven tabs are implemented.

| Mode | UX Approach | Priority |
|---|---|---|
| **By Percentage** | Circular slider with real-time % labels per member. Total must lock to 100%. | 🔴 High |
| **By Shares** | Stepper widget per member (e.g., 2 shares, 1 share). Auto-calculate amounts. | 🔴 High |
| **By Item** (NEW) | Per-item assignment from a scanned or manual receipt. Most requested Splitwise feature. | 🟡 Medium |

### 3.2 Functional Settle-Up Flow
**Current state**: `settle_up_tab.dart` uses hardcoded mock data (`Deepesh Tyagi`, `Durgesh Kumar Singh`). No real settlement logic.

**Implementation**:
- Pull real balances from the `groups.group_balance` JSONB field
- **Debt simplification algorithm**: Minimize total number of transfers (e.g., if A→B ₹100 and B→C ₹100, simplify to A→C ₹100). This is the single most impactful backend feature — Splitwise charges for it.
- Payment confirmation: After "Swipe to Settle", record settlement as a special `group_transaction` with `type: 'settlement'`
- Push notification to the payee

### 3.3 Complete Analytics Tabs
**Current state**: `analytics_tab.dart` has 6 tabs but 4 of them render the same `GroupExpenseAnalysis()` placeholder.

| Tab | What to Build | Chart Type |
|---|---|---|
| Contribution Analysis | Each member's total contribution vs. fair share | Stacked horizontal bar (`fl_chart`) |
| Group Spending Trends | Monthly spending over time | Smooth line chart with gradient fill |
| Expense Comparison | Category-wise spending: you vs. group average | Grouped bar chart |
| Top Shared Categories | Most frequently shared expense categories | Donut chart with animated segments |

### 3.4 Friend Screen
**Current state**: The `FriendScreen` directory only contains `personal_transaction_screen.dart` — not actually a friends feature.

**Build a real Friends system**:
- Add friends by phone number, email, or shareable link
- Show per-friend balance (total owed/owing across all groups)
- "Quick Split" with a friend without creating a group (1:1 expenses)
- Contact book integration for easy discovery

---

## 4. Differentiating Features — What No Competitor Does Well

### 4.1 AI-Powered Receipt Scanner (Camera → Split)
**Why**: SplitterUp launched this in 2025 and it's their #1 differentiator. Splitwise charges premium for basic OCR.

**SplitO's approach**:
- Use Google ML Kit's on-device text recognition (free, no API costs, works offline)
- Extract: merchant name, date, individual line items with prices, tax, tip
- Present items as a checklist — each member taps the items they consumed
- Auto-calculate per-person total including proportional tax/tip
- **Edge**: On-device processing = no privacy concerns (a selling point vs. cloud-based OCR apps)

### 4.2 Smart Reminders That Don't Annoy
**Why**: Splitwise's reminders are passive and generic. Users hate nagging friends about money.

**SplitO's approach**:
- **Contextual nudges**: "You and Rahul haven't settled up in 14 days. Coffee is on you! ☕" (humor defuses awkwardness)
- **Auto-remind schedule**: Configurable per-group cadence (weekly/biweekly/monthly)
- **Gentle language engine**: Randomized friendly templates instead of robotic "You owe ₹500"
- **Silent mode**: Option to mute reminders for specific people (e.g., parents, partners)

### 4.3 Trip Mode (Temporary Group with Timeline)
**Why**: Trips are the #1 use case for expense splitting. No app has a dedicated trip experience.

**SplitO's Trip Mode**:
- Create a trip with start/end dates and a destination
- **Trip timeline** (using `flutter_timeline` already in deps): chronological feed of expenses with photos, locations, and who paid
- **Per-day breakdown**: Swipe through days to see daily spending
- **Trip summary card**: Exportable card with key stats (total spent, biggest expense, most generous person, most common category)
- **Currency auto-detection**: Detect country from location/timezone and default to local currency

### 4.4 Expense Insights & Spending Intelligence
**Why**: Turning raw transaction data into actionable insights is where fintech apps (CRED, Mint) create stickiness. No splitting app does this well.

**Features**:
- **Monthly spending digest**: Push notification or in-app card summarizing "You spent ₹12,400 across 3 groups. Food was 62% of your splits."
- **Unusual expense detection**: "This ₹8,000 dinner is 3x your average group meal"
- **Category trends**: "Your transportation splits have increased 40% this month"
- **Settle-up health score**: Per-group metric showing how quickly debts get resolved

### 4.5 Offline-First Architecture
**Why**: Tricount and KipEven offer offline. Splitwise does not for free users. This is table-stakes for travel.

**Implementation**:
- Local SQLite/Drift database as source of truth
- Queue mutations (add expense, settle up) and sync on connectivity
- Conflict resolution: last-write-wins with user confirmation for conflicts
- Visual indicator: subtle badge on unsynced expenses

---

## 5. Social & Engagement Layer — Making Money Talk Fun

### 5.1 Group Activity Feed with Reactions
**Why**: Splitting expenses is inherently social, but current apps treat it like an accounting ledger.

- Real-time activity feed per group (like a mini-chat)
- React to expenses with emoji (😂 for "Why did we spend ₹5000 on dessert?")
- Comment thread on any expense for context ("This includes the cab back")
- **Brand moment**: Position SplitO as the app where splitting feels like group chat, not tax filing

### 5.2 Gamification: "Fair Share" Scores
**Why**: No competitor gamifies expense behavior. This creates retention.

- **Promptness score**: How quickly a user settles debts (visible only to them, not others — avoids shaming)
- **Contribution badges**: "Group MVP" (paid the most this month), "Splitter Pro" (added most expenses)
- **Monthly recaps**: Animated year-in-review style cards ("You split 147 expenses across 8 groups in 2025")
- Keep gamification **private and positive** — never show "slowest payer" leaderboards

### 5.3 Shared Wishlists / Planned Expenses
**Why**: Groups often plan future expenses (birthday gift, trip, rent deposit). No app handles planned vs. actual.

- Create a planned expense with a target amount
- Members can mark their contribution as "pledged" or "paid"
- Progress bar showing how close the group is to the target
- Convert planned expense to actual expense when finalized

---

## 6. Technical Differentiators — Architecture as a Moat

### 6.1 Fix the N+1 Query Problem
**Current state**: `getGroupTransactionsData` makes 2 separate user queries per transaction (marked `// OPTIMIZATION NEEDED HERE` in code).

**Fix**: Use Supabase's `select('*, users!paid_by(*), users!shared_with(*)')` join syntax to fetch user details in a single query. This alone will make group screens load 5-10x faster for groups with many transactions.

### 6.2 Repository Pattern Refactor
**Current state**: Screens call `SupabaseDatabase` directly — no abstraction layer.

**Why**: Enables offline-first (swap Supabase calls for local DB reads), simplifies testing, and makes it possible to switch backends without touching UI code.

**Architecture**:
```
Screen → Controller (GetX) → Repository (interface) → DataSource (Supabase / Local SQLite)
```

### 6.3 Real-time Sync with Supabase Realtime
**Why**: When someone adds an expense, all group members should see it instantly — not on next pull-to-refresh.

- Subscribe to `group_transaction` table changes filtered by group ID
- Use Supabase Realtime Channels (already available in the `supabase_flutter` package)
- Show a subtle "New expense added" toast with the payer's avatar

### 6.4 Biometric Auth for Sensitive Actions
**Why**: CRED uses biometric swipe for payments. Adding biometric confirmation for settle-up actions adds a premium, trust-building feel.

- Use `local_auth` Flutter package
- Required for: settling debts, deleting expenses, leaving a group
- Optional: app-level lock

---

## 7. Monetization Without Alienating Users

> **Core principle**: Never paywall features that users already have. Splitwise's #1 mistake was taking away free features.

| Tier | Price | Includes |
|---|---|---|
| **Free** | ₹0 | Unlimited transactions, all splitting modes, groups, settle-up, basic analytics, offline mode |
| **SplitO Pro** | ₹499/yr (~$6) | AI receipt scanner, advanced insights, trip mode, export to PDF/CSV, priority support |
| **Group Pro** | ₹149/group/yr | Unlocks group-level features: shared wishlists, custom categories, advanced group analytics |

**Alternative monetization** (if you want to keep everything free):
- **Whitelabel/API**: License the splitting engine to other fintech apps
- **Affiliate settlements**: Partner with UPI/payment apps for in-app settlement with a referral fee
- **Premium themes**: Cosmetic customization (accent colors, icon packs) as one-time purchases

---

## 8. Growth & Distribution — Getting to the First 10,000 Users

### 8.1 Viral Mechanics Built Into the Product
- **Invite-to-split**: When adding a non-SplitO user to a group, they get a deep-link to join. The expense is waiting for them. (Splitwise does this, but SplitO should do it faster and prettier.)
- **Settlement sharing**: After settling up, share a styled "receipt card" to Instagram Stories / WhatsApp
- **Trip summary cards**: Beautiful, shareable trip recap graphics (auto-generated, not screenshots)

### 8.2 SEO & ASO
- **App Store Optimization**: Position as "Free Splitwise Alternative" — this keyword has massive search volume in 2025
- **Landing page**: A single-page site comparing SplitO vs. Splitwise feature-by-feature

### 8.3 Community-Led Growth
- Post the comparison on Reddit's r/splitwise (where frustrated users congregate)
- Product Hunt launch with a strong "by a developer, for real groups" narrative
- Open-source the debt simplification algorithm on GitHub for developer credibility

---

## 9. Priority Roadmap

### Phase 1: Foundation (4–6 weeks)
- [x] Dark NeoPop UI  *(already done)*
- [x] Group creation & even/uneven splitting  *(already done)*
- [x] Complete percentage & shares splitting modes
- [x] Functional settle-up with debt simplification
- [x] Fix N+1 query performance
- [x] Complete all 6 analytics tabs with real data
- [x] Real friends system with per-friend balances

### Phase 2: Differentiation (6–8 weeks)
- [x] Swipe-to-Settle gesture
- [x] Glassmorphism card redesign + micro-animations  *(Home, Groups, Profile hero + staggered lists)*
- [x] AI receipt scanner (Google ML Kit)  *(wired from add-transaction screen)*
- [x] Offline-first architecture  *(repos wired to Group + Transaction UI)*
- [x] Real-time sync with Supabase Realtime  *(subscribe on group detail + refresh)*
- [x] Smart reminders with friendly language  *(per-group settings + triggers wired)*

### Phase 3: Engagement (4–6 weeks)
- [x] Trip Mode with timeline
- [x] Group activity feed with reactions
- [x] Activity comment threads on expenses
- [x] Expense insights & spending intelligence  *(z-score detection, settle-up health, digest, trend chart)*
- [x] Gamification (promptness score, badges, monthly recap)  *(real metrics + badge unlock on settle-up)*
- [x] Animated onboarding flow

### Phase 4: Growth (Ongoing)
- [x] Shareable settlement cards & trip summaries
- [x] Shareable invite deep links (friend + group join)
- [x] Pending invite queue after login
- [x] SplitO Pro IAP (monthly/yearly) + paywall screen
- [x] Premium gates (receipt scan, insights, export)
- [x] CSV & PDF group transaction export
- [ ] App Store launch with ASO strategy
- [ ] Landing page with competitive comparison
- [ ] Reddit / Product Hunt launch

---

## 10. The One-Liner Positioning

> **SplitO**: *Split expenses like a group chat, not a spreadsheet. Beautiful. Free. No limits.*

This positions against Splitwise's clinical feel and paywall, while promising the social, polished experience that no competitor delivers today.
