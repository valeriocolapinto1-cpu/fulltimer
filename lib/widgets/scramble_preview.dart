import 'dart:math';
import 'package:flutter/material.dart';

// WCA standard colors
const _pW = Color(0xFFFAFAFA); // White
const _pY = Color(0xFFFFD500); // Yellow
const _pR = Color(0xFFBA0C2F); // Red
const _pO = Color(0xFFFF5800); // Orange
const _pG = Color(0xFF009B48); // Green
const _pB = Color(0xFF003DA5); // Blue
const _pK = Color(0xFF111111); // Black edge
const _pGy = Color(0xFF888888); // Grey (unoriented OLL)

class ScramblePreview extends StatelessWidget {
  final String scramble;
  final String eventId;
  final double size;

  const ScramblePreview({
    super.key, required this.scramble, required this.eventId, this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    switch (eventId) {
      case '3x3': case 'oh':
        return SizedBox(width: size, height: size * 0.75,
            child: CustomPaint(painter: _CubeNetPainter(scramble, 3)));
      case '2x2':
        return SizedBox(width: size * 0.75, height: size * 0.56,
            child: CustomPaint(painter: _CubeNetPainter(scramble, 2)));
      // Big cubes: show solved net with size annotation
      case '4x4':
        return SizedBox(width: size, height: size * 0.75,
            child: CustomPaint(painter: _BigCubeNetPainter(4)));
      case '5x5':
        return SizedBox(width: size, height: size * 0.75,
            child: CustomPaint(painter: _BigCubeNetPainter(5)));
      case '6x6':
        return SizedBox(width: size, height: size * 0.75,
            child: CustomPaint(painter: _BigCubeNetPainter(6)));
      case '7x7':
        return SizedBox(width: size, height: size * 0.75,
            child: CustomPaint(painter: _BigCubeNetPainter(7)));
      case 'pyra':
        return SizedBox(width: size, height: size * 0.85,
            child: CustomPaint(painter: _PyraNetPainter()));
      case 'skewb':
        return SizedBox(width: size, height: size * 0.75,
            child: CustomPaint(painter: _SkewbNetPainter()));
      case 'mega':
        return SizedBox(width: size, height: size * 0.75,
            child: CustomPaint(painter: _MegaNetPainter()));
      case 'clock':
        return SizedBox(width: size * 0.9, height: size * 0.5,
            child: CustomPaint(painter: _ClockNetPainter()));
      case 'sq1':
        return SizedBox(width: size, height: size * 0.65,
            child: CustomPaint(painter: _Sq1NetPainter()));
      default:
        return Container(
          width: size * 0.8, height: size * 0.4,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: th.dividerColor, borderRadius: BorderRadius.circular(8)),
          child: Text(eventId.toUpperCase(),
              style: th.textTheme.bodyMedium?.copyWith(fontSize: 11, fontWeight: FontWeight.w700)));
    }
  }
}

// ── 3x3 / 2x2 Net (cross layout with full move simulation) ───
class _CubeNetPainter extends CustomPainter {
  final String scramble;
  final int n;
  _CubeNetPainter(this.scramble, this.n);

  static const _colors = [_pW, _pY, _pR, _pO, _pG, _pB];

  List<List<int>> _initState() => List.generate(6, (i) => List.generate(n*n, (_) => i));

  void _rotateFaceCW(List<List<int>> s, int fi) {
    if (n == 3) {
      final f = s[fi];
      int t = f[0]; f[0]=f[6]; f[6]=f[8]; f[8]=f[2]; f[2]=t;
      t = f[1]; f[1]=f[3]; f[3]=f[7]; f[7]=f[5]; f[5]=t;
    } else { // 2x2
      final f = s[fi];
      int t = f[0]; f[0]=f[2]; f[2]=f[3]; f[3]=f[1]; f[1]=t;
    }
  }

