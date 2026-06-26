import 'package:flutter/material.dart';
import 'spinning_cube.dart';

// WCA standard colors
const _pW = Color(0xFFFAFAFA);
const _pY = Color(0xFFFFD500);
const _pR = Color(0xFFBA0C2F);
const _pO = Color(0xFFFF5800);
const _pG = Color(0xFF009B48);
const _pB = Color(0xFF003DA5);
const _pK = Color(0xFF111111);

class ScramblePreview extends StatelessWidget {
  final String scramble;
  final String eventId;
  final double size;
  const ScramblePreview({super.key, required this.scramble, required this.eventId, this.size = 120});

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    Widget painter;
    switch (eventId) {
      case '3x3': case 'oh':
        painter = SizedBox(width: size, height: size * 0.75,
            child: CustomPaint(painter: _CubeNetPainter(scramble, 3)));
      case '2x2':
        painter = SizedBox(width: size * 0.75, height: size * 0.56,
            child: CustomPaint(painter: _CubeNetPainter(scramble, 2)));
      case '4x4': case '5x5': case '6x6': case '7x7':
        painter = SizedBox(width: size, height: size * 0.75,
            child: CustomPaint(painter: _NxNSimPainter(scramble, int.parse(eventId.substring(0, 1)))));
      case 'pyra': case 'skewb': case 'mega': case 'clock': case 'sq1':
        painter = Center(child: SizedBox(width: size * 0.6, height: size * 0.6,
            child: eventCube(eventId, size: size * 0.6)));
      default:
        painter = Container(
          width: size * 0.8, height: size * 0.4,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: th.dividerColor, borderRadius: BorderRadius.circular(8)),
          child: Text(eventId.toUpperCase(),
              style: th.textTheme.bodyMedium?.copyWith(fontSize: 11, fontWeight: FontWeight.w700)));
    }
    return painter;
  }
}

// ── 3x3 / 2x2 Net with full move simulation ──────────────────
class _CubeNetPainter extends CustomPainter {
  final String scramble; final int n;
  _CubeNetPainter(this.scramble, this.n);
  static const _colors = [_pW, _pY, _pR, _pO, _pG, _pB];

  List<List<int>> _init() => List.generate(6, (i) => List.generate(n*n, (_) => i));

  void _rotateFaceCW(List<List<int>> s, int fi) {
    final f = s[fi];
    if (n == 3) {
      int t=f[0]; f[0]=f[6]; f[6]=f[8]; f[8]=f[2]; f[2]=t;
      t=f[1]; f[1]=f[3]; f[3]=f[7]; f[7]=f[5]; f[5]=t;
    } else {
      int t=f[0]; f[0]=f[2]; f[2]=f[3]; f[3]=f[1]; f[1]=t;
    }
  }

  void _rotate(List<List<int>> s, String move) {
    final isPrime = move.endsWith("'");
    final isDouble = move.endsWith('2');
    final face = move.replaceAll("'", '').replaceAll('2', '');
    final times = isDouble ? 2 : isPrime ? 3 : 1;
    for (int t = 0; t < times; t++) _doFace(s, face);
  }

  void _doFace(List<List<int>> s, String face) {
    if (n == 3) _do3(s, face);
    else _do2(s, face);
  }

