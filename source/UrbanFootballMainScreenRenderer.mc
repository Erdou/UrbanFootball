using Toybox.Graphics;

class UrbanFootballMainScreenRenderer {

    const MAIN_BG_COLOR = Graphics.COLOR_WHITE;
    const PRIMARY_TEXT_COLOR = Graphics.COLOR_BLACK;
    const SECONDARY_TEXT_COLOR = Graphics.COLOR_DK_GRAY;
    const SCORE_HIGHLIGHT_COLOR = Graphics.COLOR_DK_GRAY;
    const SCORE_SINGLE_DIGIT_X_OFFSET = 62;
    const SCORE_DOUBLE_DIGIT_X_OFFSET = 80;
    const SCORE_LINE_Y_OFFSET = -50;
    const OVERLAY_RING_PEN_WIDTH = 6;
    const OVERLAY_RING_EDGE_BLEED = 2;
    const STATUS_DOT_RADIUS = 5;

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
        highlightLeftScore,
        highlightRightScore,
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
        var scoreY = centerY + SCORE_LINE_Y_OFFSET;
        var scoreHeight = dc.getFontHeight(scoreFont);
        var hasTwoDigitScore = (scoreA >= 10 || scoreB >= 10);
        var scoreXOffset = hasTwoDigitScore ? SCORE_DOUBLE_DIGIT_X_OFFSET : SCORE_SINGLE_DIGIT_X_OFFSET;

        dc.setColor(MAIN_BG_COLOR, MAIN_BG_COLOR);
        dc.clear();

        heartRateRenderer.drawHeader(dc, width, height, hrValue, PRIMARY_TEXT_COLOR);

        dc.setColor(highlightLeftScore ? SCORE_HIGHLIGHT_COLOR : PRIMARY_TEXT_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX - scoreXOffset, scoreY, scoreFont, scoreA.toString(), Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(highlightRightScore ? SCORE_HIGHLIGHT_COLOR : PRIMARY_TEXT_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX + scoreXOffset, scoreY, scoreFont, scoreB.toString(), Graphics.TEXT_JUSTIFY_CENTER);

        var iconWidth = 40;
        var iconHeight = 40;
        if (footIcon != null) {
            iconWidth = footIcon.getWidth();
            iconHeight = footIcon.getHeight();
        }
        var iconX = centerX - (iconWidth / 2);
        var iconY = scoreY + ((scoreHeight - iconHeight) / 2);

        if (footIcon != null) {
            dc.drawBitmap(iconX, iconY, footIcon);
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
            var statusDotX = width - STATUS_DOT_RADIUS;
            var statusDotY = STATUS_DOT_RADIUS;
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(statusDotX, statusDotY, STATUS_DOT_RADIUS);
        } else if (activityStarted) {
            var pausedDotX = width - STATUS_DOT_RADIUS;
            var pausedDotY = STATUS_DOT_RADIUS;
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(pausedDotX, pausedDotY, STATUS_DOT_RADIUS);
        }
    }

    function drawPauseAnimationOverlay(dc, width, height) as Void {
        var centerX = width / 2;
        var centerY = height / 2;
        var minDimension = width;
        if (height < minDimension) {
            minDimension = height;
        }
        var ringRadius = (minDimension / 2) - (OVERLAY_RING_PEN_WIDTH / 2) + OVERLAY_RING_EDGE_BLEED;
        var halfSize = 34;

        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(OVERLAY_RING_PEN_WIDTH);
        dc.drawCircle(centerX, centerY, ringRadius);
        dc.setPenWidth(1);

        dc.fillRectangle(centerX - halfSize, centerY - halfSize, halfSize * 2, halfSize * 2);
    }
}
