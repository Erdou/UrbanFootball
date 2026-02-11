using Toybox.Graphics;

class UrbanFootballPreStartRenderer {

    const PRESTART_BG_COLOR = Graphics.COLOR_BLACK;
    const READY_INDICATOR_START_DEG = 40;
    const READY_INDICATOR_END_DEG = 22;
    const OVERLAY_RING_PEN_WIDTH = 6;

    function initialize() {
    }

    function drawScreen(dc, width, height, footIcon, title, goalieTimerEnabled, goalieTimeText, showReadyIndicator) as Void {
        var centerX = width / 2;
        var centerY = height / 2;

        dc.setColor(PRESTART_BG_COLOR, PRESTART_BG_COLOR);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        if (footIcon != null) {
            var iconX = centerX - (footIcon.getWidth() / 2);
            var iconY = centerY - 60;
            dc.drawBitmap(iconX, iconY, footIcon);
        }

        var titleY = centerY + 8;
        dc.drawText(centerX, titleY, Graphics.FONT_MEDIUM, title, Graphics.TEXT_JUSTIFY_CENTER);

        if (goalieTimerEnabled) {
            var goalieY = centerY + 44;
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            dc.drawText(centerX, goalieY, Graphics.FONT_SMALL, goalieTimeText, Graphics.TEXT_JUSTIFY_CENTER);
        }

        if (showReadyIndicator) {
            drawReadyToStartIndicator(dc, width, height);
        }
    }

    function drawReadyToStartIndicator(dc, width, height) as Void {
        var centerX = width / 2;
        var centerY = height / 2;
        var outerRadius = (height / 2) - 8;

        // Arc is intentionally placed near the physical START button area.
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(6);
        dc.drawArc(centerX, centerY, outerRadius, Graphics.ARC_CLOCKWISE, READY_INDICATOR_START_DEG, READY_INDICATOR_END_DEG);
        dc.setPenWidth(1);
    }

    function drawStartAnimationOverlay(dc, width, height) as Void {
        var centerX = width / 2;
        var centerY = height / 2;
        var minDimension = width;
        if (height < minDimension) {
            minDimension = height;
        }
        var ringRadius = (minDimension / 2) - (OVERLAY_RING_PEN_WIDTH / 2);
        var playHalfHeight = 36;
        var playLeftX = centerX - 24;
        var playRightX = centerX + 34;

        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(OVERLAY_RING_PEN_WIDTH);
        dc.drawCircle(centerX, centerY, ringRadius);
        dc.setPenWidth(1);

        dc.fillPolygon([
            [playLeftX, centerY - playHalfHeight],
            [playRightX, centerY],
            [playLeftX, centerY + playHalfHeight]
        ]);
    }
}
