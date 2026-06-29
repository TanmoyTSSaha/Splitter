# SplitO Folder Structure

```
Splitter/
├── lib/
│   ├── main.dart
│   ├── git_ignore.dart              # API keys (project convention)
│   ├── Constants/         (8)       # Theme, legacy shared widgets
│   ├── Controller/        (8)       # GetX controllers
│   ├── Controllers/       (1)       # Legacy: currency_controller only
│   ├── Model/            (15)       # Domain models
│   ├── Repository/        (2)       # Group + Transaction repos
│   ├── Services/         (25)       # Domain + infra
│   │   ├── SupabaseServices/  (9)   # Per-table Supabase CRUD
│   │   └── local/         (2)       # Drift DB + generated
│   ├── Screen/           (57)       # Feature UI
│   │   ├── AuthScreens/
│   │   ├── BottomNavigationController/
│   │   ├── FriendScreen/
│   │   ├── GoalScreen/
│   │   ├── GroupScreen/
│   │   │   ├── GraphAnalysisWidgets/
│   │   │   └── SharingTypeTabs/
│   │   ├── HomeScreen/
│   │   ├── Insights/
│   │   ├── LendingScreen/
│   │   ├── NotificationScreen/
│   │   ├── OnboardingScreen/
│   │   ├── ProfileScreen/
│   │   ├── TripScreen/
│   │   └── FeatureComingUp/
│   └── Widgets/           (6)       # Cross-feature UI
├── assets/
│   ├── icons/svg/
│   ├── dev_images/
│   ├── fonts/             # Albra
│   └── json/
├── supabase/migrations/
├── test/                  (1)       # Broken default widget test
└── .cursor/rules/                   # Engineering rules + ai-docs
```

File counts are approximate Dart files per folder.

## Import aliases

Always: `package:splitter/<path>.dart`

## Naming

- Screen folders: `GroupScreen`, `HomeScreen` (PascalCase + Screen)
- Files: `snake_case.dart`
- Models: `fromJSON` / `toJSON`
