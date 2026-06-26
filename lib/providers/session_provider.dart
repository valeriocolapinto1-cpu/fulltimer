import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/session.dart';
import '../models/solve_time.dart';
import '../models/event_type.dart';
import '../services/storage_service.dart';
import '../services/scramble_service.dart';

class SessionProvider extends ChangeNotifier {
  final StorageService _storage;
  final _uuid = const Uuid();
  List<Session>   _sessions     = [];
  List<EventType> _customEvents = [];
  Session?        _activeSession;
  String          _activeEventId = '3x3';
  String          _currentScramble = '';
  int             _scrambleRequestId = 0;

  SessionProvider(this._storage);

  List<Session>   get sessions        => _sessions;
  Session?        get activeSession   => _activeSession;
  String          get activeEventId   => _activeEventId;
  String          get currentScramble => _currentScramble;
  List<SolveTime> get currentSolves   => _activeSession?.solves ?? [];
  List<EventType> get allEvents       => [...EventType.defaults, ..._customEvents];
  EventType get activeEvent => allEvents.firstWhere((e) => e.id == _activeEventId, orElse: () => EventType.defaults.first);
  List<Session> get sessionsForActiveEvent => _sessions.where((s) => s.eventId == _activeEventId).toList();

  int? get bestTime    => _activeSession?.bestMs;
  int? get ao5         => _activeSession?.averageOf(5);
  int? get ao12        => _activeSession?.averageOf(12);
  int? get sessionMean => _activeSession?.sessionMean;
  int  get solveCount  => _activeSession?.solves.length ?? 0;

  Future<void> init() async {
    _sessions      = await _storage.loadSessions();
    _customEvents  = await _storage.loadCustomEvents();
    _activeEventId = await _storage.loadActiveEventId();
    final activeId = await _storage.loadActiveSessionId();
    if (activeId != null) {
      try { _activeSession = _sessions.firstWhere((s) => s.id == activeId); }
      catch (_) { _activeSession = _getOrCreate(_activeEventId); }
    } else { _activeSession = _getOrCreate(_activeEventId); }
    _generateScramble(); notifyListeners();
  }

  Session _getOrCreate(String eid) {
    final list = _sessions.where((s) => s.eventId == eid).toList();
    return list.isNotEmpty ? list.last : _createSession(eid: eid);
  }

  Session _createSession({String? name, String? eid}) {
    final id = eid ?? _activeEventId;
    final count = _sessions.where((s) => s.eventId == id).length + 1;
    final s = Session(id: _uuid.v4(), name: name ?? 'Sessione $count', eventId: id, createdAt: DateTime.now());
    _sessions.add(s); _storage.saveSessions(_sessions); _storage.saveActiveSessionId(s.id);
    return s;
  }

  void newSession({String? name}) { _activeSession = _createSession(name: name); _generateScramble(); notifyListeners(); }

  void renameSession(String id, String name) {
    try { _sessions.firstWhere((s) => s.id == id).name = name; _storage.saveSessions(_sessions); notifyListeners(); } catch (_) {}
  }

  void deleteSession(String id) {
    final ev = sessionsForActiveEvent;
    if (ev.length <= 1) return;
    _sessions.removeWhere((s) => s.id == id);
    if (_activeSession?.id == id) { _activeSession = _getOrCreate(_activeEventId); _storage.saveActiveSessionId(_activeSession!.id); }
    _storage.saveSessions(_sessions); notifyListeners();
  }

  void switchSession(String id) {
    try { _activeSession = _sessions.firstWhere((s) => s.id == id); _storage.saveActiveSessionId(id); _generateScramble(); notifyListeners(); } catch (_) {}
  }

  void switchEvent(String eid) {
    _activeEventId = eid; _storage.saveActiveEventId(eid);
    _activeSession = _getOrCreate(eid); _storage.saveActiveSessionId(_activeSession!.id);
    _generateScramble(); notifyListeners();
  }

  SolveTime addSolve(int ms) {
    final s = SolveTime(id: _uuid.v4(), milliseconds: ms, timestamp: DateTime.now(),
        scramble: _currentScramble, eventId: _activeEventId);
    _activeSession ??= _createSession();
    _activeSession!.solves.add(s); _storage.saveSessions(_sessions); _generateScramble(); notifyListeners();
    return s;
  }

  void updateSolveResult(String id, SolveResult r) {
    final s = _find(id); if (s == null) return;
    s.result = r; _storage.saveSessions(_sessions); notifyListeners();
  }

