import 'dart:math';
import 'package:flutter/material.dart';

// WCA standard colors
const _W = Color(0xFFFAFAFA);
const _Y = Color(0xFFFFD500);
const _R = Color(0xFFBA0C2F);
const _O = Color(0xFFFF5800);
const _G = Color(0xFF009B48);
const _B = Color(0xFF003DA5);
const _K = Color(0xFF111111);
const _Pk = Color(0xFFFF69B4);
const _Pu = Color(0xFF9B59B6);

const _wcaColors = <String, List<Color>>{
  '3x3':  [_W, _R, _G, _Y, _O, _B],
  'oh':   [_W, _R, _G, _Y, _O, _B],
  '2x2':  [_W, _R, _G, _Y, _O, _B],
  '4x4':  [_W, _R, _G, _Y, _O, _B],
  '5x5':  [_W, _R, _G, _Y, _O, _B],
  '6x6':  [_W, _R, _G, _Y, _O, _B],
  '7x7':  [_W, _R, _G, _Y, _O, _B],
  'sq1':  [_W, _R, _G, _Y, _O, _B],
};

Widget eventCube(String eventId, {double size = 26}) {
  if (eventId == 'mega')  return _MegaSpinner(key: ValueKey('mega_$size'), size: size);
  if (eventId == 'pyra')  return _PyraSpinner(key: ValueKey('pyra_$size'), size: size);
  if (eventId == 'clock') return _ClockSpinner(key: ValueKey('clock_$size'), size: size);
  if (eventId == 'skewb') return _SkewbSpinner(key: ValueKey('skewb_$size'), size: size);
  final cols = _wcaColors[eventId] ?? _wcaColors['3x3']!;
  return _CubeSpinner(key: ValueKey('${eventId}_$size'), size: size, cols: cols, n: _gridN(eventId));
}

int _gridN(String id) {
  switch (id) {
    case '2x2': return 2; case '4x4': return 4; case '5x5': return 5;
    case '6x6': return 6; case '7x7': return 7; default: return 3;
  }
}

mixin SpinMixin<T extends StatefulWidget> on State<T>, SingleTickerProviderStateMixin<T> {
  late final AnimationController spinCtrl;
  int get spinSeconds => 5;
  @override void initState() {
    super.initState();
    spinCtrl = AnimationController(vsync: this, duration: Duration(seconds: spinSeconds))..repeat();
  }
  @override void dispose() { spinCtrl.dispose(); super.dispose(); }
}

// ── NxN Cube ─────────────────────────────────────────────────
class _CubeSpinner extends StatefulWidget {
  final double size; final List<Color> cols; final int n;
  const _CubeSpinner({super.key, required this.size, required this.cols, required this.n});
  @override State<_CubeSpinner> createState() => _CubeSpinnerState();
}
class _CubeSpinnerState extends State<_CubeSpinner>
    with SingleTickerProviderStateMixin, SpinMixin {
  @override Widget build(BuildContext context) => AnimatedBuilder(
    animation: spinCtrl,
    builder: (_, __) => SizedBox(width: widget.size, height: widget.size,
      child: CustomPaint(painter: _CubePainter(spinCtrl.value * 2 * pi, widget.cols, widget.n))));
}

class _CubePainter extends CustomPainter {
  final double a; final List<Color> c; final int n;
  _CubePainter(this.a, this.c, this.n);

  Offset _p(double x, double y, double z, double s, double cx, double cy) {
    final ca = cos(a), sa = sin(a);
    final rx = x*ca - z*sa, rz = x*sa + z*ca;
    return Offset(rx * cos(0.42) * s + cx, (-y*0.88 - rz*sin(0.33)) * s + cy);
  }

  bool _front(List<Offset> p) {
    final v1 = p[1]-p[0], v2 = p[2]-p[0];
    return v1.dx*v2.dy - v1.dy*v2.dx < 0;
  }

