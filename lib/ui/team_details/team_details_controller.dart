import 'dart:async'; // For StreamSubscription

import 'package:get/get.dart';

import '../../data/model/PlayerModel.dart';
import '../../data/model/TeamModel.dart';
import '../../data/services/FirestoreService.dart';
import '../../routes/app_routes.dart';

class TeamDetailsController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  late Rx<Team> team;

  var players = <Player>[].obs;
  StreamSubscription<List<Player>>? _playersStreamSubscription;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Team) {
      team = (Get.arguments as Team).obs; // Make the team observable

      print("team is " + team.value.name);
      print("team is " + team.value.id);

      // Subscribe to the stream of players for this specific team's ID
      _playersStreamSubscription = _firestoreService
          .getPlayersForTeam(team.value.id)
          .listen((fetchedPlayers) {
            players.value =
                fetchedPlayers; // Update the observable players list
          });
    } else {
      // Handle the case where the team object was not passed
      Get.snackbar(
        'Error',
        'Team details not found. Please select a team from the home screen.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      // Optionally navigate back to prevent an empty screen
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.back();
      });
    }
  }

  // Method to navigate to the Add Player screen
  void goToAddPlayer() {
    if (team.value.id.isNotEmpty) {
      // Pass the current team's ID to the Add Player screen
      Get.toNamed(AppRoutes.playerFromScreen, arguments: team.value.id);
    } else {
      Get.snackbar(
        'Error',
        'Cannot add player: Team ID is missing.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  void editPlayer(Player player) =>
      Get.toNamed(AppRoutes.playerFromScreen, arguments: player);

  @override
  void onClose() {
    // Cancel the stream subscription to prevent memory leaks
    _playersStreamSubscription?.cancel();
    super.onClose();
  }
}
