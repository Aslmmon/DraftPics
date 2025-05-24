// models/team_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'PlayerModel.dart';

class Team {
  final String? id;
  final String name;
  final List<Player> players; // This list will be populated separately

  Team({
    this.id,
    required this.name,
    this.players = const [], // Default to empty list
  });

  factory Team.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Team(
      id: doc.id, // The document ID is the Team's ID
      name: data['name'] as String,
      players: [],
    );
  }

  // Method to convert a Team object to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {'name': name};
  }
}
