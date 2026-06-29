# Testing Rules — SplitO (Splitter)

## Purpose

Testing strategy for SplitO — minimal today, defined path for when tests are requested or added.

---

## Current State

| Item | Status |
|------|--------|
| `test/widget_test.dart` | **Broken** — default counter test; app has no counter |
| Unit tests | None |
| Integration tests | None |
| CI test runner | None |

Tests are **not required unless requested** (per `flutter-rules.md`). When added, follow this file.

---

## Verification Commands

```bash
flutter analyze
flutter test
```

Run before claiming work complete when tests exist or were modified.

---

## Test Priority Order

1. **Repository tests** — Drift + mock Supabase/sync (highest value for offline-first)
2. **Controller tests** — mock repositories, verify state transitions
3. **Widget tests** — smoke render + key interactions
4. **Integration tests** — defer until unit coverage on critical paths

---

## Repository Test Pattern

```dart
// test/repository/group_repository_test.dart
void main() {
  late AppDatabase db;
  late SyncService syncService;
  late GroupRepository repository;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    syncService = SyncService(db);
    repository = GroupRepository(db, syncService);
  });

  tearDown(() async {
    await db.close();
  });

  test('createGroup writes pending row locally', () async {
    await repository.createGroup(
      groupId: 'g1',
      groupName: 'Test',
      createdBy: 'u1',
      groupBalance: [],
    );
    final groups = await repository.getGroups();
    expect(groups.length, 1);
    expect(groups.first.syncStatus, 'pending');
  });
}
```

Use in-memory Drift for isolation. Mock `SupabaseClient` for `refreshFromServer` tests (mockito or manual fake).

---

## Controller Test Pattern

```dart
void main() {
  late SettleUpController controller;
  late MockGroupRepository mockRepo;

  setUp(() {
    mockRepo = MockGroupRepository();
    Get.put<GroupRepository>(mockRepo);
    controller = SettleUpController(groupID: 'g1', userID: 'u1');
  });

  tearDown(() {
    Get.reset();
  });

  test('fetchAndSimplifyDebts sets error on failure', () async {
    when(mockRepo.getBalances()).thenThrow(Exception('network'));
    await controller.fetchAndSimplifyDebts();
    expect(controller.errorMessage.value.isNotEmpty, true);
  });
}
```

Inject repositories via `Get.put` in test `setUp`; `Get.reset()` in `tearDown`.

---

## Widget Test Pattern

Replace broken default test with smoke test:

```dart
testWidgets('MyApp renders login when no session', (tester) async {
  await tester.pumpWidget(const MyApp(hasSeenOnboarding: true));
  await tester.pumpAndSettle();
  // Assert login or home based on mock session
});
```

**Avoid** brittle pixel tests. Assert presence of key text/icons.

`MyApp` requires constructor args:

```dart
MyApp(hasSeenOnboarding: true, biometricEnabled: false)
```

Supabase initialization in `main()` prevents testing full `main()` without refactoring — test widgets with mocked dependencies or extract `MyApp` tests without calling `main()`.

---

## What to Test (When Requested)

| Area | Cases |
|------|-------|
| `SettleUpController._simplifyDebts` | Debt minimization algorithm |
| `GroupRepository.createGroup` | Local write + enqueue |
| `SyncService.enqueue` | Queue row created |
| `GroupModel.fromJSON` | Parsing edge cases |
| Login form validation | Empty email/password |

---

## Forbidden Practices

| Forbidden | Reason |
|-----------|--------|
| Counter smoke test | Not representative |
| Tests that hit real Supabase | Flaky, needs network |
| Tests without `Get.reset()` after controller tests | State leak |
| Golden tests without team agreement | High maintenance |

---

## Fixing `widget_test.dart` (First Test Task)

When enabling tests:

1. Delete counter expectations.
2. Pump `MyApp(hasSeenOnboarding: true)`.
3. Mock or skip Supabase — consider `TestWidgetsFlutterBinding` + dependency overrides.
4. Assert a visible element from `LoginScreen` or `HomeScreen`.

---

## AI Instructions

1. Do not add tests unless user requests or task explicitly includes testing.
2. When adding tests, start with repository or pure logic (debt algorithm).
3. Use in-memory Drift for repository tests.
4. Call `Get.reset()` after GetX controller tests.
5. Run `flutter test` and report output before claiming tests pass.
6. Do not write tests that require live API keys from `git_ignore.dart`.
7. Replace broken `widget_test.dart` before adding new widget tests.
