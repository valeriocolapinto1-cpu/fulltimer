import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fulltimer/providers/timer_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('does not trigger haptics when vibration disabled', (tester) async {
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        calls.add(call);
        return null;
      },
    );

    final provider = TimerProvider();
    provider.configure(
      inspectionEnabled: true,
      holdDurationMs: 10,
      inspectionDuration: 15,
      soundEnabled: true,
      vibrationEnabled: false,
    );

    provider.onPointerDown();
    await tester.pump(const Duration(milliseconds: 15));
    provider.onPointerUp();
    await tester.pump(const Duration(milliseconds: 30));

    expect(
      calls.where((c) => c.method == 'HapticFeedback.vibrate'),
      isEmpty,
    );

    provider.reset();
  });
}
