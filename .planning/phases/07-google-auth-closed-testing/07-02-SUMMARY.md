---
phase: 07-google-auth-closed-testing
plan: 02
subsystem: auth
tags: [google-sign-in, supabase, sentry, flutter, native-auth]

requires:
  - phase: 07-google-auth-closed-testing
    provides: CI env validator and release gates from 07-01
provides:
  - Native-only Google sign-in via google_sign_in + signInWithIdToken
  - D-10 linkIdentityWithIdToken fallback for verified-email conflicts
  - Sentry contract for config/AuthException paths (not cancel/offline)
  - Updated google_auth_flow_test.dart with outcome and Sentry contract tests
affects: [07-03, closed-testing-promote, manual-uat]

actuals:
  tokens: 10000
  tasks: 3
  commits: 2

tech-stack:
  added: []
  patterns:
    - "GoogleAuthErrors test seams for Sentry contract and D-10 conflict detection"
    - "AuthService offline gate via connectivity_plus before Google flow"

key-files:
  created: []
  modified:
    - apps/mobile/lib/Services/SupabaseServices/auth_service.dart
    - apps/mobile/lib/Services/google_auth_result.dart
    - apps/mobile/lib/Services/google_auth_errors.dart
    - apps/mobile/lib/Constants/app_strings.dart
    - apps/mobile/lib/Screen/AuthScreens/login_screen.dart
    - apps/mobile/lib/Screen/AuthScreens/register_screen.dart
    - apps/mobile/test/google_auth_flow_test.dart

key-decisions:
  - "D-01 confirmed: removed browser OAuth fallback permanently (option-a)"
  - "D-10: linkIdentityWithIdToken attempted on verified-email identity conflict before password-only error"

patterns-established:
  - "Google auth Sentry: report config/AuthException with feature:auth; skip cancel and offline"

requirements-completed: [AUTH-02, AUTH-03]

coverage:
  - id: D1
    description: Native-only Google sign-in — no signInWithOAuth browser tab
    requirement: AUTH-02
    verification:
      - kind: unit
        ref: "apps/mobile/test/google_auth_flow_test.dart"
        status: pass
      - kind: other
        ref: "rg signInWithOAuth|pendingBrowser|isPendingBrowser apps/mobile/lib — zero matches"
        status: pass
    human_judgment: true
    rationale: "M1 manual test on internal-track build required to confirm no Chrome tab"
  - id: D2
    description: Config-missing blocks with email-sign-in copy and Sentry feature:auth
    requirement: AUTH-03
    verification:
      - kind: unit
        ref: "google_auth_flow_test.dart#missing GOOGLE_WEB_CLIENT_ID must report to Sentry"
        status: pass
    human_judgment: true
    rationale: "M7 manual test on misconfigured build"
  - id: D3
    description: D-10 linkIdentityWithIdToken fallback for verified-email conflict
    requirement: AUTH-02
    verification:
      - kind: unit
        ref: "google_auth_flow_test.dart#D-10 identity conflict triggers linkIdentityWithIdToken"
        status: pass
    human_judgment: true
    rationale: "M2/M4 manual matrix requires device + Supabase manual linking toggle verification"

duration: 45min
completed: 2026-08-08
status: complete
---

# Phase 7 Plan 02: Native Google Auth Summary

**Native-only Google sign-in with offline/cancel/config UX, Sentry auth contract, and linkIdentityWithIdToken fallback for verified-email conflicts**

## Performance

- **Duration:** ~45 min
- **Tasks:** 3 (tracer, D-01 checkpoint, implementation)
- **Files modified:** 7
- **Commits:** 2 task commits

## Accomplishments

- Removed `signInWithOAuth` browser fallback and `pendingBrowser` outcome (D-01)
- Added offline gate, cancel toast, config-missing path with Sentry `feature: auth` (D-02–D-09)
- Implemented `linkIdentityWithIdToken` fallback when `signInWithIdToken` hits verified-email identity conflict (D-10)
- Login and register screens share identical `signInWithGoogle()` flow with cancel handling
- 19 unit tests pass in `google_auth_flow_test.dart`

## Task Commits

1. **Task 1: Tracer — native Google happy path tests** - `8c92cb3` (test)
2. **Task 2: D-01 checkpoint** - ⚡ Auto-selected option-a (native-only; locked in CONTEXT.md)
3. **Task 3: Remove browser OAuth + D-10 linking** - `98afc62` (feat)

## Files Created/Modified

- `apps/mobile/lib/Services/SupabaseServices/auth_service.dart` — native-only flow, offline gate, Sentry reporting, linkIdentityWithIdToken
- `apps/mobile/lib/Services/google_auth_result.dart` — removed pendingBrowser
- `apps/mobile/lib/Services/google_auth_errors.dart` — D-10 conflict detection, Sentry contract helpers
- `apps/mobile/lib/Constants/app_strings.dart` — cancel, offline, config-missing strings
- `apps/mobile/lib/Screen/AuthScreens/login_screen.dart` — cancel toast, no pendingBrowser branch
- `apps/mobile/lib/Screen/AuthScreens/register_screen.dart` — same as login
- `apps/mobile/test/google_auth_flow_test.dart` — outcome, Sentry, D-10 contract tests

## Decisions Made

- **D-01:** Proceeded with native-only Google sign-in (option-a); browser OAuth removed
- **D-10:** `linkIdentityWithIdToken` called when `signInWithIdToken` throws verified-email identity conflict

## Deviations from Plan

None - plan executed exactly as written.

## D-10 Manual Test Matrix (M1–M7)

Not executed in this executor session — requires internal-track device build.

| # | Expected | Pass? |
|---|----------|-------|
| M1 | Google picker → home; no Chrome tab | Pending |
| M2 | Email then Google same email → linked identities | Pending |
| M3 | Unverified email → verifyEmailBeforeGoogle | Pending |
| M4 | Manual linking toggle in Supabase if M2 needs linkIdentityWithIdToken | Pending |
| M5 | Airplane mode → offline message; no Sentry | Pending |
| M6 | Cancel picker → Sign-in cancelled toast; no Sentry | Pending |
| M7 | No client ID → email-sign-in message; Sentry feature:auth | Pending |

## Supabase Dashboard Note (D-10)

**Enable manual linking** may be required for `linkIdentityWithIdToken` to succeed when auto-link fails:

Supabase Dashboard → Authentication → Providers → enable **Manual linking** (or equivalent identity linking setting per project version). Retry M2/M4 after enabling if linking fails in app.

## Issues Encountered

None

## User Setup Required

None beyond 07-01 production env validation. Confirm Supabase manual linking toggle before closed-testing promote (M4).

## Next Phase Readiness

- AUTH-02/03 code complete; manual M1–M7 matrix pending on internal track
- Ready for 07-03 or closed-testing promote after manual verification

## Self-Check: PASSED

- `07-02-SUMMARY.md` exists
- Commits `8c92cb3`, `98afc62` found in git log
- `flutter test test/google_auth_flow_test.dart` — 19 passed

---
*Phase: 07-google-auth-closed-testing*
*Completed: 2026-08-08*