  void _do3(List<List<int>> s, String face) {
    switch (face) {
      case 'U': _rotateFaceCW(s,0);
        final t=[s[2][0],s[2][1],s[2][2]];
        s[2][0]=s[4][0];s[2][1]=s[4][1];s[2][2]=s[4][2];
        s[4][0]=s[3][0];s[4][1]=s[3][1];s[4][2]=s[3][2];
        s[3][0]=s[5][0];s[3][1]=s[5][1];s[3][2]=s[5][2];
        s[5][0]=t[0];s[5][1]=t[1];s[5][2]=t[2]; break;
      case 'D': _rotateFaceCW(s,1);
        final t=[s[2][6],s[2][7],s[2][8]];
        s[2][6]=s[5][6];s[2][7]=s[5][7];s[2][8]=s[5][8];
        s[5][6]=s[3][6];s[5][7]=s[3][7];s[5][8]=s[3][8];
        s[3][6]=s[4][6];s[3][7]=s[4][7];s[3][8]=s[4][8];
        s[4][6]=t[0];s[4][7]=t[1];s[4][8]=t[2]; break;
      case 'F': _rotateFaceCW(s,2);
        final t=[s[0][6],s[0][7],s[0][8]];
        s[0][6]=s[5][8];s[0][7]=s[5][5];s[0][8]=s[5][2];
        s[5][2]=s[1][0];s[5][5]=s[1][1];s[5][8]=s[1][2];
        s[1][0]=s[4][0];s[1][1]=s[4][3];s[1][2]=s[4][6];
        s[4][0]=t[2];s[4][3]=t[1];s[4][6]=t[0]; break;
      case 'B': _rotateFaceCW(s,3);
        final t=[s[0][0],s[0][1],s[0][2]];
        s[0][0]=s[4][2];s[0][1]=s[4][5];s[0][2]=s[4][8];
        s[4][2]=s[1][8];s[4][5]=s[1][7];s[4][8]=s[1][6];
        s[1][6]=s[5][0];s[1][7]=s[5][3];s[1][8]=s[5][6];
        s[5][0]=t[2];s[5][3]=t[1];s[5][6]=t[0]; break;
      case 'R': _rotateFaceCW(s,4);
        final t=[s[0][2],s[0][5],s[0][8]];
        s[0][2]=s[2][2];s[0][5]=s[2][5];s[0][8]=s[2][8];
        s[2][2]=s[1][2];s[2][5]=s[1][5];s[2][8]=s[1][8];
        s[1][2]=s[3][6];s[1][5]=s[3][3];s[1][8]=s[3][0];
        s[3][0]=t[2];s[3][3]=t[1];s[3][6]=t[0]; break;
      case 'L': _rotateFaceCW(s,5);
        final t=[s[0][0],s[0][3],s[0][6]];
        s[0][0]=s[3][8];s[0][3]=s[3][5];s[0][6]=s[3][2];
        s[3][2]=s[1][6];s[3][5]=s[1][3];s[3][8]=s[1][0];
        s[1][0]=s[2][0];s[1][3]=s[2][3];s[1][6]=s[2][6];
        s[2][0]=t[0];s[2][3]=t[1];s[2][6]=t[2]; break;
    }
  }

  void _do2(List<List<int>> s, String face) {
    switch (face) {
      case 'U': _rotateFaceCW(s,0);
        final t=[s[2][0],s[2][1]];
        s[2][0]=s[4][0];s[2][1]=s[4][1];
        s[4][0]=s[3][0];s[4][1]=s[3][1];
        s[3][0]=s[5][0];s[3][1]=s[5][1];
        s[5][0]=t[0];s[5][1]=t[1]; break;
      case 'R': _rotateFaceCW(s,4);
        final t=[s[0][1],s[0][3]];
        s[0][1]=s[2][1];s[0][3]=s[2][3];
        s[2][1]=s[1][1];s[2][3]=s[1][3];
        s[1][1]=s[3][2];s[1][3]=s[3][0];
        s[3][0]=t[1];s[3][2]=t[0]; break;
      case 'F': _rotateFaceCW(s,2);
        final t=[s[0][2],s[0][3]];
        s[0][2]=s[5][3];s[0][3]=s[5][1];
        s[5][1]=s[1][0];s[5][3]=s[1][2];
        s[1][0]=s[4][0];s[1][2]=s[4][2];
        s[4][0]=t[1];s[4][2]=t[0]; break;
    }
  }

  List<List<int>> _compute() {
    final s = _init();
    for (final m in scramble.trim().split(RegExp(r'\s+'))) {
      if (m.isEmpty) continue;
      try { _rotate(s, m); } catch (_) {}
    }
    return s;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = _compute();
    final cell = size.width / (4 * n);
    final fs = n * cell;
    final ep = Paint()..color=_pK.withValues(alpha:0.2)..style=PaintingStyle.stroke..strokeWidth=0.5;
    final origins = [
      Offset(fs, 0), Offset(fs, fs*2), Offset(fs, fs),
      Offset(fs*3, fs), Offset(fs*2, fs), Offset(0, fs),
    ];
    for (int fi=0;fi<6;fi++) {
      final o = origins[fi];
      for (int r=0;r<n;r++) for (int c=0;c<n;c++) {
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(o.dx+c*cell+0.5, o.dy+r*cell+0.5, cell-1, cell-1),
          Radius.circular(cell*0.12));
        canvas.drawRRect(rect, Paint()..color=_colors[s[fi][r*n+c]]);
        canvas.drawRRect(rect, ep);
      }
    }
  }
  @override bool shouldRepaint(_CubeNetPainter o) => o.scramble != scramble || o.n != n;
}

