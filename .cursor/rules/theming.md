# Theming Rules — Splitr

## Purpose

Visual design system for Splitr: colors, typography, Material theme, and Neopop components.

---

## Responsibilities

| Source | Contents |
|--------|----------|
| `lib/Constants/constants.dart` | Colors, text styles, `neopopColorScheme`, `splitter_custom_text_theme` |
| `lib/Constants/app_themes.dart` | `AppThemes.light` — applied in `main.dart` |
| `lib/main.dart` | `GetMaterialApp(theme: AppThemes.light)` |
| `neopop` package | Card/button components |
| `pubspec.yaml` fonts | Albra serif family |

---

## Theme Application

```dart
// lib/main.dart
GetMaterialApp(
  theme: AppThemes.light,
  // AppThemes.light wraps neopopColorScheme + splitter_custom_text_theme
)
```

Single light-theme shell with **dark** `neopopColorScheme` (`brightness: Brightness.dark`). No dark/light toggle today.

---

## Color Tokens

Import from `package:splitr/Constants/constants.dart`:

| Token | Hex | Use |
|-------|-----|-----|
| `neopopPrimary` | `#FE885D` | Primary actions, accents |
| `neopopAccent` | `#18C595` | Success, highlights, splash |
| `neopopBackground` | `#0D0D0D` | Dark backgrounds |
| `neopopSurface` | `#333333` | Cards, surfaces |
| `neopopError` | `#C62828` | Errors, destructive |
| `neopopYellow` | `#F9FE8A` | Warnings, sync indicator |
| `neopopGrey` | `#8A8D8E` | Muted text |
| `neopopSecondaryGrey` | `#323232` | Secondary surfaces |

### Snackbar colors (project pattern)

```dart
Get.snackbar("Success", msg, backgroundColor: neopopAccent, colorText: Colors.black);
Get.snackbar("Error", msg, backgroundColor: neopopError, colorText: Colors.white);
```

---

## Typography

### Named text styles (`constants.dart`)

```dart
headline1_text   // 32, bold, Poppins
headline2_text   // 28, w600
headline3_text   // 24, w500
body1_text, body2_text, caption_text, button_text, ...
```

### Font families

| Referenced | Source |
|------------|--------|
| `Poppins` | Used in `TextStyle` constants and bottom nav labels — **not bundled in pubspec** |
| `Albra` | Bundled in `pubspec.yaml` under `assets/fonts/` |
| `GoogleFonts.lato` | Used in `splitter_custom_text_theme` body/label slots |

**New UI:** Use `headline*_text` / `body*_text` from `constants.dart` for consistency. If Poppins renders with fallback, consider adding Poppins to pubspec or switching to Albra for headings — match surrounding screen.

### Bottom nav labels

```dart
// bottom_navigation_controller.dart
fontFamily: 'Poppins', fontSize: 10, fontWeight: w700/w500
```

---

## Neopop Components

Package: `neopop: ^1.0.2`

Used across group, lending, auth, and profile screens for elevated cards and buttons. When building new cards, follow patterns in:

- `lib/Widgets/active_group_card.dart`
- `lib/Screen/LendingScreen/lending_dashboard.dart`
- `lib/Screen/AuthScreens/login_screen.dart`

---

## Visual Primitives

| Widget | File |
|--------|------|
| `GlassCard` | `Constants/glass_card.dart` |
| `GradientMeshBackground` | `Constants/gradient_mesh_background.dart` |

Use for premium/empty states and hero sections.

---

## Required Conventions (New Code)

### Do

```dart
import 'package:splitr/Constants/constants.dart';

Text('Title', style: headline2_text);
Container(color: neopopSurface);
Icon(Icons.add, color: neopopAccent);
```

### Do not

```dart
// Avoid in new code
Text('Title', style: TextStyle(fontSize: 28, color: Color(0xFF333333)));
Container(color: Color(0xFFFAFAFA)); // unless matching specific screen BG documented below
```

### Screen background exception

`BottomNavigationController` and `HomeScreen` use `Color(0xFFFAFAFA)` light scaffold — intentional contrast with Neopop dark tokens on cards. Match parent scaffold when adding tabs to bottom nav.

---

## Responsive sizing (legacy)

```dart
// constants.dart — requires Get.context
double height_10 = (Get.height / devSysHeight).toInt() * 10;
```

Avoid new usages — prefer `MediaQuery` or fixed padding constants.

---

## Forbidden Practices

| Forbidden | Use |
|-----------|-----|
| Random `Color(0xFF...)` in new widgets | `neopop*` tokens |
| Inline font sizes outside text theme | `headline*_text`, `body*_text` |
| New theme system / ThemeExtension | Extend `constants.dart` |
| `Theme.of(context)` when token exists | Import constants (project dominant pattern) |

---

## Assets

SVG icons: `assets/icons/svg/` (declared in pubspec)

```dart
SvgPicture.asset('assets/icons/svg/<name>.svg')
```

Dev/empty state images: `assets/dev_images/`

---

## Migration Guidance

When editing a screen with hardcoded colors, replace with nearest `neopop*` token. Do not batch-refactor untouched files.

---

## AI Instructions

1. Import `constants.dart` for colors and text styles.
2. Use `neopopPrimary`, `neopopAccent`, `neopopError` for semantic colors.
3. Use `headline*_text` / `body*_text` for typography.
4. Use Neopop widgets for cards/buttons matching peer screens in the same feature.
5. `Get.snackbar` uses `neopopAccent` / `neopopError` backgrounds.
6. Do not introduce a second theme or light/dark toggle without explicit request.
7. Scaffold background on bottom-nav tabs: `0xFFFAFAFA` when inside main shell.
