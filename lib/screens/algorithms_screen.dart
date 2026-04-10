import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// Algoritmi con livello: 0=base, 1=avanzato, 2=elite
// Immagine: URL a cube visualizer (cubing.net/visual o cube.rider.biz)
// Formato immagine: stringa che descrive il caso visivamente
const _algs = <Map<String, dynamic>>[
  // ── F2L ─────────────────────────────────────────────────
  {
    'cat': 'F2L',
    'name': 'F2L Caso 1',
    'alg': 'U R U\' R\'',
    'level': 0,
    'img': 'f2l_1',
    'desc': 'Angolo e bordo già abbinati in alto'
  },
  {
    'cat': 'F2L',
    'name': 'F2L Caso 2',
    'alg': 'U\' F\' U F',
    'level': 0,
    'img': 'f2l_2',
    'desc': 'Abbinamento inverso'
  },
  {
    'cat': 'F2L',
    'name': 'F2L Caso 3',
    'alg': 'R U R\' U\' R U R\' U\' R U R\'',
    'level': 0,
    'img': 'f2l_3',
    'desc': 'Entrambi slot adiacenti'
  },
  {
    'cat': 'F2L',
    'name': 'F2L Caso 4',
    'alg': 'F\' U\' F U F\' U\' F',
    'level': 0,
    'img': 'f2l_4',
    'desc': ''
  },
  {
    'cat': 'F2L',
    'name': 'F2L Caso 5',
    'alg': 'R U\' R\' d R\' U R',
    'level': 1,
    'img': 'f2l_5',
    'desc': ''
  },
  {
    'cat': 'F2L',
    'name': 'F2L Caso 6',
    'alg': 'R U2\' R\' U\' R U R\'',
    'level': 1,
    'img': 'f2l_6',
    'desc': ''
  },
  {
    'cat': 'F2L',
    'name': 'F2L Caso 7',
    'alg': 'U R U2\' R\' U R U\' R\'',
    'level': 1,
    'img': 'f2l_7',
    'desc': ''
  },
  {
    'cat': 'F2L',
    'name': 'F2L Caso 8',
    'alg': 'R U R\' U2\' R U\' R\'',
    'level': 1,
    'img': 'f2l_8',
    'desc': ''
  },
  // ── OLL ─────────────────────────────────────────────────
  {
    'cat': 'OLL',
    'name': 'OLL 1 (Dot)',
    'alg': 'R U2\' R2\' F R F\' U2\' R\' F R F\'',
    'level': 1,
    'img': 'oll_1',
    'desc': 'Nessun pezzo giallo orientato'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 2 (Dot)',
    'alg': 'F R U R\' U\' F\' f R U R\' U\' f\'',
    'level': 1,
    'img': 'oll_2',
    'desc': ''
  },
  {
    'cat': 'OLL',
    'name': 'OLL 21 (H)',
    'alg': 'R U R\' U R U\' R\' U R U2\' R\'',
    'level': 0,
    'img': 'oll_21',
    'desc': 'Forma H sul top'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 22 (Pi)',
    'alg': 'R U2\' R2\' U\' R2 U\' R2\' U2\' R',
    'level': 0,
    'img': 'oll_22',
    'desc': 'Forma Pi'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 23 (Sune)',
    'alg': 'R U R\' U R U2\' R\'',
    'level': 0,
    'img': 'oll_23',
    'desc': 'Sune - caso più comune'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 24 (Anti-Sune)',
    'alg': 'R U2\' R\' U\' R U\' R\'',
    'level': 0,
    'img': 'oll_24',
    'desc': 'Anti-Sune'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 25 (T)',
    'alg': 'F R U R\' U\' F\'',
    'level': 0,
    'img': 'oll_25',
    'desc': 'Forma T'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 26 (L)',
    'alg': 'R\' U\' R U\' R\' U2\' R',
    'level': 0,
    'img': 'oll_26',
    'desc': 'Forma L sinistra'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 27 (L mirror)',
    'alg': 'R U R\' U R U2\' R\'',
    'level': 0,
    'img': 'oll_27',
    'desc': 'Forma L destra'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 33 (T)',
    'alg': 'R U R\' U\' R\' F R F\'',
    'level': 1,
    'img': 'oll_33',
    'desc': 'T con bordi'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 37 (Fish)',
    'alg': 'F R\' F\' R U R U\' R\'',
    'level': 1,
    'img': 'oll_37',
    'desc': 'Pesce'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 57 (H)',
    'alg': 'R U R\' U\' M\' U R U\' r\'',
    'level': 1,
    'img': 'oll_57',
    'desc': 'H con M-slice'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 29',
    'alg': 'R U R\' U\' R U\' R\' F\' U\' F R U R\'',
    'level': 2,
    'img': 'oll_29',
    'desc': ''
  },
  {
    'cat': 'OLL',
    'name': 'OLL 30',
    'alg': 'F R\' F R2 U\' R\' U\' R U R\' F2\' ',
    'level': 2,
    'img': 'oll_30',
    'desc': ''
  },
  {
    'cat': 'OLL',
    'name': 'OLL 44',
    'alg': 'F U R U\' R\' F\'',
    'level': 0,
    'img': 'oll_44',
    'desc': ''
  },
  {
    'cat': 'OLL',
    'name': 'OLL 45',
    'alg': 'F R U R\' U\' F\'',
    'level': 0,
    'img': 'oll_45',
    'desc': ''
  },
  // ── PLL ─────────────────────────────────────────────────
  {
    'cat': 'PLL',
    'name': 'PLL Ua',
    'alg': 'R U\' R U R U R U\' R\' U\' R2',
    'level': 0,
    'img': 'pll_ua',
    'desc': '3 angoli ciclici'
  },
  {
    'cat': 'PLL',
    'name': 'PLL Ub',
    'alg': 'R2 U R U R\' U\' R\' U\' R\' U R\'',
    'level': 0,
    'img': 'pll_ub',
    'desc': '3 angoli anticiclici'
  },
  {
    'cat': 'PLL',
    'name': 'PLL H',
    'alg': 'M2\' U M2\' U2\' M2\' U M2\'',
    'level': 0,
    'img': 'pll_h',
    'desc': 'Scambio opposto bordi'
  },
  {
    'cat': 'PLL',
    'name': 'PLL Z',
    'alg': 'M2\' U M2\' U M\' U2\' M2\' U2\' M\' U2\'',
    'level': 0,
    'img': 'pll_z',
    'desc': 'Scambio adiacente bordi'
  },
  {
    'cat': 'PLL',
    'name': 'PLL T',
    'alg': 'R U R\' U\' R\' F R2 U\' R\' U\' R U R\' F\'',
    'level': 0,
    'img': 'pll_t',
    'desc': ''
  },
  {
    'cat': 'PLL',
    'name': 'PLL Aa',
    'alg': 'x R\' U R\' D2\' R U\' R\' D2\' R2',
    'level': 1,
    'img': 'pll_aa',
    'desc': ''
  },
  {
    'cat': 'PLL',
    'name': 'PLL Ab',
    'alg': 'x R2 D2\' R U R\' D2\' R U\' R',
    'level': 1,
    'img': 'pll_ab',
    'desc': ''
  },
  {
    'cat': 'PLL',
    'name': 'PLL F',
    'alg': 'R\' U\' F\' R U R\' U\' R\' F R2 U\' R\' U\' R U R\' U R',
    'level': 1,
    'img': 'pll_f',
    'desc': ''
  },
  {
    'cat': 'PLL',
    'name': 'PLL Ja',
    'alg': 'x R2\' F R F\' R U2\' r\' U r U2\'',
    'level': 1,
    'img': 'pll_ja',
    'desc': ''
  },
  {
    'cat': 'PLL',
    'name': 'PLL Jb',
    'alg': 'R U R\' F\' R U R\' U\' R\' F R2 U\' R\'',
    'level': 1,
    'img': 'pll_jb',
    'desc': ''
  },
  {
    'cat': 'PLL',
    'name': 'PLL Ra',
    'alg': 'R U R\' F\' R U2\' R\' U2\' R\' F R U R U2\' R\'',
    'level': 1,
    'img': 'pll_ra',
    'desc': ''
  },
  {
    'cat': 'PLL',
    'name': 'PLL Rb',
    'alg': 'R\' U2\' R U2\' R\' F R U R\' U\' R\' F\' R2',
    'level': 1,
    'img': 'pll_rb',
    'desc': ''
  },
  {
    'cat': 'PLL',
    'name': 'PLL V',
    'alg': 'R\' U R\' d\' R\' F\' R2 U\' R\' U R\' F R F',
    'level': 1,
    'img': 'pll_v',
    'desc': ''
  },
  {
    'cat': 'PLL',
    'name': 'PLL Y',
    'alg': 'F R U\' R\' U\' R U R\' F\' R U R\' U\' R\' F R F\'',
    'level': 1,
    'img': 'pll_y',
    'desc': ''
  },
  {
    'cat': 'PLL',
    'name': 'PLL Na',
    'alg': 'R U R\' U R U R\' F\' R U R\' U\' R\' F R2 U\' R\' U2\' R U\' R\'',
    'level': 2,
    'img': 'pll_na',
    'desc': 'Più difficile'
  },
  {
    'cat': 'PLL',
    'name': 'PLL Nb',
    'alg': 'R\' U L\' U2\' R U\' L R\' U L\' U2\' R U\' L U2\'',
    'level': 2,
    'img': 'pll_nb',
    'desc': ''
  },
  {
    'cat': 'PLL',
    'name': 'PLL E',
    'alg': 'x\' R U\' R\' D R U R\' D\' R U R\' D R U\' R\' D\'',
    'level': 2,
    'img': 'pll_e',
    'desc': ''
  },
  {
    'cat': 'PLL',
    'name': 'PLL Ga',
    'alg': 'R2 U R\' U R\' U\' R U\' R2 D U\' R\' U R D\'',
    'level': 2,
    'img': 'pll_ga',
    'desc': ''
  },
  // ── 2x2 ─────────────────────────────────────────────────
  {
    'cat': '2x2',
    'name': '2x2 OLL 1',
    'alg': 'R U R\' U R U2\' R\'',
    'level': 0,
    'img': '2x2_oll1',
    'desc': 'Sune'
  },
  {
    'cat': '2x2',
    'name': '2x2 OLL 2',
    'alg': 'F R U R\' U\' F\'',
    'level': 0,
    'img': '2x2_oll2',
    'desc': ''
  },
  {
    'cat': '2x2',
    'name': '2x2 OLL 3',
    'alg': 'R U2\' R\' U\' R U\' R\'',
    'level': 0,
    'img': '2x2_oll3',
    'desc': ''
  },
  {
    'cat': '2x2',
    'name': '2x2 OLL 4',
    'alg': 'R U R\' U\' R U\' R\' F\' U\' F',
    'level': 1,
    'img': '2x2_oll4',
    'desc': ''
  },
  {
    'cat': '2x2',
    'name': '2x2 OLL 5',
    'alg': 'F\' r U r\' U\' r\' F r',
    'level': 1,
    'img': '2x2_oll5',
    'desc': ''
  },
  {
    'cat': '2x2',
    'name': '2x2 OLL 6',
    'alg': 'R U2\' R U2\' R\' F R F\'',
    'level': 1,
    'img': '2x2_oll6',
    'desc': ''
  },
  {
    'cat': '2x2',
    'name': '2x2 OLL 7',
    'alg': 'R U R\' U\' R\' F R F\'',
    'level': 1,
    'img': '2x2_oll7',
    'desc': ''
  },
  {
    'cat': '2x2',
    'name': 'PBL Ua',
    'alg': 'R U\' R U R U R U\' R\' U\' R2',
    'level': 0,
    'img': 'pbl_ua',
    'desc': ''
  },
  {
    'cat': '2x2',
    'name': 'PBL Ub',
    'alg': 'R2 U R U R\' U\' R\' U\' R\' U R\'',
    'level': 0,
    'img': 'pbl_ub',
    'desc': ''
  },
  {
    'cat': '2x2',
    'name': 'PBL Z',
    'alg': 'M\' U\' M2\' U\' M2\' U\' M\' U2\' M2\'',
    'level': 1,
    'img': 'pbl_z',
    'desc': ''
  },
  // ── Pyraminx ─────────────────────────────────────────────
  {
    'cat': 'Pyraminx',
    'name': 'L4E 1',
    'alg': 'R U R\' U R U2\' R\' U',
    'level': 0,
    'img': 'pyra_1',
    'desc': ''
  },
  {
    'cat': 'Pyraminx',
    'name': 'L4E 2',
    'alg': 'U\' R U\' R\' U R\' U R',
    'level': 0,
    'img': 'pyra_2',
    'desc': ''
  },
  {
    'cat': 'Pyraminx',
    'name': 'L4E 3',
    'alg': 'R U R\' U\' R U R\'',
    'level': 0,
    'img': 'pyra_3',
    'desc': ''
  },
  {
    'cat': 'Pyraminx',
    'name': 'L4E 4',
    'alg': 'R\' U R U\' R\' U\' R',
    'level': 0,
    'img': 'pyra_4',
    'desc': ''
  },
];

