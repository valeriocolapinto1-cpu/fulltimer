import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/session_provider.dart';
import '../providers/l10n_provider.dart';
import '../widgets/glass_button.dart';

Color _cc(Color c) => c.computeLuminance() > 0.35 ? Colors.black : Colors.white;

const _langNames = {
  'it':'🇮🇹 Italiano','en':'🇬🇧 English','es':'🇪🇸 Español','fr':'🇫🇷 Français',
  'de':'🇩🇪 Deutsch','pt':'🇧🇷 Português','ru':'🇷🇺 Русский','zh':'🇨🇳 中文',
  'ja':'🇯🇵 日本語','ko':'🇰🇷 한국어','ar':'🇸🇦 العربية','nl':'🇳🇱 Nederlands',
  'pl':'🇵🇱 Polski','tr':'🇹🇷 Türkçe','sv':'🇸🇪 Svenska',
};

const _fontNames = ['Nunito','Roboto','Poppins','Montserrat','Lato','Oswald','Raleway','Merriweather'];

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s  = context.watch<SettingsProvider>();
    final se = context.watch<SessionProvider>();
    final l  = context.watch<L10n>();
    final th = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(l.t('settings'))),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          _S(l.t('appearance'), th),
          _T(title: l.t('dark_mode'), subtitle: s.darkMode ? 'Attiva' : 'Disattiva',
              trailing: Switch(value: s.darkMode, onChanged: s.setDarkMode)),

          _S(l.t('main_color'), th),
          const SizedBox(height: 6),
          _Pal(colors: SettingsProvider.accentColors, sel: s.accentColor, onSel: s.setAccentColor),

          _S(l.t('gradient_bg'), th),
          _T(title: l.t('use_gradient'), subtitle: s.useGradient ? 'Attivo' : 'Disattivo',
              trailing: Switch(value: s.useGradient, onChanged: s.setUseGradient)),
          if (s.useGradient) ...[
            const SizedBox(height: 6),
            Text('Colore 1', style: th.textTheme.bodyMedium?.copyWith(fontSize: 12)),
            const SizedBox(height: 6),
            _Pal(colors: SettingsProvider.gradientPalette, sel: s.gradientColor1,
                onSel: s.setGradientColor1, size: 32, bright: s.gradientBrightness),
            const SizedBox(height: 10),
            Text('Colore 2', style: th.textTheme.bodyMedium?.copyWith(fontSize: 12)),
            const SizedBox(height: 6),
            _Pal(colors: SettingsProvider.gradientPalette, sel: s.gradientColor2,
                onSel: s.setGradientColor2, size: 32, bright: s.gradientBrightness),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: Text('${l.t('brightness')}  ${(s.gradientBrightness * 100).round()}%',
                  style: th.textTheme.bodyMedium?.copyWith(fontSize: 12))),
              Expanded(flex: 2, child: Slider(value: s.gradientBrightness, min: 0.3, max: 1.8,
                  divisions: 15, onChanged: s.setGradientBrightness)),
            ]),
          ],

          _S(l.t('font'), th),
          _T(title: 'Famiglia font', subtitle: s.fontFamily,
              onTap: () => _pick(context, 'Font', _fontNames, s.fontFamily,
                  (v) { s.setFontFamily(v); })),

          _S(l.t('language'), th),
          _T(title: 'Lingua / Language', subtitle: _langNames[l.lang] ?? l.lang,
              onTap: () => _pick(context, 'Lingua', _langNames.keys.toList(), l.lang,
                  (v) => l.setLang(v), display: (k) => _langNames[k] ?? k)),

          _S(l.t('timer_mode'), th),
          _T(title: l.t('manual_input'), subtitle: s.manualInput ? 'Digitazione' : 'Timer a schermo',
              trailing: Switch(value: s.manualInput, onChanged: s.setManualInput)),
          _T(title: 'Modalità display timer', subtitle: _displayModeName(s.timerDisplay),
              onTap: () => _pickEnum(context, 'Modalità display', s.timerDisplay, (v) => s.setTimerDisplay(v))),
          _T(title: 'Preview scramble (3x3)', trailing: Switch(value: s.showScramblePreview, onChanged: s.setShowScramblePreview)),

          _S('TIMER', th),
          _T(title: l.t('inspection_wca'), trailing: Switch(value: s.inspectionEnabled, onChanged: s.setInspectionEnabled)),
          if (s.inspectionEnabled) ...[
            _T(title: l.t('sound'), subtitle: 'Vibrazione a 8s e 12s',
                trailing: Switch(value: s.soundEnabled, onChanged: s.setSoundEnabled)),
            _T(title: l.t('inspection_dur'), subtitle: '${s.inspectionDuration}s',
                onTap: () => _slider(context, l.t('inspection_dur'), s.inspectionDuration.toDouble(),
                    5, 30, 25, (v) => s.setInspectionDuration(v.round()), 's')),
          ],
          _T(title: l.t('hold_duration'), subtitle: '${s.holdDuration}ms',
              onTap: () => _slider(context, l.t('hold_duration'), s.holdDuration.toDouble(),
                  200, 1000, 16, (v) => s.setHoldDuration(v.round()), 'ms')),

          _S(l.t('feedback'), th),
          _T(title: l.t('vibration'), trailing: Switch(value: s.vibrationEnabled, onChanged: s.setVibrationEnabled)),

          _S('EVENTI PERSONALIZZATI', th),
          ..._customList(context, se, th),
          _T(title: l.t('add_event'), trailing: const Icon(Icons.add, size: 18),
              onTap: () => _eventDlg(context, se)),

          _S('SESSIONE', th),
          _T(title: l.t('reset_session'), subtitle: 'Solo la sessione attiva',
              onTap: () => _resetDlg(context, se), isDestructive: true),

          const SizedBox(height: 32),
          Center(child: Text('SpeedCube Timer v1.0',
              style: th.textTheme.bodyMedium?.copyWith(fontSize: 11))),
        ]),
      ),
    );
  }

  String _displayModeName(TimerDisplayMode m) {
    switch (m) {
      case TimerDisplayMode.hidden:           return 'Nascosto';
      case TimerDisplayMode.full:             return 'Completo';
      case TimerDisplayMode.withDecimals:     return 'Con decimi';
      case TimerDisplayMode.withoutDecimals:  return 'Senza decimi';
    }
  }

  void _pickEnum(BuildContext ctx, String title, TimerDisplayMode cur, ValueChanged<TimerDisplayMode> onSel) {
    final opts = TimerDisplayMode.values;
    showDialog(context: ctx, builder: (c) => AlertDialog(
      title: Text(title),
      content: Column(mainAxisSize: MainAxisSize.min, children: opts.map((m) => ListTile(
        title: Text(_displayModeName(m)),
        trailing: m == cur ? const Icon(Icons.check, color: Color(0xFF30D158)) : null,
        onTap: () { onSel(m); Navigator.pop(c); },
      )).toList())));
  }

  List<Widget> _customList(BuildContext ctx, SessionProvider se, ThemeData th) =>
    se.allEvents.where((e) => e.isCustom).map((e) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: GlassButton(borderRadius: 16, padding: EdgeInsets.zero,
        onTap: () => _eventDlg(ctx, se, existing: e),
        child: ListTile(
          leading: Text(e.emoji, style: const TextStyle(fontSize: 20)),
          title: Text(e.name, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600)),
          trailing: IconButton(icon: Icon(Icons.delete_outline, color: th.colorScheme.error, size: 18),
              onPressed: () => se.removeCustomEvent(e.id)),
        )))).toList();

  void _slider(BuildContext ctx, String title, double init, double mn, double mx,
      int div, ValueChanged<double> cb, String suffix) {
    double v = init;
    showDialog(context: ctx, builder: (c) => StatefulBuilder(builder: (c, ss) => AlertDialog(
      title: Text(title),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('${v.round()}$suffix', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w200)),
        Slider(value: v, min: mn, max: mx, divisions: div, onChanged: (x) => ss(() => v = x)),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Annulla')),
        TextButton(onPressed: () { cb(v); Navigator.pop(c); }, child: const Text('Salva')),
      ])));
  }

  void _pick(BuildContext ctx, String title, List<String> opts, String cur,
      ValueChanged<String> onSel, {String Function(String)? display}) {
    showDialog(context: ctx, builder: (c) => AlertDialog(
      title: Text(title),
      content: SizedBox(width: 300, height: 400, child: ListView(children: opts.map((o) =>
        ListTile(
          title: Text(display != null ? display(o) : o),
          trailing: o == cur ? const Icon(Icons.check, color: Color(0xFF30D158)) : null,
          onTap: () { onSel(o); Navigator.pop(c); },
        )).toList()))));
  }

  void _eventDlg(BuildContext ctx, SessionProvider se, {dynamic existing}) {
    final isEdit = existing != null;
    final ctrl = TextEditingController(text: isEdit ? existing.name : '');
    String emoji = isEdit ? existing.emoji : '🎲';
    const emojis = ['🎲','⭐','🔴','🟡','🔵','🟢','⚡','🌀','💎','🏆','🎯','🔥'];
    showDialog(context: ctx, builder: (c) => StatefulBuilder(builder: (c, ss) => AlertDialog(
      title: Text(isEdit ? 'Modifica evento' : 'Nuovo evento'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Wrap(spacing: 8, children: emojis.map((e) => GestureDetector(
          onTap: () => ss(() => emoji = e),
          child: Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: emoji == e ? Theme.of(ctx).colorScheme.primary.withValues(alpha: 0.15) : null,
              borderRadius: BorderRadius.circular(10)),
            child: Text(e, style: const TextStyle(fontSize: 22))),
        )).toList()),
        const SizedBox(height: 12),
        TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Nome evento'), autofocus: true),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Annulla')),
        TextButton(onPressed: () {
          if (ctrl.text.isEmpty) return;
          if (isEdit) se.editCustomEvent(existing.id, ctrl.text, emoji);
          else se.addCustomEvent(ctrl.text, emoji);
          Navigator.pop(c);
        }, child: Text(isEdit ? 'Salva' : 'Aggiungi')),
      ])));
  }

  void _resetDlg(BuildContext ctx, SessionProvider se) {
    showDialog(context: ctx, builder: (c) => AlertDialog(
      title: const Text('Reset sessione'),
      content: const Text('Elimina i tempi della sessione corrente?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Annulla')),
        TextButton(onPressed: () { se.resetCurrentSession(); Navigator.pop(c); },
            style: TextButton.styleFrom(foregroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Reset')),
      ]));
  }
}

