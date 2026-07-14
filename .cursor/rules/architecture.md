# Architecture Rules — Splitr

## Purpose

Define the **layer-by-type architecture** for the Splitr Flutter app (`package:splitr`). This file is the structural map: where code lives, which layers may import which, and how data flows from UI to Supabase/Drift.

Use alongside `flutter-rules.md` (general engineering contract) and specialized rules (`getx.md`, `repository.md`, `supabase.md`, etc.).

---

## Responsibilities

| Layer | Folder | Responsibility |
|-------|--------|----------------|
| **View** | `lib/Screen/` | UI rendering, user input forwarding to controllers |
| **Controller** | `lib/Controller/` | UI state, user actions, orchestration of repositories |
| **Bindings** | `lib/Bindings/` | GetX `Bindings` — register repositories + feature controllers |
| **Model** | `lib/Model/` | Domain/API data shapes, `fromJSON`/`toJSON` |
| **Repository** | `lib/Repository/` | Local cache (Drift) + sync queue + remote refresh |
| **Service** | `lib/Services/` | Domain logic, Supabase access, device capabilities |
| **Supabase service** | `lib/Services/SupabaseServices/` | Table-scoped Supabase CRUD |
| **Local DB** | `lib/Services/local/` | Drift `AppDatabase` schema + generated code |
| **Widget** | `lib/Widgets/` | Cross-feature reusable UI |
| **Constants** | `lib/Constants/` | Theme tokens, legacy shared widgets (do not add new widgets here) |
| **Credentials** | `lib/git_ignore.dart` | API keys and environment secrets |

---

## Target Data Flow

All **new** features must follow this flow:

```
Screen (View)
    ↓  user events / Obx reads
Controller (GetxController)
    ↓  async calls
Repository (Drift + SyncService + remote refresh)
    ↓  when remote needed
SupabaseServices / domain Services
    ↓
Supabase SDK  |  AppDatabase (Drift)
```

Infrastructure registered once in `main.dart`:

```dart
// lib/main.dart — pattern to preserve
await Supabase.initialize(url: supabaseURL, anonKey: supabaseAnonPublicKey);
appDatabase = AppDatabase();
syncService = SyncService(appDatabase);
syncService.startListening();
realtimeService = RealtimeService();
reminderService = ReminderService();
await reminderService.initialize();
Get.put(appDatabase, permanent: true);
Get.put(syncService, permanent: true);
Get.put(realtimeService, permanent: true);
Get.put(reminderService, permanent: true);
Get.put(ReminderSettingsService(), permanent: true);
Get.put(CurrencyController(), permanent: true);
Get.put(PremiumSubscriptionController(), permanent: true);
deepLinkService = DeepLinkService();
Get.put(deepLinkService, permanent: true);
await deepLinkService.initialize();

// GetMaterialApp(initialBinding: AppBindings())
```

---

## Allowed Dependency Direction

```
Screen       →  Controller, Widgets, Constants, Model (display only)
Controller   →  Repository, Model, Services (orchestration only)
Repository   →  AppDatabase, SyncService, SupabaseServices, Model
Service      →  Supabase SDK, other Services, Model
Model        →  (nothing from Screen/Controller/Service)
Widgets      →  Constants, Model (display), other Widgets
Constants    →  Flutter SDK, theme packages only
```

### Forbidden imports

| From | Must NOT import |
|------|-----------------|
| `Model/` | `Screen/`, `Controller/`, `Repository/`, `Services/` |
| `Screen/` | `Services/SupabaseServices/` directly (use Controller → Repository) |
| `Screen/` | `Services/local/database.dart` directly |
| `Repository/` | `Screen/`, `Controller/`, `Widgets/` |
| `Widgets/` | `Controller/`, `Repository/`, `Services/` |

**Legacy exception:** Existing screens that call `SupabaseDatabase()` or `SupabaseAuth()` directly may remain until migrated. Do not copy this pattern into new code.

---

## Folder Conventions

### `lib/Screen/` — feature screens by domain

Organize by product area, not by layer:

```
lib/Screen/
├── AuthScreens/           # login, register, biometric lock
├── BottomNavigationController/  # app shell (4-tab nav)
├── FriendScreen/          # friends (secondary — not a bottom tab)
├── GoalScreen/
├── GroupScreen/
│   ├── GraphAnalysisWidgets/   # feature-scoped charts
│   └── SharingTypeTabs/        # split-type tab UIs
├── HomeScreen/
├── Insights/
│   └── widgets/               # insights_* cards, score ring, social trust
├── LendingScreen/
├── NotificationScreen/
├── OnboardingScreen/
├── ProfileScreen/
├── TripScreen/
└── FeatureComingUp/       # placeholder for unfinished features
```

