import 'package:get/get.dart';

import '../team_details_controller.dart';

class TeamDetailsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeamDetailsController>(() => TeamDetailsController());
  }
}
