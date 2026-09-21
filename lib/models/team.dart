class FieldTeam {
  final String id;
  final String fieldId;
  final String name;
  final bool active;

  const FieldTeam({
    required this.id,
    required this.fieldId,
    required this.name,
    this.active = true,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'fieldId': fieldId,
    'name': name,
    'active': active,
  };

  factory FieldTeam.fromMap(Map<String, dynamic> map) => FieldTeam(
    id: map['id'] ?? '',
    fieldId: map['fieldId'] ?? '',
    name: map['name'] ?? '',
    active: map['active'] ?? true,
  );
}