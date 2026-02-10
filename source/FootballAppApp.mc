using Toybox.Application;
using Toybox.Position;
using Toybox.WatchUi;

class FootballAppApp extends Application.AppBase {

    var _gpsEnabled = false;
    var _goalieTimerEnabled = true;
    var _goalieTimerDurationMinutes = 7;
    var _mainView = null;
    var _mainDelegate = null;

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
    }

    function onStop(state) {
        if (Position has :enableLocationEvents) {
            try {
                Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
            } catch (ex) {
                // Ignore failures during shutdown.
            }
        }
    }

    function getInitialView() {
        var selectorView = new FootballAppEnvironmentView();
        return [ selectorView, new FootballAppMenuDelegate(self, selectorView) ];
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
        var view = new FootballAppGoalieModeView(_goalieTimerEnabled, showCancelOption);
        var delegate = new FootballAppGoalieModeDelegate(self, view);
        WatchUi.switchToView(view, delegate, WatchUi.SLIDE_IMMEDIATE);
    }

    function openGoalieDurationView() as Void {
        var view = new FootballAppGoalieDurationView(_goalieTimerDurationMinutes);
        var delegate = new FootballAppGoalieDurationDelegate(self, view);
        WatchUi.switchToView(view, delegate, WatchUi.SLIDE_IMMEDIATE);
    }

    function openMainViewPreservingGoalieTimer() as Void {
        openMainViewInternal(true);
    }

    function openMainView() as Void {
        openMainViewInternal(false);
    }

    function openMainViewInternal(preserveGoalieTimer) as Void {
        if (_mainView == null || _mainDelegate == null) {
            _mainView = new FootballAppView();
            _mainDelegate = new FootballAppDelegate(_mainView);
        }

        var shouldResetTimer = true;
        if (preserveGoalieTimer != null && preserveGoalieTimer) {
            shouldResetTimer = false;
        }

        _mainView.configureGoalieTimer(_goalieTimerEnabled, _goalieTimerDurationMinutes, shouldResetTimer);
        WatchUi.switchToView(_mainView, _mainDelegate, WatchUi.SLIDE_IMMEDIATE);
    }
}
