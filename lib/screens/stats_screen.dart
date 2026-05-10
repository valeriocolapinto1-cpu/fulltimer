import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';
import '../providers/settings_provider.dart';
import '../models/solve_time.dart';
import '../widgets/stats_card.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _chartExpanded = false;
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final accent  = context.watch<SettingsProvider>().accentColor;
    final theme   = Theme.of(context);
    final solves  = session.currentSolves;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Statistiche')),
      body: solves.isEmpty
          ? Center(child: Text('Nessun dato ancora', style: theme.textTheme.bodyMedium))
          : ListView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              children: [
                _Label('SESSIONE CORRENTE', theme),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.4,
                  children: [
                    _SolveCountCard(count: session.solveCount, theme: theme),
                    StatsCard(label: 'MIGLIORE',       valueMs: session.bestTime,                     highlight: true, accentColor: accent),
                    StatsCard(label: 'MEDIA SESSIONE', valueMs: session.sessionMean,                   accentColor: accent),
                    StatsCard(label: 'AO5',            valueMs: session.ao5,                           accentColor: accent),
                    StatsCard(label: 'AO12',           valueMs: session.ao12,                          accentColor: accent),
                    StatsCard(label: 'AO50',           valueMs: session.activeSession?.averageOf(50),  accentColor: accent),
                  ],
                ),
                const SizedBox(height: 24),

                if (solves.length >= 3) ...[
                  // Header grafico con toggle
                  GestureDetector(
                    onTap: () => setState(() => _chartExpanded = !_chartExpanded),
                    child: Row(children: [
                      _Label('ANDAMENTO', theme),
                      const Spacer(),
                      Icon(_chartExpanded ? Icons.expand_less : Icons.expand_more,
                          size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                      const SizedBox(width: 2),
                      Text(_chartExpanded ? 'Comprimi' : 'Espandi',
                          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11)),
                    ]),
                  ),
                  const SizedBox(height: 10),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: _chartExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: _TimeChart(
                      solves: solves, accent: accent, theme: theme,
                      expanded: false, onHover: null,
                    ),
                    secondChild: Column(children: [
                      _TimeChart(
                        solves: solves, accent: accent, theme: theme,
                        expanded: true,
                        onHover: (i) => setState(() => _hoveredIndex = i),
                      ),
                      const SizedBox(height: 12),
                      _DeltaPanel(solves: solves, hoveredIndex: _hoveredIndex, accent: accent, theme: theme),
                    ]),
                  ),
                  const SizedBox(height: 24),
                ],

                if (solves.length >= 5) ...[
                  _Label('DISTRIBUZIONE', theme),
                  const SizedBox(height: 10),
                  _DistributionBar(solves: solves, accent: accent, theme: theme),
                  const SizedBox(height: 24),
                ],

                _Label('RISULTATI', theme),
                const SizedBox(height: 10),
                _ResultsBreakdown(solves: solves, theme: theme),
              ],
            ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text; final ThemeData theme;
  const _Label(this.text, this.theme);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 2, fontSize: 11));
}

class _SolveCountCard extends StatelessWidget {
  final int count; final ThemeData theme;
  const _SolveCountCard({required this.count, required this.theme});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Text('SOLVE', style: theme.textTheme.labelSmall?.copyWith(fontSize: 10, letterSpacing: 1.5)),
      const SizedBox(height: 5),
      Text('$count', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, fontFamily: 'Nunito')),
    ]),
  );
}

// ── Grafico con hover ─────────────────────────────────────────

class _TimeChart extends StatelessWidget {
  final List<SolveTime> solves;
  final Color accent;
  final ThemeData theme;
  final bool expanded;
  final ValueChanged<int?>? onHover;

  const _TimeChart({required this.solves, required this.accent, required this.theme,
      required this.expanded, required this.onHover});

