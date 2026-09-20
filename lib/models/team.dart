class Team {
  final String id;
  final String fieldId;
  final String name;
  final bool active;

  const Team({
    required this.id,
    required this.fieldId,
    required this.name,
    this.active = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fieldId': fieldId,
      'name': name,
      'active': active,
    };
  }

  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      id: map['id'] ?? '',
      fieldId: map['fieldId'] ?? '',
      name: map['name'] ?? '',
      active: map['active'] ?? true,
    );
  }
}