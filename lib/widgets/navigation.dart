import 'package:flutter/material.dart';
import '../models/app_models.dart';
import 'common.dart';

class AppNavigation extends StatelessWidget {
  final UserRole role;
  final String tab;
  final ValueChanged<String> onTab;

  const AppNavigation({
    super.key,
    required this.role,
    required this.tab,
    required this.onTab,
  });

  List<(String, String, IconData)> get items => switch (role) {
        UserRole.player => [
            ('home', 'Inicio', Icons.home),
            ('matches', 'Partidos', Icons.calendar_month),
            ('team', 'Equipo', Icons.shield),
            ('rankings', 'Ranking', Icons.emoji_events),
            ('profile', 'Perfil', Icons.person),
          ],
        UserRole.referee => [
            ('ref_control', 'En Vivo', Icons.bolt),
            ('ref_matches', 'Partidos', Icons.calendar_month),
            ('profile', 'Perfil', Icons.person),
          ],
        UserRole.managerTeam => [
            ('manager_home', 'Resumen', Icons.dashboard),
            ('manager_tactical', 'Plantilla', Icons.shield),
            ('manager_schedule', 'Calendario', Icons.calendar_month),
            ('profile', 'Perfil', Icons.person),
          ],
        UserRole.adminField => [
            ('admin_overview', 'Sede', Icons.dashboard),
            ('admin_teams', 'Equipos', Icons.groups),
            ('admin_referees', 'Árbitros', Icons.workspace_premium),
            ('profile', 'Perfil', Icons.person),
          ],
      };

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xff141416).withOpacity(.97),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.map((i) {
            final active = i.$1 == tab;
            return InkWell(
              onTap: () => onTab(i.$1),
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(i.$3, color: active ? lime : Colors.white54, size: 20),
                    Text(
                      i.$2,
                      style: TextStyle(
                        color: active ? Colors.white : Colors.white54,
                        fontSize: 9,
                        fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
}
