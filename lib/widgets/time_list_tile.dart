import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../models/solve_time.dart';
import '../providers/session_provider.dart';

class TimeListTile extends StatelessWidget {
  final SolveTime solve;
  final int index;
  final bool isBest;
  final VoidCallback onDelete, onPlusTwo, onDnf, onOk;
  final Color accentColor;

  const TimeListTile(
      {super.key,
      required this.solve,
      required this.index,
      required this.isBest,
      required this.onDelete,
      required this.onPlusTwo,
      required this.onDnf,
      required this.onOk,
      required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final onSurf = th.colorScheme.onSurface;
    return Dismissible(
      key: Key(solve.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
            color: th.colorScheme.error.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16)),
        child: Icon(Icons.delete_outline, color: th.colorScheme.error),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
            color: th.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: th.dividerColor)),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          leading:
              _Badge(index: index, isBest: isBest, accent: accentColor, th: th),
          title: Row(children: [
            Text(solve.displayTime,
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: solve.result == SolveResult.dnf
                        ? th.colorScheme.error
                        : solve.result == SolveResult.plusTwo
                            ? Colors.orange
                            : onSurf)),
            if (isBest)
              Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child:
                      Icon(Icons.star_rounded, size: 14, color: accentColor)),
            if (solve.favorite)
              Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(Icons.bookmark, size: 14, color: accentColor)),
          ]),
          subtitle:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_fmt(solve.timestamp),
                style: th.textTheme.bodyMedium?.copyWith(fontSize: 11)),
            if (solve.comment.isNotEmpty)
              Text('💬 ${solve.comment}',
                  style: th.textTheme.bodyMedium?.copyWith(
                      fontSize: 11, color: accentColor.withValues(alpha: 0.8))),
          ]),
          trailing: _Menu(
              solve: solve,
              onPlusTwo: onPlusTwo,
              onDnf: onDnf,
              onOk: onOk,
              onDelete: onDelete,
              accentColor: accentColor,
              th: th),
        ),
      ),
    );
  }

  String _fmt(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Adesso';
    if (diff.inHours < 1) return '${diff.inMinutes}m fa';
    if (diff.inDays < 1) return '${diff.inHours}h fa';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _Badge extends StatelessWidget {
  final int index;
  final bool isBest;
  final Color accent;
  final ThemeData th;
  const _Badge(
      {required this.index,
      required this.isBest,
      required this.accent,
      required this.th});
  @override
  Widget build(BuildContext context) => Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: isBest ? accent.withValues(alpha: 0.18) : th.dividerColor,
            borderRadius: BorderRadius.circular(10)),
        child: Text('$index',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'Nunito',
                color: isBest
                    ? accent
                    : th.colorScheme.onSurface.withValues(alpha: 0.6))),
      );
}

class _Menu extends StatelessWidget {
  final SolveTime solve;
  final VoidCallback onPlusTwo, onDnf, onOk, onDelete;
  final Color accentColor;
  final ThemeData th;
  const _Menu(
      {required this.solve,
      required this.onPlusTwo,
      required this.onDnf,
      required this.onOk,
      required this.onDelete,
      required this.accentColor,
      required this.th});

  @override
  Widget build(BuildContext context) {
    final session = context.read<SessionProvider>();
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert,
          color: th.colorScheme.onSurface.withValues(alpha: 0.35), size: 20),
      itemBuilder: (_) => [
        _it('ok', Icons.check_circle_outline, 'OK',
            solve.result == SolveResult.ok),
        _it('+2', Icons.add_circle_outline, '+2 secondi',
            solve.result == SolveResult.plusTwo),
        _it('dnf', Icons.cancel_outlined, 'DNF',
            solve.result == SolveResult.dnf),
        _it(
            'fav',
            solve.favorite ? Icons.bookmark : Icons.bookmark_border,
            solve.favorite ? 'Rimuovi preferito' : 'Aggiungi preferito',
            solve.favorite),
        const PopupMenuDivider(),
        _it('comment', Icons.chat_bubble_outline, 'Commento', false),
        _it('share', Icons.share_outlined, 'Condividi', false),
        const PopupMenuDivider(),
        PopupMenuItem(
            value: 'delete',
            child: Row(children: [
              Icon(Icons.delete_outline, color: th.colorScheme.error, size: 18),
              const SizedBox(width: 10),
              Text('Elimina',
                  style: TextStyle(
                      color: th.colorScheme.error, fontFamily: 'Nunito')),
            ])),
      ],
      onSelected: (v) async {
        if (v == 'ok') onOk();
        if (v == '+2') onPlusTwo();
        if (v == 'dnf') onDnf();
        if (v == 'fav') session.toggleFavorite(solve.id);
        if (v == 'delete') onDelete();
        if (v == 'share') SharePlus.instance.share(ShareParams(text: session.buildSolveShareText(solve)));
        if (v == 'comment') _showCommentDialog(context, session);
      },
    );
  }

  void _showCommentDialog(BuildContext ctx, SessionProvider session) {
    final ctrl = TextEditingController(text: solve.comment);
    showDialog(
        context: ctx,
        builder: (c) => Padding(
              padding:
                  EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom),
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                title: const Text('Commento'),
                content: TextField(
                    controller: ctrl,
                    autofocus: true,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        hintText: 'Aggiungi un commento...')),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text('Annulla')),
                  TextButton(
                      onPressed: () {
                        session.updateSolveComment(solve.id, ctrl.text);
                        Navigator.pop(c);
                      },
                      child: const Text('Salva')),
                ],
              ),
            ));
  }

  PopupMenuItem<String> _it(
      String val, IconData icon, String label, bool active) {
    const green = Color(0xFF30D158);
    return PopupMenuItem(
        value: val,
        child: Row(children: [
          Icon(icon, color: active ? green : null, size: 18),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  color: active ? green : null, fontFamily: 'Nunito')),
          if (active) ...[
            const Spacer(),
            const Icon(Icons.check, color: green, size: 14)
          ],
        ]));
  }
}
