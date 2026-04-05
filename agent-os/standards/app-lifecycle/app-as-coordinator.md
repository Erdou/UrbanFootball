---
name: App-as-Coordinator
description: App owns all navigation decisions and settings state; delegates communicate through it
type: standard
---

# App-as-Coordinator

The App class is the single owner of both settings state and navigation decisions. Delegates never navigate or update settings directly — they call App methods. This centralizes the view caching strategy and settings management.

## Pattern

```monkeyc
// Delegate calls App for state update + navigation
function confirmSelection() {
    _app.setGoalieTimerEnabled(true);
    _app.setGoalieTimerDurationMinutes(_view.getMinutes());
    _app.openMainView();
}
```

## Rules

- Delegates hold a reference to App (passed in constructor)
- Delegates call `_app.set*()` to update settings
- Delegates call `_app.open*View()` to navigate
- App owns all `WatchUi.switchToView()` calls
- App manages view caching (which views to create fresh vs. reuse)
- Delegates never call `WatchUi.switchToView()` directly

## Why

- Single place to manage navigation logic and view caching
- Settings validation happens in App setters, not scattered across delegates
- View lifecycle (cache vs. fresh) is decided in one place
