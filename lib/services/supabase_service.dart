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

  /// Called once at startup — ensures a persistent anonymous ID exists
  static Future<void> initialize() async {
    if (!AppConfig.hasSupabaseConfig) return;
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
    await _i._ensureAnonId();
  }

  // ── Anonymous user ───────────────────────────────────────
  Future<void> _ensureAnonId() async {
    final p = await SharedPreferences.getInstance();
    _anonId = p.getString('sb_anon_id') ?? '';
    if (_anonId.isEmpty) {
      _anonId = const Uuid().v4();
      await p.setString('sb_anon_id', _anonId);
    }
  }

  // ── Auth ─────────────────────────────────────────────────
  User? get currentUser => client.auth.currentUser;
  bool  get isLoggedIn  => currentUser != null;
  String? get uid       => currentUser?.id;
  String get effectiveUserId => uid ?? _anonId;

  String get displayName =>
      currentUser?.userMetadata?['display_name'] as String? ??
      _profileName;

  set profileName(String v) => _profileName = v;

  Future<AuthResponse> signUp(String email, String password) =>
      client.auth.signUp(email: email, password: password);

  Future<AuthResponse> signIn(String email, String password) =>
      client.auth.signInWithPassword(email: email, password: password);

  Future<void> signOut() async {
    try { await client.auth.signOut(); } catch (_) {}
  }

  /// Update the authenticated user's metadata (no-op for anonymous)
  Future<void> updateUserMeta(Map<String, dynamic> meta) async {
    if (!isLoggedIn) return;
    await client.auth.updateUser(UserAttributes(data: meta));
  }

  // ── Competition results ──────────────────────────────────

  Future<bool> submitCompetitionResult({
    required String eventId,
    required List<int> times,
    required int ao5,
    required String displayName,
  }) async {
    try {
      await client.from('competition_results').upsert({
        'user_id':      effectiveUserId,
        'display_name': displayName,
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
