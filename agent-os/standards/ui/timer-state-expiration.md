---
name: Timer-Based State Expiration
description: Dual-trigger pattern for time-limited UI states (undo windows, animations)
type: standard
---

# Timer-Based State Expiration

Time-limited states (undo windows, animations, alerts) use dual triggers: a `Timer` callback AND an `onUpdate()` check. Belt-and-suspenders — timers can fire slightly late, so `onUpdate()` ensures visual consistency.

## Pattern

```monkeyc
const WINDOW_DURATION_MS = 3000;
var _expiresAt = null;
var _timer;

function initialize() {
    _timer = new Timer.Timer();
}

// Activate
function startWindow() {
    _expiresAt = System.getTimer() + WINDOW_DURATION_MS;
    _timer.start(method(:onWindowExpired), WINDOW_DURATION_MS + 30, false);
    WatchUi.requestUpdate();
}

// Check in onUpdate (visual safeguard)
function maybeExpireWindow() {
    if (_expiresAt != null && !isWindowActive()) {
        clearWindow();
    }
}

function isWindowActive() {
    return _expiresAt != null && System.getTimer() < _expiresAt;
}

// Timer callback (state cleanup)
function onWindowExpired() {
    clearWindow();
    WatchUi.requestUpdate();
}

function clearWindow() {
    _expiresAt = null;
}
```

## Rules

- Store expiry as absolute timestamp (`System.getTimer() + duration`), not relative
- Timer duration = window duration + small buffer (30ms) to avoid race
- Call `maybeExpire*()` at top of `onUpdate()` before rendering
- Always call `WatchUi.requestUpdate()` from timer callbacks
