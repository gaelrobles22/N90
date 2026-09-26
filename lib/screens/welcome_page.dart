import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({
    super.key,
    required this.onStart,
  });

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            // ============================================================
            // FONDO
            // ============================================================
            Positioned.fill(
              child: Image.asset(
                'assets/images/fondo_bienvenidos.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),

            // ============================================================
            // DEGRADADO OSCURO
            // ============================================================
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xE6000000),
                      Color(0x50000000),
                      Color(0x55000000),
                      Color(0xEE000000),
                    ],
                    stops: [
                      0.0,
                      0.40,
                      0.65,
                      1.0,
                    ],
                  ),
                ),
              ),
            ),

            // ============================================================
            // CONTENIDO
            // ============================================================
            Positioned.fill(
              child: Column(
                children: [
                  // ------------------------------------------------------
                  // LOGO
                  // ------------------------------------------------------
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo_noventa.png',
                        width: 220,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // ------------------------------------------------------
                  // BOTÓN COMENZAR
                  // ------------------------------------------------------
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      44,
                      0,
                      44,
                      24,
                    ),
                    child: Column(
                      children: [
                        _StartButton(
                          onPressed: onStart,
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

// ==========================================================================
// BOTÓN COMENZAR
// ==========================================================================

class _StartButton extends StatelessWidget {
  const _StartButton({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  static const Color _limeColor = Color(0xFF9DFF21);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _limeColor,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Center(
          child: Text(
            'COMENZAR',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}