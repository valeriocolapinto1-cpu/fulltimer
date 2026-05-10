// widgets/stats_card.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../models/solve_time.dart';
import '../models/event_type.dart';

class StatsCard extends StatelessWidget {
  final String label;
  final int? valueMs; // null = non abbastanza solve, -1 = DNF
  final bool highlight;
  final Color accentColor;

  const StatsCard({
    super.key,
    required this.label,
    required this.valueMs,
    this.highlight = false,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String displayValue;

    if (valueMs == null) {
      displayValue = '-';
    } else if (valueMs == -1) {
      displayValue = 'DNF';
    } else {
      displayValue = SolveTime.format(valueMs!);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: highlight ? accentColor.withOpacity(0.12) : theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight ? accentColor.withOpacity(0.4) : theme.dividerColor,
          width: highlight ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 10,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            displayValue,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              fontFamily: 'monospace',
              color: highlight ? accentColor : theme.colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Event Selector ────────────────────────────────────────────

class EventSelector extends StatelessWidget {
  final List<EventType> events;
  final String activeEventId;
  final ValueChanged<String> onEventSelected;
  final Color accentColor;

  const EventSelector({
    super.key,
    required this.events,
    required this.activeEventId,
    required this.onEventSelected,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: events.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final event = events[i];
          final isActive = event.id == activeEventId;

          return GestureDetector(
            onTap: () => onEventSelected(event.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? accentColor : theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? accentColor : theme.dividerColor,
                ),
              ),
              child: Text(
                '${event.emoji} ${event.name}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? _contrastColor(accentColor)
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _contrastColor(Color c) =>
      c.computeLuminance() > 0.4 ? Colors.black : Colors.white;
}
