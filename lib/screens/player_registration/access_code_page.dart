import 'package:flutter/material.dart';

import '../../models/field_access_code.dart';
import '../../services/field_access_code_service.dart';

class AccessCodePage extends StatefulWidget {
  const AccessCodePage({
    super.key,
    required this.onAccessGranted,
  });

  final void Function(FieldAccessCode accessCode) onAccessGranted;

  @override
  State<AccessCodePage> createState() => _AccessCodePageState();
}

class _AccessCodePageState extends State<AccessCodePage> {
  final TextEditingController _codeController =
  TextEditingController();

  final FocusNode _codeFocusNode = FocusNode();

  final FieldAccessCodeService _accessCodeService =
  FieldAccessCodeService();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  Future<void> _validateCode() async {
    FocusScope.of(context).unfocus();

    final code = _codeController.text.trim();

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
      final accessCode =
      await _accessCodeService.validateCode(code);

      if (!mounted) return;

      if (accessCode == null) {
        setState(() {
          _isLoading = false;
          _errorMessage =
          'El código no es válido o ya no se encuentra activo.';
        });
        return;
      }

      setState(() {
        _isLoading = false;
      });

      widget.onAccessGranted(accessCode);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
        'No fue posible validar el código. '
            'Intenta nuevamente.';
      });
    }
  }

  void _onCodeChanged(String value) {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // =====================================================
            // FONDO
            // =====================================================

            Positioned.fill(
              child: Image.asset(
                'assets/images/fondo_bienvenidos.png',
                fit: BoxFit.cover,
              ),
            ),

            // =====================================================
            // OVERLAY
            // =====================================================

            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha:0.78),
              ),
            ),

            // =====================================================
            // CONTENIDO
            // =====================================================

            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                33,
                34,
                33,
                30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =================================================
                  // HEADER
                  // =================================================

                  Row(
                    children: [
                      _BackButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 17),
                      const Text(
                        'CÓDIGO DE ACCESO',
                        style: TextStyle(
                          color: Color(0xFF9DFF21),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.2,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 42),

                  // =================================================
                  // TÍTULO
                  // =================================================

                  const Text(
                    'INGRESA TU\nCÓDIGO DE ACCESO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 31,
                      fontWeight: FontWeight.w900,
                      height: 1.04,
                      letterSpacing: -1.0,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'Ingresa el código proporcionado por '
                        'tu campo de fútbol para comenzar tu registro.',
                    style: TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 35),

                  // =================================================
                  // LABEL
                  // =================================================

                  const Text(
                    'CÓDIGO DE ACCESO',
                    style: TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 9),

                  // =================================================
                  // INPUT
                  // =================================================

                  TextField(
                    controller: _codeController,
                    focusNode: _codeFocusNode,
                    textCapitalization:
                    TextCapitalization.characters,
                    autocorrect: false,
                    enableSuggestions: false,
                    maxLength: 20,
                    onChanged: _onCodeChanged,
                    onSubmitted: (_) {
                      if (!_isLoading) {
                        _validateCode();
                      }
                    },
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ej. N90-REF82K',
                      hintStyle: const TextStyle(
                        color: Color(0xFF555555),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                      ),
                      counterText: '',
                      filled: true,
                      fillColor:
                      const Color(0xFF171718),
                      contentPadding:
                      const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 19,
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: Color(0xFF303030),
                        ),
                      ),
                      enabledBorder:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: Color(0xFF303030),
                        ),
                      ),
                      focusedBorder:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: Color(0xFF9DFF21),
                          width: 1.5,
                        ),
                      ),
                      errorBorder:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ),

                  // =================================================
                  // ERROR
                  // =================================================

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: Colors.redAccent,
                          size: 19,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 28),

                  // =================================================
                  // BOTÓN
                  // =================================================

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                      _isLoading ? null : _validateCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFF9DFF21),
                        foregroundColor: Colors.black,
                        disabledBackgroundColor:
                        const Color(0xFF506610),
                        disabledForegroundColor:
                        Colors.black54,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(18),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                          AlwaysStoppedAnimation<
                              Color>(
                            Colors.black,
                          ),
                        ),
                      )
                          : const Text(
                        'CONTINUAR',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                          FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // =================================================
                  // INFORMACIÓN
                  // =================================================

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF151516),
                      borderRadius:
                      BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF292929),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color:
                            const Color(0xFF1D2615),
                            borderRadius:
                            BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            Icons.info_outline_rounded,
                            color:
                            Color(0xFF9DFF21),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 13),
                        const Expanded(
                          child: Text(
                            'El código debe ser proporcionado '
                                'por uno de los campos de fútbol '
                                'registrados en NOVENTA.',
                            style: TextStyle(
                              color:
                              Color(0xFF888888),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =================================================
                  // AYUDA
                  // =================================================

                  Center(
                    child: TextButton(
                      onPressed: () {
                        _showHelpDialog();
                      },
                      child: const Text(
                        '¿No tienes un código?',
                        style: TextStyle(
                          color: Color(0xFFAAAAAA),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
          const Color(0xFF191919),
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(24),
          ),
          title: const Text(
            '¿No tienes un código?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Solicita el código de acceso directamente '
                'en el campo de fútbol donde juegas.',
            style: TextStyle(
              color: Color(0xFF999999),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'ENTENDIDO',
                style: TextStyle(
                  color: Color(0xFF9DFF21),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ==================================================================
// BOTÓN REGRESAR
// ==================================================================

class _BackButton extends StatelessWidget {
  const _BackButton({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius:
        BorderRadius.circular(30),
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: const Color(0xFF191919),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF303030),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 19,
          ),
        ),
      ),
    );
  }
}