import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.WatchUi;

class FootballAppView extends WatchUi.View {

    private var _app as FootballAppApp;
    private var _refreshTimer as Timer.Timer;

    function initialize() {
        View.initialize();
        _app = getApp();
        _refreshTimer = new Timer.Timer();
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
        _refreshTimer.start(method(:onRefreshTimer), 1000, true);
    }

    function onHide() as Void {
        _refreshTimer.stop();
    }

    function onRefreshTimer() as Void {
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var scoreText = _app.getTeamAScore().toString() + " - " + _app.getTeamBScore().toString();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        drawStatusIndicator(dc, width);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 8, Graphics.FONT_XTINY, "Soccer Match", Graphics.TEXT_JUSTIFY_CENTER);

        var scoreY = (height / 2) - dc.getFontHeight(Graphics.FONT_LARGE);
        dc.drawText(centerX, scoreY, Graphics.FONT_LARGE, scoreText, Graphics.TEXT_JUSTIFY_CENTER);

        var goalieLabelY = scoreY + dc.getFontHeight(Graphics.FONT_LARGE) + 8;
        dc.drawText(centerX, goalieLabelY, Graphics.FONT_SMALL, "Goalie Timer", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, goalieLabelY + dc.getFontHeight(Graphics.FONT_SMALL), Graphics.FONT_MEDIUM, formatGoalieTimer(_app.getGoalieTimerSeconds()), Graphics.TEXT_JUSTIFY_CENTER);

        var heartRateText = formatHeartRate();
        var heartRateY = height - dc.getFontHeight(Graphics.FONT_MEDIUM) - 12;
        dc.drawText(centerX, heartRateY - dc.getFontHeight(Graphics.FONT_SMALL), Graphics.FONT_SMALL, "Heart Rate", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, heartRateY, Graphics.FONT_MEDIUM, heartRateText, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(8, height - dc.getFontHeight(Graphics.FONT_XTINY) - 4, Graphics.FONT_XTINY, "Tap left/right: +1 score", Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(width - 8, height - dc.getFontHeight(Graphics.FONT_XTINY) - 4, Graphics.FONT_XTINY, "Tap bottom: reset goalie", Graphics.TEXT_JUSTIFY_RIGHT);
    }

    function drawStatusIndicator(dc as Dc, width as Lang.Number) as Void {
        var isRecording = _app.isRecording();
        var statusColor = isRecording ? Graphics.COLOR_GREEN : Graphics.COLOR_RED;
        var statusText = isRecording ? "Recording" : "Paused";

        if (!_app.isRecordingSupported()) {
            statusText = "FIT Unsupported";
        }

        dc.setColor(statusColor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(width - 16, 16, 6);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width - 28, 8, Graphics.FONT_XTINY, statusText, Graphics.TEXT_JUSTIFY_RIGHT);
    }

    function formatGoalieTimer(totalSeconds as Lang.Number) as Lang.String {
        if (totalSeconds < 0) {
            totalSeconds = 0;
        }

        var minutes = totalSeconds / 60;
        var seconds = totalSeconds % 60;
        return minutes.format("%02d") + ":" + seconds.format("%02d");
    }

    function formatHeartRate() as Lang.String {
        var heartRate = _app.getHeartRate();
        if (heartRate == null) {
            return "-- bpm";
        }
        return heartRate.toString() + " bpm";
    }

}
