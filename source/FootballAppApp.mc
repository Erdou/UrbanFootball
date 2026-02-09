import Toybox.Activity;
import Toybox.ActivityRecording;
import Toybox.Application;
import Toybox.Lang;
import Toybox.Position;
import Toybox.Sensor;
import Toybox.System;
import Toybox.WatchUi;

class FootballAppApp extends Application.AppBase {

    private var _teamAScore as Lang.Number = 0;
    private var _teamBScore as Lang.Number = 0;
    private var _goalieTimerStartMs as Lang.Number = 0;
    private var _heartRate as Lang.Number?;
    private var _session as ActivityRecording.Session?;
    private var _isGpsEnabled as Lang.Boolean = false;
    private var _recordingSupported as Lang.Boolean = false;

    function initialize() {
        AppBase.initialize();
        _goalieTimerStartMs = System.getTimer();
        _recordingSupported = (Toybox has :ActivityRecording);
    }

    // onStart() is called on application start up
    function onStart(state as Lang.Dictionary?) as Void {
        _goalieTimerStartMs = System.getTimer();
        if (Toybox has :Sensor) {
            Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE]);
            Sensor.enableSensorEvents(method(:onSensorInfo));
        }
    }

    // onStop() is called when your application is exiting
    function onStop(state as Lang.Dictionary?) as Void {
        if (Toybox has :Sensor) {
            Sensor.enableSensorEvents(null);
        }
        saveSessionIfNeeded();
        setGpsTracking(false);
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [new FootballAppView(), new FootballAppDelegate()];
    }

    function onSensorInfo(info as Sensor.Info) as Void {
        _heartRate = info.heartRate;
        WatchUi.requestUpdate();
    }

    function onPosition(info as Position.Info) as Void {
    }

    function incrementTeamAScore() as Void {
        _teamAScore += 1;
    }

    function incrementTeamBScore() as Void {
        _teamBScore += 1;
    }

    function getTeamAScore() as Lang.Number {
        return _teamAScore;
    }

    function getTeamBScore() as Lang.Number {
        return _teamBScore;
    }

    function resetGoalieTimer() as Void {
        _goalieTimerStartMs = System.getTimer();
    }

    function getGoalieTimerSeconds() as Lang.Number {
        var elapsedMs = System.getTimer() - _goalieTimerStartMs;

        if (elapsedMs < 0) {
            return 0;
        }

        return elapsedMs / 1000;
    }

    function getHeartRate() as Lang.Number? {
        return _heartRate;
    }

    function isRecordingSupported() as Lang.Boolean {
        return _recordingSupported;
    }

    function isRecording() as Lang.Boolean {
        return (_session != null) && _session.isRecording();
    }

    function toggleRecording() as Lang.Boolean {
        if (!_recordingSupported) {
            return false;
        }

        if (_session == null) {
            _session = ActivityRecording.createSession({
                :name => "Football Match",
                :sport => Activity.SPORT_SOCCER
            });
        }

        if ((_session != null) && _session.isRecording()) {
            var stopped = _session.stop();
            if (stopped) {
                setGpsTracking(false);
            }
            return stopped;
        }

        setGpsTracking(true);
        if (_session == null) {
            return false;
        }

        var started = _session.start();
        if (!started) {
            setGpsTracking(false);
        }
        return started;
    }

    function stopSaveAndExit() as Void {
        saveSessionIfNeeded();
        setGpsTracking(false);
        System.exit();
    }

    function saveSessionIfNeeded() as Void {
        if (_session == null) {
            return;
        }

        if (_session.isRecording()) {
            _session.stop();
        }

        _session.save();
        _session = null;
    }

    function setGpsTracking(enable as Lang.Boolean) as Void {
        if (enable == _isGpsEnabled) {
            return;
        }

        if (enable) {
            Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
        } else {
            Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
        }

        _isGpsEnabled = enable;
    }

}

function getApp() as FootballAppApp {
    return Application.getApp() as FootballAppApp;
}
