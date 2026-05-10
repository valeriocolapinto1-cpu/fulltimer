import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/solve_time.dart';
import '../providers/session_provider.dart';
import '../services/supabase_service.dart';
import '../services/scramble_service.dart';
import '../widgets/spinning_cube.dart';
import '../widgets/glass_button.dart';

enum _CS { idle, holding, ready, running, stopped }

class OnlineCompetitionScreen extends StatefulWidget {
  const OnlineCompetitionScreen({super.key});
  @override State<OnlineCompetitionScreen> createState() => _OCState();
}

class _OCState extends State<OnlineCompetitionScreen> {
  final _sb = SupabaseService();
  String _eventId = '3x3';
  List<String> _scrambles = [];
  List<int?> _times = [null,null,null,null,null];
  int _currentSolve = 0;
  bool _submitted = false;
  bool _loading = true;
  String _displayName = 'Anonimo';
  int? _userRank; // user's position in leaderboard

  _CS _state = _CS.idle;
  int _elapsedMs = 0;
  Timer? _timer, _holdTimer;
  DateTime _startTime = DateTime.now();

  List<Map<String,dynamic>> _leaderboard = [];

  @override
  void initState() { super.initState(); _init(); }

  @override
  void dispose() { _timer?.cancel(); _holdTimer?.cancel(); super.dispose(); }

  Future<void> _init() async {
    final se = context.read<SessionProvider>();
    _displayName = se.activeSession?.name ?? 'Anonimo';
    await _loadCompetition();
  }

  Future<void> _loadCompetition() async {
    setState(() { _loading = true; _submitted = false; _userRank = null; });

    // Generate 5 scrambles asynchronously via tnoodle or fallback
    final futures = List.generate(5, (_) => ScrambleService.generateFor(_eventId));
    final results = await Future.wait(futures);

    final lb = await _sb.getDailyLeaderboard(_eventId);
    if (!mounted) return;
    setState(() {
      _scrambles = results;
      _times = [null,null,null,null,null];
      _currentSolve = 0;
      _leaderboard = lb;
      _loading = false;
    });
  }

  // ── Timer logic ───────────────────────────────────────────

  void _onDown() {
    if (_state == _CS.running) { _stop(); return; }
    if (_state == _CS.stopped) { setState(() => _state = _CS.idle); return; }
    if (_state != _CS.idle) return;
    setState(() => _state = _CS.holding);
    _holdTimer = Timer(const Duration(milliseconds: 550), () {
      if (_state == _CS.holding) setState(() => _state = _CS.ready);
    });
  }

  void _onUp() {
    if (_state == _CS.holding) { _holdTimer?.cancel(); setState(() => _state = _CS.idle); return; }
    if (_state == _CS.ready) _start();
  }

