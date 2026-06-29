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
| JSON methods | `fromJSON` / `toJSON` | Project convention |
| Supabase methods | `supabase` prefix (legacy) | `supabaseGetUserID` |

## Controllers

- Suffix: `Controller`
- Reactive: `RxBool isLoading`, `RxList<T> items`
- File: `lib/Controller/<name>_controller.dart`

## Screens

- Suffix: `Screen` or `Tab` for tab bodies
- Folder: `lib/Screen/<Feature>Screen/`

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

## Git

- Do not commit unrelated refactors
- AI changes: minimal diff per task (`flutter-rules.md`)
