using Toybox.Activity;
using Toybox.Attention;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;
using Toybox.Timer;
using Toybox.WatchUi;

class UrbanFootballActivityView extends WatchUi.View {

    const GOALIE_ALERT_PULSE_INTERVAL_MS = 900;
    const GOALIE_ALERT_PULSE_DURATION_MS = 80;
    const GOALIE_ALERT_PULSE_STRENGTH = 30;
    const START_ANIMATION_DURATION_MS = 1400;
    const PAUSE_ANIMATION_DURATION_MS = 900;
    const SCORE_UNDO_WINDOW_MS = 3000;
    const SCORE_LINE_Y_OFFSET = -50;
    const SCORE_ICON_HIT_PADDING = 12;

    var scoreA = 0;
    var scoreB = 0;
    var goalieTimerStart = 0;
    var goalieTimerEnabled = true;
    var goalieTimerDurationSeconds = 420;

    var session = null;
    var isRecording = false;
    var activityStarted = false;

    var _footIcon = null;
    var _gameTimeLabel = null;
    var _gameTimeSeparator = null;
    var _goalieTimePrefix = null;
    var _preStartTitle = null;
    var _startAnimationUntil = null;
    var _pauseAnimationUntil = null;
    var _lastGoalieAlertAt = null;
    var _sessionTimeOffsetMs = 0;
    var _goaliePausedRemainingSeconds = null;
    var _scoreUndoSide = null;
    var _scoreUndoExpiresAt = null;
    var _scoreIconTapBounds = null;

    var _refreshTimer;
    var _startAnimationTimer;
    var _pauseAnimationTimer;
    var _scoreUndoTimer;

    var _heartRateRenderer;
    var _preStartRenderer;
    var _mainScreenRenderer;

    function initialize() {
        View.initialize();

        goalieTimerStart = System.getTimer();
        _footIcon = WatchUi.loadResource(Rez.Drawables.FootIconScore) as Graphics.BitmapType;
        _gameTimeLabel = WatchUi.loadResource(Rez.Strings.gameTimeLabel);
        _gameTimeSeparator = WatchUi.loadResource(Rez.Strings.gameTimeSeparator);
        _goalieTimePrefix = WatchUi.loadResource(Rez.Strings.goalieTimePrefix);
        _preStartTitle = WatchUi.loadResource(Rez.Strings.preStartTitle);

        _heartRateRenderer = new UrbanFootballHeartRateRenderer();
        _preStartRenderer = new UrbanFootballPreStartRenderer();
        _mainScreenRenderer = new UrbanFootballMainScreenRenderer();

        _refreshTimer = new Timer.Timer();
        _refreshTimer.start(method(:onTimerTick), 1000, true);

        _startAnimationTimer = new Timer.Timer();
        _pauseAnimationTimer = new Timer.Timer();
        _scoreUndoTimer = new Timer.Timer();
    }

    function onTimerTick() as Void {
        // Central heartbeat for time-based UI updates and goalie overtime vibration.
        maybeExpireScoreUndoWindow();
        maybePulseGoalieAlert();
        WatchUi.requestUpdate();
    }

    function configureGoalieTimer(enabled, durationMinutes, resetTimer) as Void {
        goalieTimerEnabled = enabled;

        if (durationMinutes < 1) {
            goalieTimerDurationSeconds = 60;
        } else {
            goalieTimerDurationSeconds = durationMinutes * 60;
        }

        if (resetTimer == null || resetTimer) {
            // Preserve timer only when returning from in-activity settings.
            goalieTimerStart = System.getTimer();
            _goaliePausedRemainingSeconds = null;
            if (activityStarted && !isRecording) {
                _goaliePausedRemainingSeconds = goalieTimerDurationSeconds;
            }
            _lastGoalieAlertAt = null;
        }
    }

    function computeGoalieRemainingFromClock(nowMs) {
        var elapsedSeconds = (nowMs - goalieTimerStart) / 1000;
        return goalieTimerDurationSeconds - elapsedSeconds;
    }

    function getGoalieRemainingSeconds() {
        if (!activityStarted) {
            return goalieTimerDurationSeconds;
        }

        if (!isRecording && _goaliePausedRemainingSeconds != null) {
            return _goaliePausedRemainingSeconds;
        }

        return computeGoalieRemainingFromClock(System.getTimer());
    }

