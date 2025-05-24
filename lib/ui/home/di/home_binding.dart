// lib/bindings/home_binding.dart
import 'package:draftpics/ui/home/controllers/add_team_controller.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<AddTeamController>(() => AddTeamController());

  }
}
