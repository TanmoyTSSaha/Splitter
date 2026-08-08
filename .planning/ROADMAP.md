# Roadmap: Splitr

## Overview

Brownfield roadmap prioritizing sync reliability and security hardening first, then web responsive fixes, mobile maintainability, and CI/tooling alignment. Phases map to active requirements inferred from `.planning/codebase/CONCERNS.md`.

## Phases

- [ ] **Phase 1: Sync Reliability** — Fix failed sync retry and queue recovery
- [ ] **Phase 2: Security Hardening** — Fail-closed cron auth and secret surface reduction
- [ ] **Phase 3: Web Responsive UX** — Landing comparison table mobile fixes
- [ ] **Phase 4: Mobile Maintainability** — DI cleanup and oversized file decomposition
- [ ] **Phase 5: Tooling Alignment** — Package manager and SDK version consistency
- [ ] **Phase 6: Android Performance** — Faster cold start, smoother scroll, smaller release APK
- [ ] **Phase 7: Google Auth (Closed Testing)** — Reliable native Google sign-in for Play testers; block misconfigured release builds

## Phase Details

### Phase 1: Sync Reliability

**Goal**: Queued mobile mutations recover from transient failures without manual data loss
**Depends on**: Nothing (first phase)
**Requirements**: SYNC-01, SYNC-02, SYNC-03
**Success Criteria** (what must be TRUE):

  1. Airplane-mode toggle during expense enqueue does not permanently strand the mutation
  2. Failed rows retry with incremented `retryCount` and backoff
  3. Persistent failures show actionable UI instead of silent stale state

**Plans**: 2 plans

Plans:

- [ ] 01-01: Fix `markFailed` / `getPendingSyncItems` retry logic in Drift + sync service
- [ ] 01-02: Add UI surfacing for persistent sync failures and verification tests

### Phase 2: Security Hardening

**Goal**: Server endpoints and client builds minimize credential exposure
**Depends on**: Phase 1
**Requirements**: SEC-01, SEC-02, SEC-03
**Success Criteria** (what must be TRUE):

  1. Cron edge functions return 401 without valid secret even when env var unset
  2. Mobile release build contains no Gemini API key
  3. Unused DB password / connection string dart-defines removed

**Plans**: 2 plans

Plans:

- [ ] 02-01: Fail-closed cron auth on `process-*` edge functions
- [ ] 02-02: Proxy Gemini through edge function; prune mobile secret surface

### Phase 3: Web Responsive UX

**Goal**: Landing comparison section works on phone viewports
**Depends on**: Phase 2
**Requirements**: WEB-01, WEB-02, WEB-03
**Success Criteria** (what must be TRUE):

  1. `/#compare` readable at 320px without losing Splitr column context
  2. Horizontal scroll discoverable when table min-width exceeds viewport
  3. Responsive audit scripts pass comparison table checks at mobile widths

**Plans**: 2 plans

Plans:

- [ ] 03-01: Redesign `ComparisonTable` layout/CSS for mobile breakpoints
- [ ] 03-02: Update responsive audit coverage and verify screenshots

### Phase 4: Mobile Maintainability

**Goal**: Reduce DI drift and decompose highest-risk oversized files
**Depends on**: Phase 3
**Requirements**: MOB-01, MOB-02, MOB-03
**Success Criteria** (what must be TRUE):

  1. No inline `Get.put` in share-tab or transaction screens
  2. Add-transaction flow split into testable controller + sections
  3. AI goal suggestions either work or UI copy removed

**Plans**: 3 plans

Plans:

- [ ] 04-01: Consolidate GetX DI through bindings
- [ ] 04-02: Decompose `add_transaction_screen.dart`
- [ ] 04-03: Resolve `AIService.getGoalSuggestions` stub

### Phase 5: Tooling Alignment

**Goal**: Reproducible web installs and consistent Supabase SDK versions
**Depends on**: Phase 4
**Requirements**: CI-01, CI-02
**Success Criteria** (what must be TRUE):

  1. One lockfile strategy for `apps/web`; CI matches local dev
  2. Edge functions and clients on aligned Supabase JS major/minor

**Plans**: 2 plans

Plans:

- [ ] 05-01: Pick npm or pnpm; align CI and root scripts
- [ ] 05-02: Pin edge function Supabase SDK; add smoke tests

### Phase 6: Android Performance

**Goal**: Android app feels fast on mid-range devices — quick cold start, smooth lists, lean release build
**Depends on**: Phase 5
**Requirements**: PERF-01, PERF-02, PERF-03, PERF-04, PERF-05
**Success Criteria** (what must be TRUE):

  1. Cold start to interactive splash/home measurably faster than baseline (target TTI improvement documented)
  2. Long transaction/friend lists scroll without jank on 60fps mid-range device
  3. Avatar/network images use disk cache; no raw `Image.network` on list surfaces
  4. Release APK smaller or equal with R8 minify + resource shrink enabled
  5. Realtime and sync work deferred or scoped so background battery drain is bounded

**Plans**: 3 plans

Plans:
**Wave 1**

- [ ] 06-01: Defer non-critical bootstrap (push, deep link, share intent) past first frame; lazy service init

**Wave 2** *(blocked on Wave 1 completion)*

- [ ] 06-02: List/image perf — cached images, rebuild scope, spending-intelligence batch RPC

**Wave 3** *(blocked on Wave 2 completion)*

- [ ] 06-03: Release build tuning — minify, shrinkResources, visual-effect budget on low-end

### Phase 7: Google Auth (Closed Testing)

**Goal**: Play closed-testing testers can sign in with Google reliably — no placeholder Supabase URLs or browser OAuth fallback in release builds
**Depends on**: Phase 6 (or can run in parallel if closed testing is blocked)
**Requirements**: AUTH-01, AUTH-02, AUTH-03, AUTH-04
**Success Criteria** (what must be TRUE):

  1. Release CI fails if `env.prod.json` contains placeholder Supabase/Google/Razorpay/Sentry values
  2. Google sign-in uses native account picker only; no external Chrome tab to Supabase OAuth for mobile
  3. Misconfigured builds show clear user error + Sentry event; email/password fallback remains
  4. Email/password recovery and confirm links complete via `https://splitr.money/auth/callback` App Links

**Plans**: 2/3 plans executed

Plans:

- [x] 07-01-PLAN.md
- [x] 07-02-PLAN.md
- [ ] 07-03-PLAN.md

**Wave 1** *(parallel)*

- [x] 07-01: CI release gates — validate-env-prod.mjs, SHA fingerprint check, deploy_android.yml
- [ ] 07-03: App Links + email auth callbacks — assetlinks.json, DeepLinkService, web deploy

**Wave 2** *(blocked on 07-01)*

- [ ] 07-02: Native Google auth — remove browser fallback, error UX, identity linking (checkpoint before D-01)

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5 → 6 → 7 (Phase 7 may run in parallel with 6 if closed testing is blocked)

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Sync Reliability | 0/2 | Not started | - |
| 2. Security Hardening | 0/2 | Not started | - |
| 3. Web Responsive UX | 0/2 | Not started | - |
| 4. Mobile Maintainability | 0/3 | Not started | - |
| 5. Tooling Alignment | 0/2 | Not started | - |
| 6. Android Performance | 0/3 | Not started | - |
| 7. Google Auth (Closed Testing) | 2/3 | In Progress|  |
