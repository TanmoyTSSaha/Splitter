# Splitr — Product Description Document (PRD)

**Document type:** Production description / Product Requirements Document  
**Product:** Splitr (Flutter package name: `splitr`)  
**Version reviewed:** App `1.0.0+1` (from `pubspec.yaml`)  
**Last verified against codebase:** 2026-07-01 (full re-audit)  
**Methodology:** Derived entirely from source code, Supabase migrations, and existing `ai-docs/` references. Items not found in code are explicitly marked as gaps, placeholders, or marketing-only. Branding constants are sourced from `lib/Constants/app_branding.dart`.

---

## 1. Executive Summary

Splitr is a cross-platform Flutter mobile for **shared expense management**, **personal finance tracking**, **peer-to-peer lending**, and **financial goal planning**. The product is backed by **Supabase** (authentication, PostgreSQL, realtime) with a partial **offline-first** layer using **Drift/SQLite** for groups and group transactions.

Users can split bills in groups using multiple allocation methods, settle debts with simplified transfer suggestions, track personal spending alongside group activity, lend or borrow money with interest and repayment schedules, set savings goals, and view spending insights. A **Splitr Pro** subscription unlocks AI receipt scanning, advanced insights, and CSV/PDF export.

The app shell exposes four bottom-navigation tabs: **Home**, **Groups**, **Lending**, and **Profile**. Friends, Expense Insights, and many secondary flows are reached from Profile or contextual entry points—not from the bottom nav.

---

## 2. Product Identity

### 2.1 Naming (as implemented)

Canonical values live in `lib/Constants/app_branding.dart` (`AppBranding`):

| Constant | Value | Usage |
|----------|-------|-------|
| `brandName` | **Splitr** | App title (`main.dart`), share copy, exports, invite messages |
| `brandLogo` | **Splitr.** | Albra wordmark in app bars, share cards, biometric lock |
| `brandPro` | **Splitr Pro** | Premium tier label |
| `shareHashtag` | **#SplitrApp** | Monthly recap share text |
| `shareAttribution` | Shared from Splitr ✨ | Shareable card footers |
| Dart package | **splitr** | `pubspec.yaml` name; all imports use `package:splitr/...` |

**Deep links (canonical — emitted in new shares):**

| Type | App scheme | Web |
|------|------------|-----|
| Friend invite | `splitr://invite/friend/{userId}` | `https://splitr.app/invite/friend/{userId}` |
| Group join | `splitr://join/{token}` | `https://splitr.app/join/{token}` |

**Legacy deep links (parse-only in `InviteLinkService.parseUri`; not emitted in new shares):** `splito://` / `https://splito.app`.

**Local storage identifiers:** Drift DB file `splitr_local.db` (migrates from legacy `splito_local.db` on first open); notification channel `splitr_reminders`; export filename prefix `splitr`.

### 2.2 Positioning statement (from onboarding + paywall copy)

- Split bills instantly among friends, family, or roommates.
- Track spending with category breakdowns and monthly summaries.
- Settle balances with debt simplification and one-tap settlement.
- Paywall tagline: *"Charge for convenience, not your right to split."* — core splitting remains free; Pro charges for advanced tooling.

### 2.3 Supported platforms

Standard Flutter targets exist in the repository: **Android**, **iOS**, **Linux**, **macOS**, **Windows**. Primary product flows are designed for mobile (biometrics, contacts, camera, IAP, local notifications).

---

## 3. Target Users

Inferred from implemented features (not from a separate marketing brief):

| Persona | Supported use cases |
|---------|---------------------|
| Roommates / flatmates | Recurring group expenses, settle-up reminders |
| Friend groups | Quick 1:1 splits, friend balances, shareable invite links |
| Travelers | Trip groups with timeline, daily bucketing, trip summary cards |
| Personal budgeters | Personal transactions, goals, home analytics |
| Lenders / borrowers among friends | Formal loan contracts, interest, EMI schedules |
| Power users | Receipt OCR, exports, AI insights briefing (Pro) |

Default currency is **INR**; 25 currencies are supported for display and conversion via Frankfurter API rates.

---

## 4. App Entry & Authentication

### 4.1 Cold start routing (`main.dart` → `MyApp._getInitialScreen`)

| Order | Condition | Destination |
|-------|-----------|-------------|
| 1 | `hasSeenOnboarding == false` | `OnboardingScreen` |
| 2 | Valid session + biometric lock enabled | `BiometricLockScreen` |
| 3 | Valid session | `BottomNavigationController` |
| 4 | No session | `LoginScreen` |

### 4.2 Bootstrap services (initialized before UI)

1. Supabase (`supabaseURL`, `supabaseAnonPublicKey` from `git_ignore.dart`)
2. Drift `AppDatabase`
3. `SyncService` (connectivity listener + sync queue)
4. `RealtimeService` (Supabase channels)
5. `ReminderService` (local notifications)
6. `DeepLinkService` (`app_links`)
7. GetX singletons: database, sync, realtime, reminders, `ReminderSettingsService`, `CurrencyController`, `PremiumSubscriptionController`

