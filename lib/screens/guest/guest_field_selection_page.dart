import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GuestFieldSelectionPage extends StatefulWidget {
  const GuestFieldSelectionPage({
    super.key,
    required this.onFieldSelected,
  });

  final void Function(
      String fieldId,
      String fieldName,
      ) onFieldSelected;

  @override
  State<GuestFieldSelectionPage> createState() =>
      _GuestFieldSelectionPageState();
}

class _GuestFieldSelectionPageState
    extends State<GuestFieldSelectionPage> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  bool _isLoading = true;

  String? _errorMessage;

  List<_GuestField> _fields = [];

  static const Color _limeColor =
  Color(0xFF9DFF21);

  @override
  void initState() {
    super.initState();
    _loadFields();
  }

  Future<void> _loadFields() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final snapshot = await _firestore
          .collection('field')
          .get();

      if (!mounted) return;

      final fields = snapshot.docs
          .map(
            (doc) => _GuestField(
          id: doc.id,
          name:
          (doc.data()['name'] ??
              doc.data()['fieldName'] ??
              'Cancha')
              .toString(),
        ),
      )
          .where(
            (field) => field.id.isNotEmpty,
      )
          .toList();

      setState(() {
        _fields = fields;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
        'No fue posible cargar las canchas.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/fondo_bienvenidos.png',
                fit: BoxFit.cover,
              ),
            ),

            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(
                  alpha: 0.82,
                ),
              ),
            ),

            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                  const EdgeInsets.fromLTRB(
                    18,
                    18,
                    18,
                    0,
                  ),
                  child: Row(
                    children: [
                      _BackButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 17),
                      const Text(
                        'MODO INVITADO',
                        style: TextStyle(
                          color: _limeColor,
                          fontSize: 11,
                          fontWeight:
                          FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    30,
                    20,
                    8,
                  ),
                  child: Text(
                    'SELECCIONA UNA\nCANCHA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      height: 0.98,
                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Text(
                    'Consulta resultados, equipos, jugadores y estadísticas sin crear una cuenta.',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: _limeColor,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                color: Colors.white38,
                size: 42,
              ),
              const SizedBox(height: 14),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 18),
              TextButton(
                onPressed: _loadFields,
                child: const Text(
                  'Reintentar',
                  style: TextStyle(
                    color: _limeColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_fields.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Text(
            'No hay canchas disponibles.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        18,
        0,
        18,
        30,
      ),
      itemCount: _fields.length,
      separatorBuilder: (_, __) =>
      const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final field = _fields[index];

        return _FieldCard(
          field: field,
          onTap: () {
            widget.onFieldSelected(
              field.id,
              field.name,
            );
          },
        );
      },
    );
  }
}

class _GuestField {
  const _GuestField({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({
    required this.field,
    required this.onTap,
  });

  final _GuestField field;
  final VoidCallback onTap;

  static const Color _limeColor =
  Color(0xFF9DFF21);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(18),
        child: Container(
          padding:
          const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
            const Color(0xFF171718),
            borderRadius:
            BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white12,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _limeColor
                      .withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _limeColor
                        .withValues(
                      alpha: 0.25,
                    ),
                  ),
                ),
                child: const Icon(
                  Icons.stadium_outlined,
                  color: _limeColor,
                  size: 24,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      field.name,
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Ver resultados y estadísticas',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: Colors.white38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color:
          Colors.black.withValues(
            alpha: 0.55,
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color:
            Colors.white.withValues(
              alpha: 0.14,
            ),
          ),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 17,
        ),
      ),
    );
  }
}