using Toybox.Graphics;

class UrbanFootballClockRenderer {

    function initialize() {
    }

    function formatTime(hour, minute, is24Hour) {
        if (is24Hour) {
            return hour.format("%02d") + ":" + minute.format("%02d");
        }

        var displayHour = hour % 12;
        if (displayHour == 0) {
            displayHour = 12;
        }
        var suffix = hour < 12 ? " AM" : " PM";
        return displayHour.toString() + ":" + minute.format("%02d") + suffix;
    }

    function getTop(dc, height) {
        // Leave room for the curved edge of round displays.
        var bottomMargin = height * 4 / 100;
        if (bottomMargin < 10) {
            bottomMargin = 10;
        }
        return height - dc.getFontHeight(Graphics.FONT_XTINY) - bottomMargin;
    }

    function drawFooter(dc, width, height, clockTime, is24Hour, color) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, getTop(dc, height), Graphics.FONT_XTINY,
            formatTime(clockTime.hour, clockTime.min, is24Hour), Graphics.TEXT_JUSTIFY_CENTER);
    }
}