  @override
  Widget build(BuildContext context) {
    final valid = solves.where((s) => s.isValid).toList();
    if (valid.length < 3) return const SizedBox.shrink();
    final data = valid.length > (expanded ? 50 : 20)
        ? valid.sublist(valid.length - (expanded ? 50 : 20))
        : valid;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth > 0 ? constraints.maxWidth : 1.0;
        return GestureDetector(
          onTapDown: onHover == null ? null : (d) {
            final ratio = (d.localPosition.dx / width).clamp(0.0, 1.0);
            final idx = (ratio * (data.length - 1)).round();
            onHover!(idx);
          },
          onTapUp: onHover == null ? null : (_) => onHover!(null),
          child: Container(
            height: expanded ? 220 : 140,
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Expanded(child: CustomPaint(
                painter: _ChartPainter(
                  times: data.map((s) => s.effectiveMilliseconds).toList(),
                  accent: accent,
                  gridColor: theme.dividerColor,
                ),
              )),
              const SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('${data.length} solve fa', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 10)),
                Text('più recente',             style: theme.textTheme.bodyMedium?.copyWith(fontSize: 10)),
              ]),
            ]),
          ),
        );
      },
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<int> times;
  final Color accent;
  final Color gridColor;
  _ChartPainter({required this.times, required this.accent, required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (times.length < 2) return;
    final minT  = times.reduce((a, b) => a < b ? a : b).toDouble();
    final maxT  = times.reduce((a, b) => a > b ? a : b).toDouble();
    final range = maxT - minT;
    if (range == 0) return;
    final w = size.width; final h = size.height;

    // Griglia
    final gp = Paint()..color = gridColor..strokeWidth = 0.5;
    for (int i = 0; i <= 4; i++) {
      final y = h - (i / 4) * h;
      canvas.drawLine(Offset(0, y), Offset(w, y), gp);
    }

    // Punti
    final pts = <Offset>[
      for (int i = 0; i < times.length; i++)
        Offset((i / (times.length - 1)) * w, h - ((times[i] - minT) / range) * h)
    ];

    // Curva bezier
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      final cp1 = Offset((pts[i-1].dx + pts[i].dx) / 2, pts[i-1].dy);
      final cp2 = Offset((pts[i-1].dx + pts[i].dx) / 2, pts[i].dy);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(path, Paint()
      ..color = accent..strokeWidth = 2..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);

    // Area
    final fill = Path.from(path)
      ..lineTo(pts.last.dx, h)..lineTo(pts.first.dx, h)..close();
    canvas.drawPath(fill, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [accent.withValues(alpha: 0.28), accent.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill);

    // Punti
    for (final p in pts) {
      canvas.drawCircle(p, 2.5, Paint()..color = accent);
      canvas.drawCircle(p, 2.5, Paint()..color = Colors.white.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke..strokeWidth = 1);
    }
  }

  @override
  bool shouldRepaint(_ChartPainter o) => o.times != times || o.accent != accent;
}

// ── Delta panel ───────────────────────────────────────────────

class _DeltaPanel extends StatelessWidget {
  final List<SolveTime> solves;
  final int? hoveredIndex;
  final Color accent;
  final ThemeData theme;
  const _DeltaPanel({required this.solves, required this.hoveredIndex,
      required this.accent, required this.theme});

  @override
  Widget build(BuildContext context) {
    final valid = solves.where((s) => s.isValid).toList();
    if (valid.length < 2) return const SizedBox.shrink();

    // Calcola delta (differenza rispetto al precedente)
    final deltas = <int>[];
    for (int i = 1; i < valid.length; i++) {
      deltas.add(valid[i].effectiveMilliseconds - valid[i - 1].effectiveMilliseconds);
    }

    final avgDelta  = deltas.reduce((a, b) => a + b) / deltas.length;
    final maxDelta  = deltas.reduce((a, b) => a > b ? a : b);
    final minDelta  = deltas.reduce((a, b) => a < b ? a : b);
    final improving = deltas.where((d) => d < 0).length;
    final selectedDelta = hoveredIndex == null || hoveredIndex! <= 0 || hoveredIndex! >= valid.length
        ? null
        : valid[hoveredIndex!].effectiveMilliseconds - valid[hoveredIndex! - 1].effectiveMilliseconds;


    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('ANALISI DELTA', style: theme.textTheme.labelSmall?.copyWith(fontSize: 10, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        Row(children: [
          _DeltaStat('Media Δ',   _fmtDelta(avgDelta.round()),  avgDelta < 0 ? const Color(0xFF30D158) : const Color(0xFFFF453A), theme),
          const SizedBox(width: 10),
          _DeltaStat('Migl. Δ',  _fmtDelta(minDelta), const Color(0xFF30D158), theme),
          const SizedBox(width: 10),
          _DeltaStat('Pegg. Δ',  _fmtDelta(maxDelta), const Color(0xFFFF453A), theme),
        ]),
        if (selectedDelta != null) ...[
          const SizedBox(height: 8),
          Text(
            'Delta selezionato: ${_fmtDelta(selectedDelta)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              color: selectedDelta < 0 ? const Color(0xFF30D158) : const Color(0xFFFF453A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 10),
        // Barra miglioramenti
        Row(children: [
          Expanded(child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: valid.length < 2 ? 0 : improving / (valid.length - 1),
              backgroundColor: theme.dividerColor,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF30D158)),
              minHeight: 6,
            ),
          )),
          const SizedBox(width: 10),
          Text('$improving/${valid.length - 1} in miglioramento',
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11)),
        ]),
      ]),
    );
  }

  String _fmtDelta(int ms) {
    final sign = ms >= 0 ? '+' : '-';
    return '$sign${SolveTime.format(ms.abs())}';
  }
}

