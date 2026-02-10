using Toybox.WatchUi;
using Toybox.System;
using Toybox.Activity;
using Toybox.ActivityRecording;
using Toybox.Attention;

class FootballAppDelegate extends WatchUi.BehaviorDelegate {

    const LONG_PRESS_THRESHOLD_MS = 550;
    const LONG_PRESS_DEDUPE_MS = 300;

    var _view;
    var _leftButtonDownAt = null;
    var _rightButtonDownAt = null;
    var _lastLeftLongPressAt = -LONG_PRESS_DEDUPE_MS;
    var _consumeNextUpRelease = false;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function vibrate(durationMs, strength) {
        if (Attention has :vibrate) {
            var vibeData = [new Attention.VibeProfile(durationMs, strength)];
            Attention.vibrate(vibeData);
        }
    }

    function adjustScore(isLeft, delta, withVibration) {
        if (isLeft) {
            _view.scoreA += delta;
            if (_view.scoreA < 0) {
                _view.scoreA = 0;
            }
        } else {
            _view.scoreB += delta;
            if (_view.scoreB < 0) {
                _view.scoreB = 0;
            }
        }

        if (withVibration) {
            vibrate(25, 60);
        }
        WatchUi.requestUpdate();
    }

    function handleLeftLongPress() {
        var now = System.getTimer();
        if ((now - _lastLeftLongPressAt) < LONG_PRESS_DEDUPE_MS) {
            return;
        }
        _lastLeftLongPressAt = now;
        adjustScore(true, -1, true);
    }

    function onTap(clickEvent) {
        var coords = clickEvent.getCoordinates();
        var x = coords[0];
        var y = coords[1];
        var width = System.getDeviceSettings().screenWidth;
        var height = System.getDeviceSettings().screenHeight;

        if (y > height * 0.7) {
            _view.goalieTimerStart = System.getTimer();
            vibrate(50, 100);
        }
        else if (x < width / 2) {
            _view.scoreA += 1;
        } else {
            _view.scoreB += 1;
        }
        
        WatchUi.requestUpdate();
        return true;
    }

    function onKeyPressed(keyEvent) {
        var key = keyEvent.getKey();
        var now = System.getTimer();

        if (key == WatchUi.KEY_UP) {
            _consumeNextUpRelease = false;
            _leftButtonDownAt = now;
            return true;
        }

        if (key == WatchUi.KEY_DOWN) {
            _rightButtonDownAt = now;
            return true;
        }

        return false;
    }

    function onKeyReleased(keyEvent) {
        var key = keyEvent.getKey();
        var now = System.getTimer();

        if (key == WatchUi.KEY_UP) {
            if (_consumeNextUpRelease) {
                _consumeNextUpRelease = false;
                _leftButtonDownAt = null;
                return true;
            }

            var leftLongPress = (_leftButtonDownAt != null) && ((now - _leftButtonDownAt) >= LONG_PRESS_THRESHOLD_MS);
            _leftButtonDownAt = null;

            if (leftLongPress) {
                handleLeftLongPress();
            } else {
                adjustScore(true, 1, false);
            }
            return true;
        }

        if (key == WatchUi.KEY_DOWN) {
            var rightLongPress = (_rightButtonDownAt != null) && ((now - _rightButtonDownAt) >= LONG_PRESS_THRESHOLD_MS);
            _rightButtonDownAt = null;

            if (rightLongPress) {
                adjustScore(false, -1, true);
            } else {
                adjustScore(false, 1, false);
            }
            return true;
        }

        return false;
    }

    function onMenu() {
        _consumeNextUpRelease = true;
        _leftButtonDownAt = null;
        handleLeftLongPress();
        return true;
    }

    function onKey(keyEvent) {
        var key = keyEvent.getKey();
        var keyType = keyEvent.getType();

        if (key == WatchUi.KEY_UP || key == WatchUi.KEY_DOWN) {
            return true;
        }

        if (key == WatchUi.KEY_MENU) {
            _consumeNextUpRelease = true;
            _leftButtonDownAt = null;
            handleLeftLongPress();
            return true;
        }

        if ((key == WatchUi.KEY_ENTER || key == WatchUi.KEY_START) && keyType == WatchUi.PRESS_TYPE_ACTION) {
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
        
        if (key == WatchUi.KEY_ESC && keyType == WatchUi.PRESS_TYPE_ACTION) {
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
