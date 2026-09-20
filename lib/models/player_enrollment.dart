import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerEnrollment {
  final String id;

  // ============================================================
  // RELACIONES
  // ============================================================

  final String playerId;
  final String fieldId;
  final String teamId;

  // ============================================================
  // TEMPORADA
  // ============================================================

  final String? seasonId;

  // ============================================================
  // ESTADO
  // ============================================================

  final String status;

  // ============================================================
  // FECHAS
  // ============================================================

  final DateTime createdAt;
  final DateTime? updatedAt;

  const PlayerEnrollment({
    required this.id,
    required this.playerId,
    required this.fieldId,
    required this.teamId,
    this.seasonId,
    this.status = 'active',
    required this.createdAt,
    this.updatedAt,
  });

  // ============================================================
  // ESTADOS
  // ============================================================

  bool get isActive {
    return status == 'active';
  }

  bool get isPending {
    return status == 'pending';
  }

  bool get isInactive {
    return status == 'inactive';
  }

  // ============================================================
  // FIRESTORE
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'playerId': playerId,
      'fieldId': fieldId,
      'teamId': teamId,
      'seasonId': seasonId,
      'status': status,
      'createdAt':
      Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : null,
    };
  }

  // ============================================================
  // FROM FIRESTORE
  // ============================================================

  factory PlayerEnrollment.fromMap(
      Map<String, dynamic> map,
      ) {
    return PlayerEnrollment(
      id: map['id'] ?? '',
      playerId:
      map['playerId'] ?? '',
      fieldId:
      map['fieldId'] ?? '',
      teamId:
      map['teamId'] ?? '',
      seasonId:
      map['seasonId'],
      status:
      map['status'] ?? 'active',
      createdAt:
      _parseDate(map['createdAt']) ??
          DateTime.now(),
      updatedAt:
      _parseDate(map['updatedAt']),
    );
  }

  // ============================================================
  // CONVERSIÓN DE FECHAS
  // ============================================================

  static DateTime? _parseDate(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}