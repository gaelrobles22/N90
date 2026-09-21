import 'package:flutter/material.dart';

import 'player_registration/access_code_page.dart';

enum ProfileType {
  register,
  guest,
  login,
}

class ProfileSelectionPage extends StatelessWidget {
  const ProfileSelectionPage({
    super.key,
    required this.onProfileSelected,
    required this.onRegistrationAccessGranted,
  });

  final void Function(ProfileType profile) onProfileSelected;

  final void Function(RegistrationAccess access)
  onRegistrationAccessGranted;

  static const Color _limeColor = Color(0xFF9DFF21);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/fondo_bienvenidos.png',
            fit: BoxFit.cover,
          ),

          Container(
            color: Colors.black.withValues(alpha: 0.72),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                18,
                18,
                18,
                30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BackButton(
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'SELECCIÓN DE ACCESO',
                    style: TextStyle(
                      color: _limeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.8,
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    '¿CÓMO QUIERES\nENTRAR?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      height: 0.98,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Regístrate, inicia sesión o consulta NOVENTA como invitado.',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 25),

                  _AccessCard(
                    icon: Icons.person_add_alt_1_outlined,
                    title: 'Registrarme',
                    description:
                    'Tengo un código de acceso para registrarme en NOVENTA.',
                    image: 'assets/images/jugador.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AccessCodePage(
                            onAccessGranted: (access) {
                              Navigator.pop(context);

                              onRegistrationAccessGranted(
                                access,
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  _AccessCard(
                    icon: Icons.visibility_outlined,
                    title: 'Entrar como invitado',
                    description:
                    'Consulta una cancha, resultados, equipos, jugadores y estadísticas.',
                    image: 'assets/images/liga.png',
                    onTap: () {
                      onProfileSelected(
                        ProfileType.guest,
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  _AccessCard(
                    icon: Icons.login_outlined,
                    title: 'Ya tengo una cuenta',
                    description:
                    'Inicia sesión para acceder a las funciones de tu cuenta.',
                    image: 'assets/images/jugador_frente.png',
                    onTap: () {
                      onProfileSelected(
                        ProfileType.login,
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Volver',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
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

class _BackButton extends StatelessWidget {
  const _BackButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.14),
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

class _AccessCard extends StatelessWidget {
  const _AccessCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.image,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final String image;
  final VoidCallback onTap;

  static const Color _limeColor = Color(0xFF9DFF21);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 94,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF171718),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.14),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -4,
              top: 0,
              bottom: 0,
              width: 125,
              child: Image.asset(
                image,
                fit: BoxFit.contain,
                alignment: Alignment.centerRight,
                errorBuilder: (_, __, ___) {
                  return const SizedBox.shrink();
                },
              ),
            ),

            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: const [
                      0.0,
                      0.58,
                      1.0,
                    ],
                    colors: [
                      const Color(0xFF171718),
                      const Color(0xFF171718)
                          .withValues(alpha: 0.92),
                      const Color(0xFF171718)
                          .withValues(alpha: 0.10),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                14,
                120,
                12,
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                      color: Colors.black.withValues(alpha: 0.35),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.05,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 9,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: _limeColor,
                  size: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}