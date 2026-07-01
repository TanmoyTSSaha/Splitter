# GetX Rules — SplitO (Splitter)

## Purpose

Operational GetX conventions for the SplitO app. Extends `flutter-rules.md` and `architecture.md` with **repo-specific** controller, reactive state, dependency injection, and lifecycle patterns.

---

## Responsibilities

| Component | Owns |
|-----------|------|
| **GetxController** | UI state, user action handlers, repository/service orchestration |
| **Bindings** | Register controller + repository + feature services per route |
| **Rx observables** | Reactive fields consumed by `Obx` |
| **Get.put / Get.find** | Dependency injection for controllers and infra |
| **Obx / GetBuilder** | Widget rebuild binding to controller state |

Controllers must **not** build widgets, parse JSON, or access Drift/SQL directly.

---

## Required Conventions

### Controller file location and naming

```
lib/Controller/<feature>_controller.dart
class <Feature>Controller extends GetxController
```

Examples from this repo:

| File | Class |
|------|-------|
| `friends_controller.dart` | `FriendsController` |
| `settle_up_controller.dart` | `SettleUpController` |
| `goal_details_controller.dart` | `GoalDetailsController` |
| `add_transaction_controller.dart` | `AddTransactionScreenController` |

New controllers go in `lib/Controller/`. `lib/Controllers/` holds legacy `currency_controller.dart` and `premium_subscription_controller.dart` — migrate when touched.

### Standard reactive fields

Every data-loading controller should expose at minimum:

```dart
RxBool isLoading = true.obs;
RxString errorMessage = ''.obs;
```

Reference: `SettleUpController` in `lib/Controller/settle_up_controller.dart`:

```dart
RxBool isLoading = true.obs;
RxBool isSettling = false.obs;
RxString errorMessage = ''.obs;
RxList<SimplifiedDebt> simplifiedDebts = <SimplifiedDebt>[].obs;
```

### Lifecycle

```dart
@override
void onInit() {
  super.onInit();
  // read Get.arguments, start initial fetch
}

@override
void onClose() {
  // dispose TextEditingControllers, cancel StreamSubscriptions
  super.onClose();
}
```

Reference: `GoalDetailsController.onInit()` reads `Get.arguments as FinancialGoalModel`.

Controllers holding `TextEditingController` must dispose them in `onClose()` (see `CreateGoalController`).

### Error exposure

Expose errors via `RxString errorMessage` or `Get.snackbar` — not `Fluttertoast` in controllers for new code.

`SettleUpController` pattern (preferred):

```dart
errorMessage.value = "Failed to load balances. Pull to retry.";
```

### Navigation from controllers

Allowed when closing a flow or returning a result:

```dart
Get.back(result: true);
Get.to(() => const SomeScreen());
```

Use `Get.find<CurrencyController>()` for app-wide singletons registered in `main.dart`.

---

## Dependency Injection

### Infrastructure (app-wide, permanent)

Registered in `lib/main.dart`:

```dart
Get.put(appDatabase, permanent: true);
Get.put(syncService, permanent: true);
Get.put(realtimeService, permanent: true);
Get.put(reminderService, permanent: true);
Get.put(ReminderSettingsService(), permanent: true);
Get.put(CurrencyController(), permanent: true);
Get.put(PremiumSubscriptionController(), permanent: true);
Get.put(deepLinkService, permanent: true);
```

Access via `Get.find<SyncService>()`, `Get.find<AppDatabase>()`, `Get.find<PremiumSubscriptionController>()`, etc.

### App-wide bindings (`AppBindings`)

`lib/Bindings/app_bindings.dart` — registered via `GetMaterialApp(initialBinding: AppBindings())`:

```dart
class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GroupRepository(Get.find<AppDatabase>(), Get.find<SyncService>()), fenix: true);
    Get.lazyPut(() => TransactionRepository(Get.find<AppDatabase>(), Get.find<SyncService>()), fenix: true);
    Get.lazyPut(() => GroupScreenController(), fenix: true);
    Get.lazyPut(() => NotificationBadgeController(), fenix: true);
  }
}
```

### Feature controllers (target — use Bindings for new features)

**New features must provide a Binding:**

```dart
// lib/Controller/group_detail_binding.dart
class GroupDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GroupRepository(Get.find<AppDatabase>(), Get.find<SyncService>()));
    Get.lazyPut(() => GroupDetailController(
      repository: Get.find<GroupRepository>(),
    ));
  }
}
```

Navigate with:

```dart
Get.to(() => const GroupDetailedScreen(), binding: GroupDetailBinding());
```

### Legacy pattern (do not copy for new code)

Controllers instantiated in screen `initState`:

