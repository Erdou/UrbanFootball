using Toybox.Graphics;
using Toybox.System;
using Toybox.WatchUi;

class FootballAppGoalieModeView extends WatchUi.View {

    const OPTION_ROW_SPACING_TWO = 66;
    const OPTION_ROW_SPACING_THREE = 50;

    var _selectedIndex = 0;
    var _title = null;
    var _yesLabel = null;
    var _noLabel = null;
    var _cancelLabel = null;
    var _showCancelOption = false;

    function initialize(initialEnabled, showCancelOption) {
        View.initialize();
        _title = WatchUi.loadResource(Rez.Strings.goalieModeTitle);
        _yesLabel = WatchUi.loadResource(Rez.Strings.goalieModeYes);
        _noLabel = WatchUi.loadResource(Rez.Strings.goalieModeNo);
        _cancelLabel = WatchUi.loadResource(Rez.Strings.goalieModeCancel);
        _showCancelOption = showCancelOption;

        if (initialEnabled) {
            _selectedIndex = 0;
        } else {
            _selectedIndex = 1;
        }
    }

    function isTimerEnabledSelection() {
        return _selectedIndex == 0;
    }

    function isCancelSelection() {
        return _showCancelOption && _selectedIndex == 2;
    }

    function getOptionCount() {
        if (_showCancelOption) {
            return 3;
        }
        return 2;
    }

    function moveSelection(step) as Void {
        var optionCount = getOptionCount();
        _selectedIndex += step;
        if (_selectedIndex < 0) {
            _selectedIndex = optionCount - 1;
        } else if (_selectedIndex >= optionCount) {
            _selectedIndex = 0;
        }

        WatchUi.requestUpdate();
    }

    function selectFromTap(y) as Void {
        var height = System.getDeviceSettings().screenHeight;
        var firstOptionY = getFirstOptionY(height);
        var rowSpacing = getOptionRowSpacing(height);
        var optionCount = getOptionCount();

        var closestIndex = 0;
        var closestDistance = 9999;
        for (var i = 0; i < optionCount; i += 1) {
            var rowY = firstOptionY + (rowSpacing * i);
            var distance = y - rowY;
            if (distance < 0) {
                distance = -distance;
            }

            if (distance < closestDistance) {
                closestDistance = distance;
                closestIndex = i;
            }
        }

        _selectedIndex = closestIndex;
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
        if (_showCancelOption) {
            if (height < 280) {
                return 76;
            }
            return 86;
        }

        if (height < 280) {
            return 82;
        }
        return 94;
    }

    function getOptionRowSpacing(height) {
        if (_showCancelOption) {
            if (height < 280) {
                return 46;
            }
            return OPTION_ROW_SPACING_THREE;
        }

        if (height < 280) {
            return 62;
        }
        return OPTION_ROW_SPACING_TWO;
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
        var rowSpacing = getOptionRowSpacing(height);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var centerX = width / 2;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, titleY, Graphics.FONT_MEDIUM, _title, Graphics.TEXT_JUSTIFY_CENTER);

        var dividerMargin = 32;
        dc.fillRectangle(dividerMargin, dividerY, width - (dividerMargin * 2), 2);

        var rowFont = Graphics.FONT_LARGE;
        var rowHeight = dc.getFontHeight(rowFont);
        drawOptionRow(dc, centerX, firstOptionY, rowFont, rowHeight, _yesLabel, _selectedIndex == 0);
        drawOptionRow(dc, centerX, firstOptionY + rowSpacing, rowFont, rowHeight, _noLabel, _selectedIndex == 1);
        if (_showCancelOption) {
            drawOptionRow(dc, centerX, firstOptionY + (rowSpacing * 2), rowFont, rowHeight, _cancelLabel, _selectedIndex == 2);
        }
    }
}
