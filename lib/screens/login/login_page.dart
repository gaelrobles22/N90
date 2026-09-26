import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '/services/auth_service.dart';
import '/widgets/common.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  final Future<void> Function(
      String uid,
      Map<String, dynamic> userData,
      List<Map<String, dynamic>> fieldMembers,
      ) onLoginSuccess;

  final Future<void> Function(
      String uid,
      Map<String, dynamic> userData,
      ) onFieldAssignmentRequired;

  const LoginPage({
    super.key,
    required this.onLoginSuccess,
    required this.onFieldAssignmentRequired,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
  // INICIAR SESIÓN
  // ============================================================

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _errorMessage = null;
    });

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Ingresa tu correo electrónico.';
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Ingresa tu contraseña.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('========================================');
      debugPrint('NOVENTA - INICIANDO SESIÓN');
      debugPrint('NOVENTA - EMAIL: $email');
      debugPrint('========================================');

      // ----------------------------------------------------------
      // AUTENTICACIÓN
      // ----------------------------------------------------------

      final userCredential = await _authService.signIn(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user == null) {
        throw Exception(
          'No fue posible obtener el usuario autenticado.',
        );
      }

      final uid = user.uid;

      debugPrint('NOVENTA - UID: $uid');

      // ----------------------------------------------------------
      // OBTENER DATOS DEL USUARIO
      // ----------------------------------------------------------

      final userDoc =
      await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        throw Exception(
          'No encontramos la información de tu cuenta.',
        );
      }

      final userData = userDoc.data() ?? {};

      debugPrint('NOVENTA - USUARIO EN FIRESTORE:');
      debugPrint(userData.toString());

      // ----------------------------------------------------------
      // OBTENER MEMBRESÍAS ACTIVAS
      // ----------------------------------------------------------

      final membersSnapshot = await _firestore
          .collection('fieldMembers')
          .where('userId', isEqualTo: uid)
          .where('status', isEqualTo: 'active')
          .get();

      final fieldMembers = membersSnapshot.docs
          .map(
            (doc) => {
          'id': doc.id,
          ...doc.data(),
        },
      )
          .toList();

      debugPrint(
        'NOVENTA - MEMBRESÍAS ACTIVAS: ${fieldMembers.length}',
      );

      for (final member in fieldMembers) {
        debugPrint(
          'NOVENTA - FIELD MEMBER: $member',
        );
      }

      // ----------------------------------------------------------
      // SIN CANCHA ASIGNADA
      // ----------------------------------------------------------

      if (fieldMembers.isEmpty) {
        debugPrint(
          'NOVENTA - USUARIO SIN CANCHA ASIGNADA',
        );

        await widget.onFieldAssignmentRequired(
          uid,
          userData,
        );

        if (!mounted) return;

        Navigator.pop(context);
        return;
      }

      // ----------------------------------------------------------
      // LOGIN EXITOSO
      // ----------------------------------------------------------

      debugPrint('NOVENTA - LOGIN EXITOSO');

      await widget.onLoginSuccess(
        uid,
        userData,
        fieldMembers,
      );

      if (!mounted) return;

      Navigator.pop(context);
    } on FirebaseException catch (e) {
      debugPrint(
        'NOVENTA - ERROR FIREBASE LOGIN',
      );
      debugPrint(
        'NOVENTA - CODE: ${e.code}',
      );
      debugPrint(
        'NOVENTA - MESSAGE: ${e.message}',
      );

      if (!mounted) return;

      setState(() {
        _errorMessage = _firebaseErrorMessage(e);
      });
    } catch (e) {
      debugPrint(
        'NOVENTA - ERROR LOGIN: $e',
      );

      if (!mounted) return;

      setState(() {
        _errorMessage = _cleanErrorMessage(e);
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
  // RECUPERAR CONTRASEÑA
  // ============================================================

  Future<void> _forgotPassword() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim().toLowerCase();

    if (email.isEmpty) {
      setState(() {
        _errorMessage =
        'Ingresa tu correo electrónico para recuperar tu contraseña.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint(
        '========================================',
      );
      debugPrint(
        'NOVENTA - RECUPERACIÓN DE CONTRASEÑA',
      );
      debugPrint(
        'NOVENTA - EMAIL: $email',
      );
      debugPrint(
        '========================================',
      );

      await _authService.sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Si el correo está registrado, recibirás instrucciones para restablecer tu contraseña.',
          ),
        ),
      );
    } on FirebaseException catch (e) {
      debugPrint(
        'NOVENTA - ERROR RECUPERANDO CONTRASEÑA',
      );
      debugPrint(
        'NOVENTA - CODE: ${e.code}',
      );
      debugPrint(
        'NOVENTA - MESSAGE: ${e.message}',
      );

      if (!mounted) return;

      setState(() {
        _errorMessage = _firebaseErrorMessage(e);
      });
    } catch (e) {
      debugPrint(
        'NOVENTA - ERROR RECUPERANDO CONTRASEÑA: $e',
      );

      if (!mounted) return;

      setState(() {
        _errorMessage = _cleanErrorMessage(e);
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
  // MENSAJES DE FIREBASE
  // ============================================================

  String _firebaseErrorMessage(FirebaseException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo electrónico.';

      case 'wrong-password':
        return 'La contraseña es incorrecta.';

      case 'invalid-credential':
        return 'El correo o la contraseña son incorrectos.';

      case 'invalid-email':
        return 'El correo electrónico no es válido.';

      case 'user-disabled':
        return 'Esta cuenta está deshabilitada.';

      case 'too-many-requests':
        return 'Demasiados intentos. Intenta nuevamente más tarde.';

      case 'network-request-failed':
        return 'No hay conexión con Firebase.';

      case 'operation-not-allowed':
        return 'Esta operación no está habilitada.';

      default:
        return e.message ?? 'Ocurrió un error. Intenta nuevamente.';
    }
  }

  String _cleanErrorMessage(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }

    return message;
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.white54,
      ),
      prefixIcon: Icon(
        icon,
        color: Colors.white54,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
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
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
    );
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
          onPressed: _isLoading
              ? null
              : () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Regresar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),

      body: Stack(
        fit: StackFit.expand,
        children: [
          // ------------------------------------------------------
          // FONDO
          // ------------------------------------------------------

          Image.asset(
            'assets/images/fondo_bienvenidos.png',
            fit: BoxFit.cover,
          ),

          Container(
            color: Colors.black.withValues(alpha: 0.72),
          ),

          // ------------------------------------------------------
          // CONTENIDO
          // ------------------------------------------------------

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                24,
                20,
                24,
                30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // ------------------------------------------------
                  // LOGO
                  // ------------------------------------------------

                  Image.asset(
                    'assets/images/logo_noventa.png',
                    height: 70,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 8),

                  // ------------------------------------------------
                  // TÍTULO
                  // ------------------------------------------------

                  const Text(
                    'Iniciar sesión',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ------------------------------------------------
                  // CORREO
                  // ------------------------------------------------

                  TextField(
                    controller: _emailController,
                    enabled: !_isLoading,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    decoration: _inputDecoration(
                      label: 'Correo electrónico',
                      icon: Icons.email_outlined,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ------------------------------------------------
                  // CONTRASEÑA
                  // ------------------------------------------------

                  TextField(
                    controller: _passwordController,
                    enabled: !_isLoading,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      if (!_isLoading) {
                        _login();
                      }
                    },
                    decoration: _inputDecoration(
                      label: 'Contraseña',
                      icon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.white54,
                        ),
                        onPressed: _isLoading
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

                  // ------------------------------------------------
                  // OLVIDÉ MI CONTRASEÑA
                  // ------------------------------------------------

                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordPage(),
                          ),
                        );
                      },
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          color: lime,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ------------------------------------------------
                  // ERROR
                  // ------------------------------------------------

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withValues(
                            alpha: 0.35,
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
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ------------------------------------------------
                  // BOTÓN INICIAR SESIÓN
                  // ------------------------------------------------

                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lime,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor:
                        lime.withValues(alpha: 0.45),
                        disabledForegroundColor:
                        Colors.black54,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.black,
                        ),
                      )
                          : const Text(
                        'Iniciar sesión',
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
          ),
        ],
      ),
    );
  }
}