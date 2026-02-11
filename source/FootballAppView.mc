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
    const MAIN_BG_COLOR = Graphics.COLOR_WHITE;
    const PRIMARY_TEXT_COLOR = Graphics.COLOR_BLACK;
    const SECONDARY_TEXT_COLOR = Graphics.COLOR_DK_GRAY;
    const HR_ZONE_1_MAX_BPM = 109;
    const HR_ZONE_2_MAX_BPM = 129;
    const HR_ZONE_3_MAX_BPM = 149;
    const HR_ZONE_4_MAX_BPM = 169;
    const HR_ZONE_5_MAX_BPM = 200;
    const HR_ZONE_1_START_DEG = 155;
    const HR_ZONE_1_END_DEG = 131;
    const HR_ZONE_2_START_DEG = 129;
    const HR_ZONE_2_END_DEG = 105;
    const HR_ZONE_3_START_DEG = 103;
    const HR_ZONE_3_END_DEG = 79;
    const HR_ZONE_4_START_DEG = 77;
    const HR_ZONE_4_END_DEG = 53;
    const HR_ZONE_5_START_DEG = 51;
    const HR_ZONE_5_END_DEG = 27;
    const HR_HEADER_DIVIDER_Y = 86;

    var scoreA = 0;
    var scoreB = 0;
    var goalieTimerStart = 0;
    var goalieTimerEnabled = true;
    var goalieTimerDurationSeconds = 420;
    var footIcon = null;
    var _gameTimeLabel = null;
    
    var session = null; 
    var isRecording = false;
    var activityStarted = false;

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

    function clampValue(value, minValue, maxValue) {
        if (value < minValue) {
            return minValue;
        }
        if (value > maxValue) {
            return maxValue;
        }
        return value;
    }

    function interpolateRange(value, inMin, inMax, outMin, outMax) {
        if (inMax <= inMin) {
            return outMin;
        }

        var clamped = clampValue(value, inMin, inMax);
        var ratio = (clamped - inMin) * 1.0 / (inMax - inMin);
        return outMin + ((outMax - outMin) * ratio);
    }

    function getHeartRateValue(info) {
        if (info != null && info.currentHeartRate != null) {
            return info.currentHeartRate;
        }
        return null;
    }

    function getHrZoneColor(hrValue) {
        if (hrValue == null) {
            return Graphics.COLOR_DK_GRAY;
        } else if (hrValue <= HR_ZONE_1_MAX_BPM) {
            return Graphics.COLOR_DK_GRAY;
        } else if (hrValue <= HR_ZONE_2_MAX_BPM) {
            return Graphics.COLOR_BLUE;
        } else if (hrValue <= HR_ZONE_3_MAX_BPM) {
            return Graphics.COLOR_GREEN;
        } else if (hrValue <= HR_ZONE_4_MAX_BPM) {
            return Graphics.COLOR_ORANGE;
        }
        return Graphics.COLOR_RED;
    }

    function getHrCursorAngle(hrValue) {
        if (hrValue == null) {
            return HR_ZONE_1_START_DEG;
        } else if (hrValue <= HR_ZONE_1_MAX_BPM) {
            return interpolateRange(hrValue, 60, HR_ZONE_1_MAX_BPM, HR_ZONE_1_START_DEG, HR_ZONE_1_END_DEG);
        } else if (hrValue <= HR_ZONE_2_MAX_BPM) {
            return interpolateRange(hrValue, 110, HR_ZONE_2_MAX_BPM, HR_ZONE_2_START_DEG, HR_ZONE_2_END_DEG);
        } else if (hrValue <= HR_ZONE_3_MAX_BPM) {
            return interpolateRange(hrValue, 130, HR_ZONE_3_MAX_BPM, HR_ZONE_3_START_DEG, HR_ZONE_3_END_DEG);
        } else if (hrValue <= HR_ZONE_4_MAX_BPM) {
            return interpolateRange(hrValue, 150, HR_ZONE_4_MAX_BPM, HR_ZONE_4_START_DEG, HR_ZONE_4_END_DEG);
        }
        return interpolateRange(hrValue, 170, HR_ZONE_5_MAX_BPM, HR_ZONE_5_START_DEG, HR_ZONE_5_END_DEG);
    }

    function drawHeartGlyph(dc, centerX, centerY, size, color) as Void {
        var half = size / 2;
        var quarter = size / 4;
        var topY = centerY - (size / 6);

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX - quarter, topY, quarter);
        dc.fillCircle(centerX + quarter, topY, quarter);
        dc.fillPolygon([
            [centerX - half, topY],
            [centerX + half, topY],
            [centerX, centerY + half]
        ]);
    }

    function drawHeartRateHeader(dc, width, height, hrValue) as Void {
        var centerX = width / 2;
        var centerY = height / 2;
        var gaugeRadius = (height / 2) - 12;
        var cursorAngle = getHrCursorAngle(hrValue);
        var heartColor = getHrZoneColor(hrValue);
        var hrText = "--";
        if (hrValue != null) {
            hrText = hrValue.toString();
        }

        dc.setPenWidth(8);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(centerX, centerY, gaugeRadius, Graphics.ARC_CLOCKWISE, HR_ZONE_1_START_DEG, HR_ZONE_1_END_DEG);

        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(centerX, centerY, gaugeRadius, Graphics.ARC_CLOCKWISE, HR_ZONE_2_START_DEG, HR_ZONE_2_END_DEG);

        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(centerX, centerY, gaugeRadius, Graphics.ARC_CLOCKWISE, HR_ZONE_3_START_DEG, HR_ZONE_3_END_DEG);

        dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(centerX, centerY, gaugeRadius, Graphics.ARC_CLOCKWISE, HR_ZONE_4_START_DEG, HR_ZONE_4_END_DEG);

        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(centerX, centerY, gaugeRadius, Graphics.ARC_CLOCKWISE, HR_ZONE_5_START_DEG, HR_ZONE_5_END_DEG);

        dc.setColor(PRIMARY_TEXT_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(10);
        dc.drawArc(centerX, centerY, gaugeRadius, Graphics.ARC_CLOCKWISE, cursorAngle + 1, cursorAngle - 1);

        dc.setPenWidth(1);
        drawHeartGlyph(dc, centerX - 32, 48, 20, heartColor);
        dc.setColor(PRIMARY_TEXT_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX + 18, 30, Graphics.FONT_LARGE, hrText, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(34, HR_HEADER_DIVIDER_Y, width - 34, HR_HEADER_DIVIDER_Y);
        dc.setPenWidth(1);
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

    function onLayout(dc) {
    }

    function onShow() {
    }

    function onUpdate(dc) {
        dc.setColor(MAIN_BG_COLOR, MAIN_BG_COLOR);
        dc.clear();
        dc.setColor(PRIMARY_TEXT_COLOR, Graphics.COLOR_TRANSPARENT);

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
        var hrValue = getHeartRateValue(info);

        drawHeartRateHeader(dc, width, height, hrValue);

        dc.setColor(PRIMARY_TEXT_COLOR, Graphics.COLOR_TRANSPARENT);
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
        dc.setColor(SECONDARY_TEXT_COLOR, Graphics.COLOR_TRANSPARENT);
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
