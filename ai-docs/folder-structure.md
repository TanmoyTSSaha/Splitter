# SplitO Folder Structure

```
Splitter/
├── lib/
│   ├── main.dart
│   ├── git_ignore.dart              # API keys (project convention)
│   ├── Bindings/          (1)       # AppBindings — repos + shared controllers
│   ├── Constants/          (10)      # Theme, legacy shared widgets
│   ├── Controller/         (11)      # GetX controllers
│   ├── Controllers/         (2)      # Legacy: currency + premium subscription
│   ├── Model/              (18)      # Domain models
│   ├── Repository/          (2)      # Group + Transaction repos
│   ├── Services/           (33)      # Domain + infra
│   │   ├── SupabaseServices/  (9)   # Per-table Supabase CRUD
│   │   └── local/         (2)       # Drift DB + generated
│   ├── Screen/             (70)      # Feature UI
│   │   ├── AuthScreens/
│   │   ├── BottomNavigationController/
│   │   ├── FriendScreen/
│   │   ├── GoalScreen/
│   │   ├── GroupScreen/
│   │   │   ├── GraphAnalysisWidgets/
│   │   │   └── SharingTypeTabs/
│   │   ├── HomeScreen/
│   │   ├── Insights/
│   │   │   └── widgets/             # insights_* cards, score ring, social trust
│   │   ├── LendingScreen/
│   │   ├── NotificationScreen/
│   │   ├── OnboardingScreen/
│   │   ├── ProfileScreen/
│   │   ├── TripScreen/
│   │   └── FeatureComingUp/
│   └── Widgets/          (18)      # Cross-feature UI (insights, premium gates, nav)
├── assets/
│   ├── icons/svg/
│   ├── dev_images/
│   ├── fonts/             # Albra
│   ├── json/
│   └── lottie/
├── supabase/migrations/  (12)      # SQL schema migrations
├── test/                  (3)       # spending_intelligence + insights_pro_gate + widget_test
└── .cursor/rules/                   # Engineering rules + ai-docs
```

File counts are approximate Dart files per folder (SQL migrations counted separately).

## Import aliases

Always: `package:splitter/<path>.dart`

## Naming

- Screen folders: `GroupScreen`, `HomeScreen` (PascalCase + Screen)
- Files: `snake_case.dart`
- Models: `fromJSON` / `toJSON` (project convention; `LoanModel` uses `fromJson`/`toJson`)
