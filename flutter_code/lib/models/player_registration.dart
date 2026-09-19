import 'identity_document.dart';

class PlayerRegistration {
  final String? uid;
  final String role;
  final String? name;
  final String? firstLastName;
  final String? secondLastName;
  final String? country;
  final DateTime? birthDate;
  final String? whatsapp;
  final String? email;
  final String? profilePhotoUrl;
  final IdentityDocument? identityDocument;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PlayerRegistration({
    this.uid,
    this.role = 'player',
    this.name,
    this.firstLastName,
    this.secondLastName,
    this.country,
    this.birthDate,
    this.whatsapp,
    this.email,
    this.profilePhotoUrl,
    this.identityDocument,
    this.createdAt,
    this.updatedAt,
  });

  // ============================================================
  // NOMBRE COMPLETO
  // ============================================================

  String get fullName {
    return [
      name,
      firstLastName,
      secondLastName,
    ]
        .where(
          (value) =>
      value != null &&
          value.trim().isNotEmpty,
    )
        .join(' ');
  }

  // ============================================================
  // NOMBRE NORMALIZADO
  // ============================================================

  String get fullNameNormalized {
    return _normalizeText(fullName);
  }

  static String _normalizeText(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  // ============================================================
  // EDAD
  // ============================================================

  int? get age {
    if (birthDate == null) {
      return null;
    }

    final today = DateTime.now();

    int calculatedAge =
        today.year - birthDate!.year;

    final birthdayHasNotPassed =
        today.month < birthDate!.month ||
            (
                today.month == birthDate!.month &&
                    today.day < birthDate!.day
            );

    if (birthdayHasNotPassed) {
      calculatedAge--;
    }

    return calculatedAge;
  }

  // ============================================================
  // MENOR DE EDAD
  // ============================================================

  bool get isMinor {
    final playerAge = age;

    if (playerAge == null) {
      return false;
    }

    return playerAge < 18;
  }

  // ============================================================
  // DOCUMENTO DE IDENTIDAD
  // ============================================================

  bool get identityDocumentPending {
    return identityDocument == null ||
        identityDocument!.status ==
            IdentityDocumentStatus.pending;
  }

  bool get identityDocumentExpired {
    if (identityDocument?.dueDate == null) {
      return false;
    }

    return DateTime.now().isAfter(
      identityDocument!.dueDate!,
    );
  }

  // ============================================================
  // FIRESTORE
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'role': role,
      'name': name,
      'firstLastName': firstLastName,
      'secondLastName': secondLastName,
      'fullName': fullName,
      'fullNameNormalized': fullNameNormalized,
      'country': country,
      'birthDate': birthDate?.toIso8601String(),
      'age': age,
      'whatsapp': whatsapp,
      'email': email,
      'profilePhotoUrl': profilePhotoUrl,
      'identityDocument':
      identityDocument?.toMap(),
      'createdAt':
      createdAt?.toIso8601String(),
      'updatedAt':
      updatedAt?.toIso8601String(),
    };
  }

  factory PlayerRegistration.fromMap(
      Map<String, dynamic> map,
      ) {
    return PlayerRegistration(
      uid: map['uid'],
      role: map['role'] ?? 'player',
      name: map['name'],
      firstLastName:
      map['firstLastName'],
      secondLastName:
      map['secondLastName'],
      country: map['country'],
      birthDate:
      map['birthDate'] != null
          ? DateTime.tryParse(
        map['birthDate'].toString(),
      )
          : null,
      whatsapp: map['whatsapp'],
      email: map['email'],
      profilePhotoUrl:
      map['profilePhotoUrl'],
      identityDocument:
      map['identityDocument'] != null
          ? IdentityDocument.fromMap(
        Map<String, dynamic>.from(
          map['identityDocument'],
        ),
      )
          : null,
      createdAt:
      map['createdAt'] != null
          ? DateTime.tryParse(
        map['createdAt'].toString(),
      )
          : null,
      updatedAt:
      map['updatedAt'] != null
          ? DateTime.tryParse(
        map['updatedAt'].toString(),
      )
          : null,
    );
  }
}