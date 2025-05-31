import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';

import '../model/PlayerModel.dart';
import '../model/TeamModel.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String teamsCollections = "teams";

  // This is now the *name* of the subcollection, not a top-level collection path.
  String playersSubCollectionName = "players"; // Renamed for clarity

  // --- Team-related methods: These are already fine as they deal with top-level 'Teams' ---
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

  Stream<List<Player>> getAllPlayers() {
    // Requires a Firestore Collection Group index on 'players'
    return _db
        .collectionGroup(playersSubCollectionName) // Use collectionGroup for all players across all teams
        .snapshots()
        .map(
          (snapshot) =>
          snapshot.docs.map((doc) => Player.fromFirestore(doc)).toList(),
    );
  }

  Future<void> addTeam(Team team) =>
      _db.collection(teamsCollections).doc(team.id).set(team.toFirestore());

  Future<void> updateTeam(Team team) {
    return _db
        .collection(teamsCollections)
        .doc(team.id)
        .update(team.toFirestore());
  }

  Future<void> deleteTeam(String teamId) async {
    // When deleting a team, you might also want to delete its subcollection players.
    // Firestore doesn't do this automatically. You'd need to fetch and delete them
    // or use a Cloud Function for cascade delete. For now, we'll keep it simple.
    // return _db.collection(teamsCollections).doc(teamId).delete();

    try {

      // 1. Get a reference to the team document
      final teamRef = _db.collection(teamsCollections).doc(teamId);

      // 2. Fetch all players in the subcollection.
      //    NOTE: For subcollections with >500 documents, you'd need
      //    to implement pagination (fetch 500, delete, fetch next 500, etc.).
      final playersSnapshot = await teamRef.collection(playersSubCollectionName).get();

      // 3. If there are players, delete them in a batch
      if (playersSnapshot.docs.isNotEmpty) {
        WriteBatch batch = _db.batch();
        for (var doc in playersSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      // 4. Finally, delete the team document
      await teamRef.delete();

    } catch (e) {
      rethrow;
    }
  }


  // --- End Team-related methods ---

  // --- Player-related methods: SIGNIFICANT MODIFICATIONS ---

  // NOTE: If all players are now strictly within team subcollections,
  // getAllPlayers() would require a "Collection Group Query".
  // This requires setting up a Firestore index in the Firebase Console.
  // If you only ever need players *per team*, you might not need this method anymore.
  // If you DO need all players across ALL teams, uncomment and remember to create the index.
  /*
  Stream<List<Player>> getAllPlayers() {
    // Requires a Firestore Collection Group index on 'players'
    return _db
        .collectionGroup(playersSubCollectionName) // Use collectionGroup for all players across all teams
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Player.fromFirestore(doc)).toList(),
        );
  }
  */

  // MODIFIED: getPlayersForTeam now correctly queries the subcollection
  Stream<List<Player>> getPlayersForTeam(String teamId) => _db
      .collection(teamsCollections) // Start from the 'Teams' collection
      .doc(teamId) // Go into the specific team document
      .collection(
        playersSubCollectionName,
      ) // Access the 'players' subcollection
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => Player.fromFirestore(doc)).toList(),
      );

  // MODIFIED: getPlayerById now needs the teamId to locate the player
  Future<Player?> getPlayerById(String teamId, String playerId) async {
    final doc =
        await _db
            .collection(teamsCollections)
            .doc(teamId)
            .collection(playersSubCollectionName)
            .doc(playerId)
            .get();
    return doc.exists ? Player.fromFirestore(doc) : null;
  }

  // MODIFIED: addPlayer now targets the specific team's subcollection
  Future<void> addPlayer(Player player, String teamId) => _db
      .collection(teamsCollections)
      .doc(teamId)
      .collection(playersSubCollectionName)
      .doc(player.id) // Use player.id if provided, otherwise .doc() for auto-ID
      .set(player.toFirestore());

  // MODIFIED: updatePlayer now targets the specific team's subcollection
  Future<void> updatePlayer(Player player, String teamId) => _db
      .collection(teamsCollections)
      .doc(teamId)
      .collection(playersSubCollectionName)
      .doc(player.id!) // player.id must exist for update
      .update(player.toFirestore());

  // MODIFIED: deletePlayer now needs the teamId to locate the player
  Future<void> deletePlayer(String teamId, String playerId) async {

    await _db
        .collection(teamsCollections)
        .doc(teamId)
        .collection(playersSubCollectionName)
        .doc(playerId)
        .delete();
  }

  // MODIFIED: uploadPlayersFromCsv now targets the specific team's subcollection for batch writes
  Future<List<String>> uploadPlayersFromCsv(
    Uint8List csvBytes,
    String teamId,
  ) async {
    List<String> uploadStatus = [];
    try {
      final String csvString = utf8.decode(csvBytes as List<int>);
      final List<List<dynamic>> csvTable = const CsvToListConverter().convert(
        csvString,
      );

      if (csvTable.isEmpty) {
        uploadStatus.add("CSV file is empty.");
        return uploadStatus;
      }

      final List<String> headers =
          csvTable[0].map((e) => e.toString().trim()).toList();
      final List<List<dynamic>> dataRows = csvTable.sublist(1);

      final int firstNameIndex = headers.indexWhere(
        (h) => h.toLowerCase() == 'firstname',
      );
      final int lastNameIndex = headers.indexWhere(
        (h) => h.toLowerCase() == 'lastname',
      );
      final int positionIndex = headers.indexWhere(
        (h) => h.toLowerCase() == 'jersey',
      );
      final int isCapturedIndex = headers.indexWhere(
        (h) => h.toLowerCase() == 'iscaptured',
      );

      if (firstNameIndex == -1 ||
          lastNameIndex == -1 ||
          positionIndex == -1 ||
          isCapturedIndex == -1) {
        uploadStatus.add(
          "Missing required headers: firstName, lastName, jersey, isCaptured. Please check your CSV format.",
        );
        return uploadStatus;
      }

      WriteBatch batch = _db.batch();
      int successCount = 0;
      int errorCount = 0;

      for (int i = 0; i < dataRows.length; i++) {
        final row = dataRows[i];
        if (row.length <=
            [
              firstNameIndex,
              lastNameIndex,
              positionIndex,
              isCapturedIndex,
            ].reduce((a, b) => a > b ? a : b)) {
          uploadStatus.add(
            "Row ${i + 2}: Malformed data (not enough columns). Skipping.",
          );
          errorCount++;
          continue;
        }

        try {
          final String firstName = row[firstNameIndex]?.toString().trim() ?? '';
          final String lastName = row[lastNameIndex]?.toString().trim() ?? '';
          final String position = row[positionIndex]?.toString().trim() ?? '';
          final String isCapturedString =
              row[isCapturedIndex]?.toString().trim().toLowerCase() ?? '';

          if (firstName.isEmpty ||
              lastName.isEmpty ||
              position.isEmpty ||
              isCapturedString.isEmpty) {
            uploadStatus.add(
              "Row ${i + 2}: Required field is empty. Skipping.",
            );
            errorCount++;
            continue;
          }

          bool isCaptured;
          if (isCapturedString == 'true' ||
              isCapturedString == 'yes' ||
              isCapturedString == '1') {
            isCaptured = true;
          } else if (isCapturedString == 'false' ||
              isCapturedString == 'no' ||
              isCapturedString == '0') {
            isCaptured = false;
          } else {
            uploadStatus.add(
              "Row ${i + 2}: Invalid isCaptured value ('$isCapturedString'). Expected 'true/yes/1' or 'false/no/0'. Skipping.",
            );
            errorCount++;
            continue;
          }

          // Note: The Player model's constructor should allow a null ID for new players.
          final newPlayer = Player(
            id: null,
            // Let Firestore generate the ID when setting
            firstName: firstName,
            lastName: lastName,
            jerseyNumber: position,
            teamId: teamId,
            // Store teamId as a field for data integrity if needed
            isCaptured: isCaptured,
            creationTime: DateTime.now(),
          );

          // MODIFIED: Batch write now targets the specific team's subcollection
          DocumentReference playerRef =
              _db
                  .collection(teamsCollections)
                  .doc(teamId)
                  .collection(playersSubCollectionName)
                  .doc(); // .doc() for auto-generated ID
          batch.set(playerRef, newPlayer.toFirestore());
          successCount++;
        } catch (e) {
          uploadStatus.add(
            "Row ${i + 2}: Error processing row: ${e.toString()}. Skipping.",
          );
          errorCount++;
          print("Error processing CSV row ${i + 2}: $e");
        }
      }

      if (successCount > 0) {
        await batch.commit();
        uploadStatus.insert(
          0,
          "CSV Upload Complete: $successCount players added successfully to this team.",
        );
      } else if (errorCount > 0) {
        uploadStatus.insert(
          0,
          "CSV Upload Finished with Errors. No players were added.",
        );
      } else {
        uploadStatus.insert(0, "No valid players found in CSV to upload.");
      }
    } catch (e) {
      uploadStatus.add("Failed to read or parse CSV: ${e.toString()}");
      print("Error in uploadPlayersFromCsv: $e");
    }
    return uploadStatus;
  }
}
