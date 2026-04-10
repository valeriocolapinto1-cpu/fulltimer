// widgets/cube_icon.dart
// Icone 3D isometriche con colori WCA reali per ogni evento

import 'package:flutter/material.dart';

// ── Colori WCA standard ───────────────────────────────────────
const _white  = Color(0xFFFAFAFA);
const _yellow = Color(0xFFFFD500);
const _red    = Color(0xFFBA0C2F);
const _orange = Color(0xFFFF5800);
const _blue   = Color(0xFF003DA5);
const _green  = Color(0xFF009B48);
const _black  = Color(0xFF1A1A1A);

// Mappa evento → colori [top, right, left]
const _eventColors = <String, List<Color>>{
  '2x2':   [_yellow, _red,    _blue],
  '3x3':   [_yellow, _red,    _blue],
  'oh':    [_yellow, _orange, _green],
  '4x4':   [_white,  _red,    _blue],
  '5x5':   [_yellow, _orange, _blue],
  '6x6':   [_white,  _orange, _green],
  '7x7':   [_yellow, _red,    _green],
  'mega':  [_white,  _blue,   _green],
  'skewb': [_yellow, _red,    _blue],
  'clock': [_white,  _black,  _black],
  'sq1':   [_yellow, _blue,   _red],
  'pyra':  [_yellow, _red,    _green],
};

int _gridN(String id) {
  switch (id) {
    case '2x2': return 2;
    case '4x4': return 4;
    case '5x5': return 5;
    case '6x6': return 6;
    case '7x7': return 7;
    default:    return 3;
  }
}

Widget eventIcon(String eventId, {double size = 26, Color? color}) {
  if (eventId == 'pyra')  return _PyraIcon(size: size, eventId: eventId);
  if (eventId == 'clock') return _ClockIcon(size: size);
  return _CubeIcon(size: size, eventId: eventId);
}

// ── Cubo isometrico NxN ───────────────────────────────────────

class _CubeIcon extends StatelessWidget {
  final double size;
  final String eventId;
  const _CubeIcon({required this.size, required this.eventId});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size, height: size,
    child: CustomPaint(painter: _CubePainter(eventId: eventId)),
  );
}

class _CubePainter extends CustomPainter {
  final String eventId;
  _CubePainter({required this.eventId});

  @override
  void paint(Canvas canvas, Size sz) {
    final w = sz.width; final h = sz.height;
    final colors = _eventColors[eventId] ?? [_yellow, _red, _blue];
    final n = _gridN(eventId);

    // Punti isometrici
    final cx = w * 0.5;
    final top    = Offset(cx,       h * 0.04);
    final right  = Offset(w * 0.96, h * 0.28);
    final mid    = Offset(cx,       h * 0.52);
    final left   = Offset(w * 0.04, h * 0.28);
    final botR   = Offset(w * 0.96, h * 0.76);
    final bot    = Offset(cx,       h * 1.00);
    final botL   = Offset(w * 0.04, h * 0.76);

    final edgePaint = Paint()
      ..color = _black.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeJoin = StrokeJoin.round;

    // Faccia TOP
    _drawFace(canvas, [top, right, mid, left], colors[0], edgePaint);
    // Griglia top
    _drawGrid(canvas, top, right, mid, left, n,
        Paint()..color = _black.withValues(alpha: 0.22)..strokeWidth = w * 0.028..style = PaintingStyle.stroke);

    // Faccia RIGHT
    _drawFace(canvas, [right, botR, bot, mid], colors[1], edgePaint);
    _drawGrid(canvas, right, botR, bot, mid, n,
        Paint()..color = _black.withValues(alpha: 0.18)..strokeWidth = w * 0.025..style = PaintingStyle.stroke);

    // Faccia LEFT
    _drawFace(canvas, [left, mid, bot, botL], colors[2], edgePaint);
    _drawGrid(canvas, left, mid, bot, botL, n,
        Paint()..color = _black.withValues(alpha: 0.15)..strokeWidth = w * 0.022..style = PaintingStyle.stroke);
  }

