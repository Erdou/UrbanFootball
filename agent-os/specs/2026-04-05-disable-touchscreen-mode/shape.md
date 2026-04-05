# Disable Touchscreen Mode — Shaping Notes

## Scope

Add a Garmin Connect companion app setting to disable all touchscreen input across the watch app. When enabled, only physical buttons work. This prevents accidental tap actions during active football play.

## Decisions

- Setting lives in Garmin Connect companion app (not an in-app screen) — no new View/Delegate needed
- All onTap() handlers gated, not just gameplay — user chose "all taps everywhere"
- Each delegate checks the setting individually (no base class refactor — disproportionate to feature)
- ActivityDelegate uses `Application.getApp()` (doesn't hold `_app` reference)
- SavedDelegate and DiscardedDelegate already no-op on tap — no changes needed
- Default value is `false` (touchscreen enabled) — safe default for new users

## Context

- **Visuals:** None needed (setting is a toggle in Garmin Connect, no in-app UI)
- **References:** Goalie timer settings pattern (app-as-coordinator) informed the approach
- **Product alignment:** N/A (no product docs)

## Standards Applied

- app-lifecycle/app-as-coordinator — App owns the setting, delegates check via accessor
- ui/input-state-machine — ESC/onBack patterns unchanged, only onTap gated
- resources/string-key-naming — Setting string uses `setting*` prefix
- resources/localization-scope — Setting label added to all 35 locale files
