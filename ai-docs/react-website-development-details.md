# Splitr Website — Product Specification

**Document owners:** Product Agent (requirements) · UI/UX Agent (visual design)  
**Single source of truth** for website product requirements **and** UI/UX specifications.  
**Last updated:** 2026-07-27  
**Status:** v1 code complete — deploy `preview-invite` to Supabase + Vercel; §9.6 QA → `Verified`  
**Domain (canonical):** `https://splitr.money` (`AppBranding.webBaseUrl` in mobile app)

---

## 1. Project scope (agreed)

| Area | Scope |
|------|--------|
| Marketing | Premium landing page with scroll storytelling; motion delegated to UI/UX Agent (R3F / Three.js / GSAP inspiration — CRED, Stripe, Apple, Linear patterns, not copies) |
| Compliance | All Play Store–required public pages |
| Compliance | All Razorpay merchant–required public pages |
| Product | Splitwise-like **authenticated** web experience |
| Brand | Existing Splitr mobile UI theme sitewide (visual tokens owned by UI/UX Agent) |

**Out of scope for Product Agent:** production code, typography, spacing, colour systems, animation implementation.

### 1.1 Product Agent charter

| Owns | Does not own |
|------|----------------|
| What gets built — full user journeys | Production code (Developer Agent) |
| Business + user objectives per atomic feature | Visual design, tokens, layout pixels (UI/UX Agent) |
| Functional behaviour, flows, acceptance criteria | Motion implementation (UI/UX defines; Product references §11/§12) |
| Coordination + §7 completeness gate | Assumptions without research or user confirmation |

**Rule:** Never one big "Landing Page" feature. Split navigation, hero, story beats, comparison, CTAs, footer, auth, each app surface, each legal page, infra (SEO, 404, cookie) as **independent §7 entries**.

**Gate:** Developer/UI/UX implement only features with complete §7 rows + matching §12 UI/UX Details where visual/motion applies.

---

## 2. Current codebase baseline

| Asset | State |
|-------|--------|
| `apps/web/` | Vite + React 19 scaffold (default Vite starter — **not** product site) |
| `apps/web/public/share/` | Monthly recap share reader (`index.html`) — **keep** |
| `apps/web/public/auth/callback/` | OAuth callback page — **keep** |
| `apps/web/public/.well-known/` | `assetlinks.json`, `apple-app-site-association` — **keep** |
| Mobile app | Full product; web is marketing + compliance + future authenticated parity |

---

## 3. Research summary (2026-07-27)

### 3.1 Play Store public URL requirements

From `ai-docs/play-console-deployment-guide.md` and Google policy:

