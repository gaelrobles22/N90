import 'package:flutter/material.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({
    super.key,
    required this.roles,
    required this.onRoleSelected,
  });

  final List<String> roles;
  final ValueChanged<String> onRoleSelected;

  String _roleLabel(String role) {
    switch (role) {
      case 'player':
        return 'Jugador';

      case 'managerTeam':
        return 'Director técnico';

      case 'referee':
        return 'Árbitro';

      case 'adminField':
        return 'Administrador';

      default:
        return role;
    }
  }

  IconData _roleIcon(String role) {
    switch (role) {
      case 'player':
        return Icons.sports_soccer_rounded;

      case 'managerTeam':
        return Icons.groups_rounded;

      case 'referee':
        return Icons.sports_rounded;

      case 'adminField':
        return Icons.admin_panel_settings_rounded;

      default:
        return Icons.person_rounded;
    }
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
                  alpha: 0.82,
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                25,
                40,
                25,
                30,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NOVENTA',
                    style: TextStyle(
                      color: Color(0xFF9DFF21),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'ELIGE CÓMO\nQUIERES ENTRAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      height: 1.0,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tu cuenta tiene más de un rol '
                        'disponible en NOVENTA.',
                    style: TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ...roles.map(
                        (role) => Padding(
                      padding:
                      const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: _RoleCard(
                        title: _roleLabel(role),
                        icon: _roleIcon(role),
                        onTap: () {
                          onRoleSelected(role);
                        },
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
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF191919),
            borderRadius:
            BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF303030),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF202A16),
                  borderRadius:
                  BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color:
                  const Color(0xFF9DFF21),
                  size: 25,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}