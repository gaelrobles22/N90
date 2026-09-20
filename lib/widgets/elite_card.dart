import 'package:flutter/material.dart';
import '../models/app_models.dart';
import 'common.dart';

class EliteCard extends StatelessWidget {
  final Player player;
  final Team team;
  final VoidCallback? onEdit;

  const EliteCard({
    super.key,
    required this.player,
    required this.team,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) => Container(
        height: 480,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xff222222), Colors.black],
          ),
          border: Border.all(color: Colors.white12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: netImage(
                'assets/images/jugador.png',
                fallbackAsset: 'assets/images/jugador.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha:.15),
                      Colors.black.withValues(alpha:.96),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(top: 18, left: 18, child: teamLogo(team.crestUrl)),
            Positioned(
              top: 22,
              right: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'NOVENTA',
                    style: TextStyle(
                      color: lime,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'ELITE',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha:.7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 22,
              left: 22,
              right: 22,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${player.dorsal}',
                          style: const TextStyle(
                            color: lime,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          player.fullName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                          maxLines: 2,
                        ),
                        Text(
                          '${positionLabel(player.position)} · ${team.name}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
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
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        'RATING',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (onEdit != null)
              Positioned(
                bottom: 18,
                right: 18,
                child: IconButton(
                  onPressed: onEdit,
                  style: IconButton.styleFrom(backgroundColor: Colors.black54),
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                ),
              ),
          ],
        ),
      );
}