- Screen files: `*_screen.dart` or `*_tab.dart` for tab bodies.
- Large feature-specific widgets stay inside the feature folder (e.g. `GroupScreen/GraphAnalysisWidgets/`).
- Do **not** create `data/`, `domain/`, `presentation/` subfolders — this project uses layer-by-type at the `lib/` root.

### `lib/Controller/` — GetX controllers

- One controller per feature screen or cohesive flow.
- File naming: `<feature>_controller.dart`, class: `<Feature>Controller`.
- **All new controllers go in `Controller/`**, not `Controllers/`.
- `lib/Controllers/currency_controller.dart` and `premium_subscription_controller.dart` are legacy — migrate to `Controller/` when touched.

Existing controllers (reference):

| Controller | Feature |
|------------|---------|
| `AuthController` | Auth |
| `GroupScreenController` | Group list (wired to `GroupRepository`) |
| `TransactionTabController` | Group transactions tab (wired to `TransactionRepository`) |
| `AddTransactionScreenController` | Add/edit group expense |
| `AnalyticsController` | Group analytics tab |
| `SettleUpController` | Settlement flow |
| `FriendsController` | Friends list |
| `CreateGoalController` | Create goal |
| `GoalDetailsController` | Goal detail |
| `LendingRefreshController` | Lending tab refresh trigger |
| `NotificationBadgeController` | Notification badge count |
| `CurrencyController` | Currency preference (`Controllers/`) |
| `PremiumSubscriptionController` | Splitr Pro IAP (`Controllers/`) |

### `lib/Model/` — domain models

- One file per entity: `group_model.dart`, `friend_model.dart`, etc.
- Manual serialization: `fromJSON` / `toJSON` (project convention — see `models.md`).

### `lib/Repository/` — offline-first data access

Reference implementations:

- `group_repository.dart` — `watchGroups()`, `refreshFromServer()`, `createGroup()` with sync queue
- `transaction_repository.dart` — `watchTransactions()`, `refreshFromServer()`, local-first writes

New entities needing offline support get a matching repository (e.g. `FriendRepository`, `LoanRepository`).

### `lib/Services/` — infrastructure and domain services

| Category | Examples |
|----------|----------|
| **Facade** | `supabase_service.dart` → `SupabaseAuth`, `SupabaseDatabase` |
| **Supabase CRUD** | `SupabaseServices/auth_service.dart`, `group_service.dart`, `transaction_service.dart`, … |
| **Device / platform** | `biometric_auth_service.dart`, `reminder_service.dart`, `receipt_parser_service.dart` |
| **Domain** | `trip_service.dart`, `wishlist_service.dart`, `activity_service.dart`, `ai_service.dart`, `spending_intelligence_service.dart` |
| **Insights** | `insights_briefing_cache.dart`, `insights_navigation.dart` |
| **Sync / realtime** | `sync_service.dart`, `realtime_service.dart`, `deep_link_service.dart` |
| **Local DB** | `local/database.dart`, `local/database.g.dart` (generated — do not edit) |

Domain services that perform remote I/O should eventually be called **only from repositories**, not from screens.

### `lib/Widgets/` — cross-feature reusable UI

Only widgets used by **two or more features**. Feature-specific UI stays in `Screen/<Feature>/`.

Current shared widgets include: `active_group_card`, `custom_big_text_form_field`, `summary_stat_card`, `transaction_tile`, `trip_gradient_card`, `user_avatar`, `pill_tab_bar`, `animated_glass_bottom_nav_bar`, `insights_pro_gate`, `insights_promo_card`, `premium_gate`, `notification_bell_button`, `badge_unlock_toast`.

### `lib/Constants/` — theme and legacy helpers

- `constants.dart` — colors, typography, `neopopColorScheme`, `splitter_custom_text_theme`
- `shared.dart` — legacy form fields and helpers (**do not add new widgets** — use `Widgets/`)
- Visual primitives: `glass_card.dart`, `gradient_mesh_background.dart`, `sync_indicator_widget.dart`

---

## App Shell & Navigation Architecture

Bottom navigation is defined in `BottomNavigationController`:

| Index | Tab | Screen |
|-------|-----|--------|
| 0 | Home | `HomeScreen` |
| 1 | Groups | `GroupScreen` |
| 2 | Lending | `LendingDashboard` |
| 3 | Profile | `ProfileScreen` |

Implementation: `IndexedStack` preserves tab state. Uses `StatefulWidget` + `setState` for tab index (acceptable for shell only). Custom bar: `AnimatedGlassBottomNavBar`.

