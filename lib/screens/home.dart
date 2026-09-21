import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../services/home_services.dart';
import '../widgets/common.dart';

class PlayerHome extends StatefulWidget {
 final Player player;
 final String fieldId;
 final VoidCallback notifications;
 final ValueChanged<String> navigate;

 const PlayerHome({
  super.key,
  required this.player,
  required this.fieldId,
  required this.notifications,
  required this.navigate,
 });

 @override
 State<PlayerHome> createState() => _PlayerHomeState();
}

class _PlayerHomeState extends State<PlayerHome> {
 static const _card = Color(0xFF141414);
 static const _cardBorder = Color(0x14FFFFFF);

 final HomeService _homeService = HomeService();

 Team? _team;
 List<Match> _matches = [];

 bool _isLoading = true;
 String? _error;

 Player get player => widget.player;

 @override
 void initState() {
  super.initState();
  _loadHomeData();
 }

 Future<void> _loadHomeData() async {
  if (!mounted) {
   return;
  }

  setState(() {
   _isLoading = true;
   _error = null;
  });

  try {
   debugPrint('========================================');
   debugPrint('NOVENTA - HOME FIREBASE');
   debugPrint('TEAM ID: ${player.teamId}');
   debugPrint('FIELD ID: ${widget.fieldId}');
   debugPrint('========================================');

   final results = await Future.wait([
    _homeService.getTeam(player.teamId),
    _homeService.getMatchesByField(widget.fieldId),
   ]);

   final team = results[0] as Team?;
   final matches = results[1] as List<Match>;

   if (!mounted) {
    return;
   }

   setState(() {
    _team = team;
    _matches = matches;
    _isLoading = false;
   });

   debugPrint(
    'NOVENTA - EQUIPO: ${team?.name ?? 'NO ENCONTRADO'}',
   );

   debugPrint(
    'NOVENTA - PARTIDOS ENCONTRADOS: ${matches.length}',
   );
  } catch (e) {
   debugPrint(
    'NOVENTA - ERROR CARGANDO HOME: $e',
   );

   if (!mounted) {
    return;
   }

   setState(() {
    _isLoading = false;
    _error =
    'No fue posible cargar la información del Home.';
   });
  }
 }