    function pauseGoalieTimer() as Void {
        if (!activityStarted) {
            return;
        }

        _goaliePausedRemainingSeconds = computeGoalieRemainingFromClock(System.getTimer());
        _lastGoalieAlertAt = null;
    }

    function resumeGoalieTimer() as Void {
        if (!activityStarted || _goaliePausedRemainingSeconds == null) {
            return;
        }

        var elapsedSeconds = goalieTimerDurationSeconds - _goaliePausedRemainingSeconds;
        goalieTimerStart = System.getTimer() - (elapsedSeconds * 1000);
        _goaliePausedRemainingSeconds = null;
        _lastGoalieAlertAt = null;
    }

    function resetGoalieTimer() as Void {
        goalieTimerStart = System.getTimer();
        _goaliePausedRemainingSeconds = null;
        if (activityStarted && !isRecording) {
            _goaliePausedRemainingSeconds = goalieTimerDurationSeconds;
        }
        _lastGoalieAlertAt = null;
    }

    function startScoreUndoWindow(isLeft) as Void {
        _scoreUndoSide = isLeft;
        _scoreUndoExpiresAt = System.getTimer() + SCORE_UNDO_WINDOW_MS;
        _scoreUndoTimer.start(method(:onScoreUndoEndTick), SCORE_UNDO_WINDOW_MS + 30, false);
    }

    function clearScoreUndoWindow() as Void {
        _scoreUndoSide = null;
        _scoreUndoExpiresAt = null;
        _scoreUndoTimer.stop();
    }

    function maybeExpireScoreUndoWindow() as Void {
        if (_scoreUndoExpiresAt == null) {
            return;
        }

        if (!isScoreUndoWindowActive()) {
            clearScoreUndoWindow();
        }
    }

    function isScoreUndoWindowActive() {
        return (_scoreUndoExpiresAt != null) && (System.getTimer() < _scoreUndoExpiresAt);
    }

    function shouldHighlightLeftScore() {
        return isScoreUndoWindowActive() && (_scoreUndoSide != null) && _scoreUndoSide;
    }

    function shouldHighlightRightScore() {
        return isScoreUndoWindowActive() && (_scoreUndoSide != null) && !_scoreUndoSide;
    }

    function shouldShowScoreCancelIcon() {
        return isScoreUndoWindowActive() && (_scoreUndoSide != null);
    }

    function undoLastScoreIncrease() {
        if (!isScoreUndoWindowActive() || _scoreUndoSide == null) {
            return false;
        }

        if (_scoreUndoSide) {
            if (scoreA > 0) {
                scoreA -= 1;
            }
        } else {
            if (scoreB > 0) {
                scoreB -= 1;
            }
        }

        clearScoreUndoWindow();
        return true;
    }

    function isTapOnScoreCancelIcon(x, y) {
        if (!isScoreUndoWindowActive() || _scoreIconTapBounds == null) {
            return false;
        }

        var left = _scoreIconTapBounds["left"];
        var right = _scoreIconTapBounds["right"];
        var top = _scoreIconTapBounds["top"];
        var bottom = _scoreIconTapBounds["bottom"];
        return (x >= left) && (x <= right) && (y >= top) && (y <= bottom);
    }

    function updateScoreIconTapBounds(width, height, scoreHeight) as Void {
        var iconWidth = 56;
        var iconHeight = 56;
        if (_footIcon != null) {
            iconWidth = _footIcon.getWidth();
            iconHeight = _footIcon.getHeight();
        }

        var centerX = width / 2;
        var centerY = height / 2;
        var scoreY = centerY + SCORE_LINE_Y_OFFSET;
        var iconX = centerX - (iconWidth / 2);
        var iconY = scoreY + ((scoreHeight - iconHeight) / 2);

        _scoreIconTapBounds = {
            "left" => iconX - SCORE_ICON_HIT_PADDING,
            "right" => iconX + iconWidth + SCORE_ICON_HIT_PADDING,
            "top" => iconY - SCORE_ICON_HIT_PADDING,
            "bottom" => iconY + iconHeight + SCORE_ICON_HIT_PADDING
        };
    }

