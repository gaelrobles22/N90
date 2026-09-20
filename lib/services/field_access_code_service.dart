import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/field_access_code.dart';

class FieldAccessCodeService {
  final FirebaseFirestore _firestore;

  FieldAccessCodeService({
    FirebaseFirestore? firestore,
  }) : _firestore =
      firestore ?? FirebaseFirestore.instance;

  // ============================================================
  // VALIDAR CÓDIGO
  // ============================================================

  Future<FieldAccessCode?> validateCode(String code) async {
    final normalizedCode = code.trim().toUpperCase();

    if (normalizedCode.isEmpty) {
      return null;
    }

    try {
      debugPrint('========================================');
      debugPrint('NOVENTA - VALIDANDO CÓDIGO');
      debugPrint('Código: $normalizedCode');
      debugPrint('========================================');

      final snapshot = await _firestore
          .collection('accessCodes')
          .where(
        'code',
        isEqualTo: normalizedCode,
      )
          .limit(1)
          .get();

      debugPrint(
        'Documentos encontrados: ${snapshot.docs.length}',
      );

      if (snapshot.docs.isEmpty) {
        debugPrint('Código no encontrado en Firestore.');
        return null;
      }

      final document = snapshot.docs.first;

      debugPrint('Document ID: ${document.id}');
      debugPrint('Datos: ${document.data()}');

      final data = document.data();

      final accessCode = FieldAccessCode.fromMap({
        ...data,
        'id': document.id,
      });

      debugPrint('Código válido: ${accessCode.isValid}');
      debugPrint('Campo: ${accessCode.fieldName}');
      debugPrint('Field ID: ${accessCode.fieldId}');

      if (!accessCode.isValid) {
        debugPrint('Código encontrado pero está inactivo o expirado.');
        return null;
      }

      return accessCode;
    } on FirebaseException catch (e) {
      debugPrint('========================================');
      debugPrint('FIREBASE ERROR');
      debugPrint('Código: ${e.code}');
      debugPrint('Mensaje: ${e.message}');
      debugPrint('========================================');

      rethrow;
    } catch (e) {
      debugPrint('========================================');
      debugPrint('ERROR INESPERADO');
      debugPrint('$e');
      debugPrint('========================================');

      rethrow;
    }
  }
}