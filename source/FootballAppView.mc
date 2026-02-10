using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Activity;
using Toybox.Attention;
using Toybox.Timer;

class FootballAppView extends WatchUi.View {

    const GOALIE_ALERT_PULSE_INTERVAL_MS = 900;
    const GOALIE_ALERT_PULSE_DURATION_MS = 80;
    const GOALIE_ALERT_PULSE_STRENGTH = 30;

    var scoreA = 0;
    var scoreB = 0;
    var goalieTimerStart = 0;
    var goalieTimerEnabled = true;
    var goalieTimerDurationSeconds = 420;
    var footIcon = null;
    var _gameTimeLabel = null;
    
    var session = null; 
    var isRecording = false;

    var refreshTimer;
    var _lastGoalieAlertAt = null;

    function initialize() {
        View.initialize();
        goalieTimerStart = System.getTimer();
        footIcon = WatchUi.loadResource(Rez.Drawables.FootIconScore) as Graphics.BitmapType;
        _gameTimeLabel = WatchUi.loadResource(Rez.Strings.gameTimeLabel);
        
        refreshTimer = new Timer.Timer();
        refreshTimer.start(method(:onTimerTick), 1000, true);
    }

    function onTimerTick() as Void {
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
            goalieTimerStart = System.getTimer();
            _lastGoalieAlertAt = null;
        }
    }

    function getGoalieRemainingSeconds() {
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

    function formatGameTime(activityInfo) {
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

    function onLayout(dc) {
    }

    function onShow() {
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;
        var scoreFont = Graphics.FONT_NUMBER_HOT;
        var scoreY = centerY - 50;
        var scoreHeight = dc.getFontHeight(scoreFont);
        var hasTwoDigitScore = (scoreA >= 10 || scoreB >= 10);
        var scoreXOffset = hasTwoDigitScore ? 68 : 50;
        var info = Activity.getActivityInfo();

        dc.drawText(centerX - scoreXOffset, scoreY, scoreFont, scoreA.toString(), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX + scoreXOffset, scoreY, scoreFont, scoreB.toString(), Graphics.TEXT_JUSTIFY_CENTER);

        if (footIcon != null) {
            var iconY = scoreY + ((scoreHeight - footIcon.getHeight()) / 2);
            dc.drawBitmap(centerX - (footIcon.getWidth() / 2), iconY, footIcon);
        } else {
            dc.drawText(centerX, scoreY, Graphics.FONT_LARGE, "-", Graphics.TEXT_JUSTIFY_CENTER);
        }

        var gameTimeY = centerY + 38;
        var gameTime = formatGameTime(info);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, gameTimeY, Graphics.FONT_TINY, _gameTimeLabel + ": " + gameTime, Graphics.TEXT_JUSTIFY_CENTER);

        if (goalieTimerEnabled) {
            var remainingSeconds = getGoalieRemainingSeconds();
            var isOvertime = remainingSeconds < 0;
            var displaySeconds = remainingSeconds;
            var signPrefix = "";
            if (isOvertime) {
                displaySeconds = -displaySeconds;
                signPrefix = "-";
            }

            var minutes = displaySeconds / 60;
            var seconds = displaySeconds % 60;
            var timeStr = signPrefix + minutes.format("%02d") + ":" + seconds.format("%02d");

            var goalieFont = Graphics.FONT_SMALL;
            var goalieY = centerY + 74;
            var goalieMaxY = height - dc.getFontHeight(goalieFont) - 24;
            if (goalieY > goalieMaxY) {
                goalieY = goalieMaxY;
            }
            if (isOvertime) {
                dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            }
            dc.drawText(centerX, goalieY, goalieFont, "Gardien: " + timeStr, Graphics.TEXT_JUSTIFY_CENTER);
        }

        var hr = "--";
        if (info != null && info.currentHeartRate != null) {
            hr = info.currentHeartRate.toString();
        }
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 40, Graphics.FONT_MEDIUM, "FC: " + hr, Graphics.TEXT_JUSTIFY_CENTER);

        if (isRecording) {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(width - 20, 20, 5);
        } else {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(width - 20, 20, 5);
        }
    }

    function onHide() {
    }
}