  void _start() {
    _startTime = DateTime.now();
    setState(() { _state = _CS.running; });
    HapticFeedback.lightImpact();
    _timer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      setState(() => _elapsedMs = DateTime.now().difference(_startTime).inMilliseconds);
    });
  }

  void _stop() {
    _timer?.cancel();
    final ms = DateTime.now().difference(_startTime).inMilliseconds;
    setState(() {
      _elapsedMs = ms; _state = _CS.stopped;
      if (_currentSolve < 5) { _times[_currentSolve] = ms; _currentSolve++; }
    });
    HapticFeedback.mediumImpact();
  }

  int? get _ao5 {
    final valid = _times.whereType<int>().toList();
    if (valid.length < 5) return null;
    valid.sort();
    return (valid.sublist(1,4).reduce((a,b)=>a+b) / 3).round();
  }

  Color _timerColor(ThemeData th) {
    if (_state == _CS.ready)   return const Color(0xFF30D158);
    if (_state == _CS.holding) return th.colorScheme.onSurface.withValues(alpha:0.35);
    return th.colorScheme.onSurface;
  }

  // ── Submit result and show leaderboard with user position ──

  Future<void> _submit() async {
    final ao5 = _ao5;
    if (ao5 == null) return;
    setState(() => _loading = true);

    final ok = await _sb.submitCompetitionResult(
      eventId: _eventId,
      times: _times.whereType<int>().toList(),
      ao5: ao5,
      displayName: _displayName,
    );

    final lb = await _sb.getDailyLeaderboard(_eventId);

    // Find user rank
    int? rank;
    for (int i = 0; i < lb.length; i++) {
      if (lb[i]['display_name'] == _displayName) { rank = i + 1; break; }
    }

    if (!mounted) return;
    setState(() {
      _submitted = ok;
      _leaderboard = lb;
      _userRank = rank;
      _loading = false;
    });

    if (_submitted && rank != null) {
      _showLeaderboardSheet();
    }
  }

  void _showLeaderboardSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _LeaderboardSheet(
        leaderboard: _leaderboard,
        userDisplayName: _displayName,
        userRank: _userRank,
        eventId: _eventId,
        ao5: _ao5!,
      ));
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final accent = th.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('🏆 Online Competition'),
        actions: [
          if (_leaderboard.isNotEmpty)
            IconButton(icon: const Icon(Icons.leaderboard_outlined),
              tooltip: 'Classifica',
              onPressed: _showLeaderboardSheet),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: _EventBar(selected: _eventId, onSelect: (e) {
            setState(() => _eventId = e); _loadCompetition();
          })),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [

          // ── Scramble ────────────────────────────────────
          if (_currentSolve < 5)
            Container(margin:const EdgeInsets.all(12), padding:const EdgeInsets.all(14),
              decoration:BoxDecoration(color:th.cardColor, borderRadius:BorderRadius.circular(16),
                  border:Border.all(color:th.dividerColor)),
              child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
                Row(children:[
                  Text('Solve ${_currentSolve+1}/5',
                      style:TextStyle(fontWeight:FontWeight.w700, color:accent)),
                  const Spacer(),
                  Text('ao5: ${_ao5!=null?SolveTime.format(_ao5!):"-"}',
                      style:th.textTheme.bodyMedium?.copyWith(fontSize:12)),
                ]),
                const SizedBox(height:6),
                Text(_scrambles.isNotEmpty?_scrambles[_currentSolve]:'',
                    style:th.textTheme.bodyMedium?.copyWith(fontFamily:'monospace', fontSize:12)),
              ])),

          // ── Timer area ────────────────────────────────────
          Expanded(child: Listener(
            onPointerDown: (_) => _onDown(),
            onPointerUp: (_) => _onUp(),
            behavior: HitTestBehavior.opaque,
            child: Column(mainAxisAlignment:MainAxisAlignment.center, children:[
              if (_state==_CS.idle && _currentSolve<5)
                Text('Tieni premuto per iniziare', style:th.textTheme.bodyMedium),
              if (_currentSolve>=5)
                Text('Completato! ✓', style:TextStyle(color:const Color(0xFF30D158), fontSize:18, fontWeight:FontWeight.w700)),
              Text(
                _currentSolve>=5?SolveTime.format(_ao5??0)
                    : _elapsedMs==0 && _state==_CS.idle?'0.00'
                    : SolveTime.format(_elapsedMs),
                style:GoogleFonts.nunito(fontSize:80, fontWeight:FontWeight.w200,
                    color:_timerColor(th), letterSpacing:-2)),
              if (_state==_CS.holding) Text('Continua...', style:th.textTheme.bodyMedium),
              if (_state==_CS.ready)
                Text('Rilascia!', style:th.textTheme.bodyMedium?.copyWith(color:const Color(0xFF30D158))),
            ]))),

          // ── Solve chips ────────────────────────────────────
          Padding(padding:const EdgeInsets.symmetric(horizontal:12),
            child:Row(mainAxisAlignment:MainAxisAlignment.spaceEvenly,
              children:List.generate(5, (i) => _SolveChip(
                index:i+1, ms:_times[i], isActive:i==_currentSolve,
                accent:accent, theme:th)))),

          const SizedBox(height:12),

          // ── Submit button ─────────────────────────────────
          if (_ao5!=null && !_submitted)
            Padding(padding:const EdgeInsets.fromLTRB(12,0,12,16),
              child:GlassButton(borderRadius:16,
                padding:const EdgeInsets.symmetric(horizontal:40,vertical:14),
                onTap:_submit,
                child:Text('Invia risultato (${SolveTime.format(_ao5!)})',
                    style:GoogleFonts.nunito(fontSize:16,fontWeight:FontWeight.w700,color:accent)))),

          if (_submitted && _userRank!=null)
            Padding(padding:const EdgeInsets.fromLTRB(12,0,12,16),
              child:Row(mainAxisAlignment:MainAxisAlignment.center, children:[
                Icon(Icons.check_circle, color:const Color(0xFF30D158), size:18),
                const SizedBox(width:8),
                Text('Inviato! Sei #$_userRank in classifica',
                    style:TextStyle(color:const Color(0xFF30D158), fontWeight:FontWeight.w700)),
                const SizedBox(width:8),
                TextButton(onPressed:_showLeaderboardSheet,
                    child:const Text('Vedi classifica')),
              ])),
        ]),
    );
  }
}

