using Toybox.WatchUi;
using Toybox.System;
using Toybox.Activity;
using Toybox.ActivityRecording;
using Toybox.Attention;

class FootballAppDelegate extends WatchUi.BehaviorDelegate {

    var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onTap(clickEvent) {
        var coords = clickEvent.getCoordinates();
        var x = coords[0];
        var y = coords[1];
        var width = System.getDeviceSettings().screenWidth;
        var height = System.getDeviceSettings().screenHeight;

        if (y > height * 0.7) {
            _view.goalieTimerStart = System.getTimer();
            if (Attention has :vibrate) {
                var vibeData = [new Attention.VibeProfile(50, 100)];
                Attention.vibrate(vibeData);
            }
        }
        else if (x < width / 2) {
            _view.scoreA += 1;
        } else {
            _view.scoreB += 1;
        }
        
        WatchUi.requestUpdate();
        return true;
    }

    function onKey(keyEvent) {
        var key = keyEvent.getKey();

        if (key == WatchUi.KEY_ENTER || key == WatchUi.KEY_START) {
            if (_view.session == null) {
                _view.session = ActivityRecording.createSession({
                    :name => "Football",
                    :sport => Activity.SPORT_SOCCER
                });
            }

            if (_view.isRecording) {
                _view.session.stop();
                _view.isRecording = false;
            } else {
                _view.session.start();
                _view.isRecording = true;
            }
            WatchUi.requestUpdate();
            return true;
        }
        
        if (key == WatchUi.KEY_ESC) {
            if (_view.session != null && _view.isRecording) {
                _view.session.stop();
                _view.session.save();
            } else if (_view.session != null) {
                _view.session.save();
            }
            return false; 
        }

        return false;
    }
}
