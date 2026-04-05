---
name: Overtime Pulse Alert
description: Interval-deduped vibration pulses when goalie timer goes into overtime
type: standard
---

# Overtime Pulse Alert

When the goalie timer goes negative (overtime), periodic vibration pulses alert the player without being overwhelming during active play. Values tuned through real-world game testing.

## Constants

```monkeyc
const GOALIE_ALERT_PULSE_INTERVAL_MS = 900;   // Time between pulses
const GOALIE_ALERT_PULSE_DURATION_MS = 80;    // Vibration length per pulse
const GOALIE_ALERT_PULSE_STRENGTH = 30;       // Vibration intensity
```

## Rules

- Only pulse when: goalie timer enabled AND recording AND remaining < 0
- De-dupe via `_lastGoalieAlertAt` timestamp (skip if < 900ms since last pulse)
- Clear `_lastGoalieAlertAt` when timer returns to non-negative (after reset)
- Check `Attention has :vibrate` before attempting vibration
- Called from `onTimerTick()` (every second), but gated by interval

## Implementation

```monkeyc
function maybePulseGoalieAlert() {
    if (!goalieTimerEnabled || !isRecording || !(Attention has :vibrate)) {
        _lastGoalieAlertAt = null;
        return;
    }
    if (getGoalieRemainingSeconds() >= 0) {
        _lastGoalieAlertAt = null;
        return;
    }
    var now = System.getTimer();
    if (_lastGoalieAlertAt != null && (now - _lastGoalieAlertAt) < GOALIE_ALERT_PULSE_INTERVAL_MS) {
        return;
    }
    Attention.vibrate([new Attention.VibeProfile(GOALIE_ALERT_PULSE_DURATION_MS, GOALIE_ALERT_PULSE_STRENGTH)]);
    _lastGoalieAlertAt = now;
}
```