### 4.3 Authentication methods

| Method | Screen | Behavior |
|--------|--------|----------|
| Email + password sign-in | `LoginScreen` | `supabase.auth.signInWithPassword`; on success clears local Drift cache, refreshes premium status, processes pending deep-link invites, navigates to main app |
| Email + password sign-up | `RegisterScreen` | Collects first name, last name, username, email, password; `supabase.auth.signUp` with metadata; navigates to `LoginScreen` (no auto-login) |
| Google OAuth | `LoginScreen`, `RegisterScreen` | `signInWithOAuth(Google)` with redirect `io.supabase.flutterquickstart://login-callback/` |
| Biometric unlock | `BiometricLockScreen` | Local `local_auth`; unlock → main app |
| Logout | `ProfileScreen` | Confirm dialog → `signOut` + `AppDatabase.clearAllUserData()` → `LoginScreen` |

### 4.4 User profile creation

- DB trigger `handle_new_user` creates `public.users` row on `auth.users` INSERT.
- Client may also upsert `users` on signup when session is immediate.

### 4.5 Auth gaps (verified — not implemented)

| Feature | Status |
|---------|--------|
| Forgot password | UI button exists; handler is a stub (`debugPrint` only) |
| Password change | Not found |
| Profile picture upload | URL displayed; no upload flow |
| Username edit after signup | Not found (`user_name` set at registration only) |

---

## 5. Onboarding

**Screen:** `OnboardingScreen` — 3-page `PageView`.

| Page | Title | Message |
|------|-------|---------|
| 1 | Split Bills Instantly | Divide expenses; avoid awkward money conversations |
| 2 | Track Every Penny | Spending insights, category breakdowns, monthly recaps |
| 3 | Settle Up Simply | Smart debt simplification; one-tap settle |

**Actions:** Skip, Next, Get Started → sets `SharedPreferences` key `hasSeenOnboarding = true` → `LoginScreen`.

**Backend:** None.

---

## 6. Application Shell

### 6.1 Bottom navigation (`BottomNavigationController`)

| Index | Label | Screen | Refresh on tab switch |
|-------|-------|--------|----------------------|
| 0 | Home | `HomeScreen` | — |
| 1 | Groups | `GroupScreen` | `GroupScreenController.refreshFromAnywhere()` |
| 2 | Lending | `LendingDashboard` | `LendingRefreshController.refreshFromAnywhere()` |
| 3 | Profile | `ProfileScreen` | — |

Implementation uses `IndexedStack` (tabs retain state) and `AnimatedGlassBottomNavBar`.

### 6.2 Secondary navigation pattern

GetX `Get.to()` / `Get.off()` — no centralized named route table. `AppBindings` (registered via `GetMaterialApp.initialBinding`) lazily registers:

| Binding | Type |
|---------|------|
| `GroupRepository` | Drift + `SyncService` |
| `TransactionRepository` | Drift + `SyncService` |
| `GroupScreenController` | Group list state + realtime |
| `NotificationBadgeController` | Bell badge for pending actions |

Per-screen controllers (e.g. `AllTransactionsController`) are `Get.put`/`Get.delete` at screen scope.

---

## 7. Feature Specifications

### 7.1 Home (`HomeScreen`)

**Purpose:** Personal finance dashboard combining personal and group transaction visibility, lightweight analytics, and goal progress.

**Data loaded (parallel):**
- `getUnifiedTransactions` — personal + group, currency-converted
- `getMonthlySpendAnalytics` — category breakdown (current month)
- `getGoals` — active financial goals
- `getMonthlyCashFlow` — total outflow including splits
- `getMonthlyPulseData` — daily bar chart data

**UI sections:**

| Section | Description |
|---------|-------------|
| App bar | "Splitr." title, `NotificationBellButton`, user avatar |
| Sync banner | `SyncStatusBanner` from `SyncService` |
| Empty state | `HomeEmptyState` when no transactions, goals, or category spend — shortcuts to create group, add personal transaction, or create goal |
| Insights promo | `InsightsPromoCard` → `ExpenseInsightsScreen` — once per session (`insights_promo_session_shown`); dismiss hides 24h (`insights_promo_dismissed_at`); message from `SpendingIntelligenceService.getPromoHook()` |
| Monthly spend | Top 5 categories (horizontal cards) |
| Transactions | Unified list via `TransactionTile`; "VIEW ALL" → `AllTransactionsScreen` |
| Analytics toggle | **True Spend** (`DailySpendBarChart`) vs **Cash Flow** (single outflow stat) |
| Financial goals | Progress cards; "SET A GOAL" → `CreateGoalScreen` |
| FAB | `AddPersonalTransactionScreen` (only when home has data) |

**Personal transaction add (`AddPersonalTransactionScreen`):**
- Fields: amount, description, category (master + custom "Other"), date (≤ today), payment method (`Online` / `Cash`)
- Persists to `personal_transaction`; custom categories to `personal_custom_category`
- **Not offline-queued** — direct Supabase write

**All transactions (`AllTransactionsScreen` + `AllTransactionsController`):**

