import 'dart:math';
import 'package:flutter/material.dart';

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
    switch (eventId) {
      case '3x3': case 'oh':
        return SizedBox(width: size, height: size * 0.75,
            child: CustomPaint(painter: _CubeNetPainter(scramble, 3)));
      case '2x2':
        return SizedBox(width: size * 0.75, height: size * 0.56,
            child: CustomPaint(painter: _CubeNetPainter(scramble, 2)));
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
        return SizedBox(width: size, height: size * 0.75,
            child: CustomPaint(painter: _PyraNetPainter()));
      case 'skewb':
        return SizedBox(width: size, height: size * 0.75,
            child: CustomPaint(painter: _SkewbNetPainter()));
      case 'mega':
        return SizedBox(width: size, height: size * 0.75,
            child: CustomPaint(painter: _MegaNetPainter()));
      case 'clock':
        return SizedBox(width: size, height: size * 0.55,
            child: CustomPaint(painter: _ClockNetPainter()));
      case 'sq1':
        return SizedBox(width: size, height: size * 0.6,
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

// ── Big Cube Net (4x4–7x7) ────────────────────────────────────
class _BigCubeNetPainter extends CustomPainter {
  final int n;
  _BigCubeNetPainter(this.n);
  static const _faceColors = [_pW, _pY, _pR, _pO, _pG, _pB];
  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / (4 * n);
    final fs = n * cell;
    final ep = Paint()..color=_pK.withValues(alpha:0.18)..style=PaintingStyle.stroke..strokeWidth=0.4;
    final origins = [
      Offset(fs, 0), Offset(fs, fs*2), Offset(fs, fs),
      Offset(fs*3, fs), Offset(fs*2, fs), Offset(0, fs),
    ];
    for (int fi=0;fi<6;fi++) {
      final o = origins[fi];
      for (int r=0;r<n;r++) for (int c=0;c<n;c++) {
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(o.dx+c*cell+0.3, o.dy+r*cell+0.3, cell-0.6, cell-0.6),
          Radius.circular(cell*0.1));
        canvas.drawRRect(rect, Paint()..color=_faceColors[fi]);
        canvas.drawRRect(rect, ep);
      }
    }
  }
  @override bool shouldRepaint(_BigCubeNetPainter o) => o.n != n;
}

// ── Pyraminx Net ──────────────────────────────────────────────
// 4 triangular faces: Front(Y), Left(R), Right(G), Bottom(B)
// Layout: 3 faces touching at bottom, 1 face below
class _PyraNetPainter extends CustomPainter {
  static const _fc = [_pY, _pR, _pG, _pB];

  // Draw a triangular face subdivided into 9 small triangles (L3 size)
  void _face(Canvas cv, Offset apex, Offset bl, Offset br, Color col) {
    Offset lerp(Offset a, Offset b, double t) =>
        Offset(a.dx + (b.dx - a.dx)*t, a.dy + (b.dy - a.dy)*t);
    final ep = Paint()..color=_pK.withValues(alpha:0.4)..style=PaintingStyle.stroke..strokeWidth=0.8;
    for (int row=0; row<3; row++) {
      final t0=row/3.0, t1=(row+1)/3.0;
      final rl0 = lerp(apex, bl, t0), rr0 = lerp(apex, br, t0);
      final rl1 = lerp(apex, bl, t1), rr1 = lerp(apex, br, t1);
      final count = 2*row+1;
      for (int i=0; i<count; i++) {
        final ta=i/count.toDouble(), tb=(i+1)/count.toDouble();
        Offset pa, pb, pc;
        if (i.isEven) {
          pa = lerp(rl0, rr0, ta);
          pb = lerp(rl1, rr1, ta);
          pc = lerp(rl1, rr1, tb);
        } else {
          pa = lerp(rl0, rr0, ta);
          pb = lerp(rl1, rr1, tb);
          pc = lerp(rl0, rr0, tb);
        }
        final p = Path()..moveTo(pa.dx,pa.dy)..lineTo(pb.dx,pb.dy)..lineTo(pc.dx,pc.dy)..close();
        cv.drawPath(p, Paint()..color=col);
        cv.drawPath(p, ep);
      }
    }
  }

