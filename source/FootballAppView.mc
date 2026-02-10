using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Activity;
using Toybox.Timer;

class FootballAppView extends WatchUi.View {

    var scoreA = 0;
    var scoreB = 0;
    var goalieTimerStart = 0;
    var footIcon = null;
    
    var session = null; 
    var isRecording = false;

    var refreshTimer;

    function initialize() {
        View.initialize();
        goalieTimerStart = System.getTimer();
        footIcon = WatchUi.loadResource(Rez.Drawables.FootIconScore) as Graphics.BitmapType;
        
        refreshTimer = new Timer.Timer();
        refreshTimer.start(method(:onTimerTick), 1000, true);
    }

    function onTimerTick() as Void {
        WatchUi.requestUpdate();
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
        var scoreY = centerY - 34;
        var scoreHeight = dc.getFontHeight(scoreFont);
        var hasTwoDigitScore = (scoreA >= 10 || scoreB >= 10);
        var scoreXOffset = hasTwoDigitScore ? 68 : 50;

        dc.drawText(centerX - scoreXOffset, scoreY, scoreFont, scoreA.toString(), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX + scoreXOffset, scoreY, scoreFont, scoreB.toString(), Graphics.TEXT_JUSTIFY_CENTER);

        if (footIcon != null) {
            var iconY = scoreY + ((scoreHeight - footIcon.getHeight()) / 2);
            dc.drawBitmap(centerX - (footIcon.getWidth() / 2), iconY, footIcon);
        } else {
            dc.drawText(centerX, scoreY, Graphics.FONT_LARGE, "-", Graphics.TEXT_JUSTIFY_CENTER);
        }

        var now = System.getTimer();
        var diffSeconds = (now - goalieTimerStart) / 1000;
        var minutes = diffSeconds / 60;
        var seconds = diffSeconds % 60;
        var timeStr = minutes.format("%02d") + ":" + seconds.format("%02d");
        
        var goalieFont = Graphics.FONT_SMALL;
        var goalieY = centerY + 70;
        var goalieMaxY = height - dc.getFontHeight(goalieFont) - 24;
        if (goalieY > goalieMaxY) {
            goalieY = goalieMaxY;
        }
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, goalieY, goalieFont, "Gardien: " + timeStr, Graphics.TEXT_JUSTIFY_CENTER);

        var hr = "--";
        var info = Activity.getActivityInfo();
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
