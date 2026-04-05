# Disable Touchscreen Mode — Implementation Plan

## Context

Users playing football with the watch may accidentally trigger tap actions on the touchscreen during active play. This feature adds a **Garmin Connect app setting** to disable all touchscreen input across the app. When disabled, only physical buttons work. The setting is configured in the Garmin Connect companion app on the user's phone, not within the watch app itself.

## Approach

Add a boolean property `disableTouchscreen` to the Garmin Connect IQ properties/settings system. The App class reads and caches this value. Each delegate's `onTap()` method checks the cached value and returns early if touchscreen is disabled.

No new View/Delegate screens needed — this is a settings-only change.

## Files to Create

- `resources/settings/properties.xml` — Property definition (boolean, default false)
- `resources/settings/settings.xml` — Garmin Connect companion app toggle UI

## Files to Modify

- `resources/strings/strings.xml` — Add `settingDisableTouchscreenTitle` string
- `source/UrbanFootballApp.mc` — Add `_touchscreenDisabled` field, `loadSettings()`, `isTouchscreenDisabled()`, `onSettingsChanged()`
- `source/UrbanFootballActivityDelegate.mc` — Add onTap guard (uses `Application.getApp()`)
- `source/UrbanFootballEnvironmentDelegate.mc` — Add onTap guard (has `_app`)
- `source/UrbanFootballPauseMenuDelegate.mc` — Add onTap guard (has `_app`)
- `source/UrbanFootballGoalieModeDelegate.mc` — Add onTap guard (has `_app`)
- `source/UrbanFootballGoalieDurationDelegate.mc` — Add onTap guard (has `_app`)
- `source/UrbanFootballDiscardConfirmDelegate.mc` — Add onTap guard (has `_app`)
- `source/UrbanFootballSaveConfirmDelegate.mc` — Add onTap guard (has `_app`)

## Files NOT Modified

- `UrbanFootballSavedDelegate.mc` — Already returns true from onTap without processing
- `UrbanFootballDiscardedDelegate.mc` — Same, no-op onTap

## Tasks

### Task 1: Save spec documentation

Create `agent-os/specs/2026-04-05-disable-touchscreen-mode/` with plan.md, shape.md, standards.md, references.md.

### Task 2: Create settings infrastructure

Create `resources/settings/properties.xml`:
```xml
<properties>
    <property id="disableTouchscreen" type="boolean">false</property>
</properties>
```

Create `resources/settings/settings.xml`:
```xml
<settings>
    <setting propertyKey="@Properties.disableTouchscreen"
             title="@Strings.settingDisableTouchscreenTitle">
        <settingConfig type="boolean" />
    </setting>
</settings>
```

Add to `resources/strings/strings.xml`:
```xml
<string id="settingDisableTouchscreenTitle">Disable touchscreen</string>
```

### Task 3: Add setting to App class

In `UrbanFootballApp.mc`:

1. Add field: `var _touchscreenDisabled = false;`
2. Add `loadSettings()` method — reads `Application.Properties.getValue("disableTouchscreen")` with try/catch and type check
3. Add `isTouchscreenDisabled()` accessor
4. Add `onSettingsChanged()` override — calls `loadSettings()`
5. Call `loadSettings()` at end of `initialize()`

### Task 4: Gate onTap in all delegates

Add guard clause at top of each `onTap()`:

For 6 delegates with `_app`:
```monkeyc
if (_app.isTouchscreenDisabled()) {
    return true;
}
```

For ActivityDelegate (no `_app` field):
```monkeyc
var baseApp = Application.getApp();
if (baseApp instanceof UrbanFootballApp && (baseApp as UrbanFootballApp).isTouchscreenDisabled()) {
    return true;
}
```

### Task 5: Add localized strings for setting

Add `settingDisableTouchscreenTitle` to all 35 `resources-{lang}/strings/strings.xml` files with appropriate translations.

## Verification

1. Build the project — should compile without errors
2. In simulator with default setting (false): verify all tap interactions work normally
3. Change setting to true in simulator settings panel: verify all taps are silently ignored
4. Verify all button/key interactions still work when touchscreen is disabled
5. Change setting while app is running: verify `onSettingsChanged()` picks up new value without restart
