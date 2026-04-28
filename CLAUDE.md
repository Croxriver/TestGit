# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Run on a connected device or emulator
flutter run

# Run all tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Lint / analyze
flutter analyze

# Build release APK (split by ABI)
flutter build apk --release --split-per-abi
```

## Architecture

This is a Flutter Todo app with a Korean-language UI using Material 3. There is **no state management library** — all state lives in `StatefulWidget`s. There is **no persistence** — the todo list is in-memory and resets on each launch (sample todos are injected in `HomeScreen._addSampleTodos()`).

**Screen flow:**

```
SplashScreen (2s animated) → LoginScreen (no real auth) → HomeScreen ↔ AddTodoScreen
```

- `SplashScreen` navigates to `LoginScreen` after a 2-second delay via `pushReplacement`.
- `LoginScreen` accepts any credentials; pressing the login button goes straight to `HomeScreen`.
- `HomeScreen` holds the `List<Todo>` as its own state. It passes callbacks (`onToggle`, `onDelete`) down to `TodoItem` widgets. Navigation to `AddTodoScreen` uses `Navigator.push` and receives the new `Todo` as a return value.
- `AddTodoScreen` constructs a `Todo` with a millisecond-epoch ID and returns it to `HomeScreen` via `Navigator.pop(context, todo)`.

**Data model** (`lib/models/todo.dart`):

- `Todo` has `id`, `title`, `description?`, `isCompleted`, `createdAt`, and `priority`.
- `Priority` enum (`low`, `medium`, `high`) carries Korean display labels and `Color` values via an extension.
- `Todo` supports `toJson`/`fromJson` and `copyWith`, but these are not currently wired to any storage.

## Key Conventions

- The project enforces three lint rules: `prefer_const_constructors`, `prefer_const_literals_to_create_immutables`, and `use_key_in_widget_constructors`. All widgets must accept a `key` parameter.
- Seed color is `0xFF6C63FF` (purple). Do not hardcode other primary colors; use `Theme.of(context).colorScheme.*` throughout.
- `TodoItem` uses `Dismissible` (swipe left to delete) and `InkWell` tap to toggle completion. Maintain this gesture contract when modifying the widget.
- The existing widget tests skip the splash/login flow by pumping `MyApp()` directly — note that the test assertions assume `HomeScreen` is rendered immediately, which currently fails because `SplashScreen` is shown first. Be aware of this when adding or fixing tests.

## CI

GitHub Actions (`.github/workflows/build-apk.yml`) builds a release APK on push to `master` and `claude/create-flutter-app-hAxKC`. It uses Flutter 3.41.8 stable and Java 17. Artifacts are uploaded as `flutter-todo-apk` and retained for 30 days.
