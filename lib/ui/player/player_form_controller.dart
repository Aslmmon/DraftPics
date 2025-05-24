// lib/controllers/player_form_controller.dart
import 'package:flutter/material.dart'; // For TextEditingController
import 'package:get/get.dart';

import '../../data/model/PlayerModel.dart';
import '../../data/services/FirestoreService.dart';

class PlayerFormController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController positionController = TextEditingController();

  var isEditing = false.obs;
  var isLoading = false.obs;
  Player? _originalPlayer;
  late String _currentTeamId;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;

    if (arguments != null) {
      if (arguments is Player) {
        // We are in edit mode
        isEditing.value = true;
        _originalPlayer = arguments;
        _currentTeamId =
            _originalPlayer!.teamId; // Get teamId from player being edited

        // Pre-fill the form fields with existing player data
        firstNameController.text = _originalPlayer!.firstName;
        lastNameController.text = _originalPlayer!.lastName;
        positionController.text = _originalPlayer!.position;
      } else if (arguments is String) {
        // We are in add mode, arguments is the teamId
        isEditing.value = false;
        _currentTeamId = arguments;
      } else {
        // Invalid arguments
        _handleInvalidArguments();
      }
    } else {
      // No arguments provided, likely an error or direct navigation without context
      _handleInvalidArguments();
    }
  }

  void _handleInvalidArguments() {
    Get.snackbar(
      'Error',
      'Missing team information or player data for form.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
    );
    // Navigate back if context is truly missing
    Future.delayed(const Duration(milliseconds: 500), () => Get.back());
  }

  // Method to save (add or update) the player
  Future<void> savePlayer() async {
    // Basic validation
    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty ||
        positionController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation',
        'Please fill all fields.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (_currentTeamId.isEmpty) {
      Get.snackbar(
        'Error',
        'Team context missing. Cannot save player.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true; // Show loading indicator

    try {
      if (isEditing.value && _originalPlayer != null) {
        // Update existing player
        final updatedPlayer = Player(
          id: _originalPlayer!.id,
          // Keep the original ID
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          position: positionController.text.trim(),
          isCaptured: _originalPlayer!.isCaptured,
          // Preserve original avatar
          teamId: _currentTeamId, // Preserve original teamId
        );
        await _firestoreService.updatePlayer(updatedPlayer);
        Get.snackbar(
          'Success',
          'Player updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // Add new player
        final newPlayer = Player(
          id: '',
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          position: positionController.text.trim(),
          teamId: _currentTeamId,
          isCaptured: false,
        );
        await _firestoreService.addPlayer(newPlayer);
        Get.snackbar(
          'Success',
          'Player added successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      Get.back(); // Go back to the previous screen (Team Details)
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
      isLoading.value = false; // Hide loading indicator
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
