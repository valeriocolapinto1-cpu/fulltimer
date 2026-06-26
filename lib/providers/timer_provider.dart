import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum TimerState { idle, holding, ready, inspection, holdingFromInspection, readyFromInspection, running, stopped }

class TimerProvider extends ChangeNotifier {
  TimerState _state = TimerState.idle;
  int  _elapsedMs = 0, _inspectionMs = 0, _inspectionLimit = 15000, _holdDurationMs = 550;
  bool _inspectionEnabled = true, _soundEnabled = true, _vibrationEnabled = true;
  bool _lateInspectionPenalty = false;
  Timer? _timer, _holdTimer;
  DateTime? _startTime, _inspectionStart;
  Function(int)? onTimerStop;

  TimerState get state => _state;
  int  get elapsedMs => _elapsedMs;
  int  get inspectionSecondsLeft => ((_inspectionLimit - _inspectionMs) / 1000).ceil().clamp(0, 99);
  bool get isInspectionWarning =>
      (_state == TimerState.inspection || _state == TimerState.holdingFromInspection || _state == TimerState.readyFromInspection)
      && inspectionSecondsLeft <= 3;
  bool get lateInspectionPenalty => _lateInspectionPenalty;

  void configure({required bool inspectionEnabled, required int holdDurationMs,
      required int inspectionDuration, required bool soundEnabled, required bool vibrationEnabled}) {
    _inspectionEnabled = true; _holdDurationMs = holdDurationMs;
    _inspectionLimit = 15000; _soundEnabled = soundEnabled;
    _vibrationEnabled = vibrationEnabled;
  }

  void onPointerDown() {
    switch (_state) {
      case TimerState.idle:       _startHolding(); break;
      case TimerState.stopped:    _elapsedMs = 0; _startHolding(); break;
      case TimerState.inspection: _startHoldingFromInspection(); break;
      case TimerState.running:    _stopTimer(); break;
      default: break;
    }
  }

  void onPointerUp() {
    switch (_state) {
      case TimerState.holding:               _cancelHold(); break;
      case TimerState.ready:                 _inspectionEnabled ? _startInspection() : _startTimer(); break;
      case TimerState.holdingFromInspection: _cancelHoldInspection(); break;
      case TimerState.readyFromInspection:   _startTimer(fromInspection: true); break;
      default: break;
    }
  }

  void _startHolding() {
    _holdTimer?.cancel(); _state = TimerState.holding; notifyListeners();
    _holdTimer = Timer(Duration(milliseconds: _holdDurationMs), () {
      if (_state == TimerState.holding) {
        _state = TimerState.ready;
        if (_vibrationEnabled) HapticFeedback.lightImpact();
        notifyListeners();
      }
    });
  }
  void _cancelHold() { _holdTimer?.cancel(); _state = TimerState.idle; notifyListeners(); }

  void _startHoldingFromInspection() {
    _holdTimer?.cancel(); _state = TimerState.holdingFromInspection; notifyListeners();
    _holdTimer = Timer(Duration(milliseconds: _holdDurationMs), () {
      if (_state == TimerState.holdingFromInspection) {
        _state = TimerState.readyFromInspection;
        if (_vibrationEnabled) HapticFeedback.lightImpact();
        notifyListeners();
      }
    });
  }
  void _cancelHoldInspection() { _holdTimer?.cancel(); _state = TimerState.inspection; notifyListeners(); }

  void _startInspection() {
    _timer?.cancel(); _state = TimerState.inspection; _inspectionMs = 0;
    _inspectionStart = DateTime.now(); notifyListeners();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      _inspectionMs = DateTime.now().difference(_inspectionStart!).inMilliseconds;
      if (_soundEnabled && _vibrationEnabled) {
        // Beep a 8s e 12s via HapticFeedback pattern
        if (_inspectionMs >= 8000  && _inspectionMs < 8100)  { HapticFeedback.heavyImpact(); }
        if (_inspectionMs >= 12000 && _inspectionMs < 12100) { HapticFeedback.vibrate(); }
      }
      if (_inspectionMs >= (_inspectionLimit + 2000)) {
        t.cancel(); _state = TimerState.idle; onTimerStop?.call(-2); notifyListeners(); return;
      }
      notifyListeners();
    });
  }

  void _startTimer({bool fromInspection = false}) {
    _timer?.cancel(); _holdTimer?.cancel();
    _state = TimerState.running; _elapsedMs = 0; _startTime = DateTime.now();
    _lateInspectionPenalty = fromInspection && _inspectionMs > _inspectionLimit;
    if (_vibrationEnabled) HapticFeedback.lightImpact();
    _timer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      _elapsedMs = DateTime.now().difference(_startTime!).inMilliseconds; notifyListeners();
    });
    notifyListeners();
  }

  void _stopTimer() {
    _timer?.cancel();
    _elapsedMs = DateTime.now().difference(_startTime!).inMilliseconds;
    _state = TimerState.stopped;
    if (_vibrationEnabled) HapticFeedback.mediumImpact();
    notifyListeners();
    onTimerStop?.call(_elapsedMs);
  }

  void reset() { _timer?.cancel(); _holdTimer?.cancel(); _state = TimerState.idle; _elapsedMs = 0; _inspectionMs = 0; _lateInspectionPenalty = false; notifyListeners(); }

  @override
  void dispose() { _timer?.cancel(); _holdTimer?.cancel(); super.dispose(); }
}
