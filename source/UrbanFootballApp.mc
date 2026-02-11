using Toybox.Application;
using Toybox.Lang;
using Toybox.Position;
using Toybox.System;
using Toybox.WatchUi;
import Toybox.Application.Storage;

class UrbanFootballApp extends Application.AppBase {

    const RESUME_LATER_STATE_KEY = "resumeLaterState";

    var _gpsEnabled = false;
    var _goalieTimerEnabled = true;
    var _goalieTimerDurationMinutes = 7;
    var _mainView = null;
    var _mainDelegate = null;
    var _pauseMenuView = null;
    var _pauseMenuDelegate = null;
    var _resumeLaterState = null;

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
        _resumeLaterState = loadResumeLaterState();
    }

    function onStop(state) {
        if (Position has :enableLocationEvents) {
            try {
                Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
            } catch (ex) {
                // Keep stop flow safe even if location state is already invalid.
            }
        }
    }

    function getInitialView() {
        if (restoreResumeLaterStateIfAvailable()) {
            return [ _mainView, _mainDelegate ];
        }

        var selectorView = new UrbanFootballEnvironmentView();
        return [ selectorView, new UrbanFootballEnvironmentDelegate(self, selectorView) ];
    }

    function selectEnvironment(isOutdoor) as Void {
        _gpsEnabled = isOutdoor;
        applyGpsMode();
    }

    function isGpsEnabled() {
        return _gpsEnabled;
    }

    function setGoalieTimerEnabled(enabled) as Void {
        _goalieTimerEnabled = enabled;
    }

    function isGoalieTimerEnabled() {
        return _goalieTimerEnabled;
    }

    function setGoalieTimerDurationMinutes(minutes) as Void {
        if (minutes < 1) {
            _goalieTimerDurationMinutes = 1;
        } else if (minutes > 99) {
            _goalieTimerDurationMinutes = 99;
        } else {
            _goalieTimerDurationMinutes = minutes;
        }
    }

    function getGoalieTimerDurationMinutes() {
        return _goalieTimerDurationMinutes;
    }

    function applyGpsMode() as Void {
        if (!(Position has :enableLocationEvents)) {
            return;
        }

        try {
            if (_gpsEnabled) {
                Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPositionUpdate));
            } else {
                Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
            }
        } catch (ex) {
            // Keep the app usable even if positioning configuration fails.
        }
    }

    function onPositionUpdate(info as Position.Info) as Void {
    }

    function openGoalieModeView(showCancelOption) as Void {
        var view = new UrbanFootballGoalieModeView(_goalieTimerEnabled, showCancelOption);
        var delegate = new UrbanFootballGoalieModeDelegate(self, view);
        WatchUi.switchToView(view, delegate, WatchUi.SLIDE_IMMEDIATE);
    }

    function openGoalieDurationView() as Void {
        var view = new UrbanFootballGoalieDurationView(_goalieTimerDurationMinutes);
        var delegate = new UrbanFootballGoalieDurationDelegate(self, view);
        WatchUi.switchToView(view, delegate, WatchUi.SLIDE_IMMEDIATE);
    }

    function openMainViewPreservingGoalieTimer() as Void {
        openMainViewInternal(true);
    }

    function openMainView() as Void {
        openMainViewInternal(false);
    }

    function openMainViewInternal(preserveGoalieTimer) as Void {
        ensureMainActivityComponents();

        var shouldResetTimer = true;
        if (preserveGoalieTimer != null && preserveGoalieTimer) {
            shouldResetTimer = false;
        }

        if (shouldResetTimer) {
            // Starting a fresh match should not restore any deferred paused state.
            clearResumeLaterState();
        }

        _mainView.configureGoalieTimer(_goalieTimerEnabled, _goalieTimerDurationMinutes, shouldResetTimer);
        WatchUi.switchToView(_mainView, _mainDelegate, WatchUi.SLIDE_IMMEDIATE);
    }

    function openPauseMenuView() as Void {
        if (_pauseMenuView == null || _pauseMenuDelegate == null) {
            _pauseMenuView = new UrbanFootballPauseMenuView();
            _pauseMenuDelegate = new UrbanFootballPauseMenuDelegate(self, _pauseMenuView);
        }
        _pauseMenuView.resetSelection();

        WatchUi.switchToView(_pauseMenuView, _pauseMenuDelegate, WatchUi.SLIDE_IMMEDIATE);
    }

    function resumeFromPauseMenu() as Void {
        if (_mainView == null || _mainDelegate == null) {
            return;
        }

        clearResumeLaterState();

        if (_mainView.session != null) {
            _mainView.session.start();
        }
        _mainView.isRecording = true;
        _mainView.triggerStartAnimation();
        _mainDelegate.playStartFeedback();

        WatchUi.switchToView(_mainView, _mainDelegate, WatchUi.SLIDE_IMMEDIATE);
    }

    function resumeLaterFromPauseMenu() as Void {
        persistResumeLaterState();
        System.exit();
    }

    function clearResumeLaterState() as Void {
        _resumeLaterState = null;
        try {
            Storage.setValue(RESUME_LATER_STATE_KEY, null);
        } catch (ex) {
            // Keep runtime flow safe if storage is temporarily unavailable.
        }
    }

    function ensureMainActivityComponents() as Void {
        if (_mainView == null || _mainDelegate == null) {
            // Keep one activity view instance so score/session state survives settings round-trips.
            _mainView = new UrbanFootballActivityView();
            _mainDelegate = new UrbanFootballActivityDelegate(_mainView);
        }
    }

    function persistResumeLaterState() as Void {
        if (_mainView == null || !_mainView.activityStarted) {
            clearResumeLaterState();
            return;
        }

        _resumeLaterState = {
            "gpsEnabled" => _gpsEnabled,
            "goalieTimerEnabled" => _mainView.goalieTimerEnabled,
            "goalieTimerDurationSeconds" => _mainView.goalieTimerDurationSeconds,
            "goalieTimerDurationMinutes" => _mainView.goalieTimerDurationSeconds / 60,
            "scoreA" => _mainView.scoreA,
            "scoreB" => _mainView.scoreB,
            "goalieRemainingSeconds" => _mainView.getGoalieRemainingSeconds(),
            "gameTimeMs" => _mainView.getCurrentGameTimeForPersistence()
        };

        try {
            Storage.setValue(RESUME_LATER_STATE_KEY, _resumeLaterState);
        } catch (ex) {
            // If persistence fails we still exit; next launch falls back to default flow.
        }
    }

    function loadResumeLaterState() {
        try {
            return Storage.getValue(RESUME_LATER_STATE_KEY);
        } catch (ex) {
            return null;
        }
    }

    function restoreResumeLaterStateIfAvailable() {
        if (_resumeLaterState == null) {
            return false;
        }

        if (!(_resumeLaterState instanceof Lang.Dictionary)) {
            clearResumeLaterState();
            return false;
        }

        var resumeState = _resumeLaterState as Lang.Dictionary;

        try {
            var gpsEnabled = resumeState["gpsEnabled"];
            if (gpsEnabled != null) {
                _gpsEnabled = gpsEnabled;
            }

            var goalieDurationMinutes = resumeState["goalieTimerDurationMinutes"];
            if (goalieDurationMinutes != null) {
                setGoalieTimerDurationMinutes(goalieDurationMinutes);
            }

            var goalieTimerEnabled = resumeState["goalieTimerEnabled"];
            if (goalieTimerEnabled != null) {
                _goalieTimerEnabled = goalieTimerEnabled;
            }

            ensureMainActivityComponents();
            _mainView.applyResumeLaterState(resumeState);
            return true;
        } catch (ex) {
            clearResumeLaterState();
            return false;
        }
    }
}
