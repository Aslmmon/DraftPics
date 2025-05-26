// lib/home_screen_ui.dart
import 'package:draftpics/ui/home/widget/home_team_list_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reutilizacao/ui/components/AppTextField.dart';
import '../../data/model/TeamModel.dart';
import '../../utils/app_constants.dart';
import 'BottomSheetTeam.dart';
import 'controllers/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

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
              hintText: 'Search teams or Player .. ',
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
              if (controller.searchResults.isEmpty &&
                  controller.searchQuery.value.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      AppConstants.noTeamsAddedYet,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              } else if (controller.searchResults.isEmpty &&
                  controller.searchQuery.value.isNotEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      AppConstants.noTeamsFoundSearch,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                itemCount: controller.searchResults.length,
                itemBuilder: (context, index) {
                  final Team team = controller.searchResults[index];
                  final int count = controller.playerCounts[team.id] ?? 0; // Default to 0 if not found

                  return TeamListItem(
                    controller: controller,
                    team: team,
                    textTheme: textTheme,
                    count: count,
                  );
                  // Should not happen
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
