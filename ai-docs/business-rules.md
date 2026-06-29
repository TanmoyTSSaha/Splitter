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
- Loan status updates from `NotificationScreen`.

## Friends

- Friend requests and relationships (`FriendService`, `FriendModel`).
- Not a bottom tab — accessed from Profile.
- Realtime friend events via `RealtimeService` (when wired).

## Goals

- Financial goals with target amount, deadline, icon, color (`FinancialGoalModel`).
- Deposits/withdrawals as `GoalTransactionModel` (`deposit` / `withdraw` types).
- AI assists with amount estimate and feasibility (`AIService`, `CreateGoalController`).

## Trips

- Groups can be trips (`isTrip` on `GroupModel`).
- Trip timeline and shareable summary cards.

## Currency

- Default `INR`; user-selectable via `CurrencyController`.
- Persisted in SharedPreferences and Supabase `users.currency`.
- Display symbol via `CurrencyService.symbolFor()`.

## Gamification

- Badges (`badge_model`, `GamificationService`, `badges_section_widget.dart`).
- Monthly recap stories (`monthly_recap_screen.dart`).

## Auth & access

- Email/password and Google sign-in.
- Optional biometric lock after session established.
- Onboarding shown once (`hasSeenOnboarding`).

## Premium / placeholders

- `FeatureComingUp` screen gates unfinished profile features.
- `premium_plan_screen.dart` for subscription UI.

## Offline semantics

- Local mutations queue until synced.
- User sees cached data when offline; `syncStatus` tracks row state.
