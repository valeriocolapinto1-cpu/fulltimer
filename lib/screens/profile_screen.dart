import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/event_type.dart';
import '../models/solve_time.dart';
import '../services/supabase_service.dart';
import '../services/wca_auth_service.dart';
import '../widgets/auth_dialog.dart';

const _wcaCountries = [
  'Afghanistan',
  'Albania',
  'Algeria',
  'Argentina',
  'Armenia',
  'Australia',
  'Austria',
  'Azerbaijan',
  'Bangladesh',
  'Belarus',
  'Belgium',
  'Bolivia',
  'Brazil',
  'Bulgaria',
  'Cambodia',
  'Canada',
  'Chile',
  'China',
  'Colombia',
  'Croatia',
  'Czech Republic',
  'Denmark',
  'Ecuador',
  'Egypt',
  'Estonia',
  'Finland',
  'France',
  'Georgia',
  'Germany',
  'Ghana',
  'Greece',
  'Hungary',
  'India',
  'Indonesia',
  'Iran',
  'Ireland',
  'Israel',
  'Italy',
  'Jamaica',
  'Japan',
  'Kazakhstan',
  'Kenya',
  'Latvia',
  'Lebanon',
  'Lithuania',
  'Malaysia',
  'Mexico',
  'Morocco',
  'Netherlands',
  'New Zealand',
  'Nigeria',
  'Norway',
  'Pakistan',
  'Panama',
  'Peru',
  'Philippines',
  'Poland',
  'Portugal',
  'Romania',
  'Russia',
  'Saudi Arabia',
  'Serbia',
  'Singapore',
  'Slovakia',
  'South Africa',
  'South Korea',
  'Spain',
  'Sri Lanka',
  'Sweden',
  'Switzerland',
  'Taiwan',
  'Thailand',
  'Turkey',
  'Ukraine',
  'United Kingdom',
  'United States',
  'Uruguay',
  'Venezuela',
  'Vietnam',
];

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileState();
}

class _ProfileState extends State<ProfileScreen> {
  String _name = '', _wcaId = '', _country = '', _avatarEmoji = '👤';
  String? _wcaAvatarUrl;
  List<String> _favEvents = [], _learnedAlgs = [];
  bool _loading = true, _wcaLoading = false;
  final _wca = WcaAuthService();
  final _sb = SupabaseService();
  Map<String, int?> _pbs = {};
  bool _pbLoading = false;

  static const _algSets = [
    'F2L Completo (41 casi)',
    'OLL Completo (57 casi)',
    'PLL Completo (21 casi)',
    'ZBLL',
    'COLL',
    'CMLL',
    '2x2 Ortega',
    '2x2 CLL',
    'Pyraminx L4E',
    "Skewb Sarah's Advanced",
    'Megaminx OLL/PLL',
    'Square-1 OLL+PLL',
    '4x4 OLL/PLL Parity',
    '5x5 Parity',
    'ZZ Method',
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
    '🌈',
    '🦋',
    '🎪',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _wca.init();
    final p = await SharedPreferences.getInstance();
    // Prefer WCA data if authenticated
    if (_wca.isAuthenticated && _wca.profile != null) {
      _autofillFromWca(_wca.profile!);
    } else {
      _name = p.getString('p_name') ?? '';
      _wcaId = p.getString('p_wca') ?? '';
      _country = p.getString('p_country') ?? '';
    }
    setState(() {
      _avatarEmoji = p.getString('p_avatar') ?? '👤';
      _wcaAvatarUrl = p.getString('p_wca_avatar');
      _favEvents = p.getStringList('p_fav') ?? [];
      _learnedAlgs = p.getStringList('p_alg') ?? [];
      _loading = false;
    });
    if (_sb.isLoggedIn) _loadPBs();
  }

  void _autofillFromWca(Map<String, dynamic> wp) {
    _name = (wp['name'] as String?) ?? _name;
    _wcaId = (wp['wca_id'] as String?) ?? _wcaId;
    _country = (wp['country'] as Map?)?['name'] as String? ?? _country;
    // WCA avatar URL
    final avatar = wp['avatar'] as Map?;
    _wcaAvatarUrl = (avatar?['url'] as String?);
  }

