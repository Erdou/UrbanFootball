using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Lang;

class FootballAppApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
    }

    function onStop(state) {
    }

    function getInitialView() {
        var view = new FootballAppView();
        var delegate = new FootballAppDelegate(view);
        return [ view, delegate ];
    }
}