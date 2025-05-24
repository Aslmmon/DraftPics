// models/player_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Player {
  final String id;
  final String firstName;
  final String lastName;
  final String position;
  final bool isCaptured;
  final String teamId; // Crucial: Links Player to Team

  Player({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.position,
    this.isCaptured = false,
    required this.teamId, // Make sure this is required
  });

  // Factory constructor to create a Player object from a Firestore DocumentSnapshot
  factory Player.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Player(
      id: doc.id,
      // The document ID is the Player's ID
      firstName: data['firstName'] as String,
      lastName: data['lastName'] as String,
      position: data['position'] as String,
      isCaptured: data['isCaptured'] as bool? ?? false,
      teamId: data['teamId'] as String, // Retrieve teamId
    );
  }

  // Method to convert a Player object to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'position': position,
      'isCaptured': isCaptured,
      'teamId': teamId, // Include teamId when saving
    };
  }
}
