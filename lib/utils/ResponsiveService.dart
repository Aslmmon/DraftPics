// lib/services/responsive_service.dart
import 'package:draftpics/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResponsiveService extends GetxService {
  // Use RxDouble for reactive screen width
  final RxDouble _screenWidth = 0.0.obs;

  // Use RxBool for reactive small device status
  final RxBool _isSmallDevice = false.obs;
  double get screenWidth => _screenWidth.value;
  bool get isSmallDevice => _isSmallDevice.value;

  @override
  void onInit() {
    super.onInit();
    // Initialize screen width and small device status
    _updateScreenDimensions();

    // Listen for window size changes (e.g., orientation changes, resizable windows)
    // Note: WidgetsBinding.instance.window.onMetricsChanged is for low-level changes.
    // For general UI responsiveness based on screen size, you typically re-evaluate
    // within widgets or use a higher-level state management listener.
    // GetX's Get.width and Get.height automatically update if used after GetMaterialApp.
    // However, for initial setup and a dedicated service, this is a clean way.
    ever(Get.width.obs, (double width) {
      _updateScreenDimensions();
    });
  }

  void _updateScreenDimensions() {
    // Get.width and Get.height are available globally *after* GetMaterialApp is initialized
    _screenWidth.value = Get.width;
    _isSmallDevice.value =
        _screenWidth.value < AppConstants.smallDeviceBreakpoint;
    print(
      "Screen Width: ${_screenWidth.value}, Is Small Device: ${_isSmallDevice.value}",
    ); // For debugging
  }

  // You might want a method to force update if needed (though GetX usually handles it)
  void updateDimensions() {
    _updateScreenDimensions();
  }
}
