import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '/services/auth_service.dart';
import '/widgets/common.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({
    super.key,
  });

  @override
  State<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState
    extends State<ForgotPasswordPage> {
  final AuthService _authService = AuthService();

  final TextEditingController _emailController =
  TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // ============================================================
  // ENVIAR CORREO DE RECUPERACIÓN
  // ============================================================

  Future<void> _sendRecoveryEmail() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _errorMessage = null;
    });

    final email = _emailController.text.trim().toLowerCase();

    if (email.isEmpty) {
      setState(() {
        _errorMessage =
        'Ingresa tu correo electrónico.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint(
        'NOVENTA - RECUPERACIÓN DE CONTRASEÑA',
      );
      debugPrint(
        'NOVENTA - EMAIL: $email',
      );

      await _authService.sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      // --------------------------------------------------------
      // MENSAJE DE ÉXITO
      // --------------------------------------------------------

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF151515),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Text(
              'Correo enviado',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Si el correo está registrado, recibirás instrucciones para restablecer tu contraseña.',
              style: TextStyle(
                color: Colors.white70,
                height: 1.4,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Aceptar',
                  style: TextStyle(
                    color: lime,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
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
        'NOVENTA - ERROR: $e',
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
  // MENSAJES FIREBASE
  // ============================================================

  String _firebaseErrorMessage(FirebaseException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'El correo electrónico no es válido.';

      case 'user-not-found':
        return 'No existe una cuenta con este correo electrónico.';

      case 'too-many-requests':
        return 'Demasiados intentos. Intenta nuevamente más tarde.';

      case 'network-request-failed':
        return 'No hay conexión con Firebase.';

      default:
        return e.message ??
            'No fue posible enviar el correo. Intenta nuevamente.';
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
  // INPUT
  // ============================================================

  InputDecoration _inputDecoration() {
    return InputDecoration(
      labelText: 'Correo electrónico',
      labelStyle: const TextStyle(
        color: Colors.white54,
      ),
      prefixIcon: const Icon(
        Icons.email_outlined,
        color: Colors.white54,
      ),
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
            color: Colors.white,
            fontWeight: FontWeight.bold,
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
                30,
                24,
                30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 30),

                  // ------------------------------------------------
                  // LOGO
                  // ------------------------------------------------

                  Image.asset(
                    'assets/images/logo_noventa.png',
                    height: 70,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 28),

                  // ------------------------------------------------
                  // TÍTULO
                  // ------------------------------------------------

                  const Text(
                    'Recuperar contraseña',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ------------------------------------------------
                  // DESCRIPCIÓN
                  // ------------------------------------------------

                  const Text(
                    'Ingresa tu correo electrónico para recuperar tu contraseña.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ------------------------------------------------
                  // CORREO
                  // ------------------------------------------------

                  TextField(
                    controller: _emailController,
                    enabled: !_isLoading,
                    keyboardType:
                    TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                    onSubmitted: (_) {
                      if (!_isLoading) {
                        _sendRecoveryEmail();
                      }
                    },
                    decoration: _inputDecoration(),
                  ),

                  const SizedBox(height: 20),

                  // ------------------------------------------------
                  // ERROR
                  // ------------------------------------------------

                  if (_errorMessage != null) ...[
                    Container(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius:
                        BorderRadius.circular(12),
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
                  // BOTÓN
                  // ------------------------------------------------

                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : _sendRecoveryEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lime,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor:
                        lime.withValues(alpha: 0.45),
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
                        'Enviar correo',
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