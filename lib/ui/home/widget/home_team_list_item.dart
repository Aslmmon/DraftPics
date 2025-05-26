import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () => controller.goToTeamDetails(team),
        child: Container(
          padding: const EdgeInsets.all(16),
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
                radius: 40,
                backgroundColor: Colors.grey[200],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset("images/logo.png"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      // --- Using team.playerCount ---
                      '$count players',
                      // Assuming 'playerCount' is available in your Team model
                      style: textTheme.bodyMedium?.copyWith(color: Colors.grey),
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
                    onYesPressed: () {
                      controller.deleteTeam(team);
                      Get.back();
                    },
                    onNoPressed: () {
                      Get.back();
                    },
                  );
                },
                icon: Icon(Icons.delete_forever_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