  @override
  void paint(Canvas cv, Size sz) {
    final w=sz.width, h=sz.height;
    // Front face (top center): apex at top, base at 55% height
    _face(cv, Offset(w*.5, h*.02), Offset(w*.15, h*.55), Offset(w*.85, h*.55), _fc[0]);
    // Left face (bottom left): apex points down-left
    _face(cv, Offset(w*.15, h*.55), Offset(w*.02, h*.98), Offset(w*.48, h*.98), _fc[1]);
    // Right face (bottom right): apex points down-right
    _face(cv, Offset(w*.85, h*.55), Offset(w*.52, h*.98), Offset(w*.98, h*.98), _fc[2]);
    // Bottom face (inverted, connecting the bottom edges)
    _face(cv, Offset(w*.5, h*.98), Offset(w*.15, h*.55), Offset(w*.85, h*.55), _fc[3]);
  }
  @override bool shouldRepaint(_PyraNetPainter _) => false;
}

// ── Skewb Net ─────────────────────────────────────────────────
// Cross layout, each face = center diamond + 4 corner triangles
class _SkewbNetPainter extends CustomPainter {
  static const _fc = [_pW, _pY, _pR, _pO, _pG, _pB];

  void _drawFace(Canvas cv, Rect r, int fi) {
    final tl=Offset(r.left,r.top), tr=Offset(r.right,r.top);
    final br=Offset(r.right,r.bottom), bl=Offset(r.left,r.bottom);
    final mt=Offset((tl.dx+tr.dx)/2,(tl.dy+tr.dy)/2);
    final mr=Offset((tr.dx+br.dx)/2,(tr.dy+br.dy)/2);
    final mb=Offset((br.dx+bl.dx)/2,(br.dy+bl.dy)/2);
    final ml=Offset((bl.dx+tl.dx)/2,(bl.dy+tl.dy)/2);
    final ep=Paint()..color=_pK.withValues(alpha:0.35)..style=PaintingStyle.stroke..strokeWidth=0.7;

    void quad(List<Offset> pts, Color c) {
      final p=Path()..moveTo(pts[0].dx,pts[0].dy);
      for(final pt in pts.skip(1)) p.lineTo(pt.dx,pt.dy);
      p.close();
      cv.drawPath(p, Paint()..color=c); cv.drawPath(p, ep);
    }
    void tri(Offset a, Offset b, Offset c2, Color c) {
      final p=Path()..moveTo(a.dx,a.dy)..lineTo(b.dx,b.dy)..lineTo(c2.dx,c2.dy)..close();
      cv.drawPath(p, Paint()..color=c); cv.drawPath(p, ep);
    }

    final c=_fc[fi];
    quad([mt,mr,mb,ml], c);
    tri(tl, mt, ml, _fc[(fi+2)%6]);
    tri(tr, mr, mt, _fc[(fi+3)%6]);
    tri(br, mb, mr, _fc[(fi+4)%6]);
    tri(bl, ml, mb, _fc[(fi+5)%6]);
  }

  @override
  void paint(Canvas cv, Size sz) {
    final cell=sz.width/4;
    final origins=[
      Offset(cell,0), Offset(cell,cell*2), Offset(cell,cell),
      Offset(cell*3,cell), Offset(cell*2,cell), Offset(0,cell),
    ];
    for (int fi=0;fi<6;fi++) {
      final o=origins[fi];
      _drawFace(cv, Rect.fromLTWH(o.dx,o.dy,cell,cell), fi);
    }
  }
  @override bool shouldRepaint(_SkewbNetPainter _) => false;
}

// ── Megaminx Net ──────────────────────────────────────────────
// Flower layout: center face surrounded by 5 faces
// Each pentagon subdivided: 1 center + 5 edge + 5 corner pieces
class _MegaNetPainter extends CustomPainter {
  static const _megaColors = [_pW,_pR,_pB,_pG,_pO,_pY,
    Color(0xFF9B59B6),Color(0xFFFF69B4),Color(0xFF00BCD4),
    Color(0xFF795548),Color(0xFF607D8B),Color(0xFF8BC34A)];

  List<Offset> _penta(double cx, double cy, double r, double a0) =>
    List.generate(5, (i) => Offset(cx+cos(a0+i*2*pi/5)*r, cy+sin(a0+i*2*pi/5)*r));

