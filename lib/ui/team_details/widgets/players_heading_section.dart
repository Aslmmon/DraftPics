// lib/ui/team_details/widgets/players_heading_section.dart
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import '../../../../../utils/app_constants.dart';
import '../team_details_controller.dart'; // Import constants

class PlayersHeadingSection extends GetView<TeamDetailsController> {
  final TextTheme textTheme;

  const PlayersHeadingSection({super.key, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallDevice = screenWidth < AppConstants.smallDeviceBreakpoint;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Obx(() {
        final List<String> jerseyNumbers = controller.uniqueJerseyNumbers;
        final bool showDropdown =
            jerseyNumbers.length > 1 ||
            (jerseyNumbers.length == 1 &&
                controller.players.length > 1 &&
                controller.players.first.jerseyNumber != null);

        return Column(
          children: [
            Text(
              AppConstants.playersHeading, // Use constant
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: isSmallDevice ? 16 : 24,
              ),
            ),
            if (showDropdown) // Conditionally show the dropdown
              DropdownButton<String?>(
                value: controller.selectedJerseyNumber.value,
                hint: const Text('Filter by Jersey #'),
                onChanged: (String? newValue) {
                  controller.setJerseyNumberFilter(newValue);
                },

                items: [
                  const DropdownMenuItem<String?>(
                    value: null, // Represents "All"
                    child: Text('All Jersey Numbers',style: TextStyle(fontSize: 14),),
                  ),
                  ...jerseyNumbers.map<DropdownMenuItem<String>>((
                    String number,
                  ) {


                    return DropdownMenuItem<String>(
                      value: number,
                      child: Text('Jersey #$number',style: TextStyle(fontSize: 12),),
                    );
                  }).toList(),
                ],
              ),
          ],
        );
      }),
    );
  }
}
