// lib/ui/player/widgets/player_form_dropdowns_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Needed for Obx and GetView
import '../../../../data/model/PlayerModel.dart'; // PlayerModel for Gender enum
import '../../../../utils/app_constants.dart'; // Constants
import '../player_form_controller.dart'; // Controller

class PlayerFormDropdownsSection extends GetView<PlayerFormController> {
  final TextTheme textTheme;
  final InputDecoration customInputDecoration;

  const PlayerFormDropdownsSection({
    super.key,
    required this.textTheme,
    required this.customInputDecoration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 16),
        // Text(
        //   AppConstants.genderLabel, // Use constant
        //   style: textTheme.titleMedium?.copyWith(
        //     fontWeight: FontWeight.bold,
        //     color: Colors.black,
        //   ),
        // ),

        // const SizedBox(height: 8),
        // Obx(
        //       () => DropdownButtonFormField<Gender>(
        //     value: controller.selectedGender.value,
        //     decoration: customInputDecoration.copyWith(
        //       hintText: AppConstants.selectGenderHint, // Use constant
        //     ),
        //     items: const [
        //       DropdownMenuItem(value: Gender.male, child: Text(AppConstants.playerGenderMale)),
        //       DropdownMenuItem(value: Gender.female, child: Text(AppConstants.playerGenderFemale)),
        //     ],
        //     onChanged: (Gender? newValue) {
        //       if (newValue != null) {
        //         controller.selectedGender.value = newValue;
        //       }
        //     },
        //     dropdownColor: Colors.white,
        //     style: textTheme.bodyLarge?.copyWith(color: Colors.black),
        //     iconEnabledColor: Colors.blue,
        //   ),
        // ),
        // const SizedBox(height: 16),
        Text(
          AppConstants.capturedStatusLabel, // Use constant
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
              () => DropdownButtonFormField<bool>(
            value: controller.isCaptured.value,
            decoration: customInputDecoration.copyWith(
              hintText: AppConstants.selectStatusHint, // Use constant
            ),
            items: const [
              DropdownMenuItem(value: true, child: Text(AppConstants.playerCapturedYes)),
              DropdownMenuItem(value: false, child: Text(AppConstants.playerCapturedNo)),
            ],
            onChanged: (bool? newValue) {
              if (newValue != null) {
                controller.isCaptured.value = newValue;
              }
            },
            dropdownColor: Colors.white,
            style: textTheme.bodyLarge?.copyWith(color: Colors.black),
            iconEnabledColor: Colors.blue,
          ),
        ),
      ],
    );
  }
}