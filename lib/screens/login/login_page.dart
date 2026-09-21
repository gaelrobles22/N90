import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '/services/auth_service.dart';
import '/widgets/common.dart';

class LoginPage extends StatefulWidget {
  final Future<void> Function(
      String uid,
      Map<String, dynamic> userData,
      List<Map<String, dynamic>> fieldMembers,
      ) onLoginSuccess;

  const LoginPage({
    super.key,
    required this.onLoginSuccess,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _errorMessage = null;
    });

    final email =
    _emailController.text.trim().toLowerCase();

    final password =
        _passwordController.text;

    // ------------------------------------------------------------
    // VALIDACIONES
    // ------------------------------------------------------------

    if (email.isEmpty) {
      setState(() {
        _errorMessage =
        'Ingresa tu correo electrónico.';
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _errorMessage =
        'Ingresa tu contraseña.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ----------------------------------------------------------
      // FIREBASE AUTH
      // ----------------------------------------------------------

      debugPrint(
        '========================================',
      );
      debugPrint(
        'NOVENTA - LOGIN PAGE',
      );
      debugPrint(
        'NOVENTA - INICIANDO SESIÓN',
      );
      debugPrint(
        'NOVENTA - EMAIL: $email',
      );
      debugPrint(
        '========================================',
      );

      final credential = await _authService.signIn(
        email: email,
        password: password,
      );

      final user =
          credential.user;

      if (user == null) {
        throw Exception(
          'No fue posible identificar la cuenta.',
        );
      }

      final uid = user.uid;

      debugPrint(
        'NOVENTA - LOGIN PAGE: AUTH CORRECTO',
      );
      debugPrint(
        'NOVENTA - LOGIN PAGE: UID: $uid',
      );

      // ----------------------------------------------------------
      // OBTENER USUARIO
      // ----------------------------------------------------------

      final userDocument =
      await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (!userDocument.exists) {
        await _authService.signOut();

        throw Exception(
          'No se encontraron los datos de tu usuario.',
        );
      }

      final userData =
      userDocument.data();

      if (userData == null) {
        await _authService.signOut();

        throw Exception(
          'Los datos de tu usuario están vacíos.',
        );
      }

      debugPrint(
        'NOVENTA - LOGIN PAGE: USER ENCONTRADO',
      );
      debugPrint(
        'NOVENTA - LOGIN PAGE: USER DATA: $userData',
      );

      // ----------------------------------------------------------
      // OBTENER FIELD MEMBERS
      // ----------------------------------------------------------

      final membersSnapshot =
      await _firestore
          .collection('fieldMembers')
          .where(
        'userId',
        isEqualTo: uid,
      )
          .get();

      final fieldMembers =
      membersSnapshot.docs
          .map(
            (doc) => {
          ...doc.data(),
          'id': doc.id,
        },
      )
          .where(
            (member) =>
        member['status'] == 'active',
      )
          .toList();

      debugPrint(
        'NOVENTA - LOGIN PAGE: FIELD MEMBERS: ${fieldMembers.length}',
      );

      if (fieldMembers.isEmpty) {
        await _authService.signOut();

        throw Exception(
          'Tu cuenta todavía no tiene una cancha asignada.',
        );
      }

      // ----------------------------------------------------------
      // MOSTRAR INFORMACIÓN EN LOG
      // ----------------------------------------------------------

      debugPrint(
        'NOVENTA - LOGIN PAGE: MEMBERS DATA: $fieldMembers',
      );

      debugPrint(
        'NOVENTA - LOGIN PAGE: LLAMANDO onLoginSuccess',
      );

      // ----------------------------------------------------------
      // IMPORTANTE
      //
      // Esperamos a que AppShell termine de:
      //
      // 1. identificar el rol
      // 2. identificar la cancha
      // 3. buscar el enrollment
      // 4. identificar el equipo
      // 5. preparar el Player
      // 6. cambiar started = true
      //
      // Después cerramos LoginPage.
      // ----------------------------------------------------------

      await widget.onLoginSuccess(
        uid,
        userData,
        fieldMembers,
      );

      debugPrint(
        'NOVENTA - LOGIN PAGE: onLoginSuccess TERMINADO',
      );

      if (!mounted) {
        return;
      }

      debugPrint(
        'NOVENTA - LOGIN PAGE: CERRANDO LOGIN',
      );

      // ----------------------------------------------------------
      // REGRESAR A APPSHELL
      // ----------------------------------------------------------

      Navigator.pop(context);

    } on FirebaseException catch (e) {
      debugPrint(
        'NOVENTA - LOGIN PAGE: FIREBASE ERROR',
      );
      debugPrint(
        'NOVENTA - LOGIN PAGE: CODE: ${e.code}',
      );
      debugPrint(
        'NOVENTA - LOGIN PAGE: MESSAGE: ${e.message}',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage =
            _firebaseErrorMessage(e);
      });

    } catch (e) {
      debugPrint(
        'NOVENTA - LOGIN PAGE: ERROR: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage =
            _cleanErrorMessage(e);
      });

    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // MENSAJES FIREBASE
  // ============================================================

  String _firebaseErrorMessage(
      FirebaseException e,
      ) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Correo o contraseña incorrectos.';

      case 'invalid-email':
        return 'El correo electrónico no es válido.';

      case 'user-disabled':
        return 'Esta cuenta está deshabilitada.';

      case 'too-many-requests':
        return 'Demasiados intentos. Intenta nuevamente más tarde.';

      case 'network-request-failed':
        return 'No hay conexión con Firebase.';

      default:
        return e.message ??
            'No fue posible iniciar sesión.';
    }
  }

  String _cleanErrorMessage(
      Object error,
      ) {
    final message =
    error.toString();

    if (message.startsWith(
        'Exception: ')) {
      return message.substring(
        'Exception: '.length,
      );
    }

    return message;
  }

  // ============================================================
  // INPUT
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: Colors.white54,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(
        alpha: 0.05,
      ),
      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.white.withValues(
            alpha: 0.08,
          ),
        ),
      ),
      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: lime,
          width: 1.5,
        ),
      ),
      labelStyle: const TextStyle(
        color: Colors.white54,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
          ),
          onPressed: _isLoading
              ? null
              : () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Iniciar sesión',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.fromLTRB(
            24,
            20,
            24,
            30,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // --------------------------------------------------
              // LOGO / TITULO
              // --------------------------------------------------

              const Text(
                'NOVENTA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: lime,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Bienvenido de nuevo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 40),

              // --------------------------------------------------
              // CORREO
              // --------------------------------------------------

              TextField(
                controller:
                _emailController,
                enabled: !_isLoading,
                keyboardType:
                TextInputType.emailAddress,
                textInputAction:
                TextInputAction.next,
                autocorrect: false,
                decoration:
                _inputDecoration(
                  label: 'Correo electrónico',
                  icon: Icons.email_outlined,
                ),
              ),

              const SizedBox(height: 18),

              // --------------------------------------------------
              // PASSWORD
              // --------------------------------------------------

              TextField(
                controller:
                _passwordController,
                enabled: !_isLoading,
                obscureText:
                _obscurePassword,
                textInputAction:
                TextInputAction.done,
                onSubmitted: (_) {
                  if (!_isLoading) {
                    _login();
                  }
                },
                decoration:
                _inputDecoration(
                  label: 'Contraseña',
                  icon:
                  Icons.lock_outline,
                  suffixIcon:
                  IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons
                          .visibility_outlined
                          : Icons
                          .visibility_off_outlined,
                      color:
                      Colors.white54,
                    ),
                    onPressed:
                    _isLoading
                        ? null
                        : () {
                      setState(() {
                        _obscurePassword =
                        !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // --------------------------------------------------
              // ERROR
              // --------------------------------------------------

              if (_errorMessage != null)
                Container(
                  width:
                  double.infinity,
                  margin:
                  const EdgeInsets.only(
                    bottom: 18,
                  ),
                  padding:
                  const EdgeInsets.all(
                    14,
                  ),
                  decoration:
                  BoxDecoration(
                    color: Colors.red
                        .withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      12,
                    ),
                    border:
                    Border.all(
                      color: Colors.red
                          .withValues(
                        alpha: 0.35,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      const Icon(
                        Icons
                            .error_outline,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style:
                          const TextStyle(
                            color:
                            Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // --------------------------------------------------
              // BOTÓN LOGIN
              // --------------------------------------------------

              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed:
                  _isLoading
                      ? null
                      : _login,
                  style:
                  ElevatedButton
                      .styleFrom(
                    backgroundColor:
                    lime,
                    foregroundColor:
                    Colors.black,
                    disabledBackgroundColor:
                    lime.withValues(
                      alpha: 0.35,
                    ),
                    disabledForegroundColor:
                    Colors.black54,
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius
                          .circular(
                        14,
                      ),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color:
                      Colors.black,
                    ),
                  )
                      : const Text(
                    'Iniciar sesión',
                    style:
                    TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight
                          .w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --------------------------------------------------
              // REGRESAR
              // --------------------------------------------------

              TextButton(
                onPressed:
                _isLoading
                    ? null
                    : () {
                  Navigator.pop(
                    context,
                  );
                },
                child: const Text(
                  'Regresar',
                  style: TextStyle(
                    color: Colors.white60,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}