const _levels = ['Base', 'Avanzato', 'Elite'];
const _levelColors = [Color(0xFF30D158), Color(0xFFFF9F0A), Color(0xFFFF453A)];

class AlgorithmsScreen extends StatefulWidget {
  const AlgorithmsScreen({super.key});
  @override
  State<AlgorithmsScreen> createState() => _AlgScreenState();
}

class _AlgScreenState extends State<AlgorithmsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _search = '';
  final _searchCtrl = TextEditingController();
  // Livello selezionato: null = tutti
  int? _levelFilter;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<String> get _cats {
    final all = _algs.map((a) => a['cat'] as String).toSet().toList();
    return all;
  }

  List<Map<String, dynamic>> _filtered(String cat) {
    return _algs.where((a) {
      if (a['cat'] != cat) return false;
      if (_levelFilter != null && a['level'] != _levelFilter) return false;
      if (_search.isNotEmpty) {
        return (a['name'] as String)
                .toLowerCase()
                .contains(_search.toLowerCase()) ||
            (a['alg'] as String).toLowerCase().contains(_search.toLowerCase());
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final accent = th.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Algoritmi'),
        bottom: TabBar(
            controller: _tab,
            labelColor: accent,
            unselectedLabelColor:
                th.colorScheme.onSurface.withValues(alpha: 0.5),
            indicatorColor: accent,
            isScrollable: true,
            tabs: _cats.map((c) => Tab(text: c)).toList()),
      ),
      body: Column(children: [
        // Search + level filter
        Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(children: [
              Expanded(
                  child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _search = v),
                      decoration: InputDecoration(
                          hintText: 'Cerca...',
                          prefixIcon: const Icon(Icons.search, size: 18),
                          suffixIcon: _search.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 16),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() => _search = '');
                                  })
                              : null))),
              const SizedBox(width: 8),
              PopupMenuButton<int?>(
                  icon: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: _levelFilter != null
                              ? _levelColors[_levelFilter!]
                                  .withValues(alpha: 0.15)
                              : th.cardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: th.dividerColor)),
                      child: Text(
                          _levelFilter != null
                              ? _levels[_levelFilter!]
                              : 'Tutti',
                          style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: _levelFilter != null
                                  ? _levelColors[_levelFilter!]
                                  : th.colorScheme.onSurface))),
                  onSelected: (v) => setState(() => _levelFilter = v),
                  itemBuilder: (_) => [
                        PopupMenuItem(
                            value: null,
                            child: Text('Tutti', style: GoogleFonts.nunito())),
                        ...List.generate(
                            3,
                            (i) => PopupMenuItem(
                                value: i,
                                child: Row(children: [
                                  Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                          color: _levelColors[i],
                                          shape: BoxShape.circle)),
                                  const SizedBox(width: 8),
                                  Text(_levels[i], style: GoogleFonts.nunito()),
                                ]))),
                      ]),
            ])),
        // Content
        Expanded(
            child: TabBarView(
                controller: _tab,
                children: _cats.map((cat) {
                  final algs = _filtered(cat);
                  if (algs.isEmpty) {
                    return Center(
                        child: Text('Nessun algoritmo',
                            style: th.textTheme.bodyMedium));
                  }
                  return ListView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                      children: algs
                          .map((a) =>
                              _AlgCard(alg: a, theme: th, accent: accent))
                          .toList());
                }).toList())),
      ]),
    );
  }
}