```dart
// Anti-pattern — existing only
Get.put(AddTransactionScreenController());
```

Replace with Binding when touching the screen.

### Constructor injection for parameterized controllers

`SettleUpController` requires `groupID` and `userID`:

```dart
class SettleUpController extends GetxController {
  final String groupID;
  final String userID;
  SettleUpController({required this.groupID, required this.userID});
}
```

Register in Binding with route arguments:

```dart
Get.lazyPut(() => SettleUpController(
  groupID: Get.arguments['groupID'],
  userID: Get.arguments['userID'],
));
```

---

## State Management Patterns

### When to use Rx + Obx

Use for fields that change and drive UI updates:

```dart
RxBool isLoading = true.obs;
RxList<FriendModel> friends = <FriendModel>[].obs;
RxInt currentTabIndex = 0.obs;
```

Wrap **only** the widget subtree that reads the reactive value:

```dart
Obx(() => isLoading.value
  ? const CircularProgressIndicator()
  : ListView.builder(...))
```

### When to use GetBuilder + update()

Use when updating non-Rx state or a whole section after batch changes:

```dart
// GoalDetailsController — mutates goal object then:
update(); // triggers GetBuilder listeners
```

Prefer `Rx` for new code. Use `update()` only when migrating legacy `GetBuilder` screens.

### When setState is allowed

**Only** in `BottomNavigationController` (app shell tab index). New feature screens must not use `setState` for business state — use a controller.

### Mixed Rx + update() in one controller

`AddTransactionScreenController` uses both (legacy). New controllers: **Rx only**, avoid `update()` unless wrapping existing `GetBuilder` widgets.

---

## Controller → Data Layer

### Target (new code)

```dart
// GroupScreenController — wired pattern
class GroupScreenController extends GetxController {
  final GroupRepository _repository = Get.find();
  // watchGroups() stream + refreshFromServer()
}
```

### Interim (existing controllers)

Direct service/facade calls are present in legacy controllers:

| Controller | Current data access | Migration target |
|------------|--------------------|--------------------|
| `SettleUpController` | `SupabaseDatabase()` | `GroupRepository` |
| `FriendsController` | `SupabaseDatabase()` | `FriendRepository` |
| `GoalDetailsController` | `GoalService`, `GoalTransactionService` | `GoalRepository` |
| `CreateGoalController` | `GoalService`, `AIService` | keep `AIService`; goal writes via repository |
| `AnalyticsController` | `SupabaseDatabase()` | `TransactionRepository` |
| `ExpenseInsightsScreen` | `SpendingIntelligenceService` directly in StatefulWidget | `InsightsController` |

Do not add new `SupabaseDatabase()` calls inside controllers for entities that have or will have a repository.

---

## Forbidden Practices

| Forbidden | Why |
|-----------|-----|
| `BuildContext` in controller | Controllers are not widgets |
| Widget imports for layout | No `Scaffold`, `Column` in controllers |
| `Supabase.instance.client` in controller | Use repository or service |
| `AppDatabase` direct access in controller | Use repository |
| `SharedPreferences` in controller | Use a prefs service injected via Get |
| God controller (> 15 Rx fields for unrelated concerns) | Split controllers per screen/flow |
| `Obx` wrapping entire `Scaffold` | Causes full-tree rebuilds |
| `Get.put` in `build()` | Registers on every rebuild |
| Creating `TextEditingController` without `onClose` dispose | Memory leak |
| `Get.offAllNamed('/')` without named routes configured | Broken navigation (`GoalDetailsController` line 78 — fix when touched) |

---

## Naming Conventions

| Item | Convention |
|------|------------|
| Controller class | `<Feature>Controller` or `<Feature>ScreenController` (match existing screen name) |
| Binding class | `<Feature>Binding` |
| Loading flag | `isLoading` |
| Submitting flag | `isSubmitting` or `isSaving` |
| Error | `errorMessage` (`RxString`) |
| List data | `RxList<Model>` named plural: `friends`, `transactions`, `groups` |
| Selected item | `selected<T>` or `selectedTabIndex` |

---

## Preferred Patterns

### Fetch with loading/error trifecta

```dart
Future<void> fetchData() async {
  try {
    isLoading.value = true;
    errorMessage.value = '';
    // await _repository.refreshFromServer(...);
    // or assign to RxList from stream
  } catch (e) {
    debugPrint('FeatureController fetchData: $e');
    errorMessage.value = 'Could not load data. Pull to retry.';
  } finally {
    isLoading.value = false;
  }
}
```

From `SettleUpController.fetchAndSimplifyDebts()`.

### Pass data via Get.arguments

