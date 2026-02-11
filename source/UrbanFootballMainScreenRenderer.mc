using Toybox.Graphics;

class UrbanFootballMainScreenRenderer {

    const MAIN_BG_COLOR = Graphics.COLOR_WHITE;
    const PRIMARY_TEXT_COLOR = Graphics.COLOR_BLACK;
    const SECONDARY_TEXT_COLOR = Graphics.COLOR_DK_GRAY;
    const OVERLAY_RING_PEN_WIDTH = 6;

    function initialize() {
    }

    function drawScreen(
        dc,
        width,
        height,
        heartRateRenderer,
        hrValue,
        footIcon,
        scoreA,
        scoreB,
        gameTimeText,
        goalieTimerEnabled,
        goalieTimeText,
        goalieTimerOvertime,
        isRecording,
        activityStarted
    ) as Void {
        var centerX = width / 2;
        var centerY = height / 2;
        var scoreFont = Graphics.FONT_NUMBER_HOT;
        var scoreY = centerY - 50;
        var scoreHeight = dc.getFontHeight(scoreFont);
        var hasTwoDigitScore = (scoreA >= 10 || scoreB >= 10);
        var scoreXOffset = hasTwoDigitScore ? 68 : 50;

        dc.setColor(MAIN_BG_COLOR, MAIN_BG_COLOR);
        dc.clear();

        heartRateRenderer.drawHeader(dc, width, height, hrValue, PRIMARY_TEXT_COLOR);

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
        dc.setColor(SECONDARY_TEXT_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, gameTimeY, Graphics.FONT_TINY, gameTimeText, Graphics.TEXT_JUSTIFY_CENTER);

        if (goalieTimerEnabled) {
            var goalieFont = Graphics.FONT_SMALL;
            var goalieY = centerY + 74;
            var goalieMaxY = height - dc.getFontHeight(goalieFont) - 24;
            if (goalieY > goalieMaxY) {
                goalieY = goalieMaxY;
            }

            if (goalieTimerOvertime) {
                dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            }

            dc.drawText(centerX, goalieY, goalieFont, goalieTimeText, Graphics.TEXT_JUSTIFY_CENTER);
        }

        if (isRecording) {
            // Green: actively recording. Red: session exists but paused/stopped.
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(width - 20, 20, 5);
        } else if (activityStarted) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(width - 20, 20, 5);
        }
    }

    function drawPauseAnimationOverlay(dc, width, height) as Void {
        var centerX = width / 2;
        var centerY = height / 2;
        var minDimension = width;
        if (height < minDimension) {
            minDimension = height;
        }
        var ringRadius = (minDimension / 2) - (OVERLAY_RING_PEN_WIDTH / 2);
        var halfSize = 34;

        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(OVERLAY_RING_PEN_WIDTH);
        dc.drawCircle(centerX, centerY, ringRadius);
        dc.setPenWidth(1);

        dc.fillRectangle(centerX - halfSize, centerY - halfSize, halfSize * 2, halfSize * 2);
    }
}
