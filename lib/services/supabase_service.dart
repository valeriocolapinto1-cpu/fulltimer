import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

class SupabaseService {
  static final SupabaseService _i = SupabaseService._();
  factory SupabaseService() => _i;
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    if (!AppConfig.hasSupabaseConfig) {
      throw StateError(
        'Missing Supabase configuration. Pass SUPABASE_URL and SUPABASE_ANON_KEY with --dart-define.',
      );
    }
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
  }

  // ── Auth ─────────────────────────────────────────────────
  User? get currentUser => client.auth.currentUser;
  bool  get isLoggedIn  => currentUser != null;
  String? get uid       => currentUser?.id;
  String get displayName => currentUser?.userMetadata?['display_name'] as String? ?? 'Anonimo';

  Future<void> signOut() async {
    try { await client.auth.signOut(); } catch (e) { if (kDebugMode) print('[Supabase] signOut: $e'); }
  }

  // ── Competition results ───────────────────────────────────

  /// Submit an ao5 result for today's competition
  Future<bool> submitCompetitionResult({
    required String eventId,
    required List<int> times,
    required int ao5,
    required String displayName,
  }) async {
    try {
      final today = _todayStr();
      await client.from('competition_results').upsert({
        'user_id':      uid ?? 'anonymous_${DateTime.now().millisecondsSinceEpoch}',
        'display_name': displayName,
        'event_id':     eventId,
        'date':         today,
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

  /// Get today's leaderboard for an event, ordered by ao5 ascending
  Future<List<Map<String, dynamic>>> getDailyLeaderboard(String eventId) async {
    try {
      final today = _todayStr();
      final resp = await client
          .from('competition_results')
          .select()
          .eq('event_id', eventId)
          .eq('date', today)
          .order('ao5', ascending: true)
          .limit(100);
      return List<Map<String, dynamic>>.from(resp as List);
    } catch (e) {
      if (kDebugMode) print('[Supabase] leaderboard: $e');
      return [];
    }
  }

  /// Get all-time personal best for the current user
  Future<Map<String, dynamic>?> getPersonalBest(String eventId) async {
    if (!isLoggedIn) return null;
    try {
      final resp = await client
          .from('competition_results')
          .select()
          .eq('user_id', uid!)
          .eq('event_id', eventId)
          .order('ao5', ascending: true)
          .limit(1)
          .maybeSingle();
      return resp;
    } catch (e) {
      if (kDebugMode) print('[Supabase] personalBest: $e');
      return null;
    }
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
  }
}
