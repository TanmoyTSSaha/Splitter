# Widget Rules — SplitO (Splitter)

## Purpose

Conventions for reusable UI components — where they live, when to extract, and which existing widgets to reuse.

---

## Responsibilities

| Location | Holds |
|----------|-------|
| `lib/Widgets/` | Cross-feature reusable widgets |
| `lib/Screen/<Feature>/` | Feature-specific widgets and tabs |
| `lib/Constants/` | Theme tokens + **legacy** shared widgets (no new widgets here) |

---

## Required Conventions

### Widget size limit

Per `flutter-rules.md`: **~200 lines max** per widget file. Extract when exceeded.

Known violations to split when touched:

| File | Lines |
|------|-------|
| `Constants/shared.dart` | 989 |
| `monthly_recap_screen.dart` | 2,479 |
| `add_transaction_screen.dart` | 745 |
| `wishlist_tab.dart` | 546 |

### Reuse order

1. `lib/Widgets/` shared components
2. `Constants/glass_card.dart`, `gradient_mesh_background.dart`, `swipe_to_settle_widget.dart`
3. `Constants/shared.dart` helpers (`PrimaryTextFormField`, loaders) — legacy
4. Neopop components from `neopop` package
5. Create new widget only if no match

### Cross-feature widgets (`lib/Widgets/`)

| Widget | Use |
|--------|-----|
| `user_avatar.dart` | Member/user avatars |
| `transaction_tile.dart` | Transaction list rows |
| `summary_stat_card.dart` | Dashboard stat cards |
| `active_group_card.dart` | Group list cards |
| `trip_gradient_card.dart` | Trip summary cards |
| `custom_big_text_form_field.dart` | Large amount input |

Import: `package:splitter/Widgets/<file>.dart`

### Feature-scoped widgets (stay in feature folder)

```
lib/Screen/GroupScreen/SharingTypeTabs/     # even, uneven, percentage, shares, by_item
lib/Screen/GroupScreen/GraphAnalysisWidgets/  # fl_chart widgets
lib/Screen/ProfileScreen/badges_section_widget.dart
lib/Screen/HomeScreen/empty_state_widget.dart
lib/Screen/GroupScreen/shareable_settlement_card.dart
```

### New shared widget checklist

Create in `lib/Widgets/` only when used by **2+ features**:

```
lib/Widgets/my_widget.dart
class MyWidget extends StatelessWidget { ... }
```

Do **not** add to `Constants/shared.dart`.

---

## Forms

### Existing form widgets

| Widget | Location |
|--------|----------|
| `PrimaryTextFormField` | `Constants/shared.dart` |
| `CustomBigTextFormField` | `Widgets/custom_big_text_form_field.dart` |

Use `Form` + validators. Validation logic in controller, not `build()`.

```dart
// Controller
String? validateAmount(String? value) {
  if (value == null || value.isEmpty) return 'Amount required';
  if (double.tryParse(value) == null) return 'Invalid amount';
  return null;
}
```

---

## Animations

| Component | Location |
|-----------|----------|
| `StaggeredListAnimation` | `Constants/staggered_list_animation.dart` |
| `loading_animation_widget` package | Loaders in `shared.dart` |
| Lottie | `pubspec.yaml` — monthly recap, onboarding |

Use `const` constructors and `AnimatedContainer` (see `BottomNavigationController` nav item).

---

## Lists and performance

- `ListView.builder` / `GridView.builder` for dynamic lists
- `cached_network_image` for remote avatars (`user_avatar.dart`)
- `const` widgets where values are compile-time constant

---

## Currency display

Use `Get.find<CurrencyController>()` for symbol — do not hardcode `₹`:

```dart
// lib/Widgets/transaction_tile.dart pattern
final sym = Get.find<CurrencyController>().symbol;
```

---

## Forbidden Practices

| Forbidden | Use |
|-----------|-----|
| New widget in `Constants/` | `lib/Widgets/` or feature folder |
| Duplicate avatar/transaction row UI | `UserAvatar`, `TransactionTile` |
| Business logic in `build()` | Controller |
| API calls in `build()` | Controller `onInit` |
| Widget file > 200 lines (new code) | Extract child widgets |
| Hardcoded asset paths | Centralize when asset constants file exists |

---

## Anti-Patterns

| Anti-pattern | Location |
|--------------|----------|
| `shared.dart` as widget dump | 989 lines mixing forms, chips, dialogs |
| Widgets in Constants | `emoji_reaction_widget.dart`, `sync_indicator_widget.dart` |
| Duplicate form fields | `PrimaryTextFormField` vs `CustomBigTextFormField` — pick closest match |
| Full-screen `Obx` | Wrap only changing subtrees |

---

## Extraction pattern

When splitting a large screen:

```
lib/Screen/GroupScreen/
  group_screen.dart              # scaffold + layout only
  widgets/
    group_list_section.dart      # extracted section
    group_header.dart
```

For Group feature, subfolders `SharingTypeTabs/` and `GraphAnalysisWidgets/` already demonstrate colocation — follow same pattern for other features.

---

## Migration Guidance

1. **New UI:** `lib/Widgets/` if cross-feature; else colocate in `Screen/<Feature>/`.
2. **Editing `shared.dart`:** Extract touched widget to `Widgets/` instead of growing file.
3. **Editing god screens:** Extract visual sections to `widgets/` subfolder; leave controller calls in parent.
4. **Constants widgets:** Leave in place until touched; move on edit.

---

## AI Instructions

1. Search `lib/Widgets/` and `Constants/shared.dart` before creating new components.
2. Never add new widgets to `Constants/` — use `Widgets/` or feature folder.
3. Keep widgets Stateless when possible; state in controller.
4. Use Neopop components for cards/buttons matching existing screens.
5. Display money with `CurrencyController.symbol`.
6. Split any new widget file before it exceeds 200 lines.
7. Feature-specific chart/tab UI stays under `Screen/<Feature>/`.