**Friends** is **not** a bottom tab. Access via `Get.to(() => const FriendsScreen())` from Profile (`profile_screen.dart`). Keep this pattern for Friends.

**Insights** is **not** a bottom tab. Access via `Get.to(() => const ExpenseInsightsScreen())` from Profile and Home (`InsightsPromoCard`).

Auth entry in `main.dart`:

```
Onboarding (first launch)
  → BiometricLock (if session + biometric enabled)
  → BottomNavigationController (if session)
  → LoginScreen (no session)
```

---

## Feature Map

| Domain | Screen folder | Controller | Repository | Supabase service |
|--------|---------------|------------|------------|------------------|
| Home / personal tx | `HomeScreen/` | — (needs `HomeController`) | — (needs repo) | `transaction_service` |
| Groups | `GroupScreen/` | `GroupScreenController`, `TransactionTabController`, `AddTransactionScreenController`, `AnalyticsController`, `SettleUpController` | `GroupRepository` ✓, `TransactionRepository` ✓ | `group_service`, `transaction_service` |
| Friends | `FriendScreen/` | `FriendsController` | — (needs repo) | `friend_service` |
| Lending | `LendingScreen/` | `LendingRefreshController` | — (needs repo) | `loan_service` |
| Goals | `GoalScreen/` | `CreateGoalController`, `GoalDetailsController` | — | `goal_service`, `goal_transaction_service` |
| Trips | `TripScreen/` | — | — | via `group_service` / `trip_service` |
| Profile | `ProfileScreen/` | — | — | `user_service` |
| Auth | `AuthScreens/` | `AuthController` | — | `auth_service` |
| Notifications | `NotificationScreen/` | `NotificationBadgeController` | — | `notification_service` |
| Insights | `Insights/` | — (needs `InsightsController`) | — | `spending_intelligence_service`, `ai_service` |
| Premium | `ProfileScreen/premium_plan_screen` | `PremiumSubscriptionController` | — | `premium_subscriptions` table |

Blank cells indicate migration targets — not permission to call Supabase from screens in new code.

---

## Offline-First Architecture

Offline is a **required product capability**, not a connectivity fallback.

### Write path (target)

1. Controller calls repository method.
2. Repository writes to Drift with `syncStatus: 'pending'`.
3. Repository enqueues item via `SyncService`.
4. `SyncService` pushes to Supabase when online (`connectivity_plus` listener in `main.dart`).

### Read path (target)

1. Controller subscribes to repository `watch*()` Drift stream.
2. UI binds via `Obx`.
3. On pull-to-refresh or screen open, controller calls `repository.refreshFromServer()`.
4. User sees cached data immediately; UI updates when refresh completes.

### Sync UI

Use `SyncIndicator` / `SyncStatusBanner` from `Constants/sync_indicator_widget.dart`, fed by `SyncService.syncStatus` stream.

---

## Preferred Patterns

### New feature checklist

1. `lib/Screen/<Feature>/` — screen(s)
2. `lib/Controller/<feature>_controller.dart` — GetX controller
3. `lib/Bindings/<feature>_binding.dart` or extend `app_bindings.dart` — register controller + repository
4. `lib/Repository/<entity>_repository.dart` — if entity needs offline or sync
5. `lib/Model/<entity>_model.dart` — if new entity
6. `lib/Services/SupabaseServices/<entity>_service.dart` — if new Supabase table cluster
7. Reuse `lib/Widgets/` before creating new shared components

### Facade for Supabase (interim)

Until repositories cover all entities, controllers may call `SupabaseDatabase()` / `SupabaseAuth()` — **legacy only**. New group/transaction code must use `GroupRepository` / `TransactionRepository`.

### Service registration

Infrastructure singletons: register in `main.dart` with `Get.put(..., permanent: true)`.

Feature dependencies: register in `Bindings`, not in `initState`.

---

## Anti-Patterns (Observed — Do Not Repeat)

| Anti-pattern | Example in codebase | Correct approach |
|--------------|--------------------|--------------------|
| Screen calls Supabase directly | `home_screen.dart` — `SupabaseDatabase()` as field | `HomeController` → repository |
| StatefulWidget owns service calls | `expense_insights_screen.dart` — `SpendingIntelligenceService` in `initState` | `InsightsController` |
| Business logic in screen callbacks | `add_transaction_screen.dart` — `addGroupExpense()` in button handler | Controller method → repository |
| God screen file | `monthly_recap_screen.dart` (2,479 lines) | Extract widgets + controller |
| New widget in Constants | `emoji_reaction_widget.dart` in `Constants/` | Place in `Widgets/` or feature folder |
| Split controller folder | `Controllers/currency_controller.dart` | `Controller/currency_controller.dart` |
| Direct `Supabase.instance.client` in screen | `create_group_screen.dart` | Service or repository |
| Nested `FutureBuilder` chains | `group_screen.dart` | Controller loads data once, exposes `Rx` state |

