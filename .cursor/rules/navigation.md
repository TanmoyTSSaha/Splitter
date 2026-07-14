# Navigation Rules — Splitr

## Purpose

Navigation patterns for Splitr: app shell, auth flow, GetX navigation, and secondary routes.

---

## App Shell

### Bottom navigation (4 tabs)

Defined in `lib/Screen/BottomNavigationController/bottom_navigation_controller.dart`:

| Index | Label | Screen |
|-------|-------|--------|
| 0 | HOME | `HomeScreen` |
| 1 | GROUPS | `GroupScreen` |
| 2 | LENDING | `LendingDashboard` |
| 3 | PROFILE | `ProfileScreen` |

Implementation:

- `StatefulWidget` + `setState` for `currIndex` (acceptable for shell only)
- `IndexedStack` preserves tab state
- Custom bottom bar: `AnimatedGlassBottomNavBar` in `lib/Widgets/` (not `salomon_bottom_bar` package)

**Do not add a 5th tab without explicit approval.** Friends is not a bottom tab.

---

## Auth & Launch Flow

```
main.dart → MyApp._getInitialScreen()

!hasSeenOnboarding     → OnboardingScreen
hasSession + biometric → BiometricLockScreen
hasSession             → BottomNavigationController
else                   → LoginScreen
```

Session check:

```dart
SupabaseAuth().supabaseRetrieveSession()
```

Onboarding flag: `SharedPreferences` key `hasSeenOnboarding`.

---

## GetX Navigation (Preferred)

Use for all new routes:

```dart
Get.to(() => const FriendsScreen());
Get.to(() => const GroupDetailedScreen(), arguments: groupModel);
Get.to(() => const ExampleScreen(), binding: ExampleBinding());
Get.off(() => const LoginScreen());
Get.offAll(() => const BottomNavigationController());
Get.back(result: true);
```

### Pass arguments

```dart
// Navigate
Get.to(() => const GoalDetailsScreen(), arguments: goalModel);

// Controller
goal = Get.arguments as FinancialGoalModel;
```

### Return results

```dart
Get.back(result: true); // caller: final refreshed = await Get.to(...);
```

---

## Secondary Routes (Not Bottom Tabs)

Accessed via `Get.to` from parent screens:

| Screen | Accessed from |
|--------|---------------|
| `FriendsScreen` | `ProfileScreen` — `Get.to(() => const FriendsScreen())` |
| `GroupDetailedScreen` | `GroupScreen` |
| `AddTransactionScreen` | Group flow |
| `CreateGoalScreen` / `GoalDetailsScreen` | Home / profile |
| `CreateTripScreen` / `TripTimelineScreen` | Group screen |
| `ExpenseInsightsScreen` | Profile, Home (`InsightsPromoCard`) |
| `NotificationScreen` | Home / profile |
| `FeatureComingUp` | Profile (placeholder) |
| `PremiumPlanScreen` | Profile |

Friends remains secondary under Profile — not a bottom tab per product decision.

---

## Legacy Navigator (Migrate When Touching)

`Navigator.push` / `MaterialPageRoute` still present in ~13 files:

- `friends_screen.dart`, `settle_up_tab.dart`, `transaction_tab.dart`
- `receipt_scanner_screen.dart`, `add_member_screen.dart`

**Replace with `Get.to` when editing that file.**

---

## Forbidden / Broken Patterns

| Pattern | Issue |
|---------|-------|
| `Get.offAllNamed('/')` | No named routes configured — broken (`goal_details_controller.dart`) |
| `GetPage` / route table | Not set up — do not use named routes without adding `getPages` to `GetMaterialApp` |
| GoRouter | Not in project — do not add |

---

## GetMaterialApp Configuration

```dart
// lib/main.dart — current
GetMaterialApp(
  title: 'Splitr',
  debugShowCheckedModeBanner: false,
  initialBinding: AppBindings(),
  theme: AppThemes.light,
  home: _getInitialScreen(),
)
```

Deep links handled by `DeepLinkService` (registered in `main.dart`, uses `app_links`).

No `getPages`, no `initialRoute`. New screens use `Get.to(() => ...)` imperative navigation.

---

## Biometric Gate

After login, if biometrics enabled:

```dart
BiometricLockScreen → success → BottomNavigationController
```

Do not bypass biometric screen when `biometricEnabled` is true in `main.dart`.

---

## Migration Guidance

### Replacing Navigator.push

```dart
// Before
Navigator.push(context, MaterialPageRoute(builder: (_) => const FooScreen()));

// After
Get.to(() => const FooScreen());
```

### Fixing goal delete navigation

Replace `Get.offAllNamed('/')` in `GoalDetailsController.deleteGoal()` with:

```dart
Get.back(result: true); // return to previous screen with refresh signal
```

### Adding a new screen

1. Create screen in `lib/Screen/<Feature>/`.
2. Create `Binding` if controller needed.
3. Navigate with `Get.to(() => const NewScreen(), binding: NewBinding())`.
4. Do not add to bottom nav unless explicitly requested.

---

## AI Instructions

1. Use `Get.to` / `Get.off` / `Get.back` for navigation — not `Navigator.push` in new code.
2. Bottom nav is exactly 4 tabs: Home, Groups, Lending, Profile.
3. Friends: navigate from Profile only.
4. Pass data via `Get.arguments`; read in controller `onInit`.
5. Do not use named routes or `Get.offAllNamed` until `getPages` is configured.
6. Do not add GoRouter.
7. Shell tab switching stays in `BottomNavigationController` with `IndexedStack`.
