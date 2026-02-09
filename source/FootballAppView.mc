import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
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
        var isRound = (System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_ROUND);
        var safeInset = isRound ? (width / 10) : 8;
        if (safeInset < 8) {
            safeInset = 8;
        }

        var titleFont = Graphics.FONT_XTINY;
        var scoreFont = Graphics.FONT_LARGE;
        var labelFont = Graphics.FONT_SMALL;
        var valueFont = Graphics.FONT_MEDIUM;

        var sectionGap = 10;
        var rowGap = 4;
        var headerHeight = dc.getFontHeight(titleFont) + 6;
        var availableHeight = height - (safeInset * 2) - headerHeight;
        var contentHeight = calculateContentHeight(dc, scoreFont, labelFont, valueFont, sectionGap, rowGap);

        // Compact layout for tight round displays.
        if (contentHeight > availableHeight) {
            scoreFont = Graphics.FONT_MEDIUM;
            labelFont = Graphics.FONT_XTINY;
            valueFont = Graphics.FONT_SMALL;
            sectionGap = 6;
            rowGap = 2;
            contentHeight = calculateContentHeight(dc, scoreFont, labelFont, valueFont, sectionGap, rowGap);
        }

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        drawStatusIndicator(dc, width, safeInset);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, safeInset, titleFont, "Soccer Match", Graphics.TEXT_JUSTIFY_CENTER);

        var blockTop = safeInset + headerHeight + ((availableHeight - contentHeight) / 2);
        if (blockTop < (safeInset + headerHeight)) {
            blockTop = safeInset + headerHeight;
        }

        var scoreY = blockTop;
        dc.drawText(centerX, scoreY, scoreFont, scoreText, Graphics.TEXT_JUSTIFY_CENTER);

        var goalieLabelY = scoreY + dc.getFontHeight(scoreFont) + sectionGap;
        dc.drawText(centerX, goalieLabelY, labelFont, "Goalie Timer", Graphics.TEXT_JUSTIFY_CENTER);
        var goalieValueY = goalieLabelY + dc.getFontHeight(labelFont) + rowGap;
        dc.drawText(centerX, goalieValueY, valueFont, formatGoalieTimer(_app.getGoalieTimerSeconds()), Graphics.TEXT_JUSTIFY_CENTER);

        var heartRateText = formatHeartRate();
        var hrLabelY = goalieValueY + dc.getFontHeight(valueFont) + sectionGap;
        dc.drawText(centerX, hrLabelY, labelFont, "Heart Rate", Graphics.TEXT_JUSTIFY_CENTER);
        var hrValueY = hrLabelY + dc.getFontHeight(labelFont) + rowGap;
        dc.drawText(centerX, hrValueY, valueFont, heartRateText, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function calculateContentHeight(
        dc as Dc,
        scoreFont as Graphics.FontType,
        labelFont as Graphics.FontType,
        valueFont as Graphics.FontType,
        sectionGap as Lang.Number,
        rowGap as Lang.Number
    ) as Lang.Number {
        return dc.getFontHeight(scoreFont)
            + sectionGap
            + dc.getFontHeight(labelFont)
            + rowGap
            + dc.getFontHeight(valueFont)
            + sectionGap
            + dc.getFontHeight(labelFont)
            + rowGap
            + dc.getFontHeight(valueFont);
    }

    function drawStatusIndicator(dc as Dc, width as Lang.Number, safeInset as Lang.Number) as Void {
        var isRecording = _app.isRecording();
        var statusColor = isRecording ? Graphics.COLOR_GREEN : Graphics.COLOR_RED;
        var radius = 5;
        var dotX = width - safeInset;
        var dotY = safeInset + radius;

        dc.setColor(statusColor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(dotX, dotY, radius);
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
