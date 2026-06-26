import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../config/app_config.dart';

class SupabaseService {
  static final SupabaseService _i = SupabaseService._();
  factory SupabaseService() => _i;
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;

  String _anonId = '';
  String _profileName = '';
  Map<String, dynamic>? _profile;

  /// Called once at startup — ensures a persistent anonymous ID exists
  static Future<void> initialize() async {
    if (!AppConfig.hasSupabaseConfig) return;
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
    await _i._ensureSession();
    await _i._loadLocalProfileName();
  }

  // ── Anonymous user / auth session ────────────────────────
  Future<void> _ensureSession() async {
    final current = client.auth.currentUser;
    if (current != null) {
      return;
    }

    await client.auth.signInAnonymously();
    await _ensureAnonId();
  }

  Future<void> _ensureAnonId() async {
    final p = await SharedPreferences.getInstance();
    _anonId = p.getString('sb_anon_id') ?? '';
    if (_anonId.isEmpty) {
      _anonId = const Uuid().v4();
      await p.setString('sb_anon_id', _anonId);
    }
  }

  Future<void> _loadLocalProfileName() async {
    final p = await SharedPreferences.getInstance();
    _profileName = p.getString('p_name') ?? '';
  }

  // ── Auth ─────────────────────────────────────────────────
  User? get currentUser => client.auth.currentUser;
  bool  get isLoggedIn  => currentUser != null;
  String? get uid       => currentUser?.id;
  String get effectiveUserId => uid ?? _anonId;

  String get displayName =>
      _profile?['display_name'] as String? ??
      currentUser?.userMetadata?['display_name'] as String? ??
      _profileName;

  set profileName(String v) => _profileName = v;

  Future<AuthResponse> signUp(String email, String password) =>
      client.auth.signUp(email: email, password: password);

  Future<AuthResponse> signIn(String email, String password) =>
      client.auth.signInWithPassword(email: email, password: password);

  Future<void> signOut() async {
    await client.auth.signOut();
    _profile = null;
    _profileName = '';
    await _ensureSession();
    await _loadLocalProfileName();
  }

  /// Update the authenticated user's metadata (no-op for anonymous)
  Future<void> updateUserMeta(Map<String, dynamic> meta) async {
    if (!isLoggedIn) return;
    await client.auth.updateUser(UserAttributes(data: meta));
  }

  // ── Profile sync ─────────────────────────────────────────

  Future<Map<String, dynamic>?> fetchProfile() async {
    if (!isLoggedIn) return null;

    final resp = await client
        .from('profiles')
        .select()
        .eq('user_id', effectiveUserId)
        .maybeSingle();

    if (resp == null) {
      _profile = null;
      return null;
    }

    _profile = Map<String, dynamic>.from(resp as Map);
    final name = _profile?['display_name'] as String?;
    if (name != null && name.isNotEmpty) {
      _profileName = name;
    }
    return _profile;
  }

  Future<void> saveProfile({
    required String displayName,
    required String country,
    required String wcaId,
    required String avatarEmoji,
    String? wcaAvatarUrl,
    required List<String> favoriteEvents,
    required List<String> learnedAlgs,
  }) async {
    if (!isLoggedIn) return;

    final payload = <String, dynamic>{
      'user_id': effectiveUserId,
      'display_name': displayName,
      'country': country,
      'wca_id': wcaId,
      'avatar_emoji': avatarEmoji,
      'wca_avatar_url': wcaAvatarUrl,
      'favorite_events': favoriteEvents,
      'learned_algs': learnedAlgs,
    };

    await client.from('profiles').upsert(payload, onConflict: 'user_id');
    _profile = payload;
    _profileName = displayName;
  }

  // ── Input validation ────────────────────────────────────

  static const _maxDisplayNameLength = 30;
  static const _maxTimeMs = 3600000; // 1 hour
  static const _minTimeMs = 0;

  String _sanitizeDisplayName(String name) {
    var s = name.trim();
    if (s.isEmpty) s = 'Anonimo';
    // Strip control characters and non-printable chars
    s = s.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
    if (s.length > _maxDisplayNameLength) {
      s = s.substring(0, _maxDisplayNameLength);
    }
    return s;
  }

  bool _validTimes(List<int> times) {
    if (times.length != 5) return false;
    for (final t in times) {
      if (t < _minTimeMs || t > _maxTimeMs) return false;
    }
    return true;
  }

  int _computeAo5(List<int> times) {
    final sorted = List<int>.from(times)..sort();
    return ((sorted[1] + sorted[2] + sorted[3]) / 3).round();
  }

  // ── Competition results ──────────────────────────────────

  Future<bool> submitCompetitionResult({
    required String eventId,
    required List<int> times,
    required int ao5,
    required String displayName,
  }) async {
    if (!_validTimes(times)) return false;
    final expectedAo5 = _computeAo5(times);
    if (ao5 != expectedAo5) return false;
    if (ao5 < _minTimeMs || ao5 > _maxTimeMs) return false;

    try {
      await client.from('competition_results').upsert({
        'user_id':      effectiveUserId,
        'display_name': _sanitizeDisplayName(displayName),
        'event_id':     eventId,
        'date':         _todayStr(),
        'times':        times,
        'ao5':          ao5,
        'submitted_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id, event_id, date');
      return true;
    } catch (e) {
      if (kDebugMode) print('[Supabase] submitResult: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getDailyLeaderboard(String eventId) async {
    try {
      final resp = await client
          .from('competition_results')
          .select()
          .eq('event_id', eventId)
          .eq('date', _todayStr())
          .order('ao5', ascending: true)
          .limit(100);
      return List<Map<String, dynamic>>.from(resp as List);
    } catch (e) {
      if (kDebugMode) print('[Supabase] leaderboard: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getPersonalBest(String eventId) async {
    try {
      return await client
          .from('competition_results')
          .select()
          .eq('user_id', effectiveUserId)
          .eq('event_id', eventId)
          .order('ao5', ascending: true)
          .limit(1)
          .maybeSingle();
    } catch (e) {
      if (kDebugMode) print('[Supabase] personalBest: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getMyResults({int limit = 50}) async {
    try {
      final resp = await client
          .from('competition_results')
          .select()
          .eq('user_id', effectiveUserId)
          .order('submitted_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(resp as List);
    } catch (e) {
      if (kDebugMode) print('[Supabase] myResults: $e');
      return [];
    }
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
  }
}
