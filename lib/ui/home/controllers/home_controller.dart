import 'dart:async';
import 'dart:convert';
import 'dart:developer' as Logger; // Renamed to Logger for clarity
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/model/PlayerModel.dart'; // Ensure these paths are correct
import '../../../data/model/TeamModel.dart';
import '../../../data/services/FirestoreService.dart';
import '../../../routes/app_routes.dart';

class HomeController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  // --- Observables ---
  final RxList<Team> allTeams = <Team>[].obs;
  final RxList<Player> allPlayers = <Player>[].obs;
  final RxList<Team> searchResults = <Team>[].obs;
  final RxMap<String, int> playerCounts = <String, int>{}.obs;

  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs; // For individual operations like deleteTeam
  final RxBool isProcessingLargeOperation = false.obs; // For deleteAllData, syncDataFromSheets

  // --- Stream Subscriptions ---
  StreamSubscription<List<Team>>? _teamsStreamSubscription;
  StreamSubscription<List<Player>>? _playersStreamSubscription;

  // --- GetX Worker ---
  late Worker _searchDebounceWorker; // Renamed for clarity

  @override
  void onInit() {
    super.onInit();
    _initTeamAndPlayerListeners();
    _initSearchDebounce();
  }

  /// Initializes listeners for teams and players data from Firestore.
  void _initTeamAndPlayerListeners() {
    _teamsStreamSubscription = _firestoreService.getTeams().listen((teams) {
      allTeams.value = teams;
      _filterResults(); // Re-filter whenever teams update
    }, onError: (error) {
      Logger.log('Error listening to teams: $error');
      _showErrorSnackbar('Data Fetch Error', 'Failed to load teams: $error');
    });

    _playersStreamSubscription = _firestoreService.getAllPlayers().listen((players) {
      allPlayers.value = players.reversed.toList();
      _updatePlayerCounts();
      _filterResults(); // Re-filter whenever players update
    }, onError: (error) {
      Logger.log('Error listening to players: $error');
      _showErrorSnackbar('Data Fetch Error', 'Failed to load players: $error');
    });
  }

  /// Sets up a debounce worker for the search query.
  void _initSearchDebounce() {
    _searchDebounceWorker = debounce(
      searchQuery,
          (_) => _filterResults(),
      time: const Duration(milliseconds: 300),
    );
  }

  /// Updates the count of players for each team.
  void _updatePlayerCounts() {
    final Map<String, int> counts = {};
    for (var player in allPlayers) {
      if (player.teamId != null) {
        counts[player.teamId!] = (counts[player.teamId!] ?? 0) + 1;
      }
    }
    playerCounts.value = counts;
  }

  /// Deletes all teams and their associated players from Firestore.
  Future<void> deleteAllData() async {
    if (_isOperationInProgress()) return;


    final bool? confirm = await _showConfirmationDialog(
      Get.context!,
      'Confirm Deletion',
      'Are you sure you want to delete ALL teams and ALL players? This action cannot be undone.',
      confirmButtonText: 'Delete All',
      confirmButtonColor: Colors.red,
    );

    if (confirm != true) {
      Logger.log('Deletion cancelled by user.');
      return;
    }

    _setLargeOperationLoading(true, 'Deleting Data', 'Initiating deletion of all teams and players...');
    try {
      await _firestoreService.deleteAllTeamsAndPlayers();
      _showSuccessSnackbar('Deletion Complete', 'All teams and players have been successfully deleted.');
    } catch (e) {
      Logger.log('Error deleting all data: $e');
      _showErrorSnackbar('Deletion Error', 'Failed to delete all data: ${e.toString()}');
    } finally {
      _setLargeOperationLoading(false);
    }
  }

  /// Filters teams based on search query, considering both team names and player names.
  void _filterResults() {
    final query = searchQuery.value.toLowerCase().trim();
    final Set<Team> uniqueFilteredTeams = {};

    if (query.isEmpty) {
      uniqueFilteredTeams.addAll(allTeams);
    } else {
      // Filter teams by name directly
      uniqueFilteredTeams.addAll(
        allTeams.where((team) => team.name.toLowerCase().contains(query)),
      );

      // Find players matching the query
      final matchingPlayers = allPlayers.where(
            (player) =>
        player.firstName.toLowerCase().contains(query) ||
            player.lastName.toLowerCase().contains(query),
      );

      // Collect unique team IDs from matching players
      final Set<String> teamIdsWithMatchingPlayers =
      matchingPlayers.map((player) => player.teamId!).whereType<String>().toSet(); // Ensure non-null

      // Add teams corresponding to matching players
      uniqueFilteredTeams.addAll(
        allTeams.where((team) => team.id != null && teamIdsWithMatchingPlayers.contains(team.id)),
      );
    }
    searchResults.value = uniqueFilteredTeams.toList();
  }

  /// Navigates to the team details screen, passing the selected team object.
  void goToTeamDetails(Team team) {
    Get.toNamed(AppRoutes.teamDetails, arguments: team);
  }

  /// Deletes a specific team.
  Future<void> deleteTeam(Team team) async {
    if (isLoading.value) return; // Prevent multiple concurrent small deletions

    isLoading.value = true;
    try {
      if (team.id != null) {
        await _firestoreService.deleteTeam(team.id!);
        _showSuccessSnackbar('Success', 'Team "${team.name}" deleted successfully.');
      } else {
        _showErrorSnackbar('Error', 'Team ID is missing, cannot delete.');
      }
    } catch (e) {
      Logger.log('Error deleting team: $e');
      _showErrorSnackbar('Error', 'Failed to delete team: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Synchronizes data from Google Sheets to Firestore.
  Future<void> syncDataFromSheets() async {
    if (_isOperationInProgress()) return;

    _setLargeOperationLoading(true, 'Sync Initiated', 'Attempting to sync data from Google Sheet Web App...');

    try {
      final response = await _firestoreService.syncSheets();

      if (response.statusCode == 200) {
        // Use the isolate for JSON decoding
        final receivePort = ReceivePort();
        await Isolate.spawn(
          _decodeJsonInIsolate,
          response.body,
          onExit: receivePort.sendPort,
        );
        // Wait for the decoded result from the isolate
        final dynamic responseBody = await receivePort.first;
        Logger.log("Response from sheets sync: $responseBody");

        _showSuccessSnackbar('Sync Success', 'Google Sheet sync completed!');
      } else {
        Logger.log('Apps Script Web App HTTP Error: ${response.statusCode} - ${response.body}');
        _showErrorSnackbar(
          'Sync Error',
          'HTTP error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      Logger.log('Error syncing data from sheets: $e');
      _showErrorSnackbar('Sync Error', 'Failed to sync data: ${e.toString()}');
    } finally {
      _setLargeOperationLoading(false);
    }
  }

  /// Checks if a large operation (sync or mass delete) is already in progress.
  bool _isOperationInProgress() {
    if (isProcessingLargeOperation.value) {
      _showWarningSnackbar('Action in Progress', 'Another operation is already running. Please wait.');
      return true;
    }
    return false;
  }

  /// Sets the loading state for large operations and shows an initial snackbar.
  void _setLargeOperationLoading(bool value, [String? title, String? message]) {
    isProcessingLargeOperation.value = value;
    if (value && title != null && message != null) {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.amber, // Use a distinct color for ongoing ops
        colorText: Colors.black,
      );
    }
  }

  /// Shows a success snackbar.
  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  /// Shows an error snackbar.
  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  /// Shows a warning snackbar.
  void _showWarningSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }


  // /// Shows a generic confirmation dialog.
  // Future<bool?> _showConfirmationDialog(
  //     String title,
  //     String content, {
  //       String confirmButtonText = 'Confirm',
  //       Color confirmButtonColor = Colors.blue,
  //     }) async {
  //   return await Get.dialog<bool>(
  //     AlertDialog(
  //       title: Text(title),
  //       content: Text(content),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Get.back(result: false),
  //           child: const Text('Cancel'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () => Get.back(result: true),
  //           style: ElevatedButton.styleFrom(backgroundColor: confirmButtonColor),
  //           child: Text(
  //             confirmButtonText,
  //             style: const TextStyle(color: Colors.white),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Future<bool?> _showConfirmationDialog(
      BuildContext context,
      String title,
      String content, {
        String confirmButtonText = 'Confirm',
        Color confirmButtonColor = Colors.blue,
      }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text(title),

          content: Text(content),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: confirmButtonColor,
              ),

              child: Text(
                confirmButtonText,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void onClose() {
    _teamsStreamSubscription?.cancel();
    _playersStreamSubscription?.cancel();
    _searchDebounceWorker.dispose();
    super.onClose();
  }
}

/// Top-level function to decode JSON in an isolate.
/// This must be a static or top-level function.
dynamic _decodeJsonInIsolate(String jsonString) {
  return jsonDecode(jsonString);
}