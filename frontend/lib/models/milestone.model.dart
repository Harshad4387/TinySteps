class Milestone {
  final String id;
  final String milestoneType;
  final DateTime dateAchieved;
  final String? notes;

  Milestone({
    required this.id,
    required this.milestoneType,
    required this.dateAchieved,
    this.notes,
  });

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id: json['_id'],
      milestoneType: json['milestoneType'],
      dateAchieved: DateTime.parse(json['dateAchieved']),
      notes: json['notes'],
    );
  }
}
