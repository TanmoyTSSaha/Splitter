# SplitO Migration Roadmap

Prioritized path from current state to target architecture (GetX + repositories + offline-first). **No application code changes in this document** — implementation order only.

**Last reviewed:** 2026-07-01

---

## Completed since last roadmap

| Task | Notes |
|------|-------|
| `AppBindings` + `initialBinding` in `main.dart` | Registers `GroupRepository`, `TransactionRepository`, `GroupScreenController`, `NotificationBadgeController` |
| Wire `GroupRepository` into `GroupScreen` | `GroupScreenController` — `watchGroups()`, realtime, sync status |
| Wire `TransactionRepository` into `transaction_tab` | `TransactionTabController` — Drift watch + realtime |
| Expense Insights feature | `ExpenseInsightsScreen`, `SpendingIntelligenceService`, AI briefing, Pro gate |
| Premium subscriptions | `PremiumSubscriptionController`, IAP, Supabase sync |
| Loan enhancements | `LoanInterest`, `RepaymentSchedule`, `created_by`, repayment day fields |
| Friends cancel pending | `cancelFriendRequest` + RLS policy |
| Unit tests | `spending_intelligence_service_test`, `insights_pro_gate_test` |

---

## P0 — Critical

| # | Task | Effort | Risk | Depends on | Notes |
|---|------|--------|------|------------|-------|
| 1 | Add `HomeController` + `PersonalTransactionRepository` | L | Med | Drift table exists | Migrate `home_screen.dart` — largest remaining direct Supabase hotspot |
| 2 | Wire add-transaction flow through `TransactionRepository` | M | Med | — | `TransactionTabController` done; `add_transaction_screen` may still bypass repo |
| 3 | Fix broken `test/widget_test.dart` | S | Low | — | Replace counter test |
| 4 | Remove `Get.offAllNamed('/')` in `GoalDetailsController` | S | Low | — | Use `Get.back(result: true)` |

---

## P1 — Architecture

| # | Task | Effort | Risk | Depends on | Notes |
|---|------|--------|------|------------|-------|
| 5 | Add `SyncStatusBanner` to Home + Group app bars | S | Low | — | `SyncService.syncStatus` stream |
| 6 | `FriendRepository` + migrate `FriendsController` | M | Low | — | `LocalFriends` table ready |
| 7 | `LoanRepository` or service-only controller for lending | M | Low | — | `lending_dashboard.dart` |
| 8 | `ProfileController` — extract from `profile_screen.dart` | M | Low | — | |
| 9 | Move `currency_controller.dart` + `premium_subscription_controller.dart` to `Controller/` | S | Low | — | Folder cleanup |
| 10 | Replace `Navigator.push` with `Get.to` (remaining files) | M | Low | — | `expense_insights_screen` still uses `Navigator.pop` |
| 11 | `InsightsController` — extract state from `ExpenseInsightsScreen` | M | Low | — | StatefulWidget + direct service calls |

---

## P2 — Folder & dependency cleanup

| # | Task | Effort | Risk | Depends on | Notes |
|---|------|--------|------|------------|-------|
| 12 | Extract widgets from `shared.dart` → `Widgets/` | L | Med | — | 989 lines; incremental |
| 13 | Move `Constants/*_widget.dart` to `Widgets/` on touch | M | Low | — | emoji, sync, swipe, glass |
| 14 | Remove unused deps: `salomon_bottom_bar`, `rxdart` | S | Low | — | pubspec cleanup |
| 15 | Remove Appwrite stub from `git_ignore.dart` | S | Low | — | Legacy |
| 16 | Resolve Poppins vs Albra font strategy | S | Med | — | Add Poppins to pubspec or standardize Albra |

---

## P3 — Widget refactoring

| # | Task | Effort | Risk | Depends on | Notes |
|---|------|--------|------|------------|-------|
| 17 | Split `add_transaction_screen.dart` | L | High | #2 | Extract tabs + controller split |
| 18 | Split `AddTransactionScreenController` (many Rx fields) | L | High | #17 | Per sharing-type controllers |
| 19 | Split `monthly_recap_screen.dart` | XL | Med | — | Story + data layers |
| 20 | Split `home_screen.dart`, `profile_screen.dart` | L | Med | #1, #8 | After controllers exist |
| 21 | Split `expense_insights_screen.dart` | M | Low | #11 | Widgets already extracted |
| 22 | Split `transaction_service.dart`, `group_service.dart` | L | Med | — | When adding service methods |

---

## P4 — Testing

| # | Task | Effort | Risk | Depends on | Notes |
|---|------|--------|------|------------|-------|
| 23 | `SettleUpController._simplifyDebts` unit tests | S | Low | — | Pure algorithm |
| 24 | `GroupRepository` in-memory Drift tests | M | Low | — | |
| 25 | `LoanInterest` / `LoanScheduleCalculator` unit tests | S | Low | — | Pure math |
| 26 | `GroupModel.fromJSON` edge case tests | S | Low | — | |
| 27 | Controller tests with `Get.reset()` | M | Low | — | |

---

## P5 — Performance

| # | Task | Effort | Risk | Depends on | Notes |
|---|------|--------|------|------------|-------|
| 28 | Replace nested `FutureBuilder` with single controller load | M | Low | #1, #8 | |
| 29 | Audit large `Obx` scopes | S | Low | — | Per `getx.md` |
| 30 | `ListView.builder` audit on long lists | S | Low | — | |

---

## P6 — Security

| # | Task | Effort | Risk | Depends on | Notes |
|---|------|--------|------|------------|-------|
| 31 | Remove session `debugPrint` from `AuthService` | S | Low | — | |
| 32 | Plan Gemini key proxy (Edge Function) | L | Med | — | Production hardening; optional |
| 33 | Audit Supabase RLS policies | M | High | — | Backend, not Flutter |

---

## Effort key

| Code | Meaning |
|------|---------|
| S | < 1 day |
| M | 1–3 days |
| L | 3–5 days |
| XL | 1+ week |

## Risk key

| Level | Meaning |
|-------|---------|
| Low | Isolated, easy rollback |
| Med | Touches shared flows |
| High | Core split/settlement logic |

---

## Recommended sequence (next 4 sprints)

**Sprint 1:** #1, #3, #4, #5  
**Sprint 2:** #2, #6  
**Sprint 3:** #7, #8, #11  
**Sprint 4:** #17, #18 (add transaction consolidation)

---

## Out of scope (unless explicitly requested)

- Riverpod migration
- Feature-first folder restructure
- GoRouter / named routes
- Full `monthly_recap_screen` rewrite in one PR
- Friends as bottom nav tab (product: Home · Groups · Lending · Profile)
