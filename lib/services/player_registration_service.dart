import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/player_enrollment.dart';
import '../models/player_registration.dart';

class PlayerNameAlreadyExistsException
    implements Exception {
  const PlayerNameAlreadyExistsException();

  @override
  String toString() {
    return 'Ya existe un jugador registrado con este nombre completo.';
  }
}

class PlayerRegistrationService {
  final FirebaseFirestore _firestore;

  PlayerRegistrationService({
    FirebaseFirestore? firestore,
  }) : _firestore =
      firestore ?? FirebaseFirestore.instance;

  // ============================================================
  // CREAR JUGADOR
  // ============================================================

  Future<void> createPlayer(
      PlayerRegistration player,
      ) async {
    final uid = player.uid;

    if (uid == null || uid.isEmpty) {
      throw Exception(
        'El jugador no tiene un UID válido.',
      );
    }

    await _firestore
        .collection('users')
        .doc(uid)
        .set(
      player.toMap(),
    );
  }

  // ============================================================
  // CREAR JUGADOR DESDE FIREBASE AUTH
  // ============================================================

  Future<void> createPlayerFromAuth({
    required String uid,
    required PlayerRegistration player,
  }) async {
    final playerWithUid = PlayerRegistration(
      uid: uid,
      role: player.role,
      name: player.name,
      firstLastName: player.firstLastName,
      secondLastName: player.secondLastName,
      country: player.country,
      birthDate: player.birthDate,
      whatsapp: player.whatsapp,
      email: player.email,
      profilePhotoUrl: player.profilePhotoUrl,
      createdAt: player.createdAt,
      updatedAt: player.updatedAt,
    );

    await _firestore
        .collection('users')
        .doc(uid)
        .set(
      playerWithUid.toMap(),
      SetOptions(merge: true),
    );
  }

  // ============================================================
  // OBTENER USUARIO
  // ============================================================

  Future<PlayerRegistration?> getPlayer(
      String uid,
      ) async {
    final document = await _firestore
        .collection('users')
        .doc(uid)
        .get();

    if (!document.exists ||
        document.data() == null) {
      return null;
    }

    return PlayerRegistration.fromMap(
      {
        ...document.data()!,
        'uid': document.id,
      },
    );
  }

  // ============================================================
  // ACTUALIZAR JUGADOR
  // ============================================================

  Future<void> updatePlayer(
      PlayerRegistration player,
      ) async {
    final uid = player.uid;

    if (uid == null || uid.isEmpty) {
      throw Exception(
        'El jugador no tiene un UID válido.',
      );
    }

    await _firestore
        .collection('users')
        .doc(uid)
        .update(
      player.toMap(),
    );
  }

  // ============================================================
  // RESERVAR NOMBRE
  // ============================================================

  Future<void> reservePlayerName({
    required String uid,
    required String fullName,
    required String fullNameNormalized,
  }) async {
    if (uid.trim().isEmpty) {
      throw Exception(
        'El UID del jugador es obligatorio.',
      );
    }

    if (fullNameNormalized.trim().isEmpty) {
      throw Exception(
        'El nombre completo es obligatorio.',
      );
    }

    debugPrint('========================================');
    debugPrint('PLAYER NAME: INICIO');
    debugPrint('PLAYER NAME: UID = $uid');
    debugPrint('PLAYER NAME: FULL NAME = $fullName');
    debugPrint(
      'PLAYER NAME: NORMALIZED = $fullNameNormalized',
    );

    final nameReference = _firestore
        .collection('playerNames')
        .doc(fullNameNormalized);

    try {
      await _firestore.runTransaction(
            (transaction) async {
          final existingDocument =
          await transaction.get(nameReference);

          if (existingDocument.exists) {
            throw const PlayerNameAlreadyExistsException();
          }

          transaction.set(
            nameReference,
            {
              'uid': uid,
              'fullName': fullName,
              'fullNameNormalized':
              fullNameNormalized,
              'createdAt':
              FieldValue.serverTimestamp(),
            },
          );
        },
      );

      debugPrint(
        'PLAYER NAME: NOMBRE RESERVADO CORRECTAMENTE',
      );
      debugPrint('========================================');
    } catch (e, stackTrace) {
      debugPrint(
        'PLAYER NAME ERROR: $e',
      );

      debugPrint(
        'PLAYER NAME STACK: $stackTrace',
      );

      rethrow;
    }
  }

