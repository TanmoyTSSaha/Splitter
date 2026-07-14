#### Plan and add the following features. Once the implementation is completed mark the feature implementation status as done -



1. Compare and plan between Stripe, Razorpay, Lemonsqueezy, dudu payments. check setup easiness, production cost and other things and implement the most efficient one.

	- **Comparison:** Stripe — best global cards/subscriptions, higher fees, more setup. Razorpay — best for India (UPI, INR), low domestic fees, Flutter SDK. Lemon Squeezy — SaaS/digital goods, merchant of record, weak for P2P settle-up. Dodo Payments — limited India coverage vs Razorpay.

	- **Decision:** Keep **Google/Apple IAP** for in-app Pro (already implemented). Select **Razorpay** for future INR settlement rails / payment links.

	- Implementation: **Done** (`RazorpayPaymentService` + manual settle checkout; set `razorpayKeyId` in `git_ignore.dart`; IAP retained for Pro).



2. Login, registration and onboarding screens still following old dark theme. Match it with the UI.

	- Implementation: **Done** (light Neopop theme — `colorScheme.surface`, `groupOnSurface`, `neopopAccent` buttons).



3. Bug inside group tab, it's showing back button inside appbar. Home, group lending and profile tabs should not show back arrow button.

	- Implementation: **Done** (`Get.offAll` clears login route; `automaticallyImplyLeading: false` on group/lending app bars; `PopScope(canPop: false)` on bottom nav).



4. Bug after loggin in once I press back it takes me back to the login screen and the credentials are still there.

	- Implementation: **Done** (login success uses `Get.offAll` to `BottomNavigationController`; bottom nav blocks system back).



5. I have integrated 3rd party firebase auth inside supabase, check if we can set google login using it. Or else we need to use direct firebase or GCP. You can use supabase and firebase MCP.

	- **Finding:** Supabase Google via `signInWithOAuth` works with the native Google provider. Firebase-as-third-party in Supabase requires `signInWithIdToken` using a Firebase ID token from `firebase_auth` — not the current OAuth redirect flow.

	- Implementation: **Done** (`google_sign_in` + `signInWithIdToken` when `googleWebClientId` is set; OAuth deep-link callback + `Get.offAll` fallback).



6. All the AppBars are not transparent, so inside home screen the appbar is distinguishable, if it was transparent with 0 shadow it would not be distinguishable.

	- Implementation: **Done** (global `appBarTheme` transparent + home/group/lending root app bars).



7. From inside the app the notification bar of the mobile is not visible, the notification bar should be black color as normal.

	- Implementation: **Done** (`SystemChrome` edge-to-edge + dark status bar icons on light background in `main.dart`).

8. fix the error - lib/Screen/GroupScreen/manual_settle_up_screen.dart:228:15: Error: This expression has type 'void' and can't be used.

	- Implementation: **Done** (`_handleSettleUp` returns `Future<void>` so Razorpay `onSuccess` can await it).



9. **Bug:** `feature_requests` client schema does not match Supabase migration — list/sort/vote will fail on fresh DB.

	- **Verified:** Migration `20260101000001_initial_features.sql` defines column `vote_count` (no `votes`, no `status`). `RequestFeatureScreen` reads/writes `votes`, sorts by `votes`, and `FeatureRequestModel` expects `status`.

	- Implementation: **Done** (client uses `vote_count`; DB trigger keeps count in sync; migration `20260709100000_feature_request_vote_count.sql`).



10. **Unfinished:** `MonthlyRecapScreen` built but unreachable; slide trend data is fake.

	- **Verified:** No `Get.to(MonthlyRecapScreen)` anywhere in `lib/`. `GamificationService.generateRecap` loads real stats, but UI still hardcodes `+12% vs Sep` / `+12%` in `monthly_recap_screen.dart` (~lines 1967, 2416).

	- Implementation: **Done** (Profile → Monthly Recap; real MoM trend via `_trendVsLastMonthLabel()`).



11. **Preproduction:** Android package id is still `com.example.splitr`.

	- **Verified:** `android/app/build.gradle` `applicationId` and `google-services.json` both use `com.example.splitr`. Play Console will reject example IDs; Firebase/OAuth redirect configs must match production id.

	- Implementation: **Done** (`money.splitr.app` on Android/iOS/macOS/Linux; update Firebase Console + download fresh `google-services.json`).