  void _face(Canvas cv, List<Offset> pts, Color col) {
    if (!_front(pts)) return;
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (final p in pts.skip(1)) path.lineTo(p.dx, p.dy);
    path.close();
    cv.drawPath(path, Paint()..color = col);
    cv.drawPath(path, Paint()
      ..color = _K.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke..strokeWidth = 0.9..strokeJoin = StrokeJoin.round);
    if (n > 1) {
      final gp = Paint()..color = _K.withValues(alpha: 0.22)..strokeWidth = 0.45;
      for (int i = 1; i < n; i++) {
        final t = i/n;
        cv.drawLine(Offset.lerp(pts[0],pts[1],t)!, Offset.lerp(pts[3],pts[2],t)!, gp);
        cv.drawLine(Offset.lerp(pts[0],pts[3],t)!, Offset.lerp(pts[1],pts[2],t)!, gp);
      }
    }
  }

  @override void paint(Canvas cv, Size sz) {
    final s = sz.width*0.37, cx = sz.width/2, cy = sz.height*0.54;
    final v = [
      _p(-1, 1,-1,s,cx,cy), _p(1, 1,-1,s,cx,cy), _p(1,-1,-1,s,cx,cy), _p(-1,-1,-1,s,cx,cy),
      _p(-1, 1, 1,s,cx,cy), _p(1, 1, 1,s,cx,cy), _p(1,-1, 1,s,cx,cy), _p(-1,-1, 1,s,cx,cy),
    ];
    final faces = [
      ([v[4],v[5],v[1],v[0]], c[0]),
      ([v[0],v[1],v[2],v[3]], c[1]),
      ([v[1],v[5],v[6],v[2]], c[2]),
      ([v[3],v[2],v[6],v[7]], c[3]),
      ([v[5],v[4],v[7],v[6]], c[4]),
      ([v[4],v[0],v[3],v[7]], c[5]),
    ];
    faces.sort((a,b) {
      final da = a.$1.map((p)=>p.dy).reduce((x,y)=>x+y);
      final db = b.$1.map((p)=>p.dy).reduce((x,y)=>x+y);
      return db.compareTo(da);
    });
    for (final f in faces) _face(cv, f.$1, f.$2);
  }
  @override bool shouldRepaint(_CubePainter o) => o.a != a;
}

// ── Skewb: cube body with 8 large corner pieces ───────────────
// Real Skewb: looks like a cube but each face has 1 center + 4 corner triangles
// The cuts go diagonally from one corner to the opposite corner
class _SkewbSpinner extends StatefulWidget {
  final double size;
  const _SkewbSpinner({super.key, required this.size});
  @override State<_SkewbSpinner> createState() => _SkewbSpinnerState();
}
class _SkewbSpinnerState extends State<_SkewbSpinner>
    with SingleTickerProviderStateMixin, SpinMixin {
  @override int get spinSeconds => 6;
  @override Widget build(BuildContext context) => AnimatedBuilder(
    animation: spinCtrl,
    builder: (_, __) => SizedBox(width: widget.size, height: widget.size,
      child: CustomPaint(painter: _SkewbPainter(spinCtrl.value * 2 * pi))));
}

class _SkewbPainter extends CustomPainter {
  final double a;
  _SkewbPainter(this.a);

  Offset _p(double x, double y, double z, double s, double cx, double cy) {
    final ca = cos(a), sa = sin(a);
    final rx = x*ca - z*sa, rz = x*sa + z*ca;
    return Offset(rx*cos(0.42)*s+cx, (-y*0.88-rz*sin(0.33))*s+cy);
  }

  bool _front(List<Offset> pts) {
    final v1 = pts[1]-pts[0], v2 = pts[2]-pts[0];
    return v1.dx*v2.dy - v1.dy*v2.dx < 0;
  }

  void _drawPoly(Canvas cv, List<Offset> pts, Color col) {
    if (pts.length >= 3) {
      // backface cull using first 3 points
      final v1 = pts[1]-pts[0], v2 = pts[2]-pts[0];
      if (v1.dx*v2.dy - v1.dy*v2.dx > 0) return;
    }
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (final p in pts.skip(1)) path.lineTo(p.dx, p.dy);
    path.close();
    cv.drawPath(path, Paint()..color = col);
    cv.drawPath(path, Paint()..color=_K.withValues(alpha:0.5)..style=PaintingStyle.stroke..strokeWidth=0.8);
  }

