import 'package:draftpics/ui/home/di/home_binding.dart';
import 'package:draftpics/ui/home/home_screen.dart';
import 'package:draftpics/ui/player/PlayerScreen.dart';
import 'package:draftpics/ui/team_details/di/team_details_binding.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import '../ui/team_details/team_details_screen.dart';

class AppRoutes {
  static const home = '/home';
  static const teamDetails = '/teamDetails';
  static const playerScreen = '/playerScreen';

  static final pages = [
    GetPage(name: home, page: () => HomeScreen(), binding: HomeBinding()),
    GetPage(
      name: teamDetails,
      page: () => const TeamDetailsScreen(),
      binding: TeamDetailsBinding(),
    ),
    GetPage(name: playerScreen, page: () => AddPlayerScreen()),
  ];
}
