// ignore_for_file: constant_identifier_names

import 'dart:math';
import 'package:flutter/material.dart';

// WCA standard colors
const _W = Color(0xFFFAFAFA); // White  - U face
const _Y = Color(0xFFFFD500); // Yellow - D face
const _R = Color(0xFFBA0C2F); // Red    - F face
const _O = Color(0xFFFF5800); // Orange - B face
const _G = Color(0xFF009B48); // Green  - R face
const _B = Color(0xFF003DA5); // Blue   - L face
const _K = Color(0xFF111111); // Edge black

// WCA face order: [U, F, R, D, B, L]
const _wcaColors = <String, List<Color>>{
  '3x3': [_W, _R, _G, _Y, _O, _B],
  'oh': [_W, _R, _G, _Y, _O, _B],
  '2x2': [_W, _R, _G, _Y, _O, _B],
  '4x4': [_W, _R, _G, _Y, _O, _B],
  '5x5': [_W, _R, _G, _Y, _O, _B],
  '6x6': [_W, _R, _G, _Y, _O, _B],
  '7x7': [_W, _R, _G, _Y, _O, _B],
  'sq1': [_W, _R, _G, _Y, _O, _B],
};

Widget eventCube(String eventId, {double size = 26}) {
  if (eventId == 'mega')
    return _MegaSpinner(key: ValueKey('mega_$size'), size: size);
  if (eventId == 'pyra')
    return _PyraSpinner(key: ValueKey('pyra_$size'), size: size);
  if (eventId == 'clock')
    return _ClockSpinner(key: ValueKey('clock_$size'), size: size);
  if (eventId == 'skewb')
    return _SkewbSpinner(key: ValueKey('skewb_$size'), size: size);
  final cols = _wcaColors[eventId] ?? _wcaColors['3x3']!;
  final n = _gridN(eventId);
  return _CubeSpinner(
      key: ValueKey('${eventId}_$size'), size: size, cols: cols, n: n);
}

int _gridN(String id) {
  switch (id) {
    case '2x2':
      return 2;
    case '4x4':
      return 4;
    case '5x5':
      return 5;
    case '6x6':
      return 6;
    case '7x7':
      return 7;
    default:
      return 3;
  }
}

// ── Shared spin mixin ─────────────────────────────────────────
mixin SpinMixin<T extends StatefulWidget>
    on State<T>, SingleTickerProviderStateMixin<T> {
  late final AnimationController spinCtrl;
  int get spinSeconds => 5;
  @override
  void initState() {
    super.initState();
    spinCtrl = AnimationController(
        vsync: this, duration: Duration(seconds: spinSeconds))
      ..repeat();
  }

  @override
  void dispose() {
    spinCtrl.dispose();
    super.dispose();
  }
}

// ── NxN Cube ──────────────────────────────────────────────────
class _CubeSpinner extends StatefulWidget {
  final double size;
  final List<Color> cols;
  final int n;
  const _CubeSpinner(
      {super.key, required this.size, required this.cols, required this.n});
  @override
  State<_CubeSpinner> createState() => _CubeSpinnerState();
}

class _CubeSpinnerState extends State<_CubeSpinner>
    with SingleTickerProviderStateMixin, SpinMixin {
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: spinCtrl,
      builder: (_, __) => SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
              painter: _CubePainter(
                  spinCtrl.value * 2 * pi, widget.cols, widget.n))));
}

class _CubePainter extends CustomPainter {
  final double a;
  final List<Color> c;
  final int n;
  _CubePainter(this.a, this.c, this.n);

  Offset _p(double x, double y, double z, double s, double cx, double cy) {
    final ca = cos(a), sa = sin(a);
    final rx = x * ca - z * sa, rz = x * sa + z * ca;
    return Offset(
        rx * cos(0.42) * s + cx, (-y * 0.88 - rz * sin(0.33)) * s + cy);
  }

  bool _front(List<Offset> p) {
    final v1 = p[1] - p[0], v2 = p[2] - p[0];
    return v1.dx * v2.dy - v1.dy * v2.dx < 0;
  }

