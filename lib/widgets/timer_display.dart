// widgets/timer_display.dart
// Display principale del timer con animazioni di stato

import 'package:flutter/material.dart';
import 'package:fulltimer/providers/settings_provider.dart';
import '../models/solve_time.dart';
import '../providers/timer_provider.dart';

class TimerDisplay extends StatelessWidget {
  final TimerState state;
  final int elapsedMs;
  final int inspectionSecondsLeft;
  final bool isInspectionWarning;
  final Color accentColor;
  final TimerDisplayMode displayMode;

  const TimerDisplay({
    super.key,
    required this.state,
    required this.elapsedMs,
    required this.inspectionSecondsLeft,
    required this.isInspectionWarning,
    required this.accentColor,
    required this.displayMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Stati che mostrano l'ispezione
    if (state == TimerState.inspection ||
        state == TimerState.holdingFromInspection ||
        state == TimerState.readyFromInspection) {
      return _InspectionDisplay(
        key: const ValueKey('inspection'),
        secondsLeft: inspectionSecondsLeft,
        isWarning: isInspectionWarning,
        isReady: state == TimerState.readyFromInspection,
        accentColor: accentColor,
        theme: theme,
      );
    }

    // Timer display normale
    final color = _timerColor(theme);
    final timeStr = (state == TimerState.idle || state == TimerState.stopped)
        ? _formatTime(elapsedMs)
        : _formatRunningTime(elapsedMs);

    return Column(
      key: ValueKey(state),
      mainAxisSize: MainAxisSize.min,
      children: [
        // Hint di stato
        if (state == TimerState.idle || state == TimerState.stopped)
          _StatusHint(state: state, theme: theme),

        // Tempo principale
        Text(
          timeStr,
          style: theme.textTheme.displayLarge?.copyWith(
            fontSize: _fontSize(timeStr),
            color: color,
            fontWeight: FontWeight.w200,
            letterSpacing: -2,
            fontFamily: 'monospace',
          ),
        ),

        if (state == TimerState.holding)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Continua a tenere...',
              style: theme.textTheme.bodyMedium,
            ),
          ),

        if (state == TimerState.ready)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Rilascia per iniziare',
              style: theme.textTheme.bodyMedium?.copyWith(color: accentColor),
            ),
          ),
      ],
    );
  }

  Color _timerColor(ThemeData theme) {
    switch (state) {
      case TimerState.holding:
        return theme.colorScheme.onSurface.withValues(alpha: 0.4);
      case TimerState.ready:
        return const Color(0xFF4CAF50);
      case TimerState.running:
        return theme.colorScheme.onSurface;
      default:
        return theme.colorScheme.onSurface;
    }
  }

  double _fontSize(String text) {
    if (text.contains(':')) return 72;
    if (text.length > 7) return 80;
    return 96;
  }

  String _formatRunningTime(int ms) {
    if (displayMode == TimerDisplayMode.hidden) return '--';
    if (displayMode == TimerDisplayMode.withoutDecimals) {
      final seconds = ms ~/ 1000;
      final minutes = seconds ~/ 60;
      if (minutes > 0) {
        return '$minutes:${(seconds % 60).toString().padLeft(2, '0')}';
      }
      return '$seconds';
    }
    return SolveTime.format(ms);
  }

  String _formatTime(int ms) {
    if (displayMode == TimerDisplayMode.hidden) return '--';
    if (ms == 0) return displayMode == TimerDisplayMode.withoutDecimals ? '0' : '0.00';
    if (displayMode == TimerDisplayMode.withoutDecimals) {
      final seconds = ms ~/ 1000;
      final minutes = seconds ~/ 60;
      if (minutes > 0) {
        return '$minutes:${(seconds % 60).toString().padLeft(2, '0')}';
      }
      return '$seconds';
    }
    return SolveTime.format(ms);
  }
}

// ── Inspection display ────────────────────────────────────────

class _InspectionDisplay extends StatelessWidget {
  final int secondsLeft;
  final bool isWarning;
  final bool isReady;
  final Color accentColor;
  final ThemeData theme;

  const _InspectionDisplay({
    super.key,
    required this.secondsLeft,
    required this.isWarning,
    required this.isReady,
    required this.accentColor,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final color = isReady
        ? const Color(0xFF4CAF50) // verde = pronto
        : isWarning
            ? const Color(0xFFFF5722) // arancione = warning
            : accentColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'ISPEZIONE',
          style: theme.textTheme.labelSmall?.copyWith(
            letterSpacing: 4,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 96,
            fontWeight: FontWeight.w200,
            color: color,
            letterSpacing: -4,
          ),
          child: Text('$secondsLeft'),
        ),
        const SizedBox(height: 8),
        Text(
          isReady ? 'Rilascia per avviare!' : 'Tieni premuto per avviare',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isReady ? const Color(0xFF4CAF50) : null,
          ),
        ),
      ],
    );
  }
}

// ── Status hint ───────────────────────────────────────────────

class _StatusHint extends StatelessWidget {
  final TimerState state;
  final ThemeData theme;

  const _StatusHint({required this.state, required this.theme});

  @override
  Widget build(BuildContext context) {
    final text = state == TimerState.idle
        ? 'Tieni premuto per iniziare'
        : 'Tocca per un nuovo solve';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}
