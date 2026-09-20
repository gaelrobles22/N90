import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../widgets/common.dart';

class RankingsScreen extends StatelessWidget {
 final List<Player> players;
 final List<Standing> standings;

 const RankingsScreen({
  super.key,
  required this.players,
  required this.standings,
 });

 @override
 Widget build(BuildContext c) {
  final scorers = [...players]
   ..sort((a, b) => b.stats.goals.compareTo(a.stats.goals));
  final assists = [...players]
   ..sort((a, b) => b.stats.assists.compareTo(a.stats.assists));

  return Column(
   crossAxisAlignment: CrossAxisAlignment.start,
   children: [
    const Text(
     'Ranking',
     style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
    ),
    const Text(
     'Rendimiento de la liga',
     style: TextStyle(color: Colors.white54, fontSize: 12),
    ),
    const SizedBox(height: 20),
    title('Tabla general'),
    sectionCard(
     Column(
      children:
      standings
          .asMap()
          .entries
          .map((e) {
       final s = e.value;
       return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
         children: [
          SizedBox(
           width: 24,
           child: Text(
            '${e.key + 1}',
            style: const TextStyle(
             color: lime,
             fontWeight: FontWeight.w900,
            ),
           ),
          ),
          teamLogo(s.crestUrl),
          const SizedBox(width: 10),
          Expanded(
           child: Text(
            s.teamName,
            style: const TextStyle(
             fontWeight: FontWeight.w800,
            ),
           ),
          ),
          Text(
           '${s.points} pts',
           style: const TextStyle(
            fontWeight: FontWeight.w900,
           ),
          ),
         ],
        ),
       );
      })
          .toList(),
     ),
    ),
    const SizedBox(height: 20),
    title('Goleadores'),
    ...scorers.map((p) => _playerRow(p, p.stats.goals, 'Goles')),
    const SizedBox(height: 18),
    title('Asistencias'),
    ...assists.map((p) => _playerRow(p, p.stats.assists, 'Asist.')),
   ],
  );
 }

 Widget _playerRow(Player p, int n, String l) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: sectionCard(
   Row(
    children: [
     const CircleAvatar(
      radius: 22,
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
         p.teamName,
         style: const TextStyle(
          color: Colors.white54,
          fontSize: 10,
         ),
        ),
       ],
      ),
     ),
     Text(
      '$n',
      style: const TextStyle(
       color: lime,
       fontSize: 22,
       fontWeight: FontWeight.w900,
      ),
     ),
     const SizedBox(width: 5),
     Text(
      l,
      style: const TextStyle(color: Colors.white38, fontSize: 9),
     ),
    ],
   ),
  ),
 );
}