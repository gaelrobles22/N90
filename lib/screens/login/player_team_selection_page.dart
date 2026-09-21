import 'package:flutter/material.dart';

import '../../models/team.dart';
import '../../services/player_registration_service.dart';
import '../../services/team_service.dart';

class PlayerTeamSelectionPage
    extends StatefulWidget {
  const PlayerTeamSelectionPage({
    super.key,
    required this.uid,
    required this.fieldId,
    required this.fieldName,
    required this.onTeamAssigned,
  });

  final String uid;
  final String fieldId;
  final String fieldName;

  final Future<void> Function(
      FieldTeam team,
      ) onTeamAssigned;

  @override
  State<PlayerTeamSelectionPage>
  createState() =>
      _PlayerTeamSelectionPageState();
}

class _PlayerTeamSelectionPageState
    extends State<PlayerTeamSelectionPage> {
  final TeamService _teamService =
  TeamService();

  final PlayerRegistrationService
  _registrationService =
  PlayerRegistrationService();

  List<FieldTeam> _teams = [];

  String? _selectedTeamId;

  bool _isLoading = true;
  bool _isSaving = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _loadTeams();
  }

  Future<void> _loadTeams() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final teams =
      await _teamService.getTeamsByField(
        widget.fieldId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _teams = teams;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage =
        'No fue posible cargar los equipos.';
      });

      debugPrint(
        'Error cargando equipos: $e',
      );
    }
  }

  void _selectTeam(FieldTeam team) {
    if (_isSaving) {
      return;
    }

    setState(() {
      _selectedTeamId = team.id;
      _errorMessage = null;
    });
  }

  Future<void> _continue() async {
    if (_selectedTeamId == null) {
      setState(() {
        _errorMessage =
        'Selecciona un equipo para continuar.';
      });

      return;
    }

    final selectedTeam = _teams.firstWhere(
          (team) => team.id == _selectedTeamId,
    );

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await _registrationService
          .createPlayerEnrollment(
        playerId: widget.uid,
        fieldId: widget.fieldId,
        teamId: selectedTeam.id,
      );

      if (!mounted) {
        return;
      }

      await widget.onTeamAssigned(
        selectedTeam,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
        _errorMessage =
        'No fue posible asignar el equipo. '
            'Intenta nuevamente.';
      });

      debugPrint(
        'Error creando inscripción: $e',
      );
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
                  alpha: 0.80,
                ),
              ),
            ),
            SingleChildScrollView(
              physics:
              const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                25,
                34,
                25,
                30,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _BackButton(
                        onPressed: () {
                          if (!_isSaving) {
                            Navigator.pop(
                              context,
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 17),
                      const Text(
                        'ASIGNACIÓN DE EQUIPO',
                        style: TextStyle(
                          color:
                          Color(0xFF9DFF21),
                          fontSize: 12,
                          fontWeight:
                          FontWeight.w800,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  _FieldCard(
                    fieldName: widget.fieldName,
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    '¿EN QUÉ EQUIPO JUEGAS?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 29,
                      fontWeight: FontWeight.w900,
                      height: 1.04,
                      letterSpacing: -0.8,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Selecciona el equipo al que '
                        'perteneces en este campo.',
                    style: TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 15,
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 25),

                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding:
                        EdgeInsets.symmetric(
                          vertical: 50,
                        ),
                        child:
                        CircularProgressIndicator(
                          color:
                          Color(0xFF9DFF21),
                        ),
                      ),
                    )
                  else if (_teams.isEmpty)
                    const _EmptyTeamsCard()
                  else
                    ..._teams.map(
                          (team) => Padding(
                        padding:
                        const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: _TeamCard(
                          team: team,
                          selected:
                          _selectedTeamId ==
                              team.id,
                          onTap: () {
                            _selectTeam(team);
                          },
                        ),
                      ),
                    ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons
                              .error_outline_rounded,
                          color:
                          Colors.redAccent,
                          size: 19,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style:
                            const TextStyle(
                              color:
                              Colors.redAccent,
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                      _isLoading || _isSaving
                          ? null
                          : _continue,
                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(
                          0xFF9DFF21,
                        ),
                        foregroundColor:
                        Colors.black,
                        disabledBackgroundColor:
                        const Color(
                          0xFF506610,
                        ),
                        elevation: 0,
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
                            18,
                          ),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color:
                          Colors.black,
                        ),
                      )
                          : const Text(
                        'CONTINUAR',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                          FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({
    required this.fieldName,
  });

  final String fieldName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF191919),
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF303030),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF1D2A10),
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: Color(0xFF9DFF21),
              size: 21,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'CAMPO',
                  style: TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  fieldName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({
    required this.team,
    required this.selected,
    required this.onTap,
  });

  final FieldTeam team;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(18),
        child: AnimatedContainer(
          duration:
          const Duration(milliseconds: 180),
          width: double.infinity,
          padding:
          const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 17,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF202819)
                : const Color(0xFF191919),
            borderRadius:
            BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? const Color(0xFF9DFF21)
                  : const Color(0xFF303030),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF101010),
                  borderRadius:
                  BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Color(0xFFAAAAAA),
                  size: 25,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  team.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? const Color(
                      0xFF9DFF21,
                    )
                        : const Color(
                      0xFF666666,
                    ),
                    width: 1.5,
                  ),
                  color: selected
                      ? const Color(
                    0xFF9DFF21,
                  )
                      : Colors.transparent,
                ),
                child: selected
                    ? const Icon(
                  Icons.check,
                  color: Colors.black,
                  size: 14,
                )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyTeamsCard
    extends StatelessWidget {
  const _EmptyTeamsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF191919),
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF303030),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.groups_outlined,
            color: Color(0xFF777777),
            size: 35,
          ),
          SizedBox(height: 12),
          Text(
            'No hay equipos disponibles',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Este campo todavía no tiene '
                'equipos disponibles.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF777777),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius:
        BorderRadius.circular(30),
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: const Color(0xFF191919),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF303030),
            ),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 19,
          ),
        ),
      ),
    );
  }
}