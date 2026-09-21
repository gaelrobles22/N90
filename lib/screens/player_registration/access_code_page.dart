import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RegistrationAccess {
  const RegistrationAccess({
    required this.code,
    required this.type,
    this.fieldId,
    this.fieldName,
  });

  final String code;

  /// field
  /// leagueAdmin
  final String type;

  final String? fieldId;
  final String? fieldName;

  bool get isField => type == 'field';

  bool get isLeagueAdmin => type == 'leagueAdmin';
}

class AccessCodePage extends StatefulWidget {
  const AccessCodePage({
    super.key,
    required this.onAccessGranted,
  });

  final void Function(RegistrationAccess access)
  onAccessGranted;

  @override
  State<AccessCodePage> createState() =>
      _AccessCodePageState();
}

class _AccessCodePageState extends State<AccessCodePage> {
  final TextEditingController _codeController =
  TextEditingController();

  final FocusNode _codeFocusNode = FocusNode();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  bool _isLoading = false;

  String? _errorMessage;

  static const Color _limeColor =
  Color(0xFF9DFF21);

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  Future<void> _validateCode() async {
    FocusScope.of(context).unfocus();

    final code =
    _codeController.text.trim().toUpperCase();

    if (code.isEmpty) {
      setState(() {
        _errorMessage =
        'Ingresa el código de acceso.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final snapshot = await _firestore
          .collection('accessCodes')
          .where(
        'code',
        isEqualTo: code,
      )
          .limit(1)
          .get();

      if (!mounted) return;

      if (snapshot.docs.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage =
          'El código no es válido o ya no se encuentra activo.';
        });
        return;
      }

      final document = snapshot.docs.first;
      final data = document.data();

      final active = data['active'] == true;

      if (!active) {
        setState(() {
          _isLoading = false;
          _errorMessage =
          'El código no se encuentra activo.';
        });
        return;
      }

      final expiresAt = data['expiresAt'];

      if (expiresAt is Timestamp &&
          expiresAt.toDate().isBefore(DateTime.now())) {
        setState(() {
          _isLoading = false;
          _errorMessage =
          'El código de acceso ha expirado.';
        });
        return;
      }

      final type =
      (data['type'] ?? 'field')
          .toString()
          .trim();

      if (type != 'field' &&
          type != 'leagueAdmin') {
        setState(() {
          _isLoading = false;
          _errorMessage =
          'El código de acceso no tiene un tipo válido.';
        });
        return;
      }

      final access = RegistrationAccess(
        code: code,
        type: type,
        fieldId: data['fieldId']?.toString(),
        fieldName: data['fieldName']?.toString(),
      );

      if (access.isField &&
          (access.fieldId == null ||
              access.fieldId!.isEmpty)) {
        setState(() {
          _isLoading = false;
          _errorMessage =
          'El código de cancha no tiene un campo asociado.';
        });
        return;
      }

      setState(() {
        _isLoading = false;
      });

      widget.onAccessGranted(access);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
        'No fue posible validar el código. Intenta nuevamente.';
      });
    }
  }

  void _onCodeChanged(String value) {
    if (_errorMessage == null) {
      return;
    }

    setState(() {
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
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
                  alpha: 0.78,
                ),
              ),
            ),

            SingleChildScrollView(
              physics:
              const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                33,
                34,
                33,
                30,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
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
                          color: _limeColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.2,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 42),

                  const Text(
                    'INGRESA TU\nCÓDIGO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      height: 0.98,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 13),

                  const Text(
                    'El código determinará el tipo de acceso que tienes en NOVENTA.',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Container(
                    padding:
                    const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF171718),
                      borderRadius:
                      BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white12,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Código de acceso',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextField(
                          controller:
                          _codeController,
                          focusNode:
                          _codeFocusNode,
                          textCapitalization:
                          TextCapitalization.characters,
                          textInputAction:
                          TextInputAction.done,
                          onChanged:
                          _onCodeChanged,
                          onSubmitted: (_) {
                            if (!_isLoading) {
                              _validateCode();
                            }
                          },
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight:
                            FontWeight.w800,
                            letterSpacing: 2,
                          ),
                          decoration:
                          InputDecoration(
                            hintText:
                            'N90-XXXXXX',
                            hintStyle:
                            const TextStyle(
                              color:
                              Colors.white24,
                              fontSize: 18,
                              letterSpacing: 2,
                            ),
                            filled: true,
                            fillColor:
                            Colors.black26,
                            contentPadding:
                            const EdgeInsets
                                .symmetric(
                              horizontal: 16,
                              vertical: 17,
                            ),
                            border:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(14),
                              borderSide:
                              const BorderSide(
                                color:
                                Colors.white12,
                              ),
                            ),
                            enabledBorder:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(14),
                              borderSide:
                              const BorderSide(
                                color:
                                Colors.white12,
                              ),
                            ),
                            focusedBorder:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(14),
                              borderSide:
                              const BorderSide(
                                color: _limeColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),

                        if (_errorMessage !=
                            null) ...[
                          const SizedBox(height: 12),
                          _ErrorMessage(
                            message:
                            _errorMessage!,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : _validateCode,
                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        _limeColor,
                        foregroundColor:
                        Colors.black,
                        disabledBackgroundColor:
                        _limeColor.withValues(
                          alpha: 0.35,
                        ),
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
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
                          strokeWidth: 2.5,
                          color: Colors.black,
                        ),
                      )
                          : const Text(
                        'CONTINUAR',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                          FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withValues(alpha: 0.04),
                      borderRadius:
                      BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white
                            .withValues(alpha: 0.08),
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.white38,
                          size: 19,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Los códigos de cancha permiten registrarte en una cancha. Los códigos especiales pueden darte acceso administrativo.',
                            style: TextStyle(
                              color:
                              Colors.white54,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
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
        decoration: BoxDecoration(
          color:
          Colors.black.withValues(alpha: 0.55),
          shape: BoxShape.circle,
          border: Border.all(
            color:
            Colors.white.withValues(alpha: 0.14),
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

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
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