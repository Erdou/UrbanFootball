---
name: Input State Machine
description: Long-press detection, ESC/onBack consume flags, and dedupe patterns for Garmin key input
type: standard
---

# Input State Machine

Garmin SDK fires both `onKey(KEY_ESC)` and `onBack()` for the ESC/back button. Use consume flags to prevent double-handling.

## ESC/onBack Double-Fire Fix

```monkeyc
var _consumeNextOnBack = false;

function onKey(keyEvent) {
    if (keyEvent.getKey() == WatchUi.KEY_ESC) {
        _consumeNextOnBack = true;
        handleBackAction();
        return true;
    }
}

function onBack() {
    if (_consumeNextOnBack) {
        _consumeNextOnBack = false;
        return true;  // Already handled in onKey
    }
    handleBackAction();
    return true;
}
```

Apply this pattern in every delegate that overrides both `onKey` and `onBack`.

## Long-Press Detection

Track key-down timestamps and compare on release:

```monkeyc
const LONG_PRESS_THRESHOLD_MS = 550;
const LONG_PRESS_DEDUPE_MS = 300;
var _buttonDownAt = null;
var _lastLongPressAt = -LONG_PRESS_DEDUPE_MS;  // Negative init: first press always works

function onKeyPressed(keyEvent) {
    _buttonDownAt = System.getTimer();
}

function onKeyReleased(keyEvent) {
    var now = System.getTimer();
    var isLongPress = (_buttonDownAt != null) &&
                      ((now - _buttonDownAt) >= LONG_PRESS_THRESHOLD_MS);
    _buttonDownAt = null;

    if (isLongPress && (now - _lastLongPressAt) >= LONG_PRESS_DEDUPE_MS) {
        _lastLongPressAt = now;
        handleLongPress();
    } else if (!isLongPress) {
        handleShortPress();
    }
}
```

## Key rules

- Initialize dedupe timestamps to negative threshold value to avoid first-press edge case
- Always null-check `_buttonDownAt` before computing duration
- Use `_consumeNextUpRelease` when `onMenu()` also fires for UP key
