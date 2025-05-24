import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TeamDetailsController extends GetxController {
  final TextEditingController textFieldController = TextEditingController();
  final RxString currentText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    currentText.value = textFieldController.text;
    textFieldController.addListener(_updateCurrentText);
  }

  void _updateCurrentText() {
    if (currentText.value != textFieldController.text) {
      currentText.value = textFieldController.text;
      print('TextField value updated in controller: ${currentText.value}');
    }
  }

  // You can add other methods to interact with the TextField, e.g.:
  void clearText() => textFieldController.clear();

  void setText(String newText) => textFieldController.text = newText;

  @override
  void onClose() {
    textFieldController.removeListener(_updateCurrentText);
    textFieldController.dispose();
    super.onClose();
    print('MyTextFieldController disposed.');
  }
}