  // ============================================================
  // ELIMINAR RESERVA DE NOMBRE
  // ============================================================

  Future<void> releasePlayerName({
    required String fullNameNormalized,
    required String uid,
  }) async {
    final nameReference = _firestore
        .collection('playerNames')
        .doc(fullNameNormalized);

    final document =
    await nameReference.get();

    if (!document.exists) {
      return;
    }

    final data = document.data();

    if (data == null) {
      return;
    }

    if (data['uid'] != uid) {
      return;
    }

    await nameReference.delete();
  }

  // ============================================================
  // CREAR INSCRIPCIÓN
  // ============================================================

  Future<void> createEnrollment(
      PlayerEnrollment enrollment,
      ) async {
    await _firestore
        .collection('playerEnrollments')
        .doc(enrollment.id)
        .set(
      enrollment.toMap(),
    );
  }

  // ============================================================
  // CREAR INSCRIPCIÓN PARA UN JUGADOR
  //
  // Esta función se utiliza después del login cuando el jugador
  // selecciona su equipo.
  // ============================================================

  Future<PlayerEnrollment> createPlayerEnrollment({
    required String playerId,
    required String fieldId,
    required String teamId,
    String? seasonId,
  }) async {
    if (playerId.trim().isEmpty) {
      throw Exception(
        'El jugador no tiene un UID válido.',
      );
    }

    if (fieldId.trim().isEmpty) {
      throw Exception(
        'El campo es obligatorio.',
      );
    }

    if (teamId.trim().isEmpty) {
      throw Exception(
        'El equipo es obligatorio.',
      );
    }

    // Evita crear otra inscripción activa para el mismo
    // jugador, campo y equipo.
    final existingSnapshot = await _firestore
        .collection('playerEnrollments')
        .where(
      'playerId',
      isEqualTo: playerId,
    )
        .where(
      'fieldId',
      isEqualTo: fieldId,
    )
        .where(
      'teamId',
      isEqualTo: teamId,
    )
        .where(
      'status',
      isEqualTo: 'active',
    )
        .limit(1)
        .get();

    if (existingSnapshot.docs.isNotEmpty) {
      final existingDocument =
          existingSnapshot.docs.first;

      return PlayerEnrollment.fromMap(
        {
          ...existingDocument.data(),
          'id': existingDocument.id,
        },
      );
    }

    final now = DateTime.now();

    final enrollmentId =
        '${fieldId}_${playerId}_${teamId}';

    final enrollment = PlayerEnrollment(
      id: enrollmentId,
      playerId: playerId,
      fieldId: fieldId,
      teamId: teamId,
      seasonId: seasonId,
      status: 'active',
      createdAt: now,
      updatedAt: now,
    );

    await createEnrollment(enrollment);

    debugPrint(
      '========================================',
    );
    debugPrint(
      'NOVENTA - INSCRIPCIÓN CREADA',
    );
    debugPrint(
      'Player: $playerId',
    );
    debugPrint(
      'Field: $fieldId',
    );
    debugPrint(
      'Team: $teamId',
    );
    debugPrint(
      '========================================',
    );

    return enrollment;
  }

  // ============================================================
  // OBTENER INSCRIPCIONES
  // ============================================================

  Future<List<PlayerEnrollment>>
  getPlayerEnrollments(
      String playerId,
      ) async {
    final snapshot = await _firestore
        .collection('playerEnrollments')
        .where(
      'playerId',
      isEqualTo: playerId,
    )
        .get();

    return snapshot.docs
        .map(
          (doc) => PlayerEnrollment.fromMap(
        {
          ...doc.data(),
          'id': doc.id,
        },
      ),
    )
        .toList();
  }

  // ============================================================
  // OBTENER INSCRIPCIONES ACTIVAS
  // ============================================================

  Future<List<PlayerEnrollment>>
  getActiveEnrollments(
      String playerId,
      ) async {
    final snapshot = await _firestore
        .collection('playerEnrollments')
        .where(
      'playerId',
      isEqualTo: playerId,
    )
        .where(
      'status',
      isEqualTo: 'active',
    )
        .get();

    return snapshot.docs
        .map(
          (doc) => PlayerEnrollment.fromMap(
        {
          ...doc.data(),
          'id': doc.id,
        },
      ),
    )
        .toList();
  }
}