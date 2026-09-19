enum IdentityDocumentType {
  field,
  ine,
  passport,
  otherOfficial,
}

enum IdentityDocumentStatus {
  pending,
  uploaded,
  verified,
  rejected,
  expired,
}

class IdentityDocument {
  final IdentityDocumentType type;
  final IdentityDocumentStatus status;
  final String? documentUrl;
  final DateTime? uploadedAt;
  final DateTime? dueDate;
  final String? rejectionReason;

  const IdentityDocument({
    required this.type,
    required this.status,
    this.documentUrl,
    this.uploadedAt,
    this.dueDate,
    this.rejectionReason,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'status': status.name,
      'documentUrl': documentUrl,
      'uploadedAt': uploadedAt?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'rejectionReason': rejectionReason,
    };
  }

  factory IdentityDocument.fromMap(Map<String, dynamic> map) {
    return IdentityDocument(
      type: IdentityDocumentType.values.firstWhere(
            (e) => e.name == map['type'],
        orElse: () => IdentityDocumentType.otherOfficial,
      ),
      status: IdentityDocumentStatus.values.firstWhere(
            (e) => e.name == map['status'],
        orElse: () => IdentityDocumentStatus.pending,
      ),
      documentUrl: map['documentUrl'],
      uploadedAt: map['uploadedAt'] != null
          ? DateTime.tryParse(map['uploadedAt'])
          : null,
      dueDate: map['dueDate'] != null
          ? DateTime.tryParse(map['dueDate'])
          : null,
      rejectionReason: map['rejectionReason'],
    );
  }
}