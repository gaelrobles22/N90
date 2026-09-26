import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../player_registration/access_code_page.dart';
import '../../services/auth_service.dart';
import '../../widgets/country_selector.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({
    super.key,
    required this.access,
  });

  final RegistrationAccess access;

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  static const Color _limeColor = Color(0xFF9DFF21);
  static const Color _backgroundColor = Color(0xFF0B0B0B);

  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _firstLastNameController =
  TextEditingController();

  final TextEditingController _secondLastNameController =
  TextEditingController();

  final TextEditingController _whatsappController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
  TextEditingController();

  int _step = 0;

  bool _isLoading = false;

  bool _obscurePassword = true;

  bool _obscureConfirmPassword = true;

  String? _errorMessage;

  String? _selectedCountry;

  DateTime? _birthDate;

  // Indica que el usuario declaró que NO es el jugador
  // que ya tiene ese mismo nombre.
  bool _duplicateNameAcknowledged = false;

  @override
  void dispose() {
    _nameController.dispose();
    _firstLastNameController.dispose();
    _secondLastNameController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

// ============================================================
// DATOS
// ============================================================

  String get _fullName {
    return [
      _nameController.text.trim(),
      _firstLastNameController.text.trim(),
      _secondLastNameController.text.trim(),
    ].where((value) => value.isNotEmpty).join(' ');
  }

  int? get _age {
    if (_birthDate == null) {
      return null;
    }

    final today = DateTime.now();

    int age = today.year - _birthDate!.year;

    if (today.month < _birthDate!.month ||
        (today.month == _birthDate!.month &&
            today.day < _birthDate!.day)) {
      age--;
    }

    return age;
  }

  String _normalizePhone(String value) {
    return value.trim().replaceAll(RegExp(r'[^0-9+]'), '');
  }

  String _normalizeName(String value) {
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
// FECHA DE NACIMIENTO
// ============================================================

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();

    final initialDate = _birthDate ??
        DateTime(
          now.year - 18,
          now.month,
          now.day,
        );

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1940),
      lastDate: now,
      helpText: 'Fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      builder: (
          context,
          child,
          ) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _limeColor,
              onPrimary: Colors.black,
              surface: Color(0xFF181818),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _birthDate = selected;
      _errorMessage = null;
    });
  }

  String _formatBirthDate() {
    if (_birthDate == null) {
      return 'Selecciona tu fecha de nacimiento';
    }

    final day = _birthDate!.day.toString().padLeft(2, '0');

    final month = _birthDate!.month.toString().padLeft(2, '0');

    return '$day/$month/${_birthDate!.year}';
  }

// ============================================================
// VALIDACIONES
// ============================================================

  bool _validatePersonalData() {
    if (_nameController.text.trim().isEmpty) {
      _setError('Ingresa tu nombre.');
      return false;
    }

    if (_firstLastNameController.text.trim().isEmpty) {
      _setError('Ingresa tu primer apellido.');
      return false;
    }

    if (_selectedCountry == null || _selectedCountry!.isEmpty) {
      _setError('Selecciona tu país.');
      return false;
    }

    if (_birthDate == null) {
      _setError('Selecciona tu fecha de nacimiento.');
      return false;
    }

    if (_birthDate!.isAfter(DateTime.now())) {
      _setError(
        'La fecha de nacimiento no puede ser futura.',
      );
      return false;
    }

    if ((_age ?? 0) < 1) {
      _setError(
        'Ingresa una fecha de nacimiento válida.',
      );
      return false;
    }

    return true;
  }

  bool _validatePassword() {
    final password = _passwordController.text;

    final confirmPassword = _confirmPasswordController.text;

    if (password.length < 6) {
      _setError(
        'La contraseña debe tener al menos 6 caracteres.',
      );
      return false;
    }

    if (password != confirmPassword) {
      _setError(
        'Las contraseñas no coinciden.',
      );
      return false;
    }

    return true;
  }

  bool _validateContact() {
    final whatsapp = _normalizePhone(
      _whatsappController.text,
    );

    final email = _emailController.text.trim().toLowerCase();

    if (whatsapp.isEmpty) {
      _setError(
        'Ingresa tu número de WhatsApp.',
      );
      return false;
    }

    if (whatsapp.length < 8) {
      _setError(
        'Ingresa un número de WhatsApp válido.',
      );
      return false;
    }

    if (email.isEmpty) {
      _setError(
        'Ingresa tu correo electrónico.',
      );
      return false;
    }

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(email)) {
      _setError(
        'Ingresa un correo electrónico válido.',
      );
      return false;
    }

    return true;
  }

  void _setError(String message) {
    if (!mounted) {
      return;
    }

    setState(() {
      _errorMessage = message;
    });
  }

