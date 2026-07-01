# SplitO Business Rules (Inferred)

Domain rules inferred from models, sharing tabs, and services. Confirm with product owner before treating as authoritative.

## Group expense splitting

Sharing types (from `GroupScreen/SharingTypeTabs/` and transaction model):

| Type | `sharingType` value | Behaviour |
|------|---------------------|-----------|
| Even | `evenly` | Split equally among selected members |
| Uneven | custom amounts | Manual per-person amounts |
| Percentage | percentage-based | Each member's % of total |
| Shares | share units | Proportional by share count |
| By item | itemized | Per-line-item assignment (receipt flow) |

Transactions store: `paidBy`, `sharedWith`, `totalTransactionAmount`, `sharedTransactionAmount`, `selfShareAmount`, percentages, `category`, `description`, `transactionNote`.

## Group balance & settlement

- Groups maintain `group_balance` (JSON array of donor/receiver/amount).
- `SettleUpController` runs greedy debt simplification to minimize transfer count.
- Settlements recorded via `SupabaseDatabase.recordSettlement()`.
- `isSettledUp` flag on transactions.

## Personal transactions

- Separate from group expenses (`personal_transaction` table / `PersonalTransactionModel`).
- Shown on Home screen; currency from `CurrencyController`.

## Lending

- Loans between users (`LoanModel`, `LoanService`).
- Borrower/lender flows in `LendingScreen/`.
- Loan status: `pending`, `active`, `completed`, `defaulted`, `rejected`.
- `created_by` distinguishes lend-offer vs borrow-request acceptance routing.
- Interest: `simple`, `compound`, `flat`; period: `monthly`, `yearly`, `one_time`.
- Interest math in `LoanInterest` (accrued vs full-term).
- Repayment schedule via `LoanScheduleCalculator` / `RepaymentSchedule` — monthly EMI, installment windows using `repayment_start_day` / `repayment_end_day` (1–31).
- Loan status updates from `NotificationScreen`.

## Friends

- Friend requests and relationships (`FriendService`, `FriendModel`).
- States: `accepted`, `pending` (incoming vs outgoing tracked in `FriendsController`).
- Senders can cancel outgoing pending requests (`cancelFriendRequest`); RLS `friends_delete` policy.
- Not a bottom tab — accessed from Profile.
- Contact matching and invite links via `ContactInviteService`, `InviteLinkService`.
- Realtime friend events via `RealtimeService` (when wired).

## Goals

- Financial goals with target amount, deadline, icon, color (`FinancialGoalModel`).
- Deposits/withdrawals as `GoalTransactionModel` (`deposit` / `withdraw` types).
- AI assists with amount estimate and feasibility (`AIService`, `CreateGoalController`).

## Trips

- Groups can be trips (`isTrip` on `GroupModel`).
- Trip timeline and shareable summary cards.

## Insights (Expense Intelligence)

- Entry: Profile menu, Home `InsightsPromoCard` (dismissible, session-aware).
- `SpendingIntelligenceService` aggregates personal + group spend via `TransactionService`.
- Free tier (`getInsightsLite`): month totals, % change, mini trend, monthly digest.
- Full insights (`getInsights`): health score (spending + settle-up combined), unusual expense detection (z-score > 2), spending coach (projection, category deltas), social trust (open exposure, payer ratio, settlement avg days), action queue.
- Pro tier: AI briefing via `AIService.generateInsightsBriefing`; cached in `InsightsBriefingCache` (7-day TTL or invalidate on >10% spend shift).
- Pro sections gated by `InsightsProGate`; free users see blurred preview.
- Action cards navigate via `InsightsNavigation` (`settle_up`, `review_category`, `view_goal`, `view_expense`).

## Currency

- Default `INR`; user-selectable via `CurrencyController`.
- Persisted in SharedPreferences and Supabase `users.currency`.
- Display symbol via `CurrencyService.symbolFor()`.

## Gamification

- Badges (`badge_model`, `GamificationService`, `badges_section_widget.dart`).
- Monthly recap stories (`monthly_recap_screen.dart`).
- `GamificationService` references `SpendingIntelligenceService` for insight-driven badges.

## Auth & access

- Email/password and Google sign-in.
- Optional biometric lock after session established.
- Onboarding shown once (`hasSeenOnboarding`).

## Premium / Pro

- `PremiumSubscriptionController` — monthly/yearly IAP product IDs (`splito_pro_monthly`, `splito_pro_yearly`).
- Status synced to Supabase `premium_subscriptions` + local SharedPreferences cache.
- Pro gates: insights sections, group export (PDF via `export_service`), and other premium features in `premium_gate.dart`.
- `premium_plan_screen.dart` for subscription UI.

## Offline semantics

- Local mutations queue until synced.
- User sees cached data when offline; `syncStatus` tracks row state.
- Groups and group transactions read from Drift when repositories are wired.