  void _face(Canvas cv, List<Offset> pts, Color col) {
    if (!_front(pts)) return;
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    path.close();
    cv.drawPath(path, Paint()..color = col);
    cv.drawPath(
        path,
        Paint()
          ..color = _K.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9
          ..strokeJoin = StrokeJoin.round);
    if (n > 1) {
      final gp = Paint()
        ..color = _K.withValues(alpha: 0.22)
        ..strokeWidth = 0.45;
      for (int i = 1; i < n; i++) {
        final t = i / n;
        cv.drawLine(Offset.lerp(pts[0], pts[1], t)!,
            Offset.lerp(pts[3], pts[2], t)!, gp);
        cv.drawLine(Offset.lerp(pts[0], pts[3], t)!,
            Offset.lerp(pts[1], pts[2], t)!, gp);
      }
    }
  }

  @override
  void paint(Canvas cv, Size sz) {
    final s = sz.width * 0.37, cx = sz.width / 2, cy = sz.height * 0.54;
    final v = [
      _p(-1, 1, -1, s, cx, cy),
      _p(1, 1, -1, s, cx, cy),
      _p(1, -1, -1, s, cx, cy),
      _p(-1, -1, -1, s, cx, cy),
      _p(-1, 1, 1, s, cx, cy),
      _p(1, 1, 1, s, cx, cy),
      _p(1, -1, 1, s, cx, cy),
      _p(-1, -1, 1, s, cx, cy),
    ];
    // U, F, R, D, B, L
    final faces = [
      ([v[4], v[5], v[1], v[0]], c[0]),
      ([v[0], v[1], v[2], v[3]], c[1]),
      ([v[1], v[5], v[6], v[2]], c[2]),
      ([v[3], v[2], v[6], v[7]], c[3]),
      ([v[5], v[4], v[7], v[6]], c[4]),
      ([v[4], v[0], v[3], v[7]], c[5]),
    ];
    faces.sort((a, b) {
      final da = a.$1.map((p) => p.dy).reduce((x, y) => x + y);
      final db = b.$1.map((p) => p.dy).reduce((x, y) => x + y);
      return db.compareTo(da);
    });
    for (final f in faces) {
      _face(cv, f.$1, f.$2);
    }
  }

  @override
  bool shouldRepaint(_CubePainter o) => o.a != a;
}

// ── Skewb: cube shape with diagonal cuts on each face ────────
class _SkewbSpinner extends StatefulWidget {
  final double size;
  const _SkewbSpinner({super.key, required this.size});
  @override
  State<_SkewbSpinner> createState() => _SkewbSpinnerState();
}

class _SkewbSpinnerState extends State<_SkewbSpinner>
    with SingleTickerProviderStateMixin, SpinMixin {
  @override
  int get spinSeconds => 6;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: spinCtrl,
      builder: (_, __) => SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(painter: _SkewbPainter(spinCtrl.value * 2 * pi))));
}

class _SkewbPainter extends CustomPainter {
  final double a;
  _SkewbPainter(this.a);

  Offset _p(double x, double y, double z, double s, double cx, double cy) {
    final ca = cos(a), sa = sin(a), rx = x * ca - z * sa, rz = x * sa + z * ca;
    return Offset(
        rx * cos(0.42) * s + cx, (-y * 0.88 - rz * sin(0.33)) * s + cy);
  }

  bool _front(List<Offset> pts) {
    final v1 = pts[1] - pts[0], v2 = pts[2] - pts[0];
    return v1.dx * v2.dy - v1.dy * v2.dx < 0;
  }

