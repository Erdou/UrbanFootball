# References for Disable Touchscreen Mode

## Similar Implementations

### Goalie Timer Settings (App-as-Coordinator)

- **Location:** `source/UrbanFootballApp.mc` (lines 12-87)
- **Relevance:** Same pattern for storing/accessing a boolean setting in the App class
- **Key patterns:** `_goalieTimerEnabled` field, `setGoalieTimerEnabled()` setter, `isGoalieTimerEnabled()` accessor

### GPS Mode Management (Defensive Properties)

- **Location:** `source/UrbanFootballApp.mc` (lines 89-106)
- **Relevance:** Defensive pattern with `has` checks and try/catch for device capability
- **Key patterns:** Capability check before API call, silent fallback on error

### Existing onTap Handlers

- **Location:** 9 delegate files in `source/`
- **Relevance:** Every delegate that needs the guard clause
- **Key patterns:** 6 have `_app` field, ActivityDelegate uses `Application.getApp()`, Saved/Discarded are no-ops
