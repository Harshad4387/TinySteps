class Infant {
  final String id;
  final String name;
  final DateTime dateOfBirth;
  final String? gender;
  final String? bloodGroup;
  final double? birthWeight;
  final double? currentWeight;

  Infant({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    this.gender,
    this.bloodGroup,
    this.birthWeight,
    this.currentWeight,
  });

  factory Infant.fromJson(Map<String, dynamic> json) {
    return Infant(
      id: json['_id'],
      name: json['name'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      gender: json['gender'],
      bloodGroup: json['bloodGroup'],
      birthWeight: json['birthWeight']?.toDouble(),
      currentWeight: json['currentWeight']?.toDouble(),
    );
  }
}
