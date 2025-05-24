// lib/bindings/player_form_binding.dart
import 'package:get/get.dart';

import '../player_form_controller.dart';

class PlayerFormBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PlayerFormController>(() => PlayerFormController());
  }
}
