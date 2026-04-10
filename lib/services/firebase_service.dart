import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseService _i = FirebaseService._();
  factory FirebaseService() => _i;
  FirebaseService._();

  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  bool  get isLoggedIn  => currentUser != null;
  String? get uid       => currentUser?.uid;

  // ── Competition scrambles ──────────────────────────────────

  Future<Map<String, dynamic>?> getTodayCompetition(String eventId) async {
    final today = _todayStr();
    try {
      final doc = await _db
          .collection('competitions')
          .doc('$today\_$eventId')
          .get();
      return doc.exists ? doc.data() : null;
    } catch (_) { return null; }
  }

  Future<void> submitCompetitionResult({
    required String eventId,
    required List<int> times,
    required int ao5,
    required String displayName,
  }) async {
    if (!isLoggedIn) return;
    final today = _todayStr();
    await _db
        .collection('competitions')
        .doc('$today\_$eventId')
        .collection('results')
        .doc(uid)
        .set({
      'uid':         uid,
      'displayName': displayName,
      'times':       times,
      'ao5':         ao5,
      'submittedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ── Leaderboard ────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getDailyLeaderboard(String eventId) async {
    final today = _todayStr();
    try {
      final snap = await _db
          .collection('competitions')
          .doc('$today\_$eventId')
          .collection('results')
          .orderBy('ao5')
          .limit(50)
          .get();
      return snap.docs.map((d) => d.data()).toList();
    } catch (_) { return []; }
  }

  // ── User profile ───────────────────────────────────────────

  Future<void> saveUserProfile(Map<String, dynamic> data) async {
    if (!isLoggedIn) return;
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      return doc.exists ? doc.data() : null;
    } catch (_) { return null; }
  }

  // ── Auth ───────────────────────────────────────────────────

  Future<void> signOut() => _auth.signOut();

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
  }
}
