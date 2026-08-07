# Phase 6: Android Performance - Research

**Researched:** 2026-08-07
**Domain:** Flutter Android cold start, list virtualization, GetX rebuild budget, Supabase batch analytics, release APK tuning
**Confidence:** HIGH

## Summary

Phase 6 targets measurable Android perf on mid-range hardware inside `apps/mobile/`. Today `_bootstrapServices()` in `main.dart` serially awaits Supabase, Drift, sync, reminders, push, deep links, share intent, and prefs **before** `runApp` — blocking first frame by hundreds of ms to seconds. Locked decision D-01/D-02 splits critical vs deferred init and uses the ~1.8s splash animation (`AppMotion.splashFluid`) as parallel budget.

Scroll pain is concentrated: `all_transactions_screen.dart` uses `SliverChildListDelegate` (eager build all rows); `transaction_tab.dart` nests `ListView.separated(shrinkWrap: true)` inside `SingleChildScrollView` (layout thrash); `home_screen.dart` has 9 `Obx` scopes including nested wrappers; `transaction_tile.dart` runs per-row `Obx` for currency. Spending intelligence loops months calling `getMonthlySpendAnalytics` — 2 Supabase queries per month plus FX fetch duplication.

PERF-03/04/05 were planner discretion (D-16): migrate `UserAvatar`/`shared.dart` off raw `NetworkImage`/`Image.network` to `cached_network_image` (already in pubspec); enable explicit `minifyEnabled` + `shrinkResources` in `build.gradle` with Razorpay/Sentry keep rules; scope realtime (fix unfiltered `wishlist_upvotes` listener) and chunk `syncPendingItems`.

**Primary recommendation:** Split bootstrap → gate splash navigation on `Future.wait([deferredInit, animation])` → virtualize hot lists + narrow `Obx` → add `get_monthly_spend_trends` RPC → enable R8 shrink + Sentry `timeToFirstFrame`/`timeToHome` transactions.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Cold-start service init | Mobile client (`main.dart`, splash) | — | Only client controls pre-`runApp` work and splash gating |
| Cold-start metrics | Mobile client (Sentry + DevTools) | Sentry SaaS | Transactions emitted from Dart; analysis in Sentry |
| List virtualization / Obx scope | Mobile UI layer | Controller (data shape) | Flutter builds frames; controllers supply flat indices + currency symbol |
| Multi-month spend aggregates | Database (Supabase RPC) | Mobile service layer | SQL aggregation cuts round-trips; client maps JSON to existing shapes |
| Image disk cache | Mobile widgets | `cached_network_image` / `flutter_cache_manager` | Decode + cache on device |
| APK code/resource shrink | Android Gradle (`build.gradle`) | CI artifact logging | R8 runs at Android build; CI tracks size |
| Realtime subscription scope | Mobile `RealtimeService` | Supabase Realtime | Client subscribes/unsubscribes channels |
| Sync queue chunking | Mobile `SyncService` | Drift DB | Queue read/process on device |

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

#### Cold Start Strategy

- **D-01:** Before `runApp`, initialize only **Supabase** and **Drift** (`AppDatabase`). All other services defer off the critical path.
- **D-02:** Deferred services — sync listener, `ReminderService`, `PushNotificationService`, `DeepLinkService`, `ShareIntentService`, SharedPreferences/biometric check — init **during the splash animation window**, completing **before** navigation to home/login/onboarding. Use splash time as parallel init budget.
- **D-03:** Queue cold-start deep links / share intents received before `DeepLinkService` is ready; drain queue once service initializes (splash window must cover typical cold-start invite flows).
- **D-04:** Keep **Sentry init blocking** before `runApp` (current behavior). Do not defer Sentry to post-frame.
- **D-05:** Measure cold-start improvement two ways: (1) manual **Flutter DevTools timeline** baseline before/after, documented in plan; (2) **Sentry transactions** for `timeToFirstFrame` and `timeToHome` in release builds.

#### Scroll & Rebuild Budget

