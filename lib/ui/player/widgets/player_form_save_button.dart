// lib/ui/player/widgets/player_form_save_button.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reutilizacao/ui/components/AppButton.dart';
import '../../../../utils/app_constants.dart'; // Constants
import '../player_form_controller.dart';
import 'add_player_button.dart'; // Controller

class PlayerFormSaveButton extends GetView<PlayerFormController> {
  const PlayerFormSaveButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: ReusableButton(
        // Use ReusableButton
        onPressed: () => controller.savePlayer(),
        // icon: const Icon(Icons.add, color: Colors.white), // Ensure icon color is white
        customChild: controller.isLoading.value
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
          style: TextStyle(
            color: Colors.white
          ),
          controller.isEditing.value
              ? AppConstants.saveChangesButton
              : AppConstants.addPlayerButtonForm
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }
}