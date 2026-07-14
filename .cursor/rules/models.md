# Model Rules — Splitr

## Purpose

Conventions for domain model classes in `lib/Model/`. This project uses **manual JSON serialization** — no Freezed, no json_serializable unless explicitly approved.

---

## Responsibilities

Models:

- Represent API/domain data shapes
- Parse Supabase JSON (`fromJSON`) and serialize (`toJSON`)
- Stay free of Flutter imports (except rare `Color` usage — avoid adding)
- Contain no business logic, network calls, or UI code

---

## Required Conventions

### File location and naming

```
lib/Model/<entity>_model.dart
class <Entity>Model
```

Examples:

| File | Class |
|------|-------|
| `group_model.dart` | `GroupModel`, `GroupBalanceModel`, `GroupMembers` |
| `friend_model.dart` | `FriendModel` |
| `personal_transaction_model.dart` | `PersonalTransactionModel` |
| `financial_goal_model.dart` | `FinancialGoalModel` |
| `loan_model.dart` | `LoanModel` |

### JSON method naming (project convention)

Use `fromJSON` and `toJSON` — **not** `fromJson`/`toJson`:

```dart
// lib/Model/group_model.dart
GroupModel.fromJSON(Map<String, dynamic> data) { ... }
Map<String, dynamic> toJSON() { ... }
```

Match existing files when editing. Do not rename to Dart style in bulk refactors.

### Supabase column mapping

Supabase uses snake_case; Dart uses camelCase:

```dart
groupID = data["group_id"];
groupName = data["group_name"];
createdAt = DateTime.tryParse(data["created_at"].toString());
isTrip = data["is_trip"] ?? false;
```

Always use `DateTime.tryParse(...?.toString() ?? '')` for nullable timestamps.

### Nested lists

```dart
if (data["group_balance"] != null) {
  for (var element in (data["group_balance"] as List<dynamic>)) {
    groupBalanceList.add(GroupBalanceModel.fromJSON(element));
  }
}
```

### Nullable mutable fields (current style)

```dart
class GroupModel {
  String? groupID;
  String? groupName;
  List<GroupBalanceModel>? groupBalance;
  // ...
}
```

**New models:** Prefer `final` fields + copy constructor when practical, but match the dominant nullable mutable style in the same feature folder.

---

## Drift Local* vs Domain Model

| Layer | Type | Example |
|-------|------|---------|
| Drift row | `LocalGroup`, `LocalGroupTransaction` | Generated in `database.g.dart` |
| Domain | `GroupModel`, `GroupTransactionModel` | `lib/Model/` |

Mapping happens in **repository**, not in model files:

```dart
// In GroupRepository
GroupModel toGroupModel(LocalGroup local) { ... }
```

Do not add Drift imports to `lib/Model/`.

---

## Existing Models (18 files)

`activity_model`, `badge_model`, `financial_goal_model`, `friend_model`, `goal_transaction_model`, `group_invite_model`, `group_model`, `loan_model`, `loan_interest`, `personal_transaction_model`, `product_category_model`, `receipt_model`, `reminder_settings_model`, `repayment_schedule`, `trip_model`, `user_details_model`, `wishlist_model`, `wishlist_prefill`

`loan_interest.dart` and `repayment_schedule.dart` hold pure calculation types (`LoanInterest`, `RepaymentSchedule`, `LoanScheduleCalculator`) — not `*Model` suffix.

---

## Forbidden Practices

| Forbidden | Reason |
|-----------|--------|
| `fromJson` / `toJson` in new files without matching feature | Naming inconsistency across repo |
| `json_serializable` / `freezed` without approval | Not in pubspec workflow |
| JSON parsing in screens or controllers | Belongs in model or service |
| `import` from `Screen/`, `Controller/`, `Services/` | Models are pure data |
| `@JsonKey` annotations | No codegen setup |

---

## toJSON for sync payloads

Sync queue payloads use snake_case keys matching Supabase columns directly (often built in repository, not via `toJSON()`):

```dart
payload: {
  'transaction_id': transactionId,
  'group_id': groupId,
  'sharing_type': sharingType,
}
```

Use `toJSON()` when sending full model; use explicit maps in repository `enqueue()` when partial updates.

---

## Anti-Patterns

| Pattern | Location |
|---------|----------|
| Large model file with multiple unrelated classes | `group_model.dart` (338+ lines) — acceptable if cohesive; split only when editing |
| Mutable goal amount updated in controller | `GoalDetailsController` mutates `goal.currentAmount` — prefer immutable copy |
| `loan_model.dart` uses `fromJson` | Inconsistent — match `fromJSON` when touching |

---

## Migration Guidance

When adding a new Supabase table:

1. Create `lib/Model/<entity>_model.dart` with `fromJSON`/`toJSON`.
2. Add Drift table if offline-cached (see `storage.md`).
3. Update corresponding `SupabaseServices/*` to return typed models.
4. Add migration SQL if new columns on existing tables.

When editing existing models:

- Preserve `fromJSON`/`toJSON` names.
- Add new fields as nullable with defaults in constructor.
- Update repository `refreshFromServer` row mapping.

---

## AI Instructions

1. Place all new entity classes in `lib/Model/`.
2. Use `fromJSON` / `toJSON` naming — not generated code.
3. Map snake_case Supabase keys to camelCase Dart fields.
4. Use `DateTime.tryParse` for all date fields.
5. Do not add Freezed/json_serializable without explicit user approval.
6. Keep models free of `GetX`, `Widget`, and `Supabase` imports.
7. Map `Local*` Drift types to `*Model` in repositories, not in model files.