- **D-06:** Run a **list-pattern audit** across `apps/mobile/lib` — grep `ListView(`, `ListView.builder`, `SliverChildListDelegate`, `SingleChildScrollView` — profile and fix **worst offenders first** (known hot paths: `all_transactions_screen.dart`, `transaction_tab.dart`).
- **D-07:** Apply **surgical `Obx` split** on heavy screens (`home_screen.dart`, group tabs): one reactive scope per leaf widget; static layout uses plain/`const` widgets. Remove nested `Obx` wrappers that rebuild large subtrees.
- **D-08:** Replace sequential `getMonthlySpending` loops in `spending_intelligence_service.dart` with a **Supabase RPC** returning multi-month aggregates in one round trip. — **Reversibility:** costly — requires migration + client + any edge callers updated.
- **D-09:** Pagination vs in-memory cap: **researcher/planner discretion per screen** — document recommendation in plan (all-transactions already has "load older"; virtualize visible window regardless).
- **D-10:** Sectioned transaction lists (`all_transactions_screen`): **prototype both** `SliverChildBuilderDelegate` (index → section+row mapping) and flattened single-builder approaches; ship whichever is faster to implement correctly.
- **D-11:** `TransactionTile` currency display: **pass symbol from parent** list/controller; remove per-tile `Obx` subscribing to `CurrencyController`.
- **D-12:** `RepaintBoundary` on list rows: **only after profiling** confirms jank persists post-virtualization and `Obx` fixes. Do not add preemptively.
- **D-13:** Friends screen `TabBarView` tabs: use **`AutomaticKeepAliveClientMixin`** to preserve scroll position; tabs stay mounted.

### Claude's Discretion

- **D-14:** Per-screen pagination vs memory-cap strategy (D-09).
- **D-15:** Which lazy sectioned-list prototype wins (D-10) after spike on `all_transactions_screen`.
- **D-16:** PERF-03 (image caching), PERF-04 (R8/shrinkResources), PERF-05 (realtime/sync scoping) — not discussed with user; planner should align with ROADMAP success criteria unless user adds context later.

### Deferred Ideas (OUT OF SCOPE)

#### Not discussed (still in phase scope per ROADMAP — planner handles)

- Image caching policy (PERF-03) — `cached_network_image` vs raw `Image.network`
- Release APK R8 minify + `shrinkResources` (PERF-04)
- Visual effects budget — `GradientMeshBackground`, `GlassCard` blur on low-end devices
- Realtime subscribe scope + sync queue chunking (PERF-05)

#### Out of phase

- iOS-specific perf tuning — Android-first per PROJECT.md constraints
- Full web performance — Phase 3 covers web responsive only
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| PERF-01 | Non-critical services init after first frame; cold-start baseline measured | D-01/D-02 bootstrap split; splash-gated `Future.wait`; Sentry `timeToFirstFrame`/`timeToHome`; DevTools timeline protocol |
| PERF-02 | List surfaces use `ListView.builder` + narrow GetX rebuild scope; spending intelligence batched | `SliverChildBuilderDelegate` for sectioned lists; transaction_tab primary `ListView.builder`; Obx split pattern; `get_monthly_spend_trends` RPC |
| PERF-03 | Network images on lists use `cached_network_image`; raw `Image.network` removed from hot paths | `UserAvatar` + `shared.dart` migration; `CachedNetworkImage` / `CachedNetworkImageProvider` |
| PERF-04 | Release build enables R8 minify + `shrinkResources`; APK size tracked in CI | `build.gradle` release block; proguard keep rules; CI artifact size step |
| PERF-05 | Realtime subscriptions scoped to active screen; sync queue processes in chunks | Fix `wishlist_upvotes` unfiltered listener; retain single-group subscribe; sync batch size + yield |
</phase_requirements>

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Flutter SDK | 3.41.0 (stable, local) | UI, `SliverChildBuilderDelegate`, `WidgetsBinding` | Project runtime; list lazy build built-in [CITED: api.flutter.dev/widgets/SliverChildBuilderDelegate-class.html] |
| `cached_network_image` | `^3.3.0` (pubspec) | Disk+memory image cache on list avatars | Already dependency; wraps `flutter_cache_manager` [CITED: pub.dev/documentation/cached_network_image/latest/] |
| `sentry_flutter` | `^9.24.0` (pubspec) | Cold-start transactions, ANR | Already integrated in `sentry_options.dart` [CITED: docs.sentry.io/platforms/flutter/tracing/instrumentation/custom-instrumentation/] |
| Android R8 (AGP) | via Flutter Gradle plugin | Code shrink + obfuscation | Flutter release builds use R8; explicit `minifyEnabled`/`shrinkResources` for resource shrink [CITED: developer.android.com/topic/performance/app-optimization/enable-app-optimization] |
| Supabase PostgreSQL RPC | existing migration pattern | Multi-month spend in one call | Matches `SECURITY DEFINER` RPCs in `20260101000002_rpcs_and_rls.sql` [VERIFIED: supabase/migrations/20260101000002_rpcs_and_rls.sql:52-75] |
| GetX `Obx` | `^4.6.6` | Narrow reactive rebuilds | Project standard; repo rules forbid alternatives [VERIFIED: .cursor/rules/flutter-rules.md:24-31] |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `flutter_native_splash` | `^2.4.0` (dev) | Native splash until first frame | Already configured in pubspec; optional `preserve()` if native splash must cover deferred init gap [ASSUMED] |
| `flutter_cache_manager` | transitive | Cache config (max objects, stale period) | Tune avatar cache if memory pressure on long friend lists |
| DevTools Timeline | Flutter SDK | Pre/post bootstrap comparison | D-05 manual baseline |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Supabase RPC (D-08 locked) | Client `getSpendAnalytics` single date-range + Dart `groupBy` month | Fewer migrations but still ships all rows to client; violates locked D-08 |
| `SliverChildListDelegate` | Flattened `SliverChildBuilderDelegate` | ListDelegate eager — builder lazy; **recommend flattened builder** (D-15) |
| `deferFirstFrame` | Splash-gated parallel init (D-02) | User chose custom `SplitrSplashScreen` hook, not native defer API [CITED: api.flutter.dev/flutter/widgets/WidgetsBinding/deferFirstFrame.html] |

