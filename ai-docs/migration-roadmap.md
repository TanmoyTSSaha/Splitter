# SplitO Migration Roadmap

Prioritized path from current state to target architecture (GetX + repositories + offline-first). **No application code changes in this document** — implementation order only.

---

## P0 — Critical

| # | Task | Effort | Risk | Depends on | Notes |
|---|------|--------|------|------------|-------|
| 1 | Wire `GroupRepository` into `GroupScreen` + `GroupScreenController` | M | Low | — | Replace `FutureBuilder` + `SupabaseDatabase.getGroupData` |
| 2 | Wire `TransactionRepository` into `transaction_tab` + add-transaction flow | L | Med | #1 | Largest user-facing offline win |
| 3 | Add `HomeController` + `PersonalTransactionRepository` | L | Med | Drift table exists | Migrate `home_screen.dart` |
| 4 | Register repositories in Bindings | S | Low | #1–3 | Establish pattern for all features |
| 5 | Fix broken `test/widget_test.dart` | S | Low | — | Replace counter test |
| 6 | Remove `Get.offAllNamed('/')` in `GoalDetailsController` | S | Low | — | Use `Get.back(result: true)` |

---

## P1 — Architecture

| # | Task | Effort | Risk | Depends on | Notes |
|---|------|--------|------|------------|-------|
| 7 | Add `SyncStatusBanner` to Home + Group app bars | S | Low | #1 | `SyncService.syncStatus` stream |
| 8 | Wire `RealtimeService` in group detail controller | M | Med | #2 | Subscribe/unsubscribe per group |
| 9 | `FriendRepository` + migrate `FriendsController` | M | Low | — | `LocalFriends` table ready |
| 10 | `LoanRepository` or service-only with controller for lending | M | Low | — | `lending_dashboard.dart` |
| 11 | `ProfileController` — extract from `profile_screen.dart` | M | Low | — | 660 lines |
| 12 | Move `currency_controller.dart` to `Controller/` | S | Low | — | Folder cleanup |
| 13 | Replace `Navigator.push` with `Get.to` (13 files) | M | Low | — | Touch per file |

---

## P2 — Folder & dependency cleanup

| # | Task | Effort | Risk | Depends on | Notes |
|---|------|--------|------|------------|-------|
| 14 | Extract widgets from `shared.dart` → `Widgets/` | L | Med | — | 989 lines; incremental |
| 15 | Move `Constants/*_widget.dart` to `Widgets/` on touch | M | Low | — | emoji, sync, swipe, glass |
| 16 | Remove unused deps: `salomon_bottom_bar`, `rxdart` | S | Low | — | pubspec cleanup |
| 17 | Remove Appwrite stub from `git_ignore.dart` | S | Low | — | Legacy |
| 18 | Resolve Poppins vs Albra font strategy | S | Med | — | Add Poppins to pubspec or standardize Albra |

---

## P3 — Widget refactoring

| # | Task | Effort | Risk | Depends on | Notes |
|---|------|--------|------|------------|-------|
| 19 | Split `add_transaction_screen.dart` (745 lines) | L | High | #2, #4 | Extract tabs + controller split |
| 20 | Split `AddTransactionScreenController` (42 Rx fields) | L | High | #19 | Per sharing-type controllers |
| 21 | Split `monthly_recap_screen.dart` (2,479 lines) | XL | Med | — | Story + data layers |
| 22 | Split `home_screen.dart`, `group_screen.dart`, `profile_screen.dart` | L | Med | #3, #1, #11 | After controllers exist |
| 23 | Split `transaction_service.dart`, `group_service.dart` | L | Med | — | When adding service methods |

---

## P4 — Testing

| # | Task | Effort | Risk | Depends on | Notes |
|---|------|--------|------|------------|-------|
| 24 | `SettleUpController._simplifyDebts` unit tests | S | Low | — | Pure algorithm |
| 25 | `GroupRepository` in-memory Drift tests | M | Low | #1 | |
| 26 | `GroupModel.fromJSON` edge case tests | S | Low | — | |
| 27 | Controller tests with `Get.reset()` | M | Low | #4 | |

---

## P5 — Performance

| # | Task | Effort | Risk | Depends on | Notes |
|---|------|--------|------|------------|-------|
| 28 | Replace nested `FutureBuilder` with single controller load | M | Low | #1, #11 | |
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

## Recommended sequence (first 4 sprints)

**Sprint 1:** #1, #4, #6, #7, #5  
**Sprint 2:** #2, #8  
**Sprint 3:** #3, #9, #11  
**Sprint 4:** #19, #20 (add transaction consolidation)

---

## Out of scope (unless explicitly requested)

- Riverpod migration
- Feature-first folder restructure
- GoRouter / named routes
- Full `monthly_recap_screen` rewrite in one PR
- Friends as bottom nav tab (product: Home · Groups · Lending · Profile)