  // Draw one face split into center diamond + 4 corner triangles
  void _skewbFace(Canvas cv, Offset tl, Offset tr, Offset br, Offset bl,
      Color center, Color c1, Color c2, Color c3, Color c4) {
    if (!_front([tl,tr,br,bl])) return;
    // Midpoints of each edge
    final mt = Offset((tl.dx+tr.dx)/2, (tl.dy+tr.dy)/2);
    final mr = Offset((tr.dx+br.dx)/2, (tr.dy+br.dy)/2);
    final mb = Offset((br.dx+bl.dx)/2, (br.dy+bl.dy)/2);
    final ml = Offset((bl.dx+tl.dx)/2, (bl.dy+tl.dy)/2);
    // Center diamond (rotated square)
    _drawPoly(cv, [mt,mr,mb,ml], center);
    // 4 corner triangles
    _drawPoly(cv, [tl,mt,ml], c1);
    _drawPoly(cv, [tr,mr,mt], c2);
    _drawPoly(cv, [br,mb,mr], c3);
    _drawPoly(cv, [bl,ml,mb], c4);
  }

  @override void paint(Canvas cv, Size sz) {
    final s = sz.width*0.37, cx = sz.width/2, cy = sz.height*0.54;
    final v = [
      _p(-1, 1,-1,s,cx,cy), _p(1, 1,-1,s,cx,cy), _p(1,-1,-1,s,cx,cy), _p(-1,-1,-1,s,cx,cy),
      _p(-1, 1, 1,s,cx,cy), _p(1, 1, 1,s,cx,cy), _p(1,-1, 1,s,cx,cy), _p(-1,-1, 1,s,cx,cy),
    ];
    // U face: white center, corners cycle through adjacent colors
    _skewbFace(cv, v[4],v[5],v[1],v[0], _W, _G,_B,_R,_O);
    // F face: red center
    _skewbFace(cv, v[0],v[1],v[2],v[3], _R, _W,_G,_Y,_B);
    // R face: green center
    _skewbFace(cv, v[1],v[5],v[6],v[2], _G, _W,_O,_Y,_R);
  }
  @override bool shouldRepaint(_SkewbPainter o) => o.a != a;
}

// ── Megaminx: Dodecahedron with 12 pentagonal faces ───────────
// Correct geometry: 12 faces, each pentagon with 5 triangular sectors around center
class _MegaSpinner extends StatefulWidget {
  final double size;
  const _MegaSpinner({super.key, required this.size});
  @override State<_MegaSpinner> createState() => _MegaSpinnerState();
}
class _MegaSpinnerState extends State<_MegaSpinner>
    with SingleTickerProviderStateMixin, SpinMixin {
  @override int get spinSeconds => 8;
  @override Widget build(BuildContext context) => AnimatedBuilder(
    animation: spinCtrl,
    builder: (_, __) => SizedBox(width: widget.size, height: widget.size,
      child: CustomPaint(painter: _MegaPainter(spinCtrl.value * 2 * pi))));
}

class _MegaPainter extends CustomPainter {
  final double a;
  _MegaPainter(this.a);

  // WCA Megaminx face colors (12 faces)
  static const _megaFaceColors = [
    _W,   // 0: top
    _R,   // 1: front
    _B,   // 2: front-right
    _Pu,  // 3: right
    _Pk,  // 4: back-right
    _O,   // 5: back
    _Y,   // 6: bottom
    _G,   // 7: front-bottom
    _B,   // 8
    _R,   // 9
    _G,   // 10
    _W,   // 11
  ];

  // Generate pentagon vertices
  List<Offset> _penta(double cx, double cy, double r, double startAngle) =>
    List.generate(5, (i) {
      final phi = startAngle + i * 2 * pi / 5;
      return Offset(cx + cos(phi)*r, cy + sin(phi)*r);
    });

  void _drawPenta(Canvas cv, List<Offset> pts, Color col, {double edgeAlpha = 0.45}) {
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (final p in pts.skip(1)) path.lineTo(p.dx, p.dy);
    path.close();
    cv.drawPath(path, Paint()..color = col);
    cv.drawPath(path, Paint()
      ..color = _K.withValues(alpha: edgeAlpha)
      ..style = PaintingStyle.stroke..strokeWidth = 0.9);
    // Draw inner star pattern (megaminx has pieces inside each face)
    final cx2 = pts.map((p)=>p.dx).reduce((a,b)=>a+b)/5;
    final cy2 = pts.map((p)=>p.dy).reduce((a,b)=>a+b)/5;
    final innerR = sqrt(pow(pts[0].dx-cx2,2)+pow(pts[0].dy-cy2,2)) * 0.45;
    final ep = Paint()..color=_K.withValues(alpha:0.18)..strokeWidth=0.5..style=PaintingStyle.stroke;
    for (int i=0;i<5;i++) {
      cv.drawLine(Offset(cx2,cy2), pts[i], ep);
    }
  }

