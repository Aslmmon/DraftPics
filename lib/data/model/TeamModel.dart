// models/team_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'PlayerModel.dart';

class Team {
  final String? id;
  final String name;
  final List<Player> players; // This list will be populated separately
  DateTime? creationTime; // <<< ADD THIS FIELD

  Team({
    this.id,
    required this.name,
    this.players = const [],
    this.creationTime,
  });

  factory Team.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Team(
      id: doc.id, // The document ID is the Team's ID
      name: data['name'] as String,
      players: [],
      creationTime:
          (data['creationTime'] as Timestamp?)
              ?.toDate(), // Convert Timestamp to DateTime
    );
  }

  // Method to convert a Team object to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'creationTime': creationTime ?? FieldValue.serverTimestamp(),

      // Set timestamp on creation
    };
  }
}