    function maybePulseGoalieAlert() as Void {
        if (!goalieTimerEnabled || !isRecording || !(Attention has :vibrate)) {
            _lastGoalieAlertAt = null;
            return;
        }

        var remainingSeconds = getGoalieRemainingSeconds();
        if (remainingSeconds >= 0) {
            _lastGoalieAlertAt = null;
            return;
        }

        var now = System.getTimer();
        if (_lastGoalieAlertAt != null && ((now - _lastGoalieAlertAt) < GOALIE_ALERT_PULSE_INTERVAL_MS)) {
            return;
        }

        var vibeData = [new Attention.VibeProfile(GOALIE_ALERT_PULSE_DURATION_MS, GOALIE_ALERT_PULSE_STRENGTH)];
        Attention.vibrate(vibeData);
        _lastGoalieAlertAt = now;
    }

    function formatGoalieTime(remainingSeconds) {
        var isOvertime = remainingSeconds < 0;
        var displaySeconds = remainingSeconds;
        var signPrefix = "";
        if (isOvertime) {
            displaySeconds = -displaySeconds;
            signPrefix = "-";
        }

        var minutes = displaySeconds / 60;
        var seconds = displaySeconds % 60;
        return signPrefix + minutes.format("%02d") + ":" + seconds.format("%02d");
    }

    function formatGameTime(activityInfo) {
        if (!activityStarted) {
            return "--:--";
        }

        var totalSeconds = getCurrentGameTimeMs(activityInfo) / 1000;
        if (totalSeconds < 0) {
            totalSeconds = 0;
        }

        var hours = totalSeconds / 3600;
        var minutes = (totalSeconds % 3600) / 60;
        var seconds = totalSeconds % 60;

        if (hours > 0) {
            return hours.toString() + ":" + minutes.format("%02d") + ":" + seconds.format("%02d");
        }

        return minutes.format("%02d") + ":" + seconds.format("%02d");
    }

    function formatGameLine(gameTimeText) {
        var label = "Game";
        if (_gameTimeLabel != null) {
            label = _gameTimeLabel;
        }

        var separator = ": ";
        if (_gameTimeSeparator != null) {
            separator = _gameTimeSeparator;
        }

        return label + separator + gameTimeText;
    }

    function formatGoalieLine(goalieTimeText) {
        var prefix = "Goalie: ";
        if (_goalieTimePrefix != null) {
            prefix = _goalieTimePrefix;
        }

        return prefix + goalieTimeText;
    }

    function getCurrentGameTimeMs(activityInfo) {
        var liveSessionMs = 0;
        if (session != null && activityInfo != null) {
            if (activityInfo.timerTime != null) {
                liveSessionMs = activityInfo.timerTime;
            } else if (activityInfo.elapsedTime != null) {
                liveSessionMs = activityInfo.elapsedTime;
            }
        }

        if (liveSessionMs < 0) {
            liveSessionMs = 0;
        }

        return _sessionTimeOffsetMs + liveSessionMs;
    }

    function triggerStartAnimation() as Void {
        _startAnimationUntil = System.getTimer() + START_ANIMATION_DURATION_MS;
        _startAnimationTimer.start(method(:onStartAnimationEndTick), START_ANIMATION_DURATION_MS + 30, false);
        WatchUi.requestUpdate();
    }

    function triggerPauseAnimation() as Void {
        _pauseAnimationUntil = System.getTimer() + PAUSE_ANIMATION_DURATION_MS;
        _pauseAnimationTimer.start(method(:onPauseAnimationEndTick), PAUSE_ANIMATION_DURATION_MS + 30, false);
        WatchUi.requestUpdate();
    }

    function markActivityStarted() as Void {
        // Goalie timing starts from real activity start, not from screen entry.
        activityStarted = true;
        _sessionTimeOffsetMs = 0;
        goalieTimerStart = System.getTimer();
        _goaliePausedRemainingSeconds = null;
        _lastGoalieAlertAt = null;
        clearScoreUndoWindow();
        triggerStartAnimation();
    }

    function setSessionTimeOffsetMs(offsetMs) as Void {
        if (offsetMs == null || offsetMs < 0) {
            _sessionTimeOffsetMs = 0;
        } else {
            _sessionTimeOffsetMs = offsetMs;
        }
    }

    function getSessionTimeOffsetMs() {
        return _sessionTimeOffsetMs;
    }

    function getCurrentGameTimeForPersistence() {
        return getCurrentGameTimeMs(Activity.getActivityInfo());
    }