| Entry point | Constructor args | Title | Base filter |
|-------------|------------------|-------|-------------|
| Home → VIEW ALL | default | All Transactions | All unified personal + group |
| Group tab → VIEW ALL | `isGroupFilter: true`, `groups: onlyGroups` | Group Transactions | `type == 'group'` and group in non-trip list |
| Trip tab → VIEW ALL | `isTripFilter: true`, `tripGroupIds: {...}` | Trip Transactions | `type == 'group'` and group in trip ID set |

**Data loading:**
- Fetches via `SupabaseDatabase.getUnifiedTransactions()` with currency from `CurrencyController`.
- Default window: last **365 days** from today (`_loadedSince`); no row limit (`limit: null`).
- Re-fetches on currency change (`ever(cc.rxCode, ...)`).
- "Load older transactions" prepends another 365-day chunk (merged with `TransactionListHelper.mergeDeduped` by `dedupe_key`); hidden when a custom date filter is active.

**Sort (`TransactionSortSheet` → `TransactionSortOption`):**

| Option | Label |
|--------|-------|
| `newestFirst` | Newest first (default) |
| `oldestFirst` | Oldest first |
| `largestFirst` | Largest first (by absolute amount) |
| `smallestFirst` | Smallest first (by absolute amount) |

**Filter (`TransactionFilterSheet`):**

| Filter | Behavior |
|--------|----------|
| Quick range presets | 7 days, 30 days, 3 months, 6 months, 12 months — sets From/To and disables "Load older" |
| Price range | Min/max in user's currency symbol; validated (min ≤ max) |
| Custom date range | From + To required together; no future dates; To ≥ From; disables "Load older" |
| Category | Multi-select chips from categories present in loaded transactions |
| Group | Multi-select checkboxes from `GroupRepository.getGroups()` (Drift cache + trip flags via `fetchTripGroupIds`) |

Active filter count badge on app bar (categories, groups, amount, or date each count as one). "Clear all" resets filters and re-fetches.

**Section grouping (`TransactionSectionGrouper` + `TransactionSectionHeader`):**
Adaptive headers based on age from today:

| Age of transaction | Granularity | Example header |
|--------------------|-------------|----------------|
| 0–6 days | Daily | Today, Yesterday, Mon Jan 15 |
| 7–27 days | Weekly | Jan 6 – Jan 12 |
| 28–365 days | Monthly | January 2026 |
| 365+ days | Yearly | 2025 |

Client-side filters (category, group, amount) apply after fetch; date filters trigger server-side `since`/`until` on re-fetch.

**Premium gate:** None.

**Architecture note:** Home still calls `SupabaseDatabase()` directly — no `PersonalTransactionRepository` exists (Drift `LocalPersonalTransactions` table exists but is not wired to Home).

---

### 7.2 Groups (`GroupScreen` → `GroupDetailedScreen`)

#### 7.2.1 Group list (`GroupScreen`)

**Layout:** Pill sub-tabs via `PillTabBar` — **Group Expense** | **Trip Expense** (`TabController` length 2).

**Shared chrome:**
- App bar with avatar, `NotificationBellButton`, `SyncStatusBanner`.
- Hero card: "money matters, simplified." + overall stats (filtered by active sub-tab: non-trip vs trip groups).
- Pull-to-refresh → `GroupScreenController.refreshGroups()`.
- Pro upsell banner for non-subscribers (`PremiumSubscriptionController.isPremium`).
- Empty state → `GroupEmptyState` when no groups at all.

**Group Expense tab:**
- Horizontal carousel of active non-trip groups (`ActiveGroupCard`) + add card → `CreateGroupScreen`.
- "RECENT ACTIVITY" feed + VIEW ALL → `AllTransactionsScreen(isGroupFilter: true, groups: onlyGroups)`.

**Trip Expense tab:**
- Trip cards (`TripGradientCard`) from `TripService.getTrips()` + add card → `CreateTripScreen`.
- "RECENT TRIP ACTIVITY" feed + VIEW ALL → `AllTransactionsScreen(isTripFilter: true, tripGroupIds: ...)`.

**Data:** `GroupScreenController` + `GroupRepository.watchGroups()` + `refreshFromServer()` + realtime (offline-friendly reads). Trip flag on each group from server `trip_metadata` lookup during refresh.

#### 7.2.2 Group creation

| Type | Screen | Backend |
|------|--------|---------|
| Standard group | `CreateGroupScreen` | RPC `create_group_with_member(p_group_name)` |
| Trip | `CreateTripScreen` | RPC `create_trip_with_member` + `trip_metadata` row |

#### 7.2.3 Group detail tabs (`GroupDetailedScreen`)

**Regular group tab order:** Activity → Transactions → Analytics → Settle up → Members → Wishlist  

**Trip group:** prepends **Timeline** tab.

