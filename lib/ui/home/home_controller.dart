import 'dart:async'; // Required for StreamSubscription

import 'package:get/get.dart';

import '../../data/model/TeamModel.dart';
import '../../data/services/FirestoreService.dart';
import '../../routes/app_routes.dart';

class HomeController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  var allTeams = <Team>[].obs;
  var filteredTeams = <Team>[].obs;
  var searchQuery = ''.obs;

  StreamSubscription<List<Team>>? _teamsStreamSubscription;
  late Worker _searchWorker;

  @override
  void onInit() {
    super.onInit();
    _teamsStreamSubscription = _firestoreService.getTeams().listen((teams) {
      allTeams.value = teams;
      _filterTeams();
    });

    _searchWorker = debounce(
      searchQuery,
      (_) => _filterTeams(),
      time: const Duration(milliseconds: 300), // Wait 300ms after last change
    );
  }

  // Method to filter teams based on search query
  void _filterTeams() {
    if (searchQuery.value.isEmpty) {
      filteredTeams.value = allTeams; // If empty, show all teams
    } else {
      // Filter teams where name contains the search query (case-insensitive)
      filteredTeams.value =
          allTeams.where((team) {
            return team.name.toLowerCase().contains(
              searchQuery.value.toLowerCase(),
            );
          }).toList();
    }
  }

  void goToTeamDetails(Team team) {
    Get.toNamed(AppRoutes.teamDetails, arguments: team);
  }

  // Method for navigating to Add Team (if you create that screen)
  void goToAddTeam() {
    print('Navigate to Add Team screen');
    // Get.toNamed(AppRoutes.addTeam); // Example
  }

  @override
  void onClose() {
    _teamsStreamSubscription?.cancel();
    _searchWorker.dispose();
    super.onClose();
  }
}
