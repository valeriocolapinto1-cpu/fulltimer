import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/session_provider.dart';
import '../models/solve_time.dart';
import '../widgets/stats_card.dart';
import '../widgets/glass_button.dart';

enum _S { idle, holding, ready, running, stopped }

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});
  @override State<BattleScreen> createState() => _BattleState();
}

class _BattleState extends State<BattleScreen> {
  _S _sT = _S.idle, _sB = _S.idle;
  int _msT = 0, _msB = 0;
  Timer? _tT, _tB, _hT, _hB;
  DateTime _stT = DateTime.now(), _stB = DateTime.now();
  String _scrT = '', _scrB = '';
  static const _hold = 550;
  final List<(int, int)> _history = [];
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _newScrambles());
  }

  @override
  void dispose() { _tT?.cancel(); _tB?.cancel(); _hT?.cancel(); _hB?.cancel(); super.dispose(); }

  void _newScrambles() {
    final se = context.read<SessionProvider>();
    se.newScramble(); final s1 = se.currentScramble;
    se.newScramble(); final s2 = se.currentScramble;
    setState(() { _scrT=s1; _scrB=s2; _sT=_S.idle; _sB=_S.idle; _msT=0; _msB=0; });
  }

  void _saveBattle() {
    if (_sT==_S.stopped && _sB==_S.stopped) {
      setState(() => _history.add((_msT, _msB)));
    }
  }

  // ── TOP player ────────────────────────────────────────────
  void _dT() {
    if (_sT==_S.running) {
      _tT?.cancel();
      final ms=DateTime.now().difference(_stT).inMilliseconds;
      setState(()=>_sT=_S.stopped); _msT=ms;
      HapticFeedback.mediumImpact(); _saveBattle(); return;
    }
    if (_sT==_S.stopped) { setState((){_msT=0;_sT=_S.idle;}); return; }
    if (_sT!=_S.idle) return;
    setState(()=>_sT=_S.holding);
    _hT=Timer(const Duration(milliseconds:_hold), (){
      if (_sT==_S.holding) setState(()=>_sT=_S.ready);
    });
  }
  void _uT() {
    if (_sT==_S.holding) { _hT?.cancel(); setState(()=>_sT=_S.idle); return; }
    if (_sT==_S.ready) {
      _stT=DateTime.now(); setState(()=>_sT=_S.running); HapticFeedback.lightImpact();
      _tT=Timer.periodic(const Duration(milliseconds:10), (_)=>setState(()=>_msT=DateTime.now().difference(_stT).inMilliseconds));
    }
  }

  // ── BOT player ────────────────────────────────────────────
  void _dB() {
    if (_sB==_S.running) {
      _tB?.cancel();
      final ms=DateTime.now().difference(_stB).inMilliseconds;
      setState(()=>_sB=_S.stopped); _msB=ms;
      HapticFeedback.mediumImpact(); _saveBattle(); return;
    }
    if (_sB==_S.stopped) { setState((){_msB=0;_sB=_S.idle;}); return; }
    if (_sB!=_S.idle) return;
    setState(()=>_sB=_S.holding);
    _hB=Timer(const Duration(milliseconds:_hold), (){
      if (_sB==_S.holding) setState(()=>_sB=_S.ready);
    });
  }
  void _uB() {
    if (_sB==_S.holding) { _hB?.cancel(); setState(()=>_sB=_S.idle); return; }
    if (_sB==_S.ready) {
      _stB=DateTime.now(); setState(()=>_sB=_S.running); HapticFeedback.lightImpact();
      _tB=Timer.periodic(const Duration(milliseconds:10), (_)=>setState(()=>_msB=DateTime.now().difference(_stB).inMilliseconds));
    }
  }

  Color _col(ThemeData th, _S s) {
    if (s==_S.ready)   return const Color(0xFF30D158);
    if (s==_S.holding) return th.colorScheme.onSurface.withValues(alpha:0.35);
    return th.colorScheme.onSurface;
  }

  bool get _both => _sT==_S.stopped && _sB==_S.stopped;
  String get _winner => _both ? (_msT<_msB?'TOP':_msT>_msB?'BOT':'PARI') : '';
  int get _winsTop => _history.where((h)=>h.$1<h.$2).length;
  int get _winsBot => _history.where((h)=>h.$2<h.$1).length;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final se = context.watch<SessionProvider>();
    final accent = th.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: SafeArea(child: Column(children: [

        // ── Event selector ──────────────────────────────────
        SizedBox(height: 52, child: EventSelector(
          events: se.allEvents, activeEventId: se.activeEventId,
          onEventSelected: (id) { se.switchEvent(id); _newScrambles(); },
          accentColor: accent)),

        // ── Player TOP (rotated 180°) ───────────────────────
        Expanded(child: RotatedBox(quarterTurns: 2,
          child: Listener(onPointerDown: (_)=>_dT(), onPointerUp: (_)=>_uT(),
            behavior: HitTestBehavior.opaque,
            child: _Panel(state:_sT, ms:_msT, label:'G1 ($_winsTop)',
                scramble:_scrT, color:_winner=='TOP'?const Color(0xFF30D158):_col(th,_sT),
                isWinner:_winner=='TOP', theme:th)))),

        // ── Center bar ──────────────────────────────────────
        Container(color: th.cardColor, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(children: [
            if (_both && _winner.isNotEmpty)
              Text(_winner=='PARI'?'🤝 Pareggio!':'🏆 Vince ${_winner=='TOP'?'G1':'G2'}',
                  style: GoogleFonts.nunito(fontWeight:FontWeight.w700, fontSize:13, color:const Color(0xFF30D158))),
            const Spacer(),
            if (_history.isNotEmpty)
              GlassButton(borderRadius:10, padding: const EdgeInsets.symmetric(horizontal:10,vertical:4),
                onTap: () => setState(()=>_showHistory=!_showHistory),
                child: Row(mainAxisSize:MainAxisSize.min, children: [
                  Icon(Icons.history, size:14, color:accent),
                  const SizedBox(width:4),
                  Text('${_history.length}', style:TextStyle(fontSize:12,color:accent,fontWeight:FontWeight.w700)),
                ])),
            const SizedBox(width:8),
            GestureDetector(onTap:_newScrambles, child:Icon(Icons.refresh_rounded, size:18, color:accent)),
          ])),

        // ── Session history panel ───────────────────────────
        if (_showHistory && _history.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 160),
            color: th.cardColor.withValues(alpha:0.95),
            child: Column(children: [
              Padding(padding: const EdgeInsets.fromLTRB(12,6,12,2),
                child: Row(children: [
                  Text('Sessione', style: th.textTheme.labelSmall?.copyWith(letterSpacing:1.5)),
                  const Spacer(),
                  Text('G1: $_winsTop  G2: $_winsBot', style:th.textTheme.bodyMedium?.copyWith(fontSize:12)),
                  const SizedBox(width:8),
                  GestureDetector(onTap:()=>setState((){_history.clear();}),
                    child:Icon(Icons.delete_outline,size:16,color:th.colorScheme.error)),
                ])),
              const Divider(height:1),
              Expanded(child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _history.length,
                itemBuilder: (_, i) {
                  final idx = _history.length - i - 1;
                  final h = _history[idx];
                  final tWon = h.$1 < h.$2;
                  final bWon = h.$2 < h.$1;
                  return Padding(padding: const EdgeInsets.symmetric(horizontal:12, vertical:2),
                    child: Row(children: [
                      Text('#${idx+1}', style:th.textTheme.bodyMedium?.copyWith(fontSize:11,
                          color:th.colorScheme.onSurface.withValues(alpha:0.4))),
                      const SizedBox(width:8),
                      Text(SolveTime.format(h.$1), style:TextStyle(fontFamily:'monospace',fontSize:13,
                          fontWeight: tWon?FontWeight.w700:FontWeight.w400,
                          color: tWon?const Color(0xFF30D158):th.colorScheme.onSurface)),
                      const Text(' vs ', style:TextStyle(fontSize:11,color:Colors.grey)),
                      Text(SolveTime.format(h.$2), style:TextStyle(fontFamily:'monospace',fontSize:13,
                          fontWeight: bWon?FontWeight.w700:FontWeight.w400,
                          color: bWon?const Color(0xFF30D158):th.colorScheme.onSurface)),
                      const Spacer(),
                      Text(tWon?'G1 🏆':bWon?'G2 🏆':'🤝',
                          style:const TextStyle(fontSize:11)),
                    ]));
                })),
            ])),

        // ── Player BOTTOM ────────────────────────────────────
        Expanded(child: Listener(onPointerDown: (_)=>_dB(), onPointerUp: (_)=>_uB(),
          behavior: HitTestBehavior.opaque,
          child: _Panel(state:_sB, ms:_msB, label:'G2 ($_winsBot)',
              scramble:_scrB, color:_winner=='BOT'?const Color(0xFF30D158):_col(th,_sB),
              isWinner:_winner=='BOT', theme:th))),
      ])),
    );
  }
}

