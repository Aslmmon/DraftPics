// lib/ui/team_details/widgets/player_list_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_constants.dart';
import '../../team_details/team_details_controller.dart';
import '../../team_details/widgets/player_list_item.dart';

class PlayerListSection extends GetView<TeamDetailsController> {
  final TextTheme textTheme;

  const PlayerListSection({super.key, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Use filteredPlayers instead of players
      if (controller.filteredPlayers.isEmpty) {
        // If there are players but no players match the filter
        if (controller.players.isNotEmpty && controller.selectedJerseyNumber.value != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'No players found with Jersey #${controller.selectedJerseyNumber.value}.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        // If there are no players at all
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              AppConstants.noPlayersFoundForTeam,
              textAlign: TextAlign.center,
            ),
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: SizedBox(
            // You might want to adjust this height dynamically or remove it if ListView is in Expanded
            // height: 500, // Consider if this fixed height is still appropriate
            child: ListView.builder(
              shrinkWrap: false, // Ensure this works with Expanded parent
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              itemCount: controller.filteredPlayers.length, // Use filteredPlayers
              itemBuilder: (context, index) {
                final player = controller.filteredPlayers[index]; // Use filteredPlayers
                return PlayerListItem(
                  player: player,
                  textTheme: textTheme,
                  onEditPressed: () => controller.editPlayer(player),
                  onDeletePressed:
                      () async => await controller.deletePlayer(player),
                );
              },
            ),
          ),
        );
      }
    });
  }
}