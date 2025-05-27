import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';

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
    return _db
        .collection(playersCollection)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Player.fromFirestore(doc)).toList(),
        );
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

      // Define expected headers for PlayerModel (case-insensitive)
      final int firstNameIndex = headers.indexWhere(
        (h) => h.toLowerCase() == 'firstname',
      );
      final int lastNameIndex = headers.indexWhere(
        (h) => h.toLowerCase() == 'lastname',
      );
      final int positionIndex = headers.indexWhere(
        (h) => h.toLowerCase() == 'position',
      );
      final int genderIndex = headers.indexWhere(
        (h) => h.toLowerCase() == 'gender',
      );
      final int isCapturedIndex = headers.indexWhere(
        (h) => h.toLowerCase() == 'iscaptured',
      );
      // No need to look for teamId in CSV anymore, as we'll use the passed teamId

      if (firstNameIndex == -1 ||
          lastNameIndex == -1 ||
          positionIndex == -1 ||
          genderIndex == -1 ||
          isCapturedIndex == -1) {
        uploadStatus.add(
          "Missing required headers: firstName, lastName, position, gender, isCaptured. Please check your CSV format.",
        );
        return uploadStatus;
      }

      WriteBatch batch = _db.batch();
      int successCount = 0;
      int errorCount = 0;

      for (int i = 0; i < dataRows.length; i++) {
        final row = dataRows[i];
        // Ensure row has enough columns to avoid RangeError
        if (row.length <=
            [
              firstNameIndex,
              lastNameIndex,
              positionIndex,
              genderIndex,
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
          final String genderString =
              row[genderIndex]?.toString().trim().toLowerCase() ?? '';
          final String isCapturedString =
              row[isCapturedIndex]?.toString().trim().toLowerCase() ?? '';

          if (firstName.isEmpty ||
              lastName.isEmpty ||
              position.isEmpty ||
              genderString.isEmpty ||
              isCapturedString.isEmpty) {
            uploadStatus.add(
              "Row ${i + 2}: Required field is empty. Skipping.",
            );
            errorCount++;
            continue;
          }

          Gender gender;
          if (genderString == 'male') {
            gender = Gender.male;
          } else if (genderString == 'female') {
            gender = Gender.female;
          } else {
            uploadStatus.add(
              "Row ${i + 2}: Invalid gender value ('$genderString'). Expected 'male' or 'female'. Skipping.",
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

          final newPlayer = Player(
            firstName: firstName,
            lastName: lastName,
            position: position,
            teamId: teamId,
            // <<< ALWAYS ASSIGN THE PASSED teamId
            gender: gender,
            isCaptured: isCaptured,
            creationTime: DateTime.now(),
          );

          DocumentReference playerRef = _db.collection(playersCollection).doc();
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
