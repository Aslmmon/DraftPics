// lib/ui/player/player_form_screen.dart (The main screen file)
import 'package:draftpics/ui/player/player_form_controller.dart';
import 'package:draftpics/ui/player/widgets/InputDecoration.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Import new components
import 'widgets/player_form_input_section.dart';
import 'widgets/player_form_dropdowns_section.dart';
import 'widgets/player_form_save_button.dart';

// Re-use existing constants and models
import '../../utils/app_constants.dart'; // Constants

class PlayerFormScreen extends GetView<PlayerFormController> {
  const PlayerFormScreen({super.key});



  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final InputDecoration customInputDecoration = buildCustomInputDecoration(textTheme);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black, size: 28),
          onPressed: () {
            Get.back();
          },
        ),
        title: Obx(
              () => Text(
            controller.isEditing.value
                ? AppConstants.editPlayerScreenTitle // Use constant
                : AppConstants.addPlayerScreenTitle, // Use constant
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
                left: 24.0, right: 24.0, bottom: 100), // Add bottom padding for button
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                PlayerFormInputSection(
                  textTheme: textTheme,
                  customInputDecoration: customInputDecoration,
                ),
                PlayerFormDropdownsSection(
                  textTheme: textTheme,
                  customInputDecoration: customInputDecoration,
                ),
                const SizedBox(height: 24), // Space before bottom button
              ],
            ),
          ),
          // Positioned Save Button
          const PlayerFormSaveButton(),
        ],
      ),
    );
  }
}