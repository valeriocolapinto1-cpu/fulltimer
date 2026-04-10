import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/solve_time.dart';
import '../providers/session_provider.dart';
import '../services/firebase_service.dart';
import '../services/scramble_service.dart';
import '../widgets/spinning_cube.dart';
import '../widgets/glass_button.dart';

enum _CompState { idle, holding, ready, running, stopped }

class OnlineCompetitionScreen extends StatefulWidget {
  const OnlineCompetitionScreen({super.key});
  @override State<OnlineCompetitionScreen> createState() => _OCState();
}

class _OCState extends State<OnlineCompetitionScreen> {
  final _fb = FirebaseService();
  String _eventId = '3x3';
  List<String> _scrambles = [];
  List<int?> _times = [null, null, null, null, null]; // ao5
  int _currentSolve = 0;
  bool _submitted = false;
  bool _loading = true;

  // Timer
  _CompState _timerState = _CompState.idle;
  int _elapsedMs = 0;
  Timer? _timer, _holdTimer;
  DateTime _startTime = DateTime.now();

  // Leaderboard
  List<Map<String, dynamic>> _leaderboard = [];

  @override
  void initState() { super.initState(); _loadCompetition(); }

  @override
  void dispose() { _timer?.cancel(); _holdTimer?.cancel(); super.dispose(); }

  Future<void> _loadCompetition() async {
    setState(() => _loading = true);
    // Generate 5 scrambles (ideally from server for fairness)
    _scrambles = List.generate(5, (_) => ScrambleService.generateFor(_eventId));
    _times = [null, null, null, null, null];
    _currentSolve = 0;
    _submitted = false;
    final lb = await _fb.getDailyLeaderboard(_eventId);
    setState(() { _leaderboard = lb; _loading = false; });
  }

  // Timer controls
  void _onDown() {
    if (_timerState == _CompState.running) { _stop(); return; }
    if (_timerState == _CompState.stopped) { setState(() { _timerState = _CompState.idle; }); return; }
    if (_timerState != _CompState.idle) return;
    setState(() => _timerState = _CompState.holding);
    _holdTimer = Timer(const Duration(milliseconds: 550), () {
      if (_timerState == _CompState.holding) setState(() => _timerState = _CompState.ready);
    });
  }

  void _onUp() {
    if (_timerState == _CompState.holding) { _holdTimer?.cancel(); setState(() => _timerState = _CompState.idle); return; }
    if (_timerState == _CompState.ready) { _start(); }
  }

