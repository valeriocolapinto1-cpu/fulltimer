// services/storage_service.dart
// Gestisce la persistenza locale con SharedPreferences

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session.dart';
import '../models/event_type.dart';

class StorageService {
  static const _sessionsKey = 'sessions';
  static const _customEventsKey = 'custom_events';
  static const _activeSessionKey = 'active_session_id';
  static const _activeEventKey = 'active_event_id';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Sessioni ──────────────────────────────────────────────

  Future<List<Session>> loadSessions() async {
    final raw = _prefs.getString(_sessionsKey);
    if (raw == null) return [];
    final List decoded = jsonDecode(raw);
    return decoded.map((e) => Session.fromJson(e)).toList();
  }

  Future<void> saveSessions(List<Session> sessions) async {
    final encoded = jsonEncode(sessions.map((s) => s.toJson()).toList());
    await _prefs.setString(_sessionsKey, encoded);
  }

  // ── Evento / Sessione attivi ──────────────────────────────

  Future<String?> loadActiveSessionId() async =>
      _prefs.getString(_activeSessionKey);

  Future<void> saveActiveSessionId(String id) async =>
      _prefs.setString(_activeSessionKey, id);

  Future<String> loadActiveEventId() async =>
      _prefs.getString(_activeEventKey) ?? '3x3';

  Future<void> saveActiveEventId(String id) async =>
      _prefs.setString(_activeEventKey, id);

  // ── Eventi personalizzati ─────────────────────────────────

  Future<List<EventType>> loadCustomEvents() async {
    final raw = _prefs.getString(_customEventsKey);
    if (raw == null) return [];
    final List decoded = jsonDecode(raw);
    return decoded.map((e) => EventType.fromJson(e)).toList();
  }

  Future<void> saveCustomEvents(List<EventType> events) async {
    final encoded = jsonEncode(events.map((e) => e.toJson()).toList());
    await _prefs.setString(_customEventsKey, encoded);
  }

}
