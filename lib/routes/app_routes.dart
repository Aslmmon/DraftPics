import 'package:draftpics/ui/auth/login_screen.dart';
import 'package:draftpics/ui/home/home_screen.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:reutilizacao/auth/bindings/auth_binding.dart';

import '../ui/team_details/TeamDetailsScreen.dart';

class AppRoutes {
  static const home = '/home';
  static const login = '/login';
  static const addScreen = '/addScreen';

  static final pages = [
    GetPage(name: login, page: () => LoginScreen(), binding: AuthBinding()),
    GetPage(name: home, page: () => HomeScreen()),
    GetPage(name: addScreen, page: () => TeamDetailsScreen()),
  ];
}
