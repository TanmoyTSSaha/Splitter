# SplitO Architecture Overview

SplitO (`package:splitter`) is a Flutter expense-splitting and personal finance app backed by Supabase with an offline-first Drift layer.

## Layers

```
Screen → Controller → Repository → Service → Supabase / Drift
```

`lib/Bindings/` registers repositories and shared controllers via GetX `Bindings` (`AppBindings` in `main.dart` `initialBinding`).

## Key folders

| Folder | Role |
|--------|------|
| `lib/Screen/` | UI by product domain |
| `lib/Controller/` | GetX state and orchestration |
| `lib/Controllers/` | Legacy: `CurrencyController`, `PremiumSubscriptionController` |
| `lib/Bindings/` | GetX `Bindings` — repository + shared controller registration |
| `lib/Repository/` | Offline cache + sync (groups, transactions) |
| `lib/Services/` | Domain and infrastructure services |
| `lib/Services/SupabaseServices/` | Supabase table CRUD |
| `lib/Services/local/` | Drift database |
| `lib/Model/` | Manual JSON models |
| `lib/Widgets/` | Shared UI |
| `lib/Constants/` | Theme + legacy helpers |

## App shell

4 bottom tabs: **Home · Groups · Lending · Profile** (`IndexedStack` + `AnimatedGlassBottomNavBar`).

Friends: secondary screen from Profile (`Get.to(FriendsScreen)`).

Insights: secondary screen from Profile and Home promo card (`ExpenseInsightsScreen`).

## Bootstrap (`main.dart`)

1. Supabase init (credentials from `git_ignore.dart`)
2. Drift `AppDatabase`
3. `SyncService.startListening()`
4. `RealtimeService`, `ReminderService`, `DeepLinkService`, `ReminderSettingsService`
5. GetX singletons: `appDatabase`, `syncService`, `realtimeService`, `reminderService`, `CurrencyController`, `PremiumSubscriptionController`
6. `GetMaterialApp(initialBinding: AppBindings())`

## Offline wiring (current)

| Entity | Repository | Wired to UI |
|--------|------------|-------------|
| Groups | `GroupRepository` | Yes — `GroupScreenController` |
| Transactions | `TransactionRepository` | Yes — `TransactionTabController` |
| Personal tx | — | No — `home_screen.dart` still uses `SupabaseDatabase()` |
| Friends | — | No |
| Loans | — | No |

`GroupScreenController` uses `watchGroups()` + `refreshFromServer()` + `RealtimeService`. `TransactionTabController` uses `watchTransactions()` + realtime + sync status.

## Insights architecture

```
HomeScreen (InsightsPromoCard) ─┐
ProfileScreen ──────────────────┼→ ExpenseInsightsScreen
                                 │     ↓
                                 │  SpendingIntelligenceService (analytics)
                                 │     ↓
                                 │  AIService.generateInsightsBriefing (Pro)
                                 │     ↓
                                 │  InsightsBriefingCache (7-day TTL)
                                 └→ InsightsProGate (free vs Pro sections)
```

Action cards deep-link via `InsightsNavigation` (settle up, goals, transactions).

## Premium

`PremiumSubscriptionController` — IAP (`in_app_purchase`) + Supabase `premium_subscriptions` + local cache. Gates Pro insight sections via `InsightsProGate` / `PremiumGate`.

## Current gap

Repositories exist and are wired for groups + group transactions. Many other screens still call `SupabaseDatabase()` directly (`home_screen.dart`, friends, lending). Target: extend repository pattern per feature.

## State management

GetX only — no Riverpod, Bloc, or Provider.

## Rules

See `.cursor/rules/` — start with `flutter-rules.md` and `architecture.md`.
