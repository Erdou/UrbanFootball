using Toybox.WatchUi;

class FootballAppMenuDelegate extends WatchUi.BehaviorDelegate {

    var _app;
    var _selectorView;

    function initialize(app, selectorView) {
        BehaviorDelegate.initialize();
        _app = app;
        _selectorView = selectorView;
    }

    function confirmSelection() as Void {
        _app.selectEnvironment(_selectorView.getSelectedIsOutdoor());
        _app.openGoalieModeView(false);
    }

    function onKey(keyEvent) {
        if (keyEvent.getType() != WatchUi.PRESS_TYPE_ACTION) {
            return false;
        }

        var key = keyEvent.getKey();
        if (key == WatchUi.KEY_UP) {
            _selectorView.moveSelection(-1);
            return true;
        } else if (key == WatchUi.KEY_DOWN) {
            _selectorView.moveSelection(1);
            return true;
        } else if (key == WatchUi.KEY_ENTER || key == WatchUi.KEY_START) {
            confirmSelection();
            return true;
        }

        return false;
    }

    function onTap(clickEvent) {
        var coords = clickEvent.getCoordinates();
        var y = coords[1];
        _selectorView.selectFromTap(y);
        confirmSelection();
        return true;
    }
}
