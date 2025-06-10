// lib/data/model/PlayerModel.dart (Adjust path if different)
import 'package:cloud_firestore/cloud_firestore.dart'; // Make sure this is imported

enum Gender { male, female } // Define an enum for clarity and type safety

class Player {
  String? id; // Nullable for new players before ID is assigned by Firestore
  String firstName;
  String lastName;
  String jerseyNumber;

  // Gender gender; // Add gender field
  bool isCaptured; // Add isCaptured field
  String teamId; // Required for linking to team
  DateTime? creationTime;

  Player({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.jerseyNumber,
    // this.gender = Gender.male, // Default to male
    this.isCaptured = false, // Default to false
    required this.teamId,
    this.creationTime,
  });


  // Factory constructor to create a Player from a Firestore DocumentSnapshot
  factory Player.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Player(
      id: doc.id,
      firstName: data?['firstName'] as String,
      lastName: data?['lastName'] as String,
      jerseyNumber: data?['jerseyNumber'] as String,
      // gender: (data['gender'] as String?) == 'female' ? Gender.female : Gender.male,
      // Convert string to enum
      isCaptured: data?['isCaptured'] as bool? ?? false,
      // Default to false if null
      teamId: data?['teamId'] as String,
      creationTime: (data?['creationTime'] as Timestamp?)?.toDate(),
    );
  }

  // Method to convert Player object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'jerseyNumber': jerseyNumber,
      // 'gender':
      //     gender
      //         .toString()
      //         .split('.')
      //         .last,
      'isCaptured': isCaptured,
      'teamId': teamId,
      'creationTime': creationTime ?? FieldValue.serverTimestamp(),
    };
  }

  @override
  String toString() {
    return 'Player: $firstName $lastName,\n'
        'Position: $jerseyNumber,\n'
        'Captured: ${isCaptured ? "Yes," : "No,"}\n';
  }
}
