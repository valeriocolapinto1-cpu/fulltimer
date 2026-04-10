import 'dart:math';
import 'package:flutter/material.dart';

// 3x3 scramble state preview (csTimer-style)
// Applies moves to a virtual cube and renders the net
class ScramblePreview extends StatelessWidget {
  final String scramble;
  final String eventId;
  final double size;

  const ScramblePreview({super.key, required this.scramble, required this.eventId, this.size = 120});

  @override
  Widget build(BuildContext context) {
    if (eventId != '3x3' && eventId != 'oh') {
      return SizedBox(width: size, height: size * 0.7,
        child: Center(child: Text('Preview\n$eventId', textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10))));
    }
    return SizedBox(width: size, height: size * 0.75,
      child: CustomPaint(painter: _CubeNetPainter(scramble)));
  }
}

class _CubeNetPainter extends CustomPainter {
  final String scramble;
  _CubeNetPainter(this.scramble);

  // Solved state colors: U=W, D=Y, F=R, B=O, R=G, L=B
  // Face index: 0=U, 1=D, 2=F, 3=B, 4=R, 5=L
  // Each face: 9 stickers [0..8] row-major top-left
  static const _solved = [
    [0,0,0,0,0,0,0,0,0], // U: white
    [1,1,1,1,1,1,1,1,1], // D: yellow
    [2,2,2,2,2,2,2,2,2], // F: red
    [3,3,3,3,3,3,3,3,3], // B: orange
    [4,4,4,4,4,4,4,4,4], // R: green
    [5,5,5,5,5,5,5,5,5], // L: blue
  ];

  static const _colors = [
    Color(0xFFFAFAFA), // 0: White  U
    Color(0xFFFFD500), // 1: Yellow D
    Color(0xFFBA0C2F), // 2: Red    F
    Color(0xFFFF5800), // 3: Orange B
    Color(0xFF009B48), // 4: Green  R
    Color(0xFF003DA5), // 5: Blue   L
  ];

  // Apply a move to the cube state
  List<List<int>> _applyMove(List<List<int>> state, String move) {
    // Deep copy
    final s = state.map((f) => List<int>.from(f)).toList();
    final isPrime = move.endsWith("'");
    final isDouble = move.endsWith('2');
    final face = move.replaceAll("'", '').replaceAll('2', '');
    final times = isDouble ? 2 : 1;
    for (int t = 0; t < times; t++) {
      _rotate(s, face, isPrime && !isDouble);
    }
    return s;
  }

  void _rotate(List<List<int>> s, String face, bool prime) {
    final n = prime ? 3 : 1;
    for (int i = 0; i < n; i++) {
      switch (face) {
        case 'U': _rotateU(s); break;
        case 'D': _rotateD(s); break;
        case 'F': _rotateF(s); break;
        case 'B': _rotateB(s); break;
        case 'R': _rotateR(s); break;
        case 'L': _rotateL(s); break;
      }
    }
  }

  // Rotate face stickers clockwise
  void _rotateFaceCW(List<List<int>> s, int fi) {
    final f = s[fi];
    final tmp = f[0]; f[0]=f[6]; f[6]=f[8]; f[8]=f[2]; f[2]=tmp;
    final tmp2 = f[1]; f[1]=f[3]; f[3]=f[7]; f[7]=f[5]; f[5]=tmp2;
  }

  void _rotateU(List<List<int>> s) {
    _rotateFaceCW(s, 0);
    final tmp = [s[2][0],s[2][1],s[2][2]];
    s[2][0]=s[4][0]; s[2][1]=s[4][1]; s[2][2]=s[4][2];
    s[4][0]=s[3][0]; s[4][1]=s[3][1]; s[4][2]=s[3][2];
    s[3][0]=s[5][0]; s[3][1]=s[5][1]; s[3][2]=s[5][2];
    s[5][0]=tmp[0];  s[5][1]=tmp[1];  s[5][2]=tmp[2];
  }

  void _rotateD(List<List<int>> s) {
    _rotateFaceCW(s, 1);
    final tmp = [s[2][6],s[2][7],s[2][8]];
    s[2][6]=s[5][6]; s[2][7]=s[5][7]; s[2][8]=s[5][8];
    s[5][6]=s[3][6]; s[5][7]=s[3][7]; s[5][8]=s[3][8];
    s[3][6]=s[4][6]; s[3][7]=s[4][7]; s[3][8]=s[4][8];
    s[4][6]=tmp[0];  s[4][7]=tmp[1];  s[4][8]=tmp[2];
  }

