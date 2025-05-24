// Method to show the Add Team Bottom Sheet
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:reutilizacao/ui/components/AppTextField.dart';

import 'home_controller.dart';

void showAddTeamBottomSheet(BuildContext context, HomeController controller) {
  final TextEditingController newTeamNameController = TextEditingController();
  final formKey = GlobalKey<FormState>(); // Key for form validation

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor, // Use theme's canvas color
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add New Team',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  'Team Name',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ReusableTextField(
                  controller: newTeamNameController,
                  hintText: 'Enter team name',
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                const SizedBox(height: 24),
                // Use Obx to react to the controller's isLoading state
                Obx(
                  () => ElevatedButton(
                    onPressed:
                        controller
                                .isLoading
                                .value // Disable button when loading
                            ? null
                            : () {
                              if (formKey.currentState!.validate()) {
                                // Call the controller method to add the team
                                controller.addTeam(
                                  newTeamNameController.text.trim(),
                                );
                              }
                            },
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
                        controller
                                .isLoading
                                .value // Show loading indicator
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : Text(
                              'Add Team',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  ).whenComplete(() {
    // Dispose the TextEditingController when the bottom sheet is closed
    newTeamNameController.dispose();
  });
}
