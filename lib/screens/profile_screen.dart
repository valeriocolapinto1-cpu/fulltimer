import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_type.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileState();
}

class _ProfileState extends State<ProfileScreen> {
  String _name = '', _wcaId = '', _country = '', _avatarEmoji = '👤';
  List<String> _favEvents = [], _learnedAlgs = [];
  bool _loading = true;

  static const _algSets = [
    'OLL Completo (57 casi)',
    'PLL Completo (21 casi)',
    'F2L Completo (41 casi)',
    'ZBLL',
    'COLL',
    'CMLL',
    '2x2 Ortega (7+3)',
    '2x2 CLL',
    'Pyraminx L4E',
    "Skewb Sarah's Advanced",
    'Megaminx OLL',
    'Megaminx PLL',
    'Square-1 OLL+PLL',
    '4x4 OLL Parity',
    '4x4 PLL Parity',
  ];

  static const _avatarEmojis = [
    '👤',
    '🤓',
    '😎',
    '🧊',
    '🧩',
    '🏆',
    '🎯',
    '⚡',
    '🔥',
    '💎',
    '🌟',
    '🎲',
    '🦊',
    '🐉',
    '🤖',
    '👾',
    '🎮',
    '🎪',
    '🌈',
    '🦋',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _name = p.getString('profile_name') ?? '';
      _wcaId = p.getString('profile_wca') ?? '';
      _country = p.getString('profile_country') ?? '';
      _avatarEmoji = p.getString('profile_avatar') ?? '👤';
      _favEvents = p.getStringList('profile_fav_events') ?? [];
      _learnedAlgs = p.getStringList('profile_learned_algs') ?? [];
      _loading = false;
    });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('profile_name', _name);
    await p.setString('profile_wca', _wcaId);
    await p.setString('profile_country', _country);
    await p.setString('profile_avatar', _avatarEmoji);
    await p.setStringList('profile_fav_events', _favEvents);
    await p.setStringList('profile_learned_algs', _learnedAlgs);
  }

  void _editField(String label, String current, void Function(String) onSave) {
    final ctrl = TextEditingController(text: current);
    showDialog(
        context: context,
        builder: (c) => Padding(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom),
            child: AlertDialog(
                title: Text(label),
                content: TextField(controller: ctrl, autofocus: true),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text('Annulla')),
                  TextButton(
                      onPressed: () {
                        onSave(ctrl.text);
                        _save();
                        Navigator.pop(c);
                      },
                      child: const Text('Salva')),
                ])));
  }

  void _pickAvatar() {
    showDialog(
        context: context,
        builder: (c) => AlertDialog(
              title: const Text('Scegli avatar'),
              content: SizedBox(
                  width: 300,
                  height: 200,
                  child: GridView.count(
                      crossAxisCount: 5,
                      children: _avatarEmojis
                          .map((e) => GestureDetector(
                              onTap: () {
                                setState(() => _avatarEmoji = e);
                                _save();
                                Navigator.pop(c);
                              },
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                    color: _avatarEmoji == e
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: 0.2)
                                        : null,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Center(
                                    child: Text(e,
                                        style: const TextStyle(fontSize: 28))),
                              )))
                          .toList())),
            ));
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final accent = th.colorScheme.primary;
    final onSurface = th.colorScheme.onSurface;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Profilo')),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Avatar
          Center(
              child: Column(children: [
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickAvatar,
              child: Stack(children: [
                CircleAvatar(
                    radius: 52,
                    backgroundColor: accent.withValues(alpha: 0.12),
                    child: Text(_avatarEmoji,
                        style: const TextStyle(fontSize: 52))),
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: accent, shape: BoxShape.circle),
                        child: Icon(Icons.edit,
                            size: 14, color: th.colorScheme.onPrimary))),
              ]),
            ),
            const SizedBox(height: 4),
            Text('Tocca per cambiare',
                style: th.textTheme.bodyMedium?.copyWith(fontSize: 11)),
            const SizedBox(height: 12),
            GestureDetector(
                onTap: () =>
                    _editField('Nome', _name, (v) => setState(() => _name = v)),
                child: Text(_name.isEmpty ? 'Inserisci nome' : _name,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: onSurface))),
            if (_wcaId.isNotEmpty)
              Text('WCA: $_wcaId',
                  style: TextStyle(color: accent, fontSize: 13)),
          ])),

          const SizedBox(height: 24),
          _sec('INFORMAZIONI', th),
          _tile(
              th,
              Icons.badge_outlined,
              'Nome',
              _name.isEmpty ? 'Non impostato' : _name,
              () =>
                  _editField('Nome', _name, (v) => setState(() => _name = v))),
          _tile(
              th,
              Icons.emoji_events_outlined,
              'WCA ID',
              _wcaId.isEmpty ? 'Non impostato' : _wcaId,
              () => _editField('WCA ID (es. 2015MARC01)', _wcaId,
                  (v) => setState(() => _wcaId = v))),
          _tile(
              th,
              Icons.flag_outlined,
              'Paese',
              _country.isEmpty ? 'Non impostato' : _country,
              () => _editField(
                  'Paese', _country, (v) => setState(() => _country = v))),

          _sec('EVENTI PREFERITI', th),
          const SizedBox(height: 8),
          Wrap(
              spacing: 8,
              runSpacing: 8,
              children: EventType.defaults.map((e) {
                final isFav = _favEvents.contains(e.id);
                return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isFav) {
                          _favEvents.remove(e.id);
                        } else {
                          _favEvents.add(e.id);
                        }
                      });
                      _save();
                    },
                    child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                            color: isFav
                                ? accent.withValues(alpha: 0.15)
                                : th.cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: isFav ? accent : th.dividerColor,
                                width: isFav ? 1.5 : 1)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(e.emoji, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(e.name,
                              style: TextStyle(
                                  fontWeight:
                                      isFav ? FontWeight.w700 : FontWeight.w500,
                                  fontSize: 13,
                                  color: isFav ? accent : onSurface)),
                        ])));
              }).toList()),

          _sec('ALGORITMI APPRESI', th),
          const SizedBox(height: 4),
          ..._algSets.map((alg) {
            final learned = _learnedAlgs.contains(alg);
            return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (learned) {
                          _learnedAlgs.remove(alg);
                        } else {
                          _learnedAlgs.add(alg);
                        }
                      });
                      _save();
                    },
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                            color: learned
                                ? accent.withValues(alpha: 0.1)
                                : th.cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: learned
                                    ? accent.withValues(alpha: 0.4)
                                    : th.dividerColor)),
                        child: Row(children: [
                          Icon(
                              learned
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: learned
                                  ? accent
                                  : onSurface.withValues(alpha: 0.3),
                              size: 20),
                          const SizedBox(width: 12),
                          Text(alg,
                              style: TextStyle(
                                  fontWeight: learned
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: learned ? accent : onSurface)),
                        ]))));
          }),
        ]),
      ),
    );
  }

  Widget _sec(String t, ThemeData th) => Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(t,
          style: th.textTheme.labelSmall
              ?.copyWith(letterSpacing: 2, fontSize: 11)));

  Widget _tile(ThemeData th, IconData icon, String label, String value,
          VoidCallback onTap) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: GestureDetector(
              onTap: onTap,
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                      color: th.cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: th.dividerColor)),
                  child: Row(children: [
                    Icon(icon,
                        size: 20,
                        color: th.colorScheme.onSurface.withValues(alpha: 0.5)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(label,
                              style: th.textTheme.bodyMedium
                                  ?.copyWith(fontSize: 11)),
                          Text(value,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: th.colorScheme.onSurface)),
                        ])),
                    Icon(Icons.edit_outlined,
                        size: 16,
                        color: th.colorScheme.onSurface.withValues(alpha: 0.3)),
                  ]))));
}
