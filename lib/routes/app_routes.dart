import 'package:draftpics/ui/home/home_screen.dart';
import 'package:draftpics/ui/player/PlayerScreen.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import '../ui/team_details/TeamDetailsScreen.dart';

class AppRoutes {
  static const home = '/home';
  static const teamDetails = '/teamDetails';
  static const playerScreen = '/playerScreen';

  static final pages = [
    GetPage(name: home, page: () => HomeScreen()),
    GetPage(name: teamDetails, page: () => TeamDetailsScreen()),
    GetPage(name: playerScreen, page: () => AddPlayerScreen()),

  ];
}
