// lib/ui/player/player_form_controller.dart (Adjust path if different)
import 'package:flutter/material.dart'; // For TextEditingController
import 'package:get/get.dart';
import '../../data/model/PlayerModel.dart'; // Make sure PlayerModel is imported
import '../../data/services/FirestoreService.dart'; // Make sure FirestoreService is imported

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
        await _firestoreService.updatePlayer(player);
        Get.snackbar(
          'Success',
          'Player updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        await _firestoreService.addPlayer(player);
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

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    positionController.dispose();
    super.onClose();
  }
}