| Tab | Widget | Primary data |
|-----|--------|--------------|
| Timeline (trip) | `TripTimelineTab` | `TripService` — daily buckets, summary stats |
| Activity | `ActivityFeedTab` | Transactions as feed + emoji reactions + comments |
| Transactions | `TransactionTab` | `TransactionTabController` + Drift watch + realtime |
| Analytics | `AnalyticsTab` | `AnalyticsController` — charts by duration |
| Settle up | `SettleUpTab` | `SettleUpController` — simplified debts |
| Members | `MembersTab` | `getGroupMembers` |
| Wishlist | `WishlistTab` | `WishlistService` |

**Overflow menu (⋮):** Reminder settings, Export CSV/PDF (Pro), Share group invite link.

**FAB actions (tab-dependent):**
- Transactions → Add Transaction
- Settle up → Manual Settle Up
- Members → Add Member
- Wishlist → Add wishlist item (when items exist)

#### 7.2.4 Membership & invites

**In-app invites (`AddMemberScreen`):**
- Select accepted friends or search users by email.
- Creates `group_invites` rows (`pending`).
- Accept/decline via `NotificationScreen` → RPC `respond_to_group_invite`.

**Shareable join links (`InviteLinkService`):**
- URLs: `splitr://join/{token}` / `https://splitr.app/join/{token}` (via `AppBranding`).
- Table: `shareable_invites` (`invite_type: 'group'`, 30-day default expiry in schema).
- Join: RPC `join_group_as_member`; token marked `used`.
- `DeepLinkService` queues invite if user logged out; processes after login.

#### 7.2.5 Add expense (`AddTransactionScreen`)

**Flow:**
1. Select group, payer, description, amount, category, optional notes.
2. Open `ShareDistributionScreen` (5 sharing tabs).
3. Save → `SupabaseDatabase().addGroupExpense()` with `splits` map.

**Sharing types (UI tab → DB `sharing_type`):**

| Tab | Label | `sharing_type` | Validation |
|-----|-------|----------------|------------|
| 0 | Evenly | `evenly` | Split among checked members only |
| 1 | Unevenly | `unevenly` | Manual amounts; sum = total (±₹0.02) |
| 2 | By Percentage | `percentage` | Percents sum to 100% |
| 3 | By Shares | `shares` | Proportional by share units |
| 4 | By Item | `by_item` | Line items assigned to members |
| Receipt prefill | — | `by_item` | From OCR flow |
| Settlement | — | `settlement` | Recorded by settle-up flow |

**Database write:** One `group_transaction` row per `shared_with` user with amount > 0. Updates `groups.group_balance` JSONB (donor = creditor, receiver = debtor). Self-only expenses: single row, `is_settled_up: true`.

**Edit:** Delete by `transaction_group_id`, then re-insert (no update RPC).

**Post-save:** `ReminderTriggerHelper.onExpenseAdded()` schedules local nudges for debtors.

**Receipt scanner (`ReceiptScannerScreen`):**
- Entry: camera icon on add transaction — **Pro gate** (`requirePremium('AI Receipt Scanning')`).
- Pipeline: image pick → on-device ML Kit OCR (`ReceiptParserService`) → user assigns members per line → tax/tip distributed proportionally → applies as `by_item`.

#### 7.2.6 Settle up

**Balance model:** `groups.group_balance` — array of `{ donor, donor_id, receiver, receiver_id, amount }` where donor is owed and receiver owes.

**Debt simplification (`SettleUpController._simplifyDebts`):**
1. Net balance per member.
2. Greedy match largest creditor ↔ largest debtor.
3. Produces `SimplifiedDebt(from=debtor, to=creditor, amount)`.

**Settlement recording (`recordSettlement`):**
1. Insert `group_transaction` with `sharing_type: 'settlement'`, `is_settled_up: true`.
2. Reduce matching balance entry (remove if ≤ ₹0.01).
3. Create notification; schedule post-settlement reminder; check gamification badges.

**UI paths:**
- **Swipe-to-settle:** `SettleUpTab` → fullscreen `SwipeToSettleWidget` (haptic + optional biometric).
- **Manual:** `ManualSettleUpScreen` — pick recipient, amount ≤ owed.
- **Share:** `ShareableSettlementCard` after successful swipe settle.

#### 7.2.7 Group analytics (`AnalyticsTab`)

Duration filter: weekly / monthly / all-time (`DurationLabel`).

Charts (via `AnalyticsController` + `fl_chart`):
- Category breakdown (pie/donut)
- Member contributions (paid vs share)
- Monthly spending trends (line)
- Category comparison (user vs group average)
- Member net balances

**Premium gate:** None — group analytics are free.

#### 7.2.8 Activity feed

Built from group transactions (not a separate activity table). Supports:
- Emoji reactions → `activity_reactions`
- Comments → `activity_comments` (`ActivityCommentsSheet`)
- Realtime refresh via `GroupScreenController`

#### 7.2.9 Wishlist (`WishlistTab`)

- Add planned expenses: title + optional estimated amount.
- Upvote toggle (`wishlist_upvotes`).
- Creator can delete (if not yet converted).
- "Add as Expense" → `AddTransactionScreen` with `WishlistPrefill` → marks `is_added_to_expenses`.

#### 7.2.10 Per-group reminder settings

**UI:** `GroupReminderSettingsSheet`

