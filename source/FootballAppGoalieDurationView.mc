using Toybox.Graphics;
using Toybox.WatchUi;

class FootballAppGoalieDurationView extends WatchUi.View {

    const MIN_MINUTES = 1;
    const MAX_MINUTES = 99;
    const CONTROL_SIZE = 30;
    const CONTROL_THICKNESS = 6;
    const CONTROL_HIT_RADIUS = 26;

    var _minutes = 7;
    var _title = null;
    var _hint = null;

    function initialize(defaultMinutes) {
        View.initialize();

        _title = WatchUi.loadResource(Rez.Strings.goalieDurationTitle);
        _hint = WatchUi.loadResource(Rez.Strings.goalieDurationHint);

        if (defaultMinutes < MIN_MINUTES) {
            _minutes = MIN_MINUTES;
        } else if (defaultMinutes > MAX_MINUTES) {
            _minutes = MAX_MINUTES;
        } else {
            _minutes = defaultMinutes;
        }
    }

    function getMinutes() {
        return _minutes;
    }

    function incrementMinutes() as Void {
        if (_minutes < MAX_MINUTES) {
            _minutes += 1;
            WatchUi.requestUpdate();
        }
    }

    function decrementMinutes() as Void {
        if (_minutes > MIN_MINUTES) {
            _minutes -= 1;
            WatchUi.requestUpdate();
        }
    }

    function getMinusCenterX(width) {
        return 52;
    }

    function getPlusCenterX(width) {
        return width - 52;
    }

    function getControlCenterY(height) {
        if (height < 280) {
            return 152;
        }
        return 158;
    }

    function isTapOnMinus(x, y, width, height) {
        var centerX = getMinusCenterX(width);
        var centerY = getControlCenterY(height);
        return (x >= (centerX - CONTROL_HIT_RADIUS) && x <= (centerX + CONTROL_HIT_RADIUS) && y >= (centerY - CONTROL_HIT_RADIUS) && y <= (centerY + CONTROL_HIT_RADIUS));
    }

    function isTapOnPlus(x, y, width, height) {
        var centerX = getPlusCenterX(width);
        var centerY = getControlCenterY(height);
        return (x >= (centerX - CONTROL_HIT_RADIUS) && x <= (centerX + CONTROL_HIT_RADIUS) && y >= (centerY - CONTROL_HIT_RADIUS) && y <= (centerY + CONTROL_HIT_RADIUS));
    }

    function drawMinus(dc, centerX, centerY) as Void {
        var half = CONTROL_SIZE / 2;
        var halfThickness = CONTROL_THICKNESS / 2;
        dc.fillRectangle(centerX - half, centerY - halfThickness, CONTROL_SIZE, CONTROL_THICKNESS);
    }

    function drawPlus(dc, centerX, centerY) as Void {
        var half = CONTROL_SIZE / 2;
        var halfThickness = CONTROL_THICKNESS / 2;
        dc.fillRectangle(centerX - half, centerY - halfThickness, CONTROL_SIZE, CONTROL_THICKNESS);
        dc.fillRectangle(centerX - halfThickness, centerY - half, CONTROL_THICKNESS, CONTROL_SIZE);
    }

    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var controlY = getControlCenterY(height);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 24, Graphics.FONT_MEDIUM, _title, Graphics.TEXT_JUSTIFY_CENTER);

        var dividerMargin = 32;
        dc.fillRectangle(dividerMargin, 68, width - (dividerMargin * 2), 2);

        var minuteText = _minutes.format("%02d") + " min";
        dc.drawText(centerX, 96, Graphics.FONT_LARGE, minuteText, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        drawMinus(dc, getMinusCenterX(width), controlY);
        drawPlus(dc, getPlusCenterX(width), controlY);

        var hintFont = Graphics.FONT_TINY;
        var hintY = height - dc.getFontHeight(hintFont) - 10;
        dc.drawText(centerX, hintY, hintFont, _hint, Graphics.TEXT_JUSTIFY_CENTER);
    }
}
