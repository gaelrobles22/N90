class FieldAccessCode {
  final String id;

  // ============================================================
  // CÓDIGO
  // ============================================================

  final String code;

  // ============================================================
  // CAMPO
  // ============================================================

  final String fieldId;
  final String fieldName;

  // ============================================================
  // ESTADO
  // ============================================================

  final bool active;

  // ============================================================
  // FECHA DE EXPIRACIÓN
  // ============================================================

  final DateTime? expiresAt;

  const FieldAccessCode({
    required this.id,
    required this.code,
    required this.fieldId,
    required this.fieldName,
    this.active = true,
    this.expiresAt,
  });

  // ============================================================
  // EXPIRADO
  // ============================================================

  bool get isExpired {
    if (expiresAt == null) {
      return false;
    }

    return DateTime.now()
        .isAfter(expiresAt!);
  }

  // ============================================================
  // CÓDIGO VÁLIDO
  // ============================================================

  bool get isValid {
    return active && !isExpired;
  }

  // ============================================================
  // FIRESTORE
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'fieldId': fieldId,
      'fieldName': fieldName,
      'active': active,
      'expiresAt':
      expiresAt?.toIso8601String(),
    };
  }

  // ============================================================
  // FROM FIRESTORE
  // ============================================================

  factory FieldAccessCode.fromMap(
      Map<String, dynamic> map,
      ) {
    return FieldAccessCode(
      id: map['id'] ?? '',
      code: map['code'] ?? '',
      fieldId:
      map['fieldId'] ?? '',
      fieldName:
      map['fieldName'] ?? '',
      active:
      map['active'] ?? true,
      expiresAt: map['expiresAt'] != null
          ? DateTime.tryParse(
        map['expiresAt'],
      )
          : null,
    );
  }
}