**Installation:** No new packages required for core phase work. RPC migration only.

**Version verification:** `cached_network_image` and `sentry_flutter` versions taken from `apps/mobile/pubspec.yaml` (read this session). Flutter `3.41.0` from local `flutter --version`.

## Package Legitimacy Audit

> No new external packages introduced. Phase uses existing pubspec dependencies and Android Gradle tooling.

| Package | Registry | Age | Downloads | Source Repo | Verdict | Disposition |
|---------|----------|-----|-----------|-------------|---------|-------------|
| `cached_network_image` | pub.dev | mature | high | github.com/Baseflow/flutter_cached_network_image | OK (pre-existing) | Approved — already in pubspec |
| `sentry_flutter` | pub.dev | mature | high | github.com/getsentry/sentry-dart | OK (pre-existing) | Approved |

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

*Note: `gsd-tools package-legitimacy` supports npm/pypi/crates only; pub packages verified via pubspec lock + official docs.*

## Project Constraints (from .cursor/rules/)

- **State management:** GetX only — no Riverpod/Bloc/Provider [VERIFIED: .cursor/rules/flutter-rules.md:24-31]
- **Obx scope:** Never wrap entire `Scaffold`; one reactive scope per leaf where possible [VERIFIED: .cursor/rules/getx.md:276-277, 487]
- **DI:** Controllers via Bindings; avoid new inline `Get.put` in widgets [VERIFIED: .cursor/rules/getx.md:104-137]
- **Architecture:** Layer-by-type under `lib/` — no feature-clean-arch folders [VERIFIED: .cursor/rules/flutter-rules.md:53-70]
- **Controllers:** No direct `Supabase.instance` or `AppDatabase` in controllers — use repositories/services [VERIFIED: .cursor/rules/getx.md:268-274]
- **Code citations:** Normal grammar in commits/PRs/code (caveman rule boundary) [VERIFIED: .cursor/rules/caveman.mdc:20]

## Architecture Patterns

### System Architecture Diagram

