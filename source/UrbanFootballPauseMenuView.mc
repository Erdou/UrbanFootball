using Toybox.Activity;
using Toybox.Graphics;
using Toybox.WatchUi;

class UrbanFootballPauseMenuView extends WatchUi.View {

    const RING_COLOR = Graphics.COLOR_RED;
    const RING_PEN_WIDTH = 6;
    const ITEM_START_Y = 98;
    const ITEM_SPACING = 40;
    const VISIBLE_ITEM_COUNT = 3;

    var _selectedIndex = 0;
    var _resumeLabel = null;
    var _saveLabel = null;
    var _resumeLaterLabel = null;
    var _discardLabel = null;
    var _timerTitle = null;

    function initialize() {
        View.initialize();

        _resumeLabel = WatchUi.loadResource(Rez.Strings.pauseMenuResume);
        _saveLabel = WatchUi.loadResource(Rez.Strings.pauseMenuSave);
        _resumeLaterLabel = WatchUi.loadResource(Rez.Strings.pauseMenuResumeLater);
        _discardLabel = WatchUi.loadResource(Rez.Strings.pauseMenuDiscard);
        _timerTitle = WatchUi.loadResource(Rez.Strings.pauseMenuTimerTitle);
    }

    function moveSelection(step) as Void {
        _selectedIndex += step;
        if (_selectedIndex < 0) {
            _selectedIndex = 3;
        } else if (_selectedIndex > 3) {
            _selectedIndex = 0;
        }

        WatchUi.requestUpdate();
    }

    function resetSelection() as Void {
        _selectedIndex = 0;
    }

    function selectFromTap(y) as Void {
        var scrollOffset = getScrollOffset();
        var maxOffset = 4 - VISIBLE_ITEM_COUNT;
        var closestIndex = 0;
        var closestDistance = 9999;
        for (var i = 0; i < VISIBLE_ITEM_COUNT; i += 1) {
            var rowY = ITEM_START_Y + (i * ITEM_SPACING);
            var distance = y - rowY;
            if (distance < 0) {
                distance = -distance;
            }
            if (distance < closestDistance) {
                closestDistance = distance;
                closestIndex = scrollOffset + i;
            }
        }

        if (scrollOffset < maxOffset) {
            var peekY = ITEM_START_Y + (VISIBLE_ITEM_COUNT * ITEM_SPACING);
            var peekDistance = y - peekY;
            if (peekDistance < 0) {
                peekDistance = -peekDistance;
            }
            if (peekDistance < closestDistance) {
                closestDistance = peekDistance;
                closestIndex = scrollOffset + VISIBLE_ITEM_COUNT;
            }
        }

        if (closestIndex > 3) {
            closestIndex = 3;
        }
        _selectedIndex = closestIndex;
        WatchUi.requestUpdate();
    }

    function isResumeSelection() {
        return _selectedIndex == 0;
    }

    function isResumeLaterSelection() {
        return _selectedIndex == 2;
    }

    function isDiscardSelection() {
        return _selectedIndex == 3;
    }

    function setSelectionIndex(index) as Void {
        if (index == null || index < 0) {
            _selectedIndex = 0;
        } else if (index > 3) {
            _selectedIndex = 3;
        } else {
            _selectedIndex = index;
        }
    }

    function getLabelForIndex(index) {
        if (index == 0) {
            return _resumeLabel;
        } else if (index == 1) {
            return _saveLabel;
        } else if (index == 2) {
            return _resumeLaterLabel;
        }
        return _discardLabel;
    }

    function getScrollOffset() {
        var offset = _selectedIndex - (VISIBLE_ITEM_COUNT - 1);
        if (offset < 0) {
            return 0;
        }

        var maxOffset = 4 - VISIBLE_ITEM_COUNT;
        if (offset > maxOffset) {
            return maxOffset;
        }
        return offset;
    }

    function formatActivityTime() {
        var info = Activity.getActivityInfo();
        var totalMs = 0;
        if (info != null) {
            if (info.timerTime != null) {
                totalMs = info.timerTime;
            } else if (info.elapsedTime != null) {
                totalMs = info.elapsedTime;
            }
        }

        var totalSeconds = totalMs / 1000;
        if (totalSeconds < 0) {
            totalSeconds = 0;
        }

        var hours = totalSeconds / 3600;
        var minutes = (totalSeconds % 3600) / 60;
        var seconds = totalSeconds % 60;

        if (hours > 0) {
            return hours.toString() + ":" + minutes.format("%02d") + ":" + seconds.format("%02d");
        }

        return minutes.toString() + ":" + seconds.format("%02d");
    }

