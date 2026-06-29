# Storage Rules — SplitO (Splitter)

## Purpose

Define all persistence mechanisms: Drift local database, sync queue, SharedPreferences, and how they integrate with offline-first repositories.

---

## Responsibilities

| Store | File / service | Use |
|-------|----------------|-----|
| **Drift SQLite** | `Services/local/database.dart` | Offline cache, sync queue |
| **SyncService** | `Services/sync_service.dart` | Push pending mutations when online |
| **SharedPreferences** | Direct or via controller | Onboarding flag, currency pref |
| **Supabase** | Remote source of truth | See `supabase.md` |

Screens and controllers must **not** access `AppDatabase` directly — use repositories.

---

## Drift Database

### Location

```
lib/Services/local/database.dart      # Schema + queries (edit this)
lib/Services/local/database.g.dart  # Generated (never edit)
```

### Regenerate after schema changes

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Database file on device

`splito_local.db` in application documents directory (`_openConnection()` in `database.dart`).

### Schema version

Current: `schemaVersion => 2` with migration adding `LocalPersonalTransactions` from v1.

Bump `schemaVersion` and add `onUpgrade` step for every schema change.

---

## Tables

| Drift table | Purpose | `syncStatus` column |
|-------------|---------|---------------------|
| `LocalGroups` | Cached groups | Yes |
| `LocalGroupMembers` | Group membership | No |
| `LocalGroupTransactions` | Group expenses | Yes |
| `LocalPersonalTransactions` | Personal expenses | Yes |
| `LocalFriends` | Friend relationships | Yes |
| `LocalUsersCache` | User display cache | No |
| `SyncQueue` | Pending mutations | `status`: pending/processing/failed |

### syncStatus on entity rows

| Value | Set when |
|-------|----------|
| `synced` | Row pulled from server or sync confirmed |
| `pending` | Local write awaiting push |
| `failed` | Sync failed (manual retry via `SyncService.syncPendingItems()`) |

---

## AppDatabase Registration

Initialized in `main.dart`:

```dart
appDatabase = AppDatabase();
Get.put(appDatabase, permanent: true);
```

Access in repositories via constructor injection — not `Get.find` inside repository body at call sites from screens.

### Key query methods

```dart
// Groups
Stream<List<LocalGroup>> watchAllGroups()
Future<List<LocalGroup>> getAllGroups()
Future<void> upsertGroup(LocalGroupsCompanion group)

// Transactions
Stream<List<LocalGroupTransaction>> watchTransactionsForGroup(String groupId)
Future<List<LocalGroupTransaction>> getTransactionsForGroup(String groupId)

// Sync queue
Future<List<SyncQueueData>> getPendingSyncItems()
Future<void> addToSyncQueue(SyncQueueCompanion item)
Future<void> markSynced(int id)
Future<void> markFailed(int id)

// User cache
Future<void> upsertUser(LocalUsersCacheCompanion user)
Future<LocalUsersCacheData?> getUser(String userId)
```

---

## SyncService

### Registration

```dart
syncService = SyncService(appDatabase);
syncService.startListening();
Get.put(syncService, permanent: true);
```

### Behaviour

1. Listens to `connectivity_plus` — syncs when connection restored.
2. Processes `SyncQueue` items: INSERT / UPDATE / DELETE to Supabase.
3. Broadcasts `Stream<SyncStatus>`: `synced`, `syncing`, `error`.

### Enqueue from repository

```dart
await _syncService.enqueue(
  tableName: 'group_transaction',
  operation: 'INSERT',
  recordId: transactionId,
  payload: { /* JSON-serializable map */ },
);
```

`enqueue` triggers immediate sync if online.

### Full sync

`SyncService.fullSync(String userId)` pulls groups into local DB — call from a controller on app resume or pull-to-refresh (not yet wired).

---

## Sync UI

`Constants/sync_indicator_widget.dart`:

- `SyncIndicator` — dot/icon per item status
- `SyncStatusBanner` — app-bar banner during sync

Controller pattern:

```dart
final syncStatus = SyncStatus.synced.obs;

@override
void onInit() {
  super.onInit();
  _syncSub = Get.find<SyncService>().syncStatus.listen((s) => syncStatus.value = s);
}
```

**Currently unused in screens** — add to `HomeScreen` and `GroupScreen` app bars when wiring offline.

---

## SharedPreferences

### Current uses

| Key | Set in | Purpose |
|-----|--------|---------|
| `hasSeenOnboarding` | `main.dart`, `onboarding_screen.dart` | First-launch gate |
| `selected_currency` | `CurrencyController` | Local currency override |

### Convention for new prefs

Do not call `SharedPreferences.getInstance()` from screens. Wrap in a small service or controller method.

Exception: `main.dart` bootstrap reads onboarding flag before `runApp`.

---

## Biometric Storage

`BiometricAuthService` manages biometric enable flag — use service methods, not raw prefs from UI.

---

## Forbidden Practices

| Forbidden | Use |
|-----------|-----|
| `AppDatabase()` in screen/controller | Repository |
| Edit `database.g.dart` | `build_runner` |
| Schema change without version bump | Increment `schemaVersion` + `onUpgrade` |
| Skip sync queue on local writes | `enqueue()` after every mutation |
| Store secrets in Drift or SharedPreferences | `git_ignore.dart` for API keys only |

---

## Adding a New Cached Entity

1. Add `Table` class in `database.dart`.
2. Add to `@DriftDatabase(tables: [...])`.
3. Bump `schemaVersion`, add `onUpgrade` migration.
4. Run `build_runner`.
5. Add query/watch methods to `AppDatabase`.
6. Add `case` in `SyncService._getIdField()` if syncable.
7. Create repository wrapping new table.

---

## Migration Guidance

### Phase 1 — Wire sync UI

- Subscribe to `SyncService.syncStatus` in `HomeController` / `GroupScreenController`.
- Show `SyncStatusBanner` when `status != SyncStatus.synced`.

### Phase 2 — Replace remote-only reads

- `group_screen.dart` → `GroupRepository.watchGroups()`
- `transaction_tab.dart` → `TransactionRepository.watchTransactions(groupId)`

### Phase 3 — Personal transactions offline

- Implement `PersonalTransactionRepository` using `LocalPersonalTransactions`.
- Migrate `home_screen.dart` / `add_personal_transaction_screen.dart`.

---

## AI Instructions

1. Never edit `database.g.dart`.
2. After changing `database.dart`, run build_runner and commit both files.
3. All offline writes: Drift insert with `syncStatus: 'pending'` + `SyncService.enqueue`.
4. Controllers subscribe to repository `watch*` streams, not `AppDatabase` directly.
5. Use `Get.find<SyncService>()` for sync status — registered in `main.dart`.
6. JSON in Drift text columns (e.g. `groupBalance`) use `jsonEncode`/`jsonDecode` in repository.