| Setting | Values | Storage |
|---------|--------|---------|
| Cadence | off, daily, weekly, biweekly, monthly | `reminder_settings` (+ SharedPreferences fallback) |
| Tone | friendly, casual, formal | same |
| Muted members | per-member | `muted_member_ids` jsonb |

**Global silent mode:** Profile `NotificationsScreen` toggle → `reminders_silent_mode` in SharedPreferences.

#### 7.2.11 Export (Pro)

**Service:** `ExportService` — CSV and PDF via `share_plus`.  
**Gate:** `requirePremium('CSV & PDF Export')` on `GroupDetailedScreen` menu.

#### 7.2.12 Offline behavior (groups)

| Operation | Offline support |
|-----------|-----------------|
| Read groups / group transactions | Yes — Drift cache + `GroupRepository` / `TransactionRepository` |
| Create group, add expense, settle, invites, wishlist | No — direct Supabase RPC/writes |
| Sync queue | `SyncService` supports INSERT/UPDATE/DELETE for `groups`, `group_transaction`, `personal_transaction`, `friends` — but add-expense UI does not use `TransactionRepository.addTransaction()` |

---

### 7.3 Trips

Trips are **groups with `trip_metadata`** — not a separate entity.

**Creation:** `CreateTripScreen` — name, destination, date range.

**Timeline tab:** Expenses bucketed by day within trip dates; summary (total, avg/day, MVP payer, top category, biggest expense).

**Share:** `ShareableTripSummaryCard` (screenshot + system share).

---

### 7.4 Friends (Profile → `FriendsScreen`)

**Not a bottom-nav tab.**

| Screen | Purpose |
|--------|---------|
| `FriendsScreen` | Tabs: Friends (balances), Pending (outgoing), Incoming |
| `AddFriendScreen` | Search by email + device contacts matching |
| `FriendDetailScreen` | Net balance, settlement promptness score, per-group breakdown |
| `QuickSplitScreen` | 1:1 even split via direct 2-member group |

**Friend states:** `pending`, `accepted`, `rejected` (`friends` table).

**Actions:** send request, accept, cancel outgoing pending, remind.

**Invite links:** `splitr://invite/friend/{userId}` / `https://splitr.app/invite/friend/{userId}`.

**Balance threshold:** ±₹0.01 treated as settled.

**Premium gate:** None.

---

### 7.5 Lending (`LendingDashboard`)

| Screen | Role |
|--------|------|
| `LendingDashboard` | Net position hero; Active / Pending / Completed tabs |
| `CreateLoanScreen` | Lend money (wrapper) |
| `RequestLoanScreen` | Borrow money (wrapper) |
| `LoanContractFormScreen` | Shared form (`mode: lend` \| `borrow`) |
| `LoanDetailScreen` | Contract details, accept/reject, record payment |
| `LoanRepaymentScheduleScreen` | EMI breakdown |

**Loan statuses:** `pending` → `active` | `rejected` | `completed` | `defaulted`

**Contract fields:**
- Counterparty (friend picker or email lookup)
- Principal (> 0)
- Interest rate (default 5%), period — UI dropdown offers **`monthly`** and **`yearly`** only (`LoanModel` comment also references `one_time` but the form does not expose it), type (`simple` / `compound` / `flat`)
- Duration (months/years/days) → computed `due_date`
- Repayment window: `repayment_start_day`–`repayment_end_day` (1–31)
- `created_by` distinguishes lend-offer vs borrow-request for acceptance routing

**Active loan math:** `LoanInterest` for accrued interest; `LoanScheduleCalculator` for EMI and installment statuses (upcoming / partial / paid / missed).

**Pending actions:** Shown on Home `NotificationScreen` bell — accept/reject loans.

**Premium gate:** None.

---

### 7.6 Financial Goals

| Screen | Role |
|--------|------|
| `CreateGoalScreen` | New goal form |
| `GoalDetailsScreen` | Progress, fund/withdraw, history, delete |

**Goal types:** Travel, Gadget, Vehicle, Home, Education, Emergency, Investment, Other (+ custom text).

**Required fields:** title, target amount, deadline.

**AI assistance (free — uses Gemini when API key configured):**
- Icon suggestion from title
- Estimated amount after description debounce (`AIService.getEstimatedAmount`)
- Feasibility message (`AIService.checkFeasibility`)

**Transactions:** `goal_transactions` with types `deposit` / `withdraw`; `current_amount` recalculated from history.

**Tables:** `financial_goals`, `goal_transactions`.

---

### 7.7 Expense Insights (`ExpenseInsightsScreen`)

**Entry:** Profile menu, Home `InsightsPromoCard`.

**Data engine:** `SpendingIntelligenceService` (aggregates personal + group spend via `TransactionService`).

#### Free tier (`getInsightsLite`)

- Total spent this month + % vs last month
- 3-month mini trend bar chart
- `monthlyDigest` text (shown when user is **not** Pro)

#### Pro tier (`InsightsProGate` — 8 gated sections)

