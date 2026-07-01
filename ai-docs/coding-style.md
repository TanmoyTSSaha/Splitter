# SplitO Coding Style

## Imports

Order (no strict linter enforcement — follow visually):

1. `dart:` 
2. `package:flutter/`
3. Third-party `package:`
4. `package:splitter/`

Use package imports for project files, not relative `../` across layers.

## Naming

| Artifact | Style | Example |
|----------|-------|---------|
| Classes | PascalCase | `GroupRepository` |
| Files | snake_case | `group_repository.dart` |
| Variables | camelCase | `groupId`, `isLoading` |
| Constants | camelCase or lowerCamel | `neopopPrimary`, `supabaseURL` |
| Private fields | `_prefix` | `_db`, `_syncService` |
| JSON methods | `fromJSON` / `toJSON` | Project convention (`LoanModel` uses `fromJson`) |
| Supabase methods | `supabase` prefix (legacy) | `supabaseGetUserID` |

## Controllers

- Suffix: `Controller`
- Reactive: `RxBool isLoading`, `RxList<T> items`
- File: `lib/Controller/<name>_controller.dart`
- Legacy premium/currency: `lib/Controllers/` — migrate to `Controller/` when touched

## Bindings

- `lib/Bindings/<feature>_bindings.dart` or `app_bindings.dart`
- Register repositories with `Get.lazyPut(..., fenix: true)` using `Get.find<AppDatabase>()` + `Get.find<SyncService>()`

## Screens

- Suffix: `Screen` or `Tab` for tab bodies
- Folder: `lib/Screen/<Feature>Screen/`
- Feature-scoped widgets: `Screen/<Feature>/widgets/` (e.g. `Insights/widgets/`)

## Formatting

- `flutter_lints` / `analysis_options.yaml` — default package lints
- Prefer trailing commas in multi-line widget trees
- `const` constructors where possible

## Comments

- Minimal — code should be self-explanatory
- Use doc comments on public service/repository APIs
- Phase comments in pubspec OK (`# Phase 2: Offline-first`)

## Error handling

- New code: controller exposes `errorMessage`, `Get.snackbar` for user feedback
- Services: `debugPrint` + rethrow (avoid new `Fluttertoast` in services)

## Testing hooks

- `@visibleForTesting` on static pure functions (e.g. `SpendingIntelligenceService.calculateHealthScore`)
- `testIsPremium` parameter on `InsightsProGate` for widget tests without IAP

## Git

- Do not commit unrelated refactors
- AI changes: minimal diff per task (`flutter-rules.md`)