class _DeltaStat extends StatelessWidget {
  final String label, value;
  final Color color;
  final ThemeData theme;
  const _DeltaStat(this.label, this.value, this.color, this.theme);
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withValues(alpha: 0.25)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: theme.textTheme.labelSmall?.copyWith(fontSize: 9, letterSpacing: 1)),
      const SizedBox(height: 3),
      Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Nunito', color: color)),
    ]),
  ));
}

// ── Distribuzione ─────────────────────────────────────────────

class _DistributionBar extends StatelessWidget {
  final List<SolveTime> solves; final Color accent; final ThemeData theme;
  const _DistributionBar({required this.solves, required this.accent, required this.theme});
  @override
  Widget build(BuildContext context) {
    final v = solves.where((s) => s.isValid).map((s) => s.effectiveMilliseconds).toList()..sort();
    if (v.length < 3) return const SizedBox.shrink();
    final min = v.first; final max = v.last; final range = max - min;
    if (range == 0) return const SizedBox.shrink();
    const n = 8;
    final counts = List.filled(n, 0);
    for (final t in v) { counts[((t - min) / (range / n)).floor().clamp(0, n - 1)]++; }
    final maxC = counts.reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor)),
      child: Column(children: [
        SizedBox(height: 72, child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: counts.map((c) => Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              height: maxC == 0 ? 0 : c / maxC * 64,
              decoration: BoxDecoration(color: accent.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(4)),
            ),
          ))).toList(),
        )),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(SolveTime.format(min), style: theme.textTheme.bodyMedium?.copyWith(fontSize: 10)),
          Text(SolveTime.format(max), style: theme.textTheme.bodyMedium?.copyWith(fontSize: 10)),
        ]),
      ]),
    );
  }
}

// ── Risultati ────────────────────────────────────────────────

class _ResultsBreakdown extends StatelessWidget {
  final List<SolveTime> solves; final ThemeData theme;
  const _ResultsBreakdown({required this.solves, required this.theme});
  @override
  Widget build(BuildContext context) {
    final ok  = solves.where((s) => s.result == SolveResult.ok).length;
    final p2  = solves.where((s) => s.result == SolveResult.plusTwo).length;
    final dnf = solves.where((s) => s.result == SolveResult.dnf).length;
    final tot = solves.length;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor)),
      child: Column(children: [
        _Row('OK',  ok,  tot, const Color(0xFF30D158), theme),
        const SizedBox(height: 10),
        _Row('+2',  p2,  tot, const Color(0xFFFF9F0A), theme),
        const SizedBox(height: 10),
        _Row('DNF', dnf, tot, const Color(0xFFFF453A), theme),
      ]),
    );
  }
}

class _Row extends StatelessWidget {
  final String label; final int count, total; final Color color; final ThemeData theme;
  const _Row(this.label, this.count, this.total, this.color, this.theme);
  @override
  Widget build(BuildContext context) => Row(children: [
    SizedBox(width: 32, child: Text(label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Nunito', color: color))),
    Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(value: total == 0 ? 0 : count / total,
            backgroundColor: theme.dividerColor, valueColor: AlwaysStoppedAnimation(color), minHeight: 6))),
    const SizedBox(width: 10),
    Text('$count', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13)),
  ]);
}
