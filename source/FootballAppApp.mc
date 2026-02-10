using Toybox.Application;
using Toybox.Position;
using Toybox.WatchUi;

class FootballAppApp extends Application.AppBase {

    var _gpsEnabled = false;

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
        return [ new Rez.Menus.EnvironmentMenu(), new FootballAppMenuDelegate(self) ];
    }

    function selectEnvironment(isOutdoor) as Void {
        _gpsEnabled = isOutdoor;
        applyGpsMode();
    }

    function isGpsEnabled() {
        return _gpsEnabled;
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

    function openMainView() as Void {
        var view = new FootballAppView();
        var delegate = new FootballAppDelegate(view);
        WatchUi.switchToView(view, delegate, WatchUi.SLIDE_IMMEDIATE);
    }
}