  void updateSolveComment(String id, String comment) {
    final s = _find(id); if (s == null) return;
    var c = comment.trim();
    c = c.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
    if (c.length > 500) c = c.substring(0, 500);
    s.comment = c; _storage.saveSessions(_sessions); notifyListeners();
  }

  void toggleFavorite(String id) {
    final s = _find(id); if (s == null) return;
    s.favorite = !s.favorite; _storage.saveSessions(_sessions); notifyListeners();
  }

  void deleteSolve(String id) {
    _activeSession?.solves.removeWhere((s) => s.id == id);
    _storage.saveSessions(_sessions); notifyListeners();
  }

  SolveTime? _find(String id) {
    for (final s in _sessions) { try { return s.solves.firstWhere((x) => x.id == id); } catch (_) {} }
    return null;
  }

  void _generateScramble() {
    final requestId = ++_scrambleRequestId;
    final eventId = _activeEventId;
    _currentScramble = ScrambleService.generateSync(_activeEventId);
    // Async upgrade: fetch tnoodle scramble in background
    ScrambleService.generateFor(eventId).then((s) {
      if (requestId != _scrambleRequestId || eventId != _activeEventId) return;
      _currentScramble = s;
      notifyListeners();
    }).catchError((_) {});
  }
  void newScramble() { _generateScramble(); notifyListeners(); }

  void resetCurrentSession() { _activeSession?.solves.clear(); _storage.saveSessions(_sessions); notifyListeners(); }

  String _sanitizeEventName(String name) {
    var s = name.trim();
    if (s.isEmpty) return 'Evento';
    s = s.replaceAll(RegExp(r'[\x00-\x1F\x7F<>"''&]'), '');
    if (s.length > 40) s = s.substring(0, 40);
    return s;
  }

  String _sanitizeEmoji(String emoji) {
    // Allow only emoji characters (unicode Symbols and Pictographs ranges)
    var s = emoji.trim();
    if (s.isEmpty) return '🧩';
    if (s.length > 4) s = s.substring(0, 4);
    return s;
  }

  void addCustomEvent(String name, String emoji) {
    _customEvents.add(EventType(id: _uuid.v4(),
        name: _sanitizeEventName(name), emoji: _sanitizeEmoji(emoji), isCustom: true));
    _storage.saveCustomEvents(_customEvents); notifyListeners();
  }

  void editCustomEvent(String id, String name, String emoji) {
    final idx = _customEvents.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    _customEvents[idx] = EventType(id: id,
        name: _sanitizeEventName(name), emoji: _sanitizeEmoji(emoji), isCustom: true);
    _storage.saveCustomEvents(_customEvents); notifyListeners();
  }

  void removeCustomEvent(String id) {
    _customEvents.removeWhere((e) => e.id == id);
    _storage.saveCustomEvents(_customEvents); notifyListeners();
  }

  String buildShareText({String? sessionId}) {
    final sess = sessionId != null
        ? _sessions.firstWhere((s) => s.id == sessionId, orElse: () => _activeSession!)
        : _activeSession;
    if (sess == null || sess.solves.isEmpty) return 'Nessun tempo.';
    final sb = StringBuffer();
    sb.writeln('⏱ ${sess.name} · ${activeEvent.name}');
    if (sess.bestMs != null) sb.write('🏆 ${SolveTime.format(sess.bestMs!)}');
    final a5 = sess.averageOf(5), a12 = sess.averageOf(12);
    if (a5 != null && a5 > 0)  sb.write('  ao5: ${SolveTime.format(a5)}');
    if (a12 != null && a12 > 0) sb.write('  ao12: ${SolveTime.format(a12)}');
    sb.writeln('\n');
    for (int i = 0; i < sess.solves.length; i++) {
      final s = sess.solves[sess.solves.length - 1 - i];
      final dt = s.timestamp;
      final d = '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
      sb.write('#${i+1} ${s.displayTime}  $d  ${s.scramble}');
      if (s.comment.isNotEmpty) sb.write('  // ${s.comment}');
      sb.writeln();
    }
    return sb.toString();
  }

  String buildSolveShareText(SolveTime s) {
    final dt = s.timestamp;
    final d = '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
    final sb = StringBuffer();
    sb.writeln('${s.displayTime} — ${activeEvent.name}');
    sb.writeln('📅 $d');
    sb.writeln('🔀 ${s.scramble}');
    if (s.comment.isNotEmpty) sb.writeln('💬 ${s.comment}');
    return sb.toString();
  }
}
