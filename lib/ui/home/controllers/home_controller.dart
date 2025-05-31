import 'dart:async'; // Required for StreamSubscription
import 'dart:developer' as Logger;

import 'package:get/get.dart';

import '../../../data/model/PlayerModel.dart';
import '../../../data/model/TeamModel.dart';
import '../../../data/services/FirestoreService.dart';
import '../../../routes/app_routes.dart';

class HomeController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  var allTeams = <Team>[].obs;
  var allPlayers = <Player>[].obs; // Populated by Collection Group Query
  var searchResults = <Team>[].obs; // Changed to RxList<Team>
  var playerCounts =
      <String, int>{}.obs; // Map to store player counts per team

  var searchQuery = ''.obs;

  var isLoading = false.obs; // Observable for loading state (e.g., for addTeam)

  StreamSubscription<List<Team>>? _teamsStreamSubscription;
  StreamSubscription<List<Player>>? _playersStreamSubscription;

  late Worker _searchWorker;

  @override
  void onInit() {
    super.onInit();
    // Listen to changes in all teams
    _teamsStreamSubscription = _firestoreService.getTeams().listen((teams) {
      allTeams.value = teams;
      _filterResults(); // Re-filter whenever teams update
    });

    // Listen to changes in all players (requires Collection Group Query in FirestoreService)
    // _playersStreamSubscription = _firestoreService.getAllPlayers().listen((
    //     players,
    //     ) {
    //   allPlayers.value = players;
    //   _updatePlayerCounts(); // Update counts when players change
    //   _filterResults(); // Re-filter whenever players update
    // });

    // Debounce search query to avoid excessive filtering on every keystroke
    _searchWorker = debounce(
      searchQuery,
          (_) => _filterResults(), // Call _filterResults
      time: const Duration(milliseconds: 300),
    );
  }

  // Updates the count of players for each team
  void _updatePlayerCounts() {
    final Map<String, int> counts = {};
    for (var player in allPlayers) {
      // Player.teamId should ideally never be null if data is consistent
      if (player.teamId != null) {
        counts[player.teamId!] = (counts[player.teamId!] ?? 0) + 1;
      }
    }
    playerCounts.value = counts; // Update the observable map
  }

  // Filters teams based on search query, considering both team names and player names
  void _filterResults() {
    final query = searchQuery.value.toLowerCase().trim();
    final Set<Team> uniqueFilteredTeams = {}; // Use a Set to store unique teams and avoid duplicates

    if (query.isEmpty) {
      // If query is empty, show all teams
      uniqueFilteredTeams.addAll(allTeams);
    } else {
      // 1. Filter teams by name directly
      uniqueFilteredTeams.addAll(
        allTeams.where((team) => team.name.toLowerCase().contains(query)),
      );

      // 2. Find players matching the query
      final matchingPlayers = allPlayers.where(
            (player) =>
        player.firstName.toLowerCase().contains(query) ||
            player.lastName.toLowerCase().contains(query),
      );

      // 3. Collect team IDs from matching players
      // Assuming player.teamId is guaranteed to be non-null for filtering purposes here
      final Set<String> teamIdsWithMatchingPlayers =
      matchingPlayers.map((player) => player.teamId).toSet();

      // 4. Add teams corresponding to matching players
      uniqueFilteredTeams.addAll(
        allTeams.where(
              (team) =>
          team.id != null && teamIdsWithMatchingPlayers.contains(team.id),
        ),
      );
    }

    // Convert the Set back to a List and assign to searchResults
    // Sort the results, e.g., by creation time (newest first)
    searchResults.value =
    uniqueFilteredTeams.toList()..sort((a, b) {
      // Handle cases where creationTime might be null (e.g., old data without it)
      // Null values will be considered "older" (placed at the end for descending sort)
      if (a.creationTime == null && b.creationTime == null) return 0;
      if (a.creationTime == null) return 1; // b has time, a doesn't, so a goes after b
      if (b.creationTime == null) return -1; // a has time, b doesn't, so b goes after a

      // Descending order (newest first): b.compareTo(a)
      return b.creationTime!.compareTo(a.creationTime!);
    });
  }

  // Navigates to the team details screen, passing the selected team object
  void goToTeamDetails(Team team) =>
      Get.toNamed(AppRoutes.teamDetails, arguments: team);

  // Deletes a team from Firestore
  Future<void> deleteTeam(Team team) async {
    isLoading.value = true; // Set loading state
    try {
      if (team.id != null) {
        await _firestoreService.deleteTeam(team.id!);
        Get.snackbar(
          'Success',
          'Team "${team.name}" deleted successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.actionTextColor,
        );
      } else {
        Get.snackbar(
          'Error',
          'Team ID is missing, cannot delete.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.actionTextColor,
        );
      }
    } catch (e) {
      Logger.log('Error deleting team: $e'); // Use your Logger if you have one
      Get.snackbar(
        'Error',
        'Failed to delete team: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.snackBarTheme.backgroundColor,
        colorText: Get.theme.snackBarTheme.actionTextColor,
      );
    } finally {
      isLoading.value = false; // Reset loading state
    }
  }

  @override
  void onClose() {
    _teamsStreamSubscription?.cancel();
    _playersStreamSubscription?.cancel();
    _searchWorker.dispose();
    super.onClose();
  }
}