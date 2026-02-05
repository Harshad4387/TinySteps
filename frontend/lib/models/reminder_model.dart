class Reminder {
  final String id;
  final String title;
  final String description;
  final DateTime reminderTime;

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.reminderTime,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json["_id"],
      title: json["title"] ?? "Reminder",
      description: json["description"] ?? "",
      reminderTime: DateTime.parse(json["reminderTime"]),
    );
  }
}
