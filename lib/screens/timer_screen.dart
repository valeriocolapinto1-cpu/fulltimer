import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/timer_provider.dart';
import '../providers/session_provider.dart';
import '../providers/settings_provider.dart';
import '../models/solve_time.dart';
import '../widgets/timer_display.dart';
import '../widgets/stats_card.dart';
import '../widgets/glass_button.dart';
import '../widgets/scramble_preview.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});
  @override State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) => _setup()); }

  void _setup() {
    final timer = context.read<TimerProvider>();
    final s = context.read<SettingsProvider>();
    timer.configure(inspectionEnabled: s.inspectionEnabled, holdDurationMs: s.holdDuration,
        inspectionDuration: s.inspectionDuration, soundEnabled: s.soundEnabled);
    timer.onTimerStop = (ms) {
      final se = context.read<SessionProvider>();
      if (ms > 0) { se.addSolve(ms); if (mounted) _snack(ms); }
      else if (ms == -2) { final sv = se.addSolve(0); se.updateSolveResult(sv.id, SolveResult.dnf); }
    };
  }

  void _snack(int ms) {
    final se = context.read<SessionProvider>(); final th = Theme.of(context);
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating, margin: const EdgeInsets.fromLTRB(16,0,16,90),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: th.cardColor, duration: const Duration(seconds: 4),
      content: Row(children: [
        Text(SolveTime.format(ms), style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w700, color: th.colorScheme.onSurface)),
        const Spacer(),
        GlassButton(borderRadius: 10, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          onTap: () { final sv=se.currentSolves; if(sv.isNotEmpty) se.updateSolveResult(sv.last.id, SolveResult.plusTwo); ScaffoldMessenger.of(context).hideCurrentSnackBar(); },
          child: Text('+2', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: th.colorScheme.onSurface))),
        const SizedBox(width: 8),
        GlassButton(borderRadius: 10, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          onTap: () { final sv=se.currentSolves; if(sv.isNotEmpty) se.updateSolveResult(sv.last.id, SolveResult.dnf); ScaffoldMessenger.of(context).hideCurrentSnackBar(); },
          child: Text('DNF', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: th.colorScheme.error))),
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    final se = context.watch<SessionProvider>();
    if (s.manualInput) return _ManualInput(session: se, accent: s.accentColor);
    final timer = context.watch<TimerProvider>();
    final th = Theme.of(context); final accent = s.accentColor;
    final isActive = timer.state == TimerState.running || timer.state == TimerState.holding ||
        timer.state == TimerState.ready || timer.state == TimerState.inspection ||
        timer.state == TimerState.holdingFromInspection || timer.state == TimerState.readyFromInspection;

    return Scaffold(backgroundColor: Colors.transparent,
      body: SafeArea(child: Column(children: [
        AnimatedOpacity(opacity: isActive ? 0 : 1, duration: const Duration(milliseconds: 200),
          child: IgnorePointer(ignoring: isActive, child: Column(children: [
            const SizedBox(height: 8),
            EventSelector(events: se.allEvents, activeEventId: se.activeEventId,
                onEventSelected: (id) { se.switchEvent(id); context.read<TimerProvider>().reset(); }, accentColor: accent),
            const SizedBox(height: 4),
            _ScrambleBar(scramble: se.currentScramble, onRefresh: se.newScramble, accentColor: accent,
                eventId: se.activeEventId, showPreview: s.showScramblePreview),
          ]))),
        const Spacer(),
        Listener(
          onPointerDown: (_) {
            context.read<TimerProvider>().configure(inspectionEnabled: s.inspectionEnabled,
                holdDurationMs: s.holdDuration, inspectionDuration: s.inspectionDuration, soundEnabled: s.soundEnabled);
            context.read<TimerProvider>().onPointerDown();
          },
          onPointerUp: (_) => context.read<TimerProvider>().onPointerUp(),
          behavior: HitTestBehavior.opaque,
          child: SizedBox(width: double.infinity, height: 260, child: Center(
            child: TimerDisplay(state: timer.state, elapsedMs: timer.elapsedMs, inspectionSecondsLeft: timer.inspectionSecondsLeft, isInspectionWarning: timer.isInspectionWarning, accentColor: accent, displayMode: s.timerDisplay))),
        ),
        const Spacer(),
        AnimatedOpacity(opacity: isActive ? 0 : 1, duration: const Duration(milliseconds: 200),
          child: IgnorePointer(ignoring: isActive, child: Column(children: [
            _SessionSel(session: se, accent: accent, theme: th),
            const SizedBox(height: 8),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
              Expanded(child: StatsCard(label: 'MIGLIORE', valueMs: se.bestTime, highlight: true, accentColor: accent)),
              const SizedBox(width: 8),
              Expanded(child: StatsCard(label: 'AO5',  valueMs: se.ao5,  accentColor: accent)),
              const SizedBox(width: 8),
              Expanded(child: StatsCard(label: 'AO12', valueMs: se.ao12, accentColor: accent)),
            ])),
            const SizedBox(height: 16),
          ]))),
      ])),
    );
  }
}

