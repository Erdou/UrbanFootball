using Toybox.Graphics;
using Toybox.WatchUi;

class FootballAppGoalieDurationView extends WatchUi.View {

    const MIN_MINUTES = 1;
    const MAX_MINUTES = 99;

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

    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var plusY = (height / 2) - 8;
        var minusY = plusY + 56;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 24, Graphics.FONT_MEDIUM, _title, Graphics.TEXT_JUSTIFY_CENTER);

        var dividerMargin = 32;
        dc.fillRectangle(dividerMargin, 68, width - (dividerMargin * 2), 2);

        var minuteText = _minutes.format("%02d") + " min";
        dc.drawText(centerX, 96, Graphics.FONT_LARGE, minuteText, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(48, plusY, Graphics.FONT_LARGE, "+", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width - 48, plusY, Graphics.FONT_LARGE, "+", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(48, minusY, Graphics.FONT_LARGE, "-", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width - 48, minusY, Graphics.FONT_LARGE, "-", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, height - 38, Graphics.FONT_SMALL, _hint, Graphics.TEXT_JUSTIFY_CENTER);
    }
}
