---
name: Goalie Timer State Machine
description: Clock-reference-based countdown timer that survives app suspend/resume
type: standard
---

# Goalie Timer State Machine

The goalie timer uses absolute clock references (`System.getTimer()`) instead of accumulated elapsed time. This ensures the timer stays accurate even if the app is suspended and resumed by the OS.

## Three states

| State | Condition | `getGoalieRemainingSeconds()` returns |
|-------|-----------|--------------------------------------|
| Pre-activity | `!activityStarted` | Full duration (static) |
| Running | `isRecording` | Live countdown from clock |
| Paused | `!isRecording && _goaliePausedRemainingSeconds != null` | Frozen snapshot |

## Pause/Resume semantics

```monkeyc
// Pause: snapshot remaining time from clock
function pauseGoalieTimer() {
    _goaliePausedRemainingSeconds = computeGoalieRemainingFromClock(System.getTimer());
    _lastGoalieAlertAt = null;  // Clear pending alert
}

// Resume: recalculate clock reference from snapshot
function resumeGoalieTimer() {
    var elapsed = goalieTimerDurationSeconds - _goaliePausedRemainingSeconds;
    goalieTimerStart = System.getTimer() - (elapsed * 1000);
    _goaliePausedRemainingSeconds = null;
}

// Reset: restart from full duration
function resetGoalieTimer() {
    goalieTimerStart = System.getTimer();
    _goaliePausedRemainingSeconds = null;
    _lastGoalieAlertAt = null;
}
```

## Key rule

- `goalieTimerStart` is the single source of truth for running state
- `_goaliePausedRemainingSeconds` is only a snapshot used during pause
- On resume, reconstruct `goalieTimerStart` from the snapshot, don't use the snapshot as a new countdown base
- Clear alert state (`_lastGoalieAlertAt`) on pause, resume, and reset