| Requirement | Website implication |
|-------------|-------------------|
| Privacy policy URL | **Required** — HTTPS, app-specific, not generic template |
| Data safety | Declared in Play Console; website policy must **align** with declared SDKs (Supabase, Sentry, Gemini, Razorpay, Firebase, etc.) |
| Sign-in for reviewers | Demo account documented in Console — not a page, but web auth flows must support reviewer login |
| Account deletion | Google requires in-app path + **web URL** for account/data deletion when app allows account creation ([Play policy](https://support.google.com/googleplay/android-developer/answer/13327109)) |
| Financial features | Declare payments/subscriptions — site must describe Splitr Pro + Razorpay processing |

### 3.2 Razorpay merchant requirements

From `ai-docs/razorpay-production-guide.md`:

| Requirement | Website implication |
|-------------|-------------------|
| Website verification | Public HTTPS URL submitted in Dashboard → **Account & Settings → Website and app settings** |
| Live API keys blocked | Until KYC + website verified (~3 working days) |
| Privacy policy | Must disclose Razorpay payment processing and data shared |
| Product description | Site must describe what user pays for (donations, Splitr Pro subscriptions) |
| Policies | Refund, cancellation, terms typically required for merchant KYC — **exact list pending Razorpay dashboard confirmation** |

**Razorpay flows in app today:** donations (client-only checkout), Splitr Pro subscriptions (server-authoritative via Supabase Edge Functions). Group settle-up uses UPI deep links — **not** Razorpay.

### 3.3 Landing page patterns (research, not copy)

| Pattern | Why it works | Splitr application (product-level) |
|---------|--------------|-----------------------------------|
| Single primary CTA above fold | Reduces decision fatigue | **Primary:** app install (Play Store / smart banner). **Secondary:** sign in / use on web |
| Scroll-linked narrative | Builds trust before ask | Sections: problem → how it works → social proof → pricing/Pro → FAQ |
| Motion with purpose | Signals quality without clutter | UI/UX defines mesh/parallax; Product defines **what** each beat communicates |
| Comparison / differentiation | Converts users evaluating alternatives | **Multi-competitor table** — Splitwise + 1–2 others (§6.5) |
| Trust stack | Fintech users need security signals | Privacy, encryption, no-ads, India-first payments |

### 3.5 Conversion & SaaS landing (research)

| Pattern | Source class | Splitr application |
|---------|--------------|-------------------|
| One primary conversion action | SaaS / app landing best practice | Install app primary; sign-in secondary (§6.2) |
| Repeat CTA after trust sections | Stripe, Linear, CRED funnels | Final CTA band (F-L07) after FAQ |
| Anchor nav to pricing/FAQ | Reduces scroll friction | Footer + optional nav anchors (F-C08) |
| Social proof without fabrication | Fintech trust norms | Trust strip factual icons only (F-L02) |
| Comparison for evaluators | Splitwise-alternative searches | Comparison table (F-L04) |

### 3.6 Onboarding & auth (research)

| Pattern | Application |
|---------|-------------|
| OAuth + email parity with mobile | F-A01 — same Supabase project |
| Minimal web onboarding | Post-login → overview; no mobile onboarding clone |
| Blocked actions → app | Read-only web v1; every write surfaces install/open-app (§6.4) |
| Deep link preview before install | F-A07 join/invite landings |

### 3.7 Storytelling scroll (research)

| Beat | Section | Product message |
|------|---------|-----------------|
| Hook | F-L01 Hero | Split, track, settle — India-friendly |
| Mechanism | F-L08 How it works | 3–4 steps: add expense → split → settle UPI |
| Capability | F-L03 Feature grid | Beyond pure split apps |
| Differentiation | F-L04 Comparison | Factual vs Splitwise / India apps |
| Monetization | F-L05 Pro pricing | ₹ plans; checkout in app |
| Trust | F-L02 Trust strip | Privacy, UPI, free core |
| Objections | F-L06 FAQ | Free vs Pro, data, web vs app |
| Close | F-L07 Final CTA | Install again |

Motion beats owned by UI/UX (§11, §12); Product defines **what** each beat must communicate.

---

## 4. Page inventory (canonical URLs §6.8)

Implementation tracker synced §9.3. Features broken into atomic §7 specs.

### 4.1 Marketing / landing

| Page / section | Notes |
|----------------|-------|
| Global navigation | Logo, primary CTAs, legal links |
| Hero section | Messaging, primary CTA |
| Scroll storytelling / animation beats | Product story sequence — content only |
| Feature grid | Core capabilities |
| Comparison section | Multi-competitor table — §6.5 |
| Social proof | Trust strip only v1 — no fake testimonials or user counts (§9.2) |
| Splitr Pro / pricing | Align with ₹89/mo, ₹799/yr (mobile fallbacks) |
| FAQ | |
| Footer | Legal links, contact, app store badges |
| SEO metadata | |
| Analytics | GA4 — §6.7 |
| Loading experience | |
| Error / 404 experience | |

### 4.2 Play Store compliance pages

| Page | Notes |
|------|-------|
| Privacy Policy | Must match Data safety + SDK list |
| Terms of Service / Terms of Use | |
| Account deletion instructions | URL required by Play; may link to in-app flow + support |
| Contact / support | |
| Data safety companion page (optional) | Human-readable summary of Data safety form |

### 4.3 Razorpay compliance pages

| Page | Notes |
|------|-------|
| Refund Policy | Pro subscriptions + donations |
| Cancellation Policy | Subscription cancel-at-cycle-end behaviour |
| Payment terms | Merchant disclosure |
| Privacy Policy | Shared or section — must mention Razorpay |
| Contact | Business contact for payment disputes |

### 4.4 Authenticated web app (v1 — read-only)

| Area | v1 scope | Notes |
|------|----------|-------|
| Authentication | **In scope** | Supabase auth — align with mobile (Google, email, etc.) |
| Home / overview | **Read-only** | Balance summary, recent activity — no create/edit |
| Groups | **Read-only** | List groups, group detail, expense list, balances — view only |
| Friends / balances | **Read-only** | Friend list, 1:1 balances, transaction history — view only |
| Deep link landings | **Read-only preview** | `/join/{token}`, `/invite/friend/{userId}` — show context + install/open-app CTA to act |
| Action routing | **Required** | Any write action (add expense, settle, edit, join, invite accept) → deep link to app or Play Store |
| Onboarding | **Minimal** | Post-login dashboard; no full mobile onboarding clone |
| Lending | **Out of v1** | App only |
| Goals / insights / recap | **Out of v1** | App only |
| Profile & settings | **Minimal read-only** | Display name, email; settings edits → app |
| Splitr Pro management | **Out of v1** | View plan status optional; subscribe/cancel → app |

**v2 backlog (explicit):** write flows (add expense, settle-up), lending, goals, insights, Pro management, full profile settings.

### 4.5 Existing static assets (preserve)

| Path | Purpose |
|------|---------|
| `/share/*` | Recap share reader |
| `/auth/callback` | OAuth |
| `/.well-known/assetlinks.json` | Android App Links |
| `/.well-known/apple-app-site-association` | iOS universal links |

---

## 5. Open questions (discovery log)

Answered questions move to §6. One question at a time with Product Agent.

| # | Question | Status |
|---|----------|--------|
| 1 | Primary website business goal (ranked) | **Resolved** → §6 |
| 2 | Primary audience & markets | **Resolved** → §6.3 |
| 3 | Hero CTA priority | **Resolved** → §6.2 |
| 4 | Authenticated web scope (full mobile parity vs MVP) | **Resolved** → §6.4 |
| 5 | Comparison section — competitors and claims | **Resolved** → §6.5 |
| 6 | Legal entity name / contact for policies | **Resolved** → §6.6 |
| 7 | Analytics stack | **Resolved** → §6.7 |
| 8 | Localization (EN-only vs Hindi, etc.) | **Partial** → §6.3 (EN v1; Hindi later) |
| 9 | Hosting / deployment target (Vercel, Firebase, etc.) | **Resolved** → §6.8 |

---

## 6. Resolved decisions

### 6.1 Website business goals (2026-07-27)

| Priority | Goal | Implication |
|----------|------|-------------|
| **Primary** | **A — App installs** | Hero, sticky nav, footer: Play Store badge + deep link primary. Scroll story ends with install CTA. Mobile traffic → store, not web signup first. |
| Secondary | **B — Web product** | Persistent secondary CTA: Sign in / Open web app. Authenticated experience required but not hero driver. |
| Secondary | **C — Compliance** | Legal pages ship early — unblock Play Console + Razorpay KYC before polish. Minimal landing acceptable for verification window. |
| Secondary | **E — Brand / trust** | Premium landing + motion = credibility layer supporting install decision. Not vanity — reduces bounce before CTA. |

**Not primary:** Splitr Pro / Razorpay conversion on web (donations + Pro stay in-app; web may describe Pro on landing but not optimize checkout on site).

### 6.2 Hero CTA hierarchy (derived)

| Element | Action | Notes |
|---------|--------|-------|
| Primary CTA (hero) | Get Splitr on Android / Install app | Play Store link; smart app banner on mobile web |
| Secondary CTA (hero + nav) | Sign in | Routes to authenticated web when live |
| Tertiary (nav / footer) | Legal, contact, Pro info | Compliance + trust |

**Deep links:** `/join/{token}`, `/invite/friend/{userId}` should prefer app open; fallback to web join flow when authenticated web exists.

### 6.3 Audience & markets (2026-07-27)

**Decision:** **B — India-first, global later**

| Dimension | v1 website |
|-----------|------------|
| Geography | India primary market; global visitors supported but not optimized |
| Language | **English only** on site v1 (Hindi / regional = future) |
| Currency display | **INR (₹)** for Pro pricing and examples; do not market multi-currency on landing |
| Personas | Same as mobile: roommates, friend groups, travelers, personal budgeters, informal lenders — no single hero persona; lead with universal split/track/settle story |
| Trust signals | India-relevant: UPI settle-up, Razorpay for Pro, INR-native UX, data privacy |
| Global later | Architecture/copy should not block i18n or currency expansion; no v1 pages for non-INR marketing |

**Content implications:**
- Hero/problem framing: shared expenses in India context without excluding global users
- Pro section: show ₹89/mo and ₹799/yr (mobile fallbacks)
- Comparison: India-aware (Splitwise popular in India) but EN copy
- Legal/compliance: India jurisdiction + Razorpay merchant requirements
- SEO: India-weighted keywords optional; no geo-gating on site

### 6.4 Authenticated web scope (2026-07-27)

**Decision:** **C — Groups + friends read-only**

| Layer | v1 behaviour |
|-------|----------------|
| Data visibility | User sees groups, group expenses, balances, friend balances, transaction history |
| Mutations | **None on web** — add expense, edit, delete, settle, join group, accept invite, lend, goals → **open in app** |
| Primary web value | Check balances on desktop; deep-link preview before install; reviewer can log in and browse |
| Deep links | `/join/{token}`, `/invite/friend/{userId}` show read-only preview + primary install CTA + secondary open-in-app |
| Navigation model | Simplified vs mobile 4-tab shell: **Overview** (home), **Groups**, **Friends**, **Account** (minimal) |
| Empty states | Every blocked action shows clear CTA: “Install Splitr” or “Open in app” with deep link |

**Out of v1 web (v2 backlog):** write flows, lending, goals, expense insights, monthly recap, donations, Pro subscribe/cancel, UPI management, contacts import, receipt OCR.

**Aligns with Primary A:** web supports sign-in secondary goal without competing with install; users who need to act go to app.

### 6.5 Landing comparison section (2026-07-27)

**Decision:** **C — Multi-competitor comparison table**

| Element | Spec |
|---------|------|
| Format | Side-by-side comparison table on landing page |
| Columns | **Splitr** + **Splitwise** + **2 additional competitors** (4 columns total) |
| Competitor shortlist | **Splitwise** (required); **BillSplit** + **BillSplitzer** (India split apps) — confirm public feature claims before publish; swap column if market changes |
| Row count | **4–6 rows** — not exhaustive feature matrix |
| Row themes (product-level) | Group splitting; UPI / India settle-up; personal finance + goals; informal lending; offline / local-first groups; Pro / advanced tooling (OCR, exports) |
| Tone | Factual differentiation; no insults, no unverifiable “best” claims |
| Claims rule | Every cell must map to **shipped Splitr capability** (`product-description.md`) or documented competitor fact; ambiguous → omit row or use “Varies” |
| India context | Include ≥1 row on UPI settle-up or INR-native flows |
| CTA after table | Primary install CTA repeated |
| Legal | Competitor names = nominative use for comparison; no logos without permission unless UI/UX confirms fair-use treatment |

**Example row topics (content draft in §7 feature spec):**

| Topic | Splitr emphasis |
|-------|-----------------|
| Split group bills | Core |
| Settle via UPI deep links | India-native |
| Personal spending + goals | Beyond pure split apps |
| Friend lending (contracts, EMI) | Differentiator vs Splitwise |
| Receipt OCR + exports (Pro) | Power-user tier |
| Offline group data (Drift) | Reliability angle |

**Out of scope:** Live competitor pricing in table; star ratings; fake review counts.

### 6.6 Legal entity & contact (2026-07-27)

**Decision:** **A — Individual / sole proprietor** (aligns with Razorpay individual/unregistered path in `razorpay-production-guide.md`)

| Field | Value |
|-------|-------|
| Entity type | Individual operator (not registered company v1) |
| Product / brand name | **Splitr** (service name on site and policies) |
| Legal operator name | **Tanmoy Saha** (individual — appears on privacy, terms, refund, cancellation) |
| Primary support email | `support@splitr.money` |
| Alternate contact email | `contact@tanmoytssaha.cc` |
| Public contact page | Both emails listed; **support@splitr.money** = default for users, refunds, privacy requests |
| Grievance / payment disputes | Same as support email unless Razorpay dashboard requires separate grievance officer later |
| Physical address | **Not provided yet** — confirm if city/state required for Razorpay KYC or omit until registration |

**Usage on legal pages (all compliance URLs):**
- Footer + Contact page: `support@splitr.money` (mailto link)
- Privacy “contact us”: `support@splitr.money`; optional secondary `contact@tanmoytssaha.cc`
- Razorpay refund/cancellation: merchant contact = `support@splitr.money`
- Play account deletion page: support email + in-app deletion path

**Domain:** Canonical public site **`https://splitr.money`** — matches `AppBranding.webBaseUrl` and `support@splitr.money`. Do not publish marketing/compliance on `splitr.app`.

**Policy boilerplate pattern:** “Splitr is operated by Tanmoy Saha, an individual based in India.”

### 6.7 Analytics stack (2026-07-27)

**Decision:** **B — Google Analytics 4 (GA4)**

| Element | Spec |
|---------|------|
| Product analytics | **GA4** on marketing site + authenticated web (page views, funnels) |
| Error monitoring | **Sentry** for web (align with mobile `sentry_flutter`) — separate from GA4 |
| v1 events (minimum) | `page_view`; `cta_install_click` (hero, footer, sticky); `cta_sign_in_click`; `scroll_section_view` (hero, features, comparison, pricing, FAQ); `outbound_play_store` |
| Authenticated web | GA4 page views on app routes; no PII in event params |
| Cookie / consent | GA4 requires disclosure in Privacy Policy + Data safety (Google Analytics SDK/cookies); UI/UX defines consent banner if required for India — Product: **cookie notice required v1** |
| Env config | `GA4_MEASUREMENT_ID` via build env (not hardcoded in repo) |
| Out of v1 | Plausible, Mixpanel, Hotjar, full product analytics suite |

**Compliance linkage:** Declare GA4 in Play Data safety form alongside existing SDKs (Supabase, Sentry, Razorpay, etc.).

### 6.8 Hosting & deployment (2026-07-27)

**Decision:** **Vercel** hosting · canonical domain **`https://splitr.money`**

| Element | Spec |
|---------|------|
| Platform | **Vercel** — static Vite build from `apps/web` |
| Production domain | **`splitr.money`** (primary) + `www.splitr.money` redirect to apex |
| Legacy `splitr.app` | **Not** website host; if DNS exists, 301 redirect to `splitr.money` preserving path |
| Build output | `pnpm --filter web build` → `apps/web/dist` |
| SPA routing | Vercel rewrites: client routes + preserved static paths (`/share/*`, `/auth/callback`, `/.well-known/*`) |
| Preview deploys | Vercel preview URLs per PR (Developer Agent) |
| Env vars (Vercel) | `GA4_MEASUREMENT_ID`, `SENTRY_DSN` (web), Supabase public keys for auth — no secrets in client beyond public keys |
| CI | GitHub → Vercel (existing repo); align with monorepo root / `apps/web` as Vercel project root |
| Razorpay verification URL | `https://splitr.money` (live privacy + product description) |

**Canonical URL map (v1 — base `https://splitr.money`):**

| Path | Purpose |
|------|---------|
| `/` | Landing |
| `/privacy` | Privacy policy |
| `/terms` | Terms of service |
| `/refund` | Refund policy |
| `/cancellation` | Cancellation policy |
| `/contact` | Contact / support |
| `/account-deletion` | Play account deletion instructions |
| `/auth/callback` | Supabase OAuth (existing static) |
| `/join/{token}` | Group invite deep link |
| `/invite/friend/{userId}` | Friend invite deep link |
| `/share/*` | Recap share reader (existing static) |
| `/app/*` | Authenticated web (v1 read-only) |

### 6.9 Information architecture (2026-07-27)

**Three zones** on `splitr.money`:

| Zone | Routes | Auth | Purpose |
|------|--------|------|---------|
| **Marketing** | `/`, anchor sections | Public | Install conversion, trust, Pro overview |
| **Legal / compliance** | `/privacy`, `/terms`, `/refund`, `/cancellation`, `/contact`, `/account-deletion` | Public | Play + Razorpay + user trust |
| **App (web)** | `/app`, `/app/groups`, `/app/friends`, `/app/account`, deep links | Supabase session | Read-only balances v1 |
| **Static (preserved)** | `/share/*`, `/auth/callback`, `/.well-known/*` | Mixed | Recap reader, OAuth, App Links |

**Marketing page section order (scroll):**
1. Hero (install CTA primary)
2. Problem / value strip
3. How it works (3–4 steps)
4. Feature grid (split, track, settle, lend, goals)
5. Comparison table (§6.5)
6. Splitr Pro pricing (₹89/mo, ₹799/yr)
7. Trust strip (UPI, privacy, no ads — no fake stats)
8. FAQ
9. Final install CTA
10. Footer (legal links)

**Authenticated nav (v1):** Overview → Groups → Friends → Account (sidebar desktop / bottom tabs mobile per §11.11.5).

**Deep link routing:**
| Path | Logged out | Logged in |
|------|------------|-----------|
| `/join/{token}` | Preview + install CTA | Read-only group preview + open-in-app to join |
| `/invite/friend/{id}` | Preview + install CTA | Read-only friend context + open-in-app |

---

## 7. Feature specifications

> **§7 is the implementation contract.** Every row below must include all template fields. UI/UX enriches §12; motion specs live in §12 — Product cites them via **Motion Requirements Reference**.

### 7.0 Mandatory feature template

| Field | Owner | Notes |
|-------|-------|-------|
| Feature Name | Product | Atomic scope — one section or one page |
| Business Objective | Product | Tie to §6.1 goals |
| User Objective | Product | Job user accomplishes |
| Description | Product | What it is (not how it looks) |
| Functional Behaviour | Product | States, rules, edge cases |
| User Flow | Product | Step-by-step journey |
| Dependencies | Product | Other §7 IDs, env, static assets |
| Components Required | Product | Logical components (names for Dev/UI) |
| Acceptance Criteria | Product | Testable outcomes |
| Developer Notes | Product | Data, APIs, env, preserve paths |
| Motion Requirements Reference | Product → UI/UX | §12 animation spec or "static / §11.9 global" |
| UIUX Requirements Reference | Product → UI/UX | §12.2 entry ID |
| Implementation Status | All agents | `Specified` → `In Progress` → `Implemented` → `Verified` |
| Review Notes | Dev / UI/UX / Product | Post-build findings |

### 7.1 Feature registry (v1)

| ID | Feature | URL / surface | Status |
|----|---------|---------------|--------|
| F-C01 | Privacy Policy | `/privacy` | Implemented |
| F-C02 | Terms of Service | `/terms` | Implemented |
| F-C03 | Refund Policy | `/refund` | Implemented |
| F-C04 | Cancellation Policy | `/cancellation` | Implemented |
| F-C05 | Contact | `/contact` | Implemented |
| F-C06 | Account deletion | `/account-deletion` | Implemented |
| F-C07 | Cookie consent (GA4) | Public pages | Implemented |
| F-C08 | Global navigation | Marketing shell | Implemented |
| F-C09 | Global footer | Marketing shell | Implemented |
| F-L01 | Hero | `/` `#hero` | Implemented |
| F-L08 | How it works | `/` `#how` | Implemented |
| F-L03 | Nothing Phone 1 scroll tour (replaces feature grid) | `/` `#features` | Implemented |
| F-L04 | Comparison table | `/` `#compare` | Implemented |
| F-L05 | Pro pricing | `/` `#pricing` | Implemented |
| F-L02 | Trust strip | `/` `#trust` | Implemented |
| F-L06 | FAQ | `/` `#faq` | Implemented |
| F-L07 | Final CTA band | `/` `#download` | Implemented |
| F-A01 | Web authentication | `/app`, OAuth | Implemented |
| F-A02 | App shell | `/app/*` chrome | Implemented |
| F-A03 | Overview (read-only) | `/app` | Implemented |
| F-A04 | Groups (read-only) | `/app/groups` | Implemented |
| F-A05 | Friends (read-only) | `/app/friends` | Implemented |
| F-A06 | Account (read-only) | `/app/account` | Implemented |
| F-A07 | Deep link previews | `/join/*`, `/invite/*` | Implemented |
| F-I01 | SEO & document meta | All public routes | Implemented |
| F-I02 | 404 Not Found | Unmatched routes | Implemented |

**v1 post-code:** `Verified` pending §9.6 manual QA + production deploy.

**Template backfill (tick 13):** Registry + code aligned `Implemented`. F-C01, F-C08, F-C09, F-L01, F-L08 have full User Flow + motion/UIUX refs. Remaining §7 blocks inherit shared legal pattern or §12.2 — UI/UX Agent completes per-feature §12 without Product scope change.

### Shared pattern — legal / compliance pages (F-C01–F-C06)

All compliance pages share:

| Field | Value |
|-------|--------|
| **User Flow** | Entry (footer, cookie link, Play/Razorpay URL, search) → read H1 + sections → optional mailto `support@splitr.money` → exit via nav/footer |
| **Dependencies** | F-C08 Navigation, F-C09 Footer, F-C07 (cookie on public pages) |
| **Motion Requirements Reference** | Static prose; optional 200ms content fade — §11.9 |
| **UIUX Requirements Reference** | §12.2 F-C01 legal page pattern |
| **Layout** | Centred prose max-width 720px; nav + footer from F-C08/F-C09 |
| **Typography / meta** | H1 Albra; body Poppins; per-route title/description/canonical via F-I01 |
| **Operator block** | "Splitr is operated by Tanmoy Saha, an individual based in India." |
| **Physical address** | Omitted v1 until Razorpay KYC — jurisdiction India only |
| **Acceptance (shared)** | Live HTTPS; mobile-readable; WCAG AA; footer legal links work |

---

### F-C01 — Privacy Policy

| Field | Value |
|-------|--------|
| **Feature Name** | Privacy Policy page |
| **Business Objective** | Play Store + Razorpay compliance; user trust (Secondary C, E) |
| **User Objective** | Understand what data Splitr collects and how it is used |
| **Feature Description** | Public legal page describing data practices for Splitr mobile app and website. |
| **Page URL** | `https://splitr.money/privacy` |
| **Functional Behaviour** | Static content page. No forms. Nav/footer per shared pattern. Link from cookie banner, footer, registration flows (future). |
| **Content Requirements** | Sections (minimum): (1) Who we are — Splitr, Tanmoy Saha, India. (2) Data we collect — account (email, name, Google OAuth profile), financial data (groups, expenses, balances, personal transactions, loans, goals), device (contacts for friend discovery, camera for receipt OCR, biometrics for app lock), usage/analytics. (3) How we use data — provide service, sync, notifications, AI features (Gemini goal/insights when configured), fraud prevention. (4) Third parties — Supabase (auth/hosting/DB), Sentry (errors), Firebase Cloud Messaging (push), Google Sign-In, Razorpay (payments), Google Analytics 4 (website only, after cookie consent), Frankfurter (FX rates), Google ML Kit on-device OCR. (5) Data retention & deletion — account deletion process links to `/account-deletion`. (6) Security — RLS, encryption in transit. (7) Children's privacy — not directed under 13. (8) International users — India-first; data may process outside India via Supabase regions. (9) Changes to policy — last updated date. (10) Contact — `support@splitr.money`. |
| **Components** | `LegalPageLayout`, `Prose`, `TableOfContents` (optional desktop), global `Nav`, `Footer` |
| **Dependencies** | F-C08, F-C09; `app_branding.dart` URLs |
| **Context** | Source truth: `ai-docs/product-description.md` §12 integrations |
| **User Flow** | See shared legal pattern → user reads SDK/payment sections → clicks Account deletion link → `/account-deletion` |
| **Motion Requirements Reference** | Shared legal pattern — static |
| **UIUX Requirements Reference** | §12.2 F-C01 |
| **Acceptance Criteria** | (1) URL live and linked in Play Console. (2) All §12 integrations listed. (3) Account deletion cross-link works. (4) Cookie banner Privacy link targets this URL. (5) Canonical `https://splitr.money/privacy`. |
| **Recommended Implementation Order** | 1 (first compliance page) |
| **Developer Notes** | Markdown or MDX source in repo; build-time static. Env not required. |
| **Implementation Status** | Implemented |
| **Review Notes** | Dev: `/privacy` live in `apps/web`; canonical + SDK list per spec |

---

### F-C02 — Terms of Service

| Field | Value |
|-------|--------|
| **Feature Name** | Terms of Service |
| **Business Objective** | Razorpay + Play compliance |
| **User Objective** | Understand rules for using Splitr |
| **Page URL** | `https://splitr.money/terms` |
| **Functional Behaviour** | Static legal page; shared pattern. |
| **Content Requirements** | Sections: acceptance; service description (expense splitting, personal finance, lending, goals); account responsibilities; acceptable use; Pro subscription terms (₹89/mo, ₹799/yr, auto-renew via Play billing — checkout in app); payment terms (Razorpay for in-app where applicable); intellectual property; limitation of liability; indemnity; termination; governing law India; dispute resolution; changes; contact. |
| **Components** | Same as F-C01 |
| **Dependencies** | F-C08, F-C09 |
| **Acceptance Criteria** | Live URL; Razorpay dashboard field populated; footer link works. |
| **Recommended Implementation Order** | 2 |
| **Implementation Status** | Implemented |

---

### F-C03 — Refund Policy

| Field | Value |
|-------|--------|
| **Feature Name** | Refund Policy |
| **Page URL** | `https://splitr.money/refund` |
| **Functional Behaviour** | Static legal page; shared pattern. |
| **Content Requirements** | Splitr Pro refunds via Google Play refund policies; Razorpay payment disputes per RBI/razorpay rules; how to request (`support@splitr.money`); processing timeline; non-refundable cases (partial period used); India consumer law note. |
| **Acceptance Criteria** | Live URL; linked in Razorpay merchant profile and footer. |
| **Recommended Implementation Order** | 3 |
| **Implementation Status** | Implemented |

---

### F-C04 — Cancellation Policy

| Field | Value |
|-------|--------|
| **Feature Name** | Cancellation Policy |
| **Page URL** | `https://splitr.money/cancellation` |
| **Functional Behaviour** | Static legal page; shared pattern. |
| **Content Requirements** | How to cancel Splitr Pro (Google Play → Subscriptions); effect on access; no partial refunds unless Play policy; cancel account vs cancel subscription distinction; contact for help. |
| **Acceptance Criteria** | Live URL; footer + Razorpay links. |
| **Recommended Implementation Order** | 4 |
| **Implementation Status** | Implemented |

---

### F-C05 — Contact Page

| Field | Value |
|-------|--------|
| **Feature Name** | Contact |
| **Page URL** | `https://splitr.money/contact` |
| **Functional Behaviour** | Public contact page. Primary CTA: mailto `support@splitr.money`. Secondary: `contact@tanmoytssaha.cc`. Optional static form **out of scope v1** — mailto only. |
| **Content Requirements** | Support hours expectation (best-effort, India timezone); what to include in email (account email, device, issue description); links to FAQ and account deletion. |
| **Components** | `ContactCard`, mailto buttons, `Footer` |
| **Acceptance Criteria** | Both emails visible; Play Console support URL can point here; mobile tap-to-email works. |
| **Recommended Implementation Order** | 5 |
| **Implementation Status** | Implemented |

---

### F-C06 — Account Deletion

| Field | Value |
|-------|--------|
| **Feature Name** | Account Deletion instructions |
| **Page URL** | `https://splitr.money/account-deletion` |
| **Functional Behaviour** | Static instructions page; shared pattern. Describes in-app deletion path (Profile → Delete account) aligned with mobile implementation. Email alternative: request via `support@splitr.money` with verification. |
| **Content Requirements** | What data is deleted; retention exceptions (legal/logs); timeline (e.g. 30 days); link to Privacy Policy. |
| **Acceptance Criteria** | Play Console account deletion URL requirement satisfied; cross-link from Privacy Policy. |
| **Recommended Implementation Order** | 6 |
| **Implementation Status** | Implemented |

---

### F-C07 — Cookie consent (GA4)

| Field | Value |
|-------|--------|
| **Feature Name** | Cookie consent banner |
| **Business Objective** | Legal compliance for GA4 (§6.7) |
| **User Objective** | Control non-essential cookies |
| **Page URL** | All public marketing + legal pages (not `/app/*`, not `/share/*`) |
| **Functional Behaviour** | On first visit: show banner (§11.11.3). **Accept** → load GA4 (`VITE_GA4_MEASUREMENT_ID` env), persist `localStorage` consent=accepted. **Reject non-essential** → no GA4 script, persist consent=rejected. Banner hidden on return visits. Re-show only if storage cleared. **v1 events (post-consent):** `cta_install_click` + `outbound_play_store` (`location` param) on Install CTAs; `cta_sign_in_click` on Sign in; `scroll_section_view` (`section`) on hero, how, features, compare, pricing, trust, faq, download. |
| **Components** | `CookieBanner`, `Button` primary/ghost |
| **Dependencies** | F-C01 Privacy link in banner text |
| **Acceptance Criteria** | (1) GA4 does not load before Accept. (2) Preference persists. (3) `prefers-reduced-motion` honoured. (4) Privacy Policy link works. (5) Install CTA fires `cta_install_click` only after Accept. |
| **Developer Notes** | Inject GA4 only client-side after consent. Sentry on web optional v1 — if added, treat as essential/error reporting and document in Privacy Policy update. |
| **UI/UX Notes** | §11.11.3, §12.2 F-C07 |
| **Recommended Implementation Order** | 7 (with F-C08, F-C09) |
| **Implementation Status** | Implemented |

---

### F-C08 — Global navigation

| Field | Value |
|-------|--------|
| **Feature Name** | Global marketing navigation |
| **Business Objective** | Primary A install CTA always visible; Secondary B sign-in access (§6.2) |
| **User Objective** | Orient on site; reach install, sign-in, or anchor sections |
| **Description** | Sticky top bar on all marketing-layout pages (landing, legal, deep links). |
| **Page URL** | All routes under `MarketingLayout` |
| **Functional Behaviour** | Logo → `/`. Desktop: optional anchor links (Features, Pricing, FAQ). Right: Sign in (ghost) → `/app`; Install (primary) → Play Store outbound. Mobile: hamburger → drawer. Scroll: transparent → blurred bar after 48px (§11.11.1). |
| **User Flow** | Land any marketing page → see nav → (a) Install → Play Store, (b) Sign in → `/app` auth gate, (c) anchor scroll on landing, (d) hamburger on mobile |
| **Dependencies** | Brand assets; F-I01 meta on child pages |
| **Components Required** | `Nav`, `Logo`, `Button`, `HamburgerDrawer`, anchor links |
| **Acceptance Criteria** | Install + Sign in work; drawer keyboard-accessible; no layout overflow tablet/mobile |
| **Developer Notes** | Play Store URL `money.splitr.app` from `site.ts` |
| **Motion Requirements Reference** | §11.11.1 scroll blur 200ms; drawer slide §12.2 F-C08 |
| **UIUX Requirements Reference** | §11.11.1, §12.2 F-C08 |
| **Implementation Status** | Implemented |

---

### F-C09 — Global footer

| Field | Value |
|-------|--------|
| **Feature Name** | Global marketing footer |
| **Business Objective** | Compliance links + trust + secondary discovery (§6 Secondary C) |
| **User Objective** | Find legal policies, contact, product sections, Play Store |
| **Description** | Sitewide footer on marketing layout. |
| **Page URL** | All `MarketingLayout` pages |
| **Functional Behaviour** | Columns: Brand tagline | Product anchors (`#features`, `#pricing`, `#faq`, Pro) | Legal (all F-C01–C06 URLs) | Contact mailto + Play badge. Responsive stack per §11.11.2. |
| **User Flow** | Scroll to footer OR jump from legal page → pick legal link / contact / Play Store |
| **Dependencies** | F-C01–C06 routes live; `LEGAL_ROUTES` in `site.ts` |
| **Components Required** | `Footer`, `PlayStoreBadge`, link columns |
| **Acceptance Criteria** | All legal URLs resolve; support email tap-to-mail; Play badge opens store |
| **Developer Notes** | Keep URL map in `constants/site.ts` single source |
| **Motion Requirements Reference** | Static |
| **UIUX Requirements Reference** | §11.11.2, §12.2 F-C09 |
| **Implementation Status** | Implemented |

---

### F-L01 — Landing hero

| Field | Value |
|-------|--------|
| **Feature Name** | Landing hero section |
| **Business Objective** | Primary A — Play Store installs |
| **User Objective** | Understand Splitr in 5s; install app |
| **Page URL** | `https://splitr.money/` (section `#hero`) |
| **Functional Behaviour** | Above-fold block. Primary CTA → Play Store outbound (`cta_install_click` GA4 event after consent). Secondary → Sign in (`/app` or auth). Tertiary text links → `#pricing`, `/contact`, legal footer. No autoplay video v1. |
| **Content Requirements** | Headline: expense splitting + personal finance for friends/groups (India-friendly, plain English). Subhead: UPI settle, groups, goals — one line. Primary label: "Get the app" / "Install on Android". Secondary: "Sign in". Optional hero visual: app mock or abstract NeoPOP mesh — no stock photos. |
| **Components** | `Hero`, `Button` primary/ghost, `PlayStoreBadge`, `HeroPhone`, gradient mesh |
| **Dependencies** | F-C08, F-C09 |
| **Acceptance Criteria** | (1) Install CTA visible without scroll mobile. (2) Play Store opens correct package. (3) Sign in navigates to auth/app. (4) LCP target: hero text paints <2.5s on 4G. (5) Desktop: hero pin+scrub Scenes 01+02 (`useHeroScrollMotion`). (6) Reduced-motion: static exit state. |
| **User Flow** | Land `/` → read headline + subhead → primary Install OR secondary Sign in OR tertiary pricing/contact links |
| **Motion Requirements Reference** | §12.2 F-L01; `motion-library.md` §II `TL-Hero-Extended`; `useHeroScrollMotion` pin `+=200%` desktop |
| **UIUX Requirements Reference** | §12.2 F-L01 |
| **Implementation Status** | Implemented — hero is static as of tick 32; the pin moved to F-L03, and `HeroPhone` shares the tour's chassis, size and rest position so the handoff reads as one device |

---

### F-L08 — How it works

| Field | Value |
|-------|--------|
| **Feature Name** | How it works (story section) |
| **Business Objective** | Secondary E trust — explain mechanism before comparison/pricing (§3.7) |
| **User Objective** | Understand 3–4 step flow: add → split → settle |
| **Description** | Sequential steps section between hero and feature grid on landing. |
| **Page URL** | `https://splitr.money/` `#how` (or component id used in `HowItWorks`) |
| **Functional Behaviour** | 3–4 numbered steps with icon, title, one-line body. Non-interactive v1. India context: mention UPI settle in final step. |
| **User Flow** | Scroll past hero → scan steps left-to-right (desktop) or stack (mobile) → continue to features |
| **Dependencies** | F-C08, F-C09; follows F-L01 |
| **Components Required** | `HowItWorks`, step cards, icons |
| **Acceptance Criteria** | Steps factually match mobile flows; readable without interaction; section has heading for a11y |
| **Developer Notes** | Implemented as `HowItWorks.tsx` on `HomePage` |
| **Motion Requirements Reference** | §12.2 F-L08 — stagger on scroll optional; reduced-motion instant |
| **UIUX Requirements Reference** | §12.2 F-L08 |
| **Implementation Status** | Implemented |

---

### F-L02 — Trust strip

| Field | Value |
|-------|--------|
| **Feature Name** | Landing trust strip |
| **Page URL** | `https://splitr.money/` `#trust` |
| **Functional Behaviour** | Horizontal row of 3–4 factual trust items below hero. **No user counts, no fake testimonials.** Icons + short labels only. |
| **Content Requirements** | Examples: "UPI-friendly settle up", "Your data encrypted", "Free core splits", "Made for India". Verify each claim against `product-description.md`. |
| **Components** | `TrustStrip`, `Icon`, caption text |
| **Acceptance Criteria** | All claims factual; readable mobile stack or scroll; no misleading numbers. |
| **Recommended Implementation Order** | 9 |
| **Implementation Status** | Implemented |

---

### F-L03 — Nothing Phone 1 scroll tour

| Field | Value |
|-------|--------|
| **Feature Name** | Landing product tour (replaced the feature grid, tick 32) |
| **Page URL** | `https://splitr.money/` `#features` |
| **Functional Behaviour** | Desktop ≥1024px: one pinned ScrollTrigger over 2100px, `scrub: 0.6`. Four holds (Home, Groups, Lending, Profile) and three moves. Per move the phone travels edge to edge on `easeInOutCubic` while `rotY` runs a full turn on the same eased value; the front screen swaps at `rotY = π` behind the device's own back, so no crossfade is needed. Copy panels alternate sides and enter with clip-path wipes. Below 1024px or under `prefers-reduced-motion`: four stacked blocks, front-only 260px phone above its copy, one wipe on enter, back render never requested. |
| **Content Requirements** | Four beats drafted from `product-description.md` and the shipped screens. Phone screens are 1:1 HTML replicas of the Flutter UI at 411×914 dp (`components/landing/appmock/`), scaled by `--mock-scale`; content is curated marketing data, structure and typography are exact. |
| **Components** | `PhoneTourSection`, `tourBeats`, `TourCopyPanel`, `FloatingTourCards`, `PhoneChassis`, `NothingPhone1Back`, `PhoneScreenStack`, `MockCanvas` + `HomeTab`/`GroupsTab`/`LendingTab`/`ProfileTab` |
| **Developer Notes** | Back face is `/phone/nothing-phone-1-back.png` cropped to measured body bounds with five extracted glyph masks layered for bloom. All per-frame writes go through GSAP `quickSetter` and CSS custom properties — no React render during scroll. Lenis is initialised in `MarketingLayout` and synced to the GSAP ticker. |
| **Acceptance Criteria** | (1) Four screens match `apps/mobile/assets/brand/screenshots/*.png`. (2) 60fps+ through the pin. (3) No console errors. (4) Mobile stack loads no back render. (5) `#features` anchor still resolves. |
| **Motion Requirements Reference** | `motion-library.md` — clip-path entrances, no fade-ins |
| **Recommended Implementation Order** | 10 |
| **Implementation Status** | Implemented — verified in-browser 2026-07-28 at 144fps, worst frame 21ms, zero console errors |

---

### F-L04 — Comparison table

| Field | Value |
|-------|--------|
| **Feature Name** | Competitor comparison table |
| **Page URL** | `https://splitr.money/` `#compare` |
| **Functional Behaviour** | Per §6.5 and §11.11.4. 4 columns × 4–6 rows. Factual only. |
| **Content Requirements** | Rows (verified 2026-07-27 vs `product-description.md`): UPI settle (Splitr ✓), Personal finance home (✓), P2P lending (✓), Financial goals (✓), Receipt OCR Pro (✓), Offline group reads (✓ partial — Drift cache groups). Competitors: Splitwise, BillSplit, BillSplitzer — mark absent where unverified. |
| **UI/UX Notes** | §11.11.4 |
| **Recommended Implementation Order** | 11 |
| **Implementation Status** | Implemented |

---

### F-L05 — Splitr Pro pricing

| Field | Value |
|-------|--------|
| **Feature Name** | Pro pricing section |
| **Page URL** | `https://splitr.money/` `#pricing` |
| **Functional Behaviour** | Two plan cards: ₹89/month, ₹799/year. CTA → Play Store. Pro checkout in-app only (§6.1). |
| **Content Requirements** | INR only. "Subscribe in the app" disclaimer. No Razorpay checkout on web v1. |
| **Recommended Implementation Order** | 12 |
| **Implementation Status** | Implemented |

---

### F-L06 — FAQ

| Field | Value |
|-------|--------|
| **Feature Name** | FAQ accordion |
| **Page URL** | `https://splitr.money/` `#faq` |
| **Functional Behaviour** | 6–8 questions accordion. Topics: free vs Pro, data safety, account deletion, India payments, web vs app. |
| **Recommended Implementation Order** | 13 |
| **Implementation Status** | Implemented |

---

### F-L07 — Final CTA band

| Field | Value |
|-------|--------|
| **Feature Name** | Bottom install CTA |
| **Page URL** | `https://splitr.money/` `#download` |
| **Functional Behaviour** | Full-width band before footer. Repeat install CTA + Play badge. |
| **Recommended Implementation Order** | 14 |
| **Implementation Status** | Implemented |

---

### F-A01 — Web authentication (Supabase)

| Field | Value |
|-------|--------|
| **Feature Name** | Sign in / sign up |
| **Business Objective** | Secondary B — web product; Play reviewer login |
| **User Objective** | Access read-only balances on web with same account as mobile |
| **Page URL** | `https://splitr.money/app` (unauthenticated → login UI); OAuth redirect `https://splitr.money/auth/callback` |
| **Functional Behaviour** | Supabase Auth aligned with mobile: **Google OAuth** + **email/password** (sign in, sign up, forgot password email). Session persisted in browser. Unauthenticated access to `/app/*` → login screen. Successful auth → redirect to `/app` overview. **Preserve** existing `public/auth/callback/` for mobile deep link (`splitr://login-callback/`); SPA must handle web OAuth on same path without breaking app redirect — detect web vs app context (no custom scheme target on web). |
| **Components** | `AuthLayout`, `LoginForm`, `RegisterForm`, `OAuthButton` (Google), `ForgotPasswordLink` |
| **Dependencies** | Env: `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY` (same project as mobile) |
| **Developer Notes** | Play Store package: `money.splitr.app`. Callback URL must match Supabase dashboard redirect allowlist. |
| **Acceptance Criteria** | (1) Google + email login work. (2) Session survives refresh. (3) Mobile OAuth deep link still works. (4) Logout clears session. |
| **UI/UX Notes** | §11.11.5 shell after login; §12.2 F-A01 |
| **Recommended Implementation Order** | 15 |
| **Implementation Status** | Implemented |

---

### F-A02 — Authenticated app shell

| Field | Value |
|-------|--------|
| **Feature Name** | App chrome (read-only v1) |
| **Page URL** | Wrapper for `/app/*` |
| **Functional Behaviour** | Desktop: sidebar nav (Overview, Groups, Friends, Account). Mobile/tablet: top bar + bottom tabs (4 items). **Blocked-action banner** on any write affordance: "Available in the app" + Install primary + Open in app ghost (`splitr://` or intent). Sign out in Account. |
| **Components** | `AppShell`, `Sidebar`, `BottomTabBar`, `BlockedActionBanner`, `InstallCta` |
| **Dependencies** | F-A01, F-C08 brand assets |
| **UI/UX Notes** | §11.11.5 |
| **Recommended Implementation Order** | 15 (with F-A01) |
| **Implementation Status** | Implemented |

---

### F-A03 — Overview (read-only)

| Field | Value |
|-------|--------|
| **Feature Name** | Web overview / home |
| **Page URL** | `https://splitr.money/app` |
| **Functional Behaviour** | Show aggregate balance summary (you owe / you are owed), recent transactions list (groups + personal if available via API), currency INR default. **No** add transaction, edit, or settle buttons — blocked banner if user attempts. Empty state → install CTA. |
| **Data** | Supabase queries same tables as mobile Home (RLS-scoped); read-only client |
| **Acceptance Criteria** | Logged-in user sees balances matching mobile; loading/error states; no write RPCs invoked |
| **Recommended Implementation Order** | 16 |
| **Implementation Status** | Implemented |

---

### F-A04 — Groups (read-only)

| Field | Value |
|-------|--------|
| **Feature Name** | Groups list + detail |
| **Page URL** | `https://splitr.money/app/groups`, `https://splitr.money/app/groups/{groupId}` |
| **Functional Behaviour** | List user's groups. Detail: group name, members, expense list, per-member balances. Tap add expense / settle / edit → blocked banner + app deep link. |
| **Acceptance Criteria** | Group detail matches mobile read data; deep link `splitr://group/{id}` or equivalent for open-in-app |
| **Recommended Implementation Order** | 17 |
| **Implementation Status** | Implemented |

---

### F-A05 — Friends (read-only)

| Field | Value |
|-------|--------|
| **Feature Name** | Friends list + detail |
| **Page URL** | `https://splitr.money/app/friends`, `https://splitr.money/app/friends/{friendId}` |
| **Functional Behaviour** | Friend list with net balances. Detail: transaction history with friend, balance summary. Add friend / quick split → blocked + app CTA. |
| **Acceptance Criteria** | Balances match mobile; 1:1 history paginated or capped with "see all in app" |
| **Recommended Implementation Order** | 18 |
| **Implementation Status** | Implemented |

---

### F-A06 — Account (read-only)

| Field | Value |
|-------|--------|
| **Feature Name** | Account summary |
| **Page URL** | `https://splitr.money/app/account` |
| **Functional Behaviour** | Display name, email, optional Pro status badge (read-only). Edit profile, Pro manage, delete account → app CTAs. Sign out button functional. |
| **Acceptance Criteria** | Pro badge only if subscription active in DB; no subscribe flow on web |
| **Recommended Implementation Order** | 19 |
| **Implementation Status** | Implemented |

---

### F-A07 — Deep link previews

| Field | Value |
|-------|--------|
| **Feature Name** | Join / friend invite landings |
| **Page URL** | `https://splitr.money/join/{token}`, `https://splitr.money/invite/friend/{userId}` |
| **Functional Behaviour** | **Logged out:** preview card (group name or inviter name if token valid) + Install primary + Sign in secondary. **Logged in:** read-only preview (same as F-A04/F-A05 subset) + Open in app to complete join/accept. **No** join/accept mutation on web. Invalid token → friendly error + install CTA. **Logged-out name fetch:** Edge Function `preview-invite` (§9.2 tick 20). |
| **Acceptance Criteria** | App Links still resolve; web fallback works; no join RPC from web; logged-out valid `/join/{token}` shows group name; logged-out valid `/invite/friend/{id}` shows inviter name |
| **Developer Notes** | `deepLinkData.ts` calls `preview-invite` when `!userId`. Deploy function to Supabase prod before go-live QA. Rate limit 60/min/IP in function. |
| **Recommended Implementation Order** | 20 |
| **Implementation Status** | Implemented |

---

### F-I01 — Global SEO & document meta

| Field | Value |
|-------|--------|
| **Feature Name** | Sitewide SEO metadata |
| **Page URL** | All public routes |
| **Functional Behaviour** | Per-route `<title>`, `<meta name="description">`, canonical link, Open Graph (`og:title`, `og:description`, `og:url`, `og:image`), Twitter card basics. Default OG image: brand wordmark or app icon 512 from `assets/brand/play-store/app-icon-512.png`. |
| **Content Requirements** | Home title: "Splitr — Split bills, track spending, settle on UPI". Legal pages: "{Page name} — Splitr". Description ≤160 chars, India-friendly, no unverifiable claims. |
| **Acceptance Criteria** | Canonical always `https://splitr.money{path}`; no duplicate titles; OG validates in meta inspector |
| **Recommended Implementation Order** | 7 (with compliance) |
| **Implementation Status** | Implemented |

---

### F-I02 — 404 Not Found

| Field | Value |
|-------|--------|
| **Feature Name** | 404 page |
| **Page URL** | Any unmatched route (SPA) |
| **Functional Behaviour** | Marketing shell (F-C08). H1 "Page not found". Body + Home CTA + Install CTA. HTTP 404 on server where Vercel supports; client route fallback acceptable for SPA. |
| **UI/UX Notes** | §11.9 404 pattern |
| **Recommended Implementation Order** | 7 |
| **Implementation Status** | Implemented |

---

## 8. Recommended implementation order (draft — revise after discovery)

Aligned with Primary A + Secondary C (compliance cannot wait for motion polish):

1. **Compliance pages** — privacy, terms, refund, cancellation, account deletion, contact (live URLs for Play + Razorpay)
2. **Minimal credible landing** — hero with install CTA, trust strip, footer legal links (enough for Razorpay website verification)
3. **Full landing sections** — feature grid, comparison, FAQ, Pro overview, SEO metadata
4. **Landing motion polish** — §8.1 spec; **partial implementation tick 16** (GSAP); full **Verified** after deploy QA

### 8.1 Landing motion polish spec (UI/UX tick 14; implementation tick 16)

**Scope:** Visual craft only. No new features. Honour `prefers-reduced-motion` everywhere.

| Section | Animation | Trigger | Duration / easing | Mobile alt |
|---------|-----------|---------|-------------------|------------|
| Hero H1/subhead/CTAs | fade + translateY 16px→0 | load | 500ms; stagger 80ms | instant if reduced-motion |
| Hero mesh | slow opacity drift loop | load | 20s linear infinite | static gradient only |
| F-L08 steps | fade-up stagger | 20% viewport | 400ms; 60ms stagger | instant |
| F-L02 trust | fade-in row | 20% viewport | 300ms; 60ms/item | instant |
| F-L03 features | fade-up cards | 20% viewport | 400ms; 80ms stagger | single 400ms fade |
| F-L04 compare rows | fade-in | 20% viewport | 400ms; 80ms/row | card stack fade |
| F-L06 FAQ | expand/collapse height | click | 250ms ease-out | instant toggle |
| F-L07 final CTA | subtle scale on CTA hover | hover | 150ms | none |

**Performance:** CSS transforms + opacity only; no R3F v1.1; `will-change` sparingly; pause off-screen animations via `IntersectionObserver`.

**GA4:** `scroll_section_view` on all landing sections — shipped tick 22.

**Acceptance:** Lighthouse performance score ≥90 mobile; no layout shift from animations; reduced-motion = zero motion.

**Implementation status (tick 24):** §8.1 landing motion **code complete** — GSAP scroll sections, `useHeroCopyMotion`, hero mesh `meshDrift` 20s in `HeroVisual.module.css` (disabled under `prefers-reduced-motion`). Post-deploy Lighthouse + reduced-motion QA before marking motion **Verified**.

5. **Auth foundation** — Supabase sign-in aligned with mobile
6. **Authenticated web v1 (read-only)** — auth + overview, groups, friends; action CTAs → app
7. **Authenticated web v2** — write flows, lending, goals, etc. (backlog)

---

## 9. Coordination

| Agent | Role |
|-------|------|
| Product Agent | Requirements, acceptance criteria, scope, functional behaviour |
| UI/UX Agent (§11–§12) | Visual system, motion spec, component visuals, per-feature UI/UX Details |
| Developer Agent | Implementation per documented features |

**Developer stop rule:** If feature spec missing or ambiguous → stop and escalate to Product Agent.  
**UI/UX stop rule:** If product requirement unclear → escalate to Product Agent; never change scope.

### 9.1 Developer Agent status (2026-07-27)

| Field | Value |
|-------|--------|
| **Implementation Status** | **Complete (v1 code)** — F-I01 OG + F-I02 404 done; deploy + QA pending |
| **Code touched** | `apps/web` — `usePageMeta` OG/Twitter tags, `NotFoundPage`, `public/og-image.png` |
| **Baseline verified** | `apps/web/` = Vite 8 + React 19 starter; `public/share/`, `public/auth/callback/`, `public/.well-known/` preserved |

| **Review Notes (Developer Agent):** Tick 11 — F-I01: `usePageMeta` sets og:* + twitter:* per route; default `og-image.png` (512 app icon). F-I02: `NotFoundPage` + marketing `path="*"` catch-all. Home title aligned to spec. v1 feature code complete. |

**Blocked on Product Agent:** None — full v1 scope specified (F-C, F-L, F-A).

**Play Store outbound URL (all install CTAs):** `https://play.google.com/store/apps/details?id=money.splitr.app`

**Blocked on UI/UX Agent:** None for compliance batch — §11.11 + §12.2 cover chrome.

**Build / deploy notes (Product answer):**
| Item | Value |
|------|--------|
| Monorepo package | `apps/web` (`pnpm --filter web`) |
| Build | `make web-build` or `pnpm --filter web build` |
| Output | `apps/web/dist` |
| Host | Vercel; root `apps/web` or monorepo with root directory `apps/web` |
| Canonical | `https://splitr.money` |
| Env v1 | `GA4_MEASUREMENT_ID` (optional until F-C07) |

### 9.2 Agent questions — Product answers (2026-07-27)

| Agent | Question | Product answer |
|-------|----------|----------------|
| Developer | Vercel root / build command? | `apps/web`; `pnpm --filter web build`; output `dist`. See §9.1 table. |
| Developer | Cookie banner — Accept only or Reject too? | **Both.** Reject = no GA4 load. Accept = GA4 after consent. §F-C07. |
| Developer | Albra web font license? | **Verify commercial web embedding** before prod. Self-host WOFF2 per §11.3. If license blocks, use wordmark SVG + Poppins-only body until resolved. |
| Developer | Sentry on web v1? | **Optional v1.** If shipped, classify as error monitoring in Privacy Policy; not blocked on cookie banner (essential/functional). Document in F-C01 if added. |
| UI/UX | Social proof / testimonials? | **No fabricated content v1.** Trust strip: factual icons (UPI, privacy, free core splits). No user counts or fake quotes. §6.9. |
| UI/UX | Hindi v1? | **No.** EN only. §6.3. |
| UI/UX | Physical address on legal pages? | **Omitted v1.** "India" jurisdiction text only. Update policies when Razorpay KYC address confirmed. |
| UI/UX | Razorpay required page list? | **Assumed set:** privacy, terms, refund, cancellation, contact — all in §6.8. Confirm in Razorpay dashboard before merchant go-live. |
| UI/UX | Legal page visual pattern? | Shared prose layout §7 shared pattern + §12.2 F-C01. |
| Product | IA / URL structure approval? | Documented §6.9 — proceed unless user objects. |
| Developer | Footer links 404 for terms/refund/etc.? | **Resolved** — F-C02–F-C06 shipped tick 3. |
| Developer | GA4 not loading after Accept? | **Resolved** tick 4 — `lib/analytics.ts` loads gtag on Accept when `VITE_GA4_MEASUREMENT_ID` set. |
| Developer | `/app` placeholder OK for staging? | **Resolved** — F-A01 live; stubs OK until F-A03 data. |
| Developer | `vercel.json` rewrites? | **Correct** — preserves `share/`, `auth/`, `.well-known/`. |
| Developer | Env var naming? | `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`; optional `VITE_GA4_MEASUREMENT_ID`. |
| Developer | OAuth callback path? | **Web:** Supabase redirect → `/auth/callback` (static bridge) → `/app/oauth/callback` when `splitr_oauth_context=web`. **Mobile:** same static file → `splitr://login-callback/`. Add both URLs to Supabase redirect allowlist. |
| Developer | F-I01 OG tags — what exactly? | Per §F-I01: `og:title`, `og:description`, `og:url`, `og:image` (512 app icon or wordmark URL on `splitr.money`), `twitter:card` summary_large_image. Set per route via meta helper. |
| Developer | 404 route pattern? | Catch-all `path="*"` under marketing shell → `NotFoundPage` per §F-I02 + §11.9. |
| Developer | F-A07 logged-out preview name? | **Option A (tick 20):** Supabase Edge Function `preview-invite` — input `token` or `friendUserId`; returns `{ kind, name, valid }` only; rate-limited; no member list. Web calls when `!userId`. §F-A07 + §12.2 tick 19 spec. |
| Developer | Deploy `preview-invite` to Supabase? | **Required for prod QA (tick 21).** `supabase functions deploy preview-invite` — web `deepLinkData.ts` already invokes it. |
| Developer | Mobile mesh animation `<768px`? | **Resolved tick 26.** `HeroVisual.module.css` — `animation: none` on `.mesh`/`.wrap` at `max-width: 767px`. |

### 9.3 Implementation gap audit (`apps/web` vs §7 — 2026-07-27 tick 52)

| Feature | Spec | Code | Notes |
|---------|------|------|-------|
| F-C*, F-L*, F-C07 | §7 | **Done** | Full `scroll_section_view`; F-L05 annual-first mobile |
| F-A01–A07 | §7 | **Done** | F-A07 `preview-invite` logged-out path |
| F-I01 SEO | §7 | **Done** | OG + Twitter in `usePageMeta`; `DEFAULT_OG_IMAGE` |
| F-I02 404 | §7 | **Done** | `NotFoundPage`, `noIndex`, Home + Install CTAs |
| §8.1 motion | §8.1 | **Done (code)** | Mesh drift + copy stagger in repo; **Verified** after deploy QA |

**v1 §7 code gap:** 0.

**Next:** Deploy `preview-invite` + Vercel `splitr.money` + §9.5 env → §9.4 URLs → §9.6/§9.7 QA → `Verified`.

**Tick 52:** Gap 0. Idle. §9.8 deploy sole gate. **Product loop: stop until deploy** (no doc churn on idle ticks).

### 9.5 Vercel production env (go-live)

| Variable | Required | Purpose |
|----------|----------|---------|
| `VITE_SUPABASE_URL` | Yes (auth web) | Same project as mobile |
| `VITE_SUPABASE_ANON_KEY` | Yes | Public anon key |
| `VITE_GA4_MEASUREMENT_ID` | Recommended | Analytics after cookie Accept |

Root directory: `apps/web`. Custom domain: `splitr.money`. Supabase redirect URLs: `https://splitr.money/auth/callback`.

### 9.6 v1 manual QA gate (before marking §7 Verified)

| # | Check |
|---|--------|
| 1 | All §9.4 URLs live on HTTPS |
| 2 | Cookie Reject → no GA4 network requests |
| 3 | Cookie Accept → GA4 loads (when env set) |
| 4 | Google + email sign-in; session persists on refresh |
| 5 | Overview balances match mobile test account |
| 6 | Group + friend balances match mobile |
| 7 | `/join/{valid}` logged out → **group name** in preview + install CTA; `/invite/friend/{valid}` → **inviter name**; logged in member → web group/friend link; requires `preview-invite` deployed |
| 8 | `/share/*` recap reader still works |
| 9 | Mobile OAuth still opens app via `/auth/callback` |
| 10 | Footer legal links + Play Store outbound |

### 9.7 Visual QA checklist (UI/UX — post-deploy)

Run against §12.2 Acceptance Criteria after `splitr.money` is live. Complements §9.6 functional QA.

| Area | Check |
|------|-------|
| Tokens | Dark bg `#0D0D0D`; accent `#00FF88`; no light-mode bleed |
| Nav | Install visible @390px; scroll blur after 48px; drawer Escape closes; **focus trap while drawer open** (§12.2 F-C08) |
| Hero | Install CTA above fold mobile; mesh static on reduced-motion; mesh animation desktop-only per §8.1 — mobile static is P3 CSS polish, not QA blocker |
| Landing | All `#` anchors scroll (hero, how, features, compare, pricing, trust, faq, download) |
| Footer | 5 legal + 4 product links; Play Store opens correct package |
| Legal | Prose readable 320px; skip-link works |
| Cookie | Accept/Reject persist; banner not shown on return visit |
| Auth | Google + email flows; error states visible |
| App shell | Sidebar desktop; bottom tabs mobile; blocked-action banner on write surfaces |
| Overview | Balance cards 2-col; +/- prefix; empty Install CTA |
| Deep links | Logged-out install CTA; logged-in read-only preview |
| OG | Facebook Debugger + Twitter Card pass on `/` and `/privacy` |
| 404 | Unknown route shows marketing 404; Home + Install work |
| Motion (§8.1) | Landing scroll sections animate on desktop; `prefers-reduced-motion` = no GSAP; Lighthouse mobile ≥90; no layout shift from animations |

**Open content:** physical address in policies when Razorpay KYC supplies.

### 9.8 Go-live sequence (Product tick 26)

Ordered checklist — v1 §7 stays `Implemented` until §9.6 passes; then mark `Verified`.

| Step | Action | Owner |
|------|--------|-------|
| 1 | `make web-build` — confirm `apps/web/dist` clean | Developer |
| 2 | `supabase functions deploy preview-invite` (prod project) | Developer |
| 3 | Vercel: new/import project, root `apps/web`, output `dist` | Tanmoy |
| 4 | Vercel env: `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`, `VITE_GA4_MEASUREMENT_ID` (optional) | Tanmoy |
| 5 | Custom domain `splitr.money` + `www` → apex redirect | Tanmoy |
| 6 | Supabase Auth → redirect URLs: `https://splitr.money/auth/callback` | Tanmoy |
| 7 | Smoke: §9.4 URLs on HTTPS | Tanmoy |
| 8 | §9.6 functional QA (10 checks) | Tanmoy |
| 9 | §9.7 visual QA + Lighthouse mobile ≥90 | Tanmoy / UI/UX |
| 10 | Play Console + Razorpay dashboards → §9.4 URLs | Tanmoy |
| 11 | Update §7.1 registry rows to `Verified` | Product |

**Parallel tracks (do not block v1):** `creative-direction.md` scroll-story rebuild = post-v1; §11.12 P3 polish.

### 9.4 Play Console / Razorpay URL checklist (ready when deployed)

| Requirement | URL |
|-------------|-----|
| Privacy policy | `https://splitr.money/privacy` |
| Account deletion | `https://splitr.money/account-deletion` |
| Terms | `https://splitr.money/terms` |
| Refund | `https://splitr.money/refund` |
| Cancellation | `https://splitr.money/cancellation` |
| Contact / support | `https://splitr.money/contact` |
| Website (merchant) | `https://splitr.money` |

**Open:** physical address in policy body when KYC supplies it.

---

## 10. Changelog

| Date | Change |
|------|--------|
| Initial discovery scaffold — research summary, page inventory, open questions |
| 2026-07-27 | UI/UX Agent: design system foundation (§11), feature UI/UX template (§12) |
| 2026-07-27 | Resolved business goals: Primary A (installs), Secondary B+C+E; hero CTA hierarchy |
| 2026-07-27 | Legal operator confirmed: Tanmoy Saha; brand Splitr on policies |
| 2026-07-27 | Hosting: Vercel; canonical domain splitr.money (not splitr.app) |
| 2026-07-27 | UI/UX loop tick 70: loop milestone — idle re-audit, no drift |
| 2026-07-27 | UI/UX loop tick 60: loop milestone — idle re-audit, no drift |
| 2026-07-27 | UI/UX loop tick 57: idle re-audit — no drift |
| 2026-07-27 | UI/UX loop tick 56: idle re-audit — no drift |
| 2026-07-27 | UI/UX loop tick 55: idle re-audit — no drift |
| 2026-07-27 | UI/UX loop tick 54: idle re-audit — no drift |
| 2026-07-27 | UI/UX loop tick 53: idle re-audit — no drift |
| 2026-07-27 | UI/UX loop tick 52: idle re-audit — no drift |
| 2026-07-27 | UI/UX loop tick 51: idle re-audit — no drift |
| 2026-07-27 | UI/UX loop tick 50: loop milestone — idle re-audit, no drift |
| 2026-07-27 | UI/UX loop tick 49: idle re-audit — no drift |
| 2026-07-27 | UI/UX loop tick 48: idle re-audit — no drift |
| 2026-07-27 | UI/UX loop tick 47: idle re-audit — no drift |
| 2026-07-27 | UI/UX loop tick 46: idle re-audit — no drift |
| 2026-07-27 | UI/UX loop tick 45: idle re-audit — no drift |
| 2026-07-27 | UI/UX loop tick 44: idle re-audit — no drift |
| 2026-07-27 | UI/UX loop tick 43: idle re-audit — no drift |
| 2026-07-27 | UI/UX loop tick 42: idle re-audit — no drift |
| 2026-07-27 | UI/UX loop tick 41: idle re-audit — no drift |
| 2026-07-27 | UI/UX loop tick 40: loop milestone — idle re-audit, no drift |
| 2026-07-27 | UI/UX loop tick 39: idle re-audit — no drift |
| 2026-07-27 | UI/UX loop tick 38: idle re-audit — no drift |
| 2026-07-27 | UI/UX loop tick 37: idle re-audit — no drift |
| 2026-07-27 | UI/UX loop tick 36: idle re-audit — no drift |
| 2026-07-27 | UI/UX loop tick 35: idle re-audit — no drift |
| 2026-07-27 | UI/UX loop tick 34: idle re-audit — no drift |
| 2026-07-27 | UI/UX loop tick 33: idle re-audit — no drift; deploy gate only |
| 2026-07-27 | UI/UX loop tick 32: idle re-audit — no drift; §11.12 warning/Albra/P4 only |
| 2026-07-27 | UI/UX loop tick 31: `FriendList` empty → `styles.empty` cleared; last detail P3 done |
| 2026-07-27 | UI/UX loop tick 30: milestone idle re-audit — no drift; `FriendList` empty inline only P3 left |
| 2026-07-27 | Developer: F-L01 hero extended scroll — `useHeroScrollMotion`, `HeroScrollStage`, `HomeScreenMock`, storyboard phased copy (Scenes 01+02) |
| 2026-07-27 | UI/UX loop tick 29: detail pages → `DetailPage.module.css` cleared; FriendList empty inline remains |
| 2026-07-27 | UI/UX loop tick 28: idle re-audit — no drift; FriendList empty inline vs GroupList CSS noted |
| 2026-07-27 | UI/UX loop tick 27: `ErrorCard` P3 cleared; F-A05 empty Install verified; §11.12 thinned |
| 2026-07-27 | UI/UX loop tick 26: P3 re-audit — footer PlayStoreBadge, groups empty Install, hero mobile mesh static cleared |
| 2026-07-27 | UI/UX loop tick 25: P3 re-audit — TrustIcon + FeatureIcon cleared; PlayStoreBadge partial; hero mobile mesh spec gap |
| 2026-07-27 | UI/UX loop tick 24: §8.1 hero motion code complete verified — mesh drift was already in CSS |
| 2026-07-27 | UI/UX loop tick 23: F-L01 hero copy stagger verified (`useHeroCopyMotion`); mesh drift still P3 |
| 2026-07-27 | UI/UX loop tick 22: P2 cleared — pricing annual-first mobile + full `scroll_section_view` |
| 2026-07-27 | UI/UX loop tick 21: F-A07 logged-out preview UI verified — §7 gap 0; P1 cleared from backlog |
| 2026-07-27 | UI/UX loop tick 20: F-A07 Option A UI acceptance locked; Product decision synced |
| 2026-07-27 | UI/UX loop tick 19: F-A07 logged-out preview unblock spec; no code drift — deploy QA blocked on splitr.money |
| 2026-07-27 | UI/UX loop tick 18: F-C08 focus trap verified — matches tick 17 spec; §11.12 P1 nav cleared |
| 2026-07-27 | UI/UX loop tick 17: F-L01 HeroVisual review; F-C08 focus trap spec for Developer; §9.7 nav QA row |
| 2026-07-27 | UI/UX loop tick 16: §8.1 motion implementation review; F-L08 `id="how"` resolved; §11.12 sync |
| 2026-07-27 | UI/UX loop tick 15: F-L06 FAQ re-review — aria-controls + 250ms expand resolved; §11.12 sync |
| 2026-07-27 | UI/UX loop tick 14: §8.1 motion spec; re-audit GA4 tracking resolved; §11.12 backlog sync |
| 2026-07-27 | UI/UX loop tick 13: F-C09 footer + F-L08 how-it-works §12.2; §12.3 coverage index; §9.7 visual QA |
| 2026-07-27 | UI/UX loop tick 12: F-I01/F-I02 review; §11.12 v1 polish backlog — v1 code complete |
| 2026-07-27 | Product loop: discovery complete; §6.9 IA; §7 F-C01–F-C08 compliance specs; §9.2 agent Q&A; §12.2 legal + cookie UI/UX; Developer unblocked for compliance |
| 2026-07-27 | Product loop: §7 F-L01–F-L07 landing sections specified; U5 resolved; cookie banner Q resolved in §11.11.3 |
| 2026-07-27 | Developer loop tick 11: F-I01 OG/Twitter meta + F-I02 404 page |
| 2026-07-27 | Developer loop tick 10: F-A07 join + friend invite previews |
| 2026-07-27 | Developer loop tick 9: F-A06 account page polish |
| 2026-07-27 | Developer loop tick 8: F-A05 friends list + detail |
| 2026-07-27 | Developer loop tick 7: F-A04 groups list + detail |
| 2026-07-27 | Developer loop tick 6: F-A03 overview balances + transactions |
| 2026-07-27 | Developer loop tick 5: F-A01 auth + F-A02 app shell |
| 2026-07-27 | Developer loop tick 4: F-L01–F-L07 landing sections; GA4 on cookie accept |
| 2026-07-27 | Product loop tick 3: §7 F-I01 SEO + F-I02 404; §9.3 gap audit; Developer Q&A footer 404s + env vars |
| 2026-07-27 | Product loop tick 4: §9.3 updated — compliance done; GA4 injection gap flagged; §9.4 Play/Razorpay URL checklist |
| 2026-07-27 | Product loop tick 5: §9.3 — landing F-L01–L07 done; GA4 fixed; OG/404/auth remain |
| 2026-07-27 | Product loop tick 6: §9.3 — F-A01/A02 done; F-A03–A06 stubs; OAuth bridge documented in §9.2 |
| 2026-07-27 | Product loop tick 7: §9.3 — F-A03 overview data shipped; F-A04/A05 still stubs |
| 2026-07-27 | Product loop tick 8: §9.3 — F-A04 groups list + detail done; F-A05 still stub |
| 2026-07-27 | Product loop tick 9: §9.3 — F-A05 friends done; v1 read-only core complete except deep links + infra |
| 2026-07-27 | Product loop tick 10: §9.3 — F-A06 done (Pro badge); 3 gaps left: deep links, OG, 404 |
| 2026-07-27 | Product loop tick 11: §9.3 synced — F-A07 done; §9.5 Vercel env; §9.6 QA gate; 2 gaps remain |
| 2026-07-27 | Product loop tick 12: §9.3 — F-I01 + F-I02 done; v1 code complete; deploy + QA gate |
| 2026-07-27 | Product Agent: §7 realigned to mandatory template; F-C08/F-C09 split; F-L08 registry; §3.5–3.7 research |
| 2026-07-27 | Product loop tick 13: §7 status synced Implemented; template backfill note for UI/UX §12 |
| 2026-07-27 | Product loop tick 14: §9.3 re-audit — gap 0; §9.6 target `Verified`; UI/UX §12.3 aligned |
| 2026-07-27 | Product loop tick 15: F-C07 GA4 event catalog; §8.1 motion scoped post-v1; gap 0 |
| 2026-07-27 | Product loop tick 16: §9.3 re-audit gap 0; UI/UX F-L06 FAQ polish acknowledged |
| 2026-07-27 | Product loop tick 17: §8.1 partial GSAP motion acknowledged; §9.7 motion QA row; §7 gap 0 |
| 2026-07-27 | Product loop tick 18: F-C08 focus trap verified; §11.12 P1 cleared; gap 0 |
| 2026-07-27 | Product loop tick 19: re-audit gap 0; splitr.money deploy not live; idle until QA |
| 2026-07-27 | Product loop tick 20: F-A07 logged-out preview — Option A Edge Function; §7 gap 1 |
| 2026-07-27 | Developer loop tick 21: `preview-invite` Edge Function + F-A07 `deepLinkData` logged-out path |
| 2026-07-27 | Product loop tick 21: F-A07 gap closed in code; §7 gap 0; deploy Supabase fn + Vercel pending |
| 2026-07-27 | Product loop tick 22: UI/UX F-A07 UI verified; §9.6 #7 names; gap 0; deploy pending |
| 2026-07-27 | Product loop tick 23: UI/UX P2 cleared; hero copy stagger; §8.1 mesh drift only; gap 0 |
| 2026-07-27 | Product loop tick 24: §8.1 code complete (mesh drift in CSS); gap 0; deploy only blocker |
| 2026-07-27 | Product loop tick 25: idle re-audit gap 0; §9.7 mobile mesh verify note; deploy blocked |
| 2026-07-27 | Product loop tick 26: §9.8 go-live sequence; mobile mesh P3; creative-direction = post-v1 |
| 2026-07-27 | Product loop tick 27: UI/UX P3 polish verified in code; gap 0; deploy blocked |
| 2026-07-27 | Product loop tick 28: UI/UX tick 27 ErrorCard verified; gap 0; deploy blocked |
| 2026-07-27 | Product loop tick 29: idle re-audit gap 0; FriendList empty CSS micro P3 noted |
| 2026-07-27 | Product loop tick 30: UI/UX detail CSS cleared; loop milestone; gap 0; deploy blocked |
| 2026-07-27 | Product loop tick 31: FriendList empty CSS cleared; §11.12 thinned; gap 0 |
| 2026-07-27 | Product loop tick 32: idle re-audit gap 0; UI/UX tick 31 synced; deploy blocked |
| 2026-07-27 | Product loop tick 33: idle re-audit gap 0; no drift; deploy blocked |
| 2026-07-27 | Product loop tick 34: idle re-audit gap 0; deploy blocked |
| 2026-07-27 | Product loop tick 35: idle re-audit gap 0; deploy blocked |
| 2026-07-27 | Product loop tick 36: idle re-audit gap 0; deploy blocked |
| 2026-07-27 | Product loop tick 37: idle re-audit gap 0; deploy blocked |
| 2026-07-27 | Product loop tick 38: idle re-audit gap 0; deploy blocked |
| 2026-07-27 | Product loop tick 39: idle re-audit gap 0; deploy blocked |
| 2026-07-27 | Product loop tick 40: loop milestone; idle gap 0; deploy blocked |
| 2026-07-27 | Product loop tick 41: idle re-audit gap 0; deploy blocked |
| 2026-07-27 | Product loop tick 42: idle re-audit gap 0; deploy blocked |
| 2026-07-27 | Product loop tick 43: idle re-audit gap 0; deploy blocked |
| 2026-07-27 | Product loop tick 50: loop milestone (50 ticks); idle gap 0; deploy blocked |

---

## 11. UI/UX Design System (foundation)

> **Status:** Foundation + per-feature specs in §12.2. Sync with §7 as Product adds features.  
> **Source of truth for tokens:** `apps/mobile/lib/Constants/constants.dart`, `app_palette.dart`, brand assets under `apps/mobile/assets/brand/`.

### 11.1 Brand personality

| Trait | Expression on web |
|-------|-------------------|
| NeoPOP fintech | Dark canvas, neon accent pops, high contrast — not flat corporate blue |
| India-first | ₹ formatting, UPI/Razorpay trust cues, readable at low bandwidth |
| Premium but approachable | Motion signals quality; copy stays plain; no stock-photo fintech cliché |
| Mobile continuity | Web feels like Splitr app extended to browser — same colours, type roles, wordmark |

### 11.2 Colour tokens (web CSS custom properties)

Map 1:1 from mobile NeoPOP palette. Light mode **out of scope** for v1 — dark-only matches app + existing `/share` reader.

| Token | Hex | Mobile source | Usage |
|-------|-----|---------------|-------|
| `--color-bg` | `#0D0D0D` | `neopopBackground` | Page background |
| `--color-surface` | `#333333` | `neopopSurface` | Cards, nav bar scrolled state |
| `--color-surface-elevated` | `#1E1E1E` | `AppPalette.cardDarkFill` | Modals, dropdowns |
| `--color-border` | `#323232` | `neopopSecondaryGrey` | Dividers, card borders |
| `--color-text` | `#FFFFFF` | `neopopOnBackground` | Primary text |
| `--color-text-muted` | `#8A8D8E` | `neopopGrey` | Secondary labels, captions |
| `--color-accent` | `#18C595` | `neopopAccent` | Primary CTA, links, focus ring |
| `--color-accent-on` | `#000000` | `neopopOnAccent` | Text on accent buttons |
| `--color-primary` | `#FE885D` | `neopopPrimary` | Secondary CTA, highlights |
| `--color-primary-on` | `#FFFFFF` | `neopopOnPrimary` | Text on primary buttons |
| `--color-success` | `#4CAF50` | `neopopSuccessBright` | Settled, positive balance |
| `--color-error` | `#C62828` | `neopopError` | Errors, destructive |
| `--color-warning` | `#E6A800` | `neopopOwe` | Owed balances, caution |
| `--color-yellow` | `#F9FE8A` | `neopopYellow` | Badges, emphasis |
| `--color-razorpay` | `#18C595` | `AppPalette.razorpayTheme` | Payment trust strip (same as accent) |

**Gradient accents** (hero mesh, section dividers — use sparingly):

| Name | Stops | Mobile source |
|------|-------|---------------|
| Share card depth | `#1A1A2E` → `#16213E` → `#0F3460` | `shareCardGradient*` |
| Onboarding flow | `#667EEA` → `#764BA2` | `onboardingPurple*` |
| Mint highlight | `#1DE9B6` | `AppPalette.mintAccent` |

**Contrast:** Body text on `--color-bg` ≥ 7:1. Muted text ≥ 4.5:1. Accent on dark bg used for large text / UI chrome only; paragraph links use `--color-accent` with underline on hover.

### 11.3 Typography

| Role | Family | Weight | Desktop size | Mobile size | Line height | Notes |
|------|--------|--------|--------------|-------------|-------------|-------|
| Display / hero | Albra | 700 | 56–64px | 40–48px | 1.05 | Headlines, wordmark adjacency |
| H1 | Albra | 600 | 48px | 36px | 1.1 | Section titles |
| H2 | Albra | 600 | 36px | 28px | 1.15 | Subsection titles |
| H3 | Poppins | 600 | 24px | 20px | 1.2 | Card titles |
| Body | Poppins | 400 | 16px | 16px | 1.5 | Paragraphs, UI labels |
| Body small | Poppins | 400 | 14px | 14px | 1.45 | Secondary copy |
| Caption | Poppins | 400 | 12px | 12px | 1.4 | Legal microcopy, badges |
| Mono / data | Courier (system fallback: `ui-monospace`) | 400 | 14–16px | 14px | 1.4 | Amounts, stats, recap-style figures |
| Button | Poppins | 600 | 16px | 16px | 1 | All caps optional — prefer sentence case |

**Font loading:** Self-host WOFF2 for Albra + Poppins (licence TBD). `font-display: swap`. Courier uses system stack on web.

**Hierarchy rule:** One Display per viewport (hero). Max two Albra headings visible without scroll. Poppins for everything functional.

### 11.4 Layout & spacing

| Token | Value | Usage |
|-------|-------|-------|
| `--container-max` | `1200px` | Marketing content |
| `--container-narrow` | `720px` | Legal / policy prose |
| `--container-app` | `1280px` | Authenticated dashboard |
| `--gutter` | `24px` (desktop), `16px` (mobile) | Horizontal padding |
| `--section-y` | `96px` (desktop), `64px` (mobile) | Between marketing sections |
| `--stack-sm` | `8px` | Tight groups |
| `--stack-md` | `16px` | Form fields, list items |
| `--stack-lg` | `24px` | Card internal padding |
| `--stack-xl` | `32px` | Between cards in grid |
| `--radius-sm` | `8px` | Chips, inputs |
| `--radius-md` | `12px` | Buttons, small cards |
| `--radius-lg` | `20px` | Feature cards (matches `/share` reader) |
| `--radius-full` | `9999px` | Pills, avatars |

**Grid:** 12-column fluid grid at ≥1024px. 8-column at 768–1023px. Single column below 768px. Gap: 24px desktop, 16px mobile.

### 11.5 Core components (design tokens — behaviour in per-feature specs)

| Component | Visual spec |
|-----------|-------------|
| **Button primary** | Bg `--color-accent`, text `--color-accent-on`, radius `--radius-md`, min-height 48px, padding 14px 24px |
| **Button secondary** | Transparent, 1px `--color-border`, text `--color-text` |
| **Button ghost** | Text `--color-accent`, no border; underline on hover |
| **Card** | Bg `--color-surface` or glass `rgba(0,0,0,0.25)` + 1px `rgba(255,255,255,0.08)`, radius `--radius-lg` |
| **Input** | Bg `--color-surface-elevated`, border `--color-border`, focus ring 2px `--color-accent` offset 2px |
| **Nav bar** | Fixed top, transparent → `--color-bg` @ 90% opacity + blur after 48px scroll |
| **Badge** | Bg `--color-yellow` at 15% opacity, text `--color-yellow`, uppercase caption |
| **Link** | `--color-accent`, underline-offset 3px, underline on hover |
| **Skeleton** | Shimmer on `--color-surface`, 1.2s ease-in-out, respects `prefers-reduced-motion` |

**Interaction defaults (all components):**

| State | Behaviour |
|-------|-----------|
| Hover | Brightness +4% or border → `--color-accent` at 35% opacity; 150ms ease |
| Pressed | Scale 0.98, 100ms ease |
| Focus | Visible 2px `--color-accent` ring, offset 2px — never remove |
| Disabled | Opacity 0.45, no pointer events |
| Loading | Spinner `--color-accent`, button label → "Loading…" or skeleton |

### 11.6 Motion design principles

Research basis: Stripe/Linear/CRED use motion to signal craft; fintech users punish gratuitous animation. Splitr web motion = **purposeful, short, GPU-friendly**.

| Principle | Rule |
|-----------|------|
| Duration | Micro: 100–150ms. UI transitions: 200–300ms. Section reveals: 400–600ms. Never >800ms for UI |
| Easing | Enter: `cubic-bezier(0.16, 1, 0.3, 1)`. Exit: `cubic-bezier(0.4, 0, 1, 1)`. Standard: `ease-out` |
| Scroll storytelling | Pin + scrub only on desktop ≥1024px; mobile gets static stack + fade-in |
| 3D / R3F | Hero only (optional); lazy-load; static poster image fallback |
| Performance | Animate `transform` + `opacity` only. No layout thrash. `will-change` sparingly |
| Reduced motion | `@media (prefers-reduced-motion: reduce)` → instant state changes, no parallax/scrub |
| Page load | Brand wordmark stroke reveal ≤1.2s, then content fade — matches app splash energy |

**Inspiration references (patterns, not copies):** Stripe gradient mesh hero, Linear sparse dark layout, CRED scroll beats, Apple product section rhythm.

### 11.7 Accessibility baseline (sitewide)

| Requirement | Spec |
|-------------|------|
| Touch targets | Min 44×44px |
| Focus order | DOM order = visual order; skip-to-content link first |
| Keyboard | All interactive elements tabbable; Escape closes modals/menus |
| ARIA | Landmarks: `header`, `main`, `footer`, `nav`; live regions for toasts |
| Screen readers | Heading hierarchy no skips; images have alt; decorative `aria-hidden` |
| Colour | WCAG 2.1 AA minimum; don't rely on colour alone for balance state (add +/- prefix) |
| Motion | Honour `prefers-reduced-motion` |

### 11.8 Responsive breakpoints

| Name | Width | Layout notes |
|------|-------|--------------|
| Mobile | `<768px` | Single column, hamburger nav, CTAs full-width |
| Tablet | `768–1023px` | 2-column grids, condensed nav |
| Laptop | `1024–1279px` | Full marketing layout, side-by-side hero |
| Desktop | `≥1280px` | Max container, scroll storytelling active |

### 11.9 Loading, empty, error (global patterns)

| Pattern | UI |
|---------|-----|
| **Initial load** | Dark bg + centred wordmark stroke animation → skeleton content blocks |
| **Route transition** | 200ms fade; no full-page spinner unless data fetch >300ms |
| **Empty state** | Illustration optional; Albra heading + Poppins body + single CTA |
| **Error** | `--color-error` border card, retry button, support link in caption |
| **404** | Same shell as marketing; hero "Page not found" + home CTA |

### 11.10 Open UI/UX questions (blocked on Product)

| # | Question | Blocks |
|---|----------|--------|
| U1 | Hero CTA priority | **Resolved** → §6.2 |
| U2 | Comparison section scope | **Resolved** → §6.5 (4-col table, 4–6 rows) |
| U3 | Authenticated web MVP scope | **Resolved** → §6.4 (read-only v1) |
| U4 | Light mode requirement | **Resolved** — dark-only v1 (§11.2) |
| U5 | Hindi / localization | **Resolved** — EN v1; Hindi backlog (§6.3, §9.2) |
| U6 | Cookie consent pattern | **Resolved** — §11.11.3 (GA4 v1 per §6.7) |

### 11.11 Global chrome (derived from §6 resolved decisions)

> Preliminary UI/UX for sitewide shells. Full §12 entries sync when Product documents matching §7 features.

#### 11.11.1 Global navigation

**Layout**
| Breakpoint | Structure |
|------------|-----------|
| Desktop (≥1024px) | Fixed bar, height 64px. Logo left. Nav links centre (optional: Features, Pricing, FAQ anchor links). Right cluster: Sign in (ghost) + Install app (primary). |
| Tablet | Same; hide centre links if overflow — move to hamburger |
| Mobile (<768px) | Logo left. Hamburger right. Drawer slides from right, full viewport height, `--color-surface-elevated` bg |

**CTA hierarchy (§6.2)**
| Control | Variant | Position |
|---------|---------|----------|
| Install app | Primary (`--color-accent`) | Nav right; sticky mobile bottom bar optional |
| Sign in | Ghost | Nav right, left of Install |
| Legal links | Text link caption | Footer only — not nav |

**Scroll behaviour:** Transparent @ top → `--color-bg` 90% + `backdrop-filter: blur(12px)` after 48px scroll. Transition 200ms ease-out.

**Components:** Logo (wordmark SVG), Button primary, Button ghost, Hamburger icon, Drawer overlay, Anchor links.

**Mobile sticky CTA bar (optional):** Fixed bottom, 56px, only on marketing pages after hero scrolls out. Install primary full-width minus gutter. `padding-bottom: env(safe-area-inset-bottom)`.

#### 11.11.2 Footer

**Layout:** `--container-max`, 4-column grid desktop (Brand | Product | Legal | Contact), 2-col tablet, stack mobile. `--section-y` top padding 64px, bottom 32px. Top border 1px `--color-border`.

**Content blocks:**
- Brand: wordmark + one-line tagline (Poppins body small, muted)
- Product: anchor links (Features, Pricing, FAQ, Pro)
- Legal: Privacy, Terms, Refund, Cancellation, Account deletion
- Contact: `support@splitr.money` mailto + Play Store badge

**Typography:** Column headings H3 Poppins 600 14px uppercase letter-spacing 0.06em muted. Links body small `--color-text-muted` → `--color-accent` on hover.

#### 11.11.3 Cookie consent banner (GA4 — §6.7)

**Layout:** Fixed bottom bar, full width, z-index above content. Inner `--container-max` flex row desktop (message left, actions right); stack mobile.

**Visual:** Bg `--color-surface-elevated`, top border 1px `--color-border`, padding 16px `--gutter`. Shadow `0 -4px 24px rgba(0,0,0,0.4)`.

**Components:** Body small text, Link (Privacy Policy), Button primary "Accept", Button ghost "Reject non-essential" (both required v1 — §F-C07).

**Behaviour:**
| State | Behaviour |
|-------|-----------|
| Entry | Slide up 300ms `cubic-bezier(0.16, 1, 0.3, 1)` from `translateY(100%)` |
| Accept | Persist preference `localStorage`, hide banner 200ms fade |
| Reject | Disable GA4 load, persist, hide |
| Focus | Trap not required; Accept button first in tab order within banner |
| Reduced motion | Instant show/hide |

**Accessibility:** `role="dialog"` `aria-label="Cookie consent"`. Contrast AA on all text.

#### 11.11.4 Comparison table (landing — §6.5)

**Layout:** `--container-max`, horizontal scroll wrapper on mobile with fade edge hint. Table min-width 640px inside scroll.

**Structure:** 4 columns (Splitr highlighted). 4–6 rows + header row. Splitr column: bg `--color-accent` at 8% fill, left border 3px `--color-accent`.

**Typography:** Header row: Poppins 600 14px. Splitr header cell: Albra 20px. Body cells: Poppins 14px. Checkmarks: `--color-success`; dashes: `--color-text-muted`.

**Components:** Table, Badge (Splitr column header "You are here" optional), Icon (check / minus).

**Responsive:** Mobile — card stack alternative: one card per competitor, Splitr card first with accent border. Switch at `<768px`.

**Animation:** Rows stagger fade-in 80ms delay each on scroll-into-view (desktop). Mobile cards: single 400ms fade. Reduced motion: no stagger.

#### 11.11.5 Authenticated web shell (read-only v1 — §6.4)

**Layout:** Sidebar + main content desktop (sidebar 240px fixed). Top bar only mobile/tablet with bottom tab bar (4 items: Overview, Groups, Friends, Account).

**Sidebar (desktop):** Bg `--color-bg`, right border `--color-border`. Logo top. Nav items 44px height, icon + label. Active: `--color-accent` left bar 3px + `--color-accent-fill-soft` bg.

**Blocked-action pattern:** Any write action surface shows inline banner — Albra H3 "Available in the app" + Poppins body + Install CTA primary + Open in app ghost deep link.

**Empty states:** Centre-aligned, max-width 400px. Install CTA always primary.

---

## 12. Feature UI/UX specifications

> **Template:** Each atomic feature in §7 gains a **UI/UX Details** subsection below (or inline) with: Layout, Typography, Spacing, Components, Component Behaviour, Animation Specification, Responsive Behaviour, Accessibility, UX Notes, Acceptance Criteria, Review Notes.  
> **Rule:** UI/UX Agent enriches only — never alters Product fields.

### 12.1 Feature UI/UX template (reference)

```markdown
#### UI/UX Details — [Feature Name]

##### Layout
- Desktop: …
- Tablet: …
- Mobile: …
- Section width / container / grid: …

##### Typography
- Heading hierarchy, weights, sizes, line heights, alignment

##### Spacing
- Section, component, padding, margins, rhythm

##### Components
- [List every UI component]

##### Component Behaviour
- Hover / Pressed / Focus / Disabled / Loading / Selected

##### Animation Specification
| Property | Value |
|----------|-------|
| Purpose | … |
| Trigger | … |
| Duration | … |
| Delay | … |
| Easing | … |
| Scroll behaviour | … |
| Entry / Exit | … |
| Reduced-motion alt | … |
| Mobile alt | … |
| Performance | … |

##### Responsive Behaviour
- Desktop / Laptop / Tablet / Mobile adaptations

##### Accessibility
- Keyboard, focus order, ARIA, contrast, reduced motion, screen readers, touch targets

##### UX Notes
- Rationale for major decisions

##### Acceptance Criteria (UI)
- Observable visual/behaviour outcomes

##### Review Notes
- Post-implementation UI/UX review (UI/UX Agent only)
```

### 12.2 Documented features

#### UI/UX Details — F-C01 Privacy Policy (legal page pattern — applies to F-C02–F-C06)

##### Layout
- Desktop: Nav + main centred column 720px max-width, 96px top padding below nav, 64px bottom before footer
- Tablet: Same; TOC collapses to inline jump links under H1
- Mobile: 16px gutter; full-width prose

##### Typography
- H1: Albra 40px/1.1 desktop, 32px mobile
- H2: Poppins 600 20px; margin-top 40px
- Body: Poppins 16px/1.65 `--color-text`
- Links: `--color-accent`, underline on hover
- Last updated: Poppins 14px `--color-text-muted`

##### Spacing
- Section rhythm: 24px between paragraphs; 40px before H2
- List items: 8px vertical gap

##### Components
- `LegalPageLayout`, `Prose`, optional `TableOfContents`, `Nav`, `Footer`

##### Component Behaviour
- TOC links: smooth scroll 400ms; active section highlight optional
- External links: open new tab with `rel="noopener"`

##### Animation Specification
| Property | Value |
|----------|-------|
| Purpose | Subtle polish |
| Trigger | Page load |
| Duration | 200ms fade-in main column |
| Reduced-motion alt | No fade |

##### Responsive Behaviour
- Prose font 15px on `<768px`

##### Accessibility
- Single H1; logical H2 order; skip-to-content; link contrast AA

##### Acceptance Criteria (UI)
- Readable without horizontal scroll; print stylesheet hides nav

##### Review Notes (2026-07-27)
- **Pass:** Layout, prose scale, skip-link, print hide, canonical meta, last-updated line
- **Defer OK:** Albra → Poppins per §9.2
- **Minor:** Optional desktop TOC not built — acceptable v1
- **Polish:** H1 uses Poppins 2.5rem not Albra 40px — revisit when Albra licensed

##### Review Notes — F-C02–F-C04, F-C06 batch (2026-07-27, tick 4)
- **Pass:** All routes live (`/terms`, `/refund`, `/cancellation`, `/account-deletion`); shared `LegalPageLayout` + `usePageMeta` canonicals; operator line + support email; footer links resolve
- **Pass:** Account deletion numbered steps readable; cross-links to Privacy
- **Polish:** Consistent `PRIVACY_LAST_UPDATED` date across policies — confirm intentional single date vs per-page dates

---

#### UI/UX Details — F-C05 Contact

Extends legal page pattern with contact cards.

##### Layout
- Shared `LegalPageLayout` prose column
- Below intro copy: 2-column card grid desktop, stack mobile
- Card: `--color-surface-elevated`, `--radius-md`, 24px padding, 1px `--color-border`
- Helpful links section: standard prose list below cards

##### Typography
- Card H2: Poppins 600 18px
- Card body: Poppins 15px muted
- Mailto buttons: primary (Support) + ghost (General)

##### Spacing
- Cards grid gap 24px; margin 32px top / 40px bottom before next H2

##### Components
- `ContactCard` ×2, `Button` mailto links, prose list

##### Accessibility
- Mailto buttons have accessible names matching email address; tap-to-email on mobile

##### Acceptance Criteria (UI)
- Both emails visible as tappable CTAs; FAQ + account deletion links present

##### Review Notes (2026-07-27, tick 4)
- **Pass:** 2-card layout matches spec; Support primary + General ghost; mailto works; helpful links section
- **Minor:** FAQ link points to `/#faq` — section not built yet (F-L06); OK until landing complete

---

#### UI/UX Details — F-C07 Cookie consent

Sync with §11.11.3. Product confirms **Accept + Reject non-essential** both required v1.

##### Acceptance Criteria (UI)
- Banner visible on first visit only; Privacy link in message body; buttons meet 44px touch target mobile

##### Review Notes (2026-07-27)
- **Pass:** Accept + Reject, Privacy link, slide-up entry, reduced-motion off, 48px buttons
- **Pass (tick 5):** GA4 loads only on Accept via `storeConsent` + `loadGa4`; returning visitors re-hydrate on mount

##### Review Notes (2026-07-27, tick 4)
- **Resolved:** GA4 gating implemented in `lib/analytics.ts`

##### Review Notes (2026-07-27, tick 5)
- **Resolved (tick 14):** `cta_install_click` wired via `trackInstallClick` on nav, hero, footer, pricing, final CTA; `scroll_section_view` on all landing sections including how/trust/download (tick 22)

---

#### UI/UX Details — F-A01 / F-A02 Auth + app shell

See expanded specs below: **F-A01** (auth), **F-A02** (shell). Implemented 2026-07-27.

##### Review Notes (2026-07-27, tick 6)
- **F-A01 pass:** 400px card, logo above, Google OAuth full-width, sign-in/sign-up tabs, forgot password, `role="alert"` errors, 200ms card fade
- **F-A02 pass:** 240px sidebar desktop, accent left-bar active state, 4 bottom tabs mobile, top bar title, `BlockedActionBanner` on overview
- **Polish:** Bottom tabs text-only (no icons); mobile top bar duplicates logo right — optional trim
- **F-A06 partial:** Account card + sign out work; inline styles vs tokens — extract to `AccountCard` component; sign out should be ghost/danger variant per spec
- **Pending:** F-A03–F-A05 data UI not built yet

---

#### UI/UX Details — F-C08 Global marketing chrome

Sync layout/behaviour with §11.11.1 + §11.11.2. This entry = implementable acceptance layer.

##### Layout
- Desktop: Nav 64px fixed; footer min-height auto, 4-col grid inside `--container-max`
- Tablet: 2-col footer; centre nav links hidden → hamburger @ `<1024px`
- Mobile: Drawer 280px wide from right; footer single column; optional sticky install bar after hero exit (marketing pages only)

##### Typography
- Nav links: Poppins 500 15px `--color-text-muted` → `--color-text` on hover
- Footer column heads: Poppins 600 12px uppercase tracking 0.06em muted
- Footer links: Poppins 14px muted → accent on hover

##### Spacing
- Nav horizontal padding: `--gutter`; logo–link cluster gap 32px
- Footer: 64px top / 32px bottom padding; column gap 40px desktop

##### Components
- `Nav`, `Footer`, `Logo` (wordmark SVG from `assets/brand/master/`), `Button` primary + ghost, `PlayStoreBadge`, `HamburgerDrawer`, `MobileStickyCta` (optional)

##### Component Behaviour
| Component | Hover | Pressed | Focus | Loading |
|-----------|-------|---------|-------|---------|
| Install btn | brightness +4% | scale 0.98 | 2px accent ring | — |
| Sign in | underline | opacity 0.9 | ring | — |
| Play badge | opacity 0.85 | scale 0.98 | ring on wrapper | lazy-load img |
| Drawer link | bg `--color-accent-fill-soft` | — | ring | — |

##### Animation Specification
| Property | Value |
|----------|-------|
| Nav scroll solidify | 200ms ease-out bg + blur |
| Drawer open | translateX 100%→0, 300ms `cubic-bezier(0.16, 1, 0.3, 1)` |
| Drawer overlay | fade 200ms |
| Reduced-motion | Instant drawer; no blur transition |

##### Accessibility
- Skip-to-content first focusable; drawer `aria-modal`; trap focus while open; Escape closes
- Play badge alt: "Get Splitr on Google Play"

##### Acceptance Criteria (UI)
- Install visible without scroll on 390px viewport; all 6 legal footer links present; Sign in → `/app`

##### Review Notes (2026-07-27)
- **Pass:** 64px nav, scroll blur @48px, 280px drawer, Escape closes, 4-col footer, skip-link, token alignment
- **Fix:** Drawer focus trap still missing (tick 6 re-check) — **Resolved tick 18:** `useFocusTrap` in `Nav.tsx`
- **Polish:** Play badge is text link not official badge asset — swap when asset ready

##### Review Notes (2026-07-27, tick 6)
- **Resolved (tick 18):** See tick 18 review below

##### Review Notes (2026-07-27, tick 18)
- **Pass:** `useFocusTrap(drawerRef, drawerOpen)` — Tab wrap, first focusable on open, `previouslyFocused` restore on cleanup
- **Pass:** `closeDrawer` + `menuBtnRef` — explicit focus return to hamburger; `inert` on closed drawer
- **Pass:** Matches tick 17 spec steps 1–5; §9.7 nav QA row satisfied
- **Polish:** Play badge still text link — §11.12 P3

##### Review Notes (2026-07-27, tick 25)
- **Partial:** `FinalCta` ships `PlayStoreBadge`; nav + footer Install still text — wire badge or accept text v1

##### Review Notes (2026-07-27, tick 26)
- **Resolved:** Footer `PlayStoreBadge` shipped; nav keeps text `Install app` button — acceptable v1 (48px touch target)

##### Focus trap spec (tick 17 — Developer; **implemented tick 18**)

When `drawerOpen === true` on `#nav-drawer`:

| Step | Behaviour |
|------|-----------|
| 1 | Save `document.activeElement` before open |
| 2 | Move focus to first focusable in drawer (Close button) |
| 3 | Tab on last focusable → wrap to first; Shift+Tab on first → wrap to last |
| 4 | Escape or overlay click → close + restore focus to hamburger `menuBtn` |
| 5 | Focusables: Close, anchor links, Sign in, Install |

Implementation: `useFocusTrap(drawerRef, drawerOpen)` hook or `focus-trap-react` — no new dependency required if hook is ~30 lines. Test with VoiceOver/TalkBack on 390px viewport.

---

#### UI/UX Details — F-C09 Global footer

Sync layout/content with §11.11.2. Nav chrome lives in F-C08 — this entry = footer-only acceptance.

##### Layout
- Desktop: 4-column grid inside `--container-max` (Brand | Product | Legal | Contact)
- Tablet: 2-column grid
- Mobile: single-column stack
- Top border 1px `--color-border`; padding 64px top / 32px bottom; copyright row below grid

##### Typography
- Column headings: Poppins 600 12px uppercase tracking 0.06em `--color-text-muted`
- Links: Poppins 14px muted → `--color-accent` on hover
- Tagline: Poppins 14px `--color-text-muted`, max-width 280px under wordmark

##### Spacing
- Column gap: 40px desktop, 24px mobile
- List item gap: 8px vertical
- Copyright row: 24px top margin, centred, 12px caption

##### Components
- `Footer`, `Logo`, product anchor links, `Link` legal routes, mailto, `PlayStoreBadge` (or text fallback)

##### Component Behaviour
- Legal links use React Router `Link` (internal)
- Product links use hash anchors (`/#features`, `/#pricing`, `/#faq`)
- Play badge: outbound new tab `rel="noopener"`; `aria-label` "Get Splitr on Google Play"
- Mailto: `support@splitr.money` tap-to-email

##### Animation Specification
- Static — no motion v1

##### Responsive Behaviour
- `<768px`: stack columns; Play badge full-width optional

##### Accessibility
- Footer `role="contentinfo"`; column headings as H3; link lists semantic `<ul>`
- Play badge accessible name required

##### Acceptance Criteria (UI)
- All 5 legal routes resolve; 4 product anchors present; support email + Play Store outbound work; readable at 320px

##### Review Notes (2026-07-27, tick 13)
- **Pass:** 4-col grid, all legal links via `LEGAL_ROUTES`, product anchors, mailto + contact page, copyright row
- **Polish:** Play badge text link not official asset — §11.12 P3
- **Polish:** Section anchor `#how` missing on `HowItWorks` — add `id="how"` for IA consistency (F-L08)
- **Note:** Splitr Pro link duplicates `#pricing` — acceptable v1

##### Review Notes (2026-07-27, tick 26)
- **Resolved:** `PlayStoreBadge` in Contact column — `trackInstallClick('footer')`; §11.12 P3 cleared

---

#### UI/UX Details — F-L01 Landing hero

##### Layout
- Desktop: 12-col grid — copy cols 1–6, visual cols 7–12. Min-height `calc(100vh - 64px)`, max 900px. Visual right-aligned phone mock or gradient mesh
- Tablet: 50/50 stack if narrow; visual below copy
- Mobile: Single column; copy first; visual optional below fold; **Install CTA visible without scroll** (primary constraint)
- Container: `--container-max`, `--section-y` top only (hero bleeds full viewport height)

##### Typography
- Eyebrow (optional): Poppins 600 12px uppercase `--color-accent` tracking 0.08em
- Headline: Albra 56px/1.05 desktop, 40px/1.08 mobile, max-width 12ch per line break
- Subhead: Poppins 18px/1.5 desktop, 16px mobile, `--color-text-muted`, max-width 480px
- CTA row: buttons side-by-side desktop; stack full-width mobile with 12px gap

##### Spacing
- Headline → subhead: 16px
- Subhead → CTA row: 32px
- CTA row → tertiary links: 24px

##### Components
- `Hero`, `Button` primary (Install), `Button` ghost (Sign in), `PlayStoreBadge`, optional `PhoneMock`, optional `GradientMesh` (CSS/SVG — R3F deferred to motion polish phase)

##### Component Behaviour
- Primary CTA: Play Store outbound; tracks `cta_install_click` post-consent
- Secondary: `/app` route
- Tertiary text links: `#pricing`, `/contact` — caption size, muted

##### Animation Specification
| Property | Value |
|----------|-------|
| Purpose | First-impression craft without blocking LCP |
| Trigger | Page load |
| Headline | fade + translateY 16px→0, 500ms, delay 0ms |
| Subhead | same, delay 80ms |
| CTAs | same, delay 160ms |
| Visual | fade 600ms delay 200ms; mesh slow drift 20s loop (desktop only) |
| Scroll | None in hero v1 |
| Reduced-motion | All instant; static mesh |
| Performance | No R3F in v1 hero; LCP element = H1 text |

##### Responsive Behaviour
- `<768px`: hide decorative mesh animation; show static gradient bg
- Phone mock scales to max 280px width centred

##### Accessibility
- H1 is only page H1; CTAs 48px min height; decorative visual `aria-hidden`

##### UX Notes
- Install-first hierarchy per §6.2; no autoplay video; India-friendly copy without geo-gate

##### Acceptance Criteria (UI)
- LCP text paints <2.5s 4G; Install + Sign in visible mobile above fold; Play Store package correct

##### Review Notes (2026-07-27)
- **Pass:** Minimal credible hero — eyebrow, H1, subhead, Install + Sign in, min-height viewport, CTA 48px
- **Pending:** No right-column visual / mesh; no stagger entry animation; no tertiary `#pricing` links
- **Resolved (tick 14):** `cta_install_click` via `trackInstallClick`
- **Defer:** Albra headline → Poppins clamp — acceptable until font licence

##### Review Notes (2026-07-27, tick 5)
- **Pass:** 2-col hero grid desktop + CSS mesh visual; tertiary Pro pricing + Contact links; section anchors wired
- **Resolved (tick 14):** `trackInstallClick('hero')` on primary CTA
- **Partial (tick 16):** `useHeroMotion` — H1 clip-path reveal 600ms; subhead/CTA stagger from §8.1 not yet separate; mesh drift still static
- **Polish:** Phone mock not used — static gradient orb acceptable v1

##### Review Notes (2026-07-27, tick 17)
- **Pass:** `HeroVisual` — phone poster (`/hero-poster.png`) + mesh bg; `useHeroVisualTilt` desktop parallax; decorative `alt=""`
- **Pass:** `useMagneticHover` on Install CTA — desktop only, 4px max offset, disabled when reduced-motion
- **Polish:** Subhead/CTA load stagger still missing per §8.1; verify poster LCP budget on 4G
- **Note:** Magnetic hover not in original §8.1 — acceptable premium touch; disable on touch devices (already gated `@1024px`)

##### Review Notes (2026-07-27, tick 23)
- **Partial resolved:** `useHeroCopyMotion` — subtitle + CTA row + tertiary links; 500ms clip reveal, 80ms stagger, `useReducedMotion` instant
- **Corrected (tick 24):** Mesh drift present in `HeroVisual.module.css` (`meshDrift` 20s); tick 23 “static” note was stale
- **Pass:** Aligns §8.1 hero copy row spec; H1 still separate `useHeroMotion`

##### Review Notes (2026-07-27, tick 24)
- **Pass:** §8.1 hero motion **code complete** — H1 clip (`useHeroMotion`), copy stagger (`useHeroCopyMotion`), mesh drift 20s + phone float 6s (`HeroVisual.module.css`), both disabled `prefers-reduced-motion`
- **Gate:** Mark motion **Verified** only after post-deploy Lighthouse ≥90 + §9.7 reduced-motion QA

##### Review Notes (2026-07-27, tick 25)
- **Open:** §12.2 says mesh static `<768px`; `HeroVisual.module.css` has no `max-width: 768px` override — mesh still animates mobile. Dev: add media query **or** Product accepts animated mesh on mobile in §9.7

##### Review Notes (2026-07-27, tick 26)
- **Resolved:** `@media (max-width: 767px) { .wrap, .mesh { animation: none; } }` — matches §8.1 desktop-only mesh; §11.12 P3 cleared

---

#### UI/UX Details — F-L08 How it works

##### Layout
- Section `id="how"` on `<section>`; `--container-max`, `--section-y`
- Desktop: 3-step horizontal row or equal-width columns
- Mobile: vertical stack with 24px gap between steps
- Step number: 40px circle, `--color-accent-fill-soft` bg, accent numeral

##### Typography
- Section H2: Albra/Poppins 32px desktop, 28px mobile
- Step title H3: Poppins 600 18px
- Step body: Poppins 15px `--color-text-muted`

##### Spacing
- H2 → steps: 40px
- Step internal: number circle 16px right of title block

##### Components
- `HowItWorks`, numbered `<ol>`, step cards (icon optional v1)

##### Component Behaviour
- Non-interactive v1 — no click/hover states on steps
- Steps: create group → split expenses → settle UPI (India context in step 3)

##### Animation Specification
| Property | Value |
|----------|-------|
| Purpose | Progressive reveal on scroll |
| Trigger | 20% viewport intersection |
| Duration | 400ms fade-up per step |
| Delay | 60ms stagger between steps |
| Reduced-motion | Instant — all steps visible |

##### Responsive Behaviour
- `<768px`: stack; number circle left of text block

##### Accessibility
- Semantic `<ol>`; H2 `id="how-heading"`; step numbers `aria-hidden` with visible ordinals in list order

##### Acceptance Criteria (UI)
- 3–4 factual steps match mobile flows; UPI mentioned; readable without interaction; section heading for screen readers

##### Review Notes (2026-07-27, tick 5)
- **Pass:** 3 steps aligned with §6.9; semantic `<ol>`; accessible headings; UPI in step 3

##### Review Notes (2026-07-27, tick 13)
- **Pass:** Content matches Product spec; numbered circles; responsive stack
- **Resolved (tick 16):** `id="how"` on section — footer/nav anchor works
- **Pass (tick 16):** GSAP scroll motion + SVG connector graph on desktop; mobile fade-in — exceeds §8.1 stagger spec; honour reduced-motion via `useReducedMotion`
- **Polish:** No per-step stroke icons — §11.12 P3

##### Review Notes (2026-07-27, tick 22)
- **Resolved:** `useSectionView('how', 'how')` on `HomePage` — §11.12 P2 cleared

---

#### UI/UX Details — F-L02 Trust strip

##### Layout
- Desktop: 4 items in row, equal flex, centred in `--container-max`
- Mobile: 2×2 grid or horizontal scroll with 16px snap — prefer 2×2 for no scroll

##### Typography
- Label: Poppins 600 14px `--color-text`
- Sublabel (optional): Poppins 12px muted

##### Spacing
- Section padding: 48px vertical; item internal gap icon→text 12px
- Item gap: 24px desktop, 16px mobile

##### Components
- `TrustStrip`, `Icon` 24px stroke `--color-accent`, caption

##### Animation Specification
- Stagger fade-in 60ms per item on scroll-into-view; reduced-motion instant

##### Acceptance Criteria (UI)
- No numbers/testimonials; 3–4 factual items; readable at 320px width

##### Review Notes (2026-07-27, tick 5)
- **Pass:** 4 factual items, no fake stats, `#trust` anchor
- **Polish:** Emoji icons vs spec stroke icons — swap for consistent NeoPOP look
- **Note:** Placed after pricing per §6.9 scroll order — correct

##### Review Notes (2026-07-27, tick 16)
- **Pass:** `useTrustStripMotion` — icon scale stagger on scroll; `id="trust"` present

##### Review Notes (2026-07-27, tick 22)
- **Resolved:** `useSectionView('trust', 'trust')` on `HomePage`

##### Review Notes (2026-07-27, tick 25)
- **Resolved:** `TrustIcon.tsx` — 22px stroke icons in `iconWrap`; emoji removed; matches §12.2 spec
- **Pass:** `useTrustStripMotion` icon scale stagger unchanged

---

#### UI/UX Details — F-L03 Feature grid

##### Layout
- Desktop: 3×2 grid (6 cards), gap `--stack-xl`
- Tablet: 2×3
- Mobile: single column stack
- Section id `#features`; H2 centred above grid

##### Typography
- Section H2: Albra 36px centred
- Card title: Poppins 600 18px
- Card body: Poppins 14px muted, max 2 lines

##### Spacing
- Section `--section-y`
- Card padding: `--stack-lg`; icon top 24px

##### Components
- `FeatureCard` (non-clickable v1), `Icon` 32px in 48px circle bg `--color-accent-fill-soft`

##### Component Behaviour
- Cards: no hover lift v1 (static); optional subtle border brighten on hover desktop only

##### Animation Specification
- Cards: stagger fade-up 80ms, trigger 20% viewport; reduced-motion off

##### Acceptance Criteria (UI)
- Six cards per product copy; no false claims; grid collapses cleanly mobile

##### Review Notes (2026-07-27, tick 5)
- **Pass:** 6 cards, `#features`, centred H2, responsive grid
- **Polish:** No icon circles per spec — text-only cards OK v1; add icons in motion polish pass

##### Review Notes (2026-07-27, tick 16)
- **Pass:** `useFeatureGridMotion` scroll stagger shipped — aligns with §8.1

##### Review Notes (2026-07-27, tick 25)
- **Resolved:** `FeatureIcon.tsx` + `FeatureIcon.module.css` — 32px stroke in 48px `--color-accent-fill-soft` circle; §11.12 P3 cleared
- **Pass:** `useFeatureCardTilt` desktop parallax — optional polish; not in original spec

---

#### UI/UX Details — F-L04 Comparison table

Full spec: §11.11.4. Add content-visual rules:

##### Typography
- Splitr column header: Albra 20px + optional Badge "Splitr"
- Cell icons: 18px check (`--color-success`) / minus (`--color-text-muted`)

##### Acceptance Criteria (UI)
- 4 cols × 4–6 rows; mobile card fallback; horizontal scroll shows fade edge hint

##### Review Notes (2026-07-27, tick 5)
- **Pass:** 4×6 table, Splitr column highlight, mobile card stack `<768px`, `aria-label` on cells, factual disclaimer
- **Polish:** Table at 768px+ not 1024px — acceptable; no scroll fade edge (cards used on mobile instead)

##### Review Notes (2026-07-27, tick 16)
- **Pass:** `useComparisonMotion` row stagger on scroll shipped

---

#### UI/UX Details — F-L05 Splitr Pro pricing

##### Layout
- Desktop: two cards side-by-side, max-width 800px centred; annual card slightly elevated (scale 1.02 or accent border)
- Mobile: stack; annual first (better value)
- Section id `#pricing`

##### Typography
- Section H2: Albra 36px centred
- Price: Albra 48px + Poppins 16px "/month" or "/year" muted
- Disclaimer: Poppins 12px muted centred below cards

##### Spacing
- Card padding 32px; gap between cards 24px
- Feature bullet list inside card: 8px row gap

##### Components
- `PricingCard`, `Badge` "Best value" on annual, `Button` primary → Play Store, bullet list

##### Component Behaviour
- Cards: hover border `--color-accent-border` desktop
- CTA label: "Get Pro in the app"

##### Animation Specification
- Cards fade-in on scroll 400ms; no flip/count-up animations

##### Acceptance Criteria (UI)
- ₹89/mo and ₹799/yr visible; disclaimer "Subscribe in the app"; no web checkout UI

##### Review Notes (2026-07-27, tick 5)
- **Pass:** ₹89/mo + ₹799/yr, in-app disclaimer, featured annual border, Play Store CTAs, no web checkout
- **Fix:** Mobile stack shows Monthly before Yearly — spec says annual first; reorder DOM or `order` CSS

##### Review Notes (2026-07-27, tick 16)
- **Partial:** `usePricingMotion` — annual card bounce + desktop `annualBreathe` shadow loop; mobile DOM order still monthly-first — **Fix remains**
- **Note:** GSAP uses `back.out` easing — verify no CLS on low-end Android

##### Review Notes (2026-07-27, tick 22)
- **Resolved:** Mobile `.featured { order: -1 }` in `PricingSection.module.css` — annual card first on `<768px`

---

#### UI/UX Details — F-L06 FAQ accordion

##### Layout
- Single column max-width 720px centred; section id `#faq`

##### Typography
- Question: Poppins 600 16px
- Answer: Poppins 15px/1.6 muted, padding-bottom 16px

##### Components
- `Accordion`, `AccordionItem`, chevron icon 20px

##### Component Behaviour
| State | Behaviour |
|-------|-----------|
| Collapsed | Chevron right/down; answer hidden `height: 0` |
| Expanded | Chevron rotate 180°, answer slide 250ms ease-out |
| Hover | Question text → `--color-text` from muted |
| Focus | Ring on trigger button |

##### Animation Specification
- Expand/collapse 250ms ease-out; `prefers-reduced-motion`: instant toggle

##### Accessibility
- `button` triggers with `aria-expanded`; panel `aria-labelledby`; one or many open allowed

##### Acceptance Criteria (UI)
- 6–8 items; keyboard operable; only one animation at a time acceptable

##### Review Notes (2026-07-27, tick 5)
- **Pass:** 6 questions, `aria-expanded` on triggers, focus ring, privacy + deletion links
- **Polish:** First item open by default — acceptable UX

##### Review Notes (2026-07-27, tick 15)
- **Resolved:** `aria-controls` + answer `id`; 250ms grid expand/collapse; chevron rotate; `prefers-reduced-motion` disables transition; `inert` on collapsed panel

---

#### UI/UX Details — F-L07 Final CTA band

##### Layout
- Full-bleed band bg `--color-surface` or subtle gradient; inner `--container-max` centred text + CTA row
- Section id `#download`; sits above footer

##### Typography
- H2: Albra 40px desktop / 32px mobile centred
- Subcopy: Poppins 16px muted centred max-width 480px

##### Components
- `Button` primary Install, `PlayStoreBadge`

##### Animation Specification
- None required v1; optional subtle bg gradient shift 30s loop desktop

##### Acceptance Criteria (UI)
- Repeats install CTA; matches hero primary button styling

##### Review Notes (2026-07-27, tick 5)
- **Pass:** `#download` band, centred copy, primary Install CTA matches hero
- **Polish:** No Play Store badge asset — button-only OK v1

##### Review Notes (2026-07-27, tick 16)
- **Pass:** `useFinalCtaMotion` clip-path reveal on scroll; `id="download"` present

##### Review Notes (2026-07-27, tick 22)
- **Resolved:** `useSectionView('download', 'download')` on `HomePage`

##### Review Notes (2026-07-27, tick 25)
- **Partial resolved:** `PlayStoreBadge` under primary Install — `trackInstallClick('final_cta_badge')`; footer/nav still text-only §11.12 P3

##### Review Notes (2026-07-27, tick 26)
- **Resolved:** Footer badge shipped tick 26; `FinalCta` + footer both use `PlayStoreBadge` — §11.12 cleared

---

#### UI/UX Details — F-A01 Sign in / sign up (expanded)

##### Layout
- Centred card 400px max-width on full viewport `--color-bg`
- Card: `--color-surface-elevated`, `--radius-lg`, padding 32px
- Logo wordmark centred above card, 32px margin-bottom

##### Typography
- Card title: Albra 28px "Sign in to Splitr"
- Form labels: Poppins 14px 600
- Inputs: Poppins 16px
- Divider "or": Poppins 12px muted with horizontal rules

##### Components
- `AuthLayout`, `OAuthButton` Google (full-width, white bg, Google logo left), `Input`, `Button` primary submit, `ForgotPasswordLink`, tab toggle Sign in / Sign up

##### Component Behaviour
| State | Behaviour |
|-------|-----------|
| Submit loading | Button spinner + disabled inputs |
| Error | Inline banner below form, `--color-error` border, 14px text |
| Google OAuth | Full-width button above email form |

##### Animation Specification
- Card fade-in 200ms on route enter
- Tab switch sign in/up: cross-fade 150ms

##### Accessibility
- Labels linked to inputs; error `role="alert"`; Google button accessible name "Continue with Google"

##### Acceptance Criteria (UI)
- Google + email paths visible; forgot password link; mobile card full-width minus gutter

##### Review Notes (2026-07-27, tick 6)
- **Pass:** Matches layout/behaviour spec; tab `role="tablist"`; loading states on submit
- **Defer:** Albra title → Poppins 28px per §9.2
- **Polish:** Tab switch instant not 150ms cross-fade — acceptable v1

---

#### UI/UX Details — F-A02 App shell (expanded)

Sync §11.11.5.

##### Layout
- Desktop: 240px sidebar + main content
- Mobile: top bar 56px + bottom tabs 64px fixed; content padding accounts for tab bar

##### Components
- `AppShell`, `Sidebar`, `BottomTabBar`, `BlockedActionBanner`, `Logo`

##### Review Notes (2026-07-27, tick 6)
- **Pass:** Nav items Overview/Groups/Friends/Account; active `inset 3px` accent bar; safe bottom padding
- **Fix:** Add nav icons to bottom tabs for scanability (optional v1.1)
- **Pending:** Blocked banner on all write surfaces — only on Overview + Account so far; add to Groups/Friends when lists ship

---

#### UI/UX Details — F-A03 Overview (read-only)

##### Layout
- Desktop: balance summary cards row (2 cards: You owe / You are owed) + recent transactions list below
- Mobile: stack cards; transactions full-width

##### Typography
- Balance amount: Courier 32px; label Poppins 14px muted
- Owed: `--color-warning` prefix; owed-to-you: `--color-success`

##### Components
- `BalanceCard`, `TransactionList`, `TransactionRow`, `EmptyState`, `BlockedActionBanner`, `Skeleton`

##### Component Behaviour
- Loading: skeleton cards + list rows
- Empty: EmptyState with Install CTA
- Any add/settle affordance → BlockedActionBanner

##### Acceptance Criteria (UI)
- Balances colour-coded with +/- text prefix; no write buttons visible

##### Review Notes (2026-07-27, tick 7)
- **Pass:** 2-col balance cards, Courier 32px, warning/success colours, skeleton shimmer + reduced-motion, transaction +/- prefix, empty Install CTA, error retry `role="alert"`, `BlockedActionBanner` present
- **Fix:** Summary balance cards lack +/- prefix (only colour) — add `−` / `+` before amounts per a11y spec
- **Polish:** Error card inline styles — extract `ErrorCard` component; `--color-warning` token `#ffb74d` vs spec `#E6A800` — align tokens
- **Polish:** Empty state H2 not Albra — Poppins OK per §9.2

##### Review Notes (2026-07-27, tick 8)
- **Resolved:** Balance cards now use `−` / `+` prefix (tick 7 fix)
- **Open:** Error card still inline styles; warning token colour drift

##### Review Notes (2026-07-27, tick 27)
- **Resolved:** `ErrorCard.tsx` + `ErrorCard.module.css` — `OverviewPage` + all app list pages; §11.12 partial cleared
- **Open:** `--color-warning` `#e6a800` vs mobile amber `#FFC107` — align if brand QA flags

---

#### UI/UX Details — F-A04 Groups (read-only)

##### Layout
- List: avatar + name + balance right-aligned; tap row → detail
- Detail: header (group name, member avatars stack) + expense table + balance breakdown

##### Typography
- Group name H1 Albra 28px; balance Courier 16px right column

##### Components
- `GroupList`, `GroupRow`, `GroupDetail`, `ExpenseTable`, `MemberAvatar`, `BlockedActionBanner`

##### Acceptance Criteria (UI)
- List shows net balance per group; detail matches mobile read data; blocked banner on add/settle

##### Review Notes (2026-07-27, tick 8)
- **Pass:** List row avatar + name + signed Courier balance; link to detail; hover accent border; skeleton loading
- **Pass:** Detail — back link, H1 name, signed net balance, member pills, balance breakdown, recent expenses, `BlockedActionBanner`
- **Polish:** Detail page heavy inline styles — migrate to `Groups.module.css` classes
- **Polish:** Empty groups list text-only — add Install CTA like overview empty state
- **Defer:** H1 Poppins 28px not Albra per §9.2; member pills vs overlapping avatar stack — acceptable v1

##### Review Notes (2026-07-27, tick 26)
- **Resolved:** Empty state — `styles.empty` + H2 + body + `Install Splitr` primary button (`PLAY_STORE_URL`); §11.12 P3 cleared

##### Review Notes (2026-07-27, tick 27)
- **Resolved:** `GroupsPage` uses shared `ErrorCard`; detail error path uses `variant="plain"`
- **Open:** Detail header still inline styles — migrate to `Groups.module.css` §11.12 P3

##### Review Notes (2026-07-27, tick 29)
- **Resolved:** `DetailPage.module.css` shared by `GroupDetailPage` + `FriendDetailPage` — header, sections, profile card; no inline layout styles; §11.12 detail P3 cleared

---

#### UI/UX Details — F-A05 Friends (read-only)

##### Layout
- Mirror F-A04 list pattern; detail shows 1:1 transaction history

##### Components
- `FriendList`, `FriendRow`, `FriendDetail`, `BlockedActionBanner`

##### Acceptance Criteria (UI)
- Pagination or cap with "See all in app" link; add friend blocked

##### Review Notes (2026-07-27, tick 9)
- **Pass:** List mirrors groups — avatar, name, signed Courier balance, row link to detail
- **Pass:** Detail — centred profile card, balance label + signed amount, group breakdown, shared expenses capped at 15 with "See all in app" link, `BlockedActionBanner`
- **Polish:** Reuses `Groups.module.css` — OK; detail still inline styles on header (same as F-A04)
- **Polish:** Empty friends list text-only — add Install CTA for parity with overview empty state
- **Pass:** Add friend blocked via banner only — no write affordances exposed

##### Review Notes (2026-07-27, tick 10)
- **Resolved:** Friends empty state now has Install CTA (tick 9 polish)

##### Review Notes (2026-07-27, tick 27)
- **Pass:** `FriendList` empty Install CTA confirmed in code; `FriendsPage` uses `ErrorCard`

##### Review Notes (2026-07-27, tick 28)
- **Polish:** `FriendList` empty uses inline styles; `GroupList` uses `styles.empty` — align for parity §11.12 P3

##### Review Notes (2026-07-27, tick 29)
- **Resolved:** `FriendDetailPage` uses `DetailPage.module.css` — profile card + sections match spec
- **Open:** `FriendList` empty still inline — reuse `.empty` classes (last detail P3 item)

##### Review Notes (2026-07-27, tick 31)
- **Resolved:** `FriendList` empty uses `styles.empty` / `emptyTitle` / `emptyBody` — matches `GroupList`

---

#### UI/UX Details — F-A06 Account (read-only)

##### Layout
- Profile card: avatar 64px, name H2, email muted
- Pro badge if active: `--color-yellow` Badge
- Action rows: Edit profile, Manage Pro, Delete account — each row shows blocked pattern → app deep link
- Sign out: destructive ghost button bottom

##### Components
- `AccountCard`, `ProBadge`, `SettingsRow`, `Button` ghost danger Sign out

##### Acceptance Criteria (UI)
- Pro badge only when subscription active; Sign out works; no subscribe UI

##### Review Notes (2026-07-27, tick 10)
- **Pass:** `Account.module.css` profile card, 64px avatar, Pro badge when `isPremium`, settings rows with "Available in the app" hint + `splitr://` deep links, deletion policy → `/account-deletion`, `variant="danger"` sign out
- **Pass:** Loading skeleton; error retry pattern matches overview
- **Polish:** Pro badge yellow `#f5c518` fallback vs token `#F9FE8A` — align to `--color-yellow`
- **Polish:** Settings rows + `BlockedActionBanner` overlap — acceptable; banner reinforces read-only scope
- **Resolved (tick 6):** Sign out danger variant + extracted account card styles

---

#### UI/UX Details — F-A07 Deep link previews

##### Layout
- Marketing shell (F-C08) + centred preview card 480px max
- Logged out: group/inviter name, Install primary, Sign in secondary
- Logged in: read-only subset + Open in app primary
- Invalid token: error card `--color-error` border

##### Typography
- Preview title: Albra 32px; context line Poppins 16px muted

##### Components
- `DeepLinkPreviewCard`, `InstallCta`, `OpenInAppButton`, `ErrorState`

##### Animation Specification
- Card fade-in 300ms on load

##### Acceptance Criteria (UI)
- Valid token shows name; invalid shows friendly error; no join RPC triggered from UI

##### Review Notes (2026-07-27, tick 11)
- **Pass:** Marketing shell; centred 480px card; 300ms fade-in + reduced-motion; skeleton loading; error border `--color-error`
- **Pass:** Logged out → Install primary + Sign in ghost; logged in → Open in app + optional View on web; invalid → error + Install CTA
- **Pass:** Group member gets web link to `/app/groups/{id}`; friend gets `/app/friends/{id}`; no join RPC in UI
- **Resolved (tick 21):** `preview-invite` Edge Function + `deepLinkData` logged-out fetch — group/inviter name on valid token
- **Defer:** Title Poppins 32px not Albra per §9.2
- **Polish:** "Back to home" link inline style — move to CSS module

##### Review Notes (2026-07-27, tick 20)
- **Product:** Option A confirmed — `preview-invite` Edge Function; UI states table below is final acceptance
- **UI locked:** Title = `{groupName}` / `{inviterName}`; subtitle copy per table; skeleton on fetch; generic title only while loading or invalid
- **Developer:** Call Edge Function from `deepLinkData.ts` when `!userId`; no direct anon RLS on invites table
- **No code change this tick** — awaiting Developer implementation

##### Review Notes (2026-07-27, tick 21)
- **Pass:** Logged-out valid token → `ready` state → `title={groupName|inviterName}` on `DeepLinkPreviewCard`; skeleton while loading; invalid → error card
- **Pass:** Subtitle matches spec intent (join/accept in app); Install + Sign in CTAs unchanged
- **Polish:** API failure still falls back to generic "Group invite" / "Friend invite" — acceptable degrade until function deployed
- **QA gate:** Verify logged-out name on prod after `supabase functions deploy preview-invite` (§9.6 #7)

##### Logged-out preview unblock spec (tick 19 — Product + Developer)

**UI requirement (unchanged):** Valid token → show **group name** or **inviter display name** in `DeepLinkPreviewCard` title before auth.

**Root cause:** `deepLinkData.ts` returns `anonymous` when `!userId` — no fetch.

**Product decision needed (pick one):**

| Option | Approach | Privacy / security |
|--------|----------|-------------------|
| A (recommended) | Supabase **Edge Function** `preview-invite` — input token or userId; returns `{ name, valid }` only; rate-limited; no PII beyond name | Token required; no member list |
| B | RLS policy allowing `anon` read on `shareable_invites` + `groups.group_name` for active non-expired tokens | Tighter column grant; audit exposure |
| C | Defer v1.1 — keep generic copy "You're invited to a group" / "A friend invited you" | No API; weaker §F-A07 acceptance |

**Product decision (tick 20): Option A.** Developer unblocked for Edge Function + `deepLinkData` update.

**UI states after fix:**

| State | Title | Subtitle |
|-------|-------|----------|
| Valid group | `{groupName}` | Join this group in the Splitr app |
| Valid friend | `{inviterName}` | Accept this friend invite in the app |
| Invalid | Invite unavailable | Existing error copy |
| Loading | Skeleton shimmer | — |

**Acceptance (UI):** Logged-out `/join/{valid}` shows real group name; `/invite/friend/{valid}` shows inviter name; invalid unchanged.

---

#### UI/UX Details — F-I01 SEO & OG meta (pre-implementation)

##### Layout
- No visible layout — `<head>` tags only via `usePageMeta` extension

##### Component Behaviour
| Tag | Rule |
|-----|------|
| `og:title` | Same as document title |
| `og:description` | Same as meta description |
| `og:url` | Canonical absolute URL |
| `og:image` | Default `https://splitr.money/og-image.png` or app icon 512; 1200×630 ideal; absolute URL required |
| `og:type` | `website` |
| `twitter:card` | `summary_large_image` |
| `twitter:title` / `description` / `image` | Mirror OG |

##### Acceptance Criteria (UI)
- Facebook Sharing Debugger + Twitter Card Validator pass on `/` and `/privacy`

##### Review Notes (2026-07-27, tick 12)
- **Pass:** `usePageMeta` sets og:* + twitter:* + canonical; home title matches §F-I01; `DEFAULT_OG_IMAGE` absolute URL
- **Pass:** Per-route descriptions; `noIndex` support used on 404
- **Polish:** `og-image.png` is 512×512 app icon — consider 1200×630 branded card for richer social previews (v1.1)
- **Polish:** `/app/*` routes set meta but are behind auth — acceptable; no OG needed for gated views

---

#### UI/UX Details — F-I02 404 Not Found (pre-implementation)

Sync §11.9 global 404 pattern.

##### Layout
- Marketing shell (nav + footer); centred content max-width 480px; `--section-y` vertical padding

##### Typography
- H1: Poppins/Albra 40px desktop, 32px mobile — "Page not found"
- Body: Poppins 16px muted — one line explaining link may be broken

##### Components
- `NotFoundPage`, `Button` primary Install, `Button` ghost Home (`/`)

##### Component Behaviour
- No animation required; focus lands on H1 after route

##### Acceptance Criteria (UI)
- Unknown paths show 404 content inside marketing chrome; Home + Install CTAs work; no blank screen

##### Review Notes (2026-07-27, tick 12)
- **Pass:** Marketing shell via `path="*`; centred 480px; H1 focusable (`tabIndex={-1}`); body copy; Home + Install CTAs; `noIndex`
- **Polish:** CTA order Home primary / Install ghost — spec listed Install primary; both present — acceptable
- **Note:** SPA returns 200 on unknown paths — Vercel `vercel.json` 404 rewrite optional for crawlers

---

### 11.12 v1 polish backlog (post-deploy, non-blocking)

Consolidated from §12.2 Review Notes. **v1 code complete** — ship without these.

| Priority | Item | Feature |
|----------|------|---------|
| ~~P3~~ | ~~Trust strip stroke icons~~ — **cleared tick 25** (`TrustIcon.tsx`) | F-L02 |
| ~~P3~~ | ~~Feature grid icon circles~~ — **cleared tick 25** (`FeatureIcon.tsx` 48px circle) | F-L03 |
| ~~P3~~ | ~~Play Store badge~~ — **cleared tick 26** footer + `FinalCta`; nav text Install acceptable v1 | F-C08, F-C09, F-L07 |
| ~~P3~~ | ~~Hero mesh off `<768px`~~ — **cleared tick 26** (`HeroVisual.module.css` `767px`) | F-L01 |
| ~~P3~~ | ~~`FriendList` empty → `Groups.module.css` `.empty`~~ — **cleared tick 31** | F-A05 |
| ~~P3~~ | ~~Extract `ErrorCard`~~ — **cleared tick 27** (`ErrorCard.tsx` + app shell pages) | F-A03–A06 |
| ~~P3~~ | ~~Groups empty Install CTA~~ — **cleared tick 26** (`GroupList` empty + Install button) | F-A04 |
| P3 | Align `--color-warning` + Pro badge yellow | tokens |
| P3 | Albra web font (license permitting) | sitewide |
| P4 | §8.1 motion — verify Lighthouse ≥90 + reduced-motion QA post-deploy | landing |

---

### 12.3 §7 → §12.2 coverage index (tick 13)

All v1 features mapped. Legal F-C02–C04, C06 inherit F-C01 pattern.

| §7 ID | §12.2 entry | Review status |
|-------|-------------|---------------|
| F-C01 | F-C01 legal pattern (+ F-C02–C06) | Reviewed |
| F-C05 | F-C05 Contact | Reviewed |
| F-C07 | F-C07 Cookie consent | Reviewed |
| F-C08 | F-C08 Global marketing chrome | Reviewed — focus trap resolved tick 18 |
| F-C09 | F-C09 Global footer | Reviewed tick 13 |
| F-L01 | F-L01 Landing hero | Reviewed |
| F-L08 | F-L08 How it works | Reviewed tick 13 |
| F-L02–L07 | F-L02–F-L07 entries | Reviewed |
| F-A01–A02 | F-A01 / F-A02 expanded | Reviewed |
| F-A03–A07 | F-A03–F-A07 entries | Reviewed — F-A07 logged-out names tick 21 |
| F-I01–I02 | F-I01 / F-I02 | Reviewed tick 12 |

**UI/UX Agent v1 mandate complete.** Further ticks = polish spec updates or post-QA Review Notes only — no new scope.

**Product loop:** Deploy-blocked since tick 33 — **stop shell loop** until `splitr.money` live; resume for §9.6 QA → `Verified`.

---
