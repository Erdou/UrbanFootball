---
name: Defensive GPS Mode
description: Double-applied GPS with capability checks, try/catch, and SDK-required callback
type: standard
---

# Defensive GPS Mode

GPS mode is applied defensively: capability-checked, exception-wrapped, and applied at two points for redundancy. The empty callback is required by the SDK and reserved for future location features.

## Pattern

```monkeyc
function applyGpsMode() {
    if (!(Position has :enableLocationEvents)) {
        return;  // Device doesn't support positioning
    }
    try {
        if (_gpsEnabled) {
            Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPositionUpdate));
        } else {
            Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
        }
    } catch (ex) {
        // Keep the app usable even if positioning fails
    }
}

// SDK requires a callback reference even if unused
function onPositionUpdate(info as Position.Info) as Void {
    // Placeholder for future location features
}
```

## Double-application points

1. **Environment selection** (`selectEnvironment()`) — immediate mode set
2. **Session creation** (`createSessionForCurrentMode()`) — defensive re-apply before recording starts

## Rules

- Always check `Position has :enableLocationEvents` before calling
- Wrap in try/catch — positioning errors must not crash the app
- Apply at both environment selection AND session creation (guard against external state changes)
- Keep `onPositionUpdate` even if empty — SDK requires the callback reference
- Indoor = `LOCATION_DISABLE`, Outdoor = `LOCATION_CONTINUOUS`