  void _rotate(List<List<int>> s, String face, bool prime, bool double_) {
    final times = double_ ? 2 : prime ? 3 : 1;
    for (int t = 0; t < times; t++) _rotateOnce(s, face);
  }

  void _rotateOnce(List<List<int>> s, String face) {
    if (n == 3) _rotate3(s, face);
    else if (n == 2) _rotate2(s, face);
  }

  void _rotate3(List<List<int>> s, String face) {
    switch (face) {
      case 'U': _rotateFaceCW(s,0);
        final t=[s[2][0],s[2][1],s[2][2]];
        s[2][0]=s[4][0]; s[2][1]=s[4][1]; s[2][2]=s[4][2];
        s[4][0]=s[3][0]; s[4][1]=s[3][1]; s[4][2]=s[3][2];
        s[3][0]=s[5][0]; s[3][1]=s[5][1]; s[3][2]=s[5][2];
        s[5][0]=t[0]; s[5][1]=t[1]; s[5][2]=t[2]; break;
      case 'D': _rotateFaceCW(s,1);
        final t=[s[2][6],s[2][7],s[2][8]];
        s[2][6]=s[5][6]; s[2][7]=s[5][7]; s[2][8]=s[5][8];
        s[5][6]=s[3][6]; s[5][7]=s[3][7]; s[5][8]=s[3][8];
        s[3][6]=s[4][6]; s[3][7]=s[4][7]; s[3][8]=s[4][8];
        s[4][6]=t[0]; s[4][7]=t[1]; s[4][8]=t[2]; break;
      case 'F': _rotateFaceCW(s,2);
        final t=[s[0][6],s[0][7],s[0][8]];
        s[0][6]=s[5][8]; s[0][7]=s[5][5]; s[0][8]=s[5][2];
        s[5][2]=s[1][0]; s[5][5]=s[1][1]; s[5][8]=s[1][2];
        s[1][0]=s[4][0]; s[1][1]=s[4][3]; s[1][2]=s[4][6];
        s[4][0]=t[2]; s[4][3]=t[1]; s[4][6]=t[0]; break;
      case 'B': _rotateFaceCW(s,3);
        final t=[s[0][0],s[0][1],s[0][2]];
        s[0][0]=s[4][2]; s[0][1]=s[4][5]; s[0][2]=s[4][8];
        s[4][2]=s[1][8]; s[4][5]=s[1][7]; s[4][8]=s[1][6];
        s[1][6]=s[5][0]; s[1][7]=s[5][3]; s[1][8]=s[5][6];
        s[5][0]=t[2]; s[5][3]=t[1]; s[5][6]=t[0]; break;
      case 'R': _rotateFaceCW(s,4);
        final t=[s[0][2],s[0][5],s[0][8]];
        s[0][2]=s[2][2]; s[0][5]=s[2][5]; s[0][8]=s[2][8];
        s[2][2]=s[1][2]; s[2][5]=s[1][5]; s[2][8]=s[1][8];
        s[1][2]=s[3][6]; s[1][5]=s[3][3]; s[1][8]=s[3][0];
        s[3][0]=t[2]; s[3][3]=t[1]; s[3][6]=t[0]; break;
      case 'L': _rotateFaceCW(s,5);
        final t=[s[0][0],s[0][3],s[0][6]];
        s[0][0]=s[3][8]; s[0][3]=s[3][5]; s[0][6]=s[3][2];
        s[3][2]=s[1][6]; s[3][5]=s[1][3]; s[3][8]=s[1][0];
        s[1][0]=s[2][0]; s[1][3]=s[2][3]; s[1][6]=s[2][6];
        s[2][0]=t[0]; s[2][3]=t[1]; s[2][6]=t[2]; break;
    }
  }

