# Supabase Rules — SplitO (Splitter)

## Purpose

Backend access conventions for SplitO's Supabase stack. All remote data goes through `supabase_flutter` — no Dio, no REST clients.

---

## Responsibilities

| Layer | Role |
|-------|------|
| `SupabaseAuth` / `SupabaseDatabase` | Facades in `supabase_service.dart` — aggregate service calls |
| `Services/SupabaseServices/*` | Table-scoped CRUD per domain |
| `Repository/` | Local-first; calls Supabase only in `refreshFromServer` and via sync queue |
| `RealtimeService` | Postgres change subscriptions |
| `supabase/migrations/` | Schema changes |

---

## Architecture

```
Controller
    ↓
Repository.refreshFromServer()  ──→  SupabaseClient
    ↓
SyncService.enqueue()  ──→  SupabaseClient (background)

Legacy (migrate away):
Controller/Screen  ──→  SupabaseDatabase()  ──→  SupabaseServices/*
```

---

## Facade Pattern

`lib/Services/supabase_service.dart` exposes two facades:

### `SupabaseAuth`

Delegates to `AuthService`:

```dart
SupabaseAuth().supabaseEmailPassSignIn(userEmail: ..., userPassword: ...);
SupabaseAuth().supabaseSignUp(...);
SupabaseAuth().googleSignIn();
SupabaseAuth().supabaseGetUserID();
SupabaseAuth().supabaseRetrieveSession();
SupabaseAuth().supabaseSignOut();
```

### `SupabaseDatabase`

Delegates to `UserService`, `GroupService`, `FriendService`, `TransactionService`, `GoalService`, `LoanService`:

```dart
SupabaseDatabase().getGroupData(userID: userId);
SupabaseDatabase().addGroupExpense(...);
SupabaseDatabase().getGroupTransactionsData(...);
SupabaseDatabase().getCurrentUserProfile(userID: userId);
```

**New code:** Do not add methods to the facade. Add methods to the appropriate `SupabaseServices/*` class and call via repository.

---

## SupabaseServices

One service file per domain cluster in `lib/Services/SupabaseServices/`:

| Service | Tables / domain |
|---------|-----------------|
| `auth_service.dart` | Supabase Auth |
| `user_service.dart` | `users` |
| `group_service.dart` | `groups`, `group_members`, settlements |
| `transaction_service.dart` | `group_transaction`, `personal_transaction`, categories |
| `friend_service.dart` | friends / requests |
| `loan_service.dart` | loans |
| `goal_service.dart` | financial goals |
| `goal_transaction_service.dart` | goal transactions |
| `notification_service.dart` | notifications |

### Service conventions

```dart
class GroupService {
  final supabase = Supabase.instance.client;

  Future<List<GroupModel>> getGroupData({required String userID}) async {
    try {
      final response = await supabase.from('groups').select()...;
      // map to GroupModel
    } catch (e) {
      debugPrint('GroupService.getGroupData: $e');
      rethrow; // or return empty — match surrounding service style
    }
  }
}
```

- Access client via `Supabase.instance.client` inside services only.
- Map responses to `*Model` using `fromJSON`.
- **New services:** throw or return `Result` types — do not show `Fluttertoast` (legacy in `AuthService`).

---

## Forbidden Practices

| Forbidden | Location of violation | Use instead |
|-----------|----------------------|-------------|
| `Supabase.instance.client` in screens | `create_group_screen.dart`, `request_feature_screen.dart` | Service or repository |
| `SupabaseDatabase()` in new screens | `home_screen.dart`, `add_transaction_screen.dart` | Repository |
| New facade methods on `SupabaseDatabase` | — | Extend domain service + repository |
| Raw SQL from Flutter | — | Supabase client query builder |
| Schema changes without migration file | — | `supabase/migrations/YYYYMMDD_description.sql` |

---

## Realtime

`RealtimeService` (`lib/Services/realtime_service.dart`):

- Subscribes to `group_transaction` changes per `groupId`
- Subscribes to friend request changes
- Broadcasts via `onTransactionChange` and `onFriendChange` streams

### Controller integration (target)

```dart
@override
void onInit() {
  super.onInit();
  Get.find<RealtimeService>().subscribeToGroup(groupId);
  _realtimeSub = Get.find<RealtimeService>().onTransactionChange.listen((event) {
    if (event.groupId == groupId) _repository.refreshFromServer(groupId);
  });
}

@override
void onClose() {
  Get.find<RealtimeService>().unsubscribeFromGroup(groupId);
  _realtimeSub?.cancel();
  super.onClose();
}
```

Currently wired in `GroupScreenController` and `TransactionTabController` — subscribe on init, unsubscribe on close, refresh repository on transaction events.

---

## Schema Migrations

Location: `supabase/migrations/`

Example: `20260216_separate_notes.sql` — adds `transaction_note` column to `group_transaction`.

When adding columns:

1. Add SQL migration file.
2. Update `*Model.fromJSON` / `toJSON`.
3. Update Drift table in `database.dart` if cached locally.
4. Run `dart run build_runner build`.
5. Update repository `refreshFromServer` mapping.

---

## Auth Flow

```
main.dart: Supabase.initialize(url: supabaseURL, anonKey: supabaseAnonPublicKey)
Credentials from: lib/git_ignore.dart

Session check: SupabaseAuth().supabaseRetrieveSession()
User ID: SupabaseAuth().supabaseGetUserID()
```

Google sign-in and email/password via `AuthService`.

---

## Error Handling (Target)

| Layer | Responsibility |
|-------|----------------|
| SupabaseService | `debugPrint`, rethrow or return failure |
| Repository | Catch, optionally mark sync failed, rethrow |
| Controller | Set `errorMessage`, show `Get.snackbar` |
| Screen | Display `Obx` error state |

Legacy: `AuthService` shows `Fluttertoast` — do not replicate in new services.

---

## Anti-Patterns

| Pattern | Example |
|---------|---------|
| Nested `FutureBuilder` chains hitting Supabase | `home_screen.dart` |
| 700-line service | `transaction_service.dart` — split by operation group when editing |
| Direct client in screen | `request_feature_screen.dart` line 91 |
| Facade instantiated per screen field | `_supabase = SupabaseDatabase()` in `home_screen.dart` |

---

## Migration Guidance

1. **New remote operations:** Add to `SupabaseServices/<domain>_service.dart`.
2. **New reads for offline entities:** Add `refreshFromServer` to repository, not new screen `FutureBuilder`.
3. **Existing `SupabaseDatabase()` calls:** Replace with repository method when touching that file.
4. **Realtime:** Subscribe in group detail controller, trigger repository refresh on events.

---

## AI Instructions

1. Use `supabase_flutter` only — never add Dio or `http` for Supabase data.
2. Place new Supabase queries in `Services/SupabaseServices/`, not in controllers or screens.
3. Table and column names: snake_case matching Supabase schema (`group_id`, `transaction_note`).
4. Credentials: import from `package:splitter/git_ignore.dart` — never inline keys.
5. For group/transaction CRUD, prefer repository over `SupabaseDatabase()`.
6. Add SQL migrations for schema changes under `supabase/migrations/`.
7. Wire `RealtimeService` subscriptions in controllers for live group screens.
