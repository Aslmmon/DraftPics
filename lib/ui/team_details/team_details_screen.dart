// lib/team_details_screen_ui.dart
import 'package:draftpics/ui/team_details/team_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/model/PlayerModel.dart';
import '../../data/model/TeamModel.dart';

class TeamDetailsScreen extends GetView<TeamDetailsController> {
  const TeamDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          'Team Details',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        // Use Obx to react to changes in controller.team and controller.players
        // 2. Check if the team object has been initialized in the controller
        // This handles cases where Get.arguments might be null or not a Team object.
        if (controller.team.value.id.isEmpty) {
          // You could show a loading indicator or an error message here
          return const Center(child: CircularProgressIndicator());
        }

        final Team team = controller.team.value;

        return Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Team Header Section
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Image.network(
                            'https://via.placeholder.com/150x100?text=Team+Image',
                            width: 150,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          team.name,
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Division N/A',
                          style: textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Players Heading
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Players',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Player List - Now observed directly from the controller
                  if (controller
                      .players
                      .isEmpty) // Check if players list is empty
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text(
                          'No players found for this team. Add some!',
                        ),
                      ),
                    )
                  else
                    Column(
                      children:
                          controller.players
                              .map(
                                (player) => PlayerListItem(
                                  player: player,
                                  textTheme: textTheme,
                                ),
                              )
                              .toList(),
                    ),
                  const SizedBox(height: 100),
                ],
              ),
            ),

            // "Add Player" Button
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: ElevatedButton.icon(
                onPressed: () {
                  controller.goToAddPlayer(); // Call controller method
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Player'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 4,
                ),
              ),
            ),
          ],
        );
      }), // End of Obx
    );
  }
}

// PlayerListItem (unchanged - provided in previous responses)
class PlayerListItem extends StatelessWidget {
  final Player player;
  final TextTheme textTheme;

  const PlayerListItem({
    super.key,
    required this.player,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        children: [
          // CircleAvatar(
          //   radius: 28,
          //   backgroundColor: Colors.grey[200],
          //   backgroundImage:
          //       player.avatarUrl != null
          //           ? NetworkImage(player.avatarUrl!)
          //           : null,
          //   child:
          //       player.avatarUrl == null
          //           ? Icon(Icons.person, size: 30, color: Colors.blue[700])
          //           : null,
          // ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${player.firstName} ${player.lastName}',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  player.position,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.grey),
            onPressed: () {
              // You can call a controller method here for editing too
              // Get.find<TeamDetailsController>().editPlayer(player);
              print('Edit player ${player.firstName} pressed!');
            },
          ),
        ],
      ),
    );
  }
}
