using Toybox.System;
using Toybox.WatchUi;

class UrbanFootballSaveConfirmDelegate extends WatchUi.BehaviorDelegate {

    var _app;
    var _view;

    function initialize(app, view) {
        BehaviorDelegate.initialize();
        _app = app;
        _view = view;
    }

    function onKey(keyEvent) {
        if (keyEvent.getType() != WatchUi.PRESS_TYPE_ACTION) {
            return false;
        }

        var key = keyEvent.getKey();
        if (key == WatchUi.KEY_DOWN) {
            _app.returnToPauseMenuFromSaveConfirm();
            return true;
        }

        if (key == WatchUi.KEY_START || key == WatchUi.KEY_ENTER) {
            _app.saveFromPauseMenu();
            return true;
        }

        return true;
    }

    function onTap(clickEvent) {
        var coords = clickEvent.getCoordinates();
        var x = coords[0];
        var y = coords[1];
        var width = System.getDeviceSettings().screenWidth;
        var height = System.getDeviceSettings().screenHeight;

        if (_view.isTapOnBackAction(x, y, width, height)) {
            _app.returnToPauseMenuFromSaveConfirm();
            return true;
        }

        if (_view.isTapOnSaveAction(x, y, width, height)) {
            _app.saveFromPauseMenu();
            return true;
        }

        return true;
    }
}