  void _drawPenta(Canvas cv, List<Offset> outer, Color col) {
    // Outer pentagon
    final op=Path()..moveTo(outer[0].dx,outer[0].dy);
    for(final p in outer.skip(1)) op.lineTo(p.dx,p.dy);
    op.close();
    cv.drawPath(op, Paint()..color=col);

    // Inner star: connect center to each vertex with lines
    final cx=outer.map((p)=>p.dx).reduce((a,b)=>a+b)/5;
    final cy=outer.map((p)=>p.dy).reduce((a,b)=>a+b)/5;
    final r=sqrt(pow(outer[0].dx-cx,2)+pow(outer[0].dy-cy,2));
    final innerR=r*0.42;
    final inner=_penta(cx,cy,innerR,atan2(outer[0].dy-cy,outer[0].dx-cx));

    // Draw inner pentagon
    final ip=Path()..moveTo(inner[0].dx,inner[0].dy);
    for(final p in inner.skip(1)) ip.lineTo(p.dx,p.dy);
    ip.close();
    cv.drawPath(ip, Paint()..color=col.withValues(alpha:0.7));

    final ep=Paint()..color=_pK.withValues(alpha:0.4)..style=PaintingStyle.stroke..strokeWidth=0.8;
    // Radial lines from center to outer vertices (piece borders)
    for(final p in outer) cv.drawLine(Offset(cx,cy), p, ep);
    // Outer edge
    cv.drawPath(op, ep);
    // Inner edge
    cv.drawPath(ip, ep);
    // Connect outer vertices to inner vertices
    for(int i=0;i<5;i++) {
      cv.drawLine(outer[i], inner[i], ep);
      cv.drawLine(outer[(i+1)%5], inner[i], ep);
    }
  }

  @override
  void paint(Canvas cv, Size sz) {
    final cx=sz.width/2, cy=sz.height/2;
    final R=sz.width*0.44, fR=R*0.50;
    // Top/center face
    final topPts=_penta(cx, cy-R*0.08, fR, -pi/2);
    _drawPenta(cv, topPts, _megaColors[0]);
    // 5 surrounding faces, each sharing an edge with top
    for(int i=0;i<5;i++) {
      final edgeA=-pi/2+pi/5+i*2*pi/5;
      final p1=topPts[i], p2=topPts[(i+1)%5];
      final emx=(p1.dx+p2.dx)/2, emy=(p1.dy+p2.dy)/2;
      final fcx=emx+cos(edgeA)*fR*0.98;
      final fcy=emy+sin(edgeA)*fR*0.68;
      _drawPenta(cv, _penta(fcx,fcy,fR*0.90,edgeA+pi/5), _megaColors[1+i]);
    }
  }
  @override bool shouldRepaint(_MegaNetPainter _) => false;
}

// ── Clock Net ─────────────────────────────────────────────────
// Two sides (front/back) shown side by side
// Each side: rectangular frame with 9 clock dials + 4 corner pins
class _ClockNetPainter extends CustomPainter {
  void _drawSide(Canvas cv, Rect bounds, bool isFront) {
    final w=bounds.width, h=bounds.height;
    final ox=bounds.left, oy=bounds.top;

    // Background: rounded rect (the flat disc shape)
    final bgR=RRect.fromRectAndRadius(bounds, Radius.circular(8));
    cv.drawRRect(bgR, Paint()..color=isFront?_pB:const Color(0xFF5C8BD6));
    cv.drawRRect(bgR, Paint()..color=_pK.withValues(alpha:0.5)..style=PaintingStyle.stroke..strokeWidth=1.0);

    // 9 dials in 3x3 grid
    final dialR=w*0.13;
    final spX=w*0.30, spY=h*0.28;
    final startX=ox+w*0.21, startY=oy+h*0.22;
    final angles=[pi*1.5, pi*0.5, pi*1.0, pi*0.0, pi*1.75, pi*0.25, pi*1.25, pi*0.75, pi*0.0];

    for(int r=0;r<3;r++) for(int c=0;c<3;c++) {
      final cx=startX+c*spX, cy=startY+r*spY;
      final a=angles[r*3+c];
      // Dial face (white circle)
      cv.drawCircle(Offset(cx,cy), dialR, Paint()..color=Colors.white);
      cv.drawCircle(Offset(cx,cy), dialR,
          Paint()..color=_pB.withValues(alpha:0.25)..style=PaintingStyle.stroke..strokeWidth=dialR*0.18);
      // Hour marks (12 dots)
      for(int m=0;m<12;m++) {
        final mp=pi*m/6-pi/2;
        cv.drawCircle(Offset(cx+cos(mp)*dialR*0.82,cy+sin(mp)*dialR*0.82),
            dialR*0.07, Paint()..color=_pK.withValues(alpha:0.3));
      }
      // Clock hand (orange with yellow tip, like reference)
      final handEnd=Offset(cx+cos(a)*dialR*0.68, cy+sin(a)*dialR*0.68);
      cv.drawLine(Offset(cx,cy), handEnd,
          Paint()..color=const Color(0xFFFF6B00)..strokeWidth=dialR*0.28..strokeCap=StrokeCap.round);
      // Yellow tip
      cv.drawCircle(handEnd, dialR*0.16, Paint()..color=_pY);
      // Center dot
      cv.drawCircle(Offset(cx,cy), dialR*0.12, Paint()..color=_pK.withValues(alpha:0.5));
    }

    // 4 corner pins
    for(int i=0;i<4;i++) {
      final px=ox+(i%2==0?w*0.10:w*0.90);
      final py=oy+(i<2?h*0.10:h*0.90);
      final pinR=w*0.065;
      // Pin: brown/dark circle (down) or light grey (up)
      final isUp=i%2==0;
      cv.drawCircle(Offset(px,py), pinR,
          Paint()..color=isUp?const Color(0xFFD0D0D0):const Color(0xFF6B4226));
      cv.drawCircle(Offset(px,py), pinR,
          Paint()..color=_pK.withValues(alpha:0.4)..style=PaintingStyle.stroke..strokeWidth=0.8);
    }
  }