| Section | Feature label |
|---------|---------------|
| AI Weekly Briefing | AI Briefing |
| Action Queue | Smart Actions |
| Health Scores | Health Scores |
| Spending Coach | Spending Coach |
| Social Trust | Social Trust |
| 6-month trend chart | Spending Trends |
| Category pie chart | Category Breakdown |
| Unusual expenses (z-score > 2) | Unusual Expenses |

**AI briefing:** `AIService.generateInsightsBriefing` with `InsightsBriefingCache` (7-day TTL; invalidates on >10% spend shift). Falls back to `monthlyDigest` if AI fails.

**Action navigation (`InsightsNavigation`):** `settle_up` → group detail; `review_category` / `view_expense` → All Transactions; `view_goal` → Goal Details.

---

### 7.8 Profile (`ProfileScreen`)

**Hero:** Avatar (tap → Personal Details), name, tagline "JUST VIBING", lifetime TOTAL SPENT / TOTAL RECEIVED.

**Menu — ACCOUNT INFO:**

| Item | Screen |
|------|--------|
| Personal Details | `PersonalDetailsScreen` — edit first name, last name, phone (10-digit) |
| Friends | `FriendsScreen` |
| Expense Insights | `ExpenseInsightsScreen` |
| Premium Plan | `PremiumPlanScreen` |

**Menu — APP SETTINGS:**

| Item | Behavior |
|------|----------|
| Biometric Lock | Toggle with device auth (`BiometricAuthService`) |
| Edit Currency | `EditCurrencyScreen` — 25 currencies |
| Notifications | `NotificationsScreen` — in-app inbox + silent reminders toggle |

**Menu — GENEROUS:**

| Item | Behavior |
|------|----------|
| Donate | `FeatureComingUpNext` (placeholder) |
| Request a Feature | `RequestFeatureScreen` — community wishlist with voting |

**Other:** Logout; `BadgesSectionWidget` (gamification).

**Editable user fields:**

| Field | Editable |
|-------|----------|
| firstname, lastname, phone | Yes |
| currency | Yes |
| email, user_id, total_spent, total_received | No (display/computed) |
| profile_picture_url | Display only |
| user_name (username) | Signup only |

---

### 7.9 Notifications (two separate systems)

#### A. Profile → `NotificationsScreen` (in-app inbox)

- Source: `notifications` table (limit 50).
- Types: `group_invite`, `expense_added`, `settlement_request`, `friend_request`, `general`
- Actions: mark read, mark all read, swipe delete, pull to refresh.
- Toggle: **Silent settlement reminders** → `reminders_silent_mode` (SharedPreferences).

#### B. Home bell → `NotificationScreen` (action center)

- Pending **group invites** (`group_invites`) — accept/decline.
- Pending **loan requests** (`loans`) — accept/reject.
- Badge: `NotificationBadgeController` compares against `notifications_last_viewed_at`.

---

### 7.10 Gamification & Monthly Recap

**Badges (`GamificationService`):**

| ID | Name | Requirement |
|----|------|-------------|
| first_trip | Explorer | Create first trip |
| big_spender | Big Spender | Total spend > ₹1000 |
| settlement_hero | Settlement Hero | 5 settlements |
| early_bird | Early Bird | Expense before 8 AM |

Unlock toast: `BadgeUnlockToast`.

**Monthly recap (`MonthlyRecapScreen`):**
- 6-slide story: intro → spend → top category → daily habit → biggest payment → shareable card.
- Data from `GamificationService.generateRecap`.
- Share via screenshot + `#SplitrApp`.

**Gap:** `MonthlyRecapScreen` is **implemented but not linked** from Profile or any navigation entry found in code. Slide 4 contains **hardcoded** trend text and mock chart — not live data.

---

### 7.11 Community Feature Requests

**Screen:** `RequestFeatureScreen`

- Lists requests from `feature_requests` filtered by `status == 'open'` (sort: votes or newest).
- Vote/unvote via `feature_request_votes`; vote count updated on `feature_requests` row.
- Submit sheet: title, description, category (`splitting`, `analytics`, `payments`, `groups`, `design`, `other`), priority (`nice_to_have`, `really_need`, `deal_breaker`). Creator's vote auto-inserted into `feature_request_votes`.
- UI shows **In Progress** badge when `status == 'in_progress'`.

**Schema mismatch (verified):** Migration `20260101000001_initial_features.sql` defines column `vote_count` and **no `status` column**, but the Flutter client reads/writes `votes`, filters `status = 'open'`, and displays `in_progress`. Feature voting and listing may fail against a fresh migrated database until schema is aligned.

---

### 7.12 Placeholder Features

| Screen | Trigger | Message |
|--------|---------|---------|
| `FeatureComingUpNext` | Profile → Donate | "This feature is coming up next!" |

---

## 8. Monetization — Splitr Pro

### 8.1 Subscription products

| Product ID | Billing | Notes |
|------------|---------|-------|
| `splitr_pro_monthly` | Monthly (fallback display: ₹89/mo) | Canonical (`AppBranding.iapMonthly`) |
| `splitr_pro_yearly` | Yearly (fallback: ₹799/yr, "Save 25%") | Canonical (`AppBranding.iapYearly`) |
| `splito_pro_monthly` | — | Legacy ID still queried by IAP (`AppBranding.iapLegacyMonthly`) |
| `splito_pro_yearly` | — | Legacy ID still queried by IAP (`AppBranding.iapLegacyYearly`) |