class _S extends StatelessWidget {
  final String t; final ThemeData th;
  const _S(this.t, this.th);
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 8),
    child: Text(t, style: th.textTheme.labelSmall?.copyWith(letterSpacing: 2, fontSize: 11)));
}

class _T extends StatelessWidget {
  final String title; final String? subtitle; final Widget? trailing;
  final VoidCallback? onTap; final bool isDestructive;
  const _T({required this.title, this.subtitle, this.trailing, this.onTap, this.isDestructive=false});
  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    return Padding(padding: const EdgeInsets.only(bottom: 4),
      child: GlassButton(borderRadius: 16, padding: EdgeInsets.zero, onTap: onTap,
        child: ListTile(
          title: Text(title, style: TextStyle(fontWeight: FontWeight.w600,
              color: isDestructive ? th.colorScheme.error : th.colorScheme.onSurface)),
          subtitle: subtitle != null ? Text(subtitle!, style: th.textTheme.bodyMedium?.copyWith(fontSize: 12)) : null,
          trailing: trailing ?? (onTap != null
              ? Icon(Icons.chevron_right, color: th.colorScheme.onSurface.withValues(alpha: 0.3), size: 20) : null),
        )));
  }
}

class _Pal extends StatelessWidget {
  final List<Color> colors; final Color sel; final ValueChanged<Color> onSel;
  final double size; final double bright;
  const _Pal({required this.colors, required this.sel, required this.onSel, this.size=40, this.bright=1.0});

  Color _applyB(Color c) {
    final h = HSLColor.fromColor(c);
    return h.withLightness((h.lightness * bright).clamp(0.0, 0.85)).toColor();
  }

  @override
  Widget build(BuildContext context) => Wrap(spacing: 10, runSpacing: 10,
    children: colors.map((c) {
      final disp = _applyB(c);
      final isSel = sel.toARGB32() == c.toARGB32();
      return GestureDetector(onTap: () => onSel(c),
        child: AnimatedContainer(duration: const Duration(milliseconds: 180),
          width: size, height: size,
          decoration: BoxDecoration(color: disp, shape: BoxShape.circle,
            border: Border.all(color: isSel ? _cc(disp) : Colors.transparent, width: 2.5),
            boxShadow: isSel ? [BoxShadow(color: disp.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 1)] : []),
          child: isSel ? Icon(Icons.check, size: size*0.45, color: _cc(disp)) : null));
    }).toList());
}