// ── Full leaderboard bottom sheet ─────────────────────────────
class _LeaderboardSheet extends StatelessWidget {
  final List<Map<String,dynamic>> leaderboard;
  final String userDisplayName;
  final int? userRank;
  final String eventId;
  final int ao5;

  const _LeaderboardSheet({
    required this.leaderboard, required this.userDisplayName,
    required this.userRank, required this.eventId, required this.ao5,
  });

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final accent = th.colorScheme.primary;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, ctrl) => Column(children: [
        // Handle
        Padding(padding:const EdgeInsets.only(top:12,bottom:8),
          child:Container(width:40,height:4,decoration:BoxDecoration(
              color:th.dividerColor,borderRadius:BorderRadius.circular(2)))),

        // Header
        Padding(padding:const EdgeInsets.symmetric(horizontal:20,vertical:8),
          child:Row(children:[
            const Text('🏆 Classifica giornaliera', style:TextStyle(fontSize:18,fontWeight:FontWeight.w700)),
            const Spacer(),
            Text(eventId.toUpperCase(), style:TextStyle(color:accent,fontWeight:FontWeight.w700)),
          ])),

        // User's result highlight
        if (userRank!=null)
          Container(margin:const EdgeInsets.fromLTRB(16,0,16,8),
            padding:const EdgeInsets.all(12),
            decoration:BoxDecoration(
              color:accent.withValues(alpha:0.12),
              borderRadius:BorderRadius.circular(12),
              border:Border.all(color:accent.withValues(alpha:0.4))),
            child:Row(children:[
              CircleAvatar(radius:16,backgroundColor:accent,
                  child:Text('$userRank',style:const TextStyle(color:Colors.white,fontSize:12,fontWeight:FontWeight.w700))),
              const SizedBox(width:12),
              Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                Text('Il tuo risultato',style:TextStyle(fontSize:11,color:th.colorScheme.onSurface.withValues(alpha:0.6))),
                Text(SolveTime.format(ao5),style:TextStyle(fontSize:18,fontWeight:FontWeight.w700,fontFamily:'monospace',color:accent)),
              ]),
              const Spacer(),
              Text('Top ${((userRank!/leaderboard.length)*100).round()}%',
                  style:TextStyle(color:accent,fontWeight:FontWeight.w600,fontSize:12)),
            ])),

        const Divider(height:1),

        // Scrollable leaderboard
        Expanded(child:ListView.builder(
          controller:ctrl,
          padding:const EdgeInsets.only(bottom:32),
          itemCount:leaderboard.length,
          itemBuilder:(_,i) {
            final r = leaderboard[i];
            final isUser = r['display_name'] == userDisplayName;
            final times = (r['times'] as List?)?.cast<int>() ?? [];
            final rankNum = i+1;

            Color? rankColor;
            if (rankNum==1) rankColor=Colors.amber;
            else if (rankNum==2) rankColor=Colors.grey.shade400;
            else if (rankNum==3) rankColor=const Color(0xFFCD7F32);

            return Container(
              margin:const EdgeInsets.symmetric(horizontal:12,vertical:3),
              padding:const EdgeInsets.symmetric(horizontal:12,vertical:10),
              decoration:BoxDecoration(
                color:isUser?accent.withValues(alpha:0.08):th.cardColor,
                borderRadius:BorderRadius.circular(10),
                border:Border.all(color:isUser?accent.withValues(alpha:0.3):Colors.transparent)),
              child:Row(children:[
                // Rank badge
                Container(width:28,height:28,alignment:Alignment.center,
                  decoration:BoxDecoration(
                    color:rankColor??th.dividerColor,
                    shape:BoxShape.circle),
                  child:Text('$rankNum',style:TextStyle(
                    fontSize:11,fontWeight:FontWeight.w700,
                    color:rankColor!=null?Colors.white:th.colorScheme.onSurface.withValues(alpha:0.7)))),
                const SizedBox(width:12),
                // Name
                Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                  Row(children:[
                    Text(r['display_name']??'?',style:TextStyle(
                        fontWeight:isUser?FontWeight.w700:FontWeight.w500,
                        color:isUser?accent:th.colorScheme.onSurface)),
                    if (isUser) ...[const SizedBox(width:6),
                      Container(padding:const EdgeInsets.symmetric(horizontal:6,vertical:1),
                        decoration:BoxDecoration(color:accent.withValues(alpha:0.15),borderRadius:BorderRadius.circular(4)),
                        child:Text('Tu',style:TextStyle(fontSize:10,color:accent,fontWeight:FontWeight.w700)))],
                  ]),
                  // Individual times
                  if (times.isNotEmpty)
                    Text(times.map(SolveTime.format).join(' | '),
                        style:th.textTheme.bodyMedium?.copyWith(fontSize:10,
                            color:th.colorScheme.onSurface.withValues(alpha:0.5))),
                ])),
                // ao5 time
                Text(SolveTime.format(r['ao5']??0),
                    style:TextStyle(fontFamily:'monospace',fontSize:16,
                        fontWeight:FontWeight.w700,
                        color:rankNum==1?Colors.amber:isUser?accent:th.colorScheme.onSurface)),
              ]));
          })),
      ]));
  }
}

