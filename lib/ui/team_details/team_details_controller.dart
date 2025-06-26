// lib/ui/team_details/team_details_controller.dart
import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:reutilizacao/ui/components/ReusableAlertDialog.dart';
import '../../data/model/PlayerModel.dart';
import '../../data/model/TeamModel.dart';
import '../../data/services/FirestoreService.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_constants.dart';

class TeamDetailsController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final Rx<Team> team = Team(name: 'Loading...', id: '').obs;
  final RxList<Player> players = <Player>[].obs; // Reactive list of all players

  // Reactive variable for the selected jersey number filter
  // Use 'null' to represent "All Jersey Numbers"
  final Rx<String?> selectedJerseyNumber = Rx<String?>(null);

  StreamSubscription<List<Player>>? _playersStreamSubscription;
  StreamSubscription<Team>? _teamStreamSubscription;
  var isUploadingCsv = false.obs;

  @override
  void onInit() {
    super.onInit();
    final Team? argsTeam = Get.arguments as Team?;
    if (argsTeam != null) {
      team.value = argsTeam;
      _listenToPlayers(team.value);
    }

    // Initialize selectedJerseyNumber to null (show all players)
    selectedJerseyNumber.value = null;
  }

  void _listenToPlayers(Team value) {
    _playersStreamSubscription = _firestoreService
        .getPlayersForTeam(value.id!)
        .listen((playerList) {
          players.value =
              playerList; // Update the observable list of all players
          // When players update, reset filter if current selection is no longer valid
          if (selectedJerseyNumber.value != null &&
              !uniqueJerseyNumbers.contains(selectedJerseyNumber.value)) {
            selectedJerseyNumber.value =
                null; // Reset to "All" if current filter is gone
          }
        });
  }

  // Computed property to get unique jersey numbers for the dropdown
  // It returns a list of integers (jersey numbers)
  RxList<String> get uniqueJerseyNumbers {
    final Set<String> numbers = {};
    for (var player in players) {
      if (player.jerseyNumber != null) {
        numbers.add(player.jerseyNumber!);
      }
    }
    final List<String> sortedNumbers = numbers.toList();
    sortedNumbers.sort(); // Sort numbers for consistent dropdown order
    return sortedNumbers.obs; // Make it observable if you want UI to react
  }

  // Computed property for the list of players after applying the jersey number filter
  RxList<Player> get filteredPlayers {
    if (selectedJerseyNumber.value == null) {
      return players; // If "All" is selected, return all players
    } else {
      return players
          .where((player) => player.jerseyNumber == selectedJerseyNumber.value)
          .toList()
          .obs; // Filter and return observable list
    }
  }

  // Method to change the selected jersey number
  void setJerseyNumberFilter(String? jerseyNumber) {
    selectedJerseyNumber.value = jerseyNumber;
  }

  void goToAddPlayer() {
    Get.toNamed(AppRoutes.playerFromScreen, arguments: team.value.id);
  }

  void editPlayer(Player player) {
    Get.toNamed(AppRoutes.playerFromScreen, arguments: player);
  }

  Future<void> deletePlayer(Player player) async {
    ReusableAlertDialog.show(
      title: AppConstants.deletePlayerTitle,
      content:
          '${AppConstants.deletePlayerContent}"${player.firstName} ${player.lastName}"? This action cannot be undone.',
      yesText: AppConstants.deleteButton,
      noText: AppConstants.cancelButton,
      onYesPressed: () async {
        try {
          await _firestoreService.deletePlayer(player.teamId, player.id!);
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