    function applyResumeLaterState(state as Lang.Dictionary) as Void {
        var restoredScoreA = state["scoreA"];
        if (restoredScoreA != null) {
            scoreA = restoredScoreA;
        } else {
            scoreA = 0;
        }

        var restoredScoreB = state["scoreB"];
        if (restoredScoreB != null) {
            scoreB = restoredScoreB;
        } else {
            scoreB = 0;
        }

        var restoredGoalieEnabled = state["goalieTimerEnabled"];
        goalieTimerEnabled = restoredGoalieEnabled != null ? restoredGoalieEnabled : true;

        var restoredGoalieDurationSeconds = state["goalieTimerDurationSeconds"];
        if (restoredGoalieDurationSeconds != null && restoredGoalieDurationSeconds > 0) {
            goalieTimerDurationSeconds = restoredGoalieDurationSeconds;
        } else {
            goalieTimerDurationSeconds = 420;
        }

        activityStarted = true;
        isRecording = false;
        session = null;

        var restoredGoalieRemainingSeconds = state["goalieRemainingSeconds"];
        if (restoredGoalieRemainingSeconds == null) {
            restoredGoalieRemainingSeconds = goalieTimerDurationSeconds;
        }

        var elapsedGoalieSeconds = goalieTimerDurationSeconds - restoredGoalieRemainingSeconds;
        goalieTimerStart = System.getTimer() - (elapsedGoalieSeconds * 1000);
        _goaliePausedRemainingSeconds = restoredGoalieRemainingSeconds;

        var restoredGameTimeMs = state["gameTimeMs"];
        setSessionTimeOffsetMs(restoredGameTimeMs);

        _startAnimationUntil = null;
        _pauseAnimationUntil = null;
        _lastGoalieAlertAt = null;
        clearScoreUndoWindow();
        _scoreIconTapBounds = null;
    }

    function onStartAnimationEndTick() as Void {
        WatchUi.requestUpdate();
    }

    function onPauseAnimationEndTick() as Void {
        WatchUi.requestUpdate();
    }

    function onScoreUndoEndTick() as Void {
        maybeExpireScoreUndoWindow();
        WatchUi.requestUpdate();
    }

    function isStartAnimationActive() {
        return (_startAnimationUntil != null) && (System.getTimer() <= _startAnimationUntil);
    }

    function isPauseAnimationActive() {
        return (_pauseAnimationUntil != null) && (System.getTimer() <= _pauseAnimationUntil);
    }

    function getPauseAnimationDurationMs() {
        return PAUSE_ANIMATION_DURATION_MS;
    }

    function onLayout(dc) {
    }

    function onShow() {
    }

    function onUpdate(dc) {
        maybeExpireScoreUndoWindow();
        var width = dc.getWidth();
        var height = dc.getHeight();
        var remainingSeconds = getGoalieRemainingSeconds();
        var goalieTimeText = formatGoalieTime(remainingSeconds);
        var formattedGoalieTimeText = formatGoalieLine(goalieTimeText);
        // Pre-start layout stays visible during the start overlay to mimic Garmin flow.
        var showPreStartScreen = !activityStarted || isStartAnimationActive();

        if (showPreStartScreen) {
            _scoreIconTapBounds = null;
            _preStartRenderer.drawScreen(dc, width, height, _footIcon, _preStartTitle, goalieTimerEnabled, formattedGoalieTimeText, !activityStarted);
        } else {
            var activityInfo = Activity.getActivityInfo();
            var hrValue = _heartRateRenderer.getHeartRateValue(activityInfo);
            var gameTime = formatGameTime(activityInfo);
            var gameTimeText = formatGameLine(gameTime);
            var scoreHeight = dc.getFontHeight(Graphics.FONT_NUMBER_HOT);
            updateScoreIconTapBounds(width, height, scoreHeight);
            _mainScreenRenderer.drawScreen(
                dc,
                width,
                height,
                _heartRateRenderer,
                hrValue,
                _footIcon,
                scoreA,
                scoreB,
                shouldHighlightLeftScore(),
                shouldHighlightRightScore(),
                shouldShowScoreCancelIcon(),
                gameTimeText,
                goalieTimerEnabled,
                formattedGoalieTimeText,
                remainingSeconds < 0,
                isRecording,
                activityStarted
            );
        }

        // Keep overlay and pre-start background together during start transition.
        if (isStartAnimationActive()) {
            _preStartRenderer.drawStartAnimationOverlay(dc, width, height);
        } else if (isPauseAnimationActive()) {
            _mainScreenRenderer.drawPauseAnimationOverlay(dc, width, height);
        }
    }

    function onHide() {
    }
}
