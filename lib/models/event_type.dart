// models/event_type.dart
// Rappresenta un evento WCA o personalizzato

class EventType {
  final String id;
  final String name;
  final String emoji;
  final bool isCustom;

  const EventType({
    required this.id,
    required this.name,
    required this.emoji,
    this.isCustom = false,
  });

  // Eventi WCA predefiniti
  static const List<EventType> defaults = [
    EventType(id: '3x3', name: '3x3x3', emoji: '🟧'),
    EventType(id: '2x2', name: '2x2x2', emoji: '🟦'),
    EventType(id: '4x4', name: '4x4x4', emoji: '🟩'),
    EventType(id: '5x5', name: '5x5x5', emoji: '🟥'),
    EventType(id: '6x6', name: '6x6x6', emoji: '🟪'),
    EventType(id: '7x7', name: '7x7x7', emoji: '🟫'),
    EventType(id: 'oh', name: 'One-Handed', emoji: '✋'),
    EventType(id: 'pyra', name: 'Pyraminx', emoji: '🔺'),
    EventType(id: 'skewb', name: 'Skewb', emoji: '💠'),
    EventType(id: 'sq1', name: 'Square-1', emoji: '🔷'),
    EventType(id: 'mega', name: 'Megaminx', emoji: '⭐'),
    EventType(id: 'clock', name: 'Clock', emoji: '🕐'),
  ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'isCustom': isCustom,
      };

  factory EventType.fromJson(Map<String, dynamic> json) => EventType(
        id: json['id'],
        name: json['name'],
        emoji: json['emoji'],
        isCustom: json['isCustom'] ?? false,
      );
}
