using Toybox.Graphics;
using Toybox.WatchUi;

class UrbanFootballSaveConfirmView extends WatchUi.View {

    const ACTION_INDICATOR_PEN_WIDTH = 6;
    const INDICATOR_GAP_DEG = 22;
    const SAVE_INDICATOR_START_DEG = 40;
    const BACK_INDICATOR_START_DEG = 223;
    const BACK_ICON_TAP_RADIUS = 30;
    const SAVE_ICON_TAP_RADIUS = 30;

    var _title = null;

    function initialize() {
        View.initialize();
        _title = WatchUi.loadResource(Rez.Strings.pauseSaveConfirmTitle);
    }

    function getBackIconCenterX(width) {
        return width / 4.9;
    }

    function getBackIconCenterY(height) {
        return height - (height / 3.3);
    }

    function getSaveIconCenterX(width) {
        return width - (width / 6);
    }

    function getSaveIconCenterY(height) {
        return height / 3;
    }

    function getTitleY(height) {
        return (height / 2) - 16;
    }

    function isTapOnBackAction(x, y, width, height) {
        var centerX = getBackIconCenterX(width);
        var centerY = getBackIconCenterY(height);
        return (x >= (centerX - BACK_ICON_TAP_RADIUS) && x <= (centerX + BACK_ICON_TAP_RADIUS) && y >= (centerY - BACK_ICON_TAP_RADIUS) && y <= (centerY + BACK_ICON_TAP_RADIUS));
    }

    function isTapOnSaveAction(x, y, width, height) {
        var centerX = getSaveIconCenterX(width);
        var centerY = getSaveIconCenterY(height);
        return (x >= (centerX - SAVE_ICON_TAP_RADIUS) && x <= (centerX + SAVE_ICON_TAP_RADIUS) && y >= (centerY - SAVE_ICON_TAP_RADIUS) && y <= (centerY + SAVE_ICON_TAP_RADIUS));
    }

    function drawSaveIcon(dc, centerX, centerY) as Void {
        var size = 22;
        var half = size / 2;
        var shaftWidth = 4;
        var shaftHeight = size - 6;
        var trayWidth = size + 6;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(centerX - (shaftWidth / 2), centerY - half, shaftWidth, shaftHeight);
        dc.fillPolygon([
            [centerX - half, centerY + 1],
            [centerX + half, centerY + 1],
            [centerX, centerY + half]
        ]);
        dc.fillRectangle(centerX - (trayWidth / 2), centerY + half + 2, trayWidth, 3);
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
        dc.drawArc(centerX, centerY, outerRadius, Graphics.ARC_CLOCKWISE, SAVE_INDICATOR_START_DEG, SAVE_INDICATOR_START_DEG - INDICATOR_GAP_DEG);
        dc.drawArc(centerX, centerY, outerRadius, Graphics.ARC_CLOCKWISE, BACK_INDICATOR_START_DEG, BACK_INDICATOR_START_DEG - INDICATOR_GAP_DEG);
        dc.setPenWidth(1);
    }

    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        drawActionIndicators(dc, width, height);
        drawSaveIcon(dc, getSaveIconCenterX(width), getSaveIconCenterY(height));

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, getTitleY(height), Graphics.FONT_MEDIUM, _title, Graphics.TEXT_JUSTIFY_CENTER);

        drawBackIcon(dc, getBackIconCenterX(width), getBackIconCenterY(height));
    }
}