    function drawPlayIcon(dc, x, y, size) as Void {
        var half = size / 2;
        dc.fillPolygon([
            [x - (half / 2), y - half],
            [x + half, y],
            [x - (half / 2), y + half]
        ]);
    }

    function drawSaveIcon(dc, x, y, size) as Void {
        var half = size / 2;
        var shaftHeight = size - 6;
        var shaftWidth = 4;
        var trayWidth = size + 6;

        dc.fillRectangle(x - (shaftWidth / 2), y - half, shaftWidth, shaftHeight);
        dc.fillPolygon([
            [x - half, y + 2],
            [x + half, y + 2],
            [x, y + half]
        ]);
        dc.fillRectangle(x - (trayWidth / 2), y + half + 2, trayWidth, 3);
    }

    function drawResumeLaterIcon(dc, x, y, size) as Void {
        var radius = size / 2;
        dc.setPenWidth(2);
        dc.drawCircle(x, y, radius);
        dc.setPenWidth(1);
        dc.fillRectangle(x - 1, y - (radius / 2), 2, radius / 2 + 2);
        dc.fillRectangle(x, y - 1, radius / 2 + 1, 2);
    }

    function drawDiscardIcon(dc, x, y, size) as Void {
        var half = size / 2;
        dc.setPenWidth(3);
        dc.drawLine(x - half, y - half, x + half, y + half);
        dc.drawLine(x - half, y + half, x + half, y - half);
        dc.setPenWidth(1);
    }

    function drawMenuRow(dc, textX, iconX, rowY, rowFont, rowHeight, label, isSelected, iconType) as Void {
        if (isSelected) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(34, rowY - 2, 4, rowHeight + 4);
        } else {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        }

        var iconCenterY = rowY + (rowHeight / 2) + 1;
        if (iconType == 0) {
            drawPlayIcon(dc, iconX, iconCenterY, 18);
        } else if (iconType == 1) {
            drawSaveIcon(dc, iconX, iconCenterY, 18);
        } else if (iconType == 2) {
            drawResumeLaterIcon(dc, iconX, iconCenterY, 16);
        } else {
            drawDiscardIcon(dc, iconX, iconCenterY, 16);
        }

        dc.drawText(textX, rowY, rowFont, label, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function drawOuterRing(dc, width, height) as Void {
        var centerX = width / 2;
        var centerY = height / 2;
        var minDimension = width;
        if (height < minDimension) {
            minDimension = height;
        }
        var ringRadius = (minDimension / 2) - (RING_PEN_WIDTH / 2);

        dc.setColor(RING_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(RING_PEN_WIDTH);
        dc.drawCircle(centerX, centerY, ringRadius);
        dc.setPenWidth(1);
    }

    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var rowFont = Graphics.FONT_MEDIUM;
        var rowHeight = dc.getFontHeight(rowFont);
        var scrollOffset = getScrollOffset();
        var maxOffset = 4 - VISIBLE_ITEM_COUNT;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var timerText = formatActivityTime();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 18, Graphics.FONT_XTINY, _timerTitle, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, 36, Graphics.FONT_LARGE, timerText, Graphics.TEXT_JUSTIFY_CENTER);

        var iconX = 52;
        var textX = 78;
        for (var i = 0; i < VISIBLE_ITEM_COUNT; i += 1) {
            var itemIndex = scrollOffset + i;
            if (itemIndex > 3) {
                break;
            }
            var rowY = ITEM_START_Y + (i * ITEM_SPACING);
            drawMenuRow(dc, textX, iconX, rowY, rowFont, rowHeight, getLabelForIndex(itemIndex), _selectedIndex == itemIndex, itemIndex);
        }

        // Show a cropped preview of the next item so users can see the list continues.
        if (scrollOffset < maxOffset) {
            var peekIndex = scrollOffset + VISIBLE_ITEM_COUNT;
            var peekY = ITEM_START_Y + (VISIBLE_ITEM_COUNT * ITEM_SPACING);
            drawMenuRow(dc, textX, iconX, peekY, rowFont, rowHeight, getLabelForIndex(peekIndex), false, peekIndex);
        }

        // Draw the ring last so it stays visually on top, like Garmin pause UI.
        drawOuterRing(dc, width, height);
    }
}
