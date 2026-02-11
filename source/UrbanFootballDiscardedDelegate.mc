using Toybox.WatchUi;

class UrbanFootballDiscardedDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onKey(keyEvent) {
        // Keep the confirmation result visible for the full timeout.
        return true;
    }

    function onTap(clickEvent) {
        return true;
    }
}
