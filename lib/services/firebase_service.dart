import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static final FirebaseService _i = FirebaseService._();
  factory FirebaseService() => _i;
  FirebaseService._();

  static bool _initialized = false;

  // Safe init: works even without google-services.json configured
  static Future<void> safeInit() async {
    if (_initialized) return;
    try {
      if (Firebase.apps.isEmpty) {
        // Only init if google-services.json / GoogleService-Info.plist is present
        // For dev without Firebase: this will throw, which we catch silently
        await Firebase.initializeApp();
      }
      _initialized = true;
    } catch (e) {
      if (kDebugMode) print('[Firebase] Not configured: $e');
      _initialized = false;
    }
  }

  bool get isAvailable => _initialized;

  FirebaseAuth? get _auth => _initialized ? FirebaseAuth.instance : null;
  FirebaseFirestore? get _db => _initialized ? FirebaseFirestore.instance : null;

  User? get currentUser => _auth?.currentUser;
  bool  get isLoggedIn  => currentUser != null;
  String? get uid       => currentUser?.uid;

  // ── Competition ────────────────────────────────────────────

  Future<Map<String, dynamic>?> getTodayCompetition(String eventId) async {
    if (_db == null) return null;
    final today = _todayStr();
    try {
      final doc = await _db!
          .collection('competitions')
          .doc('${today}_$eventId')
          .get()
          .timeout(const Duration(seconds: 5));
      return doc.exists ? doc.data() : null;
    } catch (e) {
      if (kDebugMode) print('[Firebase] getTodayCompetition: $e');
      return null;
    }
  }

  Future<void> submitCompetitionResult({
    required String eventId,
    required List<int> times,
    required int ao5,
    required String displayName,
  }) async {
    if (_db == null || !isLoggedIn) return;
    final today = _todayStr();
    try {
      await _db!
          .collection('competitions')
          .doc('${today}_$eventId')
          .collection('results')
          .doc(uid)
          .set({
        'uid': uid, 'displayName': displayName,
        'times': times, 'ao5': ao5,
        'submittedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true))
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      if (kDebugMode) print('[Firebase] submitResult: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getDailyLeaderboard(String eventId) async {
    if (_db == null) return [];
    final today = _todayStr();
    try {
      final snap = await _db!
          .collection('competitions')
          .doc('${today}_$eventId')
          .collection('results')
          .orderBy('ao5')
          .limit(50)
          .get()
          .timeout(const Duration(seconds: 5));
      return snap.docs.map((d) => d.data()).toList();
    } catch (e) {
      if (kDebugMode) print('[Firebase] leaderboard: $e');
      return [];
    }
  }

  Future<void> saveUserProfile(Map<String, dynamic> data) async {
    if (_db == null || !isLoggedIn) return;
    try {
      await _db!.collection('users').doc(uid).set(data, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) print('[Firebase] saveProfile: $e');
    }
  }

  Future<void> signOut() async {
    try { await _auth?.signOut(); } catch (_) {}
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
  }
}