  void _tri(Canvas cv, Offset p0, Offset p1, Offset p2, Color col) {
    final path = Path()
      ..moveTo(p0.dx, p0.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();
    cv.drawPath(path, Paint()..color = col);
    cv.drawPath(
        path,
        Paint()
          ..color = _K.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7);
  }

  void _skewbFace(
      Canvas cv, List<Offset> pts, Color centerCol, Color cornerCol) {
    if (!_front(pts)) return;
    // Center: rotated square connecting edge midpoints
    final m = [
      Offset((pts[0].dx + pts[1].dx) / 2, (pts[0].dy + pts[1].dy) / 2),
      Offset((pts[1].dx + pts[2].dx) / 2, (pts[1].dy + pts[2].dy) / 2),
      Offset((pts[2].dx + pts[3].dx) / 2, (pts[2].dy + pts[3].dy) / 2),
      Offset((pts[3].dx + pts[0].dx) / 2, (pts[3].dy + pts[0].dy) / 2),
    ];
    // Center square
    final cp = Path()
      ..moveTo(m[0].dx, m[0].dy)
      ..lineTo(m[1].dx, m[1].dy)
      ..lineTo(m[2].dx, m[2].dy)
      ..lineTo(m[3].dx, m[3].dy)
      ..close();
    cv.drawPath(cp, Paint()..color = centerCol);
    cv.drawPath(
        cp,
        Paint()
          ..color = _K.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7);
    // 4 corner triangles
    for (int i = 0; i < 4; i++) {
      _tri(cv, pts[i], m[i], m[(i + 3) % 4], cornerCol.withValues(alpha: 0.82));
    }
  }

  @override
  void paint(Canvas cv, Size sz) {
    final s = sz.width * 0.37, cx = sz.width / 2, cy = sz.height * 0.54;
    final v = [
      _p(-1, 1, -1, s, cx, cy),
      _p(1, 1, -1, s, cx, cy),
      _p(1, -1, -1, s, cx, cy),
      _p(-1, -1, -1, s, cx, cy),
      _p(-1, 1, 1, s, cx, cy),
      _p(1, 1, 1, s, cx, cy),
      _p(1, -1, 1, s, cx, cy),
      _p(-1, -1, 1, s, cx, cy),
    ];
    final faces = [
      ([v[4], v[5], v[1], v[0]], _W, _G), // U: white center, green corners
      ([v[0], v[1], v[2], v[3]], _R, _Y), // F: red center, yellow corners
      ([v[1], v[5], v[6], v[2]], _G, _W), // R: green center, white corners
    ];
    faces.sort((fa, fb) {
      final da = fa.$1.map((p) => p.dy).reduce((x, y) => x + y);
      final db = fb.$1.map((p) => p.dy).reduce((x, y) => x + y);
      return db.compareTo(da);
    });
    for (final f in faces) {
      _skewbFace(cv, f.$1, f.$2, f.$3);
    }
  }

  @override
  bool shouldRepaint(_SkewbPainter o) => o.a != a;
}

// ── Megaminx: Dodecahedron ────────────────────────────────────
class _MegaSpinner extends StatefulWidget {
  final double size;
  const _MegaSpinner({super.key, required this.size});
  @override
  State<_MegaSpinner> createState() => _MegaSpinnerState();
}

class _MegaSpinnerState extends State<_MegaSpinner>
    with SingleTickerProviderStateMixin, SpinMixin {
  @override
  int get spinSeconds => 7;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: spinCtrl,
      builder: (_, __) => SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(painter: _MegaPainter(spinCtrl.value * 2 * pi))));
}

class _MegaPainter extends CustomPainter {
  final double a;
  _MegaPainter(this.a);

  static const _faceColors = [_W, _R, _B, _Y, _G, _O, _R, _G, _W, _B, _Y, _O];

  // Generate a regular pentagon centered at (cx,cy) with given radius and start angle
  List<Offset> _penta(double cx, double cy, double r, double startA) =>
      List.generate(
          5,
          (i) => Offset(cx + cos(startA + i * 2 * pi / 5) * r,
              cy + sin(startA + i * 2 * pi / 5) * r));

  void _drawPenta(Canvas cv, List<Offset> pts, Color col) {
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    path.close();
    cv.drawPath(path, Paint()..color = col);
    cv.drawPath(
        path,
        Paint()
          ..color = _K.withValues(alpha: 0.42)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8);
  }

