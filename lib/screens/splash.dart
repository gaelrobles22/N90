import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../widgets/common.dart';

class SplashScreen extends StatelessWidget {
  final ValueChanged<UserRole> onStart;

  const SplashScreen({super.key, required this.onStart});

  @override
  Widget build(BuildContext c) {
    return Container(
      color: bg,
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('assets/logo-noventa.png.png', width: 180),
          const SizedBox(height: 24),
          const Text(
            'Bienvenido a NOVENTA',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Selecciona cómo quieres entrar a la plataforma.',
            style: TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 30),
          ...[
            (
            UserRole.player,
            'Jugador',
            Icons.person,
            'Consulta tu perfil, equipo, partidos y ranking.',
            ),
            (
            UserRole.managerTeam,
            'Entrenador',
            Icons.groups,
            'Gestiona plantilla y alineación táctica.',
            ),
            (
            UserRole.referee,
            'Árbitro',
            Icons.sports,
            'Controla partidos y eventos en vivo.',
            ),
            (
            UserRole.adminField,
            'Administrador',
            Icons.admin_panel_settings,
            'Administra sede, equipos y jugadores.',
            ),
          ].map(
                (x) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => onStart(x.$1),
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: lime.withOpacity(.12),
                        child: Icon(x.$3, color: lime),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              x.$2,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              x.$4,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white38,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).toList(),
        ],
      ),
    );
  }
}