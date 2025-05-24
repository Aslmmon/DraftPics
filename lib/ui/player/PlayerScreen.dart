import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reutilizacao/ui/components/AppTextField.dart'; // For Get.back() and future GetX integration

class AddPlayerScreen extends StatefulWidget {
  const AddPlayerScreen({super.key});

  @override

  State<AddPlayerScreen> createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends State<AddPlayerScreen> {
  // TextEditingControllers for each input field
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  void _addPlayer() {
    // This is where you would typically handle saving the player data
    // For now, let's just print the values
    print('Add Player Button Pressed!');
    print('First Name: ${_firstNameController.text}');
    print('Last Name: ${_lastNameController.text}');
    print('Position: ${_positionController.text}');

    // You would then typically navigate back or show a success message
    Get.back(); // Go back to the previous screen (Team Details)
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    // Define consistent InputDecoration for the ReusableTextFields
    // These match the style from your Login UI (filled, no border)
    final InputDecoration customInputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.grey[200],
      // Light grey background
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
        borderSide: BorderSide.none, // No visible border line
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      hintStyle: textTheme.bodyLarge?.copyWith(
        color: Colors.grey[500], // Hint text color
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black, size: 28),
          // Close 'X' icon
          onPressed: () {
            Get.back(); // Use Get.back() for GetX navigation
          },
        ),
        title: Text(
          'Add Player',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        // Use Stack to position the button at the bottom
        children: [
          SingleChildScrollView(
            // For scrollability if keyboard appears
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // Align labels to start
              children: <Widget>[
                const SizedBox(height: 32),
                // Spacing from app bar

                // First Name Field
                Text(
                  'First Name',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold, // Slightly bold for labels
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                ReusableTextField(
                  controller: _firstNameController,
                  hintText: 'Enter firstname',
                  keyboardType: TextInputType.text,
                  // Apply the custom decoration directly here
                  // The ReusableTextField allows overriding 'border' and 'fillColor'
                  fillColor: customInputDecoration.fillColor,
                  border: customInputDecoration.border,
                ),
                const SizedBox(height: 16),
                // Spacing between fields

                // Last Name Field
                Text(
                  'Last Name',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                ReusableTextField(
                  controller: _lastNameController,
                  hintText: 'Enter lastname',
                  keyboardType: TextInputType.text,
                  fillColor: customInputDecoration.fillColor,
                  border: customInputDecoration.border,
                ),
                const SizedBox(height: 16),

                // Position Field
                Text(
                  'Position',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                ReusableTextField(
                  controller: _positionController,
                  hintText: 'Enter position',
                  keyboardType: TextInputType.text,
                  fillColor: customInputDecoration.fillColor,
                  border: customInputDecoration.border,
                ),

                // Add some padding at the bottom so the content isn't covered by the button
                const SizedBox(height: 100),
              ],
            ),
          ),

          // "Add Player" Button fixed at the bottom
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: ElevatedButton(
              onPressed: _addPlayer,
              // Call the method to handle player addition
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[300],
                // A lighter blue as per design
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0, // No shadow for this button
              ),
              child: Text(
                'Add Player',
                style: textTheme.titleMedium?.copyWith(
                  // Use a suitable text style
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
