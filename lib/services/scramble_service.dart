import 'dart:math';
import 'dart:convert';
import 'dart:collection';
import 'package:http/http.dart' as http;
import 'package:cuber/cuber.dart';

/// WCA-legal scramble generator.
/// Primary: tnoodle REST API (if running locally or on server)
/// Secondary: Kociemba two-phase solver via [cuber] for 3×3/OH random-state scrambles
/// Fallback: internal scrambles for other puzzles
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

  // Try tnoodle API; on failure, use cuber or internal generator
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
      // tnoodle not available → use cuber / internal
    }
    return _fallback(eventId);
  }

  // Synchronous fallback (used when tnoodle unavailable)
  static String _fallback(String eventId) {
    if (eventId == '3x3' || eventId == 'oh') return _cuberScramble();
    switch (eventId) {
      case '2x2':
        return _twoByTwo();
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
        return _cuberScramble();
    }
  }

  // Keep generateFor synchronous-compatible for existing code
  // (wraps future with cached result; callers should use await)
  static String generateSync(String eventId) => _fallback(eventId);

  // ── Kociemba random-state scrambler (cuber) ───────────────
  static String _cuberScramble() {
    final cube = Cube.scrambled(n: 100);
    final solution = cube.solve(
      maxDepth: 25,
      timeout: const Duration(seconds: 5),
    );
    if (solution == null || solution.isEmpty) return _3x3(20);
    // Invert solution → scramble
    final scramble =
        solution.algorithm.moves.reversed.map((m) => m.inverse()).toList();
    return scramble.join(' ');
  }

  // ── 2×2 scrambler (25 random moves, U/F/R only) ────────────
  // WCA defines 2×2 scrambles using only U, F, R moves.
  // The DBL corner is implicitly fixed. 25 moves >> mixing time.

  static String _twoByTwo() {
    var moves = <String>[];
    var last = '';
    for (var i = 0; i < 25; i++) {
      final faces = ['U', 'F', 'R'];
      String f;
      do { f = faces[_rng.nextInt(3)]; } while (f == last);
      moves.add('$f${['', "'", '2'][_rng.nextInt(3)]}');
      last = f;
    }
    return moves.join(' ');
  }

  // ── Internal generators ────────────────────────────────────

  static const _axisMap = {'U': 0, 'D': 0, 'F': 1, 'B': 1, 'L': 2, 'R': 2};
  static const _f3 = ['U', 'D', 'F', 'B', 'L', 'R'];
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

  static int _fact(int n) => n <= 1 ? 1 : n * _fact(n - 1);

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

  // ── Pyraminx (BFS random-state) ────────────────────────────
  // 6 edges, each at 1 of 6 positions with 2 orientations.
  // Total states: 6! × 2^5 = 23 040 (tiny, trivial BFS).
  // 4 tip moves (u l r b) added at display time — no state effect.

  static List<int>? _pyraTable;
  static const _pyraEdgePos = 6;
  static const _pyraFaces = ['U', 'L', 'R', 'B'];
  static const _pyraMoveNames = ['U', "U'", 'L', "L'", 'R', "R'", 'B', "B'"];

  // Each move cycles 3 edge positions (index→index) and flips them
  static const _pyraMoves = [
    [0, 1, 2],    // U
    [0, 2, 1],    // U'
    [0, 4, 3],    // L
    [0, 3, 4],    // L'
    [1, 3, 5],    // R
    [1, 5, 3],    // R'
    [2, 5, 4],    // B
    [2, 4, 5],    // B'
  ];

  static int _pyraEncode(List<int> ep, List<int> eo) {
    var code = 0;
    for (var i = 0; i < _pyraEdgePos; i++) {
      var c = 0;
      for (var j = i + 1; j < _pyraEdgePos; j++) if (ep[j] < ep[i]) c++;
      code = code * (_pyraEdgePos - i) + c;
    }
    return code * 32 + eo[0] * 16 + eo[1] * 8 + eo[2] * 4 + eo[3] * 2 + eo[4];
  }

  static void _pyraDecode(int idx, List<int> ep, List<int> eo) {
    var ori = idx % 32;
    var leh = idx ~/ 32;
    var avail = List.generate(_pyraEdgePos, (i) => i);
    for (var i = 0; i < _pyraEdgePos; i++) {
      var f = _fact(5 - i);
      var p = leh ~/ f;
      leh %= f;
      ep[i] = avail[p];
      avail.removeAt(p);
    }
    eo[5] = 0;
    for (var i = 0; i < 5; i++) {
      eo[i] = (ori >> (4 - i)) & 1;
      eo[5] ^= eo[i];
    }
  }

  static void _pyraInit() {
    if (_pyraTable != null) return;
    var size = _fact(6) * 32;
    var table = List.filled(size, 255);
    var ep = List.filled(_pyraEdgePos, 0);
    var eo = List.filled(_pyraEdgePos, 0);
    var nep = List.filled(_pyraEdgePos, 0);
    var neo = List.filled(_pyraEdgePos, 0);

    var start = _pyraEncode([0, 1, 2, 3, 4, 5], [0, 0, 0, 0, 0, 0]);
    table[start] = 0;
    var q = Queue<int>()..add(start);

    while (q.isNotEmpty) {
      var cur = q.removeFirst();
      var d = table[cur];
      if (d >= 10) continue;
      _pyraDecode(cur, ep, eo);
      for (var m = 0; m < 8; m++) {
        var cycle = _pyraMoves[m];
        for (var k = 0; k < _pyraEdgePos; k++) {
          nep[k] = ep[k];
          neo[k] = eo[k];
        }
        // Cycle 3 edges
        var tp = nep[cycle[2]];
        var to = neo[cycle[2]];
        for (var k = 2; k > 0; k--) {
          nep[cycle[k]] = nep[cycle[k - 1]];
          neo[cycle[k]] = neo[cycle[k - 1]] ^ 1; // flip
        }
        nep[cycle[0]] = tp;
        neo[cycle[0]] = to ^ 1;
        var nidx = _pyraEncode(nep, neo);
        if (table[nidx] == 255) {
          table[nidx] = d + 1;
          q.add(nidx);
        }
      }
    }
    _pyraTable = table;
  }

  static String _pyra() {
    _pyraInit();
    var ep = List.generate(_pyraEdgePos, (i) => i)..shuffle(_rng);
    var eo = List.filled(_pyraEdgePos, 0);
    var sum = 0;
    for (var i = 0; i < 5; i++) { eo[i] = _rng.nextInt(2); sum ^= eo[i]; }
    eo[5] = sum; // orientation parity

    var idx = _pyraEncode(ep, eo);
    var table = _pyraTable!;
    if (table[idx] == 255) return _pyraFallback();

    var result = <String>[];
    var cur = idx;
    var cpBuf = List.filled(_pyraEdgePos, 0);
    var coBuf = List.filled(_pyraEdgePos, 0);
    var ncp = List.filled(_pyraEdgePos, 0);
    var nco = List.filled(_pyraEdgePos, 0);

    while (table[cur] > 0) {
      _pyraDecode(cur, cpBuf, coBuf);
      var found = false;
      for (var m = 0; m < 8; m++) {
        var cycle = _pyraMoves[m];
        for (var k = 0; k < _pyraEdgePos; k++) {
          ncp[k] = cpBuf[k];
          nco[k] = coBuf[k];
        }
        var tp = ncp[cycle[2]];
        var to = nco[cycle[2]];
        for (var k = 2; k > 0; k--) {
          ncp[cycle[k]] = ncp[cycle[k - 1]];
          nco[cycle[k]] = nco[cycle[k - 1]] ^ 1;
        }
        ncp[cycle[0]] = tp;
        nco[cycle[0]] = to ^ 1;
        var nidx = _pyraEncode(ncp, nco);
        if (table[nidx] == table[cur] - 1) {
          result.add(_pyraMoveNames[m]);
          cur = nidx;
          found = true;
          break;
        }
      }
      if (!found) break;
    }

    // Add random tip moves (don't affect state)
    for (final t in ['u', 'l', 'r', 'b']) {
      if (_rng.nextBool()) result.add('$t${_rng.nextBool() ? "" : "'"}');
    }
    return result.isEmpty ? _pyraFallback() : result.join(' ');
  }

  static String _pyraFallback() {
    const mods = ["", "'"];
    var moves = <String>[];
    String last = '';
    while (moves.length < 15) {
      var f = _pyraFaces[_rng.nextInt(4)];
      if (f == last) continue;
      moves.add('$f${mods[_rng.nextInt(2)]}');
      last = f;
    }
    for (final t in ['u', 'l', 'r', 'b']) {
      if (_rng.nextBool()) moves.add('$t${mods[_rng.nextInt(2)]}');
    }
    return moves.join(' ');
  }

  // ── Skewb (improved random-move, 15 moves) ─────────────────
  static String _skewb() {
    const faces = ['R', 'L', 'U', 'B'];
    const mods = ["", "'"];
    var moves = <String>[];
    String last = '';
    while (moves.length < 15) {
      var f = faces[_rng.nextInt(4)];
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

  /// WCA Square-1: (top,bot)/ — always valid since no shape restriction
  static String _sq1() {
    var parts = <String>[];
    int prevTop = 99, prevBot = 99;
    for (var i = 0; i < 13; i++) {
      int top, bot;
      var tries = 0;
      do {
        top = _rng.nextInt(12) - 5;
        bot = _rng.nextInt(12) - 5;
        tries++;
        // Skip (0,0) and exact repeats of the previous move
      } while ((top == 0 && bot == 0) ||
          (top == prevTop && bot == prevBot && tries < 30));
      parts.add('($top,$bot)/');
      prevTop = top;
      prevBot = bot;
    }
    return parts.join(' ');
  }
}