class _AlgCard extends StatefulWidget {
  final Map<String, dynamic> alg;
  final ThemeData theme;
  final Color accent;
  const _AlgCard(
      {required this.alg, required this.theme, required this.accent});
  @override
  State<_AlgCard> createState() => _AlgCardState();
}

class _AlgCardState extends State<_AlgCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.alg;
    final th = widget.theme;
    final accent = widget.accent;
    final level = a['level'] as int;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: th.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: th.dividerColor)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    color: _levelColors[level], shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Expanded(
                child: Text(a['name'],
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: th.colorScheme.onSurface))),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: _levelColors[level].withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(_levels[level],
                    style: GoogleFonts.nunito(
                        fontSize: 10,
                        color: _levelColors[level],
                        fontWeight: FontWeight.w700))),
            const SizedBox(width: 8),
            Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                size: 16,
                color: th.colorScheme.onSurface.withValues(alpha: 0.4)),
          ]),
          const SizedBox(height: 6),
          // Algoritmo
          Row(children: [
            Expanded(
                child: Text(a['alg'],
                    style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: Color(0xFF6C63FF),
                        letterSpacing: 0.3))),
            IconButton(
                icon: const Icon(Icons.copy, size: 14),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: th.colorScheme.onSurface.withValues(alpha: 0.3),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: a['alg']));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Copiato!', style: GoogleFonts.nunito()),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))));
                }),
          ]),
          if (_expanded) ...[
            const SizedBox(height: 10),
            // Immagine esplicativa: cube visualizer
            _CaseVisualizer(
                caseId: a['img'] ?? '',
                cat: a['cat'] ?? '',
                theme: th,
                accent: accent),
            if ((a['desc'] as String).isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(a['desc'],
                  style: th.textTheme.bodyMedium?.copyWith(fontSize: 12)),
            ],
          ],
        ]),
      ),
    );
  }
}

