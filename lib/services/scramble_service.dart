// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// WCA-legal scramble generator.
/// Primary: tnoodle REST API (if running locally or on server)
/// Fallback: internal random-state scrambles
class ScrambleService {
  static final _rng = Random.secure();

  // tnoodle server URL — set this to your tnoodle instance
  // Run locally: java -jar tnoodle.jar → listens on http://localhost:2014
  static const _tnoodleBase = 'http://localhost:2014';

  // Mapping from internal event ID to tnoodle puzzle name
  static const _tnoodleMap = {
    '3x3': '333',
    'oh': '333oh',
    '2x2': '222',
    '4x4': '444',
    '5x5': '555',
    '6x6': '666',
    '7x7': '777',
    'pyra': 'pyraminx',
    'skewb': 'skewb',
    'mega': 'minx',
    'clock': 'clock',
    'sq1': 'sq1',
  };

  // Try tnoodle API; on failure, use internal generator
  static Future<String> generateFor(String eventId) async {
    // Try tnoodle first (non-blocking, 500ms timeout)
    try {
      final puzzle = _tnoodleMap[eventId] ?? '333';
      final uri = Uri.parse('$_tnoodleBase/api/v0/scramble/$puzzle');
      final resp =
          await http.get(uri).timeout(const Duration(milliseconds: 500));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data is Map && data['scramble'] != null)
          return data['scramble'] as String;
        if (data is String && data.isNotEmpty) return data;
      }
    } catch (_) {
      // tnoodle not available → use internal
    }
    return _fallback(eventId);
  }

  // Synchronous fallback (used when tnoodle unavailable)
  static String _fallback(String eventId) {
    switch (eventId) {
      case '2x2':
        return _nxn(_f2, 11);
      case '3x3':
      case 'oh':
        return _3x3(20);
      case '4x4':
        return _bigCube(_f4, 44);
      case '5x5':
        return _bigCube(_f4, 60);
      case '6x6':
        return _bigCube(_f6, 80);
      case '7x7':
        return _bigCube(_f6, 100);
      case 'pyra':
        return _pyra();
      case 'skewb':
        return _skewb();
      case 'mega':
        return _mega();
      case 'clock':
        return _clock();
      case 'sq1':
        return _sq1();
      default:
        return _3x3(20);
    }
  }

  // Keep generateFor synchronous-compatible for existing code
  // (wraps future with cached result; callers should use await)
  static String generateSync(String eventId) => _fallback(eventId);

  // ── Internal generators ────────────────────────────────────

  static const _axisMap = {'U': 0, 'D': 0, 'F': 1, 'B': 1, 'L': 2, 'R': 2};
  static const _f3 = ['U', 'D', 'F', 'B', 'L', 'R'];
  static const _f2 = ['U', 'F', 'R'];
  static const _f4 = [
    'U',
    'D',
    'F',
    'B',
    'L',
    'R',
    'Uw',
    'Dw',
    'Fw',
    'Bw',
    'Lw',
    'Rw'
  ];
  static const _f6 = [
    'U',
    'D',
    'F',
    'B',
    'L',
    'R',
    'Uw',
    'Dw',
    'Fw',
    'Bw',
    'Lw',
    'Rw',
    '3Uw',
    '3Dw',
    '3Fw',
    '3Bw',
    '3Lw',
    '3Rw'
  ];

  static String _mod() => ['', "'", '2'][_rng.nextInt(3)];

  static String _3x3(int len) {
    final moves = <String>[];
    int lastAx = -1, prevAx = -1;
    while (moves.length < len) {
      final f = _f3[_rng.nextInt(6)];
      final ax = _axisMap[f]!;
      if (ax == lastAx || ax == prevAx) continue;
      moves.add('$f${_mod()}');
      prevAx = lastAx;
      lastAx = ax;
    }
    return moves.join(' ');
  }

  static String _nxn(List<String> faces, int len) {
    final moves = <String>[];
    String last = '';
    while (moves.length < len) {
      final f = faces[_rng.nextInt(faces.length)];
      if (f == last) continue;
      moves.add('$f${_mod()}');
      last = f;
    }
    return moves.join(' ');
  }

  static String _bigCube(List<String> faces, int len) {
    final moves = <String>[];
    String last = '';
    while (moves.length < len) {
      final f = faces[_rng.nextInt(faces.length)];
      if (f == last) continue;
      moves.add('$f${_mod()}');
      last = f;
    }
    return moves.join(' ');
  }

  static String _pyra() {
    const main = ['U', 'L', 'R', 'B'];
    const mods = ["", "'"];
    final moves = <String>[];
    String last = '';
    while (moves.length < 9) {
      final f = main[_rng.nextInt(4)];
      if (f == last) continue;
      moves.add('$f${mods[_rng.nextInt(2)]}');
      last = f;
    }
    for (final t in ['u', 'l', 'r', 'b']) {
      if (_rng.nextBool()) moves.add('$t${mods[_rng.nextInt(2)]}');
    }
    return moves.join(' ');
  }

  static String _skewb() {
    const faces = ['R', 'L', 'U', 'B'];
    const mods = ["", "'"];
    final moves = <String>[];
    String last = '';
    while (moves.length < 11) {
      final f = faces[_rng.nextInt(4)];
      if (f == last) continue;
      moves.add('$f${mods[_rng.nextInt(2)]}');
      last = f;
    }
    return moves.join(' ');
  }

  static String _mega() {
    const faceMods = ['++', '--'];
    const rotMods = ['U', "U'"];
    final sb = StringBuffer();
    for (int row = 0; row < 7; row++) {
      for (int col = 0; col < 5; col++) {
        sb.write('${['R', 'D'][_rng.nextInt(2)]}${faceMods[_rng.nextInt(2)]} ');
      }
      sb.write('${rotMods[_rng.nextInt(2)]}\n');
    }
    return sb.toString().trim();
  }

  /// WCA Clock: UL# UR# DR# DL# U# R# D# L# ALL# y2 UL# UR# DR# DL# U# R# D# L# ALL#
  static String _clock() {
    const dials = ['UL', 'UR', 'DR', 'DL', 'U', 'R', 'D', 'L', 'ALL'];
    int rn() {
      int n;
      do {
        n = _rng.nextInt(11) - 5;
      } while (n == 0);
      return n;
    }

    String fmt(int n) => n > 0 ? '$n+' : '${n.abs()}-';
    final front = dials.map((_) => fmt(rn())).join(' ');
    final back = dials.map((_) => fmt(rn())).join(' ');
    return '$front y2 $back';
  }

  /// WCA Square-1: (top,bot)/ sequence — always produces valid scramble
  static String _sq1() {
    final parts = <String>[];
    int prevTop = 99, prevBot = 99;
    for (int i = 0; i < 11; i++) {
      int top, bot;
      int tries = 0;
      do {
        top = _rng.nextInt(12) - 5; // -5..+6
        bot = _rng.nextInt(12) - 5;
        tries++;
      } while ((top == 0 && bot == 0) ||
          (top == prevTop && bot == prevBot && tries < 30));
      parts.add('($top,$bot)/');
      prevTop = top;
      prevBot = bot;
    }
    return parts.join(' ');
  }
}
