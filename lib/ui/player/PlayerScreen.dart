import 'package:draftpics/ui/player/player_form_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reutilizacao/ui/components/AppTextField.dart';

class PlayerFormScreen extends GetView<PlayerFormController> {
  const PlayerFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    final InputDecoration customInputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      hintStyle: textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
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
        // Use Obx to dynamically update the AppBar title
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
                  controller: controller.firstNameController,
                  // Use controller's TextEditingController
                  hintText: 'Enter firstname',
                  keyboardType: TextInputType.text,
                  fillColor: customInputDecoration.fillColor,
                  border: customInputDecoration.border,
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
                  // Use controller's TextEditingController
                  hintText: 'Enter lastname',
                  keyboardType: TextInputType.text,
                  fillColor: customInputDecoration.fillColor,
                  border: customInputDecoration.border,
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
                  // Use controller's TextEditingController
                  hintText: 'Enter position',
                  keyboardType: TextInputType.text,
                  fillColor: customInputDecoration.fillColor,
                  border: customInputDecoration.border,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Obx(
              () => ElevatedButton(
                // Use Obx to dynamically update the button text and loading state
                onPressed:
                    controller.isLoading.value
                        ? null
                        : () => controller.savePlayer(),
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