// Visualizzatore del caso: disegna una rappresentazione 2D del top del cubo
class _CaseVisualizer extends StatelessWidget {
  final String caseId, cat;
  final ThemeData theme;
  final Color accent;
  const _CaseVisualizer(
      {required this.caseId,
      required this.cat,
      required this.theme,
      required this.accent});

  @override
  Widget build(BuildContext context) {
    // Genera un pattern visivo basato sull'ID del caso
    // Per OLL: mostra faccia top con orientamento stickers
    // Per PLL: mostra frecce di permutazione
    return Container(
      height: 90,
      decoration: BoxDecoration(
          color: theme.dividerColor, borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        Expanded(
            child: CustomPaint(
                painter:
                    _CasePainter(caseId: caseId, cat: cat, accent: accent))),
        // Info URL
        Padding(
            padding: const EdgeInsets.all(8),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.grid_3x3, color: accent, size: 28),
              const SizedBox(height: 4),
              Text('Vista\ntop',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 9)),
            ])),
      ]),
    );
  }
}

class _CasePainter extends CustomPainter {
  final String caseId, cat;
  final Color accent;
  _CasePainter({required this.caseId, required this.cat, required this.accent});

  static const _yc = Color(0xFFFFD500);
  static const _gc = Color(0xFF888888); // grigio = non orientato

