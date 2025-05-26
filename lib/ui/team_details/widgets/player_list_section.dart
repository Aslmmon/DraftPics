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
        return Column(
          children:
              controller.players
                  .map(
                    (player) => PlayerListItem(
                      player: player,
                      textTheme: textTheme,
                      onEditPressed: () => controller.editPlayer(player),
                      onDeletePressed: () => controller.deletePlayer(player)
                    ),
                  )
                  .toList(),
        );
      }
    });
  }
}
