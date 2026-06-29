# SplitO Technology Stack

## Core

| Technology | Version | Purpose |
|------------|---------|---------|
| Flutter | SDK `>=3.4.3 <4.0.0` | UI framework |
| Dart | 3.4+ | Language |
| GetX | ^4.6.6 | State, DI, navigation |
| Material 3 | `useMaterial3: true` | Design system base |

## Backend

| Technology | Purpose |
|------------|---------|
| Supabase | Auth, Postgres, Realtime, Storage |
| `supabase_flutter` ^2.6.0 | Client SDK |
| `supabase/migrations/` | SQL schema migrations |

## Local / Offline

| Technology | Purpose |
|------------|---------|
| Drift ^2.16.0 | SQLite ORM |
| `sqlite3_flutter_libs` | Native SQLite |
| `connectivity_plus` | Network status for sync |
| `shared_preferences` | Onboarding, currency pref |

## UI / UX

| Package | Purpose |
|---------|---------|
| `neopop` | Card/button design |
| `google_fonts` | Lato in text theme |
| Albra (bundled) | Serif font in pubspec |
| `fl_chart` | Charts / analytics |
| `flutter_svg` | Icons |
| `cached_network_image` | Avatars |
| `lottie` | Animations |
| `loading_animation_widget` | Loaders |
| `story_view` | Monthly recap stories |

## Device / Platform

| Package | Purpose |
|---------|---------|
| `local_auth` | Biometric lock |
| `flutter_local_notifications` | Reminders |
| `image_picker` | Receipt photos |
| `google_mlkit_text_recognition` | Receipt OCR |
| `vibration` | Haptics |
| `share_plus` + `screenshot` | Shareable cards |

## AI

| Package | Purpose |
|---------|---------|
| `google_generative_ai` | Goal estimation, feasibility, icons |

## Dev tooling

| Package | Purpose |
|------------|---------|
| `flutter_lints` | Analyzer |
| `drift_dev` + `build_runner` | Drift codegen |

## Explicitly not used

Riverpod, Provider, Bloc, GoRouter, Dio, Freezed, json_serializable, Appwrite, Hive.

## Credentials

`lib/git_ignore.dart` — Supabase URL/key, Gemini API key.

## Platforms

android, ios, linux, macos, windows (standard Flutter multi-platform).

## CI/CD

None configured.
