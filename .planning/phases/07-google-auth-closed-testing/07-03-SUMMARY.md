---
phase: 07-google-auth-closed-testing
plan: 03
subsystem: auth
tags: [android, app-links, assetlinks, deep-links, vercel, supabase]

requires:
  - phase: 07-google-auth-closed-testing
    provides: Native Google sign-in and CI env validation (07-01, 07-02)
provides:
  - Play app-signing SHA-256 in assetlinks.json for money.splitr.app
  - HTTPS auth callback deep link unit test coverage
  - Verified AndroidManifest App Links intent-filter for /auth/callback
affects: [closed-testing, email-auth, password-recovery]

actuals:
  tokens: 3200
  tasks: 3
  commits: 1

tech-stack:
  added: []
  patterns:
    - "HTTPS App Link primary at https://splitr.money/auth/callback with custom scheme fallback"
    - "assetlinks.json binds Play app-signing cert to money.splitr.app"

key-files:
  created: []
  modified:
    - apps/web/public/.well-known/assetlinks.json
    - apps/mobile/test/deep_link_service_test.dart

key-decisions:
  - "Play app-signing SHA-256 (not upload key) used in assetlinks.json per AUTH-04"
  - "AndroidManifest left unchanged — autoVerify and /auth/callback already correct"
  - "Vercel production deploy deferred — CLI present but not authenticated"

patterns-established:
  - "DeepLinkService.isAuthCallbackUri handles both HTTPS and splitr://login-callback/ URIs"

requirements-completed: [AUTH-04]

coverage:
  - id: D1
    description: assetlinks.json populated with Play app-signing SHA-256 for money.splitr.app
    requirement: AUTH-04
    verification:
      - kind: unit
        ref: "node assetlinks fingerprint length check"
        status: pass
    human_judgment: false
  - id: D2
    description: DeepLinkService recognizes HTTPS auth callback URIs including recovery
    verification:
      - kind: unit
        ref: "apps/mobile/test/deep_link_service_test.dart#auth callback"
        status: pass
    human_judgment: false
  - id: D3
    description: AndroidManifest has autoVerify=true for splitr.money /auth/callback
    verification:
      - kind: other
        ref: "rg autoVerify|auth/callback|splitr.money AndroidManifest.xml"
        status: pass
    human_judgment: false
  - id: D4
    description: Production assetlinks.json live on splitr.money via Vercel
    verification:
      - kind: manual_procedural
        ref: "curl -s https://www.splitr.money/.well-known/assetlinks.json"
        status: fail
    human_judgment: true
    rationale: "Vercel CLI not authenticated; live site still serves empty fingerprints array — user must deploy"

duration: 25min
completed: 2026-08-08
status: complete
---

# Phase 7 Plan 3: App Links & Email Auth Redirect Summary

**Play app-signing SHA-256 in assetlinks.json with HTTPS auth callback deep link tests; manifest verified; Vercel deploy pending user auth**

## Performance

- **Duration:** 25 min
- **Started:** 2026-08-08T06:00:00Z
- **Completed:** 2026-08-08T06:25:00Z
- **Tasks:** 3
- **Files modified:** 2

## Accomplishments

- Populated `assetlinks.json` with Play app-signing SHA-256 `8E:49:D2:B3:...:D9:C9` for `money.splitr.app`
- Added explicit HTTPS deep link tests (callback, query params, recovery, custom scheme regression)
- Verified AndroidManifest already has `android:autoVerify="true"` and `/auth/callback` for splitr.money and www.splitr.money
- Confirmed `auth/callback/index.html` still bridges to `splitr://login-callback/` when App Link verification pending

## Task Commits

1. **Task 1: Play SHA-256 checkpoint** — resolved by user (no commit)
2. **Task 2: Tracer — HTTPS auth callback** — `ad985d1` (feat)
3. **Task 3: Manifest verify + Vercel deploy** — verification-only (no code changes; deploy blocked)

**Plan metadata:** pending (docs commit)

## Files Created/Modified

- `apps/web/public/.well-known/assetlinks.json` — Play app-signing SHA-256 fingerprint
- `apps/mobile/test/deep_link_service_test.dart` — HTTPS App Link and recovery test cases

## Decisions Made

- Used Play **app signing** SHA-256 from checkpoint (not upload key)
- Manifest verify-first: no edits needed — filters already correct
- Kept `splitr://login-callback/` custom scheme fallback per D-18

## Deviations from Plan

None - plan executed as written. Vercel deploy could not complete due to missing CLI credentials (documented below, not a code deviation).

## Issues Encountered

- **Vercel CLI not authenticated:** `vercel deploy --prod` failed with "No existing credentials found". Live `https://www.splitr.money/.well-known/assetlinks.json` still returns empty `sha256_cert_fingerprints: []`. User must deploy.

## User Setup Required

### Vercel production deploy (required before closed testing)

```bash
# 1. Authenticate (one-time)
vercel login

# 2. From apps/web, deploy to production
cd apps/web
vercel deploy --prod
```

Alternatively: merge/push branch to production branch linked to Vercel project for `splitr.money`.

**Verify after deploy:**

```bash
curl.exe -s https://www.splitr.money/.well-known/assetlinks.json
# Expect sha256_cert_fingerprints array with 8E:49:D2:B3:...

curl.exe -sI https://www.splitr.money/.well-known/assetlinks.json
# Expect HTTP/1.1 200, Content-Type: application/json

curl.exe -sI https://splitr.money/auth/callback
# Expect 200 (serves auth/callback/index.html)
```

### Supabase redirect URL checklist

In **Supabase Dashboard → Authentication → URL Configuration → Redirect URLs**, ensure both:

- `https://splitr.money/auth/callback` (primary, D-15)
- `splitr://login-callback/` (custom scheme fallback, D-18)

### Android App Links verification (after install on device)

```bash
adb shell pm get-app-links money.splitr.app
# Expect splitr.money domain state: verified (after assetlinks deploy + fresh install)
```

### D-20 note (Google browser OAuth redirect URLs)

After 07-02 native-only Google ships, unused browser OAuth redirect URLs in Supabase may be removable. Defer until closed-testing confirms no browser OAuth path remains.

## Next Phase Readiness

- Code and tests ready; **blocked on Vercel deploy** for live App Link verification
- After deploy: manual email confirm + password reset on Android closed-testing build

## Self-Check: PASSED

- FOUND: `.planning/phases/07-google-auth-closed-testing/07-03-SUMMARY.md`
- FOUND: commit `ad985d1`
- FOUND: `apps/web/public/.well-known/assetlinks.json` with fingerprint
- PENDING: live Vercel deploy (user action)

---
*Phase: 07-google-auth-closed-testing*
*Completed: 2026-08-08*
