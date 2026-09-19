import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';

class DataService {
  static const _prefix = 'golpro_';
  late SharedPreferences _prefs;

  Field field = Field(
    id: 'field-1',
    name: 'Complejo Deportivo Reforma',
    logoUrl:
    'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?w=150',
    photoUrl:
    'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800',
    location: 'Av. Insurgentes Sur 1400, CDMX',
    description:
    'El campo sintético número 1 de la liga amateur más competitiva del país con certificación FIFA Quality.',
    adminId: 'admin-1',
    activeLeaguesCount: 2,
  );

  League league = League(
    id: 'league-1',
    fieldId: 'field-1',
    name: 'Liga Premier Sabatina - Torneo Apertura 2026',
    season: 'Apertura 2026',
    category: 'Primera Fuerza Libre',
    rules:
    'Partidos de 2 tiempos de 35 minutos. Acumulación de 3 tarjetas amarillas genera 1 partido de suspensión. Sustituciones ilimitadas.',
  );

  final List<Team> teams = [];
  final List<Player> players = [];
  final List<Match> matches = [];
  final List<Standing> standings = [];
  final List<MatchEvent> events = [];
  final Map<String, TeamLineup> lineups = {};

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _seed();
  }

  void _seed() {
    teams.addAll([
      Team(
        id: 'team-1',
        leagueId: 'league-1',
        fieldId: 'field-1',
        name: 'Titanes FC',
        crestUrl:
        'https://images.unsplash.com/photo-1614680376593-902f749f7ffc?w=150',
        colors: ['#1E1B4B', '#4338CA'],
        managerId: 'manager-1',
        positionInTable: 1,
      ),
      Team(
        id: 'team-2',
        leagueId: 'league-1',
        fieldId: 'field-1',
        name: 'Real Baja',
        crestUrl:
        'https://images.unsplash.com/photo-1563089145-599997674d42?w=150',
        colors: ['#047857', '#10B981'],
        managerId: 'manager-2',
        positionInTable: 2,
      ),
      Team(
        id: 'team-3',
        leagueId: 'league-1',
        fieldId: 'field-1',
        name: 'Galácticos SC',
        crestUrl:
        'https://images.unsplash.com/photo-1579783902614-a3fb3927b675?w=150',
        colors: ['#B45309', '#F59E0B'],
        managerId: 'manager-3',
        positionInTable: 3,
      ),
      Team(
        id: 'team-4',
        leagueId: 'league-1',
        fieldId: 'field-1',
        name: 'Deportivo Toluca Jr',
        crestUrl:
        'https://images.unsplash.com/photo-1541701494587-cb58502866ab?w=150',
        colors: ['#991B1B', '#EF4444'],
        managerId: 'manager-4',
        positionInTable: 4,
      ),
    ]);

    players.addAll([
      _p('player-1', 'Juan Pérez', Position.del, 10, 8.7, 'team-1', 'Titanes FC', 18, 7, 2, 0),
      _p('player-2', 'Carlos Mendoza', Position.med, 8, 8.2, 'team-1', 'Titanes FC', 5, 12, 1, 0),
      _p('player-3', 'Alejandro Vega', Position.def, 4, 7.9, 'team-1', 'Titanes FC', 2, 1, 4, 1),
      _p('player-4', 'Mateo Silva', Position.por, 1, 8.4, 'team-1', 'Titanes FC', 0, 0, 0, 0),
      _p('player-5', 'Rodrigo Neri', Position.del, 9, 8.5, 'team-2', 'Real Baja', 16, 4, 3, 0),
    ]);

    matches.addAll([
      Match(
        id: 'match-1',
        leagueId: 'league-1',
        fieldId: 'field-1',
        homeTeamId: 'team-1',
        homeTeamName: 'Titanes FC',
        homeTeamCrest: teams[0].crestUrl,
        awayTeamId: 'team-2',
        awayTeamName: 'Real Baja',
        awayTeamCrest: teams[1].crestUrl,
        date: '2026-09-06',
        time: '20:00',
        matchday: 15,
        status: MatchStatus.live,
        homeScore: 2,
        awayScore: 1,
        refereeId: 'ref-1',
        refereeName: 'Lic. Roberto Garcés',
        venueName: 'Campo Reforma - Cancha Principal',
      ),
      Match(
        id: 'match-2',
        leagueId: 'league-1',
        fieldId: 'field-1',
        homeTeamId: 'team-3',
        homeTeamName: 'Galácticos SC',
        homeTeamCrest: teams[2].crestUrl,
        awayTeamId: 'team-4',
        awayTeamName: 'Deportivo Toluca Jr',
        awayTeamCrest: teams[3].crestUrl,
        date: '2026-09-07',
        time: '18:00',
        matchday: 15,
        status: MatchStatus.scheduled,
        homeScore: 0,
        awayScore: 0,
        refereeId: 'ref-1',
        refereeName: 'Lic. Roberto Garcés',
        venueName: 'Campo Reforma - Cancha Principal',
      ),
    ]);

    standings.addAll([
      _s('std-1', 'team-1', 'Titanes FC', 35, 11, 2, 1, 38, 12, 26),
      _s('std-2', 'team-2', 'Real Baja', 33, 10, 3, 1, 35, 14, 21),
      _s('std-3', 'team-3', 'Galácticos SC', 26, 8, 2, 4, 28, 20, 8),
      _s('std-4', 'team-4', 'Deportivo Toluca Jr', 21, 6, 3, 5, 22, 24, -2),
    ]);

    events.addAll([
      MatchEvent(
        id: 'evt-1',
        matchId: 'match-1',
        type: MatchEventType.goal,
        teamId: 'team-1',
        playerId: 'player-1',
        playerName: 'Juan Pérez',
        secondaryPlayerId: 'player-2',
        secondaryPlayerName: 'Carlos Mendoza',
        minute: 24,
        refereeId: 'ref-1',
        timestamp: DateTime.now().millisecondsSinceEpoch - 3600000,
      ),
      MatchEvent(
        id: 'evt-2',
        matchId: 'match-1',
        type: MatchEventType.goal,
        teamId: 'team-2',
        playerId: 'player-5',
        playerName: 'Rodrigo Neri',
        minute: 41,
        refereeId: 'ref-1',
        timestamp: DateTime.now().millisecondsSinceEpoch - 2400000,
      ),
      MatchEvent(
        id: 'evt-3',
        matchId: 'match-1',
        type: MatchEventType.goal,
        teamId: 'team-1',
        playerId: 'player-1',
        playerName: 'Juan Pérez',
        secondaryPlayerId: 'player-3',
        secondaryPlayerName: 'Alejandro Vega',
        minute: 63,
        refereeId: 'ref-1',
        timestamp: DateTime.now().millisecondsSinceEpoch - 900000,
      ),
    ]);

    lineups['match-1_team-1'] = TeamLineup(
      matchId: 'match-1',
      teamId: 'team-1',
      formation: '4-3-3',
      players: [
        LineupPlayer(playerId: 'player-4', name: 'Mateo Silva', dorsal: 1, position: Position.por, isStarter: true, x: 50, y: 90),
        LineupPlayer(playerId: 'player-3', name: 'Alejandro Vega', dorsal: 4, position: Position.def, isStarter: true, x: 20, y: 70),
        LineupPlayer(playerId: 'p-def2', name: 'Héctor Ruiz', dorsal: 3, position: Position.def, isStarter: true, x: 40, y: 70),
        LineupPlayer(playerId: 'p-def3', name: 'Luis Morales', dorsal: 2, position: Position.def, isStarter: true, x: 60, y: 70),
        LineupPlayer(playerId: 'p-def4', name: 'Diego Torres', dorsal: 5, position: Position.def, isStarter: true, x: 80, y: 70),
        LineupPlayer(playerId: 'player-2', name: 'Carlos Mendoza', dorsal: 8, position: Position.med, isStarter: true, x: 30, y: 45),
        LineupPlayer(playerId: 'p-med2', name: 'Andrés Garza', dorsal: 6, position: Position.med, isStarter: true, x: 50, y: 45),
        LineupPlayer(playerId: 'p-med3', name: 'Samuel León', dorsal: 7, position: Position.med, isStarter: true, x: 70, y: 45),
        LineupPlayer(playerId: 'player-1', name: 'Juan Pérez', dorsal: 10, position: Position.del, isStarter: true, x: 25, y: 20),
        LineupPlayer(playerId: 'p-del2', name: 'Bruno Díaz', dorsal: 11, position: Position.del, isStarter: true, x: 50, y: 15),
        LineupPlayer(playerId: 'p-del3', name: 'Kevin Soto', dorsal: 19, position: Position.del, isStarter: true, x: 75, y: 20),
      ],
    );
  }

  Player _p(
      String id,
      String n,
      Position pos,
      int d,
      double r,
      String tid,
      String tn,
      int goals,
      int assists,
      int yellow,
      int red,
      ) => Player(
    id: id,
    fullName: n,
    position: pos,
    dorsal: d,
    photoUrl: '',
    overallRating: r,
    verificationStatus: VerificationStatus.verified,
    teamId: tid,
    teamName: tn,
    stats: PlayerStats(
      matchesPlayed: 14,
      goals: goals,
      assists: assists,
      yellowCards: yellow,
      redCards: red,
      rating: r,
    ),
  );

  Standing _s(
      String id,
      String tid,
      String n,
      int pts,
      int w,
      int dr,
      int l,
      int gf,
      int ga,
      int gd,
      ) => Standing(
    id: id,
    leagueId: 'league-1',
    teamId: tid,
    teamName: n,
    crestUrl: teams.firstWhere((t) => t.id == tid).crestUrl,
    played: 14,
    won: w,
    drawn: dr,
    lost: l,
    goalsFor: gf,
    goalsAgainst: ga,
    goalDifference: gd,
    points: pts,
  );

  Future<void> _save(String key, Object value) =>
      _prefs.setString('$_prefix$key', jsonEncode(value));

  Future<void> saveLineup(TeamLineup l) async {
    lineups['${l.matchId}_${l.teamId}'] = l;
  }

  TeamLineup? getLineup(String matchId, String teamId) =>
      lineups['${matchId}_$teamId'];

  List<MatchEvent> getEvents(String id) =>
      events.where((e) => e.matchId == id).toList();

  Future<void> addMatchEvent({
    required MatchEventType type,
    required String teamId,
    required String playerId,
    required int minute,
    String? secondaryPlayerId,
  }) async {
    final p = players.firstWhere((x) => x.id == playerId);
    events.add(
      MatchEvent(
        id: 'evt-${DateTime.now().millisecondsSinceEpoch}',
        matchId: 'match-1',
        type: type,
        teamId: teamId,
        playerId: playerId,
        playerName: p.fullName,
        secondaryPlayerId: secondaryPlayerId,
        minute: minute,
        refereeId: 'ref-1',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    );

    if (type == MatchEventType.goal) {
      final m = matches.first;
      if (m.homeTeamId == teamId) {
        m.homeScore++;
      } else if (m.awayTeamId == teamId) {
        m.awayScore++;
      }
      p.stats.goals++;
      if (secondaryPlayerId != null) {
        players.firstWhere((x) => x.id == secondaryPlayerId).stats.assists++;
      }
    }

    if (type == MatchEventType.yellowCard) p.stats.yellowCards++;
    if (type == MatchEventType.redCard) p.stats.redCards++;
  }

  void updateMatchStatus(String id, MatchStatus status) {
    matches.firstWhere((m) => m.id == id).status = status;
  }

  Future<void> addTeam(String name) async {
    teams.add(
      Team(
        id: 'team-${DateTime.now().millisecondsSinceEpoch}',
        leagueId: 'league-1',
        fieldId: 'field-1',
        name: name,
        crestUrl: '',
        colors: ['#1E1B4B', '#A3FF3F'],
        managerId: 'manager-new',
      ),
    );
  }

  Future<void> updatePlayerPhoto(String id, String path) async {
    players.firstWhere((p) => p.id == id).photoUrl = path;
  }

  Future<void> reset() async {
    for (final k in _prefs.getKeys().where((k) => k.startsWith(_prefix)).toList()) {
      await _prefs.remove(k);
    }
  }
}