  @override void paint(Canvas cv, Size sz) {
    final cx = sz.width/2, cy = sz.height/2;
    final R = sz.width * 0.44;
    final faceR = R * 0.52;

    // Top face
    final topAngle = a - pi/2;
    final topPts = _penta(cx, cy - R*0.14, faceR, topAngle);
    _drawPenta(cv, topPts, _megaFaceColors[0]);

    // 5 upper surrounding faces
    for (int i=0;i<5;i++) {
      final edgeAngle = topAngle + pi/5 + i*2*pi/5;
      // Share edge with top face
      final p1 = topPts[i];
      final p2 = topPts[(i+1)%5];
      final edgeMidX = (p1.dx+p2.dx)/2, edgeMidY = (p1.dy+p2.dy)/2;
      // Face center: project outward from edge midpoint
      final outAngle = edgeAngle;
      final fcx = edgeMidX + cos(outAngle)*faceR*1.05;
      final fcy = edgeMidY + sin(outAngle)*faceR*0.72;
      final faceAngle = outAngle + pi/5 + a*0.08;
      final facePts = _penta(fcx, fcy, faceR*0.85, faceAngle);
      _drawPenta(cv, facePts, _megaFaceColors[1+i].withValues(alpha: 0.92));
    }
  }
  @override bool shouldRepaint(_MegaPainter o) => o.a != a;
}

// ── Pyraminx: Tetrahedron ─────────────────────────────────────
class _PyraSpinner extends StatefulWidget {
  final double size;
  const _PyraSpinner({super.key, required this.size});
  @override State<_PyraSpinner> createState() => _PyraSpinnerState();
}
class _PyraSpinnerState extends State<_PyraSpinner>
    with SingleTickerProviderStateMixin, SpinMixin {
  @override Widget build(BuildContext context) => AnimatedBuilder(
    animation: spinCtrl,
    builder: (_, __) => SizedBox(width: widget.size, height: widget.size,
      child: CustomPaint(painter: _PyraPainter(spinCtrl.value * 2 * pi))));
}

class _PyraPainter extends CustomPainter {
  final double a;
  _PyraPainter(this.a);

  Offset _p(double x, double y, double z, double s, double cx, double cy) {
    final ca=cos(a), sa=sin(a), rx=x*ca-z*sa, rz=x*sa+z*ca;
    return Offset(rx*0.92*s+cx, (-y-rz*0.42)*s+cy);
  }

  @override void paint(Canvas cv, Size sz) {
    final s=sz.width*0.40, cx=sz.width/2, cy=sz.height*0.62;
    final apex = _p(0, 1.3, 0, s, cx, cy);
    final bl   = _p(-1,-0.43,-0.577,s,cx,cy);
    final br   = _p( 1,-0.43,-0.577,s,cx,cy);
    final bk   = _p( 0,-0.43, 1.155,s,cx,cy);
    final faces = [
      ([apex,br,bl], _Y),
      ([apex,bl,bk], _R),
      ([apex,bk,br], _G),
      ([bl, br, bk], _B),
    ];
    faces.sort((fa,fb) {
      final da = fa.$1.map((p)=>p.dy).reduce((x,y)=>x+y);
      final db = fb.$1.map((p)=>p.dy).reduce((x,y)=>x+y);
      return db.compareTo(da);
    });
    final ep = Paint()..color=_K.withValues(alpha:0.5)..style=PaintingStyle.stroke..strokeWidth=1.0;
    for (final f in faces) {
      final pts=f.$1; final v1=pts[1]-pts[0]; final v2=pts[2]-pts[0];
      if (v1.dx*v2.dy-v1.dy*v2.dx>0) continue;
      final p=Path()..moveTo(pts[0].dx,pts[0].dy)..lineTo(pts[1].dx,pts[1].dy)..lineTo(pts[2].dx,pts[2].dy)..close();
      cv.drawPath(p, Paint()..color=f.$2);
      cv.drawPath(p, ep);
    }
  }
  @override bool shouldRepaint(_PyraPainter o) => o.a != a;
}

