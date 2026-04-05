---
name: Save/Discard with Deferred Exit
description: Synchronous session save, then 2-second confirmation overlay before auto-exit
type: standard
---

# Save/Discard with Deferred Exit

Session operations (stop, save/discard) complete synchronously before showing the result screen. This ensures reliability — the confirmation screen is only shown if the operation succeeded. A 2-second delay gives visual feedback before auto-exit.

## Flow

```
User confirms save/discard
  → session.stop() (synchronous)
  → session.save() or session.discard() (synchronous)
  → Reset state (session=null, isRecording=false, activityStarted=false)
  → Switch to result screen (saved/discarded)
  → Play haptic feedback (TONE_SUCCESS / TONE_FAILURE)
  → Start 2-second exit timer
  → System.exit()
```

## Implementation

```monkeyc
const DISCARD_EXIT_DELAY_MS = 2000;

function saveFromPauseMenu() {
    // 1. Stop and save synchronously
    if (_mainView.isRecording) { _mainView.session.stop(); }
    _mainView.session.save();
    _mainView.session = null;
    _mainView.isRecording = false;
    _mainView.activityStarted = false;

    // 2. Show result + feedback
    WatchUi.switchToView(_savedView, _savedDelegate, WatchUi.SLIDE_IMMEDIATE);
    playConfirmationFeedback(Attention.TONE_SUCCESS, 22, 62);

    // 3. Deferred exit
    _saveExitTimer.start(method(:onSaveExitTimer), DISCARD_EXIT_DELAY_MS, false);
}
```

## Rules

- Always stop session before save/discard (wrap in try/catch)
- Reset all view state before switching to result screen
- Result screen delegates consume all input (modal — no accidental dismissal)
- Use TONE_SUCCESS for save, TONE_FAILURE for discard
- Exit timers are created once and reused, not recreated per operation
