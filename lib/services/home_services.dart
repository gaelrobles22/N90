import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/app_models.dart';

class HomeService {
  final FirebaseFirestore _firestore;

  HomeService({
    FirebaseFirestore? firestore,
  }) : _firestore =
      firestore ?? FirebaseFirestore.instance;

  Future<Team?> getTeam(String teamId) async {
    debugPrint('NOVENTA - HOME SERVICE: CONSULTANDO TEAM');
    debugPrint('NOVENTA - TEAM ID: $teamId');

    if (teamId.trim().isEmpty) {
      debugPrint('NOVENTA - TEAM ID VACÍO');
      return null;
    }

    final document = await _firestore
        .collection('teams')
        .doc(teamId)
        .get();

    debugPrint(
      'NOVENTA - TEAM DOCUMENT EXISTS: ${document.exists}',
    );

    if (!document.exists) {
      debugPrint(
        'NOVENTA - TEAM NO EXISTE: $teamId',
      );
      return null;
    }

    final data = document.data();

    debugPrint('========================================');
    debugPrint('NOVENTA - TEAM FIRESTORE');
    debugPrint('DOCUMENT ID: ${document.id}');
    debugPrint('DATA: $data');
    debugPrint('========================================');

    if (data == null) {
      debugPrint('NOVENTA - TEAM DATA ES NULL');
      return null;
    }

    try {
      final team = Team.fromJson({
        ...data,
        'id': document.id,
      });

      debugPrint(
        'NOVENTA - TEAM CONVERTIDO CORRECTAMENTE',
      );
      debugPrint(
        'NOVENTA - TEAM NAME: ${team.name}',
      );

      return team;
    } catch (e, stackTrace) {
      debugPrint(
        'NOVENTA - ERROR CONVIRTIENDO TEAM: $e',
      );
      debugPrint(
        'NOVENTA - STACK TEAM: $stackTrace',
      );
      rethrow;
    }
  }

  Future<List<Match>> getMatchesByField(
      String fieldId,
      ) async {
    debugPrint('NOVENTA - HOME SERVICE: CONSULTANDO MATCHES');
    debugPrint('NOVENTA - MATCH FIELD ID: $fieldId');

    if (fieldId.trim().isEmpty) {
      debugPrint('NOVENTA - MATCH FIELD ID VACÍO');
      return [];
    }

    final snapshot = await _firestore
        .collection('matches')
        .where(
      'fieldId',
      isEqualTo: fieldId,
    )
        .get();

    debugPrint(
      'NOVENTA - MATCHES FIRESTORE: ${snapshot.docs.length}',
    );

    for (final doc in snapshot.docs) {
      debugPrint('========================================');
      debugPrint(
        'NOVENTA - MATCH DOCUMENT: ${doc.id}',
      );
      debugPrint(
        'NOVENTA - MATCH DATA: ${doc.data()}',
      );
      debugPrint('========================================');
    }

    try {
      final matches = snapshot.docs
          .map(
            (doc) => _matchFromFirestore(
          doc.id,
          doc.data(),
        ),
      )
          .toList();

      debugPrint(
        'NOVENTA - MATCHES CONVERTIDOS: ${matches.length}',
      );

      return matches;
    } catch (e, stackTrace) {
      debugPrint(
        'NOVENTA - ERROR CONVIRTIENDO MATCH: $e',
      );
      debugPrint(
        'NOVENTA - STACK MATCH: $stackTrace',
      );
      rethrow;
    }
  }

  Match _matchFromFirestore(
      String id,
      Map<String, dynamic> data,
      ) {
    debugPrint(
      'NOVENTA - CONVIRTIENDO MATCH: $id',
    );

    return Match(
      id: id,
      leagueId:
      data['leagueId']?.toString() ?? '',
      fieldId:
      data['fieldId']?.toString() ?? '',
      homeTeamId:
      data['homeTeamId']?.toString() ?? '',
      homeTeamName:
      data['homeTeamName']?.toString() ?? '',
      homeTeamCrest:
      data['homeTeamCrest']?.toString() ?? '',
      awayTeamId:
      data['awayTeamId']?.toString() ?? '',
      awayTeamName:
      data['awayTeamName']?.toString() ?? '',
      awayTeamCrest:
      data['awayTeamCrest']?.toString() ?? '',
      date:
      data['date']?.toString() ?? '',
      time:
      data['time']?.toString() ?? '',
      matchday:
      _toInt(data['matchday']),
      status:
      _matchStatusFromString(
        data['status']?.toString(),
      ),
      homeScore:
      _toInt(data['homeScore']),
      awayScore:
      _toInt(data['awayScore']),
      refereeId:
      data['refereeId']?.toString() ?? '',
      refereeName:
      data['refereeName']?.toString() ?? '',
      venueName:
      data['venueName']?.toString() ?? '',
    );
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  MatchStatus _matchStatusFromString(
      String? value,
      ) {
    return MatchStatus.values.firstWhere(
          (status) =>
      status.name.toLowerCase() ==
          (value ?? '').toLowerCase(),
      orElse: () =>
      MatchStatus.scheduled,
    );
  }
}