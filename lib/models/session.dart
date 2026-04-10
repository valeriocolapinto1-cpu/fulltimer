// models/session.dart
import 'solve_time.dart';

class Session {
  final String id;
  String name; // mutabile per rinomina
  final String eventId;
  final DateTime createdAt;
  List<SolveTime> solves;

  Session({
    required this.id,
    required this.name,
    required this.eventId,
    required this.createdAt,
    List<SolveTime>? solves,
  }) : solves = solves ?? [];

  List<SolveTime> get validSolves => solves.where((s) => s.isValid).toList();

  int? get bestMs {
    if (validSolves.isEmpty) return null;
    return validSolves.map((s) => s.effectiveMilliseconds).reduce((a, b) => a < b ? a : b);
  }

  int? get worstMs {
    if (validSolves.isEmpty) return null;
    return validSolves.map((s) => s.effectiveMilliseconds).reduce((a, b) => a > b ? a : b);
  }

  int? averageOf(int n) {
    if (solves.length < n) return null;
    final last = solves.reversed.take(n).toList();
    final dnfCount = last.where((s) => !s.isValid).length;
    if (dnfCount > 1) return -1;
    final times = last.map((s) => s.isValid ? s.effectiveMilliseconds : 999999999).toList()..sort();
    final trimmed = times.sublist(1, times.length - 1);
    if (trimmed.contains(999999999)) return -1;
    return trimmed.reduce((a, b) => a + b) ~/ trimmed.length;
  }

  int? get sessionMean {
    if (validSolves.isEmpty) return null;
    return validSolves.map((s) => s.effectiveMilliseconds).reduce((a, b) => a + b) ~/ validSolves.length;
  }

  Map<String, dynamic> toJson() => {
        'id': id, 'name': name, 'eventId': eventId,
        'createdAt': createdAt.toIso8601String(),
        'solves': solves.map((s) => s.toJson()).toList(),
      };

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        id: json['id'], name: json['name'], eventId: json['eventId'],
        createdAt: DateTime.parse(json['createdAt']),
        solves: (json['solves'] as List).map((s) => SolveTime.fromJson(s)).toList(),
      );
}