  // Definisce quali sticker sono gialli per ogni caso OLL
  // Lista 9 booleani: [tl, tc, tr, ml, cc, mr, bl, bc, br] — cc sempre true
  static const _ollMap = <String, List<bool>>{
    'oll_21': [true, false, true, false, true, false, true, false, true], // H
    'oll_22': [false, true, false, true, true, true, false, true, false], // Pi
    'oll_23': [
      false,
      false,
      true,
      false,
      true,
      true,
      true,
      false,
      true
    ], // Sune
    'oll_24': [
      true,
      false,
      false,
      true,
      true,
      false,
      true,
      false,
      true
    ], // Anti-sune
    'oll_25': [false, false, false, false, true, true, false, true, false], // T
    'oll_26': [false, false, false, false, true, false, false, false, true],
    'oll_27': [true, false, false, false, true, false, false, false, false],
    'oll_33': [false, false, true, false, true, true, false, false, false],
    'oll_37': [false, true, false, false, true, false, false, false, true],
    'oll_44': [false, false, false, false, true, true, false, false, false],
    'oll_45': [false, false, false, false, true, true, false, true, false],
    'oll_57': [false, true, false, true, true, true, false, true, false],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.height / 3 - 2;
    final startX = (size.width - cellSize * 3 - 4) / 2;
    final startY = 2.0;

    List<bool> pattern;
    if (cat == 'OLL' || cat == '2x2') {
      pattern = _ollMap[caseId] ?? List.filled(9, true);
    } else if (cat == 'PLL') {
      // PLL: tutti gialli, frecce mostrate
      pattern = List.filled(9, true);
    } else {
      pattern = List.filled(9, true);
    }

    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        final idx = r * 3 + c;
        final isYellow = pattern[idx];
        final rect = RRect.fromRectAndRadius(
            Rect.fromLTWH(startX + c * (cellSize + 2),
                startY + r * (cellSize + 2), cellSize, cellSize),
            Radius.circular(cellSize * 0.15));
        canvas.drawRRect(rect, Paint()..color = isYellow ? _yc : _gc);
        canvas.drawRRect(
            rect,
            Paint()
              ..color = Colors.black.withValues(alpha: 0.25)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.5);
      }
    }

    // Frecce PLL
    if (cat == 'PLL') {
      _drawPllArrows(canvas, size, startX, startY, cellSize);
    }
  }

  void _drawPllArrows(
      Canvas canvas, Size size, double sx, double sy, double cell) {
    // Hash dell'id per generare un pattern semi-deterministico
    final h = caseId.hashCode.abs() % 4;
    final arrowP = Paint()
      ..color = accent.withValues(alpha: 0.8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    // Freccia semplice dall'alto verso destra
    final y = sy + cell * 1.5;
    final x1 = sx + cell * 0.5 + h * 2.0;
    final x2 = sx + cell * 2.5;
    canvas.drawLine(Offset(x1, y), Offset(x2, y), arrowP);
    canvas.drawLine(Offset(x2 - 4, y - 3), Offset(x2, y), arrowP);
    canvas.drawLine(Offset(x2 - 4, y + 3), Offset(x2, y), arrowP);
  }

  @override
  bool shouldRepaint(_CasePainter o) => false;
}
