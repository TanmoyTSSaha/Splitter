# Splitr Engineering Principles

Applied to this repository — not generic Flutter theory.

## 1. Match the codebase first

Generated code must look like existing Splitr code: GetX, layer-by-type folders, Neopop UI, manual models. Generic clean-architecture advice yields wrong output here.

## 2. Layer discipline

Views do not fetch data. Controllers do not build widgets. Repositories do not show toasts. Services do not import screens.

## 3. Offline is a feature

Users must use the app without connectivity. Local Drift writes + sync queue are required for core entities (groups, transactions, personal expenses, friends). Groups and group transactions are wired; extend the pattern to remaining entities.

## 4. Minimal scope

Change only what the task requires. Do not refactor adjacent legacy `SupabaseDatabase()` calls unless the task includes migration.

## 5. Reuse before create

Check `Widgets/`, `Constants/shared.dart`, and existing controllers before adding new classes. Reuse `InsightsProGate`, `PremiumGate`, `PillTabBar`, etc.

## 6. No parallel architectures

One state library (GetX). One local DB (Drift). One backend (Supabase). Do not introduce second patterns.

## 7. Evidence-based standards

When two patterns conflict, follow the **dominant** one in the feature area being edited — except repository/offline rules, which follow the **target** architecture even if current code bypasses it.

## 8. Security pragmatism

Secrets live in `git_ignore.dart` per project decision. AI should not relocate keys without explicit request but should flag client-side Gemini exposure.

## 9. Test when it matters

Tests on request. Priority: repository logic, debt simplification algorithm, model parsing, pure analytics math (`SpendingIntelligenceService`), Pro gate widgets — not counter widget smoke tests.

## 10. Ship incremental migration

`GroupRepository` and `TransactionRepository` are wired — continue per-feature (`HomeController`, `FriendRepository`, `LoanRepository`) rather than big-bang rewrites.
