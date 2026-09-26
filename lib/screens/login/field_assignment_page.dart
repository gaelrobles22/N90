import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FieldAssignmentPage extends StatefulWidget {
  const FieldAssignmentPage({
    super.key,
    required this.uid,
    required this.userData,
  });

  final String uid;
  final Map<String, dynamic> userData;

  @override
  State<FieldAssignmentPage> createState() => _FieldAssignmentPageState();
}

class _FieldAssignmentPageState extends State<FieldAssignmentPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _codeController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _assignField() async {
    final code = _codeController.text.trim().toUpperCase();

    if (code.isEmpty) {
      setState(() {
        _errorMessage = 'Ingresa el código de acceso.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('========================================');
      debugPrint('NOVENTA - ASIGNACIÓN DE CANCHA');
      debugPrint('NOVENTA - UID: ${widget.uid}');
      debugPrint('NOVENTA - CÓDIGO: $code');

// ============================================================
// 1. BUSCAR CÓDIGO DE ACCESO
// ============================================================

      final snapshot = await _firestore
          .collection('accessCodes')
          .where('code', isEqualTo: code)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('El código de acceso no existe.');
      }

      final accessCodeDocument = snapshot.docs.first;
      final accessCodeData = accessCodeDocument.data();

      final accessCodeId = accessCodeDocument.id;
      final fieldId = accessCodeData['fieldId'] as String?;
      final fieldName = accessCodeData['fieldName'] as String?;
      final active = accessCodeData['active'] == true;

      debugPrint('NOVENTA - ACCESS CODE ID: $accessCodeId');
      debugPrint('NOVENTA - FIELD ID: $fieldId');
      debugPrint('NOVENTA - FIELD NAME: $fieldName');
      debugPrint('NOVENTA - ACTIVE: $active');

// ============================================================
// 2. VALIDACIONES
// ============================================================

      if (!active) {
        throw Exception('Este código de acceso está inactivo.');
      }

      if (fieldId == null || fieldId.isEmpty) {
        throw Exception('El código no tiene una cancha asignada.');
      }

      if (fieldName == null || fieldName.isEmpty) {
        throw Exception('El código no tiene un nombre de cancha válido.');
      }

// ============================================================
// 3. VALIDAR EXPIRACIÓN
// ============================================================

      final expiresAt = accessCodeData['expiresAt'];

      if (expiresAt != null) {
        DateTime? expirationDate;

        if (expiresAt is Timestamp) {
          expirationDate = expiresAt.toDate();
        } else if (expiresAt is DateTime) {
          expirationDate = expiresAt;
        }

        if (expirationDate != null && !expirationDate.isAfter(DateTime.now())) {
          throw Exception('Este código de acceso ha expirado.');
        }
      }

// ============================================================
// 4. VERIFICAR SI YA TIENE ESTA CANCHA
// ============================================================

      final memberId = '${fieldId}_${widget.uid}';

      debugPrint(
        'NOVENTA - PREPARANDO FIELD MEMBER: $memberId',
      );

// ============================================================
// 5. CREAR FIELD MEMBER
// ============================================================

      final now = Timestamp.now();

      await _firestore.collection('fieldMembers').doc(memberId).set({
        'userId': widget.uid,
        'fieldId': fieldId,
        'accessCodeId': accessCodeId,
        'roles': <String>['player'],
        'status': 'active',
        'createdAt': now,
        'updatedAt': now,
      });

      debugPrint('NOVENTA - FIELD MEMBER CREADO');
      debugPrint('NOVENTA - MEMBER ID: $memberId');

// ============================================================
// 6. REGRESAR RESULTADO
// ============================================================

      if (!mounted) {
        return;
      }

      Navigator.pop(
        context,
        {
          'fieldId': fieldId,
          'fieldName': fieldName,
          'accessCodeId': accessCodeId,
        },
      );
    } catch (e) {
      debugPrint('NOVENTA - ERROR ASIGNANDO CANCHA: $e');

      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const lime = Color(0xFFA3FF3F);
    const background = Color(0xFF0B0B0B);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Asignar cancha',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.sports_soccer,
                color: lime,
                size: 72,
              ),
              const SizedBox(height: 28),
              const Text(
                'Aún no tienes una cancha asignada',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Tu cuenta está creada, pero todavía no está '
                'vinculada a una cancha.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.70),
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 36),
              const Text(
                'Código de acceso',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _codeController,
                enabled: !_isLoading,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  letterSpacing: 1.2,
                ),
                decoration: InputDecoration(
                  hintText: 'Ej. N90-REF82K',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF171717),
                  prefixIcon: const Icon(
                    Icons.key,
                    color: lime,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: lime,
                      width: 1.5,
                    ),
                  ),
                ),
                onSubmitted: (_) => _assignField(),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 14,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _assignField,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lime,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: lime.withValues(alpha: 0.35),
                    disabledForegroundColor: Colors.black54,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 23,
                          height: 23,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.black,
                          ),
                        )
                      : const Text(
                          'Asignar cancha',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Solicita el código de acceso al administrador '
                'de tu cancha.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
