import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reutilizacao/ui/components/AppButton.dart';
import '../../../utils/app_constants.dart'; // Import constants
import '../../team_details/team_details_controller.dart';

class AddPlayerButton extends GetView<TeamDetailsController> {
  const AddPlayerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: ReusableButton(
        onPressed: () => controller.goToAddPlayer(),
        text: AppConstants.addPlayerButton,
        backgroundColor: Colors.blue,
      ),
    );
  }
}
