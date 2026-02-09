import Toybox.Lang;
import Toybox.WatchUi;

class FootballAppDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new FootballAppMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}