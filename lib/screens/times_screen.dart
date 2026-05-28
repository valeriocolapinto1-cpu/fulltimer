import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/session_provider.dart';
import '../providers/settings_provider.dart';
import '../models/solve_time.dart';
import '../widgets/time_list_tile.dart';

class TimesScreen extends StatelessWidget {
  const TimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final settings = context.watch<SettingsProvider>();
    final solves = session.currentSolves.reversed.toList();
    final accent = settings.accentColor;
    final bestMs = session.bestTime;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Column(children: [
          Text(session.activeSession?.name ?? session.activeEvent.name),
          Text('${session.solveCount} solve',
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11)),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Condividi',
            onPressed: session.solveCount == 0
                ? null
                : () => SharePlus.instance.share(ShareParams(text: session.buildShareText())),
          ),
        ],
      ),
      body: solves.isEmpty
          ? _EmptyState(accent: accent)
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: solves.length,
              itemBuilder: (context, i) {
                final solve = solves[i];
                final originalIndex = session.currentSolves.length - i;
                final isBest =
                    solve.isValid && solve.effectiveMilliseconds == bestMs;
                return TimeListTile(
                  solve: solve,
                  index: originalIndex,
                  isBest: isBest,
                  accentColor: accent,
                  onDelete: () => session.deleteSolve(solve.id),
                  onOk: () =>
                      session.updateSolveResult(solve.id, SolveResult.ok),
                  onPlusTwo: () =>
                      session.updateSolveResult(solve.id, SolveResult.plusTwo),
                  onDnf: () =>
                      session.updateSolveResult(solve.id, SolveResult.dnf),
                );
              },
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Color accent;
  const _EmptyState({required this.accent});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.timer_outlined,
          size: 64, color: accent.withValues(alpha: 0.25)),
      const SizedBox(height: 16),
      Text('Nessun tempo',
          style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
      const SizedBox(height: 6),
      Text('Vai al timer per iniziare', style: theme.textTheme.bodyMedium),
    ]));
  }
}
