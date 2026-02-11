using Toybox.WatchUi;

class UrbanFootballPauseMenuDelegate extends WatchUi.BehaviorDelegate {

    var _app;
    var _view;

    function initialize(app, view) {
        BehaviorDelegate.initialize();
        _app = app;
        _view = view;
    }

    function confirmSelection() as Void {
        if (_view.isResumeSelection()) {
            _app.resumeFromPauseMenu();
            return;
        }

        if (_view.isResumeLaterSelection()) {
            _app.resumeLaterFromPauseMenu();
            return;
        }

        // Other actions are intentionally left unimplemented for now.
    }

    function onKey(keyEvent) {
        if (keyEvent.getType() != WatchUi.PRESS_TYPE_ACTION) {
            return false;
        }

        var key = keyEvent.getKey();
        if (key == WatchUi.KEY_UP) {
            _view.moveSelection(-1);
            return true;
        } else if (key == WatchUi.KEY_DOWN) {
            _view.moveSelection(1);
            return true;
        } else if (key == WatchUi.KEY_START || key == WatchUi.KEY_ENTER) {
            confirmSelection();
            return true;
        }

        return false;
    }

    function onTap(clickEvent) {
        var coords = clickEvent.getCoordinates();
        var y = coords[1];
        _view.selectFromTap(y);
        confirmSelection();
        return true;
    }
}