  void _rotate2(List<List<int>> s, String face) {
    // 2x2 uses same faces as 3x3 but with 4 stickers per face
    // U=[0..3] face stickers
    switch (face) {
      case 'U': _rotateFaceCW(s,0);
        final t=[s[2][0],s[2][1]];
        s[2][0]=s[4][0]; s[2][1]=s[4][1];
        s[4][0]=s[3][0]; s[4][1]=s[3][1];
        s[3][0]=s[5][0]; s[3][1]=s[5][1];
        s[5][0]=t[0]; s[5][1]=t[1]; break;
      case 'R': _rotateFaceCW(s,4);
        final t=[s[0][1],s[0][3]];
        s[0][1]=s[2][1]; s[0][3]=s[2][3];
        s[2][1]=s[1][1]; s[2][3]=s[1][3];
        s[1][1]=s[3][2]; s[1][3]=s[3][0];
        s[3][0]=t[3]; s[3][2]=t[1]; break;
      case 'F': _rotateFaceCW(s,2);
        final t=[s[0][2],s[0][3]];
        s[0][2]=s[5][3]; s[0][3]=s[5][1];
        s[5][1]=s[1][0]; s[5][3]=s[1][2];
        s[1][0]=s[4][0]; s[1][2]=s[4][2];
        s[4][0]=t[3]; s[4][2]=t[2]; break;
    }
  }

  List<List<int>> _computeState() {
    final state = _initState();
    for (final move in scramble.trim().split(RegExp(r'\s+'))) {
      if (move.isEmpty) continue;
      final isPrime = move.endsWith("'");
      final isDouble = move.endsWith('2');
      final face = move.replaceAll("'", '').replaceAll('2', '');
      try { _rotate(state, face, isPrime, isDouble); } catch (_) {}
    }
    return state;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final state = _computeState();
    final cell = size.width / (4 * n);
    final fs = n * cell;
    final ep = Paint()..color=_pK.withValues(alpha:0.2)..style=PaintingStyle.stroke..strokeWidth=0.5;
    // Cross: [U, D, F, B, R, L]
    final origins = [
      Offset(fs, 0), Offset(fs, fs*2), Offset(fs, fs),
      Offset(fs*3, fs), Offset(fs*2, fs), Offset(0, fs),
    ];
    for (int fi = 0; fi < 6; fi++) {
      final o = origins[fi];
      for (int r = 0; r < n; r++) {
        for (int c = 0; c < n; c++) {
          final col = _colors[state[fi][r*n+c]];
          final rect = RRect.fromRectAndRadius(
            Rect.fromLTWH(o.dx+c*cell+0.5, o.dy+r*cell+0.5, cell-1, cell-1),
            Radius.circular(cell*0.12));
          canvas.drawRRect(rect, Paint()..color=col);
          canvas.drawRRect(rect, ep);
        }
      }
    }
  }
  @override bool shouldRepaint(_CubeNetPainter o) => o.scramble != scramble || o.n != n;
}

// ── Big Cube Net (4x4..7x7): show solved with grid ───────────
class _BigCubeNetPainter extends CustomPainter {
  final int n;
  _BigCubeNetPainter(this.n);
  static const _colors = [_pW, _pY, _pR, _pO, _pG, _pB];
  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / (4 * n);
    final fs = n * cell;
    final ep = Paint()..color=_pK.withValues(alpha:0.2)..style=PaintingStyle.stroke..strokeWidth=0.4;
    final origins = [
      Offset(fs, 0), Offset(fs, fs*2), Offset(fs, fs),
      Offset(fs*3, fs), Offset(fs*2, fs), Offset(0, fs),
    ];
    for (int fi = 0; fi < 6; fi++) {
      final o = origins[fi];
      for (int r = 0; r < n; r++) {
        for (int c = 0; c < n; c++) {
          final rect = RRect.fromRectAndRadius(
            Rect.fromLTWH(o.dx+c*cell+0.3, o.dy+r*cell+0.3, cell-0.6, cell-0.6),
            Radius.circular(cell*0.1));
          canvas.drawRRect(rect, Paint()..color=_colors[fi]);
          canvas.drawRRect(rect, ep);
        }
      }
    }
  }
  @override bool shouldRepaint(_BigCubeNetPainter o) => o.n != n;
}

