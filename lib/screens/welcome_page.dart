import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({
    super.key,
    required this.onStart,
    required this.onLogin,
  });

  final VoidCallback onStart;
  final VoidCallback onLogin;

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
                  // ======================================================
                  // LOGO
                  // ======================================================

                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo_noventa.png',
                        width: 220,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // ======================================================
                  // BOTONES
                  // ======================================================

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

                        const SizedBox(height: 18),

                        _LoginButton(
                          onPressed: onLogin,
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

// ============================================================================
// BOTÓN COMENZAR
// ============================================================================

class _StartButton extends StatelessWidget {
  const _StartButton({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 65,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF9DFF21),
          borderRadius: BorderRadius.circular(48),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9DFF21).withValues(alpha:0.45),
              blurRadius: 25,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 35,
            right: 10,
          ),
          child: Row(
            children: [
              const Expanded(
                child: Center(
                  child: Text(
                    'COMENZAR',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 4.2,
                    ),
                  ),
                ),
              ),

              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFF8CE91B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// BOTÓN LOGIN
// ============================================================================

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 65,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF171817),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: const Color(0xFF383938),
            width: 1,
          ),
        ),
        child: const Center(
          child: Text(
            'YA TENGO UNA CUENTA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.2,
            ),
          ),
        ),
      ),
    );
  }
}