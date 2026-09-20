import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/data_service.dart';
import '../widgets/common.dart';

class TeamScreen extends StatelessWidget {
  final DataService data;

  const TeamScreen({super.key, required this.data});

  @override
  Widget build(BuildContext c) {
    final t = data.teams.first;
    final ps = data.players.where((p) => p.teamId == t.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            teamLogo(t.crestUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    'Plantilla · Titanes FC',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        title('Plantilla'),
        ...ps.map(
              (p) => sectionCard(
            Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage('assets/images/jugador.png'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.fullName,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        '${positionLabel(p.position)} · #${p.dorsal}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  p.overallRating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: lime,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const _Tactical(dataKey: 'match-1_team-1'),
      ],
    );
  }
}

class _Tactical extends StatefulWidget {
  final String dataKey;

  const _Tactical({required this.dataKey});

  @override
  State<_Tactical> createState() => _TacticalState();
}

class _TacticalState extends State<_Tactical> {
  String formation = '4-3-3';

  @override
  Widget build(BuildContext c) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      title('Vista táctica'),
      DropdownButtonFormField<String>(
        initialValue: formation,
        dropdownColor: card,
        decoration: const InputDecoration(
          labelText: 'Formación',
          labelStyle: TextStyle(color: Colors.white54),
          border: OutlineInputBorder(),
        ),
        items:
        ['4-3-3', '4-4-2', '3-5-2', '4-2-3-1']
            .map((x) => DropdownMenuItem(value: x, child: Text(x)))
            .toList(),
        onChanged: (v) => setState(() => formation = v!),
      ),
      const SizedBox(height: 12),
      Container(
        height: 420,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: lime.withValues(alpha:.25)),
          gradient: const LinearGradient(
            colors: [Color(0xff174d26), Color(0xff0b2d18)],
          ),
        ),
        child: Stack(
          children: [
            ...List.generate(
              11,
                  (i) => Positioned(
                left: (i % 4) * 22.0 + 8,
                top: (i < 4 ? 310 : i < 7 ? 210 : i < 10 ? 110 : 35),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: lime,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed:
              () => ScaffoldMessenger.of(c).showSnackBar(
            const SnackBar(content: Text('Alineación guardada')),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: lime,
            foregroundColor: Colors.black,
          ),
          icon: const Icon(Icons.save),
          label: const Text(
            'GUARDAR ALINEACIÓN',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ),
    ],
  );
}