import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/data_service.dart';
import '../widgets/common.dart';

class PlayerHome extends StatelessWidget {
 final DataService data;
 final Player player;
 final VoidCallback notifications;
 final ValueChanged<String> navigate;

 const PlayerHome({
  super.key,
  required this.data,
  required this.player,
  required this.notifications,
  required this.navigate,
 });

 @override
 Widget build(BuildContext c) {
  final team = data.teams.firstWhere((t) => t.id == player.teamId);
  final m = data.matches.first;

  return Column(
   crossAxisAlignment: CrossAxisAlignment.start,
   children: [
    Row(
     children: [
      Expanded(
       child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         const Text(
          'Hola, Juan 👋',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
         ),
         Text(
          'Tu temporada en NOVENTA',
          style: TextStyle(
           color: Colors.white.withOpacity(.5),
           fontSize: 12,
          ),
         ),
        ],
       ),
      ),
      IconButton(
       onPressed: notifications,
       icon: const Icon(Icons.notifications_none),
      ),
     ],
    ),
    const SizedBox(height: 20),
    sectionCard(
     Row(
      children: [
       const CircleAvatar(
        radius: 28,
        backgroundImage: AssetImage('assets/images/jugador.png'),
       ),
       const SizedBox(width: 14),
       Expanded(
        child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
          Text(
           player.fullName,
           style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
           ),
          ),
          Text(
           '${positionLabel(player.position)} · #${player.dorsal}',
           style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
           ),
          ),
         ],
        ),
       ),
       Column(
        children: [
         Text(
          player.overallRating.toStringAsFixed(1),
          style: const TextStyle(
           color: lime,
           fontSize: 25,
           fontWeight: FontWeight.w900,
          ),
         ),
         const Text(
          'RATING',
          style: TextStyle(fontSize: 8, color: Colors.white38),
         ),
        ],
       ),
      ],
     ),
    ),
    const SizedBox(height: 22),
    title(
     'Próximo partido',
     action: 'Ver más',
     onAction: () => navigate('matches'),
    ),
    sectionCard(
     Column(
      children: [
       Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
         _team(team, m.homeTeamName, m.homeTeamCrest),
         const Text(
          'VS',
          style: TextStyle(color: lime, fontWeight: FontWeight.w900),
         ),
         _team(
          data.teams.firstWhere((t) => t.id == m.awayTeamId),
          m.awayTeamName,
          m.awayTeamCrest,
         ),
        ],
       ),
       const Divider(color: Colors.white12, height: 28),
       Row(
        children: [
         const Icon(Icons.calendar_month, size: 15, color: lime),
         const SizedBox(width: 7),
         Text(
          '${m.date} · ${m.time}',
          style: const TextStyle(fontWeight: FontWeight.bold),
         ),
         const Spacer(),
         const Icon(Icons.location_on, size: 15, color: Colors.white54),
         const SizedBox(width: 4),
         Expanded(
          child: Text(
           m.venueName,
           overflow: TextOverflow.ellipsis,
           style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
           ),
          ),
         ),
        ],
       ),
      ],
     ),
    ),
    const SizedBox(height: 22),
    title(
     'Mi temporada',
     action: 'Ver más',
     onAction: () => navigate('profile'),
    ),
    sectionCard(
     Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
       _stat('${player.stats.matchesPlayed}', 'Partidos'),
       _stat('${player.stats.goals}', 'Goles', true),
       _stat('${player.stats.assists}', 'Asist.'),
       _stat(player.overallRating.toStringAsFixed(1), 'Rating', true),
      ],
     ),
    ),
    const SizedBox(height: 22),
    title(
     'Mi equipo',
     action: 'Ver plantilla',
     onAction: () => navigate('team'),
    ),
    sectionCard(
     Row(
      children: [
       teamLogo(team.crestUrl),
       const SizedBox(width: 14),
       Expanded(
        child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
          Text(
           team.name,
           style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
           ),
          ),
          Text(
           '${positionLabel(player.position)} · #${player.dorsal}',
           style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
           ),
          ),
         ],
        ),
       ),
       const Icon(Icons.chevron_right, color: Colors.white54),
      ],
     ),
    ),
    const SizedBox(height: 22),
    title('Últimos partidos'),
    ...data.matches.map(
         (x) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: sectionCard(
       Row(
        children: [
         teamLogo(x.homeTeamCrest),
         const SizedBox(width: 10),
         Expanded(
          child: Text(
           '${x.homeTeamName}\n${x.awayTeamName}',
           style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
           ),
          ),
         ),
         Text(
          '${x.homeScore} - ${x.awayScore}',
          style: const TextStyle(
           fontSize: 18,
           fontWeight: FontWeight.w900,
          ),
         ),
        ],
       ),
      ),
     ),
    ),
   ],
  );
 }

 Widget _stat(String v, String l, [bool hi = false]) => Column(
  children: [
   Text(
    v,
    style: TextStyle(
     color: hi ? lime : Colors.white,
     fontSize: 22,
     fontWeight: FontWeight.w900,
    ),
   ),
   Text(
    l.toUpperCase(),
    style: const TextStyle(
     color: Colors.white38,
     fontSize: 8,
     fontWeight: FontWeight.bold,
    ),
   ),
  ],
 );

 Widget _team(Team t, String name, String crest) => Column(
  children: [
   teamLogo(crest),
   const SizedBox(height: 6),
   Text(
    name,
    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
   ),
  ],
 );
}