---

## Naming Conventions

| Artifact | Convention | Example |
|----------|------------|---------|
| Screen folder | PascalCase + `Screen` | `GroupScreen/` |
| Screen file | snake_case | `group_detailed_screen.dart` |
| Controller file | snake_case + `_controller` | `friends_controller.dart` |
| Controller class | PascalCase + `Controller` | `FriendsController` |
| Repository file | snake_case + `_repository` | `group_repository.dart` |
| Service file | snake_case + `_service` | `trip_service.dart` |
| Model file | snake_case + `_model` | `group_model.dart` |
| Model class | PascalCase + `Model` | `GroupModel` |
| JSON methods | `fromJSON` / `toJSON` | `GroupModel.fromJSON` |
| Drift table class | `Local*` | `LocalGroup`, `LocalGroupTransaction` |
| Supabase methods | `supabase` prefix (legacy) | `supabaseEmailPassSignIn` |

---

## Examples from This Repository

### Correct infrastructure bootstrap

```dart
// lib/main.dart
await Supabase.initialize(url: supabaseURL, anonKey: supabaseAnonPublicKey);
appDatabase = AppDatabase();
syncService = SyncService(appDatabase);
syncService.startListening();
Get.put(appDatabase, permanent: true);
Get.put(syncService, permanent: true);
```

### Reference repository pattern

```dart
// lib/Repository/group_repository.dart
Stream<List<LocalGroup>> watchGroups() => _db.watchAllGroups();

Future<void> createGroup({...}) async {
  await _db.upsertGroup(LocalGroupsCompanion(..., syncStatus: const Value('pending')));
  await _syncService.enqueue(...);
}
```

### Friends access (secondary feature, not bottom tab)

```dart
// lib/Screen/ProfileScreen/profile_screen.dart
onTap: () => Get.to(() => const FriendsScreen()),
```

### Feature-scoped widget colocation

```
lib/Screen/GroupScreen/SharingTypeTabs/even_share_tab.dart   # split UI
lib/Screen/GroupScreen/GraphAnalysisWidgets/spending_trends_chart.dart  # charts
```

---

## Migration Guidance

### Phase 1 — Stop the bleeding (new code)

- New screens: always add Controller + Binding.
- New group/transaction code: use existing repositories.
- No new `SupabaseDatabase()` instantiation in screens.

### Phase 2 — Wire offline (high-traffic features)

1. ~~`GroupScreen` / `transaction_tab` → `GroupRepository` + `TransactionRepository`~~ **Done** via `AppBindings`, `GroupScreenController`, `TransactionTabController`
2. `HomeScreen` → `HomeController` → `PersonalTransactionRepository`
3. Add `SyncStatusBanner` to `GroupScreen` and `HomeScreen` app bars

### Phase 3 — Consolidate services behind repositories

- `LendingScreen` → `LoanRepository` wrapping `LoanService`
- `FriendScreen` → `FriendRepository` wrapping `FriendService`
- ~~Move `RealtimeService` subscriptions into group controllers~~ **Done** in `GroupScreenController` + `TransactionTabController`
- `ExpenseInsightsScreen` → `InsightsController` (screen still StatefulWidget + direct service calls)

### Phase 4 — Cleanup

- Merge `Controllers/` into `Controller/`
- Extract widgets from `shared.dart` into `Widgets/`
- Split god screens (`monthly_recap_screen`, `add_transaction_screen`, `home_screen`)

When editing a legacy file, migrate only the code path you touch — do not refactor unrelated sections in the same PR.

---

## AI Instructions

When generating code for this project:

1. Read this file first to determine **where** new code belongs.
2. Follow the target flow: Screen → Controller → Repository → Service.
3. Place files in the correct layer folder — never create `feature/data/domain/presentation` structure.
4. Use the 4-tab bottom nav (Home · Groups · Lending · Profile). Do not add Friends as a bottom tab.
5. Register new feature dependencies via `Bindings`, infrastructure via `main.dart`.
6. For offline-capable entities, always include repository + Drift write with `syncStatus`.
7. Colocate feature-specific widgets; only promote to `lib/Widgets/` when reused across features.
8. If unsure whether a repository exists, check `lib/Repository/` before calling `SupabaseDatabase()`.
9. Match naming conventions in this file even when they differ from generic Dart style (`fromJSON`, `supabase` prefix).
10. Do not introduce Riverpod, Bloc, GoRouter, Dio, or feature-first folder restructuring.
