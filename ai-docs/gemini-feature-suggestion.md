# Splitr Pro: Monetization Feature Specifications

**Document Type:** Feature Proposals / Strategy Brief
**Target:** Splitr Pro Premium Tier Monitization
**Focus:** Software conveniences avoiding direct flow-of-funds (no payment gateways)

---

## 1. The "Bad Cop" Automation System

* **The Reality:** The primary reason users download expense-splitting applications is the inherent social discomfort of asking friends for money.
* **Current Implementation:** The architecture currently utilizes a `ReminderSettingsService` that supports various cadences (daily, weekly, biweekly, monthly) and tones (friendly, casual, formal) `[cite: 1]`.
* **The Pro Hook:** Transition the burden of debt collection from the user to the software. While basic, generic in-app push notifications remain free, aggressive or "escalated" cadences are locked behind the Pro paywall. Premium users can trigger automated, professional-looking reminders sent directly by Splitr on their behalf. Users are highly motivated to pay a subscription fee to let the application act as the "bad cop," thereby preserving their personal relationships while still recovering their funds.

## 2. Psychological Leverage in P2P Lending

* **The Reality:** Informal lending among friends carries high default rates. Without escrow functionality, lenders seek security through psychological weight and formality.
* **Current Implementation:** The `LendingDashboard` effectively handles principal amounts, interest types (simple, compound, flat), and generates structured EMI repayment schedules `[cite: 1]`.
* **The Pro Hook:** Monetize the formalization of the debt. Introduce a Pro feature that extracts data from the existing `LoanContractFormScreen` `[cite: 1]` and generates a legally formatted, downloadable PDF Promissory Note. Delivering a formal document complete with an EMI schedule to a borrower drastically increases the psychological pressure to repay. Lenders will readily pay for the peace of mind that comes with this formalized documentation.

## 3. The "Corporate Expenser" Trojan Horse

* **The Reality:** Casual users splitting small bills possess zero willingness-to-pay. Conversely, professionals traveling for work or freelancers expensing client projects value their time highly and rely on corporate reimbursements.
* **Current Implementation:** The product correctly gates AI Receipt Scanning (via Google ML Kit) and CSV/PDF export functionality behind the Splitr Pro tier `[cite: 1]`.
* **The Pro Hook:** Actively position these gated features as a dedicated expense-reporting toolkit. Professionals will gladly pay the subscription fee to eliminate manual data entry. By allowing them to photograph complex business receipts, utilize OCR to parse line items `[cite: 1]`, and immediately export a pristine PDF ledger for their HR or accounting departments, the application transitions from a simple calculator to a high-value time-saving utility.

## 4. Premium Multi-Currency Trip Ledgers

* **The Reality:** Domestic, single-currency trips are frequent and should remain un-gated to drive user acquisition. International travel, however, inherently implies disposable income and introduces significant calculation friction.
* **Current Implementation:** The application seamlessly supports 25 distinct currencies via the Frankfurter API, caching exchange rates at the time of transaction `[cite: 1]`. Trips are structurally supported as groups utilizing `trip_metadata` `[cite: 1]`.
* **The Pro Hook:** Require a Splitr Pro subscription to initialize a multi-currency trip. When a group travels internationally and incurs shared expenses across multiple foreign currencies, manually calculating net settlements in their home currency is a severe pain point. Resolving this complex multi-currency arithmetic is a premium convenience that international travelers are highly willing to pay for.