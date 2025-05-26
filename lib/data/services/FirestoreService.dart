import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/PlayerModel.dart';
import '../model/TeamModel.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String teamsCollections = "Teams";
  String playersCollection = "Players";

  Stream<List<Team>> getTeams() {
    return _db
        .collection(teamsCollections)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Team.fromFirestore(doc)).toList(),
        );
  }

  Future<Team?> getTeamById(String teamId) async {
    final doc = await _db.collection(teamsCollections).doc(teamId).get();
    return doc.exists ? Team.fromFirestore(doc) : null;
  }

  Future<void> addTeam(Team team) =>
      _db.collection(teamsCollections).doc(team.id).set(team.toFirestore());

  Future<void> updateTeam(Team team) {
    return _db
        .collection(teamsCollections)
        .doc(team.id)
        .update(team.toFirestore());
  }

  Future<void> deleteTeam(String teamId) {
    return _db.collection(teamsCollections).doc(teamId).delete();
  }

  Future<void> deletePlayer(String playerId) async {
    await _db.collection(playersCollection).doc(playerId).delete();
  }
  Stream<List<Player>> getAllPlayers() {
    return _db.collection(playersCollection).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Player.fromFirestore(doc)).toList());
  }

  Stream<List<Player>> getPlayersForTeam(String teamId) => _db
      .collection(playersCollection)
      .where('teamId', isEqualTo: teamId) // Filter by teamId
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => Player.fromFirestore(doc)).toList(),
      );

  Future<Player?> getPlayerById(String playerId) async {
    final doc = await _db.collection(playersCollection).doc(playerId).get();
    return doc.exists ? Player.fromFirestore(doc) : null;
  }

  Future<void> addPlayer(Player player) =>
      _db.collection(playersCollection).doc().set(player.toFirestore());

  Future<void> updatePlayer(Player player) => _db
      .collection(playersCollection)
      .doc(player.id)
      .update(player.toFirestore());
}
