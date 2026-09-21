import 'package:flutter/material.dart';

import '../../models/field_access_code.dart';
import '../../models/player_registration.dart';
import '../../services/auth_service.dart';
import '../../services/player_registration_service.dart';
import '../../widgets/country_selector.dart';

class ManagerRegistrationPage extends StatefulWidget {
  const ManagerRegistrationPage({
    super.key,
    required this.accessCode,
  });

  final FieldAccessCode accessCode;

  @override
  State<ManagerRegistrationPage> createState() =>
      _ManagerRegistrationPageState();
}

class _ManagerRegistrationPageState extends State<ManagerRegistrationPage> {
  static const Color _limeColor = Color(0xFF9DFF21);
  static const Color _backgroundColor = Color(0xFF0B0B0B);

  final AuthService _authService = AuthService();

  final PlayerRegistrationService _registrationService =
  PlayerRegistrationService();

  final TextEditingController _nameController = TextEditingController();
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
      helpText: 'Selecciona tu fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      builder: (context, child) {
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

    if (selected != null) {
      setState(() {
        _birthDate = selected;
        _errorMessage = null;
      });
    }
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

  bool _validatePersonalData() {
    if (_nameController.text.trim().isEmpty) {
      _setError('Ingresa tu nombre.');
      return false;
    }

    if (_firstLastNameController.text.trim().isEmpty) {
      _setError('Ingresa tu primer apellido.');
      return false;
    }

    if (_selectedCountry == null ||
        _selectedCountry!.trim().isEmpty) {
      _setError('Selecciona tu país.');
      return false;
    }

    if (_birthDate == null) {
      _setError('Selecciona tu fecha de nacimiento.');
      return false;
    }

    final age = _age;

    if (age == null || age < 18) {
      _setError(
        'Debes ser mayor de edad para registrarte como Delegado / DT.',
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
      _setError('Las contraseñas no coinciden.');
      return false;
    }

    return true;
  }

  bool _validateContactData() {
    final whatsapp = _whatsappController.text.trim();
    final email = _emailController.text.trim();

    if (whatsapp.isEmpty) {
      _setError('Ingresa tu número de WhatsApp.');
      return false;
    }

    if (email.isEmpty) {
      _setError('Ingresa tu correo electrónico.');
      return false;
    }

    if (!email.contains('@') || !email.contains('.')) {
      _setError('Ingresa un correo electrónico válido.');
      return false;
    }

    return true;
  }

  void _setError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  void _nextStep() {
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
    if (_step == 0 || _isLoading) {
      return;
    }

    setState(() {
      _step--;
      _errorMessage = null;
    });
  }

  Future<void> _createAccount() async {
    if (!_validateContactData()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String? createdUid;

    try {
      final userCredential = await _authService.createAccount(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = userCredential.user;

      if (user == null) {
        throw Exception(
          'No se pudo obtener el usuario de Firebase.',
        );
      }

      createdUid = user.uid;

      final now = DateTime.now();

      final manager = PlayerRegistration(
        uid: createdUid,
        role: 'managerTeam',
        name: _nameController.text.trim(),
        firstLastName: _firstLastNameController.text.trim(),
        secondLastName:
        _secondLastNameController.text.trim().isEmpty
            ? null
            : _secondLastNameController.text.trim(),
        country: _selectedCountry!,
        birthDate: _birthDate!,
        whatsapp: _whatsappController.text.trim(),
        email: _emailController.text.trim().toLowerCase(),
        profilePhotoUrl: null,
        createdAt: now,
        updatedAt: now,
      );

      await _registrationService.createPlayerFromAuth(
        uid: createdUid,
        player: manager,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _step = 3;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = _getErrorMessage(e);
      });
    }
  }

  String _getErrorMessage(Object error) {
    final message = error.toString();

    if (message.contains('email-already-in-use')) {
      return 'Este correo electrónico ya está registrado.';
    }

    if (message.contains('invalid-email')) {
      return 'El correo electrónico no es válido.';
    }

    if (message.contains('weak-password')) {
      return 'La contraseña es demasiado débil.';
    }

    if (message.contains('network-request-failed')) {
      return 'No hay conexión con Firebase. Verifica tu conexión a internet.';
    }

    return 'No fue posible completar el registro. Intenta nuevamente.';
  }

  String _formatBirthDate() {
    if (_birthDate == null) {
      return 'Seleccionar fecha';
    }

    final day = _birthDate!.day.toString().padLeft(2, '0');
    final month = _birthDate!.month.toString().padLeft(2, '0');
    final year = _birthDate!.year.toString();

    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: _step > 0 && !_isLoading
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _previousStep,
        )
            : null,
        title: const Text(
          'Registro Delegado / DT',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: _step == 3
            ? _buildCompleted()
            : Column(
          children: [
            _buildProgress(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  20,
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
                  12,
                ),
                child: _ErrorMessage(
                  message: _errorMessage!,
                ),
              ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        24,
        12,
        24,
        4,
      ),
      child: Row(
        children: List.generate(
          3,
              (index) {
            final active = index <= _step;

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
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
        ),
      ),
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

      default:
        return const SizedBox();
    }
  }

  Widget _buildPersonalData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          'Crea tu cuenta como Delegado / DT.',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 15,
          ),
        ),
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

  Widget _buildPassword() {
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
          'Utilizarás esta contraseña para iniciar sesión en NOVENTA.',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 28),
        _InputField(
          controller: _passwordController,
          label: 'Contraseña',
          hint: 'Mínimo 6 caracteres',
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: Colors.white54,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        _InputField(
          controller: _confirmPasswordController,
          label: 'Confirmar contraseña',
          hint: 'Repite tu contraseña',
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: Colors.white54,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword =
                !_obscureConfirmPassword;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          'Utilizaremos estos datos para identificar y contactar tu cuenta.',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 15,
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
          textCapitalization: TextCapitalization.none,
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _limeColor.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _limeColor.withValues(alpha: .25),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: _limeColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Cancha: ${widget.accessCode.fieldName}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _limeColor.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _limeColor.withValues(alpha: .25),
            ),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.sports_soccer,
                color: _limeColor,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Después de registrarte, el administrador de la liga '
                      'podrá asignarte el equipo que vas a administrar.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        24,
        12,
        24,
        20,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: _limeColor,
            foregroundColor: Colors.black,
            disabledBackgroundColor: Colors.white12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
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
              : Text(
            _step == 2
                ? 'Crear cuenta'
                : 'Continuar',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompleted() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
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
              'Tu cuenta de Delegado / DT fue creada correctamente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              widget.accessCode.fieldName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _limeColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _limeColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
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
    this.textCapitalization = TextCapitalization.none,
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

  static const Color limeColor = Color(0xFF9DFF21);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          textCapitalization: textCapitalization,
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
            fillColor: const Color(0xFF171718),
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Colors.white12,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Colors.white12,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: limeColor,
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

  @override
  Widget build(BuildContext context) {
    final hasValue = value != 'Seleccionar fecha';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 17,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF171718),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white12,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.white54,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    value,
                    style: TextStyle(
                      color: hasValue
                          ? Colors.white
                          : Colors.white30,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.red.withValues(alpha: .30),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}