// ── Pyraminx Net: 4 triangular faces in T layout ──────────────
// Reference: 4 faces arranged like a diamond/cross
// Each face subdivided into 9 small triangles (L4 pieces)
class _PyraNetPainter extends CustomPainter {
  static const _faceColors = [_pY, _pR, _pG, _pB]; // Front, Left, Right, Bottom

  void _drawTriangle(Canvas cv, Offset a, Offset b, Offset c, Color col, bool flipped) {
    final p = Path()..moveTo(a.dx,a.dy)..lineTo(b.dx,b.dy)..lineTo(c.dx,c.dy)..close();
    cv.drawPath(p, Paint()..color=col);
    cv.drawPath(p, Paint()..color=_pK.withValues(alpha:0.35)..style=PaintingStyle.stroke..strokeWidth=0.8);
  }

  // Draw one triangular face subdivided into 9 small triangles
  // top: apex, bl: bottom-left, br: bottom-right
  void _drawFace(Canvas cv, Offset top, Offset bl, Offset br, Color col) {
    // Divide edge into 3 equal parts
    Offset lerp(Offset a, Offset b, double t) => Offset(a.dx+(b.dx-a.dx)*t, a.dy+(b.dy-a.dy)*t);
    // Row 0 (top): 1 triangle
    // Row 1 (mid): 3 triangles
    // Row 2 (bot): 5 triangles
    for (int row = 0; row < 3; row++) {
      final t0 = row / 3.0, t1 = (row + 1) / 3.0;
      final rowBl0 = lerp(top, bl, t0), rowBr0 = lerp(top, br, t0);
      final rowBl1 = lerp(top, bl, t1), rowBr1 = lerp(top, br, t1);
      final count = 2 * row + 1;
      for (int i = 0; i < count; i++) {
        final tl = i / count.toDouble(), tr = (i + 1) / count.toDouble();
        final flipped = i.isOdd;
        Offset pa, pb, pc;
        if (!flipped) {
          pa = Offset(rowBl0.dx+(rowBr0.dx-rowBl0.dx)*tl, rowBl0.dy+(rowBr0.dy-rowBl0.dy)*tl);
          pb = Offset(rowBl1.dx+(rowBr1.dx-rowBl1.dx)*tl, rowBl1.dy+(rowBr1.dy-rowBl1.dy)*tl);
          pc = Offset(rowBl1.dx+(rowBr1.dx-rowBl1.dx)*tr, rowBl1.dy+(rowBr1.dy-rowBl1.dy)*tr);
        } else {
          pa = Offset(rowBl0.dx+(rowBr0.dx-rowBl0.dx)*tl, rowBl0.dy+(rowBr0.dy-rowBl0.dy)*tl);
          pb = Offset(rowBl1.dx+(rowBr1.dx-rowBl1.dx)*tr, rowBl1.dy+(rowBr1.dy-rowBl1.dy)*tr);
          pc = Offset(rowBl0.dx+(rowBr0.dx-rowBl0.dx)*tr, rowBl0.dy+(rowBr0.dy-rowBl0.dy)*tr);
        }
        _drawTriangle(cv, pa, pb, pc, col, flipped);
      }
    }
  }

  @override
  void paint(Canvas cv, Size sz) {
    final w=sz.width, h=sz.height;
    // Layout: 4 faces in star/T pattern
    // Front face: center-top
    final cxFront = w*0.5;
    final frontTop = Offset(cxFront, h*0.02);
    final frontBL  = Offset(w*0.15, h*0.58);
    final frontBR  = Offset(w*0.85, h*0.58);
    _drawFace(cv, frontTop, frontBL, frontBR, _faceColors[0]);

    // Left face: bottom-left (pointing down-left)
    final leftTop = frontBL;
    final leftBL  = Offset(w*0.02, h*0.98);
    final leftBR  = Offset(w*0.45, h*0.98);
    _drawFace(cv, Offset(w*0.15,h*0.58), leftBL, leftBR, _faceColors[1]);

    // Right face: bottom-right (pointing down-right)
    _drawFace(cv, frontBR, Offset(w*0.55,h*0.98), Offset(w*0.98,h*0.98), _faceColors[2]);

    // Bottom face: below center (inverted)
    _drawFace(cv, Offset(w*0.5,h*0.98), frontBL, frontBR, _faceColors[3]);
  }
  @override bool shouldRepaint(_PyraNetPainter _) => false;
}

