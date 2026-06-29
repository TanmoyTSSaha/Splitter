# Dependencies Rules — SplitO (Splitter)

## Purpose

pubspec dependency policy — what is approved, what is forbidden, and how to add packages.

---

## Approved Stack

| Package | Version (pubspec) | Role |
|---------|-------------------|------|
| `get` | ^4.6.6 | State, DI, navigation |
| `supabase_flutter` | ^2.6.0 | Backend auth + database |
| `drift` | ^2.16.0 | Local SQLite ORM |
| `sqlite3_flutter_libs` | ^0.5.0 | Drift native SQLite |
| `connectivity_plus` | ^6.0.0 | Sync connectivity |
| `shared_preferences` | ^2.5.4 | Onboarding, currency pref |
| `neopop` | ^1.0.2 | UI components |
| `google_fonts` | ^6.3.3 | Typography (partial) |
| `fl_chart` | ^0.68.0 | Analytics charts |
| `flutter_svg` | ^2.0.10+1 | SVG icons |
| `intl` | ^0.19.0 | Date/number formatting |
| `cached_network_image` | ^3.3.0 | Avatars, images |
| `google_mlkit_text_recognition` | ^0.13.0 | Receipt OCR |
| `image_picker` | ^1.1.1 | Receipt photos |
| `google_generative_ai` | ^0.4.7 | AI goals/receipts |
| `local_auth` | ^2.3.0 | Biometric lock |
| `flutter_local_notifications` | ^17.0.0 | Reminders |
| `share_plus` | ^10.1.4 | Share cards |
| `screenshot` | ^3.0.0 | Shareable images |
| `lottie` | ^3.1.0 | Animations |
| `vibration` | ^2.1.0 | Haptic feedback |
| `loading_animation_widget` | ^1.3.0 | Loaders |
| `fluttertoast` | ^8.2.8 | Legacy toasts |
| `avatar_stack` | ^1.2.0 | Member avatars |
| `flutter_timeline` | ^0.3.0 | Trip timeline |
| `story_view` | ^0.16.6 | Monthly recap stories |
| `path_provider` | ^2.1.3 | DB file path |
| `path` | ^1.9.0 | Path utilities |
| `cupertino_icons` | ^1.0.6 | iOS icons |

### Dev dependencies

| Package | Role |
|---------|------|
| `flutter_lints` | Analyzer rules |
| `drift_dev` | Drift codegen |
| `build_runner` | Code generation |

---

## Forbidden Without Explicit Approval

| Package | Reason |
|---------|--------|
| `flutter_riverpod`, `riverpod` | Project uses GetX |
| `provider` | Project uses GetX |
| `flutter_bloc`, `bloc` | Project uses GetX |
| `go_router`, `auto_route` | Imperative GetX navigation |
| `dio`, `http` (for API) | Supabase client handles remote |
| `freezed`, `json_serializable` | Manual `fromJSON`/`toJSON` |
| `appwrite` | Migrated to Supabase |
| `hive`, `isar` | Project uses Drift |
| `mobx`, `redux` | Not in architecture |

---

## Unused Dependencies (Remove When Touching pubspec)

| Package | Evidence |
|---------|----------|
| `salomon_bottom_bar` | 0 imports — custom bottom nav used |
| `rxdart` | 0 imports |

---

## Adding a Dependency

1. **Ask / get explicit approval** for new packages (per `flutter-rules.md` AI behaviour).
2. Add with caret version matching pubspec style: `^x.y.z`
3. Group with comment if part of a feature phase:

```yaml
# Phase N: Feature name
new_package: ^1.0.0
```

4. Run `flutter pub get`.
5. Register platform plugins if needed (Android/iOS manifest).
6. Document in PR why existing packages insufficient.

---

## Unpinned Dependencies

Currently unpinned (consider pinning when editing):

- `image_picker: ^1.1.1`
- `path_provider: ^2.1.3`

---

## Code Generation

Only Drift uses codegen:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Do not add `json_serializable` or `freezed` without architecture approval.

---

## SDK Constraint

```yaml
environment:
  sdk: '>=3.4.3 <4.0.0'
```

Stay within declared SDK range.

---

## Assets (pubspec flutter section)

```yaml
assets:
  - assets/icons/svg/
  - assets/dev_images/
fonts:
  - family: Albra
    # ... weights in pubspec.yaml
```

Add new asset directories to pubspec when creating folders.

---

## AI Instructions

1. Do not add Riverpod, Bloc, GoRouter, Dio, or Freezed.
2. Do not re-add `appwrite`.
3. Prefer existing packages over new ones.
4. Remove `salomon_bottom_bar` and `rxdart` if editing `pubspec.yaml` for other reasons.
5. New dependencies require explicit user approval.
6. After Drift schema changes, use existing `drift_dev` + `build_runner` — no new codegen tools.
