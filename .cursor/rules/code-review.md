# Code Review Rules — SplitO (Splitter)

## Purpose

Checklist for AI self-review and human PR review. Verify generated code matches SplitO architecture before merge.

---

## Quick Reference

| Topic | Rule file |
|-------|-----------|
| Folder layout | `architecture.md` |
| GetX / controllers | `getx.md`, `flutter-rules.md` |
| Offline / repos | `repository.md`, `storage.md` |
| Supabase | `supabase.md` |
| Models | `models.md` |
| Widgets | `widgets.md` |
| Theme | `theming.md` |
| Navigation | `navigation.md` |
| Secrets | `security.md` |
| pubspec | `dependencies.md` |
| Tests | `testing.md` |

---

## Architecture Checklist

- [ ] New code in correct layer folder (`Screen/`, `Controller/`, `Repository/`, etc.)
- [ ] No `feature/data/domain/presentation` folders introduced
- [ ] Import direction respected (Screen → Controller → Repository → Service)
- [ ] No `SupabaseDatabase()` in **new** screen code for group/transaction entities
- [ ] No direct `AppDatabase` access outside repositories
- [ ] Offline writes use `syncStatus: 'pending'` + `SyncService.enqueue()`

---

## GetX Checklist

- [ ] Controller extends `GetxController` for new feature screens
- [ ] `Binding` registers controller + repository (new features; `AppBindings` for shared repos)
- [ ] Pro features gated via `InsightsProGate` / `PremiumGate` when applicable
- [ ] `isLoading` + `errorMessage` exposed for async operations
- [ ] `TextEditingController` disposed in `onClose`
- [ ] `Obx` scopes minimal — not wrapping full `Scaffold`
- [ ] No `Get.put` inside `build()`
- [ ] `Get.reset()` considered in tests

---

## UI Checklist

- [ ] Widget file ≤ ~200 lines (new code)
- [ ] New shared widgets in `lib/Widgets/` — not `Constants/`
- [ ] Reused `UserAvatar`, `TransactionTile`, etc. where applicable
- [ ] Colors from `constants.dart` — no random `Color(0xFF...)`
- [ ] Currency via `Get.find<CurrencyController>().symbol`
- [ ] No API calls in `build()`

---

## Data Checklist

- [ ] New models in `lib/Model/` with `fromJSON`/`toJSON`
- [ ] Supabase column names snake_case in queries/payloads
- [ ] Repository `watch*` stream for list UIs (offline entities)
- [ ] `refreshFromServer` on screen open / pull-to-refresh
- [ ] Drift schema version bumped if `database.dart` changed
- [ ] `build_runner` run if Drift changed

---

## Navigation Checklist

- [ ] `Get.to` / `Get.back` — not `Navigator.push` (new code)
- [ ] Bottom nav unchanged (4 tabs: Home, Groups, Lending, Profile)
- [ ] Friends accessed from Profile — not added as bottom tab
- [ ] Insights accessed from Profile/Home — not added as bottom tab
- [ ] No `Get.offAllNamed` without configured routes

---

## Security Checklist

- [ ] New API keys only in `lib/git_ignore.dart`
- [ ] No `debugPrint` of tokens/sessions/passwords
- [ ] No secrets in widgets or controllers

---

## Dependencies Checklist

- [ ] No Riverpod, Bloc, GoRouter, Dio, Freezed added
- [ ] New package has user approval
- [ ] Unused deps not re-introduced

---

## Severity Guide (From Architecture Audit)

Flag in review comments:

| Severity | Examples |
|----------|----------|
| **Critical** | Screen calls Supabase for offline entity; new code bypasses repository; secrets hardcoded |
| **High** | No controller on new screen; god widget > 200 lines; missing sync enqueue on write |
| **Medium** | `Navigator.push`; hardcoded colors; toast in new service |
| **Low** | Naming inconsistency; legacy `Controllers/` path |

---

## Legacy Code Policy

When editing **existing** files:

- Migrate only the code path you touch
- OK to leave adjacent legacy `SupabaseDatabase()` calls if not in scope
- Add `// TODO: migrate to repository` only if blocking — prefer silent migration in same PR when small

When adding **new** files:

- Full target architecture required (Controller + Binding + Repository where offline applies)

---

## Pre-Merge Commands

```bash
flutter analyze
flutter test   # when tests exist or were modified
```

---

## AI Self-Review (Before Completing Task)

1. Re-read changed files against architecture checklist above.
2. Confirm no forbidden dependencies added to `pubspec.yaml`.
3. Confirm no new widgets in `Constants/`.
4. Confirm group/transaction paths use repository if adding data operations.
5. Confirm `git_ignore.dart` used for any new secrets.
6. Run `flutter analyze` on touched Dart files.
7. Do not refactor unrelated files (per `flutter-rules.md`).

---

## Common Rejection Reasons

| Reason | Fix |
|--------|-----|
| `home_screen.dart` pattern copied | Add controller + repository |
| New widget in `shared.dart` | Move to `Widgets/` |
| `Supabase.instance.client` in screen | Move to service/repository |
| Missing `enqueue` after local write | Add `SyncService.enqueue` |
| 500-line new screen file | Extract widgets + controller |

---

## AI Instructions

Before marking a task complete, run through **Architecture**, **GetX**, and **UI** checklists. Report any intentional legacy deviations and why scope excluded migration.
