using Toybox.Activity;
using Toybox.Attention;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Timer;
using Toybox.WatchUi;

class UrbanFootballActivityView extends WatchUi.View {

    const GOALIE_ALERT_PULSE_INTERVAL_MS = 900;
    const GOALIE_ALERT_PULSE_DURATION_MS = 80;
    const GOALIE_ALERT_PULSE_STRENGTH = 30;
    const START_ANIMATION_DURATION_MS = 1400;

    var scoreA = 0;
    var scoreB = 0;
    var goalieTimerStart = 0;
    var goalieTimerEnabled = true;
    var goalieTimerDurationSeconds = 420;

    var session = null;
    var isRecording = false;
    var activityStarted = false;

    var _footIcon = null;
    var _gameTimeLabel = null;
    var _preStartTitle = null;
    var _startAnimationUntil = null;
    var _lastGoalieAlertAt = null;

    var _refreshTimer;
    var _startAnimationTimer;

    var _heartRateRenderer;
    var _preStartRenderer;
    var _mainScreenRenderer;

    function initialize() {
        View.initialize();

        goalieTimerStart = System.getTimer();
        _footIcon = WatchUi.loadResource(Rez.Drawables.FootIconScore) as Graphics.BitmapType;
        _gameTimeLabel = WatchUi.loadResource(Rez.Strings.gameTimeLabel);
        _preStartTitle = WatchUi.loadResource(Rez.Strings.preStartTitle);

        _heartRateRenderer = new UrbanFootballHeartRateRenderer();
        _preStartRenderer = new UrbanFootballPreStartRenderer();
        _mainScreenRenderer = new UrbanFootballMainScreenRenderer();

        _refreshTimer = new Timer.Timer();
        _refreshTimer.start(method(:onTimerTick), 1000, true);

        _startAnimationTimer = new Timer.Timer();
    }

    function onTimerTick() as Void {
        // Central heartbeat for time-based UI updates and goalie overtime vibration.
        maybePulseGoalieAlert();
        WatchUi.requestUpdate();
    }

    function configureGoalieTimer(enabled, durationMinutes, resetTimer) as Void {
        goalieTimerEnabled = enabled;

        if (durationMinutes < 1) {
            goalieTimerDurationSeconds = 60;
        } else {
            goalieTimerDurationSeconds = durationMinutes * 60;
        }

        if (resetTimer == null || resetTimer) {
            // Preserve timer only when returning from in-activity settings.
            goalieTimerStart = System.getTimer();
            _lastGoalieAlertAt = null;
        }
    }

    function getGoalieRemainingSeconds() {
        if (!activityStarted) {
            return goalieTimerDurationSeconds;
        }

        var now = System.getTimer();
        var elapsedSeconds = (now - goalieTimerStart) / 1000;
        return goalieTimerDurationSeconds - elapsedSeconds;
    }

    function maybePulseGoalieAlert() as Void {
        if (!goalieTimerEnabled || !(Attention has :vibrate)) {
            _lastGoalieAlertAt = null;
            return;
        }

        var remainingSeconds = getGoalieRemainingSeconds();
        if (remainingSeconds >= 0) {
            _lastGoalieAlertAt = null;
            return;
        }

        var now = System.getTimer();
        if (_lastGoalieAlertAt != null && ((now - _lastGoalieAlertAt) < GOALIE_ALERT_PULSE_INTERVAL_MS)) {
            return;
        }

        var vibeData = [new Attention.VibeProfile(GOALIE_ALERT_PULSE_DURATION_MS, GOALIE_ALERT_PULSE_STRENGTH)];
        Attention.vibrate(vibeData);
        _lastGoalieAlertAt = now;
    }

    function formatGoalieTime(remainingSeconds) {
        var isOvertime = remainingSeconds < 0;
        var displaySeconds = remainingSeconds;
        var signPrefix = "";
        if (isOvertime) {
            displaySeconds = -displaySeconds;
            signPrefix = "-";
        }

        var minutes = displaySeconds / 60;
        var seconds = displaySeconds % 60;
        return signPrefix + minutes.format("%02d") + ":" + seconds.format("%02d");
    }

    function formatGameTime(activityInfo) {
        if (!activityStarted) {
            return "--:--";
        }

        var totalMs = 0;
        if (activityInfo != null) {
            if (activityInfo.timerTime != null) {
                totalMs = activityInfo.timerTime;
            } else if (activityInfo.elapsedTime != null) {
                totalMs = activityInfo.elapsedTime;
            }
        }

        var totalSeconds = totalMs / 1000;
        if (totalSeconds < 0) {
            totalSeconds = 0;
        }

        var hours = totalSeconds / 3600;
        var minutes = (totalSeconds % 3600) / 60;
        var seconds = totalSeconds % 60;

        if (hours > 0) {
            return hours.toString() + ":" + minutes.format("%02d") + ":" + seconds.format("%02d");
        }

        return minutes.format("%02d") + ":" + seconds.format("%02d");
    }

    function triggerStartAnimation() as Void {
        _startAnimationUntil = System.getTimer() + START_ANIMATION_DURATION_MS;
        _startAnimationTimer.start(method(:onStartAnimationEndTick), START_ANIMATION_DURATION_MS + 30, false);
        WatchUi.requestUpdate();
    }

    function markActivityStarted() as Void {
        // Goalie timing starts from real activity start, not from screen entry.
        activityStarted = true;
        goalieTimerStart = System.getTimer();
        _lastGoalieAlertAt = null;
        triggerStartAnimation();
    }

    function onStartAnimationEndTick() as Void {
        WatchUi.requestUpdate();
    }

    function isStartAnimationActive() {
        return (_startAnimationUntil != null) && (System.getTimer() <= _startAnimationUntil);
    }

    function onLayout(dc) {
    }

    function onShow() {
    }

    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var remainingSeconds = getGoalieRemainingSeconds();
        var goalieTimeText = formatGoalieTime(remainingSeconds);
        // Pre-start layout stays visible during the start overlay to mimic Garmin flow.
        var showPreStartScreen = !activityStarted || isStartAnimationActive();

        if (showPreStartScreen) {
            _preStartRenderer.drawScreen(dc, width, height, _footIcon, _preStartTitle, goalieTimerEnabled, goalieTimeText, !activityStarted);
        } else {
            var activityInfo = Activity.getActivityInfo();
            var hrValue = _heartRateRenderer.getHeartRateValue(activityInfo);
            var gameTime = formatGameTime(activityInfo);
            _mainScreenRenderer.drawScreen(
                dc,
                width,
                height,
                _heartRateRenderer,
                hrValue,
                _footIcon,
                scoreA,
                scoreB,
                _gameTimeLabel,
                gameTime,
                goalieTimerEnabled,
                goalieTimeText,
                remainingSeconds < 0,
                isRecording,
                activityStarted
            );
        }

        // Keep overlay and pre-start background together during start transition.
        if (isStartAnimationActive()) {
            _preStartRenderer.drawStartAnimationOverlay(dc, width, height);
        }
    }

    function onHide() {
    }
}
