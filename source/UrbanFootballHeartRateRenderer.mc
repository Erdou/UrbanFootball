using Toybox.Graphics;

class UrbanFootballHeartRateRenderer {

    const HR_ZONE_1_MAX_BPM = 109;
    const HR_ZONE_2_MAX_BPM = 129;
    const HR_ZONE_3_MAX_BPM = 149;
    const HR_ZONE_4_MAX_BPM = 169;
    const HR_ZONE_5_MAX_BPM = 200;

    const HR_ZONE_1_START_DEG = 155;
    const HR_ZONE_1_END_DEG = 131;
    const HR_ZONE_2_START_DEG = 129;
    const HR_ZONE_2_END_DEG = 105;
    const HR_ZONE_3_START_DEG = 103;
    const HR_ZONE_3_END_DEG = 79;
    const HR_ZONE_4_START_DEG = 77;
    const HR_ZONE_4_END_DEG = 53;
    const HR_ZONE_5_START_DEG = 51;
    const HR_ZONE_5_END_DEG = 27;

    const HR_HEADER_DIVIDER_Y = 86;

    function initialize() {
    }

    function getHeartRateValue(activityInfo) {
        if (activityInfo != null && activityInfo.currentHeartRate != null) {
            return activityInfo.currentHeartRate;
        }
        return null;
    }

    function getZoneColor(hrValue) {
        if (hrValue == null) {
            return Graphics.COLOR_DK_GRAY;
        } else if (hrValue <= HR_ZONE_1_MAX_BPM) {
            return Graphics.COLOR_DK_GRAY;
        } else if (hrValue <= HR_ZONE_2_MAX_BPM) {
            return Graphics.COLOR_BLUE;
        } else if (hrValue <= HR_ZONE_3_MAX_BPM) {
            return Graphics.COLOR_GREEN;
        } else if (hrValue <= HR_ZONE_4_MAX_BPM) {
            return Graphics.COLOR_ORANGE;
        }
        return Graphics.COLOR_RED;
    }

    function drawHeader(dc, width, height, hrValue, primaryTextColor) as Void {
        var centerX = width / 2;
        var centerY = height / 2;
        var gaugeRadius = (height / 2) - 12;
        var cursorAngle = getCursorAngle(hrValue);
        var heartColor = getZoneColor(hrValue);
        var hrText = "--";
        if (hrValue != null) {
            hrText = hrValue.toString();
        }

        dc.setPenWidth(8);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(centerX, centerY, gaugeRadius, Graphics.ARC_CLOCKWISE, HR_ZONE_1_START_DEG, HR_ZONE_1_END_DEG);

        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(centerX, centerY, gaugeRadius, Graphics.ARC_CLOCKWISE, HR_ZONE_2_START_DEG, HR_ZONE_2_END_DEG);

        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(centerX, centerY, gaugeRadius, Graphics.ARC_CLOCKWISE, HR_ZONE_3_START_DEG, HR_ZONE_3_END_DEG);

        dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(centerX, centerY, gaugeRadius, Graphics.ARC_CLOCKWISE, HR_ZONE_4_START_DEG, HR_ZONE_4_END_DEG);

        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(centerX, centerY, gaugeRadius, Graphics.ARC_CLOCKWISE, HR_ZONE_5_START_DEG, HR_ZONE_5_END_DEG);

        dc.setColor(primaryTextColor, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(10);
        dc.drawArc(centerX, centerY, gaugeRadius, Graphics.ARC_CLOCKWISE, cursorAngle + 1, cursorAngle - 1);

        dc.setPenWidth(1);
        drawHeartGlyph(dc, centerX - 32, 48, 20, heartColor);
        dc.setColor(primaryTextColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX + 18, 30, Graphics.FONT_LARGE, hrText, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(34, HR_HEADER_DIVIDER_Y, width - 34, HR_HEADER_DIVIDER_Y);
        dc.setPenWidth(1);
    }

    function getCursorAngle(hrValue) {
        if (hrValue == null) {
            return HR_ZONE_1_START_DEG;
        } else if (hrValue <= HR_ZONE_1_MAX_BPM) {
            // Keep the cursor moving smoothly inside each HR zone.
            return interpolateRange(hrValue, 60, HR_ZONE_1_MAX_BPM, HR_ZONE_1_START_DEG, HR_ZONE_1_END_DEG);
        } else if (hrValue <= HR_ZONE_2_MAX_BPM) {
            return interpolateRange(hrValue, 110, HR_ZONE_2_MAX_BPM, HR_ZONE_2_START_DEG, HR_ZONE_2_END_DEG);
        } else if (hrValue <= HR_ZONE_3_MAX_BPM) {
            return interpolateRange(hrValue, 130, HR_ZONE_3_MAX_BPM, HR_ZONE_3_START_DEG, HR_ZONE_3_END_DEG);
        } else if (hrValue <= HR_ZONE_4_MAX_BPM) {
            return interpolateRange(hrValue, 150, HR_ZONE_4_MAX_BPM, HR_ZONE_4_START_DEG, HR_ZONE_4_END_DEG);
        }

        return interpolateRange(hrValue, 170, HR_ZONE_5_MAX_BPM, HR_ZONE_5_START_DEG, HR_ZONE_5_END_DEG);
    }

    function interpolateRange(value, inMin, inMax, outMin, outMax) {
        if (inMax <= inMin) {
            return outMin;
        }

        var clamped = value;
        if (clamped < inMin) {
            clamped = inMin;
        } else if (clamped > inMax) {
            clamped = inMax;
        }

        var ratio = (clamped - inMin) * 1.0 / (inMax - inMin);
        return outMin + ((outMax - outMin) * ratio);
    }

    function drawHeartGlyph(dc, centerX, centerY, size, color) as Void {
        var half = size / 2;
        var quarter = size / 4;
        var topY = centerY - (size / 6);

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX - quarter, topY, quarter);
        dc.fillCircle(centerX + quarter, topY, quarter);
        dc.fillPolygon([
            [centerX - half, topY],
            [centerX + half, topY],
            [centerX, centerY + half]
        ]);
    }
}
