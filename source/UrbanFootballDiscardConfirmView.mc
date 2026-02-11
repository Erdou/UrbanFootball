using Toybox.Graphics;
using Toybox.WatchUi;

class UrbanFootballDiscardConfirmView extends WatchUi.View {

    const ACTION_INDICATOR_PEN_WIDTH = 6;
    const DELETE_INDICATOR_START_DEG = 40;
    const DELETE_INDICATOR_SWEEP_DEG = 22;
    const BACK_INDICATOR_START_DEG = 224;
    const BACK_INDICATOR_SWEEP_DEG = 22;

    const BACK_ICON_TAP_RADIUS = 30;
    const DELETE_ICON_TAP_RADIUS = 30;

    var _title = null;

    function initialize() {
        View.initialize();
        _title = WatchUi.loadResource(Rez.Strings.pauseDiscardConfirmTitle);
    }

    function getBackIconCenterX(width) {
        return width / 6;
    }

    function getBackIconCenterY(height) {
        return height - (height / 3);
    }

    function getDeleteIconCenterX(width) {
        return width - (width / 6);
    }

    function getDeleteIconCenterY(height) {
        return height / 4;
    }

    function getTitleY(height) {
        return (height / 2) - 16;
    }

    function isTapOnBackAction(x, y, width, height) {
        var centerX = getBackIconCenterX(width);
        var centerY = getBackIconCenterY(height);
        return (x >= (centerX - BACK_ICON_TAP_RADIUS) && x <= (centerX + BACK_ICON_TAP_RADIUS) && y >= (centerY - BACK_ICON_TAP_RADIUS) && y <= (centerY + BACK_ICON_TAP_RADIUS));
    }

    function isTapOnDeleteAction(x, y, width, height) {
        var centerX = getDeleteIconCenterX(width);
        var centerY = getDeleteIconCenterY(height);
        return (x >= (centerX - DELETE_ICON_TAP_RADIUS) && x <= (centerX + DELETE_ICON_TAP_RADIUS) && y >= (centerY - DELETE_ICON_TAP_RADIUS) && y <= (centerY + DELETE_ICON_TAP_RADIUS));
    }

    function drawDeleteIcon(dc, centerX, centerY) as Void {
        var bodyWidth = 18;
        var bodyHeight = 14;
        var lidWidth = 24;
        var lidHeight = 4;

        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(centerX - (lidWidth / 2), centerY - 10, lidWidth, lidHeight);
        dc.fillRectangle(centerX - (bodyWidth / 2), centerY - 6, bodyWidth, bodyHeight);
        dc.fillRectangle(centerX - 4, centerY - 13, 8, 3);
    }

    function drawBackIcon(dc, centerX, centerY) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawLine(centerX + 16, centerY, centerX - 8, centerY);
        dc.drawLine(centerX - 8, centerY, centerX + 4, centerY - 10);
        dc.drawLine(centerX - 8, centerY, centerX + 4, centerY + 10);
        dc.setPenWidth(1);
    }

    function drawActionIndicators(dc, width, height) as Void {
        var centerX = width / 2;
        var centerY = height / 2;
        var minDimension = width;
        if (height < minDimension) {
            minDimension = height;
        }
        var outerRadius = (minDimension / 2) - 8;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(ACTION_INDICATOR_PEN_WIDTH);
        dc.drawArc(centerX, centerY, outerRadius, Graphics.ARC_CLOCKWISE, DELETE_INDICATOR_START_DEG, DELETE_INDICATOR_SWEEP_DEG);
        dc.drawArc(centerX, centerY, outerRadius, Graphics.ARC_CLOCKWISE, BACK_INDICATOR_START_DEG, BACK_INDICATOR_SWEEP_DEG);
        dc.setPenWidth(1);
    }

    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        drawActionIndicators(dc, width, height);

        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        drawDeleteIcon(dc, getDeleteIconCenterX(width), getDeleteIconCenterY(height));
        dc.drawText(centerX, getTitleY(height), Graphics.FONT_MEDIUM, _title, Graphics.TEXT_JUSTIFY_CENTER);

        drawBackIcon(dc, getBackIconCenterX(width), getBackIconCenterY(height));
    }
}