// ============================================================
// NAVEGACIÓN DE PASOS
// ============================================================

  void _nextStep() {
    FocusScope.of(context).unfocus();

    setState(() {
      _errorMessage = null;
    });

    if (_step == 0) {
      if (!_validatePersonalData()) {
        return;
      }

      setState(() {
        _step = 1;
      });

      return;
    }

    if (_step == 1) {
      if (!_validatePassword()) {
        return;
      }

      setState(() {
        _step = 2;
      });

      return;
    }

    if (_step == 2) {
      _createAccount();
    }
  }

  void _previousStep() {
    if (_isLoading) {
      return;
    }

    if (_step == 0) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _step--;
      _errorMessage = null;
    });
  }

// ============================================================
// VALIDAR WHATSAPP
// ============================================================

  Future<bool> _phoneAlreadyRegistered(
      String phone,
      ) async {
    final snapshot = await _firestore
        .collection('users')
        .where(
      'whatsapp',
      isEqualTo: phone,
    )
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

// ============================================================
// VALIDAR NOMBRE
// ============================================================

  Future<bool> _nameAlreadyRegistered(
      String fullName,
      ) async {
    final normalizedName = _normalizeName(fullName);

    final snapshot = await _firestore
        .collection('users')
        .where(
      'fullNameNormalized',
      isEqualTo: normalizedName,
    )
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

// ============================================================
// DIÁLOGO DE NOMBRE DUPLICADO
// ============================================================

  Future<bool?> _showDuplicateNameDialog(
      String fullName,
      ) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF181818),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Este nombre ya está registrado',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ya existe un jugador registrado con este nombre:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _limeColor.withValues(
                    alpha: 0.06,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _limeColor.withValues(
                      alpha: 0.18,
                    ),
                  ),
                ),
                child: Text(
                  fullName,
                  style: const TextStyle(
                    color: _limeColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                '¿Eres tú este jugador?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            16,
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(
                  color: Colors.white.withValues(
                    alpha: 0.18,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'NO',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _limeColor,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'SÍ, SOY YO',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

// ============================================================
// CONFIRMAR QUE ES OTRA PERSONA
// ============================================================

  Future<bool> _showDifferentPersonDialog() async {
    bool accepted = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
              context,
              setDialogState,
              ) {
            return AlertDialog(
              backgroundColor: const Color(0xFF181818),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Confirma tu identidad',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'El nombre que estás registrando ya pertenece '
                        'a otro jugador de NOVENTA.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 18),
                  CheckboxListTile(
                    value: accepted,
                    onChanged: (value) {
                      setDialogState(() {
                        accepted = value ?? false;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    activeColor: _limeColor,
                    checkColor: Colors.black,
                    controlAffinity:
                    ListTileControlAffinity.leading,
                    title: const Text(
                      'Declaro que estoy diciendo la verdad y '
                          'que no soy el jugador que ya está registrado '
                          'con este nombre.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                16,
              ),
              actions: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withValues(
                        alpha: 0.18,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'CANCELAR',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: accepted
                      ? () {
                    Navigator.pop(
                      dialogContext,
                      true,
                    );
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _limeColor,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor:
                    _limeColor.withValues(
                      alpha: 0.25,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'CONTINUAR',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    return result == true;
  }

// ============================================================
// RECUPERAR CONTRASEÑA
// ============================================================

  Future<void> _sendPasswordRecovery() async {
    final email = _emailController.text.trim().toLowerCase();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: const Color(0xFF181818),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Correo enviado',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            content: Text(
              'Si la cuenta asociada a $email existe, '
                  'recibirás un correo para recuperar tu contraseña.',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _limeColor,
                  foregroundColor: Colors.black,
                ),
                child: const Text(
                  'ACEPTAR',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = _authErrorMessage(e);
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = _cleanErrorMessage(e);
      });
    }
  }

// ============================================================
// CREAR CUENTA
// ============================================================

  Future<void> _createAccount() async {
    if (!_validateContact()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String? createdUid;

    try {
      final phone = _normalizePhone(
        _whatsappController.text,
      );

      final email = _emailController.text.trim().toLowerCase();

      final fullName = _fullName;

// ----------------------------------------------------------
// VALIDAR WHATSAPP
// ----------------------------------------------------------

      final phoneExists = await _phoneAlreadyRegistered(phone);

      if (phoneExists) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isLoading = false;
        });

        _setError(
          'Este número de WhatsApp ya está registrado en NOVENTA.',
        );

        return;
      }

// ----------------------------------------------------------
// VALIDAR NOMBRE COMPLETO
// ----------------------------------------------------------

      final nameExists = await _nameAlreadyRegistered(
        fullName,
      );

      if (nameExists) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isLoading = false;
        });

        final duplicateResponse =
        await _showDuplicateNameDialog(fullName);

        // Usuario canceló el diálogo.
        if (duplicateResponse == null) {
          return;
        }

        // ----------------------------------------------------
        // SÍ, SOY YO
        // ----------------------------------------------------

        if (duplicateResponse == true) {
          await _sendPasswordRecovery();
          return;
        }

        // ----------------------------------------------------
        // NO, SOY OTRA PERSONA
        // ----------------------------------------------------

        final confirmedDifferentPerson =
        await _showDifferentPersonDialog();

        if (!confirmedDifferentPerson) {
          return;
        }

        _duplicateNameAcknowledged = true;

        if (!mounted) {
          return;
        }

        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }

// ----------------------------------------------------------
// CREAR CUENTA EN FIREBASE AUTH
// ----------------------------------------------------------

      final credential = await _authService.createAccount(
        email: email,
        password: _passwordController.text,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception(
          'No se pudo obtener el usuario de Firebase.',
        );
      }

      createdUid = user.uid;

// ----------------------------------------------------------
// ENVIAR CORREO DE VERIFICACIÓN
// ----------------------------------------------------------

      await user.sendEmailVerification();

// ----------------------------------------------------------
// CREAR DOCUMENTO DE USUARIO
// ----------------------------------------------------------

      final now = DateTime.now();

      final userData = <String, dynamic>{
        'uid': createdUid,
        'name': _nameController.text.trim(),
        'firstLastName': _firstLastNameController.text.trim(),
        'secondLastName': _secondLastNameController.text.trim().isEmpty
            ? null
            : _secondLastNameController.text.trim(),
        'fullName': fullName,
        'fullNameNormalized': _normalizeName(fullName),
        'country': _selectedCountry,
        'birthDate': Timestamp.fromDate(
          _birthDate!,
        ),
        'whatsapp': phone,
        'email': email,
        'profilePhotoUrl': null,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),

        // Solo será true cuando NOVENTA detectó un nombre
        // duplicado y el usuario confirmó que NO es ese jugador.
        'duplicateNameAcknowledged': _duplicateNameAcknowledged,

        if (_duplicateNameAcknowledged)
          'duplicateNameAcknowledgedAt': Timestamp.fromDate(now),
      };

      await _firestore
          .collection('users')
          .doc(createdUid)
          .set(userData);

// ----------------------------------------------------------
// MEMBRESÍA
// ----------------------------------------------------------

      if (widget.access.isLeagueAdmin) {
        await _firestore
            .collection('leagueMembers')
            .doc(createdUid)
            .set({
          'userId': createdUid,
          'role': 'leagueAdmin',
          'status': 'active',
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        });
      } else {
        final fieldId = widget.access.fieldId;

        final accessCodeId = widget.access.accessCodeId;

        if (fieldId == null || fieldId.isEmpty) {
          throw Exception(
            'El código no tiene una cancha asociada.',
          );
        }

        if (accessCodeId.isEmpty) {
          throw Exception(
            'El código de acceso no tiene un identificador válido.',
          );
        }

        await _firestore
            .collection('fieldMembers')
            .doc(
          '${fieldId}_$createdUid',
        )
            .set({
          'userId': createdUid,
          'fieldId': fieldId,
          'accessCodeId': accessCodeId,
          'roles': <String>[
            'player',
          ],
          'status': 'active',
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        });
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;

        // Paso 3 = verificación de correo.
        _step = 3;
      });
    } on FirebaseAuthException catch (e) {
      if (createdUid != null) {
        await _cleanupCreatedUser(createdUid);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = _authErrorMessage(e);
      });
    } catch (e) {
      if (createdUid != null) {
        await _cleanupCreatedUser(createdUid);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = _cleanErrorMessage(e);
      });
    }
  }

