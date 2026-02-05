class SleepEntry {
  final DateTime start;
  final DateTime end;
  final double totalHours;

  SleepEntry({
    required this.start,
    required this.end,
    required this.totalHours,
  });

  factory SleepEntry.fromJson(Map<String, dynamic> json) {
    return SleepEntry(
      start: DateTime.parse(json['sleepStart']),
      end: DateTime.parse(json['sleepEnd']),
      totalHours:
          (json['totalHours'] as num).toDouble(),
    );
  }
}