```
Cold start
──────────
main()
  ├─ dotenv
  ├─ SentryFlutter.init (blocking, D-04)
  ├─ Supabase.initialize + AppDatabase() (D-01)
  ├─ runApp → SplitrSplashScreen
  └─ start Sentry transaction: app.cold_start

SplitrSplashScreen (parallel)
  ├─ SplitrStrokeWordmark anim (~1804ms)
  └─ AppBootstrap.deferredInit()
        ├─ SyncService.startListening
        ├─ ReminderService + PushNotificationService
        ├─ DeepLinkService.initialize (drain URI queue, D-03)
        ├─ ShareIntentService.initialize
        ├─ SharedPreferences + biometric flag
        └─ Get.put deferred singletons

Gate: anim.done AND deferredInit.done
  ├─ Sentry.finish timeToFirstFrame
  ├─ deepLinkService.markNavigationReady()
  └─ navigate → home | login | onboarding | biometric

Home / lists
────────────
Controller fetch → sections flat index
  └─ CustomScrollView
        └─ SliverChildBuilderDelegate(childCount: N)

Insights
────────
SpendingIntelligenceService
  └─ single RPC get_monthly_spend_trends(months)
        └─ map to existing trend/briefing shapes

Release / background
────────────────────
flutter build appbundle (R8 + shrinkResources)
SyncService.syncPendingItems → chunks of K, yield between
RealtimeService → subscribe active group only; filtered channels
```

### Recommended Project Structure

```
apps/mobile/lib/
├── bootstrap/
│   └── app_bootstrap.dart          # critical vs deferred init (split from main.dart)
├── Screen/SplashScreen/
│   └── splitr_splash_screen.dart   # await deferred + anim gate
├── Screen/HomeScreen/
│   └── all_transactions_screen.dart # SliverChildBuilderDelegate
├── Screen/GroupScreen/
│   └── transaction_tab.dart        # primary ListView.builder
├── Widgets/
│   ├── transaction_tile.dart       # currencySymbol param, no Obx
│   └── user_avatar.dart            # CachedNetworkImage
├── Services/
│   ├── spending_intelligence_service.dart  # RPC client
│   ├── sync_service.dart           # chunked queue
│   └── realtime_service.dart       # scoped filters
└── Utils/
    └── sectioned_list_index.dart   # flat index ↔ section/row

supabase/migrations/
└── YYYYMMDD_get_monthly_spend_trends.sql

apps/mobile/android/app/
├── build.gradle                    # minifyEnabled + shrinkResources
└── proguard-rules.pro              # Razorpay + Sentry keeps
```

### Pattern 1: Splash-gated parallel deferred init

**What:** Move non-critical awaits out of `_bootstrapServices()` into `AppBootstrap.runDeferred()` started from splash `initState`. Navigation waits for both animation complete and deferred future.

**When to use:** D-01/D-02 — every cold start.

**Example:**

```dart
// Source: CONTEXT D-02 + existing SplitrStrokeWordmark hook
class SplitrSplashScreenState {
  Future<void>? _deferredInit;
  bool _animDone = false;
  bool _initDone = false;

  @override
  void initState() {
    super.initState();
    _deferredInit = AppBootstrap.runDeferred().whenComplete(() {
      _initDone = true;
      _maybeNavigate();
    });
  }

  void _onAnimationComplete() {
    _animDone = true;
    _maybeNavigate();
  }

  void _maybeNavigate() {
    if (!_animDone || !_initDone || _navigated) return;
    _navigated = true;
    SentryColdStartMetrics.finishTimeToFirstFrame();
    deepLinkService.markNavigationReady();
    Get.off(() => _resolveInitialScreen(), transition: Transition.fade);
  }
}
```

### Pattern 2: Flattened sectioned list index (recommended D-15)

**What:** When `sections` changes, build `List<SectionedListEntry>` (header | row). `SliverChildBuilderDelegate` uses `childCount: entries.length`.

**When to use:** `all_transactions_screen` and any sectioned transaction list.

**Why over pure index math:** Variable section sizes + `loadOlder` append make index→section mapping error-prone; flatten once per data change is O(n) but only on fetch, not per frame.

**Example:**

```dart
// Source: api.flutter.dev SliverChildBuilderDelegate
SliverList(
  delegate: SliverChildBuilderDelegate(
    (context, index) {
      final entry = entries[index];
      return switch (entry) {
        SectionedHeader(:final title) => TransactionSectionHeader(title: title),
        SectionedRow(:final txn) => TransactionTile(
            txn: txn,
            currencySymbol: currencySymbol,
          ),
      };
    },
    childCount: entries.length,
  ),
)
```

### Pattern 3: Surgical Obx split (D-07, D-11)