  void _drawFace(Canvas c, List<Offset> pts, Color color, Paint edge) {
    final fill = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(pts[0].dx, pts[0].dy)
      ..lineTo(pts[1].dx, pts[1].dy)
      ..lineTo(pts[2].dx, pts[2].dy)
      ..lineTo(pts[3].dx, pts[3].dy)
      ..close();
    c.drawPath(path, fill);
    c.drawPath(path, edge);
  }

  void _drawGrid(Canvas canvas, Offset a, Offset b, Offset c, Offset d, int n, Paint p) {
    if (n < 2) return;
    for (int i = 1; i < n; i++) {
      final t = i / n;
      canvas.drawLine(Offset.lerp(a, d, t)!, Offset.lerp(b, c, t)!, p);
      canvas.drawLine(Offset.lerp(a, b, t)!, Offset.lerp(d, c, t)!, p);
    }
  }

  @override
  bool shouldRepaint(_CubePainter old) => old.eventId != eventId;
}

// ── Pyraminx ─────────────────────────────────────────────────

class _PyraIcon extends StatelessWidget {
  final double size;
  final String eventId;
  const _PyraIcon({required this.size, required this.eventId});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: size, height: size,
    child: CustomPaint(painter: _PyraPainter()),
  );
}

class _PyraPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size sz) {
    final w = sz.width; final h = sz.height;
    final edge = Paint()
      ..color = _black.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05;

    final top   = Offset(w * 0.5,  h * 0.04);
    final left  = Offset(w * 0.04, h * 0.90);
    final right = Offset(w * 0.96, h * 0.90);
    final inner = Offset(w * 0.5,  h * 0.60);

    _face(canvas, [top, right, inner],  _yellow, edge);
    _face(canvas, [top, left, inner],   _red,    edge);
    _face(canvas, [left, right, inner], _green,  edge);
  }

  void _face(Canvas c, List<Offset> pts, Color col, Paint edge) {
    final p = Path()
      ..moveTo(pts[0].dx, pts[0].dy)
      ..lineTo(pts[1].dx, pts[1].dy)
      ..lineTo(pts[2].dx, pts[2].dy)
      ..close();
    c.drawPath(p, Paint()..color = col..style = PaintingStyle.fill);
    c.drawPath(p, edge);
  }

  @override
  bool shouldRepaint(_PyraPainter _) => false;
}

// ── Clock ─────────────────────────────────────────────────────

class _ClockIcon extends StatelessWidget {
  final double size;
  const _ClockIcon({required this.size});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: size, height: size,
    child: CustomPaint(painter: _ClockPainter()),
  );
}

class _ClockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size sz) {
    final w = sz.width; final h = sz.height;
    final cx = w / 2; final cy = h / 2;
    final r  = w * 0.46;

    // Corpo
    canvas.drawCircle(Offset(cx, cy), r,
        Paint()..color = _white..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(cx, cy), r,
        Paint()..color = _black.withValues(alpha: 0.5)..style = PaintingStyle.stroke..strokeWidth = w * 0.06);

    final hand = Paint()..color = _black..strokeWidth = w * 0.07..strokeCap = StrokeCap.round;

    // Lancetta ore (corta)
    canvas.drawLine(Offset(cx, cy), Offset(cx, cy - r * 0.4), hand);
    // Lancetta minuti (lunga)
    canvas.drawLine(Offset(cx, cy), Offset(cx + r * 0.55, cy), hand);

    // Pin agli angoli
    final pinPaint = Paint()..color = _black.withValues(alpha: 0.6);
    for (final o in [
      Offset(cx - r * 0.55, cy - r * 0.55),
      Offset(cx + r * 0.55, cy - r * 0.55),
      Offset(cx - r * 0.55, cy + r * 0.55),
      Offset(cx + r * 0.55, cy + r * 0.55),
    ]) {
      canvas.drawCircle(o, w * 0.07, pinPaint);
    }
  }

  @override
  bool shouldRepaint(_ClockPainter _) => false;
}