 @override
 Widget build(BuildContext context) {
  if (_isLoading) {
   return const Center(
    child: CircularProgressIndicator(
     color: lime,
    ),
   );
  }

  if (_error != null) {
   return Center(
    child: Padding(
     padding: const EdgeInsets.all(24),
     child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
       const Icon(
        Icons.cloud_off_outlined,
        color: Colors.white54,
        size: 42,
       ),
       const SizedBox(height: 14),
       Text(
        _error!,
        textAlign: TextAlign.center,
        style: const TextStyle(
         color: Colors.white70,
        ),
       ),
       const SizedBox(height: 18),
       ElevatedButton(
        onPressed: _loadHomeData,
        style: ElevatedButton.styleFrom(
         backgroundColor: lime,
         foregroundColor: Colors.black,
         elevation: 0,
        ),
        child: const Text(
         'REINTENTAR',
         style: TextStyle(
          fontWeight: FontWeight.w900,
         ),
        ),
       ),
      ],
     ),
    ),
   );
  }

  final team = _team ??
      Team(
       id: player.teamId,
       leagueId: '',
       fieldId: widget.fieldId,
       name: player.teamName,
       crestUrl: '',
       colors: [],
       managerId: '',
      );

  final nextMatch =
  _getNextMatch(_matches);

  return RefreshIndicator(
   color: lime,
   backgroundColor: _card,
   onRefresh: _loadHomeData,
   child: SingleChildScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    child: Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
      _header(),

      const SizedBox(height: 20),

      if (nextMatch != null) ...[
       _nextMatchHero(
        nextMatch,
        team,
       ),
       const SizedBox(height: 26),
      ] else ...[
       _emptyNextMatch(),
       const SizedBox(height: 26),
      ],

      title(
       'Mi temporada',
       action: 'Ver más',
       onAction: () => widget.navigate('profile'),
      ),

      _seasonCard(),

      const SizedBox(height: 26),

      title(
       'Mi equipo',
       action: 'Ver plantilla',
       onAction: () => widget.navigate('team'),
      ),

      _teamCard(team),

      const SizedBox(height: 26),

      title(
       'Últimos partidos',
       action: 'Ver todos',
       onAction: () => widget.navigate('matches'),
      ),

      if (_matches.isEmpty)
       const Padding(
        padding: EdgeInsets.only(
         top: 12,
        ),
        child: Text(
         'No hay partidos disponibles todavía.',
         style: TextStyle(
          color: Colors.white54,
         ),
        ),
       )
      else
       ..._matches.map(
            (match) => Padding(
         padding: const EdgeInsets.only(
          top: 8,
         ),
         child: _lastMatchCard(match),
        ),
       ),

      const SizedBox(height: 26),

      _leagueHeader(),
     ],
    ),
   ),
  );
 }

 // ============================================================
 // PARTIDO PRINCIPAL
 // ============================================================

 Match? _getNextMatch(List<Match> matches) {
  if (matches.isEmpty) {
   return null;
  }

  final scheduled = matches
      .where(
       (match) =>
   match.status == MatchStatus.scheduled,
  )
      .toList();

  if (scheduled.isNotEmpty) {
   scheduled.sort(
        (a, b) => a.date.compareTo(b.date),
   );

   return scheduled.first;
  }

  return matches.first;
 }

 // ============================================================
 // HEADER
 // ============================================================

 String get _initials {
  final parts =
  player.fullName.trim().split(RegExp(r'\s+'));

  if (parts.isEmpty ||
      parts.first.isEmpty) {
   return '?';
  }

  final a = parts.first[0];
  final b =
  parts.length > 1 ? parts[1][0] : '';

  return (a + b).toUpperCase();
 }

 String get _firstName {
  final parts =
  player.fullName.trim().split(RegExp(r'\s+'));

  if (parts.isEmpty ||
      parts.first.isEmpty) {
   return '';
  }

  final n = parts.first;

  return n[0].toUpperCase() +
      n.substring(1).toLowerCase();
 }

 Widget _header() {
  return Row(
   children: [
    Stack(
     clipBehavior: Clip.none,
     children: [
      Container(
       width: 52,
       height: 52,
       decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1A1A1A),
        border: Border.all(
         color: lime,
         width: 2,
        ),
       ),
       alignment: Alignment.center,
       child: Text(
        _initials,
        style: const TextStyle(
         fontWeight: FontWeight.w900,
         fontSize: 16,
        ),
       ),
      ),
      Positioned(
       right: 0,
       bottom: 0,
       child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
         color: lime,
         shape: BoxShape.circle,
         border: Border.all(
          color: Colors.black,
          width: 2,
         ),
        ),
       ),
      ),
     ],
    ),

    const SizedBox(width: 14),

    Expanded(
     child: Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
       const Text(
        'PRO PLAYER',
        style: TextStyle(
         color: lime,
         fontSize: 10,
         fontWeight: FontWeight.w800,
         letterSpacing: 1.2,
        ),
       ),
       const SizedBox(height: 2),
       Text(
        _firstName,
        style: const TextStyle(
         fontSize: 24,
         fontWeight: FontWeight.w900,
        ),
       ),
      ],
     ),
    ),

    Container(
     decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: _card,
      border: Border.all(
       color: _cardBorder,
      ),
     ),
     child: IconButton(
      onPressed: widget.notifications,
      icon: const Icon(
       Icons.notifications_none,
       size: 22,
      ),
     ),
    ),
   ],
  );
 }

 // ============================================================
 // PRÓXIMO PARTIDO
 // ============================================================

 Widget _nextMatchHero(
     Match match,
     Team team,
     ) {
  final isHome =
      match.homeTeamId == player.teamId;

  final homeTeam = isHome
      ? team
      : Team(
   id: match.homeTeamId,
   leagueId: match.leagueId,
   fieldId: match.fieldId,
   name: match.homeTeamName,
   crestUrl: match.homeTeamCrest,
   colors: [],
   managerId: '',
  );

  final awayTeam = !isHome
      ? team
      : Team(
   id: match.awayTeamId,
   leagueId: match.leagueId,
   fieldId: match.fieldId,
   name: match.awayTeamName,
   crestUrl: match.awayTeamCrest,
   colors: [],
   managerId: '',
  );

  return Container(
   decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(26),
    border: Border.all(
     color: _cardBorder,
    ),
    gradient: const LinearGradient(
     begin: Alignment.topCenter,
     end: Alignment.bottomCenter,
     colors: [
      Color(0xFF1C2418),
      Color(0xFF0C0C0C),
     ],
    ),
   ),
   padding: const EdgeInsets.all(20),
   child: Column(
    crossAxisAlignment:
    CrossAxisAlignment.start,
    children: [
     Row(
      children: [
       Container(
        width: 6,
        height: 6,
        decoration:
        const BoxDecoration(
         color: lime,
         shape: BoxShape.circle,
        ),
       ),
       const SizedBox(width: 8),
       const Text(
        'PRÓXIMO PARTIDO',
        style: TextStyle(
         color: lime,
         fontSize: 10,
         fontWeight: FontWeight.w800,
         letterSpacing: 1.4,
        ),
       ),
       const Spacer(),
       Text(
        'JORNADA ${match.matchday}',
        style: const TextStyle(
         fontSize: 11,
         fontWeight: FontWeight.w800,
         letterSpacing: 0.8,
        ),
       ),
      ],
     ),

     const SizedBox(height: 22),

     Row(
      children: [
       Expanded(
        child: _heroTeam(
         homeTeam,
         match.homeTeamName,
         match.homeTeamCrest,
         'LOCAL',
        ),
       ),

       const Text(
        'VS',
        style: TextStyle(
         color: lime,
         fontSize: 40,
         fontWeight: FontWeight.w900,
         fontStyle: FontStyle.italic,
         height: 1,
        ),
       ),

       Expanded(
        child: _heroTeam(
         awayTeam,
         match.awayTeamName,
         match.awayTeamCrest,
         'VISITANTE',
        ),
       ),
      ],
     ),

     const SizedBox(height: 22),

     Row(
      children: [
       Expanded(
        child: Column(
         crossAxisAlignment:
         CrossAxisAlignment.start,
         children: [
          Row(
           children: [
            const Icon(
             Icons.calendar_month,
             size: 15,
             color: lime,
            ),
            const SizedBox(width: 7),
            Flexible(
             child: Text(
              '${match.date} · ${match.time}',
              overflow:
              TextOverflow.ellipsis,
              style:
              const TextStyle(
               fontWeight:
               FontWeight.w800,
               fontSize: 13,
              ),
             ),
            ),
           ],
          ),

          const SizedBox(height: 8),

          Row(
           children: [
            const Icon(
             Icons.location_on_outlined,
             size: 15,
             color: Colors.white54,
            ),
            const SizedBox(width: 7),
            Expanded(
             child: Text(
              match.venueName,
              overflow:
              TextOverflow.ellipsis,
              style:
              const TextStyle(
               color: Colors.white60,
               fontSize: 11,
              ),
             ),
            ),
           ],
          ),
         ],
        ),
       ),

       const SizedBox(width: 12),

       ElevatedButton(
        onPressed: () =>
            widget.navigate('matches'),
        style: ElevatedButton.styleFrom(
         backgroundColor: lime,
         foregroundColor: Colors.black,
         elevation: 0,
         padding:
         const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
         ),
         shape:
         RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(14),
         ),
        ),
        child: const Row(
         mainAxisSize:
         MainAxisSize.min,
         children: [
          Text(
           'VER MÁS',
           style: TextStyle(
            fontWeight:
            FontWeight.w900,
            fontSize: 12,
            letterSpacing: 0.5,
           ),
          ),
          SizedBox(width: 6),
          Icon(
           Icons.chevron_right,
           size: 18,
          ),
         ],
        ),
       ),
      ],
     ),
    ],
   ),
  );
 }

 Widget _heroTeam(
     Team team,
     String name,
     String crest,
     String role,
     ) {
  final logo =
  crest.isNotEmpty ? crest : team.crestUrl;

  return Column(
   children: [
    SizedBox(
     width: 64,
     height: 64,
     child: teamLogo(logo),
    ),

    const SizedBox(height: 10),

    Text(
     name,
     textAlign: TextAlign.center,
     maxLines: 2,
     overflow: TextOverflow.ellipsis,
     style: const TextStyle(
      fontWeight: FontWeight.w900,
      fontSize: 13,
     ),
    ),

    const SizedBox(height: 4),

    Text(
     role,
     style: const TextStyle(
      color: lime,
      fontSize: 9,
      fontWeight: FontWeight.w800,
      letterSpacing: 1,
     ),
    ),
   ],
  );
 }

 // ============================================================
 // SIN PRÓXIMO PARTIDO
 // ============================================================

 Widget _emptyNextMatch() {
  return Container(
   width: double.infinity,
   padding: const EdgeInsets.all(24),
   decoration: BoxDecoration(
    color: _card,
    borderRadius:
    BorderRadius.circular(26),
    border: Border.all(
     color: _cardBorder,
    ),
   ),
   child: const Column(
    children: [
     Icon(
      Icons.sports_soccer,
      size: 40,
      color: Colors.white38,
     ),
     SizedBox(height: 12),
     Text(
      'NO HAY PRÓXIMO PARTIDO',
      style: TextStyle(
       color: Colors.white70,
       fontSize: 12,
       fontWeight: FontWeight.w900,
       letterSpacing: 1,
      ),
     ),
     SizedBox(height: 6),
     Text(
      'Cuando se programe un partido aparecerá aquí.',
      textAlign: TextAlign.center,
      style: TextStyle(
       color: Colors.white38,
       fontSize: 11,
      ),
     ),
    ],
   ),
  );
 }

 // ============================================================
 // MI TEMPORADA
 // ============================================================

 Widget _seasonCard() {
  return Container(
   padding: const EdgeInsets.symmetric(
    vertical: 22,
    horizontal: 12,
   ),
   decoration: BoxDecoration(
    color: _card,
    borderRadius:
    BorderRadius.circular(24),
    border: Border.all(
     color: _cardBorder,
    ),
   ),
   child: Row(
    mainAxisAlignment:
    MainAxisAlignment.spaceAround,
    children: [
     _stat(
      '${player.stats.matchesPlayed}',
      'Partidos',
     ),
     _stat(
      '${player.stats.goals}',
      'Goles',
      true,
     ),
     _stat(
      '${player.stats.assists}',
      'Asist.',
     ),
     _stat(
      player.overallRating
          .toStringAsFixed(1),
      'Rating',
      true,
     ),
    ],
   ),
  );
 }

 Widget _stat(
     String value,
     String label, [
      bool highlight = false,
     ]) {
  return Column(
   children: [
    Text(
     value,
     style: TextStyle(
      color: highlight
          ? lime
          : Colors.white,
      fontSize: 30,
      fontWeight: FontWeight.w900,
      height: 1,
     ),
    ),
    const SizedBox(height: 6),
    Text(
     label.toUpperCase(),
     style: const TextStyle(
      color: Colors.white54,
      fontSize: 9,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.8,
     ),
    ),
   ],
  );
 }

 // ============================================================
 // MI EQUIPO
 // ============================================================

 Widget _teamCard(Team team) {
  return Container(
   height: 130,
   clipBehavior: Clip.antiAlias,
   decoration: BoxDecoration(
    color: _card,
    borderRadius:
    BorderRadius.circular(24),
    border: Border.all(
     color: _cardBorder,
    ),
   ),
   child: Stack(
    children: [
     Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      width: 170,
      child: ShaderMask(
       blendMode: BlendMode.dstIn,
       shaderCallback: (rect) =>
           const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
             Colors.transparent,
             Colors.black,
            ],
            stops: [
             0.0,
             0.5,
            ],
           ).createShader(rect),
       child: Image.asset(
        'assets/images/jugador_frente.png',
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder:
            (_, __, ___) =>
        const SizedBox.shrink(),
       ),
      ),
     ),

     Padding(
      padding:
      const EdgeInsets.all(22),
      child: Align(
       alignment:
       Alignment.centerLeft,
       child: Column(
        mainAxisSize:
        MainAxisSize.min,
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
         Text(
          team.name,
          style:
          const TextStyle(
           fontSize: 19,
           fontWeight:
           FontWeight.w900,
          ),
         ),

         const SizedBox(height: 8),

         Row(
          mainAxisSize:
          MainAxisSize.min,
          children: [
           Text(
            positionLabel(
             player.position,
            ),
            style:
            const TextStyle(
             color:
             Colors.white60,
             fontSize: 13,
            ),
           ),

           const SizedBox(width: 10),

           Container(
            padding:
            const EdgeInsets
                .symmetric(
             horizontal: 10,
             vertical: 4,
            ),
            decoration:
            BoxDecoration(
             color: lime.withValues(
              alpha: .15,
             ),
             borderRadius:
             BorderRadius
                 .circular(8),
             border: Border.all(
              color:
              lime.withValues(
               alpha: .6,
              ),
             ),
            ),
            child: Text(
             '#${player.dorsal}',
             style:
             const TextStyle(
              color: lime,
              fontSize: 11,
              fontWeight:
              FontWeight.w900,
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
   ),
  );
 }

 // ============================================================
 // ÚLTIMOS PARTIDOS
 // ============================================================

 Widget _lastMatchCard(Match match) {
  return Container(
   padding: const EdgeInsets.all(14),
   decoration: BoxDecoration(
    color: _card,
    borderRadius:
    BorderRadius.circular(20),
    border: Border.all(
     color: _cardBorder,
    ),
   ),
   child: Row(
    children: [
     SizedBox(
      width: 36,
      height: 36,
      child: teamLogo(
       match.homeTeamCrest,
      ),
     ),

     const SizedBox(width: 12),

     Expanded(
      child: Text(
       '${match.homeTeamName}\n'
           '${match.awayTeamName}',
       style: const TextStyle(
        fontWeight:
        FontWeight.bold,
        fontSize: 12,
        height: 1.4,
       ),
      ),
     ),

     Text(
      '${match.homeScore} - '
          '${match.awayScore}',
      style: const TextStyle(
       fontSize: 20,
       fontWeight: FontWeight.w900,
      ),
     ),
    ],
   ),
  );
 }

 // ============================================================
 // POSICIÓN EN LA LIGA
 // ============================================================

 Widget _leagueHeader() {
  return Row(
   children: [
    const Icon(
     Icons.emoji_events_outlined,
     size: 18,
     color: lime,
    ),

    const SizedBox(width: 8),

    const Text(
     'POSICIÓN EN LA LIGA',
     style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w900,
      letterSpacing: 0.8,
     ),
    ),

    const Spacer(),

    GestureDetector(
     onTap: () =>
         widget.navigate('ranking'),
     child: const Row(
      children: [
       Text(
        'Ver tabla completa',
        style: TextStyle(
         color: lime,
         fontSize: 12,
         fontWeight:
         FontWeight.w700,
        ),
       ),
       Icon(
        Icons.chevron_right,
        size: 16,
        color: lime,
       ),
      ],
     ),
    ),
   ],
  );
 }
}