import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:share_plus/share_plus.dart';
import '../models/app_models.dart';
import '../services/data_service.dart';
import '../widgets/common.dart';
import '../widgets/elite_card.dart';

class ProfileScreen extends StatefulWidget {
  final DataService data;
  final Player player;
  final VoidCallback logout;

  const ProfileScreen({
    super.key,
    required this.data,
    required this.player,
    required this.logout,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUploading = false;

  Future<void> photo() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85, // Optimiza el tamaño antes de subir
    );

    if (xFile == null) return;

    setState(() => _isUploading = true);

    try {
      final file = File(xFile.path);

      // 1. Crear referencia única en Firebase Storage
      final ref = FirebaseStorage.instance
          .ref()
          .child('players/${widget.player.id}/profile.jpg');

      // 2. Subir el archivo
      final uploadTask = await ref.putFile(file);

      // 3. Obtener la URL pública de descarga
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // 4. Actualizar la propiedad photoUrl en la base de datos
      await widget.data.updatePlayerPhoto(widget.player.id, downloadUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto actualizada correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir imagen: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext c) {
    final t = widget.data.teams.firstWhere(
          (x) => x.id == widget.player.teamId,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Mi Perfil',
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
              ),
            ),
            IconButton(
              onPressed: widget.logout,
              icon: const Icon(Icons.logout, color: Colors.white54),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Stack(
          alignment: Alignment.center,
          children: [
            EliteCard(player: widget.player, team: t, onEdit: photo),
            if (_isUploading)
              Container(
                height: 480,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: lime),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        title('Estadísticas'),
        sectionCard(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _s('${widget.player.stats.matchesPlayed}', 'Partidos'),
              _s('${widget.player.stats.goals}', 'Goles', true),
              _s('${widget.player.stats.assists}', 'Asist.'),
              _s('${widget.player.stats.yellowCards}', 'Amarillas'),
              _s('${widget.player.stats.redCards}', 'Rojas'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Share.share(
                'Mi tarjeta NOVENTA: ${widget.player.fullName} · Rating ${widget.player.overallRating}',
              );
            },
            icon: const Icon(Icons.share, color: lime),
            label: const Text(
              'COMPARTIR TARJETA',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _s(String n, String l, [bool hi = false]) => Column(
    children: [
      Text(
        n,
        style: TextStyle(
          color: hi ? lime : Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 18,
        ),
      ),
      Text(
        l,
        style: const TextStyle(color: Colors.white38, fontSize: 8),
      ),
    ],
  );
}