import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../widgets/common.dart';

class MatchesScreen extends StatelessWidget {
  final List<Match> matches;

  const MatchesScreen({super.key, required this.matches});

  @override
  Widget build(BuildContext c) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Partidos',
        style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
      ),
      const Text(
        'Calendario de la liga',
        style: TextStyle(color: Colors.white54, fontSize: 12),
      ),
      const SizedBox(height: 20),
      ...matches.map(
            (m) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color:
              m.status == MatchStatus.live
                  ? lime.withOpacity(.45)
                  : Colors.white10,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'JORNADA ${m.matchday}',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    statusLabel(m.status),
                    style: TextStyle(
                      color:
                      m.status == MatchStatus.live ? lime : Colors.white54,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _t(m.homeTeamName, m.homeTeamCrest),
                  Column(
                    children: [
                      Text(
                        '${m.homeScore}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'VS',
                        style: TextStyle(
                          color: Colors.white.withOpacity(.35),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                  _t(m.awayTeamName, m.awayTeamCrest),
                ],
              ),
              const Divider(color: Colors.white12, height: 28),
              Row(
                children: [
                  const Icon(Icons.calendar_month, size: 14, color: lime),
                  const SizedBox(width: 6),
                  Text(
                    '${m.date} · ${m.time}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.location_on,
                    size: 14,
                    color: Colors.white38,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      m.venueName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _t(String n, String u) => Column(
    children: [
      netImage(u, width: 52, height: 52, fit: BoxFit.contain),
      const SizedBox(height: 5),
      SizedBox(
        width: 90,
        child: Text(
          n,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10),
        ),
      ),
    ],
  );
}