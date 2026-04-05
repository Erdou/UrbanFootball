---
name: Activity Session Lifecycle
description: Session persists across settings trips; first-start vs resume have distinct behaviors
type: standard
---

# Activity Session Lifecycle

The recording session intentionally stays alive during settings navigation so GPS and recording continue uninterrupted. First start and resume are distinct paths.

## Session states

```
App launch → No session (session = null, activityStarted = false)
  └─ Press START → Create session + start recording (activityStarted = true)
       ├─ Press START again → Pause (isRecording = false, session stays alive)
       ├─ Navigate to settings → Session persists (view cached)
       ├─ Resume from pause → session.start() (no markActivityStarted)
       ├─ Save → session.stop() + session.save() + exit
       └─ Discard → session.stop() + session.discard() + exit
```

## First-start vs resume

```monkeyc
var firstStart = !_view.activityStarted;
_view.session.start();
_view.isRecording = true;

if (firstStart) {
    _view.markActivityStarted();   // One-time init: set flag, clear undo state
    playStartFeedback();
} else {
    _view.resumeGoalieTimer();     // Reconstruct clock reference
    _view.triggerStartAnimation(); // Show overlay on resume too
    playStartFeedback();
}
```

## Rules

- Session is created once per game, reused across pause/resume cycles
- `activityStarted` flag is set once (first start) and never reset until save/discard
- GPS mode is re-applied at session creation to ensure correct state
- View caching preserves scores, timers, and session across settings trips
- Save/discard fully resets state: session = null, isRecording = false, activityStarted = false