// ── Clock: disc with 9 clock faces and 4 corner pins ─────────
// Correct geometry: flat disc with 3x3 grid of clock dials + 4 corner pins
class _ClockSpinner extends StatefulWidget {
  final double size;
  const _ClockSpinner({super.key, required this.size});
  @override State<_ClockSpinner> createState() => _ClockSpinnerState();
}
class _ClockSpinnerState extends State<_ClockSpinner>
    with SingleTickerProviderStateMixin, SpinMixin {
  @override int get spinSeconds => 10;
  @override Widget build(BuildContext context) => AnimatedBuilder(
    animation: spinCtrl,
    builder: (_, __) => SizedBox(width: widget.size, height: widget.size,
      child: CustomPaint(painter: _ClockPainter(spinCtrl.value))));
}

class _ClockPainter extends CustomPainter {
  final double t;
  _ClockPainter(this.t);

  void _drawDial(Canvas cv, Offset center, double r, double handAngle) {
    // Dial background
    cv.drawCircle(center, r, Paint()..color=const Color(0xFFF0F0F0));
    cv.drawCircle(center, r, Paint()..color=_B.withValues(alpha:0.15)..style=PaintingStyle.stroke..strokeWidth=r*0.15);
    // 12 hour dots
    for (int i=0;i<12;i++) {
      final phi = i*2*pi/12 - pi/2;
      final dotR = r*0.08;
      final dotPos = Offset(center.dx+cos(phi)*r*0.82, center.dy+sin(phi)*r*0.82);
      cv.drawCircle(dotPos, dotR, Paint()..color=_K.withValues(alpha:0.4));
    }
    // Hour hand (blue like real WCA clock)
    cv.drawLine(center, Offset(center.dx+cos(handAngle)*r*0.65, center.dy+sin(handAngle)*r*0.65),
        Paint()..color=_B..strokeWidth=r*0.2..strokeCap=StrokeCap.round);
    // Center dot
    cv.drawCircle(center, r*0.1, Paint()..color=_K.withValues(alpha:0.6));
  }

  @override void paint(Canvas cv, Size sz) {
    final cx=sz.width/2, cy=sz.height/2;
    final discR = sz.width*0.47;

    // Outer disc (blue body like reference image)
    cv.drawCircle(Offset(cx,cy), discR, Paint()..color=_B);
    cv.drawCircle(Offset(cx,cy), discR, Paint()..color=_K.withValues(alpha:0.5)..style=PaintingStyle.stroke..strokeWidth=sz.width*0.05);

    // 9 clock dials in 3x3 grid
    final dialR = discR * 0.28;
    final spacing = discR * 0.62;
    for (int row=0;row<3;row++) {
      for (int col=0;col<3;col++) {
        final dx = cx + (col-1)*spacing;
        final dy = cy + (row-1)*spacing;
        // Each dial has different hand angle (simulating scrambled state)
        final handAngle = t*2*pi + (row*3+col)*pi/4 - pi/2;
        _drawDial(cv, Offset(dx,dy), dialR, handAngle);
      }
    }

    // 4 corner pins (white cylindrical buttons)
    final pinDist = discR * 0.76;
    for (int i=0;i<4;i++) {
      final phi = pi/4 + i*pi/2;
      final px = cx + cos(phi)*pinDist;
      final py = cy + sin(phi)*pinDist;
      final isUp = ((t * 2).floor() + i) % 2 == 0;
      cv.drawCircle(Offset(px,py), sz.width*0.065,
          Paint()..color = isUp ? const Color(0xFFEEEEEE) : const Color(0xFF888888));
      cv.drawCircle(Offset(px,py), sz.width*0.065,
          Paint()..color=_K.withValues(alpha:0.4)..style=PaintingStyle.stroke..strokeWidth=0.8);
    }
  }
  @override bool shouldRepaint(_ClockPainter o) => o.t != t;
}