  Future<void> _loadPBs() async {
    setState(() => _pbLoading = true);
    const events = ['3x3','2x2','4x4','5x5','oh','pyra','skewb','mega','clock','sq1'];
    final results = <String, int?>{};
    for (final e in events) {
      final pb = await _sb.getPersonalBest(e);
      results[e] = pb?['ao5'] as int?;
    }
    if (mounted) setState(() { _pbs = results; _pbLoading = false; });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await Future.wait([
      p.setString('p_name', _name),
      p.setString('p_wca', _wcaId),
      p.setString('p_country', _country),
      p.setString('p_avatar', _avatarEmoji),
      if (_wcaAvatarUrl != null) p.setString('p_wca_avatar', _wcaAvatarUrl!),
      p.setStringList('p_fav', _favEvents),
      p.setStringList('p_alg', _learnedAlgs),
    ]);
  }

  // ── WCA Login: open browser ──────────────────────────────────
  Future<void> _wcaLogin() async {
    setState(() => _wcaLoading = true);
    try {
      if (!_wca.isConfigured) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Configurazione WCA mancante. Imposta WCA_CLIENT_ID.'),
              behavior: SnackBarBehavior.floating));
        }
        return;
      }
      final url = await _wca.beginAuthFlow();
      final authUrl = Uri.parse(url);
      if (await canLaunchUrl(authUrl)) {
        await launchUrl(authUrl, mode: LaunchMode.externalApplication);
        if (mounted) _showCodeDialog();
      } else {
        // Fallback: show URL to copy
        if (mounted) _showCodeDialog(showUrl: url);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Impossibile avviare login WCA'),
            behavior: SnackBarBehavior.floating));
      }
    } finally {
      if (mounted) setState(() => _wcaLoading = false);
    }
  }

  void _showCodeDialog({String? showUrl}) {
    final codeCtrl = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(c).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(children: [
                  const Icon(Icons.lock_outline, size: 20),
                  const SizedBox(width: 8),
                  const Text('Login WCA',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(c),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints()),
                ]),
              ),
              const Divider(height: 20),
              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '1. Il browser si è aperto — autorizza l\'app WCA\n'
                        '2. Copia il codice ricevuto\n'
                        '3. Incollalo qui sotto',
                        style: TextStyle(fontSize: 13),
                      ),
                      if (showUrl != null) ...[
                        const SizedBox(height: 10),
                        const Text('URL da aprire manualmente:',
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        GestureDetector(
                            onTap: () =>
                                Clipboard.setData(ClipboardData(text: showUrl)),
                            child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius: BorderRadius.circular(6)),
                                child: Text(showUrl,
                                    style: const TextStyle(
                                        fontSize: 10, fontFamily: 'monospace'),
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis))),
                        TextButton.icon(
                            onPressed: () =>
                                Clipboard.setData(ClipboardData(text: showUrl)),
                            icon: const Icon(Icons.copy, size: 14),
                            label: const Text('Copia URL',
                                style: TextStyle(fontSize: 12))),
                      ],
                      const SizedBox(height: 12),
                      TextField(
                        controller: codeCtrl,
                        autofocus: false,
                        decoration: const InputDecoration(
                            hintText: 'Incolla il codice OAuth2...',
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            isDense: true),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              // Action buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text('Annulla')),
                  const SizedBox(width: 8),
                  FilledButton(
                      onPressed: () async {
                        final rawInput = codeCtrl.text.trim();
                        Navigator.pop(c);
                        if (rawInput.isEmpty) return;
                        String code = rawInput;
                        String? returnedState;
                        if (rawInput.contains('://')) {
                          try {
                            final callbackUri = Uri.parse(rawInput);
                            code = callbackUri.queryParameters['code'] ?? '';
                            returnedState = callbackUri.queryParameters['state'];
                          } catch (_) {}
                        }
                        if (code.isEmpty) return;
                        setState(() => _wcaLoading = true);
                        final ok = await _wca.handleCallback(code, state: returnedState);
                        if (ok && mounted) {
                          final wp = _wca.profile;
                          if (wp != null) {
                            setState(() {
                              _autofillFromWca(wp);
                            });
                            await _save();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          '✓ Login WCA completato! Dati sincronizzati.'),
                                      behavior: SnackBarBehavior.floating));
                            }
                          }
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('❌ Codice non valido, riprova.'),
                                  behavior: SnackBarBehavior.floating));
                        }
                        if (mounted) setState(() => _wcaLoading = false);
                      },
                      child: const Text('Conferma')),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _wcaLogout() async {
    await _wca.signOut();
    final p = await SharedPreferences.getInstance();
    await p.remove('p_wca_avatar');
    setState(() {
      _wcaAvatarUrl = null;
    });
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Disconnesso da WCA'),
          behavior: SnackBarBehavior.floating));
  }

  void _editText(String label, String cur, void Function(String) fn) {
    final ctrl = TextEditingController(text: cur);
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
                        fn(ctrl.text);
                        _save();
                        Navigator.pop(c);
                      },
                      child: const Text('Salva')),
                ])));
  }

  void _pickCountry() {
    final ctrl = TextEditingController();
    List<String> filtered = List.from(_wcaCountries);
    showDialog(
        context: context,
        builder: (c) => StatefulBuilder(
            builder: (c, ss) => AlertDialog(
                title: const Text('Seleziona paese'),
                content: SizedBox(
                    width: 320,
                    height: 400,
                    child: Column(children: [
                      TextField(
                          controller: ctrl,
                          decoration: const InputDecoration(
                              hintText: 'Cerca...',
                              prefixIcon: Icon(Icons.search, size: 18)),
                          onChanged: (v) => ss(() => filtered = _wcaCountries
                              .where((x) =>
                                  x.toLowerCase().contains(v.toLowerCase()))
                              .toList())),
                      const SizedBox(height: 8),
                      Expanded(
                          child: ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (_, i) => ListTile(
                                  title: Text(filtered[i],
                                      style: const TextStyle(fontSize: 14)),
                                  trailing: filtered[i] == _country
                                      ? const Icon(Icons.check,
                                          color: Color(0xFF30D158), size: 16)
                                      : null,
                                  onTap: () {
                                    setState(() => _country = filtered[i]);
                                    _save();
                                    Navigator.pop(c);
                                  }))),
                    ])))));
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
                              setState(() {
                                _avatarEmoji = e;
                                _wcaAvatarUrl = null;
                              });
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
                                            .withValues(alpha: 0.18)
                                        : null,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Center(
                                    child: Text(e,
                                        style:
                                            const TextStyle(fontSize: 28))))))
                        .toList()))));
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final accent = th.colorScheme.primary;
    final onSurf = th.colorScheme.onSurface;

    if (_loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Profilo')),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── WCA Connect Card ───────────────────────────
          _wcaCard(th, accent),

          // ── Supabase Account Card ─────────────────────
          _supabaseCard(th, accent),

          // ── Avatar + Name ──────────────────────────────
          Center(
              child: Column(children: [
            const SizedBox(height: 8),
            GestureDetector(
                onTap: _wcaAvatarUrl == null ? _pickAvatar : null,
                child: Stack(children: [
                  CircleAvatar(
                      radius: 52,
                      backgroundColor: accent.withValues(alpha: 0.12),
                      backgroundImage: _wcaAvatarUrl != null
                          ? NetworkImage(_wcaAvatarUrl!)
                          : null,
                      child: _wcaAvatarUrl == null
                          ? Text(_avatarEmoji,
                              style: const TextStyle(fontSize: 52))
                          : null),
                  if (_wcaAvatarUrl == null)
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                color: accent, shape: BoxShape.circle),
                            child: Icon(Icons.edit,
                                size: 14, color: th.colorScheme.onPrimary))),
                ])),
            if (_wcaAvatarUrl == null)
              Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('Tocca per cambiare',
                      style: th.textTheme.bodyMedium?.copyWith(fontSize: 11))),
            if (_wcaAvatarUrl != null)
              Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('Foto profilo WCA',
                      style: th.textTheme.bodyMedium?.copyWith(
                          fontSize: 11, color: const Color(0xFF30D158)))),
            const SizedBox(height: 10),
            GestureDetector(
                onTap: () =>
                    _editText('Nome', _name, (v) => setState(() => _name = v)),
                child: Text(_name.isEmpty ? 'Inserisci nome' : _name,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: onSurf))),
            if (_wcaId.isNotEmpty)
              Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('WCA: $_wcaId',
                      style: TextStyle(
                          color: accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w600))),
          ])),

          const SizedBox(height: 20),
          _sec('INFORMAZIONI', th),
          _tile(
              th,
              Icons.badge_outlined,
              'Nome',
              _name.isEmpty ? 'Non impostato' : _name,
              () => _editText('Nome', _name, (v) => setState(() => _name = v))),
          _tile(
              th,
              Icons.emoji_events_outlined,
              'WCA ID',
              _wcaId.isEmpty ? 'Non impostato' : _wcaId,
              () => _editText('WCA ID (es. 2015MARC01)', _wcaId,
                  (v) => setState(() => _wcaId = v))),
          _tile(th, Icons.flag_outlined, 'Paese',
              _country.isEmpty ? 'Seleziona paese' : _country, _pickCountry),

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
                        if (isFav)
                          _favEvents.remove(e.id);
                        else
                          _favEvents.add(e.id);
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
                                  color: isFav ? accent : onSurf)),
                        ])));
              }).toList()),

          _sec('RECORD ONLINE', th),
          if (_pbLoading)
            const Padding(padding: EdgeInsets.all(8), child: Center(child: SizedBox(width:20,height:20,child:CircularProgressIndicator(strokeWidth:2))))
          else ...[
            const SizedBox(height:4),
            Wrap(spacing:6, runSpacing:6, children:_pbs.entries.map((e) {
              final t = e.value;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal:10, vertical:6),
                decoration:BoxDecoration(color:th.cardColor, borderRadius:BorderRadius.circular(10),
                    border:Border.all(color:th.dividerColor)),
                child: Row(mainAxisSize:MainAxisSize.min, children:[
                  Text(e.key.toUpperCase(), style:TextStyle(fontSize:10, fontWeight:FontWeight.w600, color:accent)),
                  const SizedBox(width:6),
                  Text(t!=null ? SolveTime.format(t) : '-', style:const TextStyle(fontFamily:'monospace', fontSize:13, fontWeight:FontWeight.w700)),
                ]));
            }).toList()),
          ],

          _sec('ALGORITMI APPRESI', th),
          const SizedBox(height: 4),
          ..._algSets.map((alg) {
            final learned = _learnedAlgs.contains(alg);
            return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (learned)
                          _learnedAlgs.remove(alg);
                        else
                          _learnedAlgs.add(alg);
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
                                  : onSurf.withValues(alpha: 0.3),
                              size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(alg,
                                  style: TextStyle(
                                      fontWeight: learned
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: learned ? accent : onSurf))),
                        ]))));
          }),
        ]),
      ),
    );
  }

  Widget _supabaseCard(ThemeData th, Color accent) {
    final isAuth = _sb.isLoggedIn;
    return GestureDetector(
        onTap: isAuth ? null : () async {
          final ok = await showDialog<bool>(context: context, builder: (_) => const AuthDialog());
          if (ok == true && mounted) { setState(() {}); _loadPBs(); }
        },
        child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
                color: isAuth ? accent.withValues(alpha: 0.08) : th.cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: th.dividerColor)),
            child: Row(children: [
              Icon(isAuth ? Icons.account_circle : Icons.person_add_outlined,
                  color: isAuth ? accent : th.colorScheme.onSurface.withValues(alpha: 0.5)),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(isAuth ? _sb.currentUser!.email ?? 'Account' : 'Account FullTimer',
                    style: TextStyle(fontWeight: FontWeight.w700,
                        color: isAuth ? accent : th.colorScheme.onSurface)),
                Text(isAuth ? 'Dati sincronizzati sul cloud' : 'Registrati per salvare i risultati',
                    style: th.textTheme.bodyMedium?.copyWith(fontSize: 11)),
              ])),
              if (isAuth)
                TextButton(
                    onPressed: () async {
                      await _sb.signOut();
                      setState(() { _pbs = {}; });
                    },
                    child: Text('Esci', style: TextStyle(color: th.colorScheme.error, fontSize: 12)))
              else
                Icon(Icons.chevron_right, size: 18, color: th.colorScheme.onSurface.withValues(alpha: 0.3)),
            ])));
  }

  Widget _wcaCard(ThemeData th, Color accent) {
    final isAuth = _wca.isAuthenticated;
    return GestureDetector(
        onTap: isAuth ? null : _wcaLogin,
        child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
                color: isAuth
                    ? const Color(0xFF30D158).withValues(alpha: 0.1)
                    : accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: isAuth
                        ? const Color(0xFF30D158).withValues(alpha: 0.4)
                        : accent.withValues(alpha: 0.3))),
            child: Row(children: [
              Icon(isAuth ? Icons.check_circle : Icons.link,
                  color: isAuth ? const Color(0xFF30D158) : accent),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(isAuth ? '✓ WCA Collegato' : 'Collega account WCA',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isAuth ? const Color(0xFF30D158) : accent)),
                    Text(
                        isAuth
                            ? 'Foto e dati sincronizzati automaticamente'
                            : 'Tocca per aprire il browser e fare il login',
                        style: th.textTheme.bodyMedium?.copyWith(fontSize: 11)),
                  ])),
              if (_wcaLoading)
                const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
              else if (isAuth)
                TextButton(
                    onPressed: _wcaLogout,
                    child: Text('Disconnetti',
                        style: TextStyle(
                            color: th.colorScheme.error, fontSize: 12)))
              else
                Icon(Icons.open_in_browser, color: accent, size: 18),
            ])));
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
                    Icon(Icons.chevron_right,
                        size: 18,
                        color: th.colorScheme.onSurface.withValues(alpha: 0.3)),
                  ]))));
}