```dart
// Sending screen
Get.to(() => const GoalDetailsScreen(), arguments: goalModel);

// Controller onInit
goal = Get.arguments as FinancialGoalModel;
```

### Access currency singleton

```dart
Get.find<CurrencyController>().code
```

Used in `SettleUpController.recordSettlement()` and `GoalDetailsController.addTransaction()`.

### Snackbar feedback (project style)

```dart
Get.snackbar("Success", "Transaction added",
  backgroundColor: neopopAccent, colorText: Colors.black);
Get.snackbar("Error", "Failed to add transaction",
  backgroundColor: neopopError, colorText: Colors.white);
```

Import colors from `package:splitter/Constants/constants.dart`.

---

## Anti-Patterns (from this codebase)

### God controller — `AddTransactionScreenController`

~42 `.obs` fields covering tab index, checkboxes, share amounts, percentage splits, item splits. **Do not extend this pattern.**

Split into focused controllers or extract calculation logic to a service:

- `AddTransactionFormController` — tab + category + amount
- `EvenShareController` / `UnevenShareController` — per sharing type tab

### Controller calling facade inline

```dart
// settle_up_controller.dart — legacy
await SupabaseDatabase().getGroupBalancesForSettleUp(groupID: groupID);
```

Migrate to injected repository.

### Controller owning TextEditingControllers without dispose

`CreateGoalController` has 4 `TextEditingController`s — ensure `onClose` disposes all (add if missing when editing).

### Service instantiation inside controller

```dart
final GoalService _goalService = GoalService(); // legacy
```

Prefer injection via Binding: `Get.lazyPut(() => GoalService())` or access through repository.

---

## Examples from This Repository

### Well-structured controller skeleton

```dart
// Pattern derived from SettleUpController + GoalDetailsController
class ExampleController extends GetxController {
  final ExampleRepository _repository;

  ExampleController(this._repository);

  RxBool isLoading = true.obs;
  RxString errorMessage = ''.obs;
  RxList<ExampleModel> items = <ExampleModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadItems();
  }

  Future<void> loadItems() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      items.assignAll(await _repository.getItems());
    } catch (e) {
      errorMessage.value = 'Failed to load items.';
    } finally {
      isLoading.value = false;
    }
  }
}
```

### Screen consuming controller

```dart
class ExampleScreen extends GetView<ExampleController> {
  const ExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }
        return ListView.builder(
          itemCount: controller.items.length,
          itemBuilder: (_, i) => Text(controller.items[i].name ?? ''),
        );
      }),
    );
  }
}
```

`GetView<ExampleController>` requires controller registered before build (via Binding).

---

## Migration Guidance

### When adding a controller to a screen that lacks one

1. Create `lib/Controller/<feature>_controller.dart`.
2. Create `lib/Controller/<feature>_binding.dart`.
3. Move `FutureBuilder` data loading from screen to controller `onInit`.
4. Move button `onPressed` async logic to controller methods.
5. Replace screen `setState` with `Obx`.
6. Screen keeps only layout and `controller.method()` calls.

Priority screens without controllers: `home_screen.dart`, `profile_screen.dart`, `expense_insights_screen.dart`. `group_screen.dart` has `GroupScreenController`; `lending_dashboard.dart` uses `LendingRefreshController` only.

### When touching an existing controller

- Add `onClose` disposal if missing.
- Replace new `SupabaseDatabase()` calls with repository injection.
- Do not add more `.obs` fields to `AddTransactionScreenController` — extract instead.

### Bindings rollout order

1. ~~Group flow (`GroupScreenController`, `TransactionTabController`)~~ **Done** via `AppBindings`
2. Home (`HomeController` + `PersonalTransactionRepository`)
3. Insights (`InsightsController`)
4. Lending (`LendingController` — beyond refresh trigger)
5. Profile (`ProfileController`)

---

## AI Instructions

1. Always extend `GetxController` — never introduce other state libraries.
2. Register feature controllers via `Bindings` for all **new** screens.
3. Use `GetView<MyController>` when the screen only displays one controller's state.
4. Expose `isLoading`, `errorMessage`, and data as `Rx` types.
5. Call repositories from controllers — not `SupabaseDatabase()` for group/transaction entities.
6. Use `Get.find<CurrencyController>()` for currency code — do not duplicate currency state.
7. Dispose `TextEditingController`, `Timer`, and `StreamSubscription` in `onClose`.
8. Keep `Obx` scopes minimal — one list item or one status indicator per `Obx` where possible.
9. Use `Get.snackbar` with `neopopAccent` / `neopopError` for user feedback.
10. If a screen already uses `Get.put` in `initState`, add a TODO-free Binding only when migrating that screen — do not mix both patterns on the same route.
