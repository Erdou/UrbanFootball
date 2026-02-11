using Toybox.System;
using Toybox.WatchUi;

class UrbanFootballGoalieDurationDelegate extends WatchUi.BehaviorDelegate {

    var _app;
    var _view;

    function initialize(app, view) {
        BehaviorDelegate.initialize();
        _app = app;
        _view = view;
    }

    function confirmSelection() as Void {
        _app.setGoalieTimerEnabled(true);
        _app.setGoalieTimerDurationMinutes(_view.getMinutes());
        _app.openMainView();
    }

    function onKey(keyEvent) {
        if (keyEvent.getType() != WatchUi.PRESS_TYPE_ACTION) {
            return false;
        }

        var key = keyEvent.getKey();
        if (key == WatchUi.KEY_UP) {
            _view.incrementMinutes();
            return true;
        } else if (key == WatchUi.KEY_DOWN) {
            _view.decrementMinutes();
            return true;
        } else if (key == WatchUi.KEY_START || key == WatchUi.KEY_ENTER) {
            confirmSelection();
            return true;
        }

        return false;
    }

    function onTap(clickEvent) {
        var coords = clickEvent.getCoordinates();
        var x = coords[0];
        var y = coords[1];
        var width = System.getDeviceSettings().screenWidth;
        var height = System.getDeviceSettings().screenHeight;

        if (_view.isTapOnMinus(x, y, width, height)) {
            _view.decrementMinutes();
        } else if (_view.isTapOnPlus(x, y, width, height)) {
            _view.incrementMinutes();
        } else if (_view.isTapOnValue(x, y, width, height) || _view.isTapOnConfirm(x, y, width, height)) {
            confirmSelection();
        }

        return true;
    }
}
