import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../widgets/common.dart';

class AdminScreen extends StatefulWidget {
  final DataService data;

  const AdminScreen({super.key, required this.data});

  @override
  State<AdminScreen> createState() => _AdminState();
}

class _AdminState extends State<AdminScreen> {
  Future<void> addTeam() async {
    final ctl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (c) => AlertDialog(
        backgroundColor: card,
        title: const Text('Registrar equipo'),
        content: TextField(
          controller: ctl,
          decoration: const InputDecoration(labelText: 'Nombre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (ok == true && ctl.text.trim().isNotEmpty) {
      await widget.data.addTeam(ctl.text.trim());
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext c) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Administración',
        style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
      ),
      Text(
        widget.data.field.name,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      const SizedBox(height: 20),
      sectionCard(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: lime),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.data.field.location,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.data.field.description,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(child: title('Equipos')),
          ElevatedButton.icon(
            onPressed: addTeam,
            style: ElevatedButton.styleFrom(
              backgroundColor: lime,
              foregroundColor: Colors.black,
            ),
            icon: const Icon(Icons.add, size: 16),
            label: const Text(
              'NUEVO',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10),
            ),
          ),
        ],
      ),
      ...widget.data.teams.map(
            (t) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: sectionCard(
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
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        'Manager: ${t.managerId}',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.edit, color: Colors.white54, size: 18),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),
      title('Jugadores'),
      ...widget.data.players.map(
            (p) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(
            backgroundImage: AssetImage('assets/images/jugador.png'),
          ),
          title: Text(
            p.fullName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${p.teamName} · #${p.dorsal}',
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ),
      ),
    ],
  );
}