// ============================================================
// COMPROBAR VERIFICACIÓN
// ============================================================

  Future<void> _checkEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _setError(
        'No se encontró la cuenta.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await user.reload();

      final updatedUser = FirebaseAuth.instance.currentUser;

      if (updatedUser == null) {
        throw Exception(
          'No se encontró la cuenta.',
        );
      }

      if (!updatedUser.emailVerified) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isLoading = false;
          _errorMessage = 'Tu correo todavía no está verificado. '
              'Abre el enlace que enviamos a tu correo '
              'y después presiona nuevamente '
              '"Ya verifiqué mi correo".';
        });

        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Correo verificado correctamente.',
          ),
        ),
      );

      Navigator.popUntil(
        context,
            (route) => route.isFirst,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = _authErrorMessage(e);
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = _cleanErrorMessage(e);
      });
    }
  }

// ============================================================
// REENVIAR CORREO
// ============================================================

  Future<void> _resendVerificationEmail() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _setError(
        'No se encontró la cuenta.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await user.sendEmailVerification();

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Correo de verificación enviado nuevamente.',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = _authErrorMessage(e);
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = _cleanErrorMessage(e);
      });
    }
  }

// ============================================================
// LIMPIAR USUARIO SI FALLA EL REGISTRO
// ============================================================

  Future<void> _cleanupCreatedUser(
      String uid,
      ) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .delete();
    } catch (_) {}

    try {
      await _firestore
          .collection('fieldMembers')
          .doc(
        '${widget.access.fieldId}_$uid',
      )
          .delete();
    } catch (_) {}

    try {
      await _firestore
          .collection('leagueMembers')
          .doc(uid)
          .delete();
    } catch (_) {}

    try {
      await FirebaseAuth.instance.currentUser?.delete();
    } catch (_) {}
  }