  void _rotateF(List<List<int>> s) {
    _rotateFaceCW(s, 2);
    final tmp = [s[0][6],s[0][7],s[0][8]];
    s[0][6]=s[5][8]; s[0][7]=s[5][5]; s[0][8]=s[5][2];
    s[5][2]=s[1][0]; s[5][5]=s[1][1]; s[5][8]=s[1][2];
    s[1][0]=s[4][0]; s[1][1]=s[4][3]; s[1][2]=s[4][6];
    s[4][0]=tmp[2];  s[4][3]=tmp[1];  s[4][6]=tmp[0];
  }

  void _rotateB(List<List<int>> s) {
    _rotateFaceCW(s, 3);
    final tmp = [s[0][0],s[0][1],s[0][2]];
    s[0][0]=s[4][2]; s[0][1]=s[4][5]; s[0][2]=s[4][8];
    s[4][2]=s[1][8]; s[4][5]=s[1][7]; s[4][8]=s[1][6];
    s[1][6]=s[5][0]; s[1][7]=s[5][3]; s[1][8]=s[5][6];
    s[5][0]=tmp[2];  s[5][3]=tmp[1];  s[5][6]=tmp[0];
  }

  void _rotateR(List<List<int>> s) {
    _rotateFaceCW(s, 4);
    final tmp = [s[0][2],s[0][5],s[0][8]];
    s[0][2]=s[2][2]; s[0][5]=s[2][5]; s[0][8]=s[2][8];
    s[2][2]=s[1][2]; s[2][5]=s[1][5]; s[2][8]=s[1][8];
    s[1][2]=s[3][6]; s[1][5]=s[3][3]; s[1][8]=s[3][0];
    s[3][0]=tmp[2];  s[3][3]=tmp[1];  s[3][6]=tmp[0];
  }

  void _rotateL(List<List<int>> s) {
    _rotateFaceCW(s, 5);
    final tmp = [s[0][0],s[0][3],s[0][6]];
    s[0][0]=s[3][8]; s[0][3]=s[3][5]; s[0][6]=s[3][2];
    s[3][2]=s[1][6]; s[3][5]=s[1][3]; s[3][8]=s[1][0];
    s[1][0]=s[2][0]; s[1][3]=s[2][3]; s[1][6]=s[2][6];
    s[2][0]=tmp[0];  s[2][3]=tmp[1];  s[2][6]=tmp[2];
  }

  List<List<int>> _computeState() {
    var state = _solved.map((f) => List<int>.from(f)).toList();
    final moves = scramble.trim().split(RegExp(r'\s+'));
    for (final move in moves) {
      if (move.isEmpty) continue;
      try { state = _applyMove(state, move); } catch (_) {}
    }
    return state;
  }

  // Draw the cube net (cross layout):
  //        U
  //    L F R B
  //        D
  @override
  void paint(Canvas canvas, Size sz) {
    final state = _computeState();
    final cellSize = sz.width / 12;
    final faceSize = cellSize * 3;

    // Offsets for cross layout
    final positions = <int, Offset>{
      0: Offset(faceSize, 0),                        // U
      1: Offset(faceSize, faceSize * 2),             // D
      2: Offset(faceSize, faceSize),                 // F
      3: Offset(faceSize * 3, faceSize),             // B
      4: Offset(faceSize * 2, faceSize),             // R
      5: Offset(0, faceSize),                        // L
    };

    final ep = Paint()..color = Colors.black.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke..strokeWidth = 0.5;

    for (final entry in positions.entries) {
      final fi = entry.key; final offset = entry.value;
      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < 3; c++) {
          final colorIdx = state[fi][r*3+c];
          final rect = Rect.fromLTWH(
            offset.dx + c*cellSize, offset.dy + r*cellSize, cellSize, cellSize);
          canvas.drawRect(rect, Paint()..color = _colors[colorIdx]);
          canvas.drawRect(rect, ep);
        }
      }
    }
  }

  @override bool shouldRepaint(_CubeNetPainter o) => o.scramble != scramble;
}
