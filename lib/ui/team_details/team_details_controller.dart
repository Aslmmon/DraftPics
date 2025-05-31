// lib/ui/team_details/team_details_controller.dart
import 'dart:async'; // Required for StreamSubscription
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
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
  var isUploadingCsv = false.obs; // NEW: Loading state for CSV upload

  @override
  void onInit() {
    super.onInit();
    final Team? argsTeam = Get.arguments as Team?;
    if (argsTeam != null) {
      team.value = argsTeam; // Set the initial team from arguments
      _listenToPlayers(team.value);
    }
  }

  void _listenToPlayers(Team value) {
    _playersStreamSubscription = _firestoreService
        .getPlayersForTeam(value.id!)
        .listen((playerList) {
          players.value = playerList; // Update the observable list
        });
  }

  void goToAddPlayer() {
    Get.toNamed(AppRoutes.playerFromScreen, arguments: team.value.id);
  }

  void editPlayer(Player player) {
    Get.toNamed(AppRoutes.playerFromScreen, arguments: player);
  }

  // --- NEW: Delete Player Method ---
  Future<void> deletePlayer(Player player) async {
    ReusableAlertDialog.show(
      title: AppConstants.deletePlayerTitle,
      content:
          '${AppConstants.deletePlayerContent}"${player.firstName} ${player.lastName}"? This action cannot be undone.',
      yesText: AppConstants.deleteButton,
      noText: AppConstants.cancelButton,
      onYesPressed: () async {
        try {
          await _firestoreService.deletePlayer(player.id!,player.teamId);
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

  Future<void> pickAndUploadPlayersCsv() async {
    if (team.value.id == null) {
      Get.snackbar(
        AppConstants.error,
        AppConstants.teamIdMissingError,
        // "Team ID is missing. Cannot upload players."
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isUploadingCsv.value = true;
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        Uint8List bytes = result.files.single.bytes!;
        // Pass the current team's ID to the service
        List<String> uploadStatus = await _firestoreService
            .uploadPlayersFromCsv(bytes, team.value.id!);

        String message = uploadStatus.join('\n');
        Get.snackbar(
          AppConstants.csvUploadResultTitle,
          message,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
      } else {
        Get.snackbar(
          AppConstants.csvUploadCancelledTitle,
          AppConstants.csvUploadCancelledMessage,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        AppConstants.error,
        '${AppConstants.failedToUploadCsv} ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      print("Error picking/uploading CSV in TeamDetails: $e");
    } finally {
      isUploadingCsv.value = false;
    }
  }

  @override
  void onClose() {
    _playersStreamSubscription?.cancel();
    _teamStreamSubscription?.cancel();
    super.onClose();
  }
}
