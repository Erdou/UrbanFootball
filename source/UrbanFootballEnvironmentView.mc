using Toybox.Graphics;
using Toybox.System;
using Toybox.WatchUi;

class UrbanFootballEnvironmentView extends WatchUi.View {

    const OPTION_ROW_SPACING = 66;

    var _selectedIndex = 0;
    var _title = null;
    var _outdoorLabel = null;
    var _indoorLabel = null;

    function initialize() {
        View.initialize();
        _title = WatchUi.loadResource(Rez.Strings.environmentTypeTitle);
        _outdoorLabel = WatchUi.loadResource(Rez.Strings.environmentOutdoor);
        _indoorLabel = WatchUi.loadResource(Rez.Strings.environmentIndoor);
    }

    function getSelectedIsOutdoor() {
        return _selectedIndex == 0;
    }

    function moveSelection(step) as Void {
        _selectedIndex += step;
        if (_selectedIndex < 0) {
            _selectedIndex = 1;
        } else if (_selectedIndex > 1) {
            _selectedIndex = 0;
        }

        WatchUi.requestUpdate();
    }

    function selectFromTap(y) as Void {
        var firstOptionY = getFirstOptionY(System.getDeviceSettings().screenHeight);
        var midpoint = firstOptionY + (OPTION_ROW_SPACING / 2);
        if (y < midpoint) {
            _selectedIndex = 0;
        } else {
            _selectedIndex = 1;
        }
        WatchUi.requestUpdate();
    }

    function getTitleY(height) {
        if (height < 280) {
            return 20;
        }
        return 24;
    }

    function getDividerY(height) {
        if (height < 280) {
            return 60;
        }
        return 68;
    }

    function getFirstOptionY(height) {
        if (height < 280) {
            return 82;
        }
        return 94;
    }

    function drawOptionRow(dc, centerX, rowY, rowFont, rowHeight, label, isSelected) as Void {
        if (isSelected) {
            var markerY = rowY - 8;
            var markerHeight = rowHeight + 10;
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(36, markerY, 4, markerHeight);
            dc.drawText(centerX, rowY, rowFont, label, Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(centerX, rowY, rowFont, label, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var titleY = getTitleY(height);
        var dividerY = getDividerY(height);
        var firstOptionY = getFirstOptionY(height);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var centerX = width / 2;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, titleY, Graphics.FONT_MEDIUM, _title, Graphics.TEXT_JUSTIFY_CENTER);

        var dividerMargin = 42;
        dc.fillRectangle(dividerMargin, dividerY, width - (dividerMargin * 2), 2);

        var rowFont = Graphics.FONT_LARGE;
        var rowHeight = dc.getFontHeight(rowFont);
        drawOptionRow(dc, centerX, firstOptionY, rowFont, rowHeight, _outdoorLabel, _selectedIndex == 0);
        drawOptionRow(dc, centerX, firstOptionY + OPTION_ROW_SPACING, rowFont, rowHeight, _indoorLabel, _selectedIndex == 1);
    }
}
