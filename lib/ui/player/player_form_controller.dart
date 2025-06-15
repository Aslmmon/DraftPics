// lib/ui/player/player_form_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/model/PlayerModel.dart'; // Ensure PlayerModel is imported
import '../../data/services/FirestoreService.dart';

enum Gender {
  male,
  female,
  other,
} // Example, ensure it matches your PlayerModel

class PlayerFormController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  // Text editing controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController jerseyNumberController =
      TextEditingController(); // Renamed for clarity

  // Observables for dropdowns/checkboxes
  final Rx<Gender> selectedGender = Gender.male.obs;
  final RxBool isCaptured = false.obs;

  // State management
  final RxBool isLoading = false.obs;
  final RxBool isEditing = false.obs;

  // Store current player being edited or team ID for new player
  Player? _playerToEdit; // Made private, access via getter if needed
  String? _teamId; // Made private

  // Public getters for teamId and playerToEdit if needed in the UI
  Player? get playerToEdit => _playerToEdit;

  String? get teamId => _teamId;

  @override
  void onInit() {
    super.onInit();
    _parseArguments(Get.arguments);
  }

  /// Parses arguments passed to the controller (Player for editing, String for new team ID).
  void _parseArguments(dynamic arguments) {
    if (arguments == null) {
      Get.snackbar(
        'Error',
        'Missing arguments for Player Form.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (arguments is Player) {
      _playerToEdit = arguments;
      isEditing.value = true;
      _populateFields(_playerToEdit!);
    } else if (arguments is String) {
      _teamId = arguments; // Passed teamId when adding new player
      isEditing.value = false;
    } else {
      Get.snackbar(
        'Error',
        'Invalid arguments type for Player Form.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Populates text fields and observable values when editing an existing player.
  void _populateFields(Player player) {
    firstNameController.text = player.firstName;
    lastNameController.text = player.lastName;
    jerseyNumberController.text = player.jerseyNumber;
    // selectedGender.value = player.gender; // Uncomment and implement if gender is part of PlayerModel
    isCaptured.value = player.isCaptured;
    _teamId = player.teamId; // Ensure teamId is set for editing context
  }

  /// Handles saving a new player or updating an existing one.
  Future<void> savePlayer() async {
    if (!_validateFields()) {
      return; // Validation failed, snackbar already shown
    }

    if (_teamId == null) {
      _showErrorSnackbar('Team ID is missing. Cannot save player.');
      return;
    }

    isLoading.value = true;
    try {
      // Create a Player instance from current form values
      final currentPlayer = Player(
        id: _playerToEdit?.id,
        // Use existing ID if editing
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        jerseyNumber: jerseyNumberController.text.trim(),
        isCaptured: isCaptured.value,
        teamId: _teamId!,
      );

      if (isEditing.value) {
        await _handlePlayerUpdate(currentPlayer);
      } else {
        await _firestoreService.addPlayer(currentPlayer, _teamId!);
        _showSuccessSnackbar('Player added successfully!');
      }
    //  Get.back(); // Navigate back after successful save/update
    } catch (e) {
      _showErrorSnackbar('Failed to save player: ${e.toString()}');
      print('Error saving player: $e'); // Keep print for debug console
    } finally {
      isLoading.value = false;
    }
  }

  /// Handles the logic for updating an existing player.
  Future<void> _handlePlayerUpdate(Player updatedPlayer) async {
    // Determine which fields have changed for Google Sheet and Firestore updates
    final Map<String, dynamic> changedFields = _getChangedFields(updatedPlayer);

    if (changedFields.isNotEmpty) {
      try {
        await _firestoreService.updatePlayerInSheet(
          teamFirestoreId: _teamId!,
          originalFirstName: _playerToEdit!.firstName,
          originalLastName: _playerToEdit!.lastName,
          originalJerseyNumber: _playerToEdit!.jerseyNumber,
          // Pass original jersey number for lookup
          updatedFields: changedFields,
        );
      } catch (e) {
        // If sheet update fails, log and show specific error, but don't prevent Firestore update
        print('Warning: Google Sheet update failed: $e');
        //  _showErrorSnackbar(
        //   'Player updated in app, but failed to update Google Sheet: ${e.toString()}',
        // );
      }
    }

    // Always attempt to update Firestore
    await _firestoreService.updatePlayer(updatedPlayer, _teamId!);
  //  _showSuccessSnackbar('Player updated successfully!');
  }

  /// Compares the updated player with the original to find changed fields.
  Map<String, dynamic> _getChangedFields(Player updatedPlayer) {
    final Map<String, dynamic> changedFields = {};
    if (updatedPlayer.firstName != _playerToEdit!.firstName) {
      changedFields['firstName'] = updatedPlayer.firstName;
    }
    if (updatedPlayer.lastName != _playerToEdit!.lastName) {
      changedFields['lastName'] = updatedPlayer.lastName;
    }
    if (updatedPlayer.jerseyNumber != _playerToEdit!.jerseyNumber) {
      changedFields['jerseyNumber'] = updatedPlayer.jerseyNumber;
    }
    if (updatedPlayer.isCaptured != _playerToEdit!.isCaptured) {
      changedFields['isCaptured'] = updatedPlayer.isCaptured;
    }
    return changedFields;
  }

  /// Basic form validation.
  bool _validateFields() {
    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty ||
        jerseyNumberController.text.trim().isEmpty) {
      _showErrorSnackbar('All fields are required!');
      return false;
    }
    return true;
  }

  /// Helper for displaying success snackbars.
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green, // Example success color
      colorText: Colors.white,
    );
  }

  /// Helper for displaying error snackbars.
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
    );
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    jerseyNumberController.dispose();
    super.onClose();
  }
}