// ── NxN Simulator (4x4–7x7) ────────────────────────────────────
class _NxNSimPainter extends CustomPainter {
  final String scramble;
  final int n;
  _NxNSimPainter(this.scramble, this.n);
  static const _colors = [_pW, _pY, _pR, _pO, _pG, _pB];

  List<List<int>> _init() => List.generate(6, (i) => List.filled(n * n, i));

  // Get row from face as list (left→right)
  List<int> _row(List<List<int>> s, int fi, int r) =>
      [for (var c = 0; c < n; c++) s[fi][r * n + c]];

  // Set row on face
  void _setRow(List<List<int>> s, int fi, int r, List<int> d) {
    for (var c = 0; c < n; c++) s[fi][r * n + c] = d[c];
  }

  // Get column from face as list (top→bottom)
  List<int> _col(List<List<int>> s, int fi, int c) =>
      [for (var r = 0; r < n; r++) s[fi][r * n + c]];

  // Set column on face
  void _setCol(List<List<int>> s, int fi, int c, List<int> d) {
    for (var r = 0; r < n; r++) s[fi][r * n + c] = d[r];
  }

  // Rotate a face clockwise (idx 0-5)
  void _rotateFace(List<List<int>> s, int fi) {
    final f = s[fi];
    for (var layer = 0; layer < n ~/ 2; layer++) {
      var first = layer;
      var last = n - 1 - layer;
      for (var i = first; i < last; i++) {
        var offset = i - first;
        var t = f[first * n + i];
        f[first * n + i] = f[(last - offset) * n + first];
        f[(last - offset) * n + first] = f[last * n + (last - offset)];
        f[last * n + (last - offset)] = f[i * n + last];
        f[i * n + last] = t;
      }
    }
  }

  // R axis: U.col(n-1-i) ↔ F.col(n-1-i) ↔ D.col(n-1-i) ↔ B.col(i) rev
  void _rSlice(List<List<int>> s, int i) {
    var ci = n - 1 - i;
    var tmp = _col(s, 0, ci);
    _setCol(s, 0, ci, _col(s, 2, ci));
    _setCol(s, 2, ci, _col(s, 1, ci));
    _setCol(s, 1, ci, _col(s, 3, i).reversed.toList());
    _setCol(s, 3, i, tmp.reversed.toList());
  }

  // L axis: U.col(i) ↔ B.col(n-1-i) rev ↔ D.col(i) rev ↔ F.col(i)
  void _lSlice(List<List<int>> s, int i) {
    var ci = i;
    var tmp = _col(s, 0, ci);
    _setCol(s, 0, ci, _col(s, 3, n - 1 - i).reversed.toList());
    _setCol(s, 3, n - 1 - i, _col(s, 1, ci).reversed.toList());
    _setCol(s, 1, ci, _col(s, 2, ci));
    _setCol(s, 2, ci, tmp);
  }

  // U axis: F.row(i) ↔ R.row(i) ↔ B.row(i) ↔ L.row(i)
  void _uSlice(List<List<int>> s, int i) {
    var ri = i;
    var tmp = _row(s, 2, ri);
    _setRow(s, 2, ri, _row(s, 4, ri));
    _setRow(s, 4, ri, _row(s, 3, ri));
    _setRow(s, 3, ri, _row(s, 5, ri));
    _setRow(s, 5, ri, tmp);
  }

  // D axis: F.row(n-1-i) ↔ L.row(n-1-i) ↔ B.row(n-1-i) ↔ R.row(n-1-i)
  void _dSlice(List<List<int>> s, int i) {
    var ri = n - 1 - i;
    var tmp = _row(s, 2, ri);
    _setRow(s, 2, ri, _row(s, 5, ri));
    _setRow(s, 5, ri, _row(s, 3, ri));
    _setRow(s, 3, ri, _row(s, 4, ri));
    _setRow(s, 4, ri, tmp);
  }

