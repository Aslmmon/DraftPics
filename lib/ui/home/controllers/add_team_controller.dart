import 'dart:async'; // Required for StreamSubscription

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../data/model/TeamModel.dart';
import '../../../data/services/FirestoreService.dart';

class AddTeamController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  var isLoading = false.obs;

  final TextEditingController teamNameController = TextEditingController();

  // Method to add a new team to Firestore (Pure Logic)
  Future<void> addTeam(String teamName) async {
    isLoading.value = true; // Set loading to true

    print(teamName.toString());
    try {
      if (teamName.trim().isEmpty) {
        Get.snackbar(
          'Validation Error',
          'Team name cannot be empty.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return; // Exit if validation fails
      }

      final newTeam = Team(name: teamName);

      await _firestoreService.addTeam(newTeam);

      Get.back(); // Close the bottom sheet (this is called from the UI)
      Get.snackbar(
        'Success',
        'Team "$teamName" added successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add team: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      print('Error adding team: $e');
    } finally {
      teamNameController.text = '';
      isLoading.value = false; // Set loading to false regardless of outcome
    }
  }

  @override
  void onClose() {
    teamNameController.text = '';
    teamNameController.dispose();
    super.onClose();
  }
}
