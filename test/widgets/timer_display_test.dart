import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fulltimer/providers/settings_provider.dart';
import 'package:fulltimer/providers/timer_provider.dart';
import 'package:fulltimer/widgets/timer_display.dart';

void main() {
  Widget wrap(TimerDisplayMode mode, {required int elapsedMs}) {
    return MaterialApp(
      home: Scaffold(
        body: TimerDisplay(
          state: TimerState.stopped,
          elapsedMs: elapsedMs,
          inspectionSecondsLeft: 0,
          isInspectionWarning: false,
          accentColor: Colors.blue,
          displayMode: mode,
        ),
      ),
    );
  }

  testWidgets('shows hidden marker in hidden mode', (tester) async {
    await tester.pumpWidget(wrap(TimerDisplayMode.hidden, elapsedMs: 12345));
    expect(find.text('--'), findsOneWidget);
  });

  testWidgets('shows integer seconds in withoutDecimals mode', (tester) async {
    await tester.pumpWidget(
      wrap(TimerDisplayMode.withoutDecimals, elapsedMs: 12345),
    );
    expect(find.text('12'), findsOneWidget);
  });

  testWidgets('shows centiseconds in withDecimals mode', (tester) async {
    await tester.pumpWidget(
      wrap(TimerDisplayMode.withDecimals, elapsedMs: 12345),
    );
    expect(find.text('12.34'), findsOneWidget);
  });
}
