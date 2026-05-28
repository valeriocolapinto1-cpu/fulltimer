// screens/settings_screen.dart
// Schermata impostazioni completa

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/session_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final session = context.watch<SessionProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Impostazioni')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Tema ──────────────────────────────────────────────
          _SectionHeader(title: 'ASPETTO', theme: theme),

          _SettingsTile(
            title: 'Modalità scura',
            subtitle: settings.darkMode ? 'Attiva' : 'Disattiva',
            trailing: Switch(
              value: settings.darkMode,
              onChanged: settings.setDarkMode,
            ),
          ),

          _SectionHeader(title: 'COLORE PRINCIPALE', theme: theme),
          const SizedBox(height: 8),
          _ColorPicker(settings: settings),
          const SizedBox(height: 16),

          // ── Timer ─────────────────────────────────────────────
          _SectionHeader(title: 'TIMER', theme: theme),

          _SettingsTile(
            title: 'Ispezione WCA',
            subtitle: 'Countdown prima del timer',
            trailing: Switch(
              value: settings.inspectionEnabled,
              onChanged: settings.setInspectionEnabled,
            ),
          ),

          if (settings.inspectionEnabled)
            _SettingsTile(
              title: 'Durata ispezione',
              subtitle: '${settings.inspectionDuration} secondi',
              trailing: null,
              onTap: () => _showInspectionDialog(context, settings),
            ),

          _SettingsTile(
            title: 'Tempo pressione',
            subtitle: '${settings.holdDuration}ms per avviare',
            trailing: null,
            onTap: () => _showHoldDialog(context, settings),
          ),

          // ── Feedback ─────────────────────────────────────────
          _SectionHeader(title: 'FEEDBACK', theme: theme),

          _SettingsTile(
            title: 'Vibrazione',
            subtitle: 'Feedback aptico',
            trailing: Switch(
              value: settings.vibrationEnabled,
              onChanged: settings.setVibrationEnabled,
            ),
          ),

          // ── Sessione ─────────────────────────────────────────
          _SectionHeader(title: 'SESSIONE', theme: theme),

          _SettingsTile(
            title: 'Aggiungi evento personalizzato',
            subtitle: null,
            trailing: const Icon(Icons.add),
            onTap: () => _showAddEventDialog(context, session),
          ),

          _SettingsTile(
            title: 'Reset sessione corrente',
            subtitle: 'Elimina tutti i tempi',
            trailing: null,
            onTap: () => _confirmReset(context, session),
            isDestructive: true,
          ),

          const SizedBox(height: 60),

          // Info app
          Center(
            child: Text(
              'FullTimer v2.0',
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dialogs ───────────────────────────────────────────────

  void _showInspectionDialog(BuildContext context, SettingsProvider settings) {
    int value = settings.inspectionDuration;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Durata ispezione'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$value secondi',
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.w200)),
              Slider(
                value: value.toDouble(),
                min: 5,
                max: 30,
                divisions: 25,
                onChanged: (v) => setState(() => value = v.round()),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annulla')),
            TextButton(
              onPressed: () {
                settings.setInspectionDuration(value);
                Navigator.pop(ctx);
              },
              child: const Text('Salva'),
            ),
          ],
        ),
      ),
    );
  }

  void _showHoldDialog(BuildContext context, SettingsProvider settings) {
    int value = settings.holdDuration;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Tempo di pressione'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${value}ms',
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.w200)),
              Slider(
                value: value.toDouble(),
                min: 200,
                max: 1000,
                divisions: 16,
                onChanged: (v) => setState(() => value = v.round()),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annulla')),
            TextButton(
              onPressed: () {
                settings.setHoldDuration(value);
                Navigator.pop(ctx);
              },
              child: const Text('Salva'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context, SessionProvider session) {
    final nameController = TextEditingController();
    String emoji = '🎲';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Nuovo evento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Semplice rotazione di emoji
                      const emojis = ['🎲', '⭐', '🔴', '🟡', '🔵', '🟢', '⚡'];
                      final current = emojis.indexOf(emoji);
                      setState(
                          () => emoji = emojis[(current + 1) % emojis.length]);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: nameController,
                      decoration:
                          const InputDecoration(hintText: 'Nome evento'),
                      autofocus: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annulla')),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  session.addCustomEvent(nameController.text, emoji);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Aggiungi'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context, SessionProvider session) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset sessione'),
        content: const Text(
            'Tutti i tempi della sessione corrente verranno eliminati. Continuare?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annulla')),
          TextButton(
            onPressed: () {
              session.resetCurrentSession();
              Navigator.pop(ctx);
            },
            style:
                TextButton.styleFrom(foregroundColor: const Color(0xFFCF6679)),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

// ── Componenti settings ───────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final ThemeData theme;

  const _SectionHeader({required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(
          letterSpacing: 2,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive
                ? const Color(0xFFCF6679)
                : theme.colorScheme.onSurface,
          ),
        ),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final SettingsProvider settings;

  const _ColorPicker({required this.settings});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      children: SettingsProvider.accentColors.map((color) {
        final isSelected = settings.accentColor.value == color.value;
        return GestureDetector(
          onTap: () => settings.setAccentColor(color),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    size: 18,
                    color: color.computeLuminance() > 0.4
                        ? Colors.black
                        : Colors.white,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}