class _SolveChip extends StatelessWidget {
  final int index; final int? ms; final bool isActive;
  final Color accent; final ThemeData theme;
  const _SolveChip({required this.index, required this.ms, required this.isActive,
      required this.accent, required this.theme});
  @override
  Widget build(BuildContext context) => Container(
    padding:const EdgeInsets.symmetric(horizontal:10,vertical:6),
    decoration:BoxDecoration(
      color:isActive?accent.withValues(alpha:0.15):theme.cardColor,
      borderRadius:BorderRadius.circular(10),
      border:Border.all(color:isActive?accent:theme.dividerColor,width:isActive?1.5:1)),
    child:Column(children:[
      Text('S$index',style:TextStyle(fontSize:10,color:theme.colorScheme.onSurface.withValues(alpha:0.5))),
      Text(ms!=null?SolveTime.format(ms!):'-',
          style:TextStyle(fontFamily:'monospace',fontSize:13,fontWeight:FontWeight.w700,
              color:isActive?accent:theme.colorScheme.onSurface)),
    ]));
}

class _EventBar extends StatelessWidget {
  final String selected; final ValueChanged<String> onSelect;
  const _EventBar({required this.selected, required this.onSelect});
  static const _events=['3x3','2x2','4x4','5x5','oh','pyra','skewb','mega','clock','sq1'];
  @override
  Widget build(BuildContext context) {
    final th=Theme.of(context);
    return SizedBox(height:52,child:ListView.separated(
      scrollDirection:Axis.horizontal,
      padding:const EdgeInsets.symmetric(horizontal:12,vertical:4),
      itemCount:_events.length,
      separatorBuilder:(_,__)=>const SizedBox(width:8),
      itemBuilder:(_,i) {
        final e=_events[i]; final isActive=e==selected;
        return GestureDetector(
          onTap:()=>onSelect(e),
          child:Chip(
            avatar:SizedBox(width:16,height:16,child:eventCube(e,size:16)),
            label:Text(e,style:TextStyle(fontWeight:isActive?FontWeight.w700:FontWeight.w400,
                color:isActive?th.colorScheme.primary:th.colorScheme.onSurface,fontSize:12)),
            backgroundColor:isActive?th.colorScheme.primary.withValues(alpha:0.12):th.cardColor,
            side:BorderSide(color:isActive?th.colorScheme.primary:th.dividerColor)));
      }));
  }
}