**Controller:** `PremiumSubscriptionController` — `in_app_purchase`, syncs to `users.is_premium` / `users.premium_expires_at`, local SharedPreferences cache (`premium_active`, `premium_expires_at`). Debug: `enableDevPremium()`. No separate `premium_subscriptions` table in migrations — flags live on `users`.

### 8.2 Plan comparison (from `PremiumPlanScreen`)

**Basic (free):**
- Unlimited expense splitting
- Unlimited groups
- Basic monthly stats
- Standard support

**Premium (Pro):**
- Everything in Basic
- AI Receipt Scanning (OCR)
- UPI Quick Settle Links
- Advanced Analytics & Charts
- CSV & PDF Export
- Elite Splitr Badge

### 8.3 Enforced gates (code-verified)

| Feature | Mechanism | Location |
|---------|-----------|----------|
| AI Receipt Scanning | `requirePremium()` | `AddTransactionScreen` |
| CSV & PDF Export | `requirePremium()` | `GroupDetailedScreen` |
| 8 Insights sections | `InsightsProGate` | `ExpenseInsightsScreen` |

### 8.4 Marketing-only (listed on paywall, no runtime gate found)

- UPI Quick Settle Links
- Elite Splitr Badge

---

## 9. Deep Links

**Service:** `DeepLinkService` (`app_links`)

| Type | URI patterns (canonical) | Post-login action |
|------|--------------------------|-------------------|
| Friend invite | `splitr://invite/friend/{id}`, `https://splitr.app/invite/friend/{id}` | Accept friend → `FriendsScreen` |
| Group join | `splitr://join/{token}`, `https://splitr.app/join/{token}` | RPC join → `GroupDetailedScreen` |

Legacy hosts/schemes (`splito.app`, `splito://`) are still parsed by `InviteLinkService.parseUri`.

Logged-out users: URI stored in SharedPreferences; processed after login via `processPendingInvite()`.

---

## 10. Currency & Multi-Currency

- **Default:** INR (`users.currency`, `CurrencyController`).
- **25 supported currencies** via `CurrencyService.supportedCurrencies` (Frankfurter API).
- Rates cached 24 hours; `exchange_rate_to_inr` frozen at transaction save time.
- Display symbol via `CurrencyService.symbolFor()`.
- Home and unified transaction lists re-fetch on currency change.

---

## 11. Data Model Summary

### 11.1 Core Supabase tables

| Table | Purpose |
|-------|---------|
| `users` | Profile, currency, premium flags, lifetime totals |
| `groups` | Group name, `group_balance` JSONB |
| `group_members` | Membership |
| `group_transaction` | Expenses and settlements (one row per participant) |
| `personal_transaction` | Personal spending |
| `master_product_category` | Seeded categories (Food, Transport, …) |
| `group_custom_category` / `personal_custom_category` | User-defined categories |
| `trip_metadata` | Trip details keyed by `group_id` |
| `friends` | Friend relationships |
| `group_invites` | In-app group invites |
| `shareable_invites` | Token-based friend/group links |
| `activity_reactions` / `activity_comments` | Social on activity feed |
| `notifications` | In-app notification inbox |
| `reminder_settings` | Per-user per-group reminder prefs |
| `group_wishlists` / `wishlist_upvotes` | Planned group expenses |
| `financial_goals` / `goal_transactions` | Savings goals |
| `loans` | P2P lending contracts |
| `feature_requests` / `feature_request_votes` | Community wishlist (see §7.11 schema note) |

### 11.2 Key RPCs

| RPC | Purpose |
|-----|---------|
| `create_group_with_member` | Create group + add creator |
| `add_group_members` | Bulk add members |
| `create_trip_with_member` | Create trip group + metadata |
| `respond_to_group_invite` | Accept/decline invite |
| `join_group_as_member` | Join via shareable link |
| `is_group_member` | RLS helper |

### 11.3 Local Drift tables

| Table | Purpose |
|-------|---------|
| `LocalGroups` | Cached group name, balance JSON, sync status |
| `LocalGroupMembers` | Membership cache |
| `LocalGroupTransactions` | Cached group expense rows |
| `LocalPersonalTransactions` | Personal tx cache (schema v2; not wired to Home UI) |
| `LocalFriends` | Friend relationship cache |
| `LocalUsersCache` | Display names/avatars |
| `SyncQueue` | Pending INSERT/UPDATE/DELETE ops |

**Database file:** `splitr_local.db` in app documents directory (`AppBranding.localDbFileName`). On first launch, renames legacy `splito_local.db` if present. **Schema version:** 2 (v2 migration adds `LocalPersonalTransactions`).

---

## 12. External Integrations

