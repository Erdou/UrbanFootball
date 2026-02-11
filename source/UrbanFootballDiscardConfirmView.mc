using Toybox.Graphics;
using Toybox.WatchUi;

class UrbanFootballDiscardConfirmView extends WatchUi.View {

    const TOP_MARKER_WIDTH = 42;
    const TOP_MARKER_HEIGHT = 4;
    const BACK_ICON_TAP_RADIUS = 34;
    const DELETE_ICON_TAP_RADIUS = 34;

    var _title = null;

    function initialize() {
        View.initialize();
        _title = WatchUi.loadResource(Rez.Strings.pauseDiscardConfirmTitle);
    }

    function getBackIconCenterX(width) {
        return width / 2;
    }

    function getBackIconCenterY(height) {
        return height - 34;
    }

    function getDeleteIconCenterX(width) {
        return width / 2;
    }

    function getDeleteIconCenterY() {
        return 46;
    }

    function getTitleY(height) {
        return (height / 2) - 16;
    }

    function isTapOnBackAction(x, y, width, height) {
        var centerX = getBackIconCenterX(width);
        var centerY = getBackIconCenterY(height);
        return (x >= (centerX - BACK_ICON_TAP_RADIUS) && x <= (centerX + BACK_ICON_TAP_RADIUS) && y >= (centerY - BACK_ICON_TAP_RADIUS) && y <= (centerY + BACK_ICON_TAP_RADIUS));
    }

    function isTapOnDeleteAction(x, y, width) {
        var centerX = getDeleteIconCenterX(width);
        var centerY = getDeleteIconCenterY();
        return (x >= (centerX - DELETE_ICON_TAP_RADIUS) && x <= (centerX + DELETE_ICON_TAP_RADIUS) && y >= (centerY - DELETE_ICON_TAP_RADIUS) && y <= (centerY + DELETE_ICON_TAP_RADIUS));
    }

    function drawDeleteIcon(dc, centerX, centerY) as Void {
        var bodyWidth = 18;
        var bodyHeight = 14;
        var lidWidth = 24;
        var lidHeight = 4;

        dc.setColor(Graphics.COLOR_PINK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(centerX - (lidWidth / 2), centerY - 10, lidWidth, lidHeight);
        dc.fillRectangle(centerX - (bodyWidth / 2), centerY - 6, bodyWidth, bodyHeight);
        dc.fillRectangle(centerX - 4, centerY - 13, 8, 3);
    }

    function drawBackIcon(dc, centerX, centerY) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawLine(centerX + 14, centerY, centerX - 8, centerY);
        dc.drawLine(centerX - 8, centerY, centerX + 2, centerY - 9);
        dc.drawLine(centerX - 8, centerY, centerX + 2, centerY + 9);
        dc.setPenWidth(1);
    }

    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(centerX - (TOP_MARKER_WIDTH / 2), 12, TOP_MARKER_WIDTH, TOP_MARKER_HEIGHT);

        drawDeleteIcon(dc, getDeleteIconCenterX(width), getDeleteIconCenterY());
        dc.drawText(centerX, getTitleY(height), Graphics.FONT_MEDIUM, _title, Graphics.TEXT_JUSTIFY_CENTER);
        drawBackIcon(dc, getBackIconCenterX(width), getBackIconCenterY(height));
    }
}
