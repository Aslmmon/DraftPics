// lib/ui/player/widgets/player_form_save_button.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reutilizacao/ui/components/AppButton.dart';
import '../../../../utils/app_constants.dart'; // Constants
import '../player_form_controller.dart';

class PlayerFormSaveButton extends GetView<PlayerFormController> {
  const PlayerFormSaveButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: Obx(
        () => ReusableButton(
          onPressed: () async {
             controller.savePlayer().whenComplete((){
               Get.back();
             });
          },
          isLoading: controller.isLoading.value,
          text:
              controller.isEditing.value
                  ? AppConstants.saveChangesButton
                  : AppConstants.addPlayerButtonForm,
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }
}
