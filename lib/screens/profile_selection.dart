import 'package:flutter/material.dart';

import '../models/field_access_code.dart';
import 'player_registration/access_code_page.dart';

class ProfileSelectionPage extends StatelessWidget {
  const ProfileSelectionPage({
    super.key,
    required this.onProfileSelected,
    this.onPlayerAccessGranted,
  });

  final void Function(ProfileType profile) onProfileSelected;
  final void Function(FieldAccessCode accessCode)? onPlayerAccessGranted;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // ============================================================
            // FONDO
            // ============================================================

            Positioned.fill(
              child: Image.asset(
                'assets/images/fondo_bienvenidos.png',
                fit: BoxFit.cover,
              ),
            ),

            // ============================================================
            // CAPA OSCURA
            // ============================================================

            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha:0.50),
              ),
            ),

            // ============================================================
            // CONTENIDO
            // ============================================================

            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ======================================================
                  // HEADER
                  // ======================================================

                  Row(
                    children: [
                      _BackButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),

                      const SizedBox(width: 17),

                      const Text(
                        'SELECCIÓN DE PERFIL',
                        style: TextStyle(
                          color: Color(0xFF9DFF21),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.2,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 34),

                  // ======================================================
                  // TÍTULO
                  // ======================================================

                  const Text(
                    '¿CÓMO PARTICIPAS EN\nEl JUEGO?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 31,
                      fontWeight: FontWeight.w900,
                      height: 1.04,
                      letterSpacing: -1.0,
                    ),
                  ),

                  const SizedBox(height: 13),

                  // ======================================================
                  // SUBTÍTULO
                  // ======================================================

                  const Text(
                    'Selecciona tu rol para personalizar tu experiencia.',
                    style: TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 31),

                  // ======================================================
                  // JUGADOR
                  // ======================================================

                  _ProfileCard(
                    title: 'Jugador',
                    description:
                    'Crea tu perfil, mira tus estadísticas y forma parte de un equipo.',
                    image: 'assets/images/jugador.png',
                    icon: Icons.person_outline_rounded,

                    imageWidth: 130,
                    imageHeight: 135,
                    imageRight: -5,
                    imageTop: -8,
                    imageBottom: 16,

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AccessCodePage(
                            onAccessGranted: (accessCode) {
                              Navigator.pop(context);

                              if (onPlayerAccessGranted != null) {
                                onPlayerAccessGranted!(accessCode);
                              } else {
                                onProfileSelected(ProfileType.player);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),

                  //SEPARACION ENTRE PROFILES
                  const SizedBox(height: 8),

                  // ======================================================
                  // DELEGADO / DT
                  // ======================================================

                  _ProfileCard(
                    title: 'Delegado / DT',
                    description:
                    'Administra tu equipo, invita jugadores y gestiona alineaciones.',
                    image: 'assets/images/dt.PNG',
                    icon: Icons.groups_outlined,

                    imageWidth: 130,
                    imageHeight: 135,
                    imageRight: -5,
                    imageTop: -8,
                    imageBottom: 16,

                    onTap: () {
                      onProfileSelected(ProfileType.manager);
                    },
                  ),

                  const SizedBox(height: 8),

                  // ======================================================
                  // ÁRBITRO
                  // ======================================================

                  _ProfileCard(
                    title: 'Árbitro',
                    description:
                    'Registra partidos, goles, tarjetas y genera actas desde la app.',
                    image: 'assets/images/arbitro.PNG',
                    icon: Icons.shield_outlined,

                    imageWidth: 120,
                    imageHeight: 120,
                    imageRight: 12,
                    imageTop: 3,
                    imageBottom: 16,

                    onTap: () {
                      onProfileSelected(ProfileType.referee);
                    },
                  ),

                  const SizedBox(height: 8),

                  // ======================================================
                  // ADMINISTRADOR
                  // ======================================================

                  _ProfileCard(
                    title: 'Administrador de Liga /\nCampo',
                    description:
                    'Gestiona torneos, equipos, jornadas, árbitros y todo desde un solo lugar.',
                    image: 'assets/images/liga.png',
                    icon: Icons.workspace_premium_outlined,

                    imageWidth: 120,
                    imageHeight: 100,
                    imageRight: 1,
                    imageTop: 3,
                    imageBottom: 16,

                    onTap: () {
                      onProfileSelected(ProfileType.admin);
                    },
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
// TIPOS DE PERFIL
// ============================================================================

enum ProfileType {
  player,
  manager,
  referee,
  admin,
}

// ============================================================================
// BOTÓN REGRESAR
// ============================================================================

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
        borderRadius: BorderRadius.circular(30),
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

// ============================================================================
// TARJETA DE PERFIL
// ============================================================================

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.title,
    required this.description,
    required this.image,
    required this.icon,
    required this.onTap,
    this.imageWidth = 110,
    this.imageHeight = 125,
    this.imageRight = 3,
    this.imageTop = -4,
    this.imageBottom = 7,
  });

  final String title;
  final String description;
  final String image;
  final IconData icon;
  final VoidCallback onTap;

  // ============================================================
  // CONFIGURACIÓN INDIVIDUAL DE IMAGEN
  // ============================================================

  final double imageWidth;
  final double imageHeight;
  final double imageRight;
  final double imageTop;
  final double imageBottom;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        splashColor: const Color(0xFF9DFF21).withValues(alpha:0.08),
        highlightColor: Colors.white.withValues(alpha:0.02),
        child: Container(
          height: 125,
          width: double.infinity,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: const Color(0xFF171718),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFF303030),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // ==========================================================
              // IMAGEN
              // ==========================================================

              Positioned(
                right: imageRight,
                bottom: imageBottom,
                top: imageTop,
                child: SizedBox(
                  width: imageWidth,
                  height: imageHeight,
                  child: Image.asset(
                    image,
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomRight,
                  ),
                ),
              ),

              // ==========================================================
              // SOMBRA MUY SUTIL
              // ==========================================================

              Positioned(
                right: 98,
                top: 0,
                bottom: 0,
                width: 45,
                child: IgnorePointer(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0x00171718),
                          Color(0xB8171718),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ==========================================================
              // CONTENIDO
              // ==========================================================

              Positioned(
                left: 22,
                top: 0,
                bottom: 0,
                right: 108,
                child: Row(
                  children: [
                    // ======================================================
                    // ICONO
                    // ======================================================

                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF161617),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF303030),
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // ======================================================
                    // TEXTO
                    // ======================================================

                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              height: 1.12,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            description,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF999999),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 1.20,
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
      ),
    );
  }
}