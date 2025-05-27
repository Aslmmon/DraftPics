// lib/ui/team_details/widgets/player_list_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_constants.dart'; // Adjust path
import '../../team_details/team_details_controller.dart';
import '../../team_details/widgets/player_list_item.dart'; // Adjust path

class PlayerListSection extends GetView<TeamDetailsController> {
  final TextTheme textTheme;

  const PlayerListSection({super.key, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.players.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              AppConstants.noPlayersFoundForTeam, // Use constant
              textAlign: TextAlign.center,
            ),
          ),
        );
      } else {

        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: SizedBox(
            height: 500,
            child: ListView.builder(
              shrinkWrap: false,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              itemCount: controller.players.length,
              itemBuilder: (context, index) {
                final  player = controller.players[index];
                return PlayerListItem(
                    player: player,
                    textTheme: textTheme,
                    onEditPressed: () => controller.editPlayer(player),
                    onDeletePressed: () async => await controller.deletePlayer(player)
                );
                // Should not happen
              },
            ),
          ),
        );

      }
    });
  }
}
