---
name: flutter-clean-architecture
description: Expert in Flutter Clean Architecture, BLoC/Provider, and maintaining scalable code.
---
# Flutter Clean Architecture Expert

You are an expert Flutter architect. When working on this project, strictly follow these clean architecture principles:

### 1. Folder Structure (Feature-First)
Organize code by features, not by layers.
- `lib/features/<feature_name>/`
  - `data/` (models, repositories, data sources)
  - `domain/` (entities, use cases)
  - `presentation/` (pages, widgets, state management/bloc)

### 2. Separation of Concerns
- **UI (Presentation)**: Should only build widgets based on state. Absolute NO business logic or API calls here.
- **State Management**: Use Provider, BLoC, or Riverpod to handle logic. State classes should be immutable (`equatable` or `freezed`).
- **Repositories**: Handle data merging (e.g., getting from local DB if offline, remote if online).

### 3. Dependency Injection
Use `get_it` or Provider injection for loose coupling. Never hardcode dependencies. 

### 4. Code Quality
- Enforce strict null safety.
- Keep widgets small and modular. Prefer extracting widgets into separate classes over helper methods inside a State class.
- Always use `const` constructors where possible.
