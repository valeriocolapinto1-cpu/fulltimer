enum SolveResult { ok, plusTwo, dnf }

class SolveTime {
  final String id;
  final int milliseconds;
  final DateTime timestamp;
  final String scramble;
  final String eventId;
  SolveResult result;
  String comment;
  bool favorite;

  SolveTime({
    required this.id, required this.milliseconds, required this.timestamp,
    required this.scramble, required this.eventId,
    this.result = SolveResult.ok, this.comment = '', this.favorite = false,
  });

  int get effectiveMilliseconds => result == SolveResult.plusTwo ? milliseconds + 2000 : milliseconds;
  bool get isValid => result != SolveResult.dnf;

  static String format(int ms) {
    if (ms < 0) return 'DNF';
    final min = ms ~/ 60000, sec = (ms % 60000) ~/ 1000, cs = (ms % 1000) ~/ 10;
    return min > 0
        ? '$min:${sec.toString().padLeft(2,'0')}.${cs.toString().padLeft(2,'0')}'
        : '$sec.${cs.toString().padLeft(2,'0')}';
  }

  String get displayTime {
    if (result == SolveResult.dnf) return 'DNF';
    return result == SolveResult.plusTwo ? '${format(effectiveMilliseconds)}+' : format(effectiveMilliseconds);
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'milliseconds': milliseconds, 'timestamp': timestamp.toIso8601String(),
    'scramble': scramble, 'eventId': eventId, 'result': result.index,
    'comment': comment, 'favorite': favorite,
  };

  factory SolveTime.fromJson(Map<String, dynamic> j) => SolveTime(
    id: j['id'], milliseconds: j['milliseconds'], timestamp: DateTime.parse(j['timestamp']),
    scramble: j['scramble'], eventId: j['eventId'],
    result: SolveResult.values[j['result'] ?? 0],
    comment: j['comment'] ?? '', favorite: j['favorite'] ?? false,
  );
}
