// lib/home_screen_ui.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reutilizacao/ui/components/AppTextField.dart';
import 'package:reutilizacao/ui/components/ReusableAlertDialog.dart';

import 'BottomSheetTeam.dart';
import 'controllers/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Teams',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black, size: 30),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useRootNavigator: true,
                builder: (context) => AddTeamBottomSheet(),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: ReusableTextField(
              // Assuming 'AppTextField' is the correct class name
              onChanged: (value) => controller.searchQuery.value = value,
              hintText: 'Search teams...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'My Teams',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: Obx(() {
              // --- Refined Empty/Loading State Messages ---
              if (controller.allTeams.isEmpty &&
                  controller.searchQuery.isEmpty) {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return const Center(
                  child: Text(
                    'No teams added yet! Tap the + icon to add your first team.',
                  ),
                );
              }
              if (controller.filteredTeams.isEmpty &&
                  controller.searchQuery.isNotEmpty) {
                // No results for the current search query
                return const Center(
                  child: Text('No teams found matching your search.'),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                itemCount: controller.filteredTeams.length,
                itemBuilder: (context, index) {
                  final team = controller.filteredTeams[index];
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
                            // --- Refined Image/Icon Display ---
                            Hero(tag: 1, child: Image.asset('images/team_image.png')),
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
                                    '${team.players.length} players',
                                    // Assuming 'playerCount' is available in your Team model
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey,
                                    ),
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
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
