import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/team.dart';

class TeamService {
  final FirebaseFirestore _firestore;

  TeamService({
    FirebaseFirestore? firestore,
  }) : _firestore =
      firestore ?? FirebaseFirestore.instance;

  Future<List<Team>> getTeamsByField(
      String fieldId,
      ) async {
    final snapshot = await _firestore
        .collection('teams')
        .where(
      'fieldId',
      isEqualTo: fieldId,
    )
        .where(
      'active',
      isEqualTo: true,
    )
        .get();

    return snapshot.docs
        .map(
          (doc) => Team.fromMap({
        ...doc.data(),
        'id': doc.id,
      }),
    )
        .toList();
  }
}