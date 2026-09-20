import 'package:flutter/material.dart';
import '../widgets/common.dart';

class NotificationsSheet extends StatelessWidget {
  const NotificationsSheet({super.key});

  @override
  Widget build(BuildContext c) {
    final ns = [
      (
      'Convocatoria Confirmada',
      'Estás convocado como titular (Delantero #10) para el partido contra Real Baja en Campo Reforma.',
      'Hace 10 min',
      Icons.calendar_month,
      ),
      (
      '¡Líderes de la Liga!',
      'Titanes FC se consolida en el 1er lugar de la tabla general con 35 puntos.',
      'Hace 2 horas',
      Icons.emoji_events,
      ),
      (
      'Actualización de Rating',
      'Tu desempeño subió a 8.7 tras tu última actuación estelar de 2 goles.',
      'Ayer',
      Icons.check_circle,
      ),
      (
      'Pago de Cuota Semanal',
      'El registro de aportación para arbitraje y cancha ha sido validado con éxito.',
      'Hace 3 días',
      Icons.check_circle,
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xff121214),
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications, color: lime),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notificaciones',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Centro de alertas y avisos oficiales',
                      style: TextStyle(fontSize: 11, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(c),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(color: Colors.white12),
          ...ns.map(
                (n) => Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(n.$4, color: lime, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n.$1,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          n.$2,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                        Text(
                          n.$3,
                          style: const TextStyle(
                            color: Colors.white30,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(c),
              style: ElevatedButton.styleFrom(
                backgroundColor: lime,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.all(15),
              ),
              child: const Text(
                'MARCAR TODAS COMO LEÍDAS',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}