// lib/ui/player/player_form_controller.dart (Adjust path if different)
import 'dart:convert';

import 'package:flutter/material.dart'; // For TextEditingController
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../data/model/PlayerModel.dart'; // Make sure PlayerModel is imported
import '../../data/services/FirestoreService.dart';
import '../../utils/app_constants.dart'; // Make sure FirestoreService is imported

class PlayerFormController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  // Text editing controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController positionController = TextEditingController();

  // Observables for new dropdowns
  final Rx<Gender> selectedGender = Gender.male.obs; // Observable for gender
  final RxBool isCaptured = false.obs; // Observable for isCaptured

  // State management
  final RxBool isLoading = false.obs;
  final RxBool isEditing = false.obs; // To determine if we're adding or editing

  // Store current player being edited
  Player? playerToEdit;
  String? teamId; // To know which team this player belongs to

  @override
  void onInit() {
    super.onInit();
    // Get arguments (player for editing, teamId for adding)
    if (Get.arguments != null) {
      if (Get.arguments is Player) {
        playerToEdit = Get.arguments as Player;
        isEditing.value = true;
        _populateFields(playerToEdit!);
      } else if (Get.arguments is String) {
        teamId =
            Get.arguments as String; // Passed teamId when adding new player
        isEditing.value = false;
      }
    }
  }

  void _populateFields(Player player) {
    firstNameController.text = player.firstName;
    lastNameController.text = player.lastName;
    positionController.text = player.jerseyNumber;
    // selectedGender.value = player.gender; // Set initial gender
    isCaptured.value = player.isCaptured; // Set initial isCaptured
    teamId = player.teamId; // Ensure teamId is set for editing context
  }

  Future<void> savePlayer() async {
    // Basic validation
    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty ||
        positionController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'All fields are required!',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (teamId == null) {
      Get.snackbar(
        'Error',
        'Team ID is missing. Cannot save player.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    print("isLoading value" + isLoading.value.toString());
    try {
      final player = Player(
        id: playerToEdit?.id,
        // Use existing ID if editing
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        jerseyNumber: positionController.text.trim(),
        // gender: selectedGender.value,
        // Get selected gender
        isCaptured: isCaptured.value,
        // Get selected isCaptured
        teamId: teamId!,
      );

      if (isEditing.value) {
        final updatedPlayer = Player(
          id: playerToEdit!.id,
          // Keep the existing ID
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          jerseyNumber: positionController.text.trim(),
          // gender: selectedGender.value, // Uncomment if gender is updated
          isCaptured: isCaptured.value,
          teamId: teamId!,
          // creationTime: playerToEdit!.creationTime, // Keep original creation time
        );

        // Determine which fields have changed for Google Sheet update
        final Map<String, dynamic> sheetUpdatedFields = {};
        if (updatedPlayer.firstName != playerToEdit!.firstName) {
          sheetUpdatedFields['firstName'] = updatedPlayer.firstName;
        }
        if (updatedPlayer.lastName != playerToEdit!.lastName) {
          sheetUpdatedFields['lastName'] = updatedPlayer.lastName;
        }
        if (updatedPlayer.jerseyNumber != playerToEdit!.jerseyNumber) {
          sheetUpdatedFields['jerseyNumber'] = updatedPlayer.jerseyNumber;
        }

        if (updatedPlayer.isCaptured != playerToEdit!.isCaptured) {
          sheetUpdatedFields['isCaptured'] = updatedPlayer.isCaptured;
        }

        if (sheetUpdatedFields.isNotEmpty) {
          await updatePlayerInSheetOnly(
            teamFirestoreId: teamId!,
            originalFirstName: playerToEdit!.firstName,
            originalLastName: playerToEdit!.lastName,
            originalJerseyNumber: playerToEdit!.jerseyNumber,
            updatedFields: sheetUpdatedFields,
          );
        }

        await _firestoreService.updatePlayer(player, player.teamId);
        Get.snackbar(
          'Success',
          'Player updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        await _firestoreService.addPlayer(player, player.teamId);
        Get.snackbar(
          'Success',
          'Player added successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save player: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      print('Error saving player: $e');
    } finally {
      isLoading.value = false;
      print("isLoading value finally " + isLoading.value.toString());
    }
  }

  Future<void> updatePlayerInSheetOnly({
    required String teamFirestoreId,
    // Still needed to identify the Google Sheet
    required String
    originalFirstName, // Player's current first name for sheet lookup
    required String
    originalLastName, // Player's current last name for sheet lookup
    required String originalJerseyNumber,
    // Player's current jersey number for sheet lookup
    required Map<String, dynamic> updatedFields, // Only the fields that changed
  }) async {
    const String webAppUrl =
        AppConstants
            .appsScriptWebAppUrl; // Replace with your deployed Web App URL

    try {
      final Map<String, String> params = {
        'action': 'editPlayerInSheet',
        // <-- New action name
        'teamFirestoreId': teamFirestoreId,
        'originalFirstName': originalFirstName,
        'originalLastName': originalLastName,
        'originalJerseyNumber': originalJerseyNumber,
        'updatedFields': jsonEncode(updatedFields),
        // Stringify the map of updated fields
      };

      final response = await http.post(Uri.parse(webAppUrl), body: params);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print("response total is + " + responseBody.toString());
        print('Player update in sheet successful: ${responseBody['message']}');
        // Handle success in UI (e.g., show snackbar)
      } else {
        print(
          'Player update in sheet failed: ${response.statusCode} - ${response.body}',
        );
        // Handle error in UI
      }
    } catch (e) {
      print('Error updating player in sheet: $e');
      // Handle exception
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    positionController.dispose();
    super.onClose();
  }
}
