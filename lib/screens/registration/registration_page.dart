import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../player_registration/access_code_page.dart';
import '../profile_selection.dart';
import '../../services/auth_service.dart';
import '../../widgets/country_selector.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({
    super.key,
    required this.access,
  });

  final RegistrationAccess access;

  @override
  State<RegistrationPage> createState() =>
      _RegistrationPageState();
}

class _RegistrationPageState
    extends State<RegistrationPage> {
  static const Color _limeColor =
  Color(0xFF9DFF21);

  static const Color _backgroundColor =
  Color(0xFF0B0B0B);

  final AuthService _authService = AuthService();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final TextEditingController _nameController =
  TextEditingController();

  final TextEditingController
  _firstLastNameController =
  TextEditingController();

  final TextEditingController
  _secondLastNameController =
  TextEditingController();

  final TextEditingController
  _whatsappController =
  TextEditingController();

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController
  _passwordController =
  TextEditingController();

  final TextEditingController
  _confirmPasswordController =
  TextEditingController();

  int _step = 0;

  bool _isLoading = false;

  bool _obscurePassword = true;

  bool _obscureConfirmPassword = true;

  String? _errorMessage;

  String? _selectedCountry;

  DateTime? _birthDate;

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

    int age =
        today.year - _birthDate!.year;

    if (today.month < _birthDate!.month ||
        (today.month ==
            _birthDate!.month &&
            today.day < _birthDate!.day)) {
      age--;
    }

    return age;
  }

  String _normalizePhone(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'[^0-9+]'), '');
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

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();

    final initialDate =
        _birthDate ??
            DateTime(
              now.year - 18,
              now.month,
              now.day,
            );

    final selected =
    await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1940),
      lastDate: now,
      helpText:
      'Fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      builder: (
          context,
          child,
          ) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
            const ColorScheme.dark(
              primary: _limeColor,
              onPrimary: Colors.black,
              surface:
              Color(0xFF181818),
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

    final day =
    _birthDate!.day
        .toString()
        .padLeft(2, '0');

    final month =
    _birthDate!.month
        .toString()
        .padLeft(2, '0');

    return '$day/$month/${_birthDate!.year}';
  }

  bool _validatePersonalData() {
    if (_nameController.text
        .trim()
        .isEmpty) {
      _setError(
        'Ingresa tu nombre.',
      );
      return false;
    }

    if (_firstLastNameController.text
        .trim()
        .isEmpty) {
      _setError(
        'Ingresa tu primer apellido.',
      );
      return false;
    }

    if (_selectedCountry == null ||
        _selectedCountry!.isEmpty) {
      _setError(
        'Selecciona tu país.',
      );
      return false;
    }

    if (_birthDate == null) {
      _setError(
        'Selecciona tu fecha de nacimiento.',
      );
      return false;
    }

    if (_birthDate!
        .isAfter(DateTime.now())) {
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
    final password =
        _passwordController.text;

    final confirmPassword =
        _confirmPasswordController.text;

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
    final whatsapp =
    _normalizePhone(
      _whatsappController.text,
    );

    final email =
    _emailController.text
        .trim()
        .toLowerCase();

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
      final phone =
      _normalizePhone(
        _whatsappController.text,
      );

      final email =
      _emailController.text
          .trim()
          .toLowerCase();

      final phoneExists =
      await _phoneAlreadyRegistered(
        phone,
      );

      if (phoneExists) {
        _setError(
          'Este número de WhatsApp ya está registrado en NOVENTA.',
        );

        setState(() {
          _isLoading = false;
        });

        return;
      }

      final credential =
      await _authService.createAccount(
        email: email,
        password:
        _passwordController.text,
      );

      final user =
          credential.user;

      if (user == null) {
        throw Exception(
          'No se pudo obtener el usuario de Firebase.',
        );
      }

      createdUid = user.uid;

      final now = DateTime.now();

      final userData =
      <String, dynamic>{
        'uid': createdUid,
        'name':
        _nameController.text.trim(),
        'firstLastName':
        _firstLastNameController
            .text
            .trim(),
        'secondLastName':
        _secondLastNameController
            .text
            .trim()
            .isEmpty
            ? null
            : _secondLastNameController
            .text
            .trim(),
        'fullName': _fullName,
        'fullNameNormalized':
        _normalizeName(_fullName),
        'country':
        _selectedCountry,
        'birthDate':
        Timestamp.fromDate(
          _birthDate!,
        ),
        'whatsapp': phone,
        'email': email,
        'profilePhotoUrl': null,
        'createdAt':
        Timestamp.fromDate(now),
        'updatedAt':
        Timestamp.fromDate(now),
      };

      await _firestore
          .collection('users')
          .doc(createdUid)
          .set(userData);

      if (widget.access.isLeagueAdmin) {
        await _firestore
            .collection('leagueMembers')
            .doc(createdUid)
            .set({
          'userId': createdUid,
          'role': 'leagueAdmin',
          'status': 'active',
          'createdAt':
          Timestamp.fromDate(now),
          'updatedAt':
          Timestamp.fromDate(now),
        });
      } else {
        final fieldId =
            widget.access.fieldId;

        if (fieldId == null ||
            fieldId.isEmpty) {
          throw Exception(
            'El código no tiene una cancha asociada.',
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
          'roles': <String>[
            'player',
          ],
          'status': 'active',
          'createdAt':
          Timestamp.fromDate(now),
          'updatedAt':
          Timestamp.fromDate(now),
        });
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _step = 3;
      });
    } on FirebaseAuthException catch (e) {
      if (createdUid != null) {
        await _cleanupCreatedUser(
          createdUid,
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage =
            _authErrorMessage(e);
      });
    } catch (e) {
      if (createdUid != null) {
        await _cleanupCreatedUser(
          createdUid,
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage =
        'No fue posible completar el registro. Intenta nuevamente.';
      });
    }
  }

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
      await FirebaseAuth
          .instance
          .currentUser
          ?.delete();
    } catch (_) {}
  }

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

      default:
        return 'No fue posible crear la cuenta. Intenta nuevamente.';
    }
  }

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

  Widget _buildPersonalData() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
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
            widget.access.fieldName !=
                null) ...[
          const SizedBox(height: 18),
          _InfoCard(
            icon:
            Icons.stadium_outlined,
            title:
            'Cancha de registro',
            value:
            widget.access.fieldName!,
          ),
        ],

        const SizedBox(height: 28),

        _InputField(
          controller: _nameController,
          label: 'Nombre',
          hint: 'Tu nombre',
          textCapitalization:
          TextCapitalization.words,
        ),

        const SizedBox(height: 16),

        _InputField(
          controller:
          _firstLastNameController,
          label: 'Primer apellido',
          hint: 'Primer apellido',
          textCapitalization:
          TextCapitalization.words,
        ),

        const SizedBox(height: 16),

        _InputField(
          controller:
          _secondLastNameController,
          label: 'Segundo apellido',
          hint:
          'Segundo apellido (opcional)',
          textCapitalization:
          TextCapitalization.words,
        ),

        const SizedBox(height: 16),

        CountrySelector(
          selectedCountry:
          _selectedCountry,
          onSelected: (country) {
            setState(() {
              _selectedCountry =
                  country.name;
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

  Widget _buildPassword() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
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
          controller:
          _passwordController,
          label: 'Contraseña',
          hint: 'Mínimo 6 caracteres',
          obscureText:
          _obscurePassword,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _obscurePassword =
                !_obscurePassword;
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
          controller:
          _confirmPasswordController,
          label: 'Confirmar contraseña',
          hint:
          'Repite tu contraseña',
          obscureText:
          _obscureConfirmPassword,
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

  Widget _buildContact() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
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
          controller:
          _whatsappController,
          label: 'WhatsApp',
          hint: 'Número de WhatsApp',
          keyboardType:
          TextInputType.phone,
        ),

        const SizedBox(height: 16),

        _InputField(
          controller:
          _emailController,
          label: 'Correo electrónico',
          hint: 'correo@ejemplo.com',
          keyboardType:
          TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _buildCompleted() {
    final title =
    widget.access.isLeagueAdmin
        ? 'Registro completado'
        : 'Cuenta creada';

    final description =
    widget.access.isLeagueAdmin
        ? 'Tu cuenta de administrador de liga ha sido creada correctamente.'
        : 'Tu cuenta ha sido creada correctamente. El administrador podrá asignarte los roles correspondientes.';

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 35),

        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            color: _limeColor
                .withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: _limeColor
                  .withValues(alpha: 0.35),
            ),
          ),
          child: const Icon(
            Icons.check_rounded,
            color: _limeColor,
            size: 42,
          ),
        ),

        const SizedBox(height: 25),

        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 14,
            height: 1.45,
          ),
        ),

        const SizedBox(height: 28),

        if (!widget.access.isLeagueAdmin)
          _InfoCard(
            icon: Icons.verified_user_outlined,
            title: 'Estado',
            value:
            'Registro realizado correctamente',
          ),
      ],
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return _buildPersonalData();

      case 1:
        return _buildPassword();

      case 2:
        return _buildContact();

      case 3:
        return _buildCompleted();

      default:
        return const SizedBox();
    }
  }

  String _buttonText() {
    if (_step == 2) {
      return 'Crear cuenta';
    }

    if (_step == 3) {
      return 'Continuar';
    }

    return 'Continuar';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      _backgroundColor,
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
              color: Colors.black
                  .withValues(alpha: 0.76),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                  const EdgeInsets.fromLTRB(
                    20,
                    14,
                    20,
                    8,
                  ),
                  child: Row(
                    children: [
                      _BackButton(
                        onPressed:
                        _previousStep,
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Text(
                          widget.access
                              .isLeagueAdmin
                              ? 'ADMINISTRADOR DE LIGA'
                              : 'REGISTRO',
                          style:
                          const TextStyle(
                            color: _limeColor,
                            fontSize: 10,
                            fontWeight:
                            FontWeight.w800,
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
                  child:
                  SingleChildScrollView(
                    padding:
                    const EdgeInsets.fromLTRB(
                      24,
                      18,
                      24,
                      30,
                    ),
                    child:
                    _buildCurrentStep(),
                  ),
                ),

                if (_errorMessage !=
                    null &&
                    _step < 3)
                  Padding(
                    padding:
                    const EdgeInsets.fromLTRB(
                      24,
                      0,
                      24,
                      10,
                    ),
                    child:
                    _ErrorMessage(
                      message:
                      _errorMessage!,
                    ),
                  ),

                if (_step < 3)
                  Padding(
                    padding:
                    const EdgeInsets.fromLTRB(
                      24,
                      0,
                      24,
                      18,
                    ),
                    child:
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child:
                      ElevatedButton(
                        onPressed:
                        _isLoading
                            ? null
                            : _nextStep,
                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          _limeColor,
                          foregroundColor:
                          Colors.black,
                          disabledBackgroundColor:
                          _limeColor
                              .withValues(
                            alpha: 0.35,
                          ),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                              16,
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                          CircularProgressIndicator(
                            strokeWidth:
                            2.5,
                            color:
                            Colors.black,
                          ),
                        )
                            : Text(
                          _buttonText(),
                          style:
                          const TextStyle(
                            fontSize: 14,
                            fontWeight:
                            FontWeight
                                .w900,
                            letterSpacing:
                            0.8,
                          ),
                        ),
                      ),
                    ),
                  ),

                if (_step == 3)
                  Padding(
                    padding:
                    const EdgeInsets.fromLTRB(
                      24,
                      0,
                      24,
                      18,
                    ),
                    child:
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child:
                      ElevatedButton(
                        onPressed: () {
                          Navigator.popUntil(
                            context,
                                (route) =>
                            route.isFirst,
                          );
                        },
                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          _limeColor,
                          foregroundColor:
                          Colors.black,
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                              16,
                            ),
                          ),
                          elevation: 0,
                        ),
                        child:
                        const Text(
                          'ENTRAR A NOVENTA',
                          style:
                          TextStyle(
                            fontSize: 14,
                            fontWeight:
                            FontWeight.w900,
                            letterSpacing:
                            0.8,
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

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({
    required this.step,
  });

  final int step;

  static const Color _limeColor =
  Color(0xFF9DFF21);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        24,
        8,
        24,
        4,
      ),
      child: Row(
        children: List.generate(
          3,
              (index) {
            final active =
                index <= step;

            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(
                  right:
                  index == 2 ? 0 : 6,
                ),
                decoration:
                BoxDecoration(
                  color: active
                      ? _limeColor
                      : Colors.white12,
                  borderRadius:
                  BorderRadius.circular(
                    10,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

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
  final TextCapitalization
  textCapitalization;
  final bool obscureText;
  final Widget? suffixIcon;

  static const Color _limeColor =
  Color(0xFF9DFF21);

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
          decoration:
          InputDecoration(
            hintText: hint,
            hintStyle:
            const TextStyle(
              color: Colors.white30,
            ),
            filled: true,
            fillColor:
            const Color(0xFF171718),
            suffixIcon:
            suffixIcon,
            contentPadding:
            const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
            border:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(
                14,
              ),
              borderSide:
              const BorderSide(
                color: Colors.white12,
              ),
            ),
            enabledBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(
                14,
              ),
              borderSide:
              const BorderSide(
                color: Colors.white12,
              ),
            ),
            focusedBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(
                14,
              ),
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
            decoration:
            BoxDecoration(
              color:
              const Color(0xFF171718),
              borderRadius:
              BorderRadius.circular(
                14,
              ),
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
      padding:
      const EdgeInsets.all(14),
      decoration:
      BoxDecoration(
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
                  style:
                  const TextStyle(
                    color:
                    Colors.white54,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 2,
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

class _BackButton extends StatelessWidget {
  const _BackButton({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 42,
        height: 42,
        decoration:
        BoxDecoration(
          color: Colors.black
              .withValues(alpha: 0.55),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white
                .withValues(alpha: 0.14),
          ),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 17,
        ),
      ),
    );
  }
}

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
      decoration:
      BoxDecoration(
        color: Colors.red
            .withValues(alpha: 0.10),
        borderRadius:
        BorderRadius.circular(10),
        border: Border.all(
          color: Colors.red
              .withValues(alpha: 0.25),
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
              style:
              const TextStyle(
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