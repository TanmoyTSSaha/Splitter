# Repository Rules — SplitO (Splitter)

## Purpose

Define how repositories mediate between **Drift (local)**, **SyncService (queue)**, and **Supabase (remote)**. Offline is a required product capability — repositories are the only data access layer controllers should use for offline-capable entities.

---

## Responsibilities

Repositories:

- Read from Drift (`watch*` streams and one-shot `get*`)
- Write locally first with `syncStatus: 'pending'`
- Enqueue mutations via `SyncService.enqueue()`
- Refresh from Supabase via `refreshFromServer()`
- Map between `Local*` Drift rows and `*Model` domain types when needed

Repositories must **not** contain UI logic, `Get.snackbar`, or `Fluttertoast`.

---

## Required Conventions

### File location and naming

```
lib/Repository/<entity>_repository.dart
class <Entity>Repository
```

### Constructor dependencies

Every repository receives `AppDatabase` and `SyncService`:

```dart
class GroupRepository {
  final AppDatabase _db;
  final SyncService _syncService;
  final SupabaseClient _supabase = Supabase.instance.client;

  GroupRepository(this._db, this._syncService);
}
```

Register via Binding:

```dart
Get.lazyPut(() => GroupRepository(Get.find<AppDatabase>(), Get.find<SyncService>()));
```

### Read path — reactive

Expose Drift streams for controller subscription:

```dart
// lib/Repository/group_repository.dart
Stream<List<LocalGroup>> watchGroups() => _db.watchAllGroups();

// lib/Repository/transaction_repository.dart
Stream<List<LocalGroupTransaction>> watchTransactions(String groupId) =>
    _db.watchTransactionsForGroup(groupId);
```

Controller binds:

```dart
StreamSubscription? _sub;

@override
void onInit() {
  super.onInit();
  _sub = _repository.watchGroups().listen((data) => groups.value = data);
  refresh();
}

@override
void onClose() {
  _sub?.cancel();
  super.onClose();
}
```

### Read path — remote refresh

```dart
Future<void> refreshFromServer(String userId) async {
  // Fetch from Supabase → upsert into Drift with syncStatus: 'synced'
}
```

Always set `syncStatus: const Value('synced')` on server-pulled rows.

### Write path — local first + enqueue

```dart
await _db.upsertGroup(LocalGroupsCompanion(
  groupId: Value(groupId),
  groupName: Value(groupName),
  syncStatus: const Value('pending'),
));

await _syncService.enqueue(
  tableName: 'groups',
  operation: 'INSERT',
  recordId: groupId,
  payload: { /* snake_case keys matching Supabase columns */ },
);
```

### syncStatus values (Drift row columns)

| Value | Meaning |
|-------|---------|
| `synced` | Matches server or pulled from server |
| `pending` | Local write awaiting sync |
| `failed` | Sync attempt failed (retry via SyncService) |

### Sync queue table names

Must match `SyncService._getIdField()` cases:

| `tableName` | Primary key field |
|-------------|-------------------|
| `groups` | `group_id` |
| `group_transaction` | `transaction_id` |
| `personal_transaction` | `transaction_id` |
| `friends` | `id` |

---

## Existing Repositories (Reference)

| Repository | Drift tables | Supabase tables | Status |
|------------|--------------|-----------------|--------|
| `GroupRepository` | `LocalGroups`, `LocalGroupMembers` | `groups`, `group_members` | Implemented, **not wired to UI** |
| `TransactionRepository` | `LocalGroupTransactions` | `group_transaction` | Implemented, **not wired to UI** |

---

## Repositories to Add

| Repository | Priority | Drift table | Supabase service |
|------------|----------|-------------|------------------|
| `PersonalTransactionRepository` | P0 | `LocalPersonalTransactions` | `TransactionService` |
| `FriendRepository` | P1 | `LocalFriends` | `FriendService` |
| `UserRepository` | P1 | `LocalUsersCache` | `UserService` |
| `LoanRepository` | P2 | — (add table when offline needed) | `LoanService` |
| `GoalRepository` | P2 | — | `GoalService` |

---

## Forbidden Practices

| Forbidden | Correct |
|-----------|---------|
| Screen calls `SupabaseDatabase()` for CRUD on offline entities | Controller → Repository |
| Controller calls `AppDatabase` directly | Controller → Repository |
| Repository shows toast/snackbar | Controller exposes error state |
| Skip local write on mutations | Always write Drift first |
| `syncStatus: 'synced'` on local-only writes before server confirms | Use `'pending'` on writes |
| Repository imports `Screen/` or `Controller/` | Never |

---

## Mapping Local* → Model

Repositories map Drift rows to domain models when controllers need `GroupModel` etc.:

```dart
GroupModel toGroupModel(LocalGroup local) {
  return GroupModel(
    groupID: local.groupId,
    groupName: local.groupName,
    groupBalance: jsonDecode(local.groupBalance) /* → List<GroupBalanceModel> */,
    createdAt: local.createdAt,
    updatedOn: local.updatedOn,
    createdBy: local.createdBy,
  );
}
```

Keep mapping in repository — not in controller or screen.

---

## Sync UI Integration

Repositories do not render UI. Controllers listen to `SyncService.syncStatus`:

```dart
// In controller onInit
_syncSub = Get.find<SyncService>().syncStatus.listen((status) {
  syncStatus.value = status;
});
```

Screens show `SyncStatusBanner` from `Constants/sync_indicator_widget.dart` (see `storage.md`).

---

## Anti-Patterns (Current Codebase)

| Anti-pattern | Location |
|--------------|----------|
| Repositories exist but zero imports | `group_repository.dart`, `transaction_repository.dart` |
| Screens write directly to Supabase | `add_transaction_screen.dart` → `addGroupExpense()` |
| `FutureBuilder` + `SupabaseDatabase` instead of Drift stream | `group_screen.dart`, `transaction_tab.dart` |
| `SyncService.fullSync()` exists but no controller calls it | `sync_service.dart` |

---

## Migration Guidance

### Wiring existing repositories (first migration)

1. Create `GroupBinding` registering `GroupRepository`.
2. Update `GroupScreenController` to subscribe to `watchGroups()`.
3. Call `refreshFromServer(userId)` in `onInit` and on pull-to-refresh.
4. Replace `SupabaseDatabase().getGroupData()` in `group_screen.dart`.
5. Repeat for `TransactionRepository` in `transaction_tab.dart`.

### New feature with offline

1. Ensure Drift table exists in `database.dart`.
2. Run `dart run build_runner build`.
3. Create repository with `watch*`, `get*`, `refreshFromServer`, write methods.
4. Register in Binding.
5. Controller uses repository only.

### Legacy screens

When editing a screen that calls `SupabaseDatabase()` directly, migrate that screen's data path to a repository. Do not migrate unrelated screens in the same change.

---

## AI Instructions

1. For group and group-transaction features, use `GroupRepository` and `TransactionRepository` — do not add new `SupabaseDatabase()` calls.
2. Every repository write must set `syncStatus: 'pending'` and call `_syncService.enqueue()`.
3. Every repository read for lists must expose a `watch*` stream.
4. Inject `AppDatabase` and `SyncService` via constructor — never instantiate `AppDatabase()` in repository.
5. Payload keys in `enqueue()` must use Supabase snake_case column names.
6. When adding a new offline entity, add Drift table + repository + sync queue table name in `SyncService._getIdField`.
7. Map `Local*` → `*Model` inside repository, return models to controller.
