# Security Rules — SplitO (Splitter)

## Purpose

Credential management and sensitive data handling for SplitO. This project stores API keys in a dedicated Dart file — not environment variables or `--dart-define`.

---

## Credentials File

### Location

```
lib/git_ignore.dart
```

Despite the name, this file is **committed source** (project convention). Import:

```dart
import 'package:splitter/git_ignore.dart';
```

### Contents

| Constant | Purpose |
|----------|---------|
| `supabaseURL` | Supabase project URL |
| `supabaseAnonPublicKey` | Supabase anon/publishable key |
| `supabaseDirectDatabaseConnectionString` | Direct Postgres (dev/admin — placeholder password) |
| `geminiApiKey` | Google Generative AI |
| `geminiProjectName` | Optional Gemini metadata |
| `geminiProjectNumber` | Optional Gemini metadata |
| `appwriteProjectId` | Legacy stub (empty) |

### Usage in app

```dart
// lib/main.dart
await Supabase.initialize(
  url: supabaseURL,
  anonKey: supabaseAnonPublicKey,
);
```

```dart
// lib/Services/ai_service.dart
// Uses geminiApiKey from git_ignore.dart
```

---

## Required Conventions

### Adding new API keys

1. Add constant to `lib/git_ignore.dart` with comment describing service.
2. Import from `package:splitter/git_ignore.dart` in the service that needs it.
3. **Never** inline keys in screens, controllers, or widgets.

```dart
// Good
import 'package:splitter/git_ignore.dart';
final model = GenerativeModel(apiKey: geminiApiKey, ...);

// Forbidden
const apiKey = 'AIza...';
```

### Supabase anon key

Client-side anon key is expected for Flutter apps. **Data protection relies on Supabase Row Level Security (RLS)** — verify policies on all tables.

### Gemini API key in client

`geminiApiKey` is exposed in the app binary. Acceptable for development per project pattern; production should use a Supabase Edge Function or backend proxy to hide the key. Document risk; do not remove without migration plan.

---

## Forbidden Practices

| Forbidden | Reason |
|-----------|--------|
| Log passwords or tokens | `AuthService` debugPrints session — do not extend |
| Log full `AuthResponse` in production paths | Credential leakage |
| Store API keys in `SharedPreferences` or Drift | Use `git_ignore.dart` |
| Add keys to `pubspec.yaml` or assets | Source exposure |
| Commit `.env` with real secrets without team agreement | Project uses `git_ignore.dart` pattern |
| Hardcode Supabase URL in multiple files | Single source: `git_ignore.dart` |

---

## Authentication Security

- Session managed by `supabase_flutter` — do not persist tokens manually.
- Biometric gate: `BiometricAuthService` + `BiometricLockScreen` before main app.
- Sign out: `SupabaseAuth().supabaseSignOut()` from profile.

---

## User Data

- Do not log PII (`email`, `phone`, full names) in `debugPrint` for new code.
- Profile updates via `UserService` / `SupabaseDatabase` — no local plaintext password storage (Supabase handles auth).

---

## Anti-Patterns

| Pattern | Location |
|---------|----------|
| `debugPrint("Session: $session")` | `auth_service.dart` |
| Empty Appwrite stub | `git_ignore.dart` — remove when cleaning legacy |
| Postgres connection string with placeholder | `git_ignore.dart` — dev tooling only, never use from app runtime |

---

## Migration Guidance

If moving to `--dart-define` or CI secrets later:

1. Keep `git_ignore.dart` as fallback or remove after all import sites updated.
2. Update `main.dart` and `ai_service.dart` first.
3. Do not change pattern in a single AI session without explicit user request.

---

## AI Instructions

1. All new secrets go in `lib/git_ignore.dart`.
2. Import via `package:splitter/git_ignore.dart`.
3. Never hardcode API keys in generated service or screen code.
4. Do not add `debugPrint` of sessions, tokens, or passwords.
5. Do not store credentials in SharedPreferences or SQLite.
6. Remind that client-side Gemini keys are extractable from APK/IPA.
7. Do not add real passwords to `supabaseDirectDatabaseConnectionString` in commits.