// ── Skewb Net ─────────────────────────────────────────────────
// Each face: center diamond + 4 corner triangles
class _SkewbNetPainter extends CustomPainter {
  static const _faceColors = [_pW, _pY, _pR, _pO, _pG, _pB];

  void _drawSkewbFace(Canvas cv, Offset tl, Offset tr, Offset br, Offset bl, int fi) {
    final mt = Offset((tl.dx+tr.dx)/2, (tl.dy+tr.dy)/2);
    final mr = Offset((tr.dx+br.dx)/2, (tr.dy+br.dy)/2);
    final mb = Offset((br.dx+bl.dx)/2, (br.dy+bl.dy)/2);
    final ml = Offset((bl.dx+tl.dx)/2, (bl.dy+tl.dy)/2);
    final ep = Paint()..color=_pK.withValues(alpha:0.35)..style=PaintingStyle.stroke..strokeWidth=0.8;

    void tri(List<Offset> pts, Color col) {
      final p=Path()..moveTo(pts[0].dx,pts[0].dy)..lineTo(pts[1].dx,pts[1].dy)..lineTo(pts[2].dx,pts[2].dy)..close();
      cv.drawPath(p, Paint()..color=col); cv.drawPath(p, ep);
    }
    void quad(List<Offset> pts, Color col) {
      final p=Path()..moveTo(pts[0].dx,pts[0].dy);
      for (final pt in pts.skip(1)) p.lineTo(pt.dx,pt.dy);
      p.close();
      cv.drawPath(p, Paint()..color=col); cv.drawPath(p, ep);
    }

    final c = _faceColors[fi];
    // Center diamond in main color
    quad([mt,mr,mb,ml], c);
    // Corner triangles alternate with adjacent face colors
    tri([tl,mt,ml], _faceColors[(fi+1)%6]);
    tri([tr,mr,mt], _faceColors[(fi+2)%6]);
    tri([br,mb,mr], _faceColors[(fi+3)%6]);
    tri([bl,ml,mb], _faceColors[(fi+4)%6]);
  }

  @override
  void paint(Canvas cv, Size sz) {
    final cell = sz.width / 4;
    final origins = [
      Offset(cell, 0), Offset(cell, cell*2), Offset(cell, cell),
      Offset(cell*3, cell), Offset(cell*2, cell), Offset(0, cell),
    ];
    for (int fi=0;fi<6;fi++) {
      final o = origins[fi];
      _drawSkewbFace(cv, o, Offset(o.dx+cell,o.dy), Offset(o.dx+cell,o.dy+cell), Offset(o.dx,o.dy+cell), fi);
    }
  }
  @override bool shouldRepaint(_SkewbNetPainter _) => false;
}

