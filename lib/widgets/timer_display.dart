import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/solve_time.dart';
import '../providers/timer_provider.dart';
import '../providers/settings_provider.dart';

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
    this.displayMode = TimerDisplayMode.withDecimals,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (state == TimerState.inspection ||
        state == TimerState.holdingFromInspection ||
        state == TimerState.readyFromInspection) {
      return _InspectionDisplay(
        secondsLeft: inspectionSecondsLeft,
        isWarning: isInspectionWarning,
        isReady: state == TimerState.readyFromInspection,
        accentColor: accentColor, theme: theme);
    }

    final color = _color(theme);
    final timeStr = _formatTime();

    return Column(mainAxisSize: MainAxisSize.min, children: [
      if (state == TimerState.idle || state == TimerState.stopped)
        Padding(padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            state == TimerState.idle ? 'Tieni premuto per iniziare' : 'Tocca per un nuovo solve',
            style: theme.textTheme.bodyMedium)),
      Text(timeStr,
        style: GoogleFonts.nunito(
          fontSize: _fontSize(timeStr), color: color,
          fontWeight: FontWeight.w200, letterSpacing: -2)),
      if (state == TimerState.holding)
        Padding(padding: const EdgeInsets.only(top: 8),
          child: Text('Continua a tenere...', style: theme.textTheme.bodyMedium)),
      if (state == TimerState.ready)
        Padding(padding: const EdgeInsets.only(top: 8),
          child: Text('Rilascia per iniziare',
            style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF30D158)))),
    ]);
  }

  String _formatTime() {
    if (elapsedMs == 0 && state != TimerState.running) return '0.00';
    if (state == TimerState.running) {
      switch (displayMode) {
        case TimerDisplayMode.hidden:
          return '⬤ ⬤ ⬤';
        case TimerDisplayMode.withoutDecimals:
          return _noDecimals(elapsedMs);
        case TimerDisplayMode.withDecimals:
          // Show decimals under 10s only for readability
          return elapsedMs < 10000 ? SolveTime.format(elapsedMs) : _noDecimals(elapsedMs);
      }
    }
    return SolveTime.format(elapsedMs);
  }

  String _noDecimals(int ms) {
    final s = ms ~/ 1000, m = s ~/ 60;
    return m > 0 ? '$m:${(s%60).toString().padLeft(2,'0')}' : '$s';
  }

  Color _color(ThemeData th) {
    switch (state) {
      case TimerState.holding: return th.colorScheme.onSurface.withValues(alpha: 0.35);
      case TimerState.ready:   return const Color(0xFF30D158);
      default:                 return th.colorScheme.onSurface;
    }
  }

  double _fontSize(String t) {
    if (t == '⬤ ⬤ ⬤') return 36;
    if (t.contains(':')) return 72;
    if (t.length > 7) return 80;
    return 96;
  }
}

class _InspectionDisplay extends StatelessWidget {
  final int secondsLeft; final bool isWarning, isReady;
  final Color accentColor; final ThemeData theme;
  const _InspectionDisplay({required this.secondsLeft, required this.isWarning,
      required this.isReady, required this.accentColor, required this.theme});

  @override
  Widget build(BuildContext context) {
    final color = isReady ? const Color(0xFF30D158) : isWarning ? const Color(0xFFFF453A) : accentColor;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text('ISPEZIONE', style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 4)),
      const SizedBox(height: 8),
      AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: GoogleFonts.nunito(fontSize: 96, fontWeight: FontWeight.w200, color: color, letterSpacing: -4),
        child: Text('$secondsLeft')),
      const SizedBox(height: 8),
      Text(isReady ? 'Rilascia per avviare!' : 'Tieni premuto per avviare',
          style: theme.textTheme.bodyMedium?.copyWith(color: isReady ? const Color(0xFF30D158) : null)),
    ]);
  }
}
