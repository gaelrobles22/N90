// ============================================================
// NOVENTA - APP MODELS
// ============================================================

enum UserRole {
  player,
  managerTeam,
  referee,
  adminField,
}

// ============================================================
// POSITION
// ============================================================

enum Position {
  por,
  def,
  med,
  del,
}

Position positionFromString(String v) => Position.values.firstWhere(
      (e) => e.name.toUpperCase() == v.toUpperCase(),
  orElse: () => Position.del,
);

String positionLabel(Position p) => switch (p) {
  Position.por => 'Portero',
  Position.def => 'Defensa',
  Position.med => 'Medio',
  Position.del => 'Delantero',
};

// ============================================================
// VERIFICATION
// ============================================================

enum VerificationStatus {
  verified,
  pending,
  rejected,
}

// ============================================================
// MATCH STATUS
// ============================================================

enum MatchStatus {
  scheduled,
  live,
  finished,
  suspended,
}

// ============================================================
// MATCH EVENT TYPE
// ============================================================

enum MatchEventType {
  goal,
  assist,
  yellowCard,
  redCard,
  substitution,
  matchStarted,
  matchEnded,
}

// ============================================================
// PLAYER STATS
// ============================================================

class PlayerStats {
  int matchesPlayed;
  int goals;
  int assists;
  int yellowCards;
  int redCards;
  double rating;

  PlayerStats({
    this.matchesPlayed = 0,
    this.goals = 0,
    this.assists = 0,
    this.yellowCards = 0,
    this.redCards = 0,
    this.rating = 0,
  });

  Map<String, dynamic> toJson() => {
    'matchesPlayed': matchesPlayed,
    'goals': goals,
    'assists': assists,
    'yellowCards': yellowCards,
    'redCards': redCards,
    'rating': rating,
  };

  factory PlayerStats.fromJson(Map<String, dynamic> j) {
    return PlayerStats(
      matchesPlayed: _toInt(j['matchesPlayed']),
      goals: _toInt(j['goals']),
      assists: _toInt(j['assists']),
      yellowCards: _toInt(j['yellowCards']),
      redCards: _toInt(j['redCards']),
      rating: _toDouble(j['rating']),
    );
  }
}

// ============================================================
// PLAYER
// ============================================================

class Player {
  String id;
  String fullName;
  String photoUrl;
  String teamId;
  String teamName;

  Position position;

  int dorsal;

  double overallRating;

  VerificationStatus verificationStatus;

  PlayerStats stats;

  Player({
    required this.id,
    required this.fullName,
    required this.position,
    required this.dorsal,
    required this.photoUrl,
    required this.overallRating,
    required this.verificationStatus,
    required this.teamId,
    required this.teamName,
    required this.stats,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'position': position.name,
    'dorsal': dorsal,
    'photoUrl': photoUrl,
    'overallRating': overallRating,
    'verificationStatus': verificationStatus.name,
    'teamId': teamId,
    'teamName': teamName,
    'stats': stats.toJson(),
  };

  factory Player.fromJson(Map<String, dynamic> j) {
    return Player(
      id: j['id']?.toString() ?? '',
      fullName: j['fullName']?.toString() ?? '',
      position: positionFromString(
        j['position']?.toString() ?? 'del',
      ),
      dorsal: _toInt(
        j['dorsal'],
        defaultValue: 10,
      ),
      photoUrl: j['photoUrl']?.toString() ?? '',
      overallRating: _toDouble(j['overallRating']),
      verificationStatus:
      VerificationStatus.values.firstWhere(
            (e) => e.name == j['verificationStatus']?.toString(),
        orElse: () => VerificationStatus.verified,
      ),
      teamId: j['teamId']?.toString() ?? '',
      teamName: j['teamName']?.toString() ?? '',
      stats: PlayerStats.fromJson(
        j['stats'] is Map
            ? Map<String, dynamic>.from(j['stats'])
            : {},
      ),
    );
  }
}

// ============================================================
// FIELD
// ============================================================

class Field {
  String id;
  String name;
  String logoUrl;
  String photoUrl;
  String location;
  String description;
  String adminId;

  int activeLeaguesCount;

  Field({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.photoUrl,
    required this.location,
    required this.description,
    required this.adminId,
    required this.activeLeaguesCount,
  });
}

// ============================================================
// LEAGUE
// ============================================================

class League {
  String id;
  String fieldId;
  String name;
  String season;
  String category;
  String rules;

