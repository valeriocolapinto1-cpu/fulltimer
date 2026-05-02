import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'providers/l10n_provider.dart';
import 'theme/app_theme.dart';
import 'screens/timer_screen.dart';
import 'screens/times_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/battle_screen.dart';
import 'screens/online_competition_screen.dart';
import 'screens/algorithms_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';

class SpeedCubeApp extends StatelessWidget {
  const SpeedCubeApp({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    final l = context.watch<L10n>();
    return MaterialApp(
      title: 'SpeedCube Timer',
      debugShowCheckedModeBanner: false,
      locale: Locale(l.lang),
      theme: AppTheme.build(dark: s.darkMode, accent: s.accentColor, fontFamily: s.fontFamily, transparent: s.useGradient),
      home: const _Shell(),
    );
  }
}

class _Shell extends StatefulWidget {
  const _Shell();
  @override State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int _idx = 0;
  late final PageController _pc;
  @override void initState() { super.initState(); _pc = PageController(); }
  @override void dispose() { _pc.dispose(); super.dispose(); }

  // Main nav screens (4 bottom nav items)
  static const _mainScreens = [TimerScreen(), TimesScreen(), StatsScreen(), BattleScreen()];

  void _go(int i) {
    setState(() => _idx = i);
    _pc.animateToPage(i, duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
  }

  void _openMenu(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Theme.of(ctx).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (c) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 8),
        Container(width: 40, height: 4, decoration: BoxDecoration(color: Theme.of(ctx).dividerColor, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        _menuItem(c, Icons.school_outlined, 'Algoritmi', const AlgorithmsScreen()),
        _menuItem(c, Icons.emoji_events_outlined, 'Online Competition', const OnlineCompetitionScreen()),
        _menuItem(c, Icons.person_outline, 'Profilo', const ProfileScreen()),
        _menuItem(c, Icons.tune_outlined, 'Impostazioni', const SettingsScreen()),
        const SizedBox(height: 8),
      ])));
  }

  Widget _menuItem(BuildContext ctx, IconData icon, String label, Widget screen) {
    final th = Theme.of(ctx);
    return ListTile(
      leading: Icon(icon, color: th.colorScheme.primary),
      title: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: th.colorScheme.onSurface)),
      onTap: () {
        Navigator.pop(ctx);
        Navigator.push(ctx, MaterialPageRoute(builder: (_) => screen));
      });
  }

  @override
  Widget build(BuildContext context) {
    final s  = context.watch<SettingsProvider>();
    final l  = context.watch<L10n>();
    final th = Theme.of(context);
    final onSurf = th.colorScheme.onSurface;

    final Widget content = Scaffold(
      backgroundColor: s.useGradient ? Colors.transparent : th.scaffoldBackgroundColor,
      body: PageView(
        controller: _pc,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (i) => setState(() => _idx = i),
        children: _mainScreens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: th.cardColor,
          border: Border(top: BorderSide(color: th.dividerColor, width: 0.5))),
        child: BottomNavigationBar(
          currentIndex: _idx.clamp(0, 3),
          onTap: (i) { if (i == 4) { _openMenu(context); } else { _go(i); } },
          backgroundColor: Colors.transparent,
          selectedItemColor: s.accentColor,
          unselectedItemColor: onSurf.withValues(alpha: 0.35),
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.timer_outlined),                 activeIcon: const Icon(Icons.timer),                label: l.t('timer')),
            BottomNavigationBarItem(icon: const Icon(Icons.format_list_numbered_outlined),   activeIcon: const Icon(Icons.format_list_numbered), label: l.t('times')),
            BottomNavigationBarItem(icon: const Icon(Icons.bar_chart_outlined),              activeIcon: const Icon(Icons.bar_chart),            label: l.t('stats')),
            BottomNavigationBarItem(icon: const Icon(Icons.people_outline),                  activeIcon: const Icon(Icons.people),               label: l.t('battle')),
            BottomNavigationBarItem(icon: const Icon(Icons.menu),                            activeIcon: const Icon(Icons.menu),                 label: 'Menu'),
          ],
          type: BottomNavigationBarType.fixed,
        )),
    );

    // Note: menu tab handled via onTap before state changes

    if (!s.useGradient) return content;
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [s.effectiveGradient1, s.effectiveGradient2])),
      child: content);
  }
}