| Integration | Usage |
|-------------|-------|
| Supabase Auth | Email/password, Google OAuth |
| Supabase Postgres | All persistent data |
| Supabase Realtime | Group/transaction/wishlist change events |
| Frankfurter API | Exchange rates (`api.frankfurter.app`) |
| Google ML Kit | On-device receipt OCR |
| Google Gemini | Goal AI, insights briefing (`google_generative_ai`, key in `git_ignore.dart`) |
| App Store / Play Store | IAP via `in_app_purchase` |
| Device biometrics | `local_auth` |
| Local notifications | Settlement reminders |
| Device contacts | Friend discovery (`flutter_contacts`) |
| System share sheet | Exports, shareable cards, invite links |

---

## 13. Non-Functional Requirements (as implemented)

| Area | Behavior |
|------|----------|
| State management | GetX (`Obx`, controllers, bindings) |
| Theming | `AppThemes.light`, Material 3, Neopop accents, Albra + Poppins fonts |
| Offline reads | Drift cache for groups + group transactions (when repositories wired) |
| Offline writes | Queue exists; most write flows bypass it |
| Sync indicator | `SyncStatusBanner` on Home and Group detail |
| Security | Supabase RLS on all public tables; biometric optional app lock |
| Haptics | Swipe-to-settle, vibration package |
| Tests | `spending_intelligence_service_test`, `insights_pro_gate_test`, `transaction_list_helper_test` (sort, filter, section grouping, date formatter) |
| Branding | Single source: `lib/Constants/app_branding.dart` |

---

## 14. Known Gaps & Inconsistencies (code-verified)

| Item | Detail |
|------|--------|
| Forgot password | Stub only (`debugPrint` in `LoginScreen`) |
| Profile photo | No upload |
| Monthly recap | `MonthlyRecapScreen` implemented; **no navigation entry** in app; slide 4 has hardcoded trend text and mock chart |
| `PersonalTransactionScreen` | Exists with mock data; not wired to home |
| Feature requests schema | DB has `vote_count`, no `status`; client uses `votes` + `status` — likely broken on fresh DB |
| UPI Quick Settle / Elite Badge | Paywall copy only; no runtime gate |
| Home offline | Personal transactions not repository-backed |
| Add expense offline | Direct Supabase — no queue |
| Google OAuth completion | No in-app `onAuthStateChange` listener; relies on redirect/deep link |
| CI/CD | None configured |
| Widget test | `test/widget_test.dart` still expects counter app (0/1); incompatible with current `MyApp` |

---

## 15. Screen Inventory

### Auth & onboarding
`OnboardingScreen`, `LoginScreen`, `RegisterScreen`, `BiometricLockScreen`

### Main shell
`BottomNavigationController`, `HomeScreen`, `GroupScreen`, `LendingDashboard`, `ProfileScreen`

### Home
`AddPersonalTransactionScreen`, `AllTransactionsScreen`, `HomeEmptyState`, `DailySpendBarChart`, `PersonalTransactionScreen` (orphaned)  
**Widgets:** `TransactionFilterSheet`, `TransactionSortSheet`, `TransactionSectionHeader`, `TransactionTile`, `InsightsPromoCard`

### Groups
`CreateGroupScreen`, `GroupDetailedScreen`, `GroupEmptyState`, `AddTransactionScreen`, `ShareDistributionScreen`, `AddMemberScreen`, `ManualSettleUpScreen`, `ReceiptScannerScreen`, `ActivityFeedTab`, `TransactionTab`, `AnalyticsTab`, `SettleUpTab`, `MembersTab`, `WishlistTab`

### Trips
`CreateTripScreen`, `TripTimelineTab`, `ShareableTripSummaryCard`

### Friends
`FriendsScreen`, `AddFriendScreen`, `FriendDetailScreen`, `QuickSplitScreen`

### Lending
`CreateLoanScreen`, `RequestLoanScreen`, `LoanContractFormScreen`, `LoanDetailScreen`, `LoanRepaymentScheduleScreen`

### Goals
`CreateGoalScreen`, `GoalDetailsScreen`

### Insights & recap
`ExpenseInsightsScreen`, `MonthlyRecapScreen` (orphaned nav)

### Profile & settings
`PersonalDetailsScreen`, `EditCurrencyScreen`, `NotificationsScreen`, `PremiumPlanScreen`, `RequestFeatureScreen`, `FeatureComingUpNext`

### Notifications
`NotificationScreen` (action center), `NotificationsScreen` (inbox)

---

## 16. Related Documentation

| Document | Scope |
|----------|-------|
| `ai-docs/architecture.md` | Layer diagram, offline wiring, insights architecture |
| `ai-docs/business-rules.md` | Domain rules (splitting, settlement, lending math) |
| `ai-docs/technology-stack.md` | Packages, platforms, tests |
| `ai-docs/migration-roadmap.md` | Engineering backlog (not product scope) |
| `supabase/migrations/` | Authoritative database schema |

---

## 17. Document Maintenance

When updating this PRD:

1. Verify claims against `lib/`, `supabase/migrations/`, and `test/` — not against this document or prior assumptions.
2. Distinguish **implemented**, **partially implemented**, **placeholder**, and **marketing-only** features.
3. Update the "Last verified" date and app version from `pubspec.yaml`.
