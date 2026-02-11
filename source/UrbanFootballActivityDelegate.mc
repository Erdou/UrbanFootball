using Toybox.Activity;
using Toybox.ActivityRecording;
using Toybox.Application;
using Toybox.Attention;
using Toybox.System;
using Toybox.Timer;
using Toybox.WatchUi;

class UrbanFootballActivityDelegate extends WatchUi.BehaviorDelegate {

    const MAX_SCORE = 99;
    const LONG_PRESS_THRESHOLD_MS = 550;
    const BACK_LONG_PRESS_THRESHOLD_MS = 700;
    const LONG_PRESS_DEDUPE_MS = 300;
    const BACK_RESET_DEDUPE_MS = 250;

    var _view;
    var _leftButtonDownAt = null;
    var _rightButtonDownAt = null;
    var _backButtonDownAt = null;
    var _lastLeftLongPressAt = -LONG_PRESS_DEDUPE_MS;
    var _consumeNextUpRelease = false;
    var _suppressNextOnBack = false;
    var _lastBackResetAt = -BACK_RESET_DEDUPE_MS;
    var _pauseMenuTimer = null;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
        _pauseMenuTimer = new Timer.Timer();
    }

    function vibrate(durationMs, strength) {
        if (Attention has :vibrate) {
            var vibeData = [new Attention.VibeProfile(durationMs, strength)];
            Attention.vibrate(vibeData);
        }
    }

    function playStartFeedback() as Void {
        // Mirrors the official activity start cue: one tone + a short light haptic pulse.
        if (Attention has :playTone) {
            try {
                Attention.playTone(Attention.TONE_START);
            } catch (ex) {
                // Some devices may not expose tone output at runtime.
            }
        }

        if (Attention has :vibrate) {
            try {
                Attention.vibrate([new Attention.VibeProfile(20, 60)]);
            } catch (ex) {
                // Keep start flow alive even if haptics are unavailable.
            }
        }
    }

    function playPauseFeedback() as Void {
        // Matches Garmin-style pause cue: stop tone with a light pulse.
        if (Attention has :playTone) {
            try {
                Attention.playTone(Attention.TONE_STOP);
            } catch (ex) {
                // Some devices may not expose tone output at runtime.
            }
        }

        if (Attention has :vibrate) {
            try {
                Attention.vibrate([new Attention.VibeProfile(24, 65)]);
            } catch (ex) {
                // Keep pause flow alive even if haptics are unavailable.
            }
        }
    }

    function showPauseMenuAfterOverlay() as Void {
        _pauseMenuTimer.start(method(:onPauseOverlayFinished), _view.getPauseAnimationDurationMs() + 40, false);
    }

    function onPauseOverlayFinished() as Void {
        var app = Application.getApp() as UrbanFootballApp;
        if (app != null) {
            app.openPauseMenuView();
        }
    }

    function adjustScore(isLeft, delta, withVibration) {
        // Ignore scoring inputs on the pre-start screen.
        if (!_view.activityStarted || !_view.isRecording) {
            return;
        }

        if (isLeft) {
            _view.scoreA += delta;
            if (_view.scoreA < 0) {
                _view.scoreA = 0;
            } else if (_view.scoreA > MAX_SCORE) {
                _view.scoreA = MAX_SCORE;
            }
        } else {
            _view.scoreB += delta;
            if (_view.scoreB < 0) {
                _view.scoreB = 0;
            } else if (_view.scoreB > MAX_SCORE) {
                _view.scoreB = MAX_SCORE;
            }
        }

        if (withVibration) {
            vibrate(25, 60);
        }
        WatchUi.requestUpdate();
    }

    function handleLeftLongPress() {
        var now = System.getTimer();
        // Ignore repeated key-repeat events while the same long press is held.
        if ((now - _lastLeftLongPressAt) < LONG_PRESS_DEDUPE_MS) {
            return;
        }

        _lastLeftLongPressAt = now;
        adjustScore(true, -1, true);
    }

    function resetGoalieTimer(withVibration) {
        if (!_view.goalieTimerEnabled) {
            return;
        }

        _view.goalieTimerStart = System.getTimer();
        if (withVibration) {
            vibrate(50, 100);
        }
        WatchUi.requestUpdate();
    }

    function handleBackReset() {
        if (!_view.goalieTimerEnabled) {
            return;
        }

        var now = System.getTimer();
        // ESC may arrive through multiple paths; de-dupe to avoid double resets.
        if ((now - _lastBackResetAt) < BACK_RESET_DEDUPE_MS) {
            return;
        }

        _lastBackResetAt = now;
        resetGoalieTimer(true);
    }

    function createSessionForCurrentMode() {
        var sessionName = "Urban Football";
        var baseApp = Application.getApp();
        if (baseApp instanceof UrbanFootballApp) {
            var app = baseApp as UrbanFootballApp;
            if (app.isGpsEnabled()) {
                sessionName = "Urban Football Ext";
            } else {
                sessionName = "Urban Football Int";
            }
            app.applyGpsMode();
        }

        _view.session = ActivityRecording.createSession({
            :name => sessionName,
            :sport => Activity.SPORT_SOCCER
        });
    }

    function openGoalieConfiguration() as Void {
        var app = Application.getApp() as UrbanFootballApp;
        app.openGoalieModeView(true);
    }

    function onTap(clickEvent) {
        if (!_view.activityStarted || !_view.isRecording || _view.isPauseAnimationActive()) {
            return true;
        }

        var coords = clickEvent.getCoordinates();
        var x = coords[0];
        var y = coords[1];
        var width = System.getDeviceSettings().screenWidth;
        var height = System.getDeviceSettings().screenHeight;

        if (_view.goalieTimerEnabled && y > height * 0.7) {
            resetGoalieTimer(true);
            return true;
        }

        if (x < width / 2) {
            adjustScore(true, 1, false);
        } else {
            adjustScore(false, 1, false);
        }

        return true;
    }

    function onKeyPressed(keyEvent) {
        var key = keyEvent.getKey();
        var now = System.getTimer();

        if (key == WatchUi.KEY_UP) {
            _consumeNextUpRelease = false;
            _leftButtonDownAt = now;
            return true;
        }

        if (key == WatchUi.KEY_DOWN) {
            _rightButtonDownAt = now;
            return true;
        }

        if (key == WatchUi.KEY_ESC) {
            _backButtonDownAt = now;
            return true;
        }

        return false;
    }

    function onKeyReleased(keyEvent) {
        var key = keyEvent.getKey();
        var now = System.getTimer();

        if (key == WatchUi.KEY_UP) {
            if (_consumeNextUpRelease) {
                _consumeNextUpRelease = false;
                _leftButtonDownAt = null;
                return true;
            }

            var leftLongPress = (_leftButtonDownAt != null) && ((now - _leftButtonDownAt) >= LONG_PRESS_THRESHOLD_MS);
            _leftButtonDownAt = null;

            if (leftLongPress) {
                handleLeftLongPress();
            } else {
                adjustScore(true, 1, false);
            }
            return true;
        }

        if (key == WatchUi.KEY_DOWN) {
            var rightLongPress = (_rightButtonDownAt != null) && ((now - _rightButtonDownAt) >= LONG_PRESS_THRESHOLD_MS);
            _rightButtonDownAt = null;

            if (rightLongPress) {
                adjustScore(false, -1, true);
            } else {
                adjustScore(false, 1, false);
            }
            return true;
        }

        if (key == WatchUi.KEY_ESC) {
            var backLongPress = (_backButtonDownAt != null) && ((now - _backButtonDownAt) >= BACK_LONG_PRESS_THRESHOLD_MS);
            _backButtonDownAt = null;

            if (backLongPress) {
                // Consume the paired onBack callback after opening settings.
                _suppressNextOnBack = true;
                openGoalieConfiguration();
            } else {
                handleBackReset();
            }
            return true;
        }

        return false;
    }

    function onMenu() {
        _consumeNextUpRelease = true;
        _leftButtonDownAt = null;
        handleLeftLongPress();
        return true;
    }

    function onBack() {
        if (_suppressNextOnBack) {
            _suppressNextOnBack = false;
            return true;
        }

        handleBackReset();
        return true;
    }

    function onKey(keyEvent) {
        var key = keyEvent.getKey();
        var keyType = keyEvent.getType();

        if (key == WatchUi.KEY_UP || key == WatchUi.KEY_DOWN || key == WatchUi.KEY_ESC) {
            return true;
        }

        if (key == WatchUi.KEY_MENU) {
            _consumeNextUpRelease = true;
            _leftButtonDownAt = null;
            handleLeftLongPress();
            return true;
        }

        if ((key == WatchUi.KEY_ENTER || key == WatchUi.KEY_START) && keyType == WatchUi.PRESS_TYPE_ACTION) {
            if (_view.isPauseAnimationActive()) {
                return true;
            }

            if (_view.session == null) {
                createSessionForCurrentMode();
            }

            if (_view.isRecording) {
                _view.session.stop();
                _view.isRecording = false;
                _view.triggerPauseAnimation();
                playPauseFeedback();
                showPauseMenuAfterOverlay();
            } else {
                var firstStart = !_view.activityStarted;
                _view.session.start();
                _view.isRecording = true;
                if (firstStart) {
                    // First start initializes runtime counters and launch overlay once.
                    _view.markActivityStarted();
                    playStartFeedback();
                }
            }

            WatchUi.requestUpdate();
            return true;
        }

        return false;
    }
}
