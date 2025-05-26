import 'package:draftpics/ui/player/player_form_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reutilizacao/ui/components/AppTextField.dart'; // Assuming AppTextField is your reusable widget
import '../../data/model/PlayerModel.dart'; // Import the PlayerModel for Gender enum

class PlayerFormScreen extends GetView<PlayerFormController> {
  const PlayerFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    final InputDecoration customInputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue),
      ),
      focusedBorder: OutlineInputBorder(
        // Define focused border for consistency
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        // Define enabled border for consistency
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        // Define error border for consistency
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        // Define focused error border
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red[700]!, width: 2),
      ),
      // --- Disabling Hover: ---
      hoverColor: Colors.transparent,
      // Set hover color to transparent
      // You might also need to ensure that the fillColor, border, etc.,
      // are not using MaterialStateProperty.resolveWith where hover state is handled.
      // AppTextField's internal implementation needs to respect this.
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      hintStyle: textTheme.bodyLarge?.copyWith(color: Colors.blue[500]),
    );

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
            controller.isEditing.value ? 'Edit Player' : 'Add Player',
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 32),
                Text(
                  'First Name',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                ReusableTextField(
                  // Using AppTextField based on your import
                  controller: controller.firstNameController,
                  hintText: 'firstname',
                  keyboardType: TextInputType.text,
                  decoration: customInputDecoration, // Pass the decoration
                ),
                const SizedBox(height: 16),
                Text(
                  'Last Name',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                ReusableTextField(
                  controller: controller.lastNameController,
                  hintText: 'lastname',
                  keyboardType: TextInputType.text,
                  decoration: customInputDecoration,
                ),
                const SizedBox(height: 16),
                Text(
                  'Position',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                ReusableTextField(
                  controller: controller.positionController,
                  hintText: 'Enter position',
                  keyboardType: TextInputType.text,
                  // Changed to text as positions can be like 'GK', 'ST'
                  decoration: customInputDecoration,
                ),

                const SizedBox(height: 16),

                // --- NEW: Gender Dropdown ---
                Text(
                  'Gender',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => DropdownButtonFormField<Gender>(
                    value: controller.selectedGender.value,
                    decoration: customInputDecoration.copyWith(
                      hintText: 'Select Gender', // Hint specific to dropdown
                    ),
                    items: const [
                      DropdownMenuItem(value: Gender.male, child: Text('Male')),
                      DropdownMenuItem(
                        value: Gender.female,
                        child: Text('Female'),
                      ),
                    ],
                    onChanged: (Gender? newValue) {
                      if (newValue != null) {
                        controller.selectedGender.value = newValue;
                      }
                    },
                    dropdownColor: Colors.white,
                    // Ensure dropdown background is white
                    style: textTheme.bodyLarge?.copyWith(color: Colors.black),
                    // Text style for selected item
                    iconEnabledColor:
                        Colors.blue, // Color of the dropdown arrow
                  ),
                ),

                const SizedBox(height: 16),

                // --- NEW: isCaptured Dropdown ---
                Text(
                  'Captured Status',
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
                      hintText: 'Select Status',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: true,
                        child: Text('Yes (Captured)'),
                      ),
                      DropdownMenuItem(
                        value: false,
                        child: Text('No (Not Captured)'),
                      ),
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

                const SizedBox(height: 100),
                // More space to prevent button overlapping
              ],
            ),
          ),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Obx(
              () => ElevatedButton(
                onPressed:
                    controller.isLoading.value
                        ? null
                        : () =>
                            controller.savePlayer()..whenComplete(() {
                              Get.back();
                            }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[300],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child:
                    controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                          controller.isEditing.value
                              ? 'Save Changes'
                              : 'Add Player',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