  League({
    required this.id,
    required this.fieldId,
    required this.name,
    required this.season,
    required this.category,
    required this.rules,
  });
}

// ============================================================
// TEAM
// ============================================================

class Team {
  String id;
  String leagueId;
  String fieldId;
  String name;
  String crestUrl;
  List<String> colors;
  String managerId;

  int? positionInTable;

  Team({
    required this.id,
    required this.leagueId,
    required this.fieldId,
    required this.name,
    required this.crestUrl,
    required this.colors,
    required this.managerId,
    this.positionInTable,
  });

  Map<String, dynamic> toJson() => {
    'leagueId': leagueId,
    'fieldId': fieldId,
    'name': name,
    'crestUrl': crestUrl,
    'colors': colors,
    'managerId': managerId,
    'positionInTable': positionInTable,
  };

  factory Team.fromJson(Map<String, dynamic> j) {
    final rawColors = j['colors'];

    List<String> parsedColors = [];

    if (rawColors is List) {
      parsedColors = rawColors
          .map(
            (item) => item?.toString() ?? '',
      )
          .where(
            (item) => item.isNotEmpty,
      )
          .toList();
    }

    return Team(
      id: j['id']?.toString() ?? '',
      leagueId: j['leagueId']?.toString() ?? '',
      fieldId: j['fieldId']?.toString() ?? '',
      name: j['name']?.toString() ?? '',
      crestUrl: j['crestUrl']?.toString() ?? '',
      colors: parsedColors,
      managerId: j['managerId']?.toString() ?? '',
      positionInTable: j['positionInTable'] is num
          ? (j['positionInTable'] as num).toInt()
          : null,
    );
  }
}

// ============================================================
// MATCH
// ============================================================

class Match {
  String id;
  String leagueId;
  String fieldId;

  String homeTeamId;
  String homeTeamName;
  String homeTeamCrest;

  String awayTeamId;
  String awayTeamName;
  String awayTeamCrest;

  String date;
  String time;

  String refereeId;
  String refereeName;

  String venueName;

  int matchday;
  int homeScore;
  int awayScore;

  MatchStatus status;

  Match({
    required this.id,
    required this.leagueId,
    required this.fieldId,
    required this.homeTeamId,
    required this.homeTeamName,
    required this.homeTeamCrest,
    required this.awayTeamId,
    required this.awayTeamName,
    required this.awayTeamCrest,
    required this.date,
    required this.time,
    required this.matchday,
    required this.status,
    required this.homeScore,
    required this.awayScore,
    required this.refereeId,
    required this.refereeName,
    required this.venueName,
  });
}

// ============================================================
// STANDING
// ============================================================

class Standing {
  String id;
  String leagueId;

  String teamId;
  String teamName;
  String crestUrl;

  int played;
  int won;
  int drawn;
  int lost;

  int goalsFor;
  int goalsAgainst;
  int goalDifference;
  int points;

  Standing({
    required this.id,
    required this.leagueId,
    required this.teamId,
    required this.teamName,
    required this.crestUrl,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.goalDifference,
    required this.points,
  });
}

// ============================================================
// LINEUP PLAYER
// ============================================================

class LineupPlayer {
  String playerId;
  String name;

  int dorsal;

  Position position;

  bool isStarter;

  double x;
  double y;

  LineupPlayer({
    required this.playerId,
    required this.name,
    required this.dorsal,
    required this.position,
    required this.isStarter,
    required this.x,
    required this.y,
  });
}

// ============================================================
// TEAM LINEUP
// ============================================================

class TeamLineup {
  String matchId;
  String teamId;
  String formation;

  List<LineupPlayer> players;

  TeamLineup({
    required this.matchId,
    required this.teamId,
    required this.formation,
    required this.players,
  });
}

// ============================================================
// MATCH EVENT
// ============================================================

class MatchEvent {
  String id;
  String matchId;

  MatchEventType type;

  String teamId;

  String playerId;
  String playerName;

  String? secondaryPlayerId;
  String? secondaryPlayerName;

  int minute;

  String refereeId;

  int timestamp;

  MatchEvent({
    required this.id,
    required this.matchId,
    required this.type,
    required this.teamId,
    required this.playerId,
    required this.playerName,
    this.secondaryPlayerId,
    this.secondaryPlayerName,
    required this.minute,
    required this.refereeId,
    required this.timestamp,
  });
}

// ============================================================
// HELPERS
// ============================================================

int _toInt(
    dynamic value, {
      int defaultValue = 0,
    }) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(
    value?.toString() ?? '',
  ) ??
      defaultValue;
}

double _toDouble(dynamic value) {
  if (value is double) {
    return value;
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(
    value?.toString() ?? '',
  ) ??
      0;
}