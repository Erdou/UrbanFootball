using Toybox.WatchUi;

class FootballAppMenuDelegate extends WatchUi.MenuInputDelegate {

    var _app;

    function initialize(app) {
        MenuInputDelegate.initialize();
        _app = app;
    }

    function onMenuItem(item) as Void {
        if (item == :modeIndoor) {
            _app.selectEnvironment(false);
            _app.openMainView();
        } else if (item == :modeOutdoor) {
            _app.selectEnvironment(true);
            _app.openMainView();
        }
    }
}
