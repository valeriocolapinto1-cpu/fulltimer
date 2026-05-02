import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData build({required bool dark, required Color accent, String fontFamily = 'Nunito', bool transparent = false}) {
    final bg      = dark ? const Color(0xFF0D0D0D) : const Color(0xFFF2F2F7);
    final surface = dark ? const Color(0xFF1C1C1E) : Colors.white;
    final onSurf  = dark ? Colors.white : Colors.black;
    final subtle  = dark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);
    final br      = dark ? Brightness.dark : Brightness.light;

    TextStyle Function(TextStyle?) makeStyle;
    try {
      makeStyle = (base) => GoogleFonts.getFont(fontFamily, textStyle: base);
    } catch (_) {
      makeStyle = (base) => GoogleFonts.nunito(textStyle: base);
    }

    final tt = TextTheme(
      displayLarge:  makeStyle(TextStyle(color: onSurf, fontWeight: FontWeight.w200)),
      displayMedium: makeStyle(TextStyle(color: onSurf, fontWeight: FontWeight.w200)),
      titleLarge:    makeStyle(TextStyle(color: onSurf, fontWeight: FontWeight.w700)),
      titleMedium:   makeStyle(TextStyle(color: onSurf, fontWeight: FontWeight.w600)),
      bodyLarge:     makeStyle(TextStyle(color: onSurf)),
      bodyMedium:    makeStyle(TextStyle(color: onSurf.withValues(alpha: 0.65))),
      labelSmall:    makeStyle(TextStyle(color: onSurf.withValues(alpha: 0.45), letterSpacing: 1.2)),
    );

    return ThemeData(
      brightness: br, useMaterial3: true, textTheme: tt,
      colorScheme: ColorScheme(
        brightness: br,
        primary: accent,     onPrimary: contrastColor(accent),
        secondary: accent,   onSecondary: contrastColor(accent),
        surface: surface,    onSurface: onSurf,
        error: const Color(0xFFFF453A), onError: Colors.white,
      ),
      scaffoldBackgroundColor: transparent ? Colors.transparent : bg,
      cardColor: surface,
      dividerColor: subtle,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent, elevation: 0, centerTitle: true,
        titleTextStyle: makeStyle(TextStyle(color: onSurf, fontSize: 18, fontWeight: FontWeight.w700)),
        iconTheme: IconThemeData(color: onSurf),
      ),
      cardTheme: CardThemeData(
        color: surface, elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: subtle)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: accent, unselectedItemColor: onSurf.withValues(alpha: 0.35),
        elevation: 0, type: BottomNavigationBarType.fixed,
        selectedLabelStyle: makeStyle(const TextStyle(fontWeight: FontWeight.w700, fontSize: 10)),
        unselectedLabelStyle: makeStyle(const TextStyle(fontWeight: FontWeight.w500, fontSize: 10)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? accent : onSurf.withValues(alpha: 0.4)),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? accent.withValues(alpha: 0.3) : subtle),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accent, thumbColor: accent,
        inactiveTrackColor: subtle, overlayColor: accent.withValues(alpha: 0.2),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: subtle,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        hintStyle: makeStyle(TextStyle(color: onSurf.withValues(alpha: 0.4))),
        labelStyle: makeStyle(TextStyle(color: onSurf.withValues(alpha: 0.7))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        titleTextStyle: makeStyle(TextStyle(color: onSurf, fontSize: 18, fontWeight: FontWeight.w700)),
        contentTextStyle: makeStyle(TextStyle(color: onSurf.withValues(alpha: 0.8), fontSize: 14)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: makeStyle(TextStyle(color: onSurf, fontSize: 14)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: accent,
            textStyle: makeStyle(const TextStyle(fontWeight: FontWeight.w600)))),
      listTileTheme: ListTileThemeData(textColor: onSurf, iconColor: onSurf.withValues(alpha: 0.7)),
      bottomSheetTheme: const BottomSheetThemeData(shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)))),
    );
  }

  static Color contrastColor(Color c) => c.computeLuminance() > 0.4 ? Colors.black : Colors.white;
}