**What:** Scaffold/AppBar static; wrap only loading indicator, filter badge, FAB visibility, and per-field amounts.

**When to use:** `home_screen.dart`, `friends_screen.dart`, `transaction_tab.dart` outer `Obx`.

**Example:**

```dart
// Parent passes symbol once
final symbol = Get.find<CurrencyController>().symbol;
// In list builder — no Obx in TransactionTile
TransactionTile(txn: txn, currencySymbol: symbol)
```

### Pattern 4: Deep link / share intent queue (D-03)

**What:** Extend existing `_pendingNavigation` / `_runWhenNavigationReady` to buffer inbound URIs/intents before `DeepLinkService.initialize()` completes during splash.

**When to use:** Cold-start invite links.

**Existing hook:** `DeepLinkService._runWhenNavigationReady` queues callbacks until `markNavigationReady()` [VERIFIED: apps/mobile/lib/Services/deep_link_service.dart:155-161]

### Pattern 5: Multi-month spend RPC (D-08)

**What:** PostgreSQL function aggregates personal debits + group shares by `date_trunc('month', ...)` for `p_months` lookback; returns JSON array matching client trend shape.

**When to use:** `getSpendingTrend`, `getSpendingTrendEndingAt`, briefing paths that loop months.

**Server shape (sketch):**

```sql
-- Source: existing RPC style 20260101000002_rpcs_and_rls.sql
CREATE OR REPLACE FUNCTION public.get_monthly_spend_trends(
  p_months int DEFAULT 6,
  p_currency text DEFAULT 'INR'
) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public AS $$
-- auth.uid() guard; aggregate personal_transaction + group_transaction
-- exclude settlements/income per recap rules
$$;
```

Client: single `supabase.rpc('get_monthly_spend_trends', params)` in `TransactionService`, consumed by `SpendingIntelligenceService`.

### Pattern 6: Sentry cold-start transactions (D-05)

**What:** After `SentryFlutter.init`, start `app.cold_start` transaction (`bindToScope: true`). Finish `timeToFirstFrame` span at splash navigation gate. Finish `timeToHome` when `BottomNavigationController` first frame or primary tab visible.

**Example:**

```dart
// Source: docs.sentry.io/platforms/flutter/tracing/instrumentation/custom-instrumentation/
final transaction = Sentry.startTransaction(
  'app.cold_start',
  'app.startup',
  bindToScope: true,
);
// child span: time_to_first_frame → finish at splash gate
// child span: time_to_home → finish in BottomNavigationController initState post-frame
await transaction.finish();
```

### Pattern 7: Sync queue chunking (PERF-05)

**What:** In `syncPendingItems`, process `syncChunkSize` items (recommend **10**), then `await Future<void>.delayed(Duration.zero)` to yield UI isolate; set status `syncing` once per batch.

### Pattern 8: Realtime scoping (PERF-05)

**What:** Keep single active group channel via `GroupScreenController.subscribeToGroupRealtime`. Fix `wishlist_upvotes` listener to filter by `group_id` (currently table-wide) [VERIFIED: apps/mobile/lib/Services/realtime_service.dart:76-81]. `subscribeToFriends` is unused — do not auto-subscribe at bootstrap.

### Anti-Patterns to Avoid

- **`SliverChildListDelegate` for long lists:** Builds all children eagerly [VERIFIED: all_transactions_screen.dart:192]
- **`shrinkWrap: true` ListView inside `SingleChildScrollView`:** Forces full layout of all rows [VERIFIED: transaction_tab.dart:203-261]
- **Per-tile `Obx` for app-wide currency:** N subscriptions for N rows [VERIFIED: transaction_tile.dart:171-172]
- **Awaiting push/deeplink before `runApp`:** Blocks first frame unnecessarily [VERIFIED: main.dart:98-156]
- **Preemptive `RepaintBoundary`:** D-12 forbids until post-fix profiling shows need

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Image disk cache | Custom `HttpClient` + file IO | `cached_network_image` | Cache eviction, resize, error widgets |
| Sectioned list virtualization | Custom scroll physics | `SliverChildBuilderDelegate` | Framework maintains viewport window |
| Multi-month SQL aggregation | Sequential client loops | Supabase RPC | 6 months × 2 queries = 12+ round trips today |
| APK shrinking | Manual dex stripping | R8 `minifyEnabled` + `shrinkResources` | AGP-integrated dead code + resource removal |
| Cold-start timing | `DateTime.now()` logs only | Sentry transactions + DevTools | D-05 requires both |