  void _start() {
    _startTime = DateTime.now();
    setState(() => _timerState = _CompState.running);
    HapticFeedback.lightImpact();
    _timer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      setState(() => _elapsedMs = DateTime.now().difference(_startTime).inMilliseconds);
    });
  }

  void _stop() {
    _timer?.cancel();
    final ms = DateTime.now().difference(_startTime).inMilliseconds;
    setState(() {
      _elapsedMs = ms;
      _timerState = _CompState.stopped;
      if (_currentSolve < 5) {
        _times[_currentSolve] = ms;
        _currentSolve++;
      }
    });
    HapticFeedback.mediumImpact();
  }

  int? get _ao5 {
    final valid = _times.whereType<int>().toList();
    if (valid.length < 5) return null;
    valid.sort();
    return (valid.sublist(1, 4).reduce((a,b)=>a+b) / 3).round();
  }

  Color _timerColor(ThemeData th) {
    if (_timerState == _CompState.ready) return const Color(0xFF30D158);
    if (_timerState == _CompState.holding) return th.colorScheme.onSurface.withValues(alpha: 0.35);
    return th.colorScheme.onSurface;
  }

  Future<void> _submit() async {
    final ao5 = _ao5;
    if (ao5 == null) return;
    final profile = context.read<SessionProvider>().activeSession?.name ?? 'Anonimo';
    await _fb.submitCompetitionResult(
      eventId: _eventId, times: _times.whereType<int>().toList(),
      ao5: ao5, displayName: profile,
    );
    final lb = await _fb.getDailyLeaderboard(_eventId);
    setState(() { _submitted = true; _leaderboard = lb; });
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final accent = th.colorScheme.primary;
    final onSurf = th.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('🏆 Online Competition'),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(50),
          child: _EventBar(selected: _eventId, onSelect: (e) {
            setState(() => _eventId = e); _loadCompetition();
          }))),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [

          // ── Scramble ─────────────────────────────────────
          if (_currentSolve < 5)
            Container(margin: const EdgeInsets.all(12), padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: th.cardColor, borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: th.dividerColor)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text('Solve ${_currentSolve+1}/5', style: TextStyle(fontWeight: FontWeight.w700, color: accent)),
                  const Spacer(),
                  Text('ao5 attuale: ${_ao5 != null ? SolveTime.format(_ao5!) : "-"}',
                      style: th.textTheme.bodyMedium?.copyWith(fontSize: 12)),
                ]),
                const SizedBox(height: 6),
                Text(_scrambles[_currentSolve],
                    style: th.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace', fontSize: 12)),
              ])),

          // ── Timer ─────────────────────────────────────────
          Expanded(child: Listener(
            onPointerDown: (_) => _onDown(),
            onPointerUp: (_) => _onUp(),
            behavior: HitTestBehavior.opaque,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (_timerState == _CompState.idle && _currentSolve < 5)
                Text('Tieni premuto per iniziare', style: th.textTheme.bodyMedium),
              Text(
                _currentSolve >= 5 ? 'Completato!' :
                _elapsedMs == 0 && _timerState == _CompState.idle ? '0.00' :
                SolveTime.format(_elapsedMs),
                style: GoogleFonts.nunito(fontSize: 80, fontWeight: FontWeight.w200,
                    color: _timerColor(th), letterSpacing: -2),
              ),
              if (_timerState == _CompState.holding) Text('Continua...', style: th.textTheme.bodyMedium),
              if (_timerState == _CompState.ready)
                Text('Rilascia!', style: th.textTheme.bodyMedium?.copyWith(color: const Color(0xFF30D158))),
            ]))),

          // ── Times ─────────────────────────────────────────
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (i) => _SolveChip(
                index: i+1, ms: _times[i], isActive: i == _currentSolve, accent: accent, theme: th)))),

          // ── Submit ────────────────────────────────────────
          if (_ao5 != null && !_submitted)
            Padding(padding: const EdgeInsets.all(12),
              child: GlassButton(borderRadius: 16, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                onTap: _submit,
                child: Text('Invia risultato (${SolveTime.format(_ao5!)})',
                    style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: accent)))),

          if (_submitted)
            Padding(padding: const EdgeInsets.all(8),
              child: Text('✓ Risultato inviato!', style: TextStyle(color: const Color(0xFF30D158), fontWeight: FontWeight.w700))),

          // ── Leaderboard ───────────────────────────────────
          if (_leaderboard.isNotEmpty)
            Expanded(child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12,0,12,80),
              itemCount: _leaderboard.length,
              itemBuilder: (_, i) {
                final r = _leaderboard[i];
                return ListTile(
                  leading: CircleAvatar(radius: 14, backgroundColor: i==0?Colors.amber:i==1?Colors.grey:i==2?const Color(0xFFCD7F32):th.dividerColor,
                      child: Text('${i+1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                          color: i<3?Colors.white:onSurf))),
                  title: Text(r['displayName']??'?', style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: Text(SolveTime.format(r['ao5']??0), style: TextStyle(fontFamily:'monospace', color: accent, fontWeight: FontWeight.w700)),
                );
              })),

          const SizedBox(height: 16),
        ]),
    );
  }
}

class _SolveChip extends StatelessWidget {
  final int index; final int? ms; final bool isActive; final Color accent; final ThemeData theme;
  const _SolveChip({required this.index, required this.ms, required this.isActive, required this.accent, required this.theme});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: isActive ? accent.withValues(alpha: 0.15) : theme.cardColor,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: isActive ? accent : theme.dividerColor, width: isActive ? 1.5 : 1)),
    child: Column(children: [
      Text('S$index', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
      Text(ms != null ? SolveTime.format(ms!) : '-',
          style: TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.w700,
              color: isActive ? accent : theme.colorScheme.onSurface)),
    ]));
}

class _EventBar extends StatelessWidget {
  final String selected; final ValueChanged<String> onSelect;
  const _EventBar({required this.selected, required this.onSelect});

  static const _events = ['3x3','2x2','4x4','5x5','oh','pyra','skewb','mega','clock','sq1'];

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    return SizedBox(height: 50, child: ListView.separated(
      scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: _events.length, separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final e = _events[i]; final isActive = e == selected;
        return GestureDetector(
          onTap: () => onSelect(e),
          child: Chip(
            avatar: SizedBox(width: 18, height: 18, child: eventCube(e, size: 18)),
            label: Text(e, style: TextStyle(fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? th.colorScheme.primary : th.colorScheme.onSurface, fontSize: 12)),
            backgroundColor: isActive ? th.colorScheme.primary.withValues(alpha: 0.12) : th.cardColor,
            side: BorderSide(color: isActive ? th.colorScheme.primary : th.dividerColor),
          ));
      }));
  }
}
