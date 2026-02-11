using Toybox.Graphics;
using Toybox.WatchUi;

class UrbanFootballGoalieDurationView extends WatchUi.View {

    const MIN_MINUTES = 1;
    const MAX_MINUTES = 99;
    const CONTROL_SIZE = 30;
    const CONTROL_THICKNESS = 6;
    const CONTROL_HIT_RADIUS = 26;
    const VALUE_TAP_HALF_WIDTH = 94;
    const VALUE_TAP_HALF_HEIGHT = 34;
    const CONFIRM_ICON_TAP_RADIUS = 28;
    const ACTION_INDICATOR_PEN_WIDTH = 6;
    const CONFIRM_INDICATOR_START_DEG = 40;
    const CONFIRM_INDICATOR_END_DEG = 22;

    var _minutes = 7;
    var _title = null;

    function initialize(defaultMinutes) {
        View.initialize();

        _title = WatchUi.loadResource(Rez.Strings.goalieDurationTitle);

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
        return (width / 2) - 78;
    }

    function getPlusCenterX(width) {
        return (width / 2) + 78;
    }

    function getTitleY(height) {
        if (height < 280) {
            return 96;
        }
        return 104;
    }

    function getValueCenterY(height) {
        if (height < 280) {
            return (height / 2) + 44;
        }
        return (height / 2) + 46;
    }

    function getControlCenterY(height) {
        return getValueCenterY(height);
    }

    function getConfirmIconCenterX(width) {
        return (width - (width / 6)) - 6;
    }

    function getConfirmIconCenterY(height) {
        return (height / 5) + 22;
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

    function isTapOnValue(x, y, width, height) {
        var centerX = width / 2;
        var centerY = getValueCenterY(height);
        return (x >= (centerX - VALUE_TAP_HALF_WIDTH) && x <= (centerX + VALUE_TAP_HALF_WIDTH) && y >= (centerY - VALUE_TAP_HALF_HEIGHT) && y <= (centerY + VALUE_TAP_HALF_HEIGHT));
    }

    function isTapOnConfirm(x, y, width, height) {
        var centerX = getConfirmIconCenterX(width);
        var centerY = getConfirmIconCenterY(height);
        return (x >= (centerX - CONFIRM_ICON_TAP_RADIUS) && x <= (centerX + CONFIRM_ICON_TAP_RADIUS) && y >= (centerY - CONFIRM_ICON_TAP_RADIUS) && y <= (centerY + CONFIRM_ICON_TAP_RADIUS));
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

    function drawConfirmIndicatorArc(dc, width, height) as Void {
        var centerX = width / 2;
        var centerY = height / 2;
        var minDimension = width;
        if (height < minDimension) {
            minDimension = height;
        }
        var outerRadius = (minDimension / 2) - 8;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(ACTION_INDICATOR_PEN_WIDTH);
        dc.drawArc(centerX, centerY, outerRadius, Graphics.ARC_CLOCKWISE, CONFIRM_INDICATOR_START_DEG, CONFIRM_INDICATOR_END_DEG);
        dc.setPenWidth(1);
    }

    function drawCheckIcon(dc, centerX, centerY) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(4);
        dc.drawLine(centerX - 10, centerY + 2, centerX - 2, centerY + 10);
        dc.drawLine(centerX - 2, centerY + 10, centerX + 12, centerY - 4);
        dc.setPenWidth(1);
    }

    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var valueFont = Graphics.FONT_LARGE;
        var valueTopY = getValueCenterY(height) - (dc.getFontHeight(valueFont) / 2);
        var controlY = getControlCenterY(height);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        drawConfirmIndicatorArc(dc, width, height);
        drawCheckIcon(dc, getConfirmIconCenterX(width), getConfirmIconCenterY(height));

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, getTitleY(height), Graphics.FONT_MEDIUM, _title, Graphics.TEXT_JUSTIFY_CENTER);

        var minuteText = _minutes.toString() + " min";
        dc.drawText(centerX, valueTopY, valueFont, minuteText, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        drawMinus(dc, getMinusCenterX(width), controlY);
        drawPlus(dc, getPlusCenterX(width), controlY);
    }
}
