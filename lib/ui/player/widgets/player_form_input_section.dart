// lib/ui/player/widgets/player_form_input_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Needed for GetView if controller is used directly
import 'package:reutilizacao/ui/components/AppTextField.dart'; // Your AppTextField
import '../../../../utils/app_constants.dart'; // Constants
import '../player_form_controller.dart'; // Controller

class PlayerFormInputSection extends GetView<PlayerFormController> {
  final TextTheme textTheme;
  final InputDecoration customInputDecoration;

  const PlayerFormInputSection({
    super.key,
    required this.textTheme,
    required this.customInputDecoration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 32),
        Text(
          AppConstants.firstNameLabel, // Use constant
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        ReusableTextField(
          controller: controller.firstNameController,
          hintText: AppConstants.firstNameHint, // Use constant
          keyboardType: TextInputType.text,
          decoration: customInputDecoration,
        ),
        const SizedBox(height: 16),
        Text(
          AppConstants.lastNameLabel, // Use constant
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        ReusableTextField(
          controller: controller.lastNameController,
          hintText: AppConstants.lastNameHint, // Use constant
          keyboardType: TextInputType.text,
          decoration: customInputDecoration,
        ),
        const SizedBox(height: 16),
        Text(
          AppConstants.positionLabel, // Use constant
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        ReusableTextField(
          controller: controller.positionController,
          hintText: AppConstants.enterPositionHint, // Use constant
          keyboardType: TextInputType.text,
          decoration: customInputDecoration,
        ),
      ],
    );
  }
}