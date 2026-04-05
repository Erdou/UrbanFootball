---
name: View Caching Strategy
description: When to cache vs. recreate View-Delegate pairs during navigation
type: standard
---

# View Caching Strategy

Caching is about state preservation, not performance. Cache views that hold important mutable state; recreate views where stale state would confuse the user.

## Rules

| View type | Strategy | Why |
|-----------|----------|-----|
| Main activity | Cache in App | Preserves scores, session, timers across screen transitions |
| Pause menu | Cache + reset selection | Preserves menu structure but resets cursor position |
| Config screens | Create fresh | Avoids showing stale selections from previous visits |
| Confirmation dialogs | Cache (stateless) | No meaningful state to preserve or reset |
| Result screens | Cache (stateless) | Just display a message, no state concerns |

## Implementation

```monkeyc
// App holds cached references
var _mainView = null;
var _mainDelegate = null;

// Lazy-init: create once, reuse forever
function ensureMainActivityComponents() {
    if (_mainView == null || _mainDelegate == null) {
        _mainView = new UrbanFootballActivityView();
        _mainDelegate = new UrbanFootballActivityDelegate(_mainView);
    }
}

// Config views: always fresh
function openEnvironmentView() {
    var view = new UrbanFootballEnvironmentView();
    var delegate = new UrbanFootballEnvironmentDelegate(self, view);
    WatchUi.switchToView(view, delegate, WatchUi.SLIDE_IMMEDIATE);
}

// Cached + reset: preserve structure, reset position
function openPauseMenuView() {
    if (_pauseMenuView == null) {
        _pauseMenuView = new UrbanFootballPauseMenuView();
        _pauseMenuDelegate = new UrbanFootballPauseMenuDelegate(self, _pauseMenuView);
    }
    _pauseMenuView.resetSelection();
    WatchUi.switchToView(_pauseMenuView, _pauseMenuDelegate, WatchUi.SLIDE_IMMEDIATE);
}
```

## Decision guide

- View holds game/session state → cache
- View has a selection that should reset → cache + reset
- View is a one-time config picker → create fresh
