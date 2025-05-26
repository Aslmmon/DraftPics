import 'dart:async'; // Required for StreamSubscription

import 'package:get/get.dart';

import '../../../data/model/PlayerModel.dart';
import '../../../data/model/TeamModel.dart';
import '../../../data/services/FirestoreService.dart';
import '../../../routes/app_routes.dart';

class HomeController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  var allTeams = <Team>[].obs;
  var allPlayers = <Player>[].obs; // NEW: All players
  var searchResults = <Team>[].obs; // <<< Changed to RxList<Team>
  var playerCounts =
      <String, int>{}.obs; // NEW: Map to store player counts per team

  var searchQuery = ''.obs;

  var isLoading =
      false.obs; // Observable for loading state of addTeam operation

  StreamSubscription<List<Team>>? _teamsStreamSubscription;
  StreamSubscription<List<Player>>?
  _playersStreamSubscription; // NEW: Player stream

  late Worker _searchWorker;

  @override
  void onInit() {
    super.onInit();
    _teamsStreamSubscription = _firestoreService.getTeams().listen((teams) {
      allTeams.value = teams;
      _filterResults(); // Filter whenever teams or players update
    });

    _playersStreamSubscription = _firestoreService.getAllPlayers().listen((
      players,
    ) {
      allPlayers.value = players;
      _updatePlayerCounts(); // NEW: Update counts when players change
      _filterResults(); // Filter whenever teams or players update
    });

    _searchWorker = debounce(
      searchQuery,
      (_) => _filterResults(), // Call _filterResults
      time: const Duration(milliseconds: 300),
    );
  }

  void _updatePlayerCounts() {
    final Map<String, int> counts = {};
    for (var player in allPlayers) {
      if (player.teamId != null) {
        counts[player.teamId!] = (counts[player.teamId!] ?? 0) + 1;
      }
    }
    playerCounts.value = counts; // Update the observable map
  }

  // NEW: Filter method for combined results
  void _filterResults() {
    final query = searchQuery.value.toLowerCase().trim();
    final Set<Team> uniqueFilteredTeams = {}; // Use a Set to store unique teams

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
      final Set<String> teamIdsWithMatchingPlayers =
          matchingPlayers
              .map((player) => player.teamId) // Assuming teamId is not null
              .toSet();

      // 4. Add teams corresponding to matching players
      uniqueFilteredTeams.addAll(
        allTeams.where(
          (team) =>
              team.id != null && teamIdsWithMatchingPlayers.contains(team.id),
        ),
      );
    }

    // Convert the Set back to a List and assign to searchResults
    // You might want to sort these teams, e.g., alphabetically
    searchResults.value =
        uniqueFilteredTeams.toList()..sort((a, b) {
          // Handle cases where creationTime might be null (e.g., old data without it)
          // Null values will be considered "older" (placed at the end for descending sort)
          if (a.creationTime == null && b.creationTime == null) return 0;
          if (a.creationTime == null) return 1; // b is newer, a goes after b
          if (b.creationTime == null) return -1; // a is newer, b goes after a

          // Descending order: b.compareTo(a) means newest first
          return b.creationTime!.compareTo(a.creationTime!);
        });
  }

  void goToTeamDetails(Team team) =>
      Get.toNamed(AppRoutes.teamDetails, arguments: team);

  void deleteTeam(Team team) =>
      _firestoreService.deleteTeam(team.id.toString());

  @override
  void onClose() {
    _teamsStreamSubscription?.cancel();
    _playersStreamSubscription?.cancel(); // NEW: Cancel player stream
    _searchWorker.dispose();
    super.onClose();
  }
}