// ============================================================
// MENSAJES DE FIREBASE
// ============================================================

  String _authErrorMessage(
      FirebaseAuthException error,
      ) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'Este correo electrónico ya está registrado.';

      case 'invalid-email':
        return 'El correo electrónico no es válido.';

      case 'weak-password':
        return 'La contraseña es demasiado débil.';

      case 'network-request-failed':
        return 'No hay conexión con Firebase.';

      case 'too-many-requests':
        return 'Demasiados intentos. Intenta nuevamente más tarde.';

      case 'operation-not-allowed':
        return 'El método de autenticación no está habilitado.';

      default:
        return 'No fue posible crear la cuenta. Intenta nuevamente.';
    }
  }

  String _cleanErrorMessage(
      Object error,
      ) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(
        'Exception: '.length,
      );
    }

    return message;
  }

// ============================================================
// TEXTOS
// ============================================================

  String _registrationTitle() {
    if (widget.access.isLeagueAdmin) {
      return 'Administrador\nde liga';
    }

    return 'Crear tu\ncuenta';
  }

  String _registrationSubtitle() {
    if (widget.access.isLeagueAdmin) {
      return 'Regístrate como administrador de liga.';
    }

    return 'Tu cuenta podrá tener uno o varios roles dentro de NOVENTA.';
  }