  // F axis: U.row(n-1-i) ↔ L.col(n-1-i) rev ↔ D.row(i) ↔ R.col(i)
  void _fSlice(List<List<int>> s, int i) {
    var uRow = n - 1 - i;
    var dRow = i;
    var rCol = i;
    var lCol = n - 1 - i;
    var tmp = _row(s, 0, uRow);
    _setRow(s, 0, uRow, _col(s, 5, lCol).reversed.toList());
    _setCol(s, 5, lCol, _row(s, 1, dRow));
    _setRow(s, 1, dRow, _col(s, 4, rCol));
    _setCol(s, 4, rCol, tmp.reversed.toList());
  }

  // B axis: U.row(i) ↔ R.col(n-1-i) rev ↔ D.row(n-1-i) rev ↔ L.col(i)
  void _bSlice(List<List<int>> s, int i) {
    var uRow = i;
    var dRow = n - 1 - i;
    var rCol = n - 1 - i;
    var lCol = i;
    var tmp = _row(s, 0, uRow);
    _setRow(s, 0, uRow, _col(s, 4, rCol).reversed.toList());
    _setCol(s, 4, rCol, _row(s, 1, dRow).reversed.toList());
    _setRow(s, 1, dRow, _col(s, 5, lCol));
    _setCol(s, 5, lCol, tmp.reversed.toList());
  }

  void _apply(List<List<int>> s, String move) {
    var m = move;
    var isPrime = m.endsWith("'");
    var isDouble = m.endsWith('2');
    if (isPrime) m = m.substring(0, m.length - 1);
    if (isDouble) m = m.substring(0, m.length - 1);

    int layers;
    String face;
    if (m.endsWith('w')) {
      var prefix = m.substring(0, m.length - 1);
      if (prefix.length == 1) {
        layers = 2;
        face = prefix;
      } else {
        face = prefix.substring(prefix.length - 1);
        layers = int.parse(prefix.substring(0, prefix.length - 1));
      }
    } else {
      layers = 1;
      face = m;
    }
    if (layers > n) layers = n;

    void turn() {
      for (var i = 0; i < layers; i++) {
        switch (face) {
          case 'R': _rSlice(s, i); break;
          case 'L': _lSlice(s, i); break;
          case 'U': _uSlice(s, i); break;
          case 'D': _dSlice(s, i); break;
          case 'F': _fSlice(s, i); break;
          case 'B': _bSlice(s, i); break;
        }
      }
      if (layers > 0) _rotateFace(s, _faceIdx(face));
    }

    turn();
    if (isDouble) turn();
    if (isPrime) { turn(); turn(); }
  }

  int _faceIdx(String f) => switch (f) {
    'U' => 0, 'D' => 1, 'F' => 2, 'B' => 3, 'R' => 4, 'L' => 5, _ => 0,
  };

  List<List<int>> _compute() {
    var s = _init();
    for (final m in scramble.trim().split(RegExp(r'\s+'))) {
      if (m.isEmpty) continue;
      try { _apply(s, m); } catch (_) {}
    }
    return s;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var s = _compute();
    var cell = size.width / (4 * n);
    var fs = n * cell;
    var ep = Paint()
      ..color = _pK.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    var origins = [
      Offset(fs, 0),
      Offset(fs, fs * 2),
      Offset(fs, fs),
      Offset(fs * 3, fs),
      Offset(fs * 2, fs),
      Offset(0, fs),
    ];
    for (var fi = 0; fi < 6; fi++) {
      var o = origins[fi];
      for (var r = 0; r < n; r++) {
        for (var c = 0; c < n; c++) {
          var rect = RRect.fromRectAndRadius(
            Rect.fromLTWH(o.dx + c * cell + 0.5, o.dy + r * cell + 0.5,
                cell - 1, cell - 1),
            Radius.circular(cell * 0.12),
          );
          canvas.drawRRect(rect, Paint()..color = _colors[s[fi][r * n + c]]);
          canvas.drawRRect(rect, ep);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_NxNSimPainter o) =>
      o.scramble != scramble || o.n != n;
}


