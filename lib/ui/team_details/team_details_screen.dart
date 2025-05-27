// lib/ui/team_details/team_details_screen.dart (The main screen file)
import 'package:draftpics/ui/team_details/team_details_controller.dart';
import 'package:draftpics/ui/team_details/widgets/player_list_section.dart';
import 'package:draftpics/ui/team_details/widgets/players_heading_section.dart';
import 'package:draftpics/ui/team_details/widgets/team_header_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Import new components
import '../../data/model/TeamModel.dart';
import '../player/widgets/add_player_button.dart';

import '../../utils/app_constants.dart'; // Import constants

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
          AppConstants.teamDetailsScreenTitle, // Use constant
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        // Show loading indicator if team data is not yet available/initialized
        if (controller.team.value.id == null ||
            controller.team.value.id!.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final Team team = controller.team.value;

        return Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TeamHeaderSection(team: team, textTheme: textTheme),
                const SizedBox(height: 24),
                PlayersHeadingSection(textTheme: textTheme),
                const SizedBox(height: 16),
                Expanded(child: PlayerListSection(textTheme: textTheme)),


              ],
            ),
          ],
        );
      }),
      floatingActionButton: // NEW: CSV Upload Button for Players
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                onPressed: (){
                controller.goToAddPlayer();
              },
              child: Icon(Icons.plus_one_outlined, color: Colors.blue),),
              SizedBox(height: 20),
              Obx(
                      () => IconButton(
              icon:
                  controller.isUploadingCsv.value
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.blue,
                          strokeWidth: 2,
                        ),
                      )
                      : const Icon(Icons.upload_file, color: Colors.blue),
              onPressed:
                  controller.isUploadingCsv.value
                      ? null // Disable while uploading
                      : () => controller.pickAndUploadPlayersCsv(),
              tooltip: 'Upload Players from CSV',
                      ),
                    ),
            ],
          ), // End of Obx
    );
  }
}