// ============================================================
// DATOS PERSONALES
// ============================================================

  Widget _buildPersonalData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _registrationTitle(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            height: 1,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _registrationSubtitle(),
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 14,
            height: 1.35,
          ),
        ),
        if (!widget.access.isLeagueAdmin &&
            widget.access.fieldName != null) ...[
          const SizedBox(height: 18),
          _InfoCard(
            icon: Icons.stadium_outlined,
            title: 'Cancha de registro',
            value: widget.access.fieldName!,
          ),
        ],
        const SizedBox(height: 28),
        _InputField(
          controller: _nameController,
          label: 'Nombre',
          hint: 'Tu nombre',
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        _InputField(
          controller: _firstLastNameController,
          label: 'Primer apellido',
          hint: 'Primer apellido',
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        _InputField(
          controller: _secondLastNameController,
          label: 'Segundo apellido',
          hint: 'Segundo apellido (opcional)',
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        CountrySelector(
          selectedCountry: _selectedCountry,
          onSelected: (country) {
            setState(() {
              _selectedCountry = country.name;
              _errorMessage = null;
            });
          },
        ),
        const SizedBox(height: 16),
        _DateField(
          value: _formatBirthDate(),
          onTap: _selectBirthDate,
        ),
        if (_age != null) ...[
          const SizedBox(height: 8),
          Text(
            'Edad: $_age años',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }

// ============================================================
// CONTRASEÑA
// ============================================================

  Widget _buildPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Crea tu\ncontraseña',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            height: 1,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Utilizarás esta contraseña para iniciar sesión en NOVENTA.',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 14,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 28),
        _InputField(
          controller: _passwordController,
          label: 'Contraseña',
          hint: 'Mínimo 6 caracteres',
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: Colors.white54,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _InputField(
          controller: _confirmPasswordController,
          label: 'Confirmar contraseña',
          hint: 'Repite tu contraseña',
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _obscureConfirmPassword =
                !_obscureConfirmPassword;
              });
            },
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: Colors.white54,
            ),
          ),
        ),
      ],
    );
  }

// ============================================================
// CONTACTO
// ============================================================

  Widget _buildContact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Datos de contacto',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'El número de WhatsApp será único para tu cuenta.',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 14,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 28),
        _InputField(
          controller: _whatsappController,
          label: 'WhatsApp',
          hint: 'Número de WhatsApp',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _InputField(
          controller: _emailController,
          label: 'Correo electrónico',
          hint: 'correo@ejemplo.com',
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

// ============================================================
// VERIFICACIÓN DE CORREO
// ============================================================

  Widget _buildEmailVerification() {
    final email = _emailController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 30),
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            color: _limeColor.withValues(
              alpha: 0.12,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: _limeColor.withValues(
                alpha: 0.35,
              ),
            ),
          ),
          child: const Icon(
            Icons.mark_email_unread_outlined,
            color: _limeColor,
            size: 42,
          ),
        ),
        const SizedBox(height: 25),
        const Text(
          'Verifica tu\ncorreo electrónico',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 27,
            height: 1.05,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Te enviamos un enlace de verificación a:',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white60,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          email,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _limeColor,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Abre tu correo y pulsa el enlace de verificación. '
              'Después regresa a NOVENTA y confirma que ya verificaste tu correo.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        _InfoCard(
          icon: Icons.mark_email_read_outlined,
          title: 'Revisa también',
          value:
          'Si no encuentras el correo, revisa tu carpeta de spam o correo no deseado.',
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed:
            _isLoading ? null : _checkEmailVerification,
            style: ElevatedButton.styleFrom(
              backgroundColor: _limeColor,
              foregroundColor: Colors.black,
              disabledBackgroundColor:
              _limeColor.withValues(
                alpha: 0.35,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.black,
              ),
            )
                : const Text(
              'YA VERIFIQUÉ MI CORREO',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.7,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed:
            _isLoading ? null : _resendVerificationEmail,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(
                color: Colors.white.withValues(
                  alpha: 0.18,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'REENVIAR CORREO',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
              ),
            ),
          ),
        ),
      ],
    );
  }

// ============================================================
// PASO ACTUAL
// ============================================================

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return _buildPersonalData();

      case 1:
        return _buildPassword();

      case 2:
        return _buildContact();

      case 3:
        return _buildEmailVerification();

      default:
        return const SizedBox();
    }
  }

// ============================================================
// TEXTO DEL BOTÓN INFERIOR
// ============================================================

  String _buttonText() {
    if (_step == 2) {
      return 'Crear cuenta';
    }

    return 'Continuar';
  }

