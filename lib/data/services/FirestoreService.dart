import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:draftpics/utils/app_constants.dart';
import 'package:http/http.dart' as http;

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
        .orderBy('orderIndex', descending: false) // <--- THIS IS THE KEY CHANGE
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Team.fromFirestore(doc)).toList(),
        );
  }


  Future<void> deleteAllTeamsAndPlayers() async {
    try {
      // Get all team documents
      final QuerySnapshot<Map<String, dynamic>> teamsSnapshot =
      await _db.collection(teamsCollections).get();

      if (teamsSnapshot.docs.isEmpty) {
        print('No teams found to delete.');
        return;
      }

      // Initialize a WriteBatch for efficient deletion
      WriteBatch batch = _db.batch();

      // Iterate through each team document
      for (var teamDoc in teamsSnapshot.docs) {
        final teamId = teamDoc.id;

        // 1. Delete all players for the current team
        final QuerySnapshot<Map<String, dynamic>> playersSnapshot =
        await _db.collection(teamsCollections).doc(teamId).collection(playersSubCollectionName).get();

        if (playersSnapshot.docs.isNotEmpty) {
          print('Deleting ${playersSnapshot.docs.length} players for team: $teamId');
          for (var playerDoc in playersSnapshot.docs) {
            batch.delete(playerDoc.reference); // Add player to batch for deletion
          }
        } else {
          print('No players found for team: $teamId');
        }

        // 2. Delete the team document itself
        batch.delete(teamDoc.reference); // Add team to batch for deletion
        print('Adding team "$teamId" to batch for deletion.');
      }

      // Commit the batch writes
      await batch.commit();
      print('Successfully deleted all teams and their players.');
    } catch (e) {
      print('Error deleting teams and players: $e');
      // You might want to throw the error or handle it more robustly
      rethrow;
    }
  }

  Future<Team?> getTeamById(String teamId) async {
    final doc = await _db.collection(teamsCollections).doc(teamId).get();
    return doc.exists ? Team.fromFirestore(doc) : null;
  }

  Stream<List<Player>> getAllPlayers() {
    // Requires a Firestore Collection Group index on 'players'
    return _db
        .collectionGroup(
          playersSubCollectionName,
        ) // Use collectionGroup for all players across all teams
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
    try {
      final teamRef = _db.collection(teamsCollections).doc(teamId);
      final playersSnapshot =
          await teamRef.collection(playersSubCollectionName).get();

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

  Future<void> deleteTeams(String teamId, String playerId) async {
    await _db.collection(teamsCollections).doc(teamId).delete();
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

  Future<void> updatePlayerInSheet({
    required String teamFirestoreId,
    required String originalFirstName,
    required String originalLastName,
    required String
    originalJerseyNumber, // Added this back for clarity in sheet lookup
    required Map<String, dynamic> updatedFields,
  }) async {
    final Map<String, String> params = {
      'action': 'editPlayerInSheet',
      'teamFirestoreId': teamFirestoreId,
      'originalFirstName': originalFirstName,
      'originalLastName': originalLastName,
      'originalJerseyNumber': originalJerseyNumber,
      // Ensure this is sent for lookup
      'updatedFields': jsonEncode(updatedFields),
    };

    // --- Debugging the Request ---
    print('--- HTTP Request Details (GoogleSheetService) ---');
    print('URL: ${AppConstants.appsScriptWebAppUrl}');
    print('Method: POST');
    print('Request Body (params):');
    params.forEach((key, value) {
      print('  $key: $value');
    });
    print('--------------------------------------------------');
    // --- End Debugging the Request ---

    try {
      final response = await http.post(
        Uri.parse(AppConstants.appsScriptWebAppUrl),
        body: params,
      );

      // --- Debugging the Response ---
      print('--- HTTP Response Details (GoogleSheetService) ---');
      print('URL: ${response.request?.url}');
      print('Status Code: ${response.statusCode}');
      print('Response Headers:');
      response.headers.forEach((key, value) {
        print('  $key: $value');
      });
      print('Response Body: ${response.body}');
      print('--------------------------------------------------');
      // --- End Debugging the Response ---

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print("Google Sheet update response: ${responseBody.toString()}");
        if (responseBody['status'] == 'success') {
          print(
            'Player update in sheet successful: ${responseBody['message']}',
          );
          // No Get.snackbar here, let the controller handle UI feedback
        } else {
          // Specific error from the Apps Script
          throw Exception('Sheet API Error: ${responseBody['message']}');
        }
      } else {
        throw Exception(
          'Failed to update player in sheet: HTTP ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error updating player in sheet (GoogleSheetService): $e');
      rethrow; // Re-throw to allow the controller to catch and show snackbar
    }
  }

  Future<http.Response> syncSheets() async {
    final response = await http.get(
      Uri.parse(AppConstants.appsScriptWebAppUrl),
    );

    return response;
  }
}
