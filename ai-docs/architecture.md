# SplitO Architecture Overview

SplitO (`package:splitter`) is a Flutter expense-splitting and personal finance app backed by Supabase with an offline-first Drift layer.

## Layers

```
Screen → Controller → Repository → Service → Supabase / Drift
```

## Key folders

| Folder | Role |
|--------|------|
| `lib/Screen/` | UI by product domain |
| `lib/Controller/` | GetX state and orchestration |
| `lib/Repository/` | Offline cache + sync (groups, transactions) |
| `lib/Services/` | Domain and infrastructure services |
| `lib/Services/SupabaseServices/` | Supabase table CRUD |
| `lib/Services/local/` | Drift database |
| `lib/Model/` | Manual JSON models |
| `lib/Widgets/` | Shared UI |
| `lib/Constants/` | Theme + legacy helpers |

## App shell

4 bottom tabs: **Home · Groups · Lending · Profile** (`IndexedStack`).

Friends: secondary screen from Profile (`Get.to(FriendsScreen)`).

## Bootstrap (`main.dart`)

1. Supabase init (credentials from `git_ignore.dart`)
2. Drift `AppDatabase`
3. `SyncService.startListening()`
4. `RealtimeService`, `ReminderService`
5. GetX: `appDatabase`, `syncService`, `CurrencyController`, etc.

## Current gap

Repositories and Drift exist but UI still calls `SupabaseDatabase()` directly in many screens. Target: wire repositories for offline-first reads/writes.

## State management

GetX only — no Riverpod, Bloc, or Provider.

## Rules

See `.cursor/rules/` — start with `flutter-rules.md` and `architecture.md`.