// ── Inserimento manuale: formato h;mm;ss;ms a schermo ─────────

class _ManualInput extends StatefulWidget {
  final SessionProvider session; final Color accent;
  const _ManualInput({required this.session, required this.accent});
  @override State<_ManualInput> createState() => _ManualInputState();
}

class _ManualInputState extends State<_ManualInput> {
  // Buffer: [h, mm, ss, ms] come stringhe parziali
  // Inserimento digit per digit dal fondo
  final List<int> _digits = []; // max 7 cifre: h mm ss ms(2)

  void _push(int d) { if (_digits.length >= 7) return; setState(() => _digits.add(d)); }
  void _pop() { if (_digits.isEmpty) return; setState(() => _digits.removeLast()); }
  void _clear() => setState(() => _digits.clear());

  // Compone il tempo: digits riempiono da destra: cs cs ss ss mm mm h
  String get _display {
    final d = List.filled(7, 0)..setAll(7 - _digits.length, _digits);
    final h = d[0]; final m = d[1]*10+d[2]; final s = d[3]*10+d[4]; final cs = d[5]*10+d[6];
    if (h > 0) return '${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}.${cs.toString().padLeft(2,'0')}';
    if (m > 0) return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}.${cs.toString().padLeft(2,'0')}';
    return '$s.${cs.toString().padLeft(2,'0')}';
  }

  int get _ms {
    final d = List.filled(7, 0)..setAll(7 - _digits.length, _digits);
    final h=d[0]; final m=d[1]*10+d[2]; final s=d[3]*10+d[4]; final cs=d[5]*10+d[6];
    return ((h*3600 + m*60 + s) * 1000) + cs*10;
  }

  void _save() {
    final ms = _ms; if (ms == 0) return;
    widget.session.addSolve(ms); HapticFeedback.mediumImpact(); _clear();
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final onSurf = th.colorScheme.onSurface;
    return Scaffold(backgroundColor: Colors.transparent,
      body: SafeArea(child: Column(children: [
        const SizedBox(height: 8),
        EventSelector(events: widget.session.allEvents, activeEventId: widget.session.activeEventId,
            onEventSelected: widget.session.switchEvent, accentColor: widget.accent),
        const SizedBox(height: 4),
        _ScrambleBar(scramble: widget.session.currentScramble, onRefresh: widget.session.newScramble, accentColor: widget.accent),
        const Spacer(),
        // Display tempo nel formato h;mm;ss;ms
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(color: th.cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: th.dividerColor)),
          child: Column(children: [
            Text('hh:mm:ss.ms', style: th.textTheme.labelSmall?.copyWith(letterSpacing: 2)),
            const SizedBox(height: 8),
            Text(_digits.isEmpty ? '0 ; 00' : _display,
                style: GoogleFonts.nunito(fontSize: 52, fontWeight: FontWeight.w200,
                    color: _digits.isEmpty ? onSurf.withValues(alpha:0.3) : onSurf, letterSpacing: -1)),
          ]),
        ),
        const SizedBox(height: 24),
        // Tastierino
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(children: [
          _row(['7','8','9'], th, onSurf),
          const SizedBox(height: 10),
          _row(['4','5','6'], th, onSurf),
          const SizedBox(height: 10),
          _row(['1','2','3'], th, onSurf),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _numBtn('0', th, onSurf),
            _numBtn('00', th, onSurf),
            GlassButton(borderRadius: 16, padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              onTap: _pop,
              child: Icon(Icons.backspace_outlined, color: onSurf, size: 22)),
          ]),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            GlassButton(borderRadius: 16, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              onTap: _clear,
              child: Text('C', style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w600, color: th.colorScheme.error))),
            GlassButton(borderRadius: 16, padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
              onTap: _save,
              child: Text('Salva', style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w700, color: widget.accent))),
          ]),
        ])),
        const Spacer(),
      ])),
    );
  }

  Widget _row(List<String> ds, ThemeData th, Color onSurf) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: ds.map((d) => _numBtn(d, th, onSurf)).toList());

  Widget _numBtn(String d, ThemeData th, Color onSurf) => GlassButton(
    borderRadius: 16, padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
    onTap: () { if (d == '00') { _push(0); if (_digits.length < 7) _push(0); } else if (d != '.') _push(int.parse(d)); },
    child: Text(d, style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w600, color: onSurf)));
}

