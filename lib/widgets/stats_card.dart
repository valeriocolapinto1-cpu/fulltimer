import 'package:flutter/material.dart';
import '../models/solve_time.dart';
import '../models/event_type.dart';
import 'spinning_cube.dart';
import 'glass_button.dart';

class StatsCard extends StatelessWidget {
  final String label;
  final int? valueMs;
  final bool highlight;
  final Color accentColor;

  const StatsCard({super.key, required this.label, required this.valueMs,
      this.highlight = false, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onBackground;
    final String dv = valueMs == null ? '-' : valueMs == -1 ? 'DNF' : SolveTime.format(valueMs!);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: highlight ? accentColor.withValues(alpha: 0.12) : theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: highlight ? accentColor.withValues(alpha: 0.4) : theme.dividerColor,
            width: highlight ? 1.5 : 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(fontSize: 10, letterSpacing: 1.5)),
        const SizedBox(height: 5),
        Text(dv, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, fontFamily: 'Nunito',
            color: highlight ? accentColor : onBg, letterSpacing: -0.3)),
      ]),
    );
  }
}

class EventSelector extends StatelessWidget {
  final List<EventType> events;
  final String activeEventId;
  final ValueChanged<String> onEventSelected;
  final Color accentColor;

  const EventSelector({super.key, required this.events, required this.activeEventId,
      required this.onEventSelected, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: events.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final event = events[i];
          final isActive = event.id == activeEventId;
          return GlassButton(
            active: isActive,
            borderRadius: 14,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            onTap: () => onEventSelected(event.id),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              eventCube(event.id, size: 22),
              const SizedBox(width: 7),
              Text(event.name, style: TextStyle(fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? accentColor : theme.colorScheme.onBackground,
                  fontFamily: 'Nunito')),
            ]),
          );
        },
      ),
    );
  }
}
