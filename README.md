# Taskify

A production-ready task management application built with Flutter. Supports full
offline CRUD operations backed by Hive local storage, with a clean layered
architecture and Provider-based state management.

## Setup

1. Ensure Flutter SDK (>=3.10.4) is installed and on your PATH.
2. Clone the repository and navigate into the project root.
3. Run `flutter pub get` to install dependencies.
4. Run `flutter run` to launch on a connected device or emulator.
5. Run `flutter test` to execute the test suite.

## Dependencies

| Package | Purpose |
|---|---|
| hive / hive_flutter | Local NoSQL storage for persisting tasks |
| provider | Lightweight state management via ChangeNotifier |
| uuid | Generating unique task identifiers |
| intl | Date formatting and locale-aware display |

## Project Structure

```
lib/
  main.dart
  core/
    constants/app_colors.dart
    theme/app_theme.dart
    utils/date_formatter.dart
  data/
    models/task_model.dart
    services/hive_service.dart
  presentation/
    providers/task_provider.dart
    screens/
      splash/splash_screen.dart
      main/main_screen.dart
      home/home_screen.dart
      tasks/task_screen.dart
      add_task/add_task_screen.dart
      profile/profile_screen.dart
    widgets/
      task_card.dart
      custom_bottom_nav.dart
      status_chip.dart
      empty_state.dart
```

## Architecture

The codebase follows a three-layer architecture that separates concerns between
core utilities, data operations, and presentation logic.

### Core Layer (lib/core/)

Framework-agnostic primitives shared across the app.

- `app_colors.dart` -- single source of truth for the colour palette. Changing a
  value here propagates to every widget that references it.
- `app_theme.dart` -- builds a Material 3 ThemeData from the colour constants.
  Configures AppBar, InputDecoration, Card, ElevatedButton, and SnackBar themes
  centrally so screens never define inline styles.
- `date_formatter.dart` -- static helpers that convert DateTime values into
  human-readable strings ("Today", "Tomorrow", "In 3 days", etc.).

### Data Layer (lib/data/)

Handles persistence and defines the domain model. No Flutter UI imports exist
in this layer.

- `task_model.dart` -- plain Dart class with fields: id, title, description,
  status (pending/inProgress/completed), priority (low/medium/high), category,
  dueDate, createdAt, updatedAt. Includes `copyWith` for immutable updates and
  an `isOverdue` getter. Three manually written Hive TypeAdapter classes (Task,
  TaskStatus, TaskPriority) are co-located here to avoid a build_runner
  dependency.
- `hive_service.dart` -- thin wrapper around a Hive Box<Task>. Exposes
  getAllTasks, addTask, updateTask, deleteTask, and clearAll. A static `init()`
  registers adapters and opens the box; called once in main() before runApp.

### Presentation Layer (lib/presentation/)

Everything the user sees and interacts with.

**Provider (task_provider.dart)**

A single ChangeNotifier that owns the in-memory task list and mediates between
the UI and HiveService. It exposes filtered/sorted task lists (by status and
search query), computed statistics (total, completed, pending, in-progress,
overdue, completion rate), convenience getters (todayTasks, recentTasks), and
async CRUD methods. Each write-through method persists to Hive, reloads the
list, and calls notifyListeners so all consumers rebuild.

The provider is created once at the widget tree root via ChangeNotifierProvider
in main.dart. Screens consume it with Consumer<TaskProvider> for rebuilds or
context.read<TaskProvider>() for one-off calls.

**Screens**

- `splash_screen.dart` -- animated splash with the brand logo, a subtitle, and
  a progress bar. Uses three AnimationControllers for staggered effects, then
  navigates to MainScreen with a fade transition.
- `main_screen.dart` -- hosts an IndexedStack of four tab screens with a
  CustomBottomNav. Selecting the Add tab increments a ValueKey to reset form
  state.
- `home_screen.dart` -- dashboard with a greeting, stat cards, a gradient
  progress card, and sections for today's and recent tasks.
- `task_screen.dart` -- full task list with a search field and horizontal filter
  chips (All / Pending / In Progress / Completed). Wrapped in RefreshIndicator.
- `add_task_screen.dart` -- form for creating or editing a task. An optional
  existingTask parameter switches between create and edit modes. Validates title
  length and resets all fields after a successful create.
- `profile_screen.dart` -- user card, completion statistics, and menu items for
  viewing detailed stats, categories, clearing data, and app info.

**Widgets**

- `task_card.dart` -- Dismissible card with swipe-to-delete (confirmation
  dialog), tap-to-edit, and an animated checkbox for quick status toggling.
- `custom_bottom_nav.dart` -- four-item bar where the Add button uses a gradient
  container; the active item expands to reveal its label with animation.
- `status_chip.dart` -- small coloured badge mapping TaskStatus to a tint and
  label.
- `empty_state.dart` -- centered placeholder used when lists are empty or search
  yields no results.

## State Management Rationale

Provider with a single ChangeNotifier was chosen because the app has one shared
data source (the task list) and straightforward read/write flows. Every screen
either reads the same list with different filters or writes back through the
same provider methods. There is no complex event-driven logic that would benefit
from a stream-based solution like Bloc, and no need for the scoping features of
Riverpod given the flat dependency graph. The result is fewer files, no code
generation, and a state layer any Flutter developer can follow without
framework-specific knowledge.

## Testing

Unit tests for the Task model live in `test/widget_test.dart`, covering
construction defaults, copyWith behaviour, isOverdue logic for open and
completed tasks, and enum extension correctness. Run with `flutter test`.