// ── Scramble bar ──────────────────────────────────────────────
class _ScrambleBar extends StatelessWidget {
  final String scramble; final VoidCallback onRefresh; final Color accentColor;
  final String eventId; final bool showPreview;
  const _ScrambleBar({required this.scramble, required this.onRefresh, required this.accentColor,
      this.eventId = '3x3', this.showPreview = false});
  @override
  Widget build(BuildContext ctx) {
    final th = Theme.of(ctx);
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(children: [
        Row(children: [
          Expanded(child: Text(scramble, textAlign: TextAlign.center,
              style: th.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace', fontSize: 12, letterSpacing: 0.3))),
          GestureDetector(onTap: onRefresh, child: Icon(Icons.refresh_rounded, color: accentColor, size: 20)),
        ]),
        if (showPreview && (eventId == '3x3' || eventId == 'oh')) ...[
          const SizedBox(height: 8),
          Center(child: ScramblePreview(scramble: scramble, eventId: eventId, size: 120)),
        ],
      ]));
  }
}

// ── Session selector ──────────────────────────────────────────
class _SessionSel extends StatelessWidget {
  final SessionProvider session; final Color accent; final ThemeData theme;
  const _SessionSel({required this.session, required this.accent, required this.theme});

  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(children: [
      GlassButton(borderRadius: 12, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        onTap: () => _menu(context),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.layers_outlined, size: 14, color: accent),
          const SizedBox(width: 6),
          Text(session.activeSession?.name ?? 'Sessione',
              style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600, fontSize: 13, color: theme.colorScheme.onSurface)),
          Icon(Icons.expand_more, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
        ])),
      const SizedBox(width: 8),
      GlassButton(borderRadius: 12, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        onTap: () => _newDlg(context),
        child: Icon(Icons.add, size: 16, color: accent)),
    ]));

  void _menu(BuildContext ctx) {
    showModalBottomSheet(context: ctx, backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (c) => Padding(padding: const EdgeInsets.all(16), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Sessioni — ${session.activeEvent.name}', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        ...session.sessionsForActiveEvent.map((s) {
          final isA = s.id == session.activeSession?.id;
          return ListTile(
            leading: Icon(Icons.layers, color: isA ? accent : null),
            title: Text(s.name, style: TextStyle(fontFamily:'Nunito', fontWeight: isA ? FontWeight.w700 : FontWeight.w500)),
            subtitle: Text('${s.solves.length} solve', style: theme.textTheme.bodyMedium?.copyWith(fontSize:11)),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: const Icon(Icons.edit_outlined, size:18),
                  onPressed: () { Navigator.pop(c); _renameDlg(ctx, s.id, s.name); }),
              if (session.sessionsForActiveEvent.length > 1)
                IconButton(icon: Icon(Icons.delete_outline, size:18, color: theme.colorScheme.error),
                    onPressed: () { session.deleteSession(s.id); Navigator.pop(c); }),
            ]),
            onTap: () { session.switchSession(s.id); Navigator.pop(c); },
          );
        }),
      ])));
  }

  void _dlg(BuildContext ctx, String title, String hint, String initial, void Function(String) onSave) {
    final ctrl = TextEditingController(text: initial);
    showDialog(context: ctx, builder: (c) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom),
      child: AlertDialog(title: Text(title),
        content: TextField(controller: ctrl, decoration: InputDecoration(hintText: hint), autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Annulla')),
          TextButton(onPressed: () { onSave(ctrl.text); Navigator.pop(c); }, child: const Text('Salva')),
        ])));
  }

  void _newDlg(BuildContext ctx) => _dlg(ctx, 'Nuova sessione', 'Nome...', '', (name) => session.newSession(name: name.isEmpty ? null : name));
  void _renameDlg(BuildContext ctx, String id, String cur) => _dlg(ctx, 'Rinomina', cur, cur, (name) => session.renameSession(id, name));
}
