---
phase: 07-google-auth-closed-testing
plan: 01
subsystem: infra
tags: [node, github-actions, android, auth, ci, env-validation]

requires: []
provides:
  - Production env validator (validate-env-prod.mjs) for CI and local AAB
  - deploy_android.yml gates for placeholder secrets and SHA-1 fingerprints
affects: [07-02, 07-03, google-auth, closed-testing]

actuals:
  tokens: 3200
  tasks: 3
  commits: 3

tech-stack:
  added: []
  patterns:
    - "Node built-ins-only env validator shared between CI and local AAB script"
    - "D-05 tier-1 SHA-1 compare + Play signing secret presence (GCP API deferred)"

key-files:
  created:
    - scripts/validate-env-prod.mjs
    - scripts/validate-env-prod.test.mjs
  modified:
    - .github/workflows/deploy_android.yml
    - scripts/mobile-build-aab.sh

key-decisions:
  - "D-05 tier-1: compare upload SHA-1 to GCP_ANDROID_OAUTH_UPLOAD_SHA1; require Play signing secret non-empty; defer GCP Credentials API read"
  - "Validator runs only on release path (deploy_android.yml + mobile-build-aab.sh), not debug/profile"

patterns-established:
  - "Blocklist + format validation for required prod keys with optional-key contract when non-empty"

requirements-completed: [AUTH-01]

coverage:
  - id: D1
    description: "CI rejects placeholder/invalid env.prod.json before flutter build"
    requirement: AUTH-01
    verification:
      - kind: unit
        ref: "node scripts/validate-env-prod.mjs apps/mobile/env.example.json → exit 1"
        status: pass
      - kind: unit
        ref: "node --test scripts/validate-env-prod.test.mjs"
        status: pass
    human_judgment: false
  - id: D2
    description: "deploy_android.yml runs validator after materialize env.prod.json"
    requirement: AUTH-01
    verification:
      - kind: integration
        ref: "rg validate-env-prod .github/workflows/deploy_android.yml"
        status: pass
    human_judgment: false
  - id: D3
    description: "CI SHA-1 fingerprint gate (upload match + Play signing secret present)"
    requirement: AUTH-01
    verification:
      - kind: integration
        ref: "deploy_android.yml Verify Android signing fingerprints step"
        status: pass
    human_judgment: true
    rationale: "Full CI run requires GitHub internal environment secrets; tier-1 gate logic verified by workflow inspection only"
  - id: D4
    description: "Local AAB script invokes same validator when env.prod.json present"
    requirement: AUTH-01
    verification:
      - kind: integration
        ref: "rg validate-env-prod scripts/mobile-build-aab.sh"
        status: pass
    human_judgment: false

duration: 25min
completed: 2026-08-08
status: complete
---

# Phase 7 Plan 01: CI Env Validator + SHA-1 Gate Summary

**Node env validator blocks placeholder prod secrets in CI and local AAB builds; D-05 tier-1 SHA-1 fingerprint gate on deploy_android release pipeline**

## Performance

- **Duration:** 25 min
- **Started:** 2026-08-08T05:53:00Z
- **Completed:** 2026-08-08T06:18:00Z
- **Tasks:** 3
- **Files modified:** 4

## Accomplishments

- `validate-env-prod.mjs` validates required keys (blocklist + format) and optional keys when non-empty (D-12)
- `deploy_android.yml` runs validator after `Materialize env.prod.json`, before `flutter pub get` (D-14 release-only)
- SHA-1 fingerprint step compares upload keystore to `GCP_ANDROID_OAUTH_UPLOAD_SHA1`; fails if `GCP_ANDROID_OAUTH_PLAY_SIGNING_SHA1` unset
- `mobile-build-aab.sh` optionally runs same validator before local release AAB build (D-21)

## D-05 Tier-1 Scope

| Check | Tier-1 (shipped) | Deferred |
|-------|------------------|----------|
| Upload keystore SHA-1 | Compared to `GCP_ANDROID_OAUTH_UPLOAD_SHA1` | — |
| Play app-signing SHA-1 | Secret must be non-empty; operator keeps GCP registration in sync | GCP Credentials API read confirming fingerprint on Android OAuth client |

**Rationale for deferral:** GCP API verification adds setup cost and no read API in current CI; revisit if secret-non-empty proves insufficient.

## Task Commits

1. **Tracer: env validator rejects placeholders end-to-end** - `3ffac3f` (feat)
2. **CI SHA-1 fingerprint gate for GCP Android OAuth client (D-05 tier-1)** - `e149ccf` (feat)
3. **Optional local AAB validator hook** - `a33bfc3` (feat)

## Files Created/Modified

- `scripts/validate-env-prod.mjs` - Blocklist, format rules, optional-key contract; Node built-ins only
- `scripts/validate-env-prod.test.mjs` - Seven `node --test` cases (placeholders, valid fixture, malformed JSON, per-key failures)
- `.github/workflows/deploy_android.yml` - Validate production env + Verify Android signing fingerprints steps
- `scripts/mobile-build-aab.sh` - Calls validator when script exists

## Decisions Made

- D-05 tier-1: upload SHA-1 string compare + Play signing secret presence; no GCP API call in this plan
- Validator scoped to release paths only (not debug/profile workflows)

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None

## User Setup Required

GitHub internal environment secrets for release pipeline:

- `GCP_ANDROID_OAUTH_UPLOAD_SHA1` — colon-separated uppercase SHA-1 from upload keystore (`keytool -list -v`)
- `GCP_ANDROID_OAUTH_PLAY_SIGNING_SHA1` — Play Console app-signing SHA-1 (must be registered in GCP Android OAuth client manually)

## Next Phase Readiness

- AUTH-01 CI gates ready for 07-02 (auth service changes can assume validator blocks bad env)
- Operator must set fingerprint secrets before next deploy_android run succeeds

## Self-Check: PASSED

- FOUND: scripts/validate-env-prod.mjs
- FOUND: scripts/validate-env-prod.test.mjs
- FOUND: commit 3ffac3f
- FOUND: commit e149ccf
- FOUND: commit a33bfc3

---
*Phase: 07-google-auth-closed-testing*
*Completed: 2026-08-08*
