// lib/ui/home/widget/home_team_list_item.dart
import 'package:draftpics/utils/app_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reutilizacao/ui/components/ReusableAlertDialog.dart';

import '../../../data/model/TeamModel.dart';
import '../controllers/home_controller.dart';

class TeamListItem extends StatelessWidget {
  const TeamListItem({
    super.key,
    required this.controller,
    required this.team,
    required this.textTheme,
    required this.count,
  });

  final HomeController controller;
  final Team team;
  final TextTheme textTheme;
  final int count;

  @override
  Widget build(BuildContext context) {
    // Get the current screen width
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallDevice = screenWidth < AppConstants.smallDeviceBreakpoint;

    // Adjust sizes based on whether it's a small device
    final double avatarRadius = isSmallDevice ? 20.0 : 40.0;
    final double horizontalSpacing = isSmallDevice ? 12.0 : 16.0;
    final double verticalPadding = isSmallDevice ? 2.0 : 8.0;
    final double containerPadding = isSmallDevice ? 12.0 : 16.0;
    final double iconSize = isSmallDevice ? 20.0 : 24.0; // For delete icon

    final TextStyle? titleStyle =
        isSmallDevice
            ? textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 15,
            )
            : textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            );

    final TextStyle? subtitleStyle =
        isSmallDevice
            ? textTheme.bodySmall?.copyWith(color: Colors.grey)
            : textTheme.bodyMedium?.copyWith(color: Colors.grey);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: InkWell(
        onTap: () => controller.goToTeamDetails(team),
        child: Container(
          padding: EdgeInsets.all(containerPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: avatarRadius, // Adjusted size
                backgroundColor: Colors.grey[200],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset("assets/images/logo.png"),
                ),
              ),
              SizedBox(width: horizontalSpacing), // Adjusted spacing
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.name,
                      style: titleStyle, // Adjusted style
                    ),
                    Text(
                      '$count players',
                      style: subtitleStyle, // Adjusted style
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  ReusableAlertDialog.show(
                    title: 'Delete Team?',
                    content:
                        'Are you sure you want to delete this team ? \n This action cannot be undone.',
                    yesText: 'Delete',
                    noText: 'Cancel',
                    onYesPressed: () async {
                      await controller.deleteTeam(team);
                      Get.back();
                    },
                    onNoPressed: () {
                      Get.back();
                    },
                  );
                },
                icon: Icon(
                  Icons.delete_forever_outlined,
                  size: iconSize, // Adjusted size
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
