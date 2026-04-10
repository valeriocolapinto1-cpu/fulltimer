import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TimerDisplayMode { hidden, full, withDecimals, withoutDecimals }

class SettingsProvider extends ChangeNotifier {
  late SharedPreferences _prefs;

  bool   _dark        = true;
  Color  _accent      = const Color(0xFF6C63FF);
  Color  _g1          = const Color(0xFF0D0D0D);
  Color  _g2          = const Color(0xFF1a1a2e);
  bool   _useGrad     = false;
  double _bright      = 1.0;
  bool   _inspection  = true;
  int    _inspDur     = 15;
  bool   _sound       = true;
  bool   _vibration   = true;
  int    _hold        = 550;
  bool   _manual      = false;
  String _font        = 'Nunito';
  TimerDisplayMode _timerDisplay = TimerDisplayMode.full;
  bool   _showScramblePreview = true;

  bool   get darkMode           => _dark;
  Color  get accentColor        => _accent;
  Color  get gradientColor1     => _g1;
  Color  get gradientColor2     => _g2;
  bool   get useGradient        => _useGrad;
  double get gradientBrightness => _bright;
  bool   get inspectionEnabled  => _inspection;
  int    get inspectionDuration => _inspDur;
  bool   get soundEnabled       => _sound;
  bool   get vibrationEnabled   => _vibration;
  int    get holdDuration       => _hold;
  bool   get manualInput        => _manual;
  String get fontFamily         => _font;
  TimerDisplayMode get timerDisplay => _timerDisplay;
  bool   get showScramblePreview => _showScramblePreview;

  Color get effectiveGradient1 => _applyB(_g1);
  Color get effectiveGradient2 => _applyB(_g2);
  Color _applyB(Color c) {
    final h = HSLColor.fromColor(c);
    return h.withLightness((h.lightness * _bright).clamp(0.0, 0.85)).toColor();
  }

  static const accentColors = [
    Color(0xFF6C63FF), Color(0xFF00BCD4), Color(0xFF30D158),
    Color(0xFFFF9F0A), Color(0xFFFF453A), Color(0xFFFF375F),
    Color(0xFFBF5AF2), Color(0xFF64D2FF), Color(0xFFFFEB3B),
    Color(0xFF9E9E9E), Color(0xFFFFFFFF), Color(0xFF000000),
  ];

  static const gradientPalette = [
    Color(0xFF000000), Color(0xFF0D0D0D), Color(0xFF1C1C1E),
    Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460),
    Color(0xFF1b1b2f), Color(0xFF2d132c), Color(0xFF0a3d2e),
    Color(0xFF1a0533), Color(0xFF2c2c54), Color(0xFF130f40),
    Color(0xFF0d2137), Color(0xFF1a2744), Color(0xFF0a1628),
    Color(0xFF1e1e2e), Color(0xFF11111b), Color(0xFF181825),
    Color(0xFF313244), Color(0xFF45475a), Color(0xFF585b70),
    Color(0xFF6c7086), Color(0xFF7f849c), Color(0xFF9399b2),
  ];

  static const availableFonts = ['Nunito','Roboto','Poppins','Montserrat','Lato','Raleway'];

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _dark       = _prefs.getBool('dark')        ?? true;
    _accent     = Color(_prefs.getInt('accent') ?? const Color(0xFF6C63FF).toARGB32());
    _g1         = Color(_prefs.getInt('g1')     ?? const Color(0xFF0D0D0D).toARGB32());
    _g2         = Color(_prefs.getInt('g2')     ?? const Color(0xFF1a1a2e).toARGB32());
    _useGrad    = _prefs.getBool('useGrad')     ?? false;
    _bright     = _prefs.getDouble('bright')    ?? 1.0;
    _inspection = _prefs.getBool('inspection')  ?? true;
    _inspDur    = _prefs.getInt('inspDur')      ?? 15;
    _sound      = _prefs.getBool('sound')       ?? true;
    _vibration  = _prefs.getBool('vibration')   ?? true;
    _hold       = _prefs.getInt('hold')         ?? 550;
    _manual     = _prefs.getBool('manual')      ?? false;
    _font       = _prefs.getString('font')      ?? 'Nunito';
    _timerDisplay = TimerDisplayMode.values[_prefs.getInt('timerDisplay') ?? 0];
    _showScramblePreview = _prefs.getBool('scramblePreview') ?? true;
    notifyListeners();
  }

  Future<void> _set(Future<void> Function() fn) async { await fn(); notifyListeners(); }

  Future<void> setDarkMode(bool v)              => _set(() async { _dark=v;        await _prefs.setBool('dark',v); });
  Future<void> setAccentColor(Color c)          => _set(() async { _accent=c;      await _prefs.setInt('accent',c.toARGB32()); });
  Future<void> setGradientColor1(Color c)       => _set(() async { _g1=c;          await _prefs.setInt('g1',c.toARGB32()); });
  Future<void> setGradientColor2(Color c)       => _set(() async { _g2=c;          await _prefs.setInt('g2',c.toARGB32()); });
  Future<void> setUseGradient(bool v)           => _set(() async { _useGrad=v;     await _prefs.setBool('useGrad',v); });
  Future<void> setGradientBrightness(double v)  => _set(() async { _bright=v;      await _prefs.setDouble('bright',v); });
  Future<void> setInspectionEnabled(bool v)     => _set(() async { _inspection=v;  await _prefs.setBool('inspection',v); });
  Future<void> setInspectionDuration(int s)     => _set(() async { _inspDur=s;     await _prefs.setInt('inspDur',s); });
  Future<void> setSoundEnabled(bool v)          => _set(() async { _sound=v;       await _prefs.setBool('sound',v); });
  Future<void> setVibrationEnabled(bool v)      => _set(() async { _vibration=v;   await _prefs.setBool('vibration',v); });
  Future<void> setHoldDuration(int ms)          => _set(() async { _hold=ms;       await _prefs.setInt('hold',ms); });
  Future<void> setManualInput(bool v)           => _set(() async { _manual=v;      await _prefs.setBool('manual',v); });
  Future<void> setFontFamily(String v)          => _set(() async { _font=v;        await _prefs.setString('font',v); });
  Future<void> setTimerDisplay(TimerDisplayMode m) => _set(() async { _timerDisplay=m; await _prefs.setInt('timerDisplay',m.index); });
  Future<void> setShowScramblePreview(bool v)   => _set(() async { _showScramblePreview=v; await _prefs.setBool('scramblePreview',v); });
}