12. **Security:** API keys and DB password live in tracked `lib/git_ignore.dart`.

	- **Verified:** File contains Supabase service password, Gemini key, Razorpay secret (test), etc. File is modified in git — risk of leak via commit/history.

	- Implementation: **Done** (`lib/config/app_secrets.dart` + `.env` / `--dart-define-from-file=env.json`; `env.example.json` committed). **Rotate keys** that were ever in `git_ignore.dart` history.



13. **Offline gap:** Personal expense add does not use offline queue.

	- **Verified:** `AddPersonalTransactionScreen` writes via `SupabaseDatabase` directly. `PersonalTransactionRepository` + Drift cache exist and `HomeController` calls `refreshFromServer`, but new personal tx are not enqueued in `SyncService` — fails offline (matches runtime auth/network errors in device logs).

	- Implementation: **Done** (`PersonalTransactionRepository.addTransaction` + sync queue; `id` column fix for Supabase schema).



14. **Missing feature (competitors + reviews):** Edit/delete personal transactions from Home / All Transactions.

	- **Verified:** No `updatePersonalTransaction` UI in `lib/Screen/HomeScreen/` or `AllTransactionsScreen`. [AboutMoney App Store reviews](https://apps.apple.com/in/app/aboutmoney/id6771859753) cite missing edit as top complaint.

	- Implementation: **Done** (long-press personal tx → `PersonalTransactionSheet` edit/delete + offline sync).



15. **Competitor gap:** Share screenshot/PDF into app to auto-add expense (no bank link).

	- **Verified:** No `receive_sharing_intent` / share-handler in `pubspec.yaml`. Receipt scan exists (`ReceiptScannerScreen` + `image_picker`) but only inside group flow — not system share target like [AboutMoney](https://apps.apple.com/in/app/aboutmoney/id6771859753).

	- Implementation: **Done** (`ShareIntentService` + Android `SEND` manifest + receipt prefill on `AddPersonalTransactionScreen`).



16. **Competitor gap:** SMS / UPI notification expense drafts (India).

	- **Verified:** No SMS permission or parser in codebase. [Splitkaro](https://play.google.com/store/apps/details?id=com.bsquare.splitkaro) and [Mojek](https://play.google.com/store/apps/details?id=money.mojek.finance_manager_tracker) market automatic UPI/bank tracking.

	- Implementation: **Done** (`UpiSmsParser` + `SmsExpenseDraftsScreen` — paste SMS, no device SMS permission; Play-policy safe).



17. **Competitor gap:** Splitwise balance import.

	- **Verified:** No import path in `lib/`. [Splitkaro](https://play.google.com/store/apps/details?id=com.bsquare.splitkaro) and [Hisaab](https://play.google.com/store/apps/details?id=com.krishanblr.hisaab) advertise Splitwise migration — lowers switching cost.

	- Implementation: **Done** (`SplitwiseImportScreen` — CSV → group RPC + expense import).



18. **Placeholder:** Donate menu opens `FeatureComingUpNext`.

	- **Verified:** `ProfileScreen` → Donate → stub screen ("coming up next").

	- Implementation: **Done** (`DonateScreen` — Razorpay preset amounts).



19. **Auth/profile gaps** (still missing per `ai-docs/product-description.md` §4.5).

	- **Verified:** Password change done; username + photo missing.

	- Implementation: **Done** (username edit + gallery photo upload to `avatars` bucket; migration `20260709130000_avatars_storage.sql`).



20. **Premium marketing vs product:** "UPI Quick Settle links" on paywall — no dedicated implementation.

	- **Verified:** `premium_plan_screen.dart` lists feature; settle flow is Razorpay checkout on `ManualSettleUpScreen` only — no generated UPI deep link / QR per debt, no Pro gate on that path.

	- Implementation: **Done** (`UpiSettleService` + Pro-gated button on `ManualSettleUpScreen`).



21. **Orphan screen:** `PersonalTransactionScreen` is mock UI, not wired.

	- **Verified:** Hardcoded strings (`"Flight Confirmation"`, etc.); no navigation from app shell.

	- Implementation: **Done** (orphan mock screen removed).



22. **Preproduction:** No CI/CD pipeline.

	- **Verified:** No `.github/workflows/` in repo. `flutter test` passes **29/29** locally; `flutter analyze` reports warnings/infos only (no compile errors in current tree).

	- Implementation: **Done** (`.github/workflows/flutter_ci.yml`).



23. **Competitor gap (high user love):** Shareable web settlement / monthly summary link.

	- **Verified:** Group export is file share (`ExportService` CSV/PDF) only. [Hisaab](https://play.google.com/store/apps/details?id=com.krishanblr.hisaab) shares month hisaab as web link readable without app install.

	- Implementation: **Done** (`PublicShareLinkService` + `web/share/index.html` reader; Monthly Recap “Share web link”; deploy HTML with Supabase URL/anon key).



24. **Competitor gap:** Personal budgets with daily allowance + overspend alerts.

	- **Verified:** `personal_budgets` table existed; no UI.

	- Implementation: **Done** (`PersonalBudgetsScreen` — set limits, progress bars, near/over alerts from monthly spend).



25. **Competitor gap:** Subscription / recurring bill auto-detection.

	- **Verified:** `ReminderService` + group recurring exists partially; no personal subscription tracker like Mojek/Splitkaro bill reminders.

	- Implementation: **Done** (`detectRecurringMerchants` + Insights “Likely Subscriptions” section).



26. **Test coverage gap:** Critical paths untested.

	- **Verified:** Tests cover insights gate, loan schedule, spending intelligence, transaction list helpers, theme widget only — no tests for split math, settle-up, sync queue, feature requests, auth.

	- Implementation: **Done** (119+ tests: split math, settle-up balance, sync queue/service, SMS parser, mock HTTP harness; live Supabase integration tests out of scope).



27. Login UI text fields inconsistent with light/dark theme components.

	- Implementation: **Done** (`PrimaryTextFormField` uses light Neopop surface fill, rounded borders, `groupOnSurface` text).



28. **Preproduction:** Supabase auth redirect still uses quickstart boilerplate scheme.

	- **Verified:** `auth_service.dart` and `deep_link_service.dart` use `io.supabase.flutterquickstart://login-callback/` — not tied to `com.example.splitr` or a production bundle. Google OAuth / email confirm / password-reset links depend on this matching Android intent filters + Supabase dashboard redirect allowlist.

	- Implementation: **Done** (`splitr://login-callback/` in auth + manifest; legacy quickstart retained).



29. **Auth gap:** Password reset has no “set new password” screen after email link.

	- **Verified:** `resetPasswordForEmail` sends link; `DeepLinkService` handles `login-callback` by calling `getSessionFromUrl` then `Get.offAll` to main app. No screen to enter a new password (`recovery` / `updateUser` flow absent in `lib/`).

	- Implementation: **Done** (`ResetPasswordScreen` on `type=recovery` deep link).



30. **UX bug:** Home network errors are silent.

	- **Verified:** `HomeController.fetchError` is set on catch (`'Could not refresh home data.'`) but `HomeScreen` never reads/displays it — user sees stale or empty data with no banner (unlike `GroupScreenController.groupsError` and `LendingDashboard._fetchError`).

	- Implementation: **Done** (home error banner with retry).



31. **Competitor gap:** No dark mode.

	- **Verified:** `GetMaterialApp` sets `theme: AppThemes.light` only — no `darkTheme` or `ThemeMode` toggle. [Splitkaro reviews](https://play.google.com/store/apps/details?id=com.bsquare.splitkaro) and [Splitser](https://play.google.com/store/apps/details?id=nl.wiebetaaltwat.webapp) ship dark mode.

	- Implementation: **Done** (`ThemeController` + Profile → Appearance).



32. **UX gap:** Login/register forms skip field validation.

	- **Verified:** `LoginScreen` and `RegisterScreen` pass `validator: null` on all `PrimaryTextFormField`s — empty/invalid email and weak passwords can be submitted until Supabase rejects server-side.

	- Implementation: **Done** (`AuthValidators` on login/register forms).



33. **Missing feature:** Personal income / credit entries not supported.

	- **Verified:** `personal_transaction` table has no `is_credit` column (`initial_schema.sql`). `AddPersonalTransactionScreen` title is "Add Personal Expense"; payment methods only `Online` / `Cash`. [Splitkaro reviews](https://play.google.com/store/apps/details?id=com.bsquare.splitkaro) request income tracking.

	- Implementation: **Done** (`is_credit` on add + edit; expense/income toggle on add screen).



34. **Competitor gap:** Granular payment types (UPI, cards, Fastag).

	- **Verified:** `kPersonalPaymentMethods` const (Cash, Online, UPI, Debit/Credit card, Fastag, Wallet); add/edit pickers + filter chips in All Transactions; client-side filter on unified personal txns.

	- Implementation: **Done**



35. **Competitor gap:** Archive / hide inactive groups.

	- **Verified:** `groups.is_archived` on Supabase; `GroupModel.isArchived`, `GroupRepository.fetchArchivedGroupIds` / `setGroupArchived`, group list filter + Show archived toggle, archive action in group detail sheet.

	- Implementation: **Done**



36. **UX bug:** Feature requests fail silently on load error.

	- **Verified:** `RequestFeatureScreen._load()` `catch (_)` only sets `_loading = false` — user sees empty "Community Wishlist" with no error/retry if Supabase query fails (e.g. migration not applied).

	- Implementation: **Done** (error state + retry in `RequestFeatureScreen`).



37. **Premium inconsistency:** Group analytics not gated despite paywall copy.

	- **Verified:** `premium_plan_screen.dart` lists "Advanced analytics" as Pro-only (`false` on free plan). `AnalyticsTab` in `group_detailed_screen.dart` renders full charts with no `requirePremium` / `InsightsProGate` (unlike export + receipt scan which call `requirePremium`).

	- Implementation: **Done** (`InsightsProGate` on group `AnalyticsTab`).



38. **Preproduction:** Release builds signed with debug keystore.

	- **Verified:** `android/app/build.gradle` `release { signingConfig = signingConfigs.debug }` with TODO comment — Play Store upload requires release signing config.

	- Implementation: **Done** (`android/key.properties.example` + conditional release signing in `build.gradle`).



39. **Missing feature:** Cannot leave group or remove members.

	- **Verified:** `MembersTab` is read-only grid (avatar + name). No `removeMember` / `leaveGroup` in `lib/`. Splitwise/Tricount/Splid all support leaving or admin removal.

	- Implementation: **Done** (`leave_group` RPC + Members tab "Leave group").



40. **Branding inconsistency:** Invite deep links vs auth redirects use different schemes.

	- **Verified:** `AppBranding.appScheme` = `splitr` used by `InviteLinkService` (`splitr://join/...`). Supabase auth still redirects to `io.supabase.flutterquickstart://login-callback/` (`auth_service.dart`, `AndroidManifest.xml`). Users get mixed URL schemes in production.

	- Implementation: **Done** (unified `splitr://login-callback/` for auth; invites remain `splitr://join`).



41. **Bug:** Edit personal transaction drops income flag.

	- **Verified:** `PersonalTransactionSheet._save` called `updateTransaction` without `isCredit`.

	- Implementation: **Done** (`isCredit: _isIncome` on update).



42. **Bug:** Drift personal-tx cache missing `is_credit`.

	- **Verified:** `LocalPersonalTransactions` lacked `is_credit`; refresh omitted field.

	- Implementation: **Done** (Drift schema v3 + repository read/write `isCredit`).



43. **Bug:** Share-intent receipt parse result discarded.

	- **Verified:** `ShareIntentService` ignored `ReceiptData`; opened empty add screen.

	- Implementation: **Done** (`receiptPrefill` on `AddPersonalTransactionScreen` — amount/merchant/date).



44. **Offline gap:** Group expense + settlement still network-only.

	- **Verified:** `TransactionRepository.addGroupExpense` calls `_groupService.addGroupExpense` directly — no `SyncService.enqueue`. `SettleUpController.recordSettlement` uses `SupabaseDatabase().recordSettlement` directly. Personal tx queued; group writes fail offline.

	- Implementation: **Done** (`TransactionRepository` queues group expense + settlement via Drift + `SyncService`; `GroupExpenseBuilder` + `GroupBalanceMutator`).



45. **Dead code:** `FeatureComingUpNext` screen orphaned.

	- **Verified:** No navigation references after Donate → `DonateScreen`.

	- Implementation: **Done** (file deleted).



46. **UI inconsistency:** Dark-theme screens/cards on light app shell.

	- **Verified:** Several screens still dark on light shell.

	- Implementation: **Done** (goal details, trip create, create goal, home/groups/biometric aligned to light Neopop).



47. **Gap:** Admin cannot remove another member (self-leave only).

	- **Verified:** Only self-leave existed.

	- Implementation: **Done** (`remove_group_member` RPC + creator long-press remove on `MembersTab`).



48. **Auth gap:** No `onAuthStateChange` listener.

	- **Verified:** Session only checked at cold start; remote sign-out left stale Drift cache.

	- Implementation: **Done** (`onAuthStateChange` → `unsubscribeAll` + `clearAllUserData` + `LoginScreen`).



49. **Premium inconsistency:** Pro gates exist but not on paywall list.

	- **Verified:** Gates on loans, trips, reminders, insights not listed on paywall.

	- Implementation: **Done** (premium card lists trip ledger, promissory PDF, escalated reminders, AI briefing).



50. **Still partial / open from prior items:**

	- **#15** share target — **Done** (manifest + receipt prefill).
	- **#16** SMS/UPI drafts — **Done** (paste SMS flow).
	- **#23** web share reader — **Done** (`web/share/index.html` + recap link).
	- **#24** personal budgets — **Done**.
	- **#25** subscription auto-detect — **Done**.
	- **#26** test coverage — **Done** (see #26).
	- **#19** profile photo upload + username edit — **Done** (`PersonalDetailsScreen` — `image_picker` + `uploadProfilePhoto` + editable username).



51. **UX bug:** Expense Insights spins forever on fetch fail.

	- **Verified:** `FutureBuilder` had no `hasError` branch.

	- Implementation: **Done** (error panel + Try again on lite + briefing futures).



52. **UX bug:** All Transactions cannot tell error from empty.

	- **Verified:** No `fetchError`; empty list looked like no data.

	- Implementation: **Done** (`fetchError` observable + retry when load fails with no cached rows).



53. **UX bug:** Trip timeline fails silently.

	- **Verified:** `TripTimelineTab._fetchTripData` swallowed errors.

	- Implementation: **Done** (`_loadError` + Try again).



54. **UX bug:** Groups tab error has no retry.

	- **Verified:** `_buildErrorState` was static text only.

	- Implementation: **Done** (Try again → `refreshGroups`).



55. **UX bug:** Add personal expense category load fails silent.

	- **Verified:** Offline fetch left empty picker.

	- Implementation: **Done** (`PersonalCategoryCache` SharedPreferences fallback in `getPersonalCategories` + error/retry UI on add screen).



56. **Offline gap:** Create group requires network.

	- **Verified:** Direct RPC with no offline path.

	- Implementation: **Done** (connectivity pre-check + clear offline snackbar; no queue).



57. **Premium gap:** Elite Splitr Badge on paywall — no profile UI.

	- **Verified:** Paywall promised badge; profile had no Pro indicator.

	- Implementation: **Done** (Pro crown on avatar + PRO MEMBER subtitle when subscribed).



58. **Compile error:** `ProfileScreen` missing imports.

	- **Verified:** `CurrencyController` + `NotificationsScreen` imports dropped.

	- Implementation: **Done** (imports restored).



59. **Personal budgets UI wired.**

	- **Verified:** `PersonalBudgetsScreen` exists + Profile menu entry (`personal_budgets_screen.dart`). Closes part of **#24** — verify alerts/overspend notifications still open.

	- Implementation: **Done** (local push via `PersonalBudgetAlertService` on home refresh; once-per-month dedupe).



60. **App startup is failing:** `receive_sharing_intent` Gradle `kotlin()` error.

	- **Verified:** Plugin build.gradle calls `kotlin {}` without Kotlin plugin applied. `android/build.gradle` applies `org.jetbrains.kotlin.android` in `beforeProject` + sets `compileSdk 36`. `gradlew :receive_sharing_intent:tasks` → **BUILD SUCCESSFUL**.

	- Implementation: **Done** (root `android/build.gradle` workaround).



61. **Runtime bug:** Goal details controller reset on every rebuild.

	- **Verified:** `GoalDetailsScreen.build()` always `Get.delete` + `Get.put(GoalDetailsController)` — ancestor rebuilds wipe state and re-fetch.

	- Implementation: **Done** (`GoalDetailsScreen` → `StatefulWidget`; controller in `initState`/`dispose` only).



62. **UX bug:** Edit personal tx category load fails silent (#55 gap).

	- **Verified:** `personal_transaction_sheet.dart` `_fetchCategories` catch leaves empty `_categories`; add screen has cache/retry via **#55** but edit sheet still direct Supabase + silent catch.

	- Implementation: **Done** (`PersonalCategoryCache` fallback + error/retry in `PersonalTransactionSheet`).



63. **UX bug:** Friend email search masks network errors as “No users found”.

	- **Verified:** `FriendsController.searchUsers` catch only clears `isSearching`; `add_friend_screen.dart` shows “No users found” when `searchResults.isEmpty` + query non-empty.

	- Implementation: **Done** (`FriendsController.searchError` + retry on `AddFriendScreen`).



64. **UI inconsistency:** Personal transaction add vs edit flows diverge.

	- **Verified:** Was split UI (`ChoiceChip` vs `_toggleChip`, different field order). Now shared `personal_transaction_form_fields.dart` — `PersonalTransactionTypeToggle`, `PersonalCategoryPicker`, date/payment row used by both add screen + edit sheet.

	- Implementation: **Done** (shared form field widgets; unified toggle, category chips, spacing tokens).



65. **UI/UX gap:** Donate screen immature + no custom amount.

	- **Verified:** Preset chip grid + `BorderedInputField` custom amount + single donate CTA. Minor: field inside `GlassCard` = nested borders (card + field).

	- Implementation: **Done** (`BorderedInputField` — single outer border; donate + prefix-icon fields migrated).



66. **UI inconsistency:** Legacy screens skip design tokens.

	- **Verified:** Shared `HeroAmountField` (Albra 48px borderless) wired into `loan_contract_form_screen` + `add_transaction_screen` amount. Major forms, graphs, `by_item_tab` spacing, `add_transaction_screen` spacing done. Dark-surface item inputs in `by_item_tab` kept intentional.

	- Implementation: **Done** (`HeroAmountField` + form/token passes in **#73–77**).



67. **UI inconsistency:** Text fields with mismatched inner + outer borders.

	- **Verified:** `BorderedInputField` (`bordered_input_field.dart`) — outer border only, inner `InputBorder.none`. Prefix-icon wrappers + donate custom amount migrated. Optional polish: `showBorder: false` when parent is `GlassCard`.

	- Implementation: **Done** (`BorderedInputField`; `CustomTextFormFieldWithPrefixIcon` + `CustomBigTextFormFieldWithPrefixIcon` + donate custom amount).



68. **Test gap:** Component/widget coverage incomplete.

	- **Verified:** Added `test/widgets/` suite incl. `InsightsPromoCard`, transaction sheets, core components. `test/mock_http_test.dart` + `runWithMockHttp` harness for SVG/PNG stubs; widget-level `NetworkImage` decode still flaky — needs richer HttpClient stub.

	- Implementation: **Done** (widget + unit suite; `runWithMockHttp` for network stubs).



69. **UI/UX audit (fintech baseline):** Splitr target aesthetic = Neopop light shell on `GradientMeshBackground`: transparent AppBars, `groupOnSurface` (`neopopBackground`) on white, `neopopAccent` for positive/settle CTAs, Albra display + Poppins body, `GlassCard` depth, `BorderedInputField` for forms. Competitors benchmarked: [Splitwise](https://www.splitwise.com/) — balance-first hierarchy, minimal chrome, owed/owe color split; [Splitkaro](https://play.google.com/store/apps/details?id=com.bsquare.splitkaro) — India UPI-forward, card lists, dark mode; [AboutMoney](https://apps.apple.com/in/app/aboutmoney/id6771859753) — clean expense rows, large tabular amounts; Monzo/Revolut — transparent headers, muted secondary labels, no visible AppBar band. Splitr mesh+glass is differentiated; token discipline and sub-screen polish lag behind Splitwise/AboutMoney clarity.

	- **Verified:** Repo-wide scan ongoing. Accent CTA text on yellow (`goal_details`, `create_goal`, `donate`, `request_feature`, `premium_plan`) migrated `Colors.black` → `groupOnSurface`. Remaining `Colors.black` mostly shadows/borders on light cards.

	- Implementation: **Done** (accent CTAs + card shadows use `groupOnSurface` tokens).



70. **UI inconsistency:** Sub-screen AppBars opaque — breaks seamless scroll (#6 fixed root tabs only).

	- **Verified:** `SplitrDetailAppBar` exists and is used on 30+ routes. Remaining raw `AppBar`: `monthly_recap_screen.dart` (intentional recap styling).

	- Implementation: **Done** (`request_feature_screen` migrated this pass; only recap/empty-state sub-bars differ).



71. **UI inconsistency:** Home dashboard analytics section uses raw Material greys.

	- **Verified:** `home_screen.dart` analytics toggle + cash-flow card now use `groupOnSurfaceMuted`, `groupChipTrackBg`, `groupCardFill`, `groupSurfaceBorder`, `groupChipSelectedFg`.

	- Implementation: **Done** (tokens added to `group_screen_spacing.dart`).



72. **UI inconsistency:** Profile + lending mix raw Material greys on light shell.

	- **Verified:** `profile_screen.dart` stat chips + biometric switch track + menu divider migrated to `groupCardFill` / `groupSurfaceBorder` / `groupChipTrackBg`. Pro avatar ring whites kept intentional.

	- Implementation: **Done** (placeholder avatar, loan badge muted state, progress track tokenized).



73. **UI inconsistency:** Legacy form inputs outside personal-tx flow.

	- **Verified:** Auth (`PrimaryTextFormField` → single-border), group create/add-member, add-txn (description + `HeroAmountField` amount), profile personal details + budgets all on `BorderedInputField` / shared wrappers.

	- Implementation: **Done** (app-wide form parity; `CustomTextFormFieldWithPrefixIcon` delegates to `BorderedInputField`).



74. **UI inconsistency:** Spacing tokens not app-wide.

	- **Verified:** `groupGutter`/`groupGap*` applied to `splitwise_import`, `goal_details`, `loan_contract`, `request_feature`, `premium_plan_screen`, `add_carousel_card`, `edit_currency`. `PillTabBar` track/labels tokenized.

	- Implementation: **Done** (form/profile screens; recap export slides keep `_lightBg` for screenshot layout).



75. **UI inconsistency:** `neopopSecondaryGrey` on light surfaces (dark-theme chip fill).

	- **Verified:** Zero `neopopSecondaryGrey` in `lib/Screen/`. Widget sweep: `transaction_tile` icon chip → `groupChipTrackBg`; `group_reminder_settings_sheet` segment track → `groupChipTrackBg`; `active_group_card` default avatar color → `0xFF1E1E1E`. `shared.dart` category/loader circles + `app_themes` dark fill retain token by design.

	- Implementation: **Done** (screens clean; `shared.dart` loaders + dark theme retain token by design).



76. **UI inconsistency:** Bottom nav scaffold + dark-mode parity gaps.

	- **Verified:** `bottom_navigation_controller` scaffold uses `colorScheme.surface`. `splitr_splash_screen`, `personal_details_screen` save footer, `monthly_recap_screen` scaffolds migrated off hardcoded `0xFFFAFAFA`/`Colors.white`. Share/export cards + recap slide fills keep `_lightBg` for screenshot consistency.

	- Implementation: **Done** (shell scaffolds + `ThemeController` dark mode; FAB `neopopBackground` CTAs intentional).



77. **UI inconsistency:** Typography hierarchy drifts on secondary screens.

	- **Verified:** `subtitle1_text` global grey → `neopopGrey`. `badges_section_widget`, `edit_currency`, `transaction_filter_sheet` tokenized. `premium_plan_screen` body/caption/feature rows use `body2_text`/`caption_text` + `groupGutter` spacing (Albra display prices kept).

	- Implementation: **Done** (paywall hero Albra 28/32 display sizes intentional).



78. **UI/UX gap:** Group tab inner surfaces still dark-token heavy.

	- **Verified:** `group_detailed_screen` TabBar tokenized. `wishlist_tab` cards/sheet/upvote pills use `groupOnSurface`/`groupCardFill` (accent CTA text on yellow kept). `activity_feed_tab` cards → `groupCardFill`.

	- Implementation: **Done** (group inner tabs light-shell pass complete).



79. **UI/UX audit summary (loop exit criteria):** Items **69–78** are the UI consistency backlog. Exit loop when each is **Done** or explicitly **Won't fix** with reason. Priority order for implementation pass: **70** (AppBar — highest visual impact) → **71–72** (home/profile) → **73–75** (forms/tokens) → **76–78** (theme parity + group tabs).

	- Implementation: **Done** (items **69–78** closed Jul 2026; recap/export cards excluded by design).



80. **Compile error:** `AllTransactionsScreen` missing `TransactionTile` import.

	- **Verified:** `flutter analyze lib/Screen/HomeScreen/all_transactions_screen.dart` — `undefined_method` at line 75: `TransactionTile` used but `package:splitr/Widgets/transaction_tile.dart` not imported. DOCAUDIT tick 2 missed this by not file-scoping analyze.

	- Implementation: **Done** (import added).
