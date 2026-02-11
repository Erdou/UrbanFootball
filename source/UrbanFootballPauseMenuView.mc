using Toybox.Activity;
using Toybox.Graphics;
using Toybox.WatchUi;

class UrbanFootballPauseMenuView extends WatchUi.View {

    const RING_COLOR = Graphics.COLOR_RED;
    const ITEM_START_Y = 102;
    const ITEM_SPACING = 44;

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
        var closestIndex = 0;
        var closestDistance = 9999;
        for (var i = 0; i < 4; i += 1) {
            var rowY = ITEM_START_Y + (i * ITEM_SPACING);
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

    function isResumeSelection() {
        return _selectedIndex == 0;
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

    function drawMenuRow(dc, textX, iconX, rowY, label, isSelected, iconType) as Void {
        if (isSelected) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(34, rowY - 16, 4, 30);
        } else {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        }

        if (iconType == 0) {
            drawPlayIcon(dc, iconX, rowY - 4, 18);
        } else if (iconType == 1) {
            drawSaveIcon(dc, iconX, rowY - 4, 18);
        } else if (iconType == 2) {
            drawResumeLaterIcon(dc, iconX, rowY - 4, 16);
        } else {
            drawDiscardIcon(dc, iconX, rowY - 4, 16);
        }

        dc.drawText(textX, rowY, Graphics.FONT_MEDIUM, label, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        dc.setColor(RING_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(6);
        dc.drawCircle(centerX, height / 2, (height / 2) - 12);
        dc.setPenWidth(1);

        var timerText = formatActivityTime();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 18, Graphics.FONT_XTINY, _timerTitle, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, 36, Graphics.FONT_LARGE, timerText, Graphics.TEXT_JUSTIFY_CENTER);

        var iconX = 52;
        var textX = 78;
        drawMenuRow(dc, textX, iconX, ITEM_START_Y, _resumeLabel, _selectedIndex == 0, 0);
        drawMenuRow(dc, textX, iconX, ITEM_START_Y + ITEM_SPACING, _saveLabel, _selectedIndex == 1, 1);
        drawMenuRow(dc, textX, iconX, ITEM_START_Y + (ITEM_SPACING * 2), _resumeLaterLabel, _selectedIndex == 2, 2);
        drawMenuRow(dc, textX, iconX, ITEM_START_Y + (ITEM_SPACING * 3), _discardLabel, _selectedIndex == 3, 3);
    }
}