// ============================================================
// BUILD
// ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondo_bienvenidos.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(
                alpha: 0.76,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    14,
                    20,
                    8,
                  ),
                  child: Row(
                    children: [
                      _BackButton(
                        onPressed:
                        _step == 3 ? null : _previousStep,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          widget.access.isLeagueAdmin
                              ? 'ADMINISTRADOR DE LIGA'
                              : 'REGISTRO',
                          style: const TextStyle(
                            color: _limeColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_step < 3)
                  _ProgressIndicator(
                    step: _step,
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      24,
                      18,
                      24,
                      30,
                    ),
                    child: _buildCurrentStep(),
                  ),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      24,
                      0,
                      24,
                      10,
                    ),
                    child: _ErrorMessage(
                      message: _errorMessage!,
                    ),
                  ),
                if (_step < 3)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      24,
                      0,
                      24,
                      18,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed:
                        _isLoading ? null : _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _limeColor,
                          foregroundColor: Colors.black,
                          disabledBackgroundColor:
                          _limeColor.withValues(
                            alpha: 0.35,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.black,
                          ),
                        )
                            : Text(
                          _buttonText(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// INDICADOR DE PROGRESO
// ================================================================

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({
    required this.step,
  });

  final int step;

  static const Color _limeColor = Color(0xFF9DFF21);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        24,
        8,
        24,
        4,
      ),
      child: Row(
        children: List.generate(
          3,
              (index) {
            final active = index <= step;

            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(
                  right: index == 2 ? 0 : 6,
                ),
                decoration: BoxDecoration(
                  color: active
                      ? _limeColor
                      : Colors.white12,
                  borderRadius:
                  BorderRadius.circular(10),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ================================================================
// INPUT
// ================================================================

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.textCapitalization =
        TextCapitalization.none,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final Widget? suffixIcon;

  static const Color _limeColor = Color(0xFF9DFF21);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization:
          textCapitalization,
          obscureText: obscureText,
          autocorrect: false,
          enableSuggestions: false,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Colors.white30,
            ),
            filled: true,
            fillColor:
            const Color(0xFF171718),
            suffixIcon: suffixIcon,
            contentPadding:
            const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(14),
              borderSide:
              const BorderSide(
                color: Colors.white12,
              ),
            ),
            enabledBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(14),
              borderSide:
              const BorderSide(
                color: Colors.white12,
              ),
            ),
            focusedBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(14),
              borderSide:
              const BorderSide(
                color: _limeColor,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ================================================================
// FECHA
// ================================================================

class _DateField extends StatelessWidget {
  const _DateField({
    required this.value,
    required this.onTap,
  });

  final String value;
  final VoidCallback onTap;

  static const Color _limeColor =
  Color(0xFF9DFF21);

  @override
  Widget build(BuildContext context) {
    final isSelected =
        value !=
            'Selecciona tu fecha de nacimiento';

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'Fecha de nacimiento',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius:
          BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding:
            const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
            decoration: BoxDecoration(
              color:
              const Color(0xFF171718),
              borderRadius:
              BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white12,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: _limeColor,
                  size: 21,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white54,
                      fontSize: 15,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white54,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ================================================================
// INFO CARD
// ================================================================

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  static const Color _limeColor =
  Color(0xFF9DFF21);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _limeColor.withValues(
          alpha: 0.06,
        ),
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: _limeColor.withValues(
            alpha: 0.18,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: _limeColor,
            size: 21,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 3,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// BOTÓN ATRÁS
// ================================================================

class _BackButton extends StatelessWidget {
  const _BackButton({
    required this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.black.withValues(
            alpha: 0.55,
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(
              alpha: 0.14,
            ),
          ),
        ),
        child: Icon(
          Icons.arrow_back_ios_new,
          color: onPressed == null
              ? Colors.white24
              : Colors.white,
          size: 17,
        ),
      ),
    );
  }
}

// ================================================================
// MENSAJE DE ERROR
// ================================================================

class _ErrorMessage
    extends StatelessWidget {
  const _ErrorMessage({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.red.withValues(
          alpha: 0.10,
        ),
        borderRadius:
        BorderRadius.circular(10),
        border: Border.all(
          color: Colors.red.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.redAccent,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}