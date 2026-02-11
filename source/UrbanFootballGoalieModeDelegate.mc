using Toybox.WatchUi;

class UrbanFootballGoalieModeDelegate extends WatchUi.BehaviorDelegate {

    var _app;
    var _view;
    var _consumeNextOnBack = false;

    function initialize(app, view) {
        BehaviorDelegate.initialize();
        _app = app;
        _view = view;
    }

    function confirmSelection() as Void {
        if (_view.isCancelSelection()) {
            _app.openMainViewPreservingGoalieTimer();
        } else if (_view.isTimerEnabledSelection()) {
            _app.setGoalieTimerEnabled(true);
            _app.openGoalieDurationView();
        } else {
            _app.setGoalieTimerEnabled(false);
            _app.openMainView();
        }
    }

    function handleBackAction() as Void {
        _app.handleBackFromGoalieMode();
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
        } else if (key == WatchUi.KEY_ESC) {
            _consumeNextOnBack = true;
            handleBackAction();
            return true;
        } else if (key == WatchUi.KEY_START || key == WatchUi.KEY_ENTER) {
            confirmSelection();
            return true;
        }

        return false;
    }

    function onBack() {
        if (_consumeNextOnBack) {
            _consumeNextOnBack = false;
            return true;
        }

        handleBackAction();
        return true;
    }

    function onTap(clickEvent) {
        var coords = clickEvent.getCoordinates();
        var y = coords[1];
        _view.selectFromTap(y);
        confirmSelection();
        return true;
    }
}
