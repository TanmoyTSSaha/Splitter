# Requirements: Splitr

**Defined:** 2026-08-07
**Core Value:** Users can split expenses with friends and groups reliably — including offline — and trust balances, settlements, and sync to stay correct.

## v1 Requirements

### Reliability & Sync

- [ ] **SYNC-01**: Failed sync queue items retry with backoff and eventually succeed or surface persistent errors to the user
- [ ] **SYNC-02**: `retryCount` increments on failure and eligible failed rows re-enter sync passes
- [ ] **SYNC-03**: Transient network errors do not permanently strand queued mutations

### Security

- [ ] **SEC-01**: Cron edge functions reject unauthenticated requests when `PUSH_CRON_SECRET` is unset (fail closed)
- [ ] **SEC-02**: Gemini API calls proxied through edge function; no extractable Gemini key in mobile release builds
- [ ] **SEC-03**: Unused privileged dart-defines removed from mobile secret surface

### Web UX

- [ ] **WEB-01**: Comparison table usable on 320–767px viewports without hidden critical content
- [ ] **WEB-02**: Horizontal scroll affordance visible when table exceeds viewport width
- [ ] **WEB-03**: Competitor column labels not truncated on mobile

### Mobile Maintainability

- [ ] **MOB-01**: GetX DI routed through bindings; inline `Get.put` removed from widgets
- [ ] **MOB-02**: `add_transaction_screen.dart` decomposed into controller + form sections
- [ ] **MOB-03**: `AIService.getGoalSuggestions` implemented or entry point removed

### Tooling & CI

- [ ] **CI-01**: Single package manager for `apps/web` (npm or pnpm) with aligned lockfile and CI
- [ ] **CI-02**: Supabase JS SDK versions aligned across edge functions and clients

### Android Performance

- [ ] **PERF-01**: Non-critical services (push, deep link, share intent) init after first frame; cold-start baseline measured
- [ ] **PERF-02**: List surfaces use `ListView.builder` + narrow GetX rebuild scope; spending intelligence batched
- [ ] **PERF-03**: Network images on lists use `cached_network_image`; raw `Image.network` removed from hot paths
- [ ] **PERF-04**: Release build enables R8 minify + `shrinkResources`; APK size tracked in CI
- [ ] **PERF-05**: Realtime subscriptions scoped to active screen; sync queue processes in chunks

### Closed Testing Auth

- [x] **AUTH-01**: Release CI rejects placeholder or invalid production secrets in `env.prod.json` / `PROD_ENV_JSON`
- [ ] **AUTH-02**: Mobile Google sign-in uses native `google_sign_in` only; browser OAuth fallback removed from release path
- [ ] **AUTH-03**: Google sign-in config failures surface clear user message and Sentry telemetry; email/password fallback remains
- [ ] **AUTH-04**: Email confirm and password reset complete via `https://splitr.money/auth/callback` App Links on Android

## v2 Requirements

### Offline Expansion

- **OFF-01**: Offline group creation with optimistic local ID + sync enqueue
- **OFF-02**: Broader offline coverage audit for non-transaction flows

### Web Parity

- **WEB-04**: Deeper authenticated web feature parity with mobile groups/friends
- **WEB-05**: Headless-friendly fallback for homepage motion (audit/SEO)

### AI Features

- **AI-01**: Goal suggestions fully wired to Gemini with Pro gating
- **AI-02**: Spending intelligence error paths surfaced to UI with telemetry

## Out of Scope

| Feature | Reason |
|---------|--------|
| Backend migration off Supabase | Platform of record; high cost |
| iOS-native push without FCM | Android-first; Firebase established |
| Full web/mobile feature parity | Web is marketing + light client |
| Real-time chat in groups | Not core to expense splitting value |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| SYNC-01 | Phase 1 | Pending |
| SYNC-02 | Phase 1 | Pending |
| SYNC-03 | Phase 1 | Pending |
| SEC-01 | Phase 2 | Pending |
| SEC-02 | Phase 2 | Pending |
| SEC-03 | Phase 2 | Pending |
| WEB-01 | Phase 3 | Pending |
| WEB-02 | Phase 3 | Pending |
| WEB-03 | Phase 3 | Pending |
| MOB-01 | Phase 4 | Pending |
| MOB-02 | Phase 4 | Pending |
| MOB-03 | Phase 4 | Pending |
| CI-01 | Phase 5 | Pending |
| CI-02 | Phase 5 | Pending |
| PERF-01 | Phase 6 | Pending |
| PERF-02 | Phase 6 | Pending |
| PERF-03 | Phase 6 | Pending |
| PERF-04 | Phase 6 | Pending |
| PERF-05 | Phase 6 | Pending |
| AUTH-01 | Phase 7 | Complete |
| AUTH-02 | Phase 7 | Pending |
| AUTH-03 | Phase 7 | Pending |
| AUTH-04 | Phase 7 | Pending |

**Coverage:**

- v1 requirements: 23 total
- Mapped to phases: 19
- Unmapped: 0 ✓

---
*Requirements defined: 2026-08-07*
*Last updated: 2026-08-07 — Phase 6 Android Performance added*
