import 'package:flutter/material.dart';

import '../../models/player_registration.dart';
import '../../widgets/country_selector.dart';
import '../../services/auth_service.dart';
import '../../services/player_registration_service.dart';

class PlayerRegistrationPage extends StatefulWidget {
  const PlayerRegistrationPage({
    super.key,
  });

  @override
  State<PlayerRegistrationPage> createState() =>
      _PlayerRegistrationPageState();
}

class _PlayerRegistrationPageState
    extends State<PlayerRegistrationPage> {
  // ============================================================
  // SERVICES
  // ============================================================

  final AuthService _authService = AuthService();
  final PlayerRegistrationService _registrationService =
  PlayerRegistrationService();

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _nameController =
  TextEditingController();

  final TextEditingController _firstLastNameController =
  TextEditingController();

  final TextEditingController _secondLastNameController =
  TextEditingController();

  final TextEditingController _whatsappController =
  TextEditingController();

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  final TextEditingController _confirmPasswordController =
  TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  int _step = 0;

  bool _isLoading = false;

  String? _errorMessage;

  String? _selectedCountry;

  DateTime? _birthDate;

  // ============================================================
  // COLORS
  // ============================================================

  static const Color _limeColor = Color(0xFF9DFF21);

  // ============================================================
  // DISPOSE
  // ============================================================

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
  // NAVIGATION
  // ============================================================

  void _nextStep() {
    setState(() {
      _errorMessage = null;
    });

    if (!_validateCurrentStep()) {
      return;
    }

    if (_step < 3) {
      setState(() {
        _step++;
      });
    }
  }

  void _previousStep() {
    if (_step > 0) {
      setState(() {
        _step--;
        _errorMessage = null;
      });
    }
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  bool _validateCurrentStep() {
    switch (_step) {
      case 0:
        return _validatePersonalData();

      case 1:
        return _validatePasswordData();

      case 2:
        return _validateContactData();

      default:
        return true;
    }
  }

  bool _validatePersonalData() {
    if (_nameController.text.trim().isEmpty) {
      _showError('Ingresa tu nombre.');
      return false;
    }

    if (_firstLastNameController.text.trim().isEmpty) {
      _showError('Ingresa tu primer apellido.');
      return false;
    }

    if (_selectedCountry == null ||
        _selectedCountry!.isEmpty) {
      _showError('Selecciona tu país.');
      return false;
    }

    if (_birthDate == null) {
      _showError(
        'Selecciona tu fecha de nacimiento.',
      );
      return false;
    }

    if (_birthDate!.isAfter(DateTime.now())) {
      _showError(
        'La fecha de nacimiento no puede ser futura.',
      );
      return false;
    }

    return true;
  }

  bool _validateContactData() {
    if (_whatsappController.text.trim().isEmpty) {
      _showError(
        'Ingresa tu número de WhatsApp.',
      );
      return false;
    }

    if (_emailController.text.trim().isEmpty) {
      _showError(
        'Ingresa tu correo electrónico.',
      );
      return false;
    }

    final email = _emailController.text.trim().toLowerCase();



    if (!email.contains('@') || !email.contains('.')) {
      _showError(
        'Ingresa un correo electrónico válido.',
      );
      return false;
    }

    return true;
  }

  bool _validatePasswordData() {
    final password = _passwordController.text;

    final confirmPassword =
        _confirmPasswordController.text;

    if (password.isEmpty) {
      _showError(
        'Ingresa una contraseña.',
      );
      return false;
    }

    if (password.length < 6) {
      _showError(
        'La contraseña debe tener al menos 6 caracteres.',
      );
      return false;
    }

    if (confirmPassword.isEmpty) {
      _showError(
        'Confirma tu contraseña.',
      );
      return false;
    }

    if (password != confirmPassword) {
      _showError(
        'Las contraseñas no coinciden.',
      );
      return false;
    }

    return true;
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectBirthDate() async {
    final today = DateTime.now();

    final defaultDate = DateTime(
      today.year - 18,
      today.month,
      today.day,
    );

    final firstDate = DateTime(
      today.year - 120,
      today.month,
      today.day,
    );

    final lastDate = today;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? defaultDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'FECHA DE NACIMIENTO',
      cancelText: 'CANCELAR',
      confirmText: 'ACEPTAR',
      fieldLabelText: 'Fecha de nacimiento',
      fieldHintText: 'dd/mm/aaaa',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _limeColor,
              onPrimary: Colors.black,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _birthDate = selectedDate;
        _errorMessage = null;
      });
    }
  }

  // ============================================================
  // AGE
  // ============================================================

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();

    int age = today.year - birthDate.year;

    final birthdayHasNotPassed =
        today.month < birthDate.month ||
            (today.month == birthDate.month &&
                today.day < birthDate.day);

    if (birthdayHasNotPassed) {
      age--;
    }

    return age;
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime date) {
    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    final year = date.year.toString();

    return '$day/$month/$year';
  }

  // ============================================================
  // CREATE FIREBASE ACCOUNT
  // ============================================================

  Future<void> _createFirebaseAccount() async {
    if (!_validateContactData()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String? createdUid;
    String? reservedName;

    try {
      final name =
      _nameController.text.trim();

      final firstLastName =
      _firstLastNameController.text.trim();

      final secondLastName =
      _secondLastNameController.text.trim();

      final email =
      _emailController.text
          .trim()
          .toLowerCase();

      final password =
          _passwordController.text;

      final fullName = [
        name,
        firstLastName,
        if (secondLastName.isNotEmpty)
          secondLastName,
      ].join(' ');

      final fullNameNormalized =
      _normalizeText(fullName);

      // ==========================================================
      // 1. CREAR CUENTA EN FIREBASE AUTH
      // ==========================================================

      final userCredential =
      await _authService.createAccount(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user == null) {
        throw Exception(
          'No fue posible obtener el usuario creado.',
        );
      }

      createdUid = user.uid;

      // ==========================================================
      // 2. RESERVAR NOMBRE
      // ==========================================================

      await _registrationService
          .reservePlayerName(
        uid: createdUid,
        fullName: fullName,
        fullNameNormalized:
        fullNameNormalized,
      );

      reservedName =
          fullNameNormalized;

      // ==========================================================
      // 3. CREAR DOCUMENTO DEL JUGADOR
      // ==========================================================

      final player =
      PlayerRegistration(
        uid: createdUid,
        role: 'player',
        name: name,
        firstLastName:
        firstLastName,
        secondLastName:
        secondLastName.isEmpty
            ? null
            : secondLastName,
        country: _selectedCountry,
        birthDate: _birthDate,
        whatsapp:
        _whatsappController.text.trim(),
        email: email,
        profilePhotoUrl: null,
        identityDocument: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _registrationService
          .createPlayerFromAuth(
        uid: createdUid,
        player: player,
      );

      // ==========================================================
      // 4. REGISTRO COMPLETADO
      // ==========================================================

      if (!mounted) {
        return;
      }

      setState(() {
        _step = 3;
        _isLoading = false;
      });
    } on PlayerNameAlreadyExistsException {
      // ==========================================================
      // EL NOMBRE YA EXISTE
      // ==========================================================

      if (createdUid != null) {
        try {
          await _authService.currentUser?.delete();
        } catch (e) {
          debugPrint(
            'ERROR ELIMINANDO AUTH DUPLICADO: $e',
          );
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage =
        'Ya existe un jugador registrado con este nombre completo.';
      });
    } catch (e) {
      debugPrint(
        'ERROR REGISTRATION: $e',
      );

      // ==========================================================
      // LIMPIAR RESERVA SI YA SE HABÍA CREADO
      // ==========================================================

      if (reservedName != null &&
          createdUid != null) {
        try {
          await _registrationService
              .releasePlayerName(
            fullNameNormalized:
            reservedName,
            uid: createdUid,
          );
        } catch (releaseError) {
          debugPrint(
            'ERROR LIBERANDO NOMBRE: '
                '$releaseError',
          );
        }
      }

      // ==========================================================
      // LIMPIAR CUENTA AUTH SI FALLÓ FIRESTORE
      // ==========================================================

      if (createdUid != null) {
        try {
          await _authService.currentUser?.delete();
        } catch (authError) {
          debugPrint(
            'ERROR ELIMINANDO AUTH: '
                '$authError',
          );
        }
      }

      if (!mounted) {
        return;
      }

      final error = e.toString();

      String message =
          'No fue posible completar el registro. '
          'Verifica tus datos e intenta nuevamente.';

      if (error.contains(
        'Ya existe una cuenta con este correo',
      )) {
        message =
        'Ya existe una cuenta con este correo. '
            'Utiliza otro correo o inicia sesión.';
      }

      setState(() {
        _isLoading = false;
        _errorMessage = message;
      });
    }
  }

  String _normalizeText(String value) {
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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ============================================================
          // IMAGEN DE FONDO
          // ============================================================

          Positioned.fill(
            child: Image.asset(
              'assets/images/fondo_bienvenidos.png',
              fit: BoxFit.cover,
            ),
          ),

          // ============================================================
          // CAPA PARA DIFUMINAR / OSCURECER EL FONDO
          // ============================================================

          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.75),
            ),
          ),

          // ============================================================
          // CONTENIDO
          // ============================================================

          SafeArea(
            child: Column(
              children: [
                // --------------------------------------------------
                // HEADER
                // --------------------------------------------------

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      if (_step > 0 && _step < 3)
                        _BackButton(
                          onPressed: _previousStep,
                        ),

                      const SizedBox(width: 12),

                      const Expanded(
                        child: Text(
                          'Registro de jugador',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // --------------------------------------------------
                // PROGRESS
                // --------------------------------------------------

                if (_step < 3)
                  _ProgressIndicator(
                    currentStep: _step,
                  ),

                // --------------------------------------------------
                // CONTENT
                // --------------------------------------------------

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _buildCurrentStep(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CURRENT STEP
  // ============================================================

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return _buildPersonalDataStep();

      case 1:
        return _buildPasswordStep();

      case 2:
        return _buildContactStep();

      case 3:
        return _buildCompletedStep();

      default:
        return const SizedBox();
    }
  }

  // ============================================================
  // STEP 0 - PERSONAL DATA
  // ============================================================

  Widget _buildPersonalDataStep() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'Datos personales',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Cuéntanos un poco sobre ti.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 28),

        _FieldLabel(
          text: 'Nombre',
        ),

        const SizedBox(height: 8),

        _TextField(
          controller: _nameController,
          hintText: 'Ingresa tu nombre',
          textCapitalization:
          TextCapitalization.words,
        ),

        const SizedBox(height: 20),

        _FieldLabel(
          text: 'Primer apellido',
        ),

        const SizedBox(height: 8),

        _TextField(
          controller:
          _firstLastNameController,
          hintText:
          'Ingresa tu primer apellido',
          textCapitalization:
          TextCapitalization.words,
        ),

        const SizedBox(height: 20),

        _FieldLabel(
          text: 'Segundo apellido',
        ),

        const SizedBox(height: 8),

        _TextField(
          controller:
          _secondLastNameController,
          hintText:
          'Ingresa tu segundo apellido',
          textCapitalization:
          TextCapitalization.words,
        ),

        const SizedBox(height: 20),

        _FieldLabel(
          text: 'País',
        ),

        const SizedBox(height: 8),

        // --------------------------------------------------------
        // COUNTRY DROPDOWN
        // --------------------------------------------------------

        CountrySelector(
          selectedCountry: _selectedCountry,
          onSelected: (country) {
            setState(() {
              _selectedCountry = country.name;
              _errorMessage = null;
            });
          },
        ),

        const SizedBox(height: 20),

        _FieldLabel(
          text: 'Fecha de nacimiento',
        ),

        const SizedBox(height: 8),

        // --------------------------------------------------------
        // BIRTH DATE
        // --------------------------------------------------------

        InkWell(
          onTap: _selectBirthDate,
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
              color: Colors.white10,
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: _limeColor,
                  size: 21,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    _birthDate == null
                        ? 'Selecciona tu fecha de nacimiento'
                        : _formatDate(
                      _birthDate!,
                    ),
                    style: TextStyle(
                      color: _birthDate == null
                          ? Colors.white54
                          : Colors.white,
                      fontSize: 16,
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

        if (_birthDate != null) ...[
          const SizedBox(height: 10),

          Text(
            'Edad: ${_calculateAge(_birthDate!)} años',
            style: const TextStyle(
              color: _limeColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],

        const SizedBox(height: 24),

        if (_errorMessage != null)
          _ErrorMessage(
            message: _errorMessage!,
          ),

        const SizedBox(height: 16),

        _PrimaryButton(
          text: 'Continuar',
          onPressed: _nextStep,
        ),
      ],
    );
  }

  // ============================================================
  // STEP 1 - CONTACT
  // ============================================================

  Widget _buildContactStep() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'Datos de contacto',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Necesitamos estos datos para poder contactarte.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 28),

        _FieldLabel(
          text: 'WhatsApp',
        ),

        const SizedBox(height: 8),

        _TextField(
          controller: _whatsappController,
          hintText: 'Ingresa tu número de WhatsApp',
          keyboardType:
          TextInputType.phone,
        ),

        const SizedBox(height: 20),

        _FieldLabel(
          text: 'Correo electrónico',
        ),

        const SizedBox(height: 8),

        _TextField(
          controller: _emailController,
          hintText:
          'Ingresa tu correo electrónico',
          keyboardType:
          TextInputType.emailAddress,
        ),

        const SizedBox(height: 24),

        if (_errorMessage != null)
          _ErrorMessage(
            message: _errorMessage!,
          ),

        const SizedBox(height: 16),

        _PrimaryButton(
          text: 'Crear cuenta',
          isLoading: _isLoading,
          onPressed: _createFirebaseAccount,
        ),
      ],
    );
  }

  // ============================================================
  // STEP 2 - PASSWORD
  // ============================================================

  Widget _buildPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Crea tu contraseña',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Utiliza una contraseña que puedas recordar fácilmente.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 28),

        _FieldLabel(
          text: 'Contraseña',
        ),

        const SizedBox(height: 8),

        _PasswordField(
          controller: _passwordController,
          hintText: 'Ingresa tu contraseña',
        ),

        const SizedBox(height: 20),

        _FieldLabel(
          text: 'Confirmar contraseña',
        ),

        const SizedBox(height: 8),

        _PasswordField(
          controller: _confirmPasswordController,
          hintText: 'Confirma tu contraseña',
        ),

        const SizedBox(height: 24),

        if (_errorMessage != null)
          _ErrorMessage(
            message: _errorMessage!,
          ),

        const SizedBox(height: 16),

        _PrimaryButton(
          text: 'Continuar',
          isLoading: _isLoading,
          onPressed: _nextStep,
        ),
      ],
    );
  }

  // ============================================================
  // STEP 3 - COMPLETED
  // ============================================================

  Widget _buildCompletedStep() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.symmetric(
          vertical: 60,
        ),
        child: Column(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: _limeColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.black,
                size: 50,
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              '¡Registro completado!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Tu cuenta de jugador fue creada correctamente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 30),

            _PrimaryButton(
              text: 'Continuar',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// PROGRESS INDICATOR
// ==================================================================

class _ProgressIndicator extends StatelessWidget {
  final int currentStep;

  const _ProgressIndicator({
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Row(
        children: List.generate(
          3,
              (index) {
            final active =
                index <= currentStep;

            return Expanded(
              child: Container(
                height: 4,
                margin:
                const EdgeInsets.symmetric(
                  horizontal: 3,
                ),
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFF9DFF21)
                      : Colors.white24,
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

// ==================================================================
// FIELD LABEL
// ==================================================================

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ==================================================================
// TEXT FIELD
// ==================================================================

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  const _TextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.textCapitalization =
        TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization:
      textCapitalization,
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.white54,
        ),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF9DFF21),
            width: 1.5,
          ),
        ),
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
      ),
    );
  }
}

// ==================================================================
// PASSWORD FIELD
// ==================================================================

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;

  const _PasswordField({
    required this.controller,
    required this.hintText,
  });

  @override
  State<_PasswordField> createState() =>
      _PasswordFieldState();
}

class _PasswordFieldState
    extends State<_PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          color: Colors.white54,
        ),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF9DFF21),
            width: 1.5,
          ),
        ),
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText
                ? Icons.visibility_off
                : Icons.visibility,
            color: Colors.white54,
          ),
          onPressed: () {
            setState(() {
              _obscureText =
              !_obscureText;
            });
          },
        ),
      ),
    );
  }
}

// ==================================================================
// ERROR MESSAGE
// ==================================================================

class _ErrorMessage extends StatelessWidget {
  final String message;

  const _ErrorMessage({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(
          alpha: 0.12,
        ),
        borderRadius:
        BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.redAccent,
            size: 20,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// BACK BUTTON
// ==================================================================

class _BackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _BackButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(
        Icons.arrow_back,
        color: Colors.white,
      ),
    );
  }
}

// ==================================================================
// PRIMARY BUTTON
// ==================================================================

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const _PrimaryButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed:
        isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
          const Color(0xFF9DFF21),
          foregroundColor: Colors.black,
          disabledBackgroundColor:
          const Color(0xFF9DFF21)
              .withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child:
          CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.black,
          ),
        )
            : Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),
    );
  }
}