  @override
  void paint(Canvas cv, Size sz) {
    final cx = sz.width / 2, cy = sz.height / 2;
    final R = sz.width * 0.44;
    final r = R * 0.55; // inner pentagon

    // Draw back faces first (visible from below/side)
    // Top pentagon (U face - White)
    final topAngle = a - pi / 2;
    final topPts = _penta(cx, cy - R * 0.12, r, topAngle);
    _drawPenta(cv, topPts, _faceColors[0]);

    // 5 upper surrounding faces with proper 3D tilt
    for (int i = 0; i < 5; i++) {
      final edgeAngle = topAngle + i * 2 * pi / 5 + pi / 5;
      // Project center of each surrounding face
      final faceCx = cx + cos(edgeAngle) * R * 0.68;
      final faceCy = cy - R * 0.12 + sin(edgeAngle) * R * 0.5;
      // Size shrinks with depth
      final depth = (sin(edgeAngle - a) + 1) / 2;
      final faceR = r * (0.7 + depth * 0.12);
      final faceA = edgeAngle + pi / 5 + a * 0.15;
      final facePts = _penta(faceCx, faceCy, faceR, faceA);
      // Only draw if facing viewer
      _drawPenta(cv, facePts, _faceColors[1 + i]);
    }

    // Lower partial faces (bottom ring, partially visible)
    for (int i = 0; i < 3; i++) {
      final edgeAngle = topAngle + pi + i * 2 * pi / 3;
      final faceCx = cx + cos(edgeAngle) * R * 0.52;
      final faceCy = cy + R * 0.3 + sin(edgeAngle) * R * 0.32;
      if (faceCy > cy + R * 0.1) {
        final faceR = r * 0.55;
        final facePts = _penta(faceCx, faceCy, faceR, edgeAngle + a * 0.1);
        _drawPenta(cv, facePts, _faceColors[6 + i].withValues(alpha: 0.75));
      }
    }
  }

  @override
  bool shouldRepaint(_MegaPainter o) => o.a != a;
}

// ── Pyraminx: Tetrahedron ────────────────────────────────────
class _PyraSpinner extends StatefulWidget {
  final double size;
  const _PyraSpinner({super.key, required this.size});
  @override
  State<_PyraSpinner> createState() => _PyraSpinnerState();
}

class _PyraSpinnerState extends State<_PyraSpinner>
    with SingleTickerProviderStateMixin, SpinMixin {
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: spinCtrl,
      builder: (_, __) => SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(painter: _PyraPainter(spinCtrl.value * 2 * pi))));
}

class _PyraPainter extends CustomPainter {
  final double a;
  _PyraPainter(this.a);

  Offset _p(double x, double y, double z, double s, double cx, double cy) {
    final ca = cos(a), sa = sin(a), rx = x * ca - z * sa, rz = x * sa + z * ca;
    return Offset(rx * 0.92 * s + cx, (-y - rz * 0.42) * s + cy);
  }

  @override
  void paint(Canvas cv, Size sz) {
    final s = sz.width * 0.40, cx = sz.width / 2, cy = sz.height * 0.62;
    final apex = _p(0, 1.3, 0, s, cx, cy);
    final bl = _p(-1, -0.43, -0.577, s, cx, cy);
    final br = _p(1, -0.43, -0.577, s, cx, cy);
    final bk = _p(0, -0.43, 1.155, s, cx, cy);
    final faces = [
      ([apex, br, bl], _Y),
      ([apex, bl, bk], _R),
      ([apex, bk, br], _G),
      ([bl, br, bk], _B),
    ];
    faces.sort((fa, fb) {
      final da = fa.$1.map((p) => p.dy).reduce((x, y) => x + y);
      final db = fb.$1.map((p) => p.dy).reduce((x, y) => x + y);
      return db.compareTo(da);
    });
    final ep = Paint()
      ..color = _K.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (final f in faces) {
      final pts = f.$1;
      final v1 = pts[1] - pts[0];
      final v2 = pts[2] - pts[0];
      if (v1.dx * v2.dy - v1.dy * v2.dx > 0) continue;
      final p = Path()
        ..moveTo(pts[0].dx, pts[0].dy)
        ..lineTo(pts[1].dx, pts[1].dy)
        ..lineTo(pts[2].dx, pts[2].dy)
        ..close();
      cv.drawPath(p, Paint()..color = f.$2);
      cv.drawPath(p, ep);
    }
  }

