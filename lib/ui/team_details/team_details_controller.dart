// lib/ui/team_details/team_details_controller.dart
import 'dart:async'; // Required for StreamSubscription

import 'package:get/get.dart';
import 'package:reutilizacao/ui/components/ReusableAlertDialog.dart';
import '../../data/model/PlayerModel.dart';
import '../../data/model/TeamModel.dart';
import '../../data/services/FirestoreService.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_constants.dart'; // Import constants

class TeamDetailsController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final Rx<Team> team =
      Team(name: 'Loading...', id: '').obs; // Initialize with a dummy team
  final RxList<Player> players = <Player>[].obs; // Reactive list of players

  StreamSubscription<List<Player>>? _playersStreamSubscription;
  StreamSubscription<Team>? _teamStreamSubscription;

  @override
  void onInit() {
    super.onInit();
    final Team? argsTeam = Get.arguments as Team?;
    if (argsTeam != null) {
      team.value = argsTeam; // Set the initial team from arguments

      // Listen to the team document for real-time updates (e.g., if name changes)
      // _teamStreamSubscription = _firestoreService
      //     .getTeamById(argsTeam.id!)
      //     .listen((updatedTeam) {
      //       if (updatedTeam != null) {
      //         team.value = updatedTeam;
      //       }
      //     });

      // Listen for players for this specific team
      _playersStreamSubscription = _firestoreService
          .getPlayersForTeam(argsTeam.id!)
          .listen((playerList) {
            players.value = playerList; // Update the observable list
          });
    } else {
      // Handle case where no team is passed (e.g., show an error or go back)
      Get.back();
      Get.snackbar(
        'Error',
        'No team data received!',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void goToAddPlayer() {
    Get.toNamed(AppRoutes.playerFromScreen, arguments: team.value.id);
  }

  void editPlayer(Player player) {
    Get.toNamed(AppRoutes.playerFromScreen, arguments: player);
  }

  // --- NEW: Delete Player Method ---
  void deletePlayer(Player player) {
    ReusableAlertDialog.show(
      title: AppConstants.deletePlayerTitle,
      content:
          '${AppConstants.deletePlayerContent}"${player.firstName} ${player.lastName}"? This action cannot be undone.',
      yesText: AppConstants.deleteButton,
      noText: AppConstants.cancelButton,
      onYesPressed: () async {
        try {
          await _firestoreService.deletePlayer(player.id!);
          Get.snackbar(
            'Success',
            'Player "${player.firstName} ${player.lastName}" deleted successfully!',
            snackPosition: SnackPosition.BOTTOM,
          );
        } catch (e) {
          Get.snackbar(
            'Error',
            'Failed to delete player: ${e.toString()}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError,
          );
          print('Error deleting player: $e');
        }
      },
    );
  }

  @override
  void onClose() {
    _playersStreamSubscription?.cancel();
    _teamStreamSubscription?.cancel();
    super.onClose();
  }
}
