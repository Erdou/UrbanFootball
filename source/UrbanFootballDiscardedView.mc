using Toybox.Graphics;
using Toybox.WatchUi;

class UrbanFootballDiscardedView extends WatchUi.View {

    const RING_PEN_WIDTH = 6;
    const CHECK_PEN_WIDTH = 5;

    var _title = null;

    function initialize() {
        View.initialize();
        _title = WatchUi.loadResource(Rez.Strings.pauseDiscardedTitle);
    }

    function drawRing(dc, width, height) as Void {
        var centerX = width / 2;
        var centerY = height / 2;
        var minDimension = width;
        if (height < minDimension) {
            minDimension = height;
        }
        var ringRadius = (minDimension / 2) - (RING_PEN_WIDTH / 2);

        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(RING_PEN_WIDTH);
        dc.drawCircle(centerX, centerY, ringRadius);
        dc.setPenWidth(1);
    }

    function drawCheck(dc, width, height) as Void {
        var centerX = width / 2;
        var centerY = height / 2;
        var checkX = centerX + 56;
        var checkY = centerY - 52;

        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(CHECK_PEN_WIDTH);
        dc.drawLine(checkX - 12, checkY + 2, checkX - 2, checkY + 12);
        dc.drawLine(checkX - 2, checkY + 12, checkX + 14, checkY - 6);
        dc.setPenWidth(1);
    }

    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        drawRing(dc, width, height);
        drawCheck(dc, width, height);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, (height / 2) - 16, Graphics.FONT_MEDIUM, _title, Graphics.TEXT_JUSTIFY_CENTER);
    }
}
