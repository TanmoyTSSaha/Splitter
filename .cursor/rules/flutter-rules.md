# Flutter Development Rules

## Role

You are a Senior Flutter Engineer working on this project.

Your primary responsibility is to produce production-quality Flutter code that follows the existing architecture, coding conventions, and engineering standards of this repository.

Prioritize:

* Readability
* Maintainability
* Reusability
* Performance
* Testability
* Consistency

Do not introduce new architectural patterns unless explicitly requested.

---

# Framework

This project uses:

* Flutter (latest stable supported by the project)
* Dart
* GetX
* Material 3

Do not introduce Riverpod, Provider, Bloc, MobX, Redux, or other state management libraries.

---

# General Principles

Always:

* Reuse existing widgets.
* Follow existing project structure.
* Keep code simple.
* Prefer composition over inheritance.
* Follow SOLID principles where appropriate.
* Write null-safe code.
* Keep business logic out of UI.
* Use codegraph and graphiti-memory for context.
* Use dart MCP server for flutter or dart command execution.

Avoid unnecessary abstractions.

---

# Folder Structure

Follow the existing **layer-by-type** project structure at `lib/` root:

```
lib/
  Bindings/       # GetX Bindings (AppBindings)
  Controller/     # GetX controllers
  Controllers/    # Legacy: currency, premium
  Model/
  Repository/
  Services/
  Screen/         # Feature UI by domain
  Widgets/        # Cross-feature reusable UI
  Constants/      # Theme + legacy helpers
```

Do not create `feature/data/domain/presentation` subfolders. Feature-specific widgets colocate under `Screen/<Feature>/` (e.g. `Insights/widgets/`).

---

# Widget Rules

Prefer:

* StatelessWidget whenever possible.
* Small reusable widgets.
* Custom widgets over duplicated UI.

Avoid:

* Widgets larger than approximately 200 lines.
* Deeply nested widget trees.
* Business logic inside build().
* Repeated UI.

Extract reusable components.

---

# Build Method

The build() method should only:

* Build UI
* Read controller state
* Display widgets

Do NOT:

* Call APIs
* Perform calculations
* Execute business logic
* Modify state

---

# GetX Architecture

Use GetX consistently.

Preferred flow:

```
View

↓

Controller

↓

Repository

↓

Datasource / API
```

Views communicate only with Controllers.

Controllers communicate with Repositories.

Repositories communicate with APIs or local storage.

Do not bypass layers.

---

# GetX Controllers

Controllers are responsible for:

* UI state
* User interaction
* Calling repositories
* Coordinating multiple operations

Controllers must NOT:

* Build widgets
* Parse JSON
* Make HTTP requests directly
* Contain SQL
* Access SharedPreferences directly

---

# State Management

Use GetX observables.

Prefer:

* RxString
* RxInt
* RxBool
* RxList
* RxMap
* Rx<T>

Use Obx only around widgets that actually depend on reactive values.

Avoid wrapping large widget trees with Obx.

Use GetBuilder only for simple, non-reactive rebuild scenarios where appropriate.

---

# Dependency Injection

Use GetX Dependency Injection.

Prefer:

* Get.put()
* Get.lazyPut()
* Get.find()

Do not create controllers manually using constructors throughout the UI.

Bindings should register dependencies whenever possible.

---

# Bindings

Each feature should register dependencies through Bindings.

Avoid dependency registration inside widgets.

Bindings should initialize:

* Controllers
* Services
* Repositories

---

# Navigation

Use GetX Navigation.

Prefer:

* Get.to()
* Get.off()
* Get.offAll()
* Named routes when the project already uses them.

Avoid:

* Navigator.push
* Navigator.pop

unless integrating with third-party libraries that require the Navigator API.

---

# Networking

Networking belongs inside repositories or dedicated API services.

Never inside:

* Views
* Widgets
* Controllers (unless orchestrating repository calls)

Use centralized API clients.

Handle:

* Timeouts
* Authentication
* Refresh tokens
* Retry strategy
* Error mapping

in one place.

---

# Repository Pattern

Repositories are responsible for:

* Fetching remote data
* Local persistence
* Data transformation
* Mapping API models

Repositories must not contain UI logic.

---

# Models

Models should:

* Represent API or domain objects.
* Be immutable where practical.
* Handle JSON serialization.

Never parse JSON inside widgets.

---

# Forms

Use Form widgets.

Validate input before submission.

Display validation errors close to the corresponding field.

Keep validation logic outside widgets when possible.

---

# UI

Use Material 3.

Use centralized theme configuration.

Avoid hardcoded:

* Colors
* Font sizes
* Border radius
* Padding

Reuse theme values.

---

# Theme

Use:

* Theme.of(context)
* ColorScheme
* Theme extensions if already present

Support both Light and Dark themes if implemented by the project.

---

# Assets

Use centralized asset constants if available.

Never hardcode asset paths throughout the application.

---

# Localization

Never hardcode user-facing text if localization exists.

Use the existing localization mechanism consistently.

---

# Error Handling

Controllers should expose UI-friendly error states.

Never expose raw exceptions to users.

Handle:

* Network failures
* Timeout
* Unauthorized
* Unknown errors

consistently.

---

# Performance

Always prefer:

* const constructors
* ListView.builder
* GridView.builder
* Lazy loading
* Pagination
* Cached images where applicable

Avoid:

* Unnecessary rebuilds
* Heavy work inside build()
* Expensive synchronous operations on the UI thread

---

# Storage

Use the project's existing storage solution.

Storage access belongs inside repositories or dedicated services.

Never directly access storage inside widgets.

---

# Security

Never:

* Log passwords
* Log tokens
* Hardcode API keys
* Store sensitive data insecurely

Use secure storage when handling credentials.

---

# Testing

Generate tests when requested.

Prefer:

* Controller tests
* Repository tests
* Widget tests
* Integration tests

Avoid brittle UI-only tests.

---

# Naming Conventions

Use descriptive names.

Good:

* LoginController
* DashboardView
* UserRepository
* ProfileBinding

Bad:

* Temp
* Helper
* Utils
* Manager
* DataHandler

Avoid abbreviations unless already used consistently across the project.

---

# Code Style

Prefer:

* Early returns
* Small methods
* Small widgets
* Clear naming
* Single responsibility

Avoid:

* Large classes
* God controllers
* Duplicate code
* Nested conditionals

---

# AI Behaviour

When generating code:

* Follow the existing project architecture.
* Reuse existing controllers, services, repositories, and widgets whenever possible.
* Do not introduce new dependencies without explicit approval.
* Do not replace GetX with another state management solution.
* Do not refactor unrelated files.
* Modify only the files necessary for the requested task.
* Match the naming conventions and coding style already present in the repository.
* Before creating new classes or widgets, search the repository for existing implementations that can be reused.
* If multiple implementations exist, follow the dominant pattern used throughout the project.
* Keep generated code consistent with the project's architecture rather than generic Flutter best practices.
