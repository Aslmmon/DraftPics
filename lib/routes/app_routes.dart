import 'dart:math';

import 'package:draftpics/ui/auth/login_screen.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:reutilizacao/auth/bindings/auth_binding.dart';

class AppRoutes {
  static const home = '/home';
  static const login = '/login';

  static final pages = [
    GetPage(name: login, page: () => LoginScreen(), bindings: [AuthBinding()]),
  ];
}