  @override
  bool shouldRepaint(_PyraPainter o) => o.a != a;
}

// ── Clock: disc with dials and pins ──────────────────────────
class _ClockSpinner extends StatefulWidget {
  final double size;
  const _ClockSpinner({super.key, required this.size});
  @override
  State<_ClockSpinner> createState() => _ClockSpinnerState();
}

class _ClockSpinnerState extends State<_ClockSpinner>
    with SingleTickerProviderStateMixin, SpinMixin {
  @override
  int get spinSeconds => 8;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: spinCtrl,
      builder: (_, __) => SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(painter: _ClockPainter(spinCtrl.value))));
}

class _ClockPainter extends CustomPainter {
  final double t;
  _ClockPainter(this.t);
  @override
  void paint(Canvas cv, Size sz) {
    final cx = sz.width / 2, cy = sz.height / 2, R = sz.width * 0.46;
    // Outer body (grey disc)
    cv.drawCircle(Offset(cx, cy), R, Paint()..color = const Color(0xFF9E9E9E));
    cv.drawCircle(
        Offset(cx, cy),
        R,
        Paint()
          ..color = _K.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = sz.width * 0.06);
    // 4 pins at corners
    for (int i = 0; i < 4; i++) {
      final phi = pi / 4 + i * pi / 2;
      final px = cx + cos(phi) * R * 0.72, py = cy + sin(phi) * R * 0.72;
      final isUp = (i + t.floor()) % 2 == 0;
      cv.drawCircle(
          Offset(px, py),
          sz.width * 0.072,
          Paint()
            ..color = isUp ? const Color(0xFFEEEEEE) : const Color(0xFF555555));
      cv.drawCircle(
          Offset(px, py),
          sz.width * 0.072,
          Paint()
            ..color = _K.withValues(alpha: 0.4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.7);
    }
    // Clock face
    final faceR = R * 0.52;
    cv.drawCircle(Offset(cx, cy), faceR, Paint()..color = _W);
    cv.drawCircle(
        Offset(cx, cy),
        faceR,
        Paint()
          ..color = _K.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7);
    // 12 hour markers
    for (int i = 0; i < 12; i++) {
      final phi = i * 2 * pi / 12 - pi / 2;
      cv.drawLine(
          Offset(cx + cos(phi) * faceR * 0.78, cy + sin(phi) * faceR * 0.78),
          Offset(cx + cos(phi) * faceR * 0.94, cy + sin(phi) * faceR * 0.94),
          Paint()
            ..color = _K.withValues(alpha: 0.35)
            ..strokeWidth = 0.6);
    }
    // Minute hand
    final mA = t * 2 * pi - pi / 2;
    cv.drawLine(
        Offset(cx, cy),
        Offset(cx + cos(mA) * faceR * 0.66, cy + sin(mA) * faceR * 0.66),
        Paint()
          ..color = _K
          ..strokeWidth = sz.width * 0.035
          ..strokeCap = StrokeCap.round);
    // Hour hand
    final hA = t * 2 * pi * 0.5 - pi / 2;
    cv.drawLine(
        Offset(cx, cy),
        Offset(cx + cos(hA) * faceR * 0.42, cy + sin(hA) * faceR * 0.42),
        Paint()
          ..color = _K
          ..strokeWidth = sz.width * 0.058
          ..strokeCap = StrokeCap.round);
    // Center
    cv.drawCircle(Offset(cx, cy), sz.width * 0.04, Paint()..color = _K);
  }

  @override
  bool shouldRepaint(_ClockPainter o) => o.t != t;
}