**Key insight:** Perf wins here are mostly **defer work**, **lazy-build UI**, and **batch IO** — not new Dart isolates or custom render objects.

## D-14 Pagination vs memory-cap (researcher recommendation)

| Screen | Recommendation | Rationale |
|--------|----------------|-----------|
| `all_transactions_screen` | **Keep `loadOlder`** + virtualize | `_loadedSince` defaults to 365 days [VERIFIED: app_motion.dart:58 `allTransactionsLoadedSince = Duration(days: 365)`]; virtualization fixes jank without new server API |
| `transaction_tab` | **No pagination initially** — virtualize primary scroll | Group txns typically smaller set; fix scroll structure first |
| `friends_screen` | **In-memory lists OK** + `AutomaticKeepAliveClientMixin` (D-13) | Friend count bounded; tab switch jank from rebuild/scroll loss is higher risk |

## D-15 Sectioned list prototype verdict

**Ship flattened `SectionedListEntry` list + `SliverChildBuilderDelegate`** over dynamic index→section binary search. Same lazy build benefit, less bug surface when filters/`loadOlder` mutate sections. Spike task can be timeboxed 1–2h; if flatten overhead measurable on 5k rows, revisit index math.

## Common Pitfalls

### Pitfall 1: Deferred init exceeds splash duration

**What goes wrong:** Push/FCM/deeplink init not done before navigation; invite deep link races home route.

**Why it happens:** `AppMotion.splashFluid` is ~1.8s; FCM token fetch can exceed on slow networks.

**How to avoid:** `Future.wait` with `timeout` logging; extend gate with minimum splash OR hold navigation until deeplink queue drained (D-03). Show static wordmark if anim finishes first.

**Warning signs:** Sentry `time_to_home` OK but missed invite routes in QA.

### Pitfall 2: R8 strips Razorpay / Firebase / Sentry

**What goes wrong:** Release-only payment or crash reporting failures.

**Why it happens:** `minifyEnabled true` without plugin keep rules.

**How to avoid:** Add Razorpay Flutter ProGuard rules from vendor docs; existing Sentry keeps in `proguard-rules.pro` [VERIFIED: proguard-rules.pro:11-16]; test `flutter build appbundle --release` + smoke paywall.

### Pitfall 3: RPC currency conversion drift

**What goes wrong:** Batch RPC totals disagree with per-month `getMonthlySpendAnalytics`.

**Why it happens:** Client applies `CurrencyService.getRates` per call today [VERIFIED: transaction_service.dart:606-610]; RPC must use same INR base + `exchange_rate_to_inr` logic.

**How to avoid:** Share filter functions (`countsAsRecapExpense`) in SQL or document parity tests in `spending_intelligence_service_test.dart`.

### Pitfall 4: Chunked sync re-entrancy

**What goes wrong:** Connectivity flap triggers overlapping `syncPendingItems`.

**Why it happens:** `_isSyncing` guard exists but chunk loop may starve UI if batch huge.

**How to avoid:** Keep `_isSyncing` for whole batch session; chunk inner loop only; cap items per invocation.

### Pitfall 5: `CachedNetworkImage` on DiceBear SVG URLs

**What goes wrong:** `UserAvatar` uses `SvgPicture.network` for identicons — different code path than raster uploads.

**How to avoid:** PERF-03 targets **custom uploaded** `NetworkImage` [VERIFIED: user_avatar.dart:68-69] and `Image.network` in `shared.dart` [VERIFIED: shared.dart:408]; keep SVG path or add SVG cache separately.

## Code Examples

### Android release shrink (Groovy)