class _Panel extends StatelessWidget {
  final _S state; final int ms; final String label, scramble;
  final Color color; final bool isWinner; final ThemeData theme;
  const _Panel({required this.state, required this.ms, required this.label,
      required this.scramble, required this.color, required this.isWinner, required this.theme});

  @override
  Widget build(BuildContext context) => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontSize:11)),
    const SizedBox(height:4),
    Padding(padding: const EdgeInsets.symmetric(horizontal:12),
      child: Text(scramble, textAlign:TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(fontFamily:'monospace', fontSize:9,
              color:theme.colorScheme.onSurface.withValues(alpha:0.7)))),
    const SizedBox(height:8),
    Text(ms==0&&state==_S.idle?'0.00':SolveTime.format(ms),
        style: GoogleFonts.nunito(fontSize:58, fontWeight:FontWeight.w200,
            color:color, letterSpacing:-2)),
    if (state==_S.holding) Text('Tieni premuto...', style:theme.textTheme.bodyMedium),
    if (state==_S.ready) Text('Rilascia!',
        style:theme.textTheme.bodyMedium?.copyWith(color:const Color(0xFF30D158))),
    if (state==_S.idle&&ms==0) Text('Premi per iniziare', style:theme.textTheme.bodyMedium),
    if (isWinner) const Text('🏆', style:TextStyle(fontSize:20)),
  ]);
}