  @override
  void paint(Canvas cv, Size sz) {
    final sW=sz.width*0.46, h=sz.height;
    _drawSide(cv, Rect.fromLTWH(0, 0, sW, h), true);
    _drawSide(cv, Rect.fromLTWH(sz.width*0.54, 0, sW, h), false);
    // "y2" label between the two sides
    final tp=TextPainter(text: const TextSpan(text:'y2',style:TextStyle(fontSize:10,color:Color(0xFF888888))),
        textDirection: TextDirection.ltr)..layout();
    tp.paint(cv, Offset(sz.width*0.485,h/2-5));
  }
  @override bool shouldRepaint(_ClockNetPainter _) => false;
}

// ── Square-1 Net ──────────────────────────────────────────────
// Top + Bottom layer (each octagonal), Middle slice (strip)
class _Sq1NetPainter extends CustomPainter {
  @override
  void paint(Canvas cv, Size sz) {
    final w=sz.width, h=sz.height;
    final ep=Paint()..color=_pK.withValues(alpha:0.35)..style=PaintingStyle.stroke..strokeWidth=0.8;

    // Draw one octagonal layer (Square-1 layer)
    void drawLayer(double cy, List<Color> pieceColors) {
      final r=w*0.23, innerR=w*0.10;
      final cx=w/2;
      // 8 pieces alternating: corner(wide) and edge(narrow)
      // Corner pieces span 60°, edge pieces span 30°
      for(int i=0;i<8;i++) {
        final isCorner=i.isEven;
        final span=isCorner?pi/3:pi/6; // 60° or 30°
        // Calculate cumulative start angle
        double a0=-pi/2;
        for(int j=0;j<i;j++) a0+=(j.isEven?pi/3:pi/6);
        final a1=a0+span;
        final path=Path()
          ..moveTo(cx+cos(a0)*innerR, cy+sin(a0)*innerR)
          ..lineTo(cx+cos(a0)*r, cy+sin(a0)*r)
          ..arcToPoint(Offset(cx+cos(a1)*r, cy+sin(a1)*r),
              radius: Radius.circular(r), clockwise: true)
          ..lineTo(cx+cos(a1)*innerR, cy+sin(a1)*innerR)
          ..arcToPoint(Offset(cx+cos(a0)*innerR, cy+sin(a0)*innerR),
              radius: Radius.circular(innerR), clockwise: false)
          ..close();
        cv.drawPath(path, Paint()..color=pieceColors[i]);
        cv.drawPath(path, ep);
      }
    }

    // Top layer: white corners, red edges
    final topColors=[_pW,_pR,_pW,_pR,_pW,_pR,_pW,_pR];
    drawLayer(h*0.26, topColors);

    // Middle slice (black strip)
    final mr=RRect.fromRectAndRadius(Rect.fromLTWH(w*0.15,h*0.46,w*0.70,h*0.08), Radius.circular(4));
    cv.drawRRect(mr, Paint()..color=const Color(0xFF1A1A1A));

    // Bottom layer: yellow corners, orange edges
    final botColors=[_pY,_pO,_pY,_pO,_pY,_pO,_pY,_pO];
    drawLayer(h*0.74, botColors);
  }
  @override bool shouldRepaint(_Sq1NetPainter _) => false;
}
