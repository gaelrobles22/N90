import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/data_service.dart';
import '../widgets/common.dart';

class RefereeScreen extends StatefulWidget {
  final DataService data;

  const RefereeScreen({super.key, required this.data});

  @override
  State<RefereeScreen> createState() => _RefereeState();
}

class _RefereeState extends State<RefereeScreen> {
  int minute = 63;
  String team = 'team-1';
  String player = 'player-1';

  Future<void> event(MatchEventType type) async {
    await widget.data.addMatchEvent(
      type: type,
      teamId: team,
      playerId: player,
      minute: minute,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext c) {
    final m = widget.data.matches.first;
    final ps = widget.data.players.where((p) => p.teamId == team).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Centro de Control',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: lime.withValues(alpha:.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'EN VIVO',
                style: TextStyle(
                  color: lime,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        sectionCard(
          Column(
            children: [
              Text(
                '${m.homeTeamName}  ${m.homeScore}  -  ${m.awayScore}  ${m.awayTeamName}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$minute\' · ${m.venueName}',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
              const Divider(color: Colors.white12, height: 24),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: team,
                      decoration: const InputDecoration(
                        labelText: 'Equipo',
                        labelStyle: TextStyle(color: Colors.white54),
                      ),
                      dropdownColor: card,
                      items:
                      [m.homeTeamId, m.awayTeamId]
                          .map(
                            (x) => DropdownMenuItem(
                          value: x,
                          child: Text(
                            x == m.homeTeamId
                                ? m.homeTeamName
                                : m.awayTeamName,
                          ),
                        ),
                      )
                          .toList(),
                      onChanged: (v) => setState(() => team = v!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue:
                      ps.any((p) => p.id == player) ? player : ps.first.id,
                      decoration: const InputDecoration(
                        labelText: 'Jugador',
                        labelStyle: TextStyle(color: Colors.white54),
                      ),
                      dropdownColor: card,
                      items:
                      ps
                          .map(
                            (p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(
                            '#${p.dorsal} ${p.fullName}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                          .toList(),
                      onChanged: (v) => setState(() => player = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _btn(
                    'GOOOL',
                    Icons.sports_soccer,
                        () => event(MatchEventType.goal),
                  ),
                  _btn(
                    'AMARILLA',
                    Icons.warning_amber,
                        () => event(MatchEventType.yellowCard),
                  ),
                  _btn(
                    'ROJA',
                    Icons.warning,
                        () => event(MatchEventType.redCard),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        title('Eventos'),
        ...widget.data
            .getEvents(m.id)
            .reversed
            .map(
              (e) => sectionCard(
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: lime.withValues(alpha:.1),
                child: const Icon(Icons.sports_soccer, color: lime),
              ),
              title: Text(
                '${e.minute}\' · ${e.playerName}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(
                e.type.name.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 9,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _btn(String t, IconData i, VoidCallback f) => ElevatedButton.icon(
    onPressed: f,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white10,
      foregroundColor: Colors.white,
    ),
    icon: Icon(i, size: 16),
    label: Text(
      t,
      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
    ),
  );
}