```groovy
// Source: developer.android.com/topic/performance/app-optimization/enable-app-optimization
buildTypes {
    release {
        signingConfig = releaseKeystoreReady ? signingConfigs.release : signingConfigs.debug
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

### Cached avatar

```dart
// Source: pub.dev/documentation/cached_network_image/latest/
CachedNetworkImage(
  imageUrl: imageUrl!,
  fit: BoxFit.cover,
  memCacheWidth: (radius * 2 * devicePixelRatio).round(),
  placeholder: (_, __) => _buildInitialsFallback(),
  errorWidget: (_, __, ___) => _buildInitialsFallback(),
)
```

### transaction_tab primary scroll

```dart
// Replace SingleChildScrollView + shrinkWrap ListView
RefreshIndicator(
  onRefresh: _controller.refresh,
  child: ListView.separated(
    physics: const AlwaysScrollableScrollPhysics(),
    itemCount: cnsGrpTrns.length,
    itemBuilder: (context, index) => _buildRow(cnsGrpTrns[index], index),
    separatorBuilder: (_, __) => Divider(...),
  ),
)
```

### Sync chunk loop

```dart
static const _syncChunkSize = 10;

for (var i = 0; i < pendingItems.length; i++) {
  await _processSyncItem(pendingItems[i]);
  await _db.markSynced(pendingItems[i].id);
  if ((i + 1) % _syncChunkSize == 0) {
    await Future<void>.delayed(Duration.zero);
  }
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Serial `main()` bootstrap | Splash-gated parallel deferred init | Phase 6 (planned) | Faster first frame |
| `SliverChildListDelegate` | `SliverChildBuilderDelegate` | Phase 6 (planned) | Lazy list build |
| N× `getMonthlySpendAnalytics` | Single RPC `get_monthly_spend_trends` | Phase 6 (planned) | Fewer network round trips |
| `NetworkImage` in avatars | `cached_network_image` | Phase 6 (planned) | Less decode jank on scroll |
| Release without explicit shrink | `minifyEnabled` + `shrinkResources` | Phase 6 (planned) | Smaller APK |

**Deprecated/outdated:**
- Per-tile `Obx` for global currency — replace with parent-passed symbol (D-11)

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Splash animation (~1804ms) sufficient for typical deferred init | Pattern 1 | Invite/push races; need longer gate |
| A2 | Flattened section list preferred over index math (D-15) | D-15 verdict | Spike may favor alternate — planner should timebox |
| A3 | `subscribeToFriends` intentionally unused | Pattern 8 | If product expects live friend requests globally, need scoped subscribe on Friends tab only |
| A4 | Razorpay ProGuard rules from vendor docs suffice | Pitfall 2 | Release payment regression |
| A5 | CI APK size tracking added to `deploy_android.yml` or `flutter_ci.yml` | PERF-04 | No regression visibility |

## Open Questions

1. **Visual effects budget (GradientMeshBackground / GlassCard)**
   - What we know: Used on home, insights, recap surfaces [grep: 20+ files]
   - What's unclear: Acceptable quality reduction on low-RAM devices
   - Recommendation: Gate blur/mesh with `MediaQuery.disableAnimations` or `androidInfo.isLowRamDevice` in 06-03 plan stub

2. **APK size baseline**
   - What we know: CI builds appbundle but does not log size
   - What's unclear: Current MB baseline for before/after
   - Recommendation: Wave 0 step — record `apkanalyzer` output in plan verification

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | build, test, DevTools | ✓ | 3.41.0 stable | — |
| Android SDK / Gradle | release APK, R8 | ✓ (via project) | compileSdk 36 | — |
| Supabase CLI / migration apply | RPC D-08 | ✓ (repo has migrations) | — | Manual SQL in dashboard |
| Mid-range Android device | scroll/TTI validation | ✗ (not in CI) | — | Manual QA + profile mode |
| Sentry project | D-05 transactions | ✓ (configured) | sentry_flutter ^9.24.0 | DevTools-only baseline |

**Missing dependencies with no fallback:**
- Physical mid-range device for 60fps scroll sign-off (manual gate in verification)

**Missing dependencies with fallback:**
- None blocking implementation

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | `flutter_test` (SDK 3.41.0) |
| Config file | none — `analysis_options.yaml` lints only |
| Quick run command | `cd apps/mobile && flutter test` |
| Full suite command | `cd apps/mobile && flutter test` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| PERF-01 | Deferred bootstrap completes before navigation gate | unit | `flutter test test/app_bootstrap_test.dart -x` | ❌ Wave 0 |
| PERF-01 | Deep link queue drains after init | unit | `flutter test test/deep_link_service_test.dart` | ✅ (extend) |
| PERF-02 | Section index flattening | unit | `flutter test test/sectioned_list_index_test.dart -x` | ❌ Wave 0 |
| PERF-02 | Spending trend uses RPC not N loops | unit | `flutter test test/spending_intelligence_service_test.dart -x` | ✅ (extend) |
| PERF-02 | TransactionTile no Obx when symbol passed | widget | `flutter test test/widgets/transaction_tile_test.dart -x` | ❌ Wave 0 |
| PERF-03 | UserAvatar uses cache provider | widget | `flutter test test/widgets/user_avatar_test.dart -x` | ❌ Wave 0 |
| PERF-04 | Release Gradle has minify flags | static | grep `minifyEnabled` android/app/build.gradle | ❌ (add then verify) |
| PERF-05 | Sync processes max chunk size | unit | `flutter test test/sync_service_test.dart -x` | ✅ (extend) |
| PERF-05 | Realtime wishlist filter present | unit | `flutter test test/realtime_service_test.dart -x` | ❌ Wave 0 |

### Sampling Rate

- **Per task commit:** `cd apps/mobile && flutter test`
- **Per wave merge:** `cd apps/mobile && flutter test` + `flutter analyze`
- **Phase gate:** DevTools cold-start timeline doc + release Sentry transaction sample + manual scroll on device

### Wave 0 Gaps

- [ ] `test/app_bootstrap_test.dart` — deferred/critical split
- [ ] `test/sectioned_list_index_test.dart` — flat entry builder
- [ ] `test/realtime_service_test.dart` — channel filter contracts
- [ ] Extend `test/deep_link_service_test.dart` — URI queue before init
- [ ] Extend `test/sync_service_test.dart` — chunk boundary
- [ ] CI step: log AAB/APK size artifact

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|------------------|
| V2 Authentication | no | — |
| V3 Session Management | no | — |
| V4 Access Control | yes | RPC `auth.uid()` guard + `SECURITY DEFINER` like existing RPCs |
| V5 Input Validation | yes | Bound `p_months` (e.g. 1–24) in RPC |
| V6 Cryptography | no | — |

### Known Threat Patterns for stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| RPC returns other user's spend | Information disclosure | `WHERE user_id = auth.uid()` inside SECURITY DEFINER function |
| Over-broad realtime channel | Information disclosure | Postgres filter on `group_id` for all tables in channel |
| ProGuard breaking security SDK | Tampering | Vendor keep rules; release smoke test |

## Sources

### Primary (HIGH confidence)

- `apps/mobile/lib/main.dart` — current serial bootstrap (read this session)
- `apps/mobile/lib/Screen/SplashScreen/splitr_splash_screen.dart` — navigation gate hook
- `apps/mobile/lib/Constants/app_motion.dart:21` — `splashFluid = Duration(milliseconds: 1804)`
- `apps/mobile/lib/Services/spending_intelligence_service.dart:46-58` — month loop
- [SliverChildBuilderDelegate](https://api.flutter.dev/flutter/widgets/SliverChildBuilderDelegate-class.html) — lazy sliver children
- [Sentry custom instrumentation](https://docs.sentry.io/platforms/flutter/performance/instrumentation/custom-instrumentation/) — transactions/spans
- [Android R8 enable optimization](https://developer.android.com/topic/performance/app-optimization/enable-app-optimization) — minify + shrinkResources

### Secondary (MEDIUM confidence)

- [cached_network_image pub docs](https://pub.dev/documentation/cached_network_image/latest/)
- [Flutter Android deployment](https://docs.flutter.dev/deployment/android) — R8 in release builds
- `.cursor/rules/getx.md` — Obx scope rules
- `.planning/codebase/CONCERNS.md` — spending N+1, sync queue, realtime scope

### Tertiary (LOW confidence)

- GetX Obx narrow-scope community patterns (websearch; aligns with repo rules)

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — existing deps + official Flutter/Android/Sentry docs
- Architecture: HIGH — codebase files read and cited with line-verified values
- Pitfalls: MEDIUM — R8 plugin interactions need release smoke on device

**Research date:** 2026-08-07
**Valid until:** 2026-09-07 (30 days — stable Flutter/Android tooling)
