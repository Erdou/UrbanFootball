import Toybox.Attention;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class FootballAppDelegate extends WatchUi.BehaviorDelegate {

    private var _app as FootballAppApp;
    private var _screenWidth as Lang.Number;
    private var _screenHeight as Lang.Number;

    function initialize() {
        BehaviorDelegate.initialize();
        _app = getApp();

        var deviceSettings = System.getDeviceSettings();
        _screenWidth = deviceSettings.screenWidth;
        _screenHeight = deviceSettings.screenHeight;
    }

    function onTap(clickEvent as ClickEvent) as Lang.Boolean {
        var coordinates = clickEvent.getCoordinates();
        var tapX = coordinates[0];
        var tapY = coordinates[1];
        var bottomZoneStart = (_screenHeight * 2) / 3;

        if (tapY >= bottomZoneStart) {
            _app.resetGoalieTimer();
            vibrateGoalieReset();
        } else if (tapX < (_screenWidth / 2)) {
            _app.incrementTeamAScore();
        } else {
            _app.incrementTeamBScore();
        }

        WatchUi.requestUpdate();
        return true;
    }

    function onSelect() as Lang.Boolean {
        _app.toggleRecording();
        WatchUi.requestUpdate();
        return true;
    }

    function onBack() as Lang.Boolean {
        _app.stopSaveAndExit();
        return true;
    }

    function onKey(keyEvent as KeyEvent) as Lang.Boolean {
        var key = keyEvent.getKey();

        if ((key == KEY_START) || (key == KEY_ENTER)) {
            return onSelect();
        }

        if ((key == KEY_LAP) || (key == KEY_ESC)) {
            return onBack();
        }

        return false;
    }

    function vibrateGoalieReset() as Void {
        if (Attention has :vibrate) {
            Attention.vibrate([new Attention.VibeProfile(100, 120)]);
        }
    }

}
