---
name: Haptic Feedback Conventions
description: Two-tier haptic helpers — defensive for critical flows, simple for gameplay
type: standard
---

# Haptic Feedback Conventions

Two vibration helpers with different error-handling philosophies. Critical flows (save/discard) must never crash, so they use try/catch + tone. Gameplay uses a simpler helper.

## Critical flows (App)

```monkeyc
function playConfirmationFeedback(tone, vibeDurationMs, vibeStrength) {
    if (Attention has :playTone) {
        try { Attention.playTone(tone); }
        catch (ex) {}  // Some devices don't support all tones
    }
    if (Attention has :vibrate) {
        try { Attention.vibrate([new Attention.VibeProfile(vibeDurationMs, vibeStrength)]); }
        catch (ex) {}
    }
}

// Usage:
playConfirmationFeedback(Attention.TONE_SUCCESS, 22, 62);  // Save
playConfirmationFeedback(Attention.TONE_FAILURE, 22, 62);   // Discard
```

## Gameplay (Delegate)

```monkeyc
function vibrate(durationMs, strength) {
    if (Attention has :vibrate) {
        Attention.vibrate([new Attention.VibeProfile(durationMs, strength)]);
    }
}

// Usage:
vibrate(25, 60);   // Score increment
vibrate(50, 100);  // Score decrement (stronger)
```

## Rules

- Always check `Attention has :vibrate` / `has :playTone` before calling
- Critical flows: use App helper with try/catch (save, discard, exit)
- Gameplay: use Delegate helper without try/catch (score, timer alerts)
- Use TONE_SUCCESS for save, TONE_FAILURE for discard
- Stronger vibration (higher duration/strength) for more impactful actions
