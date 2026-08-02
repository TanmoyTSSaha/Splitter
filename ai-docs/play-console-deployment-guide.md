# Google Play Console — Account Creation & App Deployment Guide

**App:** Splitr (`money.splitr.app`)  
**Last updated:** 2026-07-15  
**Sources:** Official Google Play Console Help Center (linked throughout)

This guide covers developer account setup, first release, testing tracks, and production access — with **blockers and solutions** grounded in current Google policy.

---

## Table of contents

1. [Prerequisites](#1-prerequisites)
2. [Phase A — Create Play Console developer account](#2-phase-a--create-play-console-developer-account)
3. [Phase B — Create the app in Play Console](#3-phase-b--create-the-app-in-play-console)
4. [Phase C — Build & sign the release AAB (local)](#4-phase-c--build--sign-the-release-aab-local)
5. [Phase D — First upload & Play App Signing](#5-phase-d--first-upload--play-app-signing)
6. [Phase E — App content & store listing (required before review)](#6-phase-e--app-content--store-listing-required-before-review)
7. [Phase F — Testing tracks (internal → closed → production)](#7-phase-f--testing-tracks-internal--closed--production)
8. [Phase G — Production access (personal accounts after Nov 2023)](#8-phase-g--production-access-personal-accounts-after-nov-2023)
9. [Phase H — Ongoing releases (CI/CD context)](#9-phase-h--ongoing-releases-cicd-context)
10. [Blockers & solutions reference](#10-blockers--solutions-reference)
11. [Splitr-specific checklist](#11-splitr-specific-checklist)
12. [Official documentation links](#12-official-documentation-links)

---

## 1. Prerequisites

Before opening Play Console:

| Requirement | Details |
|-------------|---------|
| Age | 18+ ([source](https://support.google.com/googleplay/android-developer/answer/6112435)) |
| Google Account | Used for entire developer account lifecycle |
| Payment card | One-time **$25 USD** registration fee. Accepted: Visa, MasterCard, Amex, Discover (US), Visa Electron (outside US). **Prepaid cards not accepted.** ([source](https://support.google.com/googleplay/android-developer/answer/6112435)) |
| Identity documents | Valid government ID may be required; name on ID must match payment profile ([source](https://support.google.com/googleplay/android-developer/answer/6112435)) |
| Android device | Physical, non-rooted, **Android 10+** for device verification ([source](https://support.google.com/googleplay/android-developer/answer/14316361)) |
| Upload keystore | RSA **2048-bit+** `.jks` / `.keystore` — you generate this; Google does not provide it ([source](https://support.google.com/googleplay/android-developer/answer/9842756)) |
| Privacy policy URL | Public HTTPS URL — **required** before Data safety and store review ([source](https://support.google.com/googleplay/android-developer/answer/9859455)) |

### Account type: Personal vs Organization

| Type | When to use |
|------|-------------|
| **Personal** | Solo dev, expense/P2P apps, most consumer apps |
| **Organization** | **Required** if you provide: banking, loans, stock trading, investment funds, crypto wallets/exchanges, health/medical apps, VPN (`VpnService`), or government apps ([source](https://support.google.com/googleplay/android-developer/answer/10788890)) |

**Splitr note:** Expense-splitting with Razorpay checkout is **not** the same as banking/lending/trading. Personal account is appropriate unless Google classifies your app under Financial Services policy during review. If you add wallet, lending, or brokerage features, reassess.

---

## 2. Phase A — Create Play Console developer account

**Official guide:** [Get started with Play Console](https://support.google.com/googleplay/android-developer/answer/6112435)

### Steps

1. Go to [Play Console](https://play.google.com/console) and sign in with your Google Account.
2. Click **Sign up** / register for a developer account.
3. **Accept** the [Developer Distribution Agreement](https://play.google.com/about/developer-distribution-agreement.html).
4. Pay the **$25** one-time registration fee.
5. **Choose account type:** Personal or Organization (cannot change later easily — choose carefully).
6. **Link or create a Google Payments profile** — used for identity verification ([source](https://support.google.com/googleplay/android-developer/answer/10841920)).
7. **Complete identity verification:**
   - Personal: government ID, legal name/address from payment profile, verified email + phone (OTP).
   - Organization: D-U-N-S number, business documents (D-U-N-S can take **30+ days** to obtain).
8. **(Personal accounts)** Complete **device verification** via Play Console mobile app (see blockers below).
9. Wait until Play Console Home shows account as verified and ready.

### Blockers — account creation

| Blocker | Cause | Solution |
|---------|-------|----------|
| Payment declined | Prepaid card, wrong billing country, bank block | Use Visa/MasterCard debit or credit; contact bank; no prepaid ([source](https://support.google.com/googleplay/android-developer/answer/6112435)) |
| Identity verification failed | Name mismatch ID vs payment profile | Update Google Payments profile to match ID exactly; resubmit ([source](https://support.google.com/googleplay/android-developer/answer/10841920)) |
| Registration fee not refunded on failure | Invalid identity submitted | Fix documents and re-apply; fee may be forfeited per Google terms ([source](https://support.google.com/googleplay/android-developer/answer/6112435)) |
| Cannot publish any app | Device verification incomplete | Install Play Console app on physical Android 10+ device; scan QR from Play Console Home ([source](https://support.google.com/googleplay/android-developer/answer/14316361)) |
| Developer account not visible in mobile app | Wrong Google Account signed in | Use **same** account that created developer account ([source](https://support.google.com/googleplay/android-developer/answer/14316361)) |
| Emulator rejected | Virtual device | Use **physical** non-rooted device only ([source](https://support.google.com/googleplay/android-developer/answer/14316361)) |

---

## 3. Phase B — Create the app in Play Console

**Official guide:** [Create and set up your app](https://support.google.com/googleplay/android-developer/answer/9859152)

### Steps

1. Play Console → **Home** → **Create app**.
2. Select **default language** (e.g. English – India or US).
3. Enter **app name** (can change later; 30 chars on store).
4. Select **App** (not Game) unless Splitr is classified as game.
5. Select **Free** or **Paid** (Splitr is likely Free with IAP/subscriptions).
6. Enter **developer contact email** (shown to users).
7. Under **Declarations:**
   - Acknowledge Developer Program Policies.
   - Acknowledge US export laws.
   - **Accept Play App Signing Terms of Service** (required).
8. Click **Create app**.

### Critical: package name

- Enter **`money.splitr.app`** — must match [`android/app/build.gradle`](android/app/build.gradle) `applicationId`.
- Package name is **permanent**. Cannot change or reuse after creation ([source](https://support.google.com/googleplay/android-developer/answer/9859152)).
- Uploading any artifact locks the package name for that app.

### Blockers — app creation

| Blocker | Cause | Solution |
|---------|-------|----------|
| Wrong package name | Typo at create time | **Cannot fix.** Create new app entry with correct package; old one is wasted |
| `com.example.*` package | Default Flutter template ID | Splitr already uses `money.splitr.app` — do not use example ID |
| Play App Signing ToS not accepted | Skipped declaration | Accept during app creation or first release setup |

---

## 4. Phase C — Build & sign the release AAB (local)

Play Console requires **Android App Bundle (`.aab`)**, not APK, for new apps ([source](https://support.google.com/googleplay/android-developer/answer/9859152)).

### 4.1 Generate upload keystore

`keytool` ships with the JDK. Flutter/Android Studio already install one on Windows — it is usually **not** on `PATH`, so bare `keytool` fails with *"not recognized"*.

**Find keytool (run one):**

```powershell
# Android Studio bundled JDK (Flutter doctor often points here)
Test-Path "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"

# Or standalone JDK
Get-ChildItem "C:\Program Files\Java\*\bin\keytool.exe" -ErrorAction SilentlyContinue
```

**Option A — use full path (recommended):**

```powershell
cd C:\TanmoySaha\Works\Code\FlutterProjects\Splitter

& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -genkeypair -v `
  -keystore android\upload-keystore.jks `
  -keyalg RSA -keysize 2048 -validity 10000 `
  -alias upload
```

**Option B — add JDK to PATH for this PowerShell session only:**

```powershell
$env:Path += ";C:\Program Files\Android\Android Studio\jbr\bin"

keytool -genkeypair -v `
  -keystore android\upload-keystore.jks `
  -keyalg RSA -keysize 2048 -validity 10000 `
  -alias upload
```

You will be prompted for keystore password, key password, and certificate details (name, org, city, etc.). Store passwords in a password manager.

**If neither path exists:** install [JDK 17+](https://adoptium.net/) (matches project JVM 17), then reopen the terminal or use that install's `bin\keytool.exe` full path.

**Verify keystore after generation:**

```powershell
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -list -v `
  -keystore android\upload-keystore.jks -alias upload
```

Requirements from Google: upload key must be **RSA 2048-bit or higher** ([source](https://support.google.com/googleplay/android-developer/answer/9842756)).

### 4.2 Create `android/key.properties` (local only, gitignored)

```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=upload
storeFile=../upload-keystore.jks
```

Template: [`android/key.properties.example`](android/key.properties.example)

### 4.3 Create `env.prod.json` (local only, gitignored)

Copy from [`env.example.json`](env.example.json). Fill production values for Supabase, Sentry, Gemini, Google Sign-In, Razorpay.

### 4.4 Build signed AAB

```powershell
Copy-Item .env.example .env   # pubspec.yaml lists .env as asset — file must exist at build time

flutter pub get
flutter build appbundle --release `
  --dart-define-from-file=env.prod.json `
  --obfuscate `
  --split-debug-info=build/debug-info `
  --extra-gen-snapshot-options=--save-obfuscation-map=build/app/obfuscation.map.json
```

Output: `build\app\outputs\bundle\release\app-release.aab`

### 4.5 Verify signing

```powershell
jarsigner -verify -verbose -certs build\app\outputs\bundle\release\app-release.aab
```

If signed with debug key, Play upload will fail or create security issues.

### Blockers — local build

| Blocker | Cause | Solution |
|---------|-------|----------|
| Build uses debug signing | Missing `key.properties` or `.jks` | Gradle falls back to debug — fix keystore setup ([`build.gradle`](../android/app/build.gradle)) |
| `flutter build` fails on missing `.env` | `pubspec.yaml` asset declaration | Copy `.env.example` → `.env` before build |
| Version code collision later | Static `1.0.0+1` in pubspec | CI must pass `--build-number` > last Play upload |
| target API rejected (future) | Google raises target API bar | Splitr `targetSdk = 35` today. **From 2026-08-31**, new apps must target **API 36** ([source](https://support.google.com/googleplay/android-developer/answer/11926878)) |

---

## 5. Phase D — First upload & Play App Signing

**Official guide:** [Use Play App Signing](https://support.google.com/googleplay/android-developer/answer/9842756)

### Steps

1. Play Console → your app → **Test and release** → **Internal testing** (recommended first) or Production.
2. Click **Create new release**.
3. **Upload** `app-release.aab`.
4. On first upload, **Play App Signing enrolls automatically** (Google-generated app signing key by default).
5. You keep the **upload key**; Google holds the **app signing key** that signs APKs delivered to devices.
6. Add **release notes** → **Review release** → **Start rollout to Internal testing**.

### First manual upload requirement

Google's tooling (Play Console, Fastlane, Codemagic, Flutter CD docs) all assume **at least one version** was uploaded through Play Console before API automation works reliably. Plan for this manual step once.

### Register API key fingerprints (critical for Splitr)

Google signs the APK users install. Third-party APIs authenticate using certificate fingerprints.

**Prerequisite:** Upload at least one AAB first (§5 above). Until then, Play App Signing is not enrolled and certificate fingerprints are not shown.

**Where to find them (2026 Play Console UI):** Google moved signing out of **App integrity**. That page now redirects to **Protected with Play**.

1. Play Console → your app → **Protected with Play** (left sidebar; or click **Go to Protected with Play** from the old App integrity page).
2. Under **Play Store protection** → **Manage Play app signing** (or open directly: [play.google.com/console/developers/app/keymanagement](https://play.google.com/console/developers/app/keymanagement) and select Splitr).
3. Copy **App signing key certificate** SHA-1 and SHA-256 (not upload key — users get Google’s app signing key on device).

**Google Sign-In (GCP OAuth — project `splitr-501702`, not Firebase):**

4. [Google Cloud Console → Credentials](https://console.cloud.google.com/apis/credentials?project=splitr-501702) → Android OAuth client for `money.splitr.app`.
5. Add Play **app signing** SHA-1 (and debug/upload SHA-1 for local builds).
6. Ensure a **Web** OAuth client exists; its client ID is `GOOGLE_WEB_CLIENT_ID` in `env.prod.json`.
7. Supabase → Auth → Providers → Google: same Web client ID + secret.

**Before first upload:** GCP Android OAuth only has your local **upload key** SHA-1. After first Play upload, add the **app signing key** SHA-1 or Google Sign-In fails in release.

**Splitr impact:** Without Play app-signing SHA-1 in **GCP OAuth**, Google Sign-In fails in release builds while working in debug.

**FCM (Firebase — project `splitr-9a35d`, separate from login):**

- Wired in app: `firebase_core` + `firebase_messaging`, `device_tokens` + `push_preferences` tables, `send-push` Edge Function.
- Restore `google-services.json` from `splitr-9a35d` locally; CI uses `GOOGLE_SERVICES_JSON_BASE64`.
- Set Supabase secrets: `FCM_SERVICE_ACCOUNT_JSON`, `PUSH_WEBHOOK_SECRET`, `PUSH_CRON_SECRET`, `ADMIN_PUSH_SECRET` (marketing).
- Add Play app-signing SHA-1 to Firebase Console → Android app `money.splitr.app`.

### Blockers — first upload

| Blocker | Cause | Solution |
|---------|-------|----------|
| "Upload failed" — wrong signing | Debug-signed AAB | Rebuild with upload keystore |
| "Version code already used" | Duplicate `versionCode` | Increment `--build-number` |
| "You need to use a different package name" | Package mismatch | AAB `applicationId` must be `money.splitr.app` |
| Play App Signing not configured | Skipped ToS | Accept Play App Signing terms on first release |
| Upload key lost | No backup | Request [upload key reset](https://support.google.com/googleplay/android-developer/answer/9842756) via new PEM certificate — app signing key preserved by Google |
| App signing key lost (no Play App Signing) | Never enrolled | **Cannot update app.** Play App Signing prevents this |

---

## 6. Phase E — App content & store listing (required before review)

**Official guide:** [Prepare your app for review](https://support.google.com/googleplay/android-developer/answer/9859455)

Complete everything on **Dashboard** and **Policy and programs → App content**. Incomplete items block release.

### 6.1 Store listing

**Path:** Grow users → Store presence → Main store listing

| Field | Limit | Required |
|-------|-------|----------|
| App name | 30 chars | Yes |
| Short description | 80 chars | Yes |
| Full description | 4000 chars | Yes |
| App icon | 512×512 PNG | Yes |
| Feature graphic | 1024×500 | Yes |
| Phone screenshots | Min 2 | Yes |

### 6.2 App content declarations

| Declaration | Path | Splitr relevance |
|-------------|------|------------------|
| **Privacy policy** | App content → Privacy policy | **Required** — hosted HTTPS URL |
| **Data safety** | App content → Data safety | **Required** for closed/open/production tracks. Declare Supabase, Sentry, Gemini, Razorpay, analytics ([source](https://support.google.com/googleplay/android-developer/answer/10787469)) |
| **Ads** | App content → Ads | Declare Yes/No accurately |
| **Sign-in credentials** | App content → Sign-in details | **Required** — Splitr uses Supabase auth; provide test account for reviewers |
| **Target audience** | App content → Target audience | Age groups; affects Families policy |
| **Content rating** | App content → Content rating | Complete IARC questionnaire — unrated apps may be removed |
| **Financial features** | App content (if prompted) | Declare payments/subscriptions if applicable |

### 6.3 Data safety — internal vs other tracks

- Apps **only** on **internal testing**: exempt from Data safety section on store listing ([source](https://support.google.com/googleplay/android-developer/answer/10787469)).
- Moving to **closed testing** or higher: Data safety form **required**.

### 6.4 Demo account for reviewers

Play requires login credentials if app is restricted ([source](https://support.google.com/googleplay/android-developer/answer/10788890)):

> Provide an active demo account, login information, and all other resources needed for Google Play to review your app.

Create a dedicated `reviewer@...` Supabase user. Document email/password in Sign-in details. Ensure account has sample group/expense data.

### Blockers — app content

| Blocker | Cause | Solution |
|---------|-------|----------|
| Release button greyed out | Dashboard tasks incomplete | Complete every item on Dashboard checklist |
| Privacy policy rejected | URL 404, generic template, not app-specific | Host live policy covering Splitr data practices |
| Data safety mismatch | Under-declared SDK data collection | Declare all SDKs: Supabase, Sentry, Google ML Kit, Razorpay, Firebase, etc. |
| Review rejection — can't log in | No demo account or broken auth | Add working test credentials in Sign-in details |
| "Unrated" removal warning | Content rating not done | Complete IARC questionnaire |
| Families policy violation | Wrong target audience | If not for children, don't select child age groups |

---

## 7. Phase F — Testing tracks (internal → closed → production)

**Official guide:** [Set up an open, closed, or internal test](https://support.google.com/googleplay/android-developer/answer/9845334)

### Track comparison

| Track | Max testers | Setup required | Purpose |
|-------|-------------|----------------|---------|
| **Internal** | 100 | None — can start before app fully configured | Fast QA; builds live in **minutes** |
| **Closed** | 2000 per list, 200 lists | App setup finished | Wider beta; **required path to production** for new personal accounts |
| **Open** | Unlimited | **Production access required** | Public opt-in beta |
| **Production** | All users | Closed test + approval for personal accounts | Live release |

### 7.1 Internal testing (start here)

**Path:** Test and release → Testing → Internal testing

1. **Testers** tab → Create email list → add Gmail / Google Workspace addresses (max 100).
2. **Releases** tab → Create new release → upload AAB → rollout.
3. Copy **opt-in link** → send to testers.
4. Testers need Google account; install via Play Store link.

**Notes:**
- First publish may show **temporary app name** for up to 48 hours ([source](https://support.google.com/googleplay/android-developer/answer/9845334)).
- Internal testers who opt in **cannot** also receive closed/open tests until they opt out of internal first.
- Paid apps: internal testers install **free** ([source](https://support.google.com/googleplay/android-developer/answer/9845334)).

### 7.2 Closed testing (required before production)

**Path:** Test and release → Testing → Closed testing

1. Create email list or Google Group.
2. Create release → upload AAB → rollout.
3. Share opt-in link.
4. Collect feedback (Play Console → Ratings and reviews → Testing feedback).

### 7.3 Open testing

Only available **after production access** is granted ([source](https://support.google.com/googleplay/android-developer/answer/14151465)).

### Blockers — testing tracks

| Blocker | Cause | Solution |
|---------|-------|----------|
| Test link not working | First publish delay | Wait up to a few hours after first release ([source](https://support.google.com/googleplay/android-developer/answer/9845334)) |
| Tester can't install | Not opted in, wrong Google account | Use opt-in link; tester must use listed Gmail |
| "Not compatible with your device" | ABI / SDK filters | Check `minSdk`; test on physical device |
| Tester on internal can't join closed | Track exclusivity | Opt out of internal first ([source](https://support.google.com/googleplay/android-developer/answer/9845334)) |
| CSV upload fails | UTF-8 with BOM | Re-save CSV without BOM ([source](https://support.google.com/googleplay/android-developer/answer/9845334)) |

---

## 8. Phase G — Production access (personal accounts after Nov 2023)

**Official guide:** [App testing requirements for new personal developer accounts](https://support.google.com/googleplay/android-developer/answer/14151465)

If your **personal** developer account was created **after November 13, 2023**, Production and Pre-registration are **disabled** until you complete closed testing and apply.

### Requirements for production access

| Requirement | Detail |
|-------------|--------|
| Closed test | Must run closed testing track |
| Testers | **Minimum 12** opted-in testers |
| Duration | Testers must stay opted in **14 consecutive days** (not cumulative) |
| Application | Dashboard → **Apply for production** |
| Review time | Usually **7 days or less** (can be longer) |

### Application sections

1. **About your closed test** — recruitment difficulty, engagement, feedback summary.
2. **About your app** — target audience, value proposition, expected installs year 1.
3. **Production readiness** — changes made from testing, why ready for production.

### After approval

- **Production** track unlocks (Test and release → Production).
- **Open testing** unlocks.
- Use **staged rollout** (e.g. 10% → 50% → 100%) for safer production releases.

### Blockers — production access

| Blocker | Cause | Solution |
|---------|-------|----------|
| "Apply for production" not visible | <12 testers or <14 days | Wait; ensure 12 testers **continuously** opted in 14 days ([source](https://support.google.com/googleplay/android-developer/answer/14151465)) |
| Application rejected | Low tester engagement | Recruit active testers; document real usage in re-application |
| Tester opted out day 10 | Breaks 14-day continuity | 14 days must be **consecutive** — restarting clock |
| Production still locked | Personal account, not approved | Cannot bypass with Organization switch on same app — must complete process |
| Device verification incomplete | Personal account | Complete Play Console mobile app verification first |

---

## 9. Phase H — Ongoing releases (CI/CD context)

After Phase D manual first upload, automate with GitHub Actions + Fastlane (see CI/CD plan).

### Per-release checklist

1. Increment `versionCode` (monotonic — Play rejects duplicates).
2. Build signed AAB with production `--dart-define-from-file`.
3. Upload to target track (internal / beta / production).
4. Upload mapping / debug symbols to Sentry.
5. For production: consider staged rollout percentage.

### Play track mapping (your CI/CD plan)

| Your stage | Play track |
|------------|------------|
| Auto on `Master` merge | `internal` |
| Manual dispatch | `beta` |
| Manual dispatch + rollout | `production` |

### versionCode rules

- Max `versionCode`: **2,100,000,000** ([source](https://support.google.com/googleplay/android-developer/answer/9859152)).
- Each upload must have **higher** versionCode than any previous upload on any track.

---

## 10. Blockers & solutions reference

Quick lookup — all phases.

| # | Symptom | Likely cause | Fix |
|---|---------|--------------|-----|
| 1 | Can't create developer account | Age, payment, region | 18+; valid non-prepaid card |
| 2 | Identity verification stuck | ID/name mismatch | Align Google Payments profile with government ID |
| 3 | Can't publish anything | Device verification pending | Play Console app on physical Android 10+ |
| 4 | Upload rejected — signature | Debug-signed AAB | Use upload keystore via `key.properties` |
| 5 | Upload rejected — version | Duplicate versionCode | `--build-number=$((max_play_code + 1))` |
| 6 | Google Sign-In fails in release | Wrong SHA-1 in GCP OAuth (`splitr-501702`) | Register **App signing key** SHA-1 on Android OAuth client in Google Cloud |
| 7 | Razorpay fails in release | Live vs test keys | Use live `RAZORPAY_KEY_ID` in prod env; verify backend |
| 8 | Release blocked on Dashboard | Incomplete App content | Finish all declarations |
| 9 | Data safety enforcement | SDK collects undeclared data | Update Data safety form to match actual behavior |
| 10 | Review rejection — login | No demo account | Add Supabase test credentials |
| 11 | Production locked | Personal account post-Nov 2023 | 12 testers × 14 days closed test → Apply |
| 12 | CI upload 403 | Service account permissions | Grant Release permission in Play Console Users |
| 13 | Lost upload keystore | No backup | Play Console → request upload key reset |
| 14 | Lost app signing key (no PAS) | Never used Play App Signing | **Unrecoverable** — use Play App Signing always |
| 15 | target API warning | Outdated targetSdk | Splitr: raise to 36 before 2026-08-31 for new submissions |

---

## 11. Splitr-specific checklist

Use this after account creation, before first public release.

### Build & signing

- [ ] Upload keystore generated and backed up offline
- [ ] `android/key.properties` configured locally
- [ ] `env.prod.json` with all production keys
- [ ] Signed AAB builds locally without debug fallback
- [ ] `targetSdk 35` (raise to 36 before Aug 31, 2026 for new submissions)

### Google Sign-In (GCP OAuth `splitr-501702`)

- [ ] Play **App signing** SHA-1 + SHA-256 on Android OAuth client in Google Cloud
- [ ] Web OAuth client created; `GOOGLE_WEB_CLIENT_ID` in prod env matches it
- [ ] Supabase Google provider enabled with same Web client ID + secret
- [ ] Google Sign-In tested on **release** build from internal track

### FCM (Firebase `splitr-9a35d`)

- [x] Client: `firebase_core` + `firebase_messaging` + `PushNotificationService`
- [x] Server: `device_tokens`, `push_preferences`, `send-push` Edge Function, `process-push-outbox` cron fallback
- [ ] `google-services.json` from `splitr-9a35d` on build machines (`GOOGLE_SERVICES_JSON_BASE64` secret)
- [ ] `FCM_SERVICE_ACCOUNT_JSON` + `PUSH_WEBHOOK_SECRET` + `PUSH_CRON_SECRET` in Supabase secrets
- [ ] Play app-signing SHA-1 added to Firebase Android app
- [ ] Database Webhook on `notifications` INSERT → `send-push` (optional; outbox cron covers delay)
- [ ] Data safety form: declare Firebase SDK + device identifiers / push tokens

### Play Console content

- [ ] Privacy policy URL live
- [ ] Data safety form completed (required before closed testing)
- [ ] Demo Supabase account for reviewers
- [ ] Content rating questionnaire done
- [ ] Financial/payment features declared if prompted
- [ ] Store listing: icon, screenshots, descriptions

### Testing path (personal account)

- [ ] Internal testing with your team (up to 100)
- [ ] Closed testing with 12+ testers for 14 consecutive days
- [ ] Apply for production access
- [ ] Production release with staged rollout

### CI/CD (after manual first upload)

- [ ] GitHub secrets: keystore, Play service account, `PROD_ENV_JSON` (`GOOGLE_SERVICES_JSON_BASE64` only when FCM is enabled)
- [ ] `deploy_android.yml` uploads to `internal` on `Master` merge
- [ ] Manual workflow for `beta` and `production`

---

## 12. Official documentation links

| Topic | URL |
|-------|-----|
| Get started / account registration | https://support.google.com/googleplay/android-developer/answer/6112435 |
| Identity verification | https://support.google.com/googleplay/android-developer/answer/10841920 |
| Device verification (personal) | https://support.google.com/googleplay/android-developer/answer/14316361 |
| Play Console requirements | https://support.google.com/googleplay/android-developer/answer/10788890 |
| Create and set up app | https://support.google.com/googleplay/android-developer/answer/9859152 |
| Play App Signing | https://support.google.com/googleplay/android-developer/answer/9842756 |
| Internal / closed / open testing | https://support.google.com/googleplay/android-developer/answer/9845334 |
| Personal account testing requirements | https://support.google.com/googleplay/android-developer/answer/14151465 |
| Prepare app for review | https://support.google.com/googleplay/android-developer/answer/9859455 |
| Data safety form | https://support.google.com/googleplay/android-developer/answer/10787469 |
| Target API level requirements | https://support.google.com/googleplay/android-developer/answer/11926878 |
| Flutter continuous delivery | https://docs.flutter.dev/deployment/cd |
| Fastlane upload_to_play_store | https://docs.fastlane.tools/actions/upload_to_play_store/ |

---

## Recommended timeline for Splitr (realistic)

| Week | Action |
|------|--------|
| 1 | Create developer account; identity + device verification; generate keystore; build signed AAB |
| 1 | Create app `money.splitr.app`; upload to **internal testing**; fix GCP OAuth SHA-1 |
| 1–2 | Complete store listing, privacy policy, data safety, content rating, demo account |
| 2 | Start **closed testing**; recruit 12+ testers |
| 3–4 | Maintain 14-day closed test; gather feedback; fix bugs |
| 4 | Apply for **production access**; wait for review (~7 days) |
| 5+ | Production staged rollout; enable CI/CD automation |

**Minimum calendar time to production (personal account, no shortcuts): ~3–4 weeks** — dominated by the 14-day closed test requirement, not build time.

---

## Developer display name ideas (Gen Z energy, still Play-safe)

**Note:** Personal accounts must use your **real legal name** on your Google Payments profile for verification. The names below are for your **public developer name** on Google Play (what users see under "Offered by"). Pick something you'd still be fine with on a store listing in 2026.

### Top picks

| Name | Vibe |
|------|------|
| **Side Quest Studios** | Gaming-coded, works for any app genre |
| **Midnight Commit Co.** | Dev culture without being corny |
| **Lowkey Digital** | Gen Z staple, sounds legit |
| **Main Character Labs** | Bold, memorable, not cringe |
| **Ship It Society** | Indie dev energy, action-oriented |
| **Final Form Apps** | Anime / transformation arc coded |
| **Silent Launcher** | Clean, mysterious, scalable |
| **Patch Notes Pending** | Relatable dev humor, still professional |

### More unhinged (meme-forward brands)

| Name | Vibe |
|------|------|
| **Touch Grass Software** | Ironic "go outside" dev account |
| **Delulu Labs** | Peak 2024–2026 slang, confident |
| **Works On My Machine** | Classic dev meme, instant recognition |
| **Undefined Behavior Co.** | Programmer inside joke |
| **Hotfix Heroes** | Chaotic good dev house |
| **Beta Era Collective** | "In my beta testing era" |
| **Brainrot but Functional** | Self-aware, very online |
| **404 Motivation Found** | Punny, lighthearted |
| **Git Push & Pray** | Chaos energy |
| **No Documentation Studios** | Honest. Too honest. |

### Clean / scalable (multi-app umbrella)

| Name | Vibe |
|------|------|
| **Northbound Interactive** | Grown-up, no meme baggage |
| **Parallel Thread Labs** | Techy without trying hard |
| **Small Wins Software** | Wholesome indie dev |
| **Offscreen Studios** | Aesthetic, genre-neutral |
| **After Hours Apps** | Side-project grind coded |
| **Pixel & Prose** | Creative, broad appeal |
| **Stack Trace Studios** | Dev-native, still readable |
| **Null Island Software** | Niche programmer joke, memorable |

### Avoid for Play Console public name

- Big tech cosplay: `Google Labs`, `Meta Official`, `Apple Dev Team`
- All caps spam: `BEST APPS OFFICIAL REAL`
- Emoji in name: `My App Studio 🚀🔥` (Play may strip or reject)
- "Official" / "Verified" unless you actually are — policy gray area
- Trademark bait: existing app/store/dev names you don't own

**Solid defaults:** **Side Quest Studios**, **Lowkey Digital**, or **Midnight Commit Co.** — unique, Gen Z-adjacent, won't scare Play review.