// ── Clock Net: front+back side by side ────────────────────────
// Reference image shows 2 sides with 9 dials each + 4 pins
class _ClockNetPainter extends CustomPainter {
  void _drawSide(Canvas cv, Offset origin, double w, double h, bool isFront) {
    // Background
    final bgR = RRect.fromRectAndRadius(Rect.fromLTWH(origin.dx,origin.dy,w,h), Radius.circular(8));
    cv.drawRRect(bgR, Paint()..color=isFront?_pB:const Color(0xFF64B5F6));
    cv.drawRRect(bgR, Paint()..color=_pK.withValues(alpha:0.4)..style=PaintingStyle.stroke..strokeWidth=1);

    final dialR = w*0.14;
    final sp = w * 0.30;
    final startX = origin.dx + w*0.22;
    final startY = origin.dy + h*0.22;

    // 9 dials in 3x3
    for (int r=0;r<3;r++) {
      for (int c=0;c<3;c++) {
        final cx = startX + c*sp, cy = startY + r*sp*0.85;
        // Dial background
        cv.drawCircle(Offset(cx,cy), dialR, Paint()..color=const Color(0xFFEEEEEE));
        cv.drawCircle(Offset(cx,cy), dialR, Paint()..color=_pB.withValues(alpha:0.3)..style=PaintingStyle.stroke..strokeWidth=dialR*0.15);
        // Hand pointing different directions
        final angle = (r*3+c) * pi/4 - pi/2;
        cv.drawLine(Offset(cx,cy), Offset(cx+cos(angle)*dialR*0.7,cy+sin(angle)*dialR*0.7),
            Paint()..color=const Color(0xFFFF6600)..strokeWidth=dialR*0.3..strokeCap=StrokeCap.round);
        // Tip dot
        cv.drawCircle(Offset(cx+cos(angle)*dialR*0.7,cy+sin(angle)*dialR*0.7),
            dialR*0.15, Paint()..color=_pY);
        cv.drawCircle(Offset(cx,cy), dialR*0.12, Paint()..color=_pK.withValues(alpha:0.5));
      }
    }

    // 4 corner pins
    final pinR = w*0.065;
    for (int i=0;i<4;i++) {
      final px = origin.dx + (i%2==0 ? w*0.1 : w*0.9);
      final py = origin.dy + (i<2 ? h*0.12 : h*0.88);
      final isUp = i%2==0;
      cv.drawCircle(Offset(px,py), pinR, Paint()..color=isUp?const Color(0xFFEEEEEE):const Color(0xFF777777));
      cv.drawCircle(Offset(px,py), pinR, Paint()..color=_pK.withValues(alpha:0.4)..style=PaintingStyle.stroke..strokeWidth=0.7);
    }
  }

  @override
  void paint(Canvas cv, Size sz) {
    final sideW = sz.width * 0.47;
    final sideH = sz.height;
    // Front side (left)
    _drawSide(cv, Offset(0, 0), sideW, sideH, true);
    // Back side (right) - slightly lighter
    _drawSide(cv, Offset(sz.width*0.53, 0), sideW, sideH, false);
  }
  @override bool shouldRepaint(_ClockNetPainter _) => false;
}

// ── Megaminx Net ──────────────────────────────────────────────
// Reference: two groups of pentagons in flower pattern
// Each pentagon has center + 5 edge pieces
class _MegaNetPainter extends CustomPainter {
  // WCA Megaminx colors (12 faces)
  static const _megaColors = [
    _pW, _pR, _pB, _pG, _pO, _pY,
    Color(0xFF9B59B6), Color(0xFFFF69B4), Color(0xFF00CED1), Color(0xFF808080),
    Color(0xFF8B4513), Color(0xFF006400),
  ];

  List<Offset> _penta(double cx, double cy, double r, double startA) =>
    List.generate(5, (i) {
      final phi = startA + i*2*pi/5;
      return Offset(cx+cos(phi)*r, cy+sin(phi)*r);
    });

