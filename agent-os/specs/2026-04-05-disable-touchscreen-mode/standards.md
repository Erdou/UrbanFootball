# Standards for Disable Touchscreen Mode

## app-lifecycle/app-as-coordinator

App owns all navigation and settings state. Delegates call `_app.set*()` for state and `_app.open*View()` for navigation. Delegates never call `WatchUi.switchToView()` directly.

## ui/input-state-machine

Garmin SDK fires both `onKey(KEY_ESC)` and `onBack()` for ESC button. Use `_consumeNextOnBack` flag in delegates that override both. Only `onTap()` is gated by this feature — key handlers are unaffected.

## resources/string-key-naming

String IDs use `{feature}{Element}{Suffix}` camelCase pattern. For this feature: `settingDisableTouchscreenTitle`.

## resources/localization-scope

Only strings are localized (35 langs). New strings must be added to all `resources-{lang}/strings/strings.xml` files with complete parity.
