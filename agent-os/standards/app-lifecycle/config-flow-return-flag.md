---
name: Configuration Flow with Return Flag
description: App-level flag determines back navigation target for goalie settings
type: standard
---

# Configuration Flow with Return Flag

A simple boolean flag (`_goalieSettingsReturnToMain`) determines where back navigation goes from goalie settings. Simpler than a navigation stack for the current use case, though may evolve for robustness.

## Two entry points, different return targets

```
Initial setup:
  Environment → Goalie Mode → Goalie Duration → Main Activity
  (back returns to previous config screen)

In-activity settings (long-press back):
  Main Activity → Goalie Mode → Goalie Duration → Main Activity
  (back returns to main activity, preserving timer)
```

## Implementation

```monkeyc
var _goalieSettingsReturnToMain = false;

// From initial setup: back goes to environment
function openGoalieModeView(showCancelOption) {
    _goalieSettingsReturnToMain = showCancelOption == true;
    // ...
}

// Back handler checks the flag
function handleBackFromGoalieMode() {
    if (_goalieSettingsReturnToMain) {
        openMainViewPreservingGoalieTimer();  // Return to game
    } else {
        openEnvironmentView();  // Restart config flow
    }
}
```

## Rules

- Set flag to `true` when entering settings from main activity (in-game)
- Set flag to `false` when entering from initial configuration flow
- `preserveGoalieTimer` is only `true` when returning from in-activity settings
- Cancel option in goalie mode view is only shown when flag is `true`