  void _drawPenta(Canvas cv, List<Offset> pts, Color col) {
    // Draw center piece (inner pentagon at 60% scale)
    final cx2 = pts.map((p)=>p.dx).reduce((a,b)=>a+b)/5;
    final cy2 = pts.map((p)=>p.dy).reduce((a,b)=>a+b)/5;

    // Outer face
    final outer = Path()..moveTo(pts[0].dx,pts[0].dy);
    for (final p in pts.skip(1)) outer.lineTo(p.dx,p.dy);
    outer.close();
    cv.drawPath(outer, Paint()..color=col);

    // Inner pentagon (center piece)
    final inner = _penta(cx2, cy2,
        sqrt(pow(pts[0].dx-cx2,2)+pow(pts[0].dy-cy2,2))*0.42,
        atan2(pts[0].dy-cy2, pts[0].dx-cx2));
    final ip = Path()..moveTo(inner[0].dx,inner[0].dy);
    for (final p in inner.skip(1)) ip.lineTo(p.dx,p.dy);
    ip.close();
    cv.drawPath(ip, Paint()..color=col.withValues(alpha:0.75));

    // Edge dividers
    final ep = Paint()..color=_pK.withValues(alpha:0.4)..style=PaintingStyle.stroke..strokeWidth=0.8;
    for (int i=0;i<5;i++) {
      cv.drawLine(Offset(cx2,cy2), pts[i], ep);
    }
    cv.drawPath(outer, ep);
    cv.drawPath(ip, ep);
  }

  @override
  void paint(Canvas cv, Size sz) {
    final cx=sz.width/2, cy=sz.height/2;
    final R = sz.width * 0.42;
    final fR = R * 0.50;

    // Top face (center)
    final topPts = _penta(cx, cy-R*0.08, fR, -pi/2);
    _drawPenta(cv, topPts, _megaColors[0]);

    // 5 surrounding faces
    for (int i=0;i<5;i++) {
      final edgeA = -pi/2 + pi/5 + i*2*pi/5;
      final p1 = topPts[i], p2 = topPts[(i+1)%5];
      final emx=(p1.dx+p2.dx)/2, emy=(p1.dy+p2.dy)/2;
      final fcx = emx + cos(edgeA)*fR*1.02;
      final fcy = emy + sin(edgeA)*fR*0.70;
      final fPts = _penta(fcx, fcy, fR*0.88, edgeA + pi/5);
      _drawPenta(cv, fPts, _megaColors[1+i]);
    }
  }
  @override bool shouldRepaint(_MegaNetPainter _) => false;
}

// ── Square-1 Net ──────────────────────────────────────────────
// Top layer: 8 pieces (4 corners + 4 edges), Middle: single strip, Bottom: 8 pieces
class _Sq1NetPainter extends CustomPainter {
  @override
  void paint(Canvas cv, Size sz) {
    final w=sz.width, h=sz.height;
    final ep = Paint()..color=_pK.withValues(alpha:0.35)..style=PaintingStyle.stroke..strokeWidth=0.8;

    void drawLayer(double cy, Color topColor, Color sideColor) {
      final r = w*0.22, layerH = h*0.32;
      final cx = w*0.5;
      // Draw as octagon with alternating wide/narrow pieces
      for (int i=0;i<8;i++) {
        final a1 = (i-0.5)*2*pi/8 - pi/2;
        final a2 = (i+0.5)*2*pi/8 - pi/2;
        final isCorner = i%2==0;
        final col = isCorner ? topColor : sideColor;
        // Outer ring piece
        final path = Path()
          ..moveTo(cx+cos(a1)*r*0.38, cy+sin(a1)*r*0.38)
          ..lineTo(cx+cos(a1)*r, cy+sin(a1)*r)
          ..lineTo(cx+cos(a2)*r, cy+sin(a2)*r)
          ..lineTo(cx+cos(a2)*r*0.38, cy+sin(a2)*r*0.38)
          ..close();
        cv.drawPath(path, Paint()..color=col);
        cv.drawPath(path, ep);
      }
      // Center
      cv.drawCircle(Offset(cx,cy), r*0.35, Paint()..color=const Color(0xFF333333));
    }

    // Top layer (W/Y)
    drawLayer(h*0.25, _pW, _pR);

    // Middle slice
    final mr = RRect.fromRectAndRadius(
      Rect.fromLTWH(w*0.18, h*0.47, w*0.64, h*0.06), Radius.circular(3));
    cv.drawRRect(mr, Paint()..color=const Color(0xFF222222));

    // Bottom layer
    drawLayer(h*0.75, _pY, _pO);
  }
  @override bool shouldRepaint(_Sq1NetPainter _) => false;
}
