// lib/controllers/settings_controller.dart
import 'package:flutter/material.dart'; // <<< 1. IMPORT THIS
import 'package:get/get.dart';
import 'package:expense_tracker/services/theme_service.dart';

class SettingsController extends GetxController {
  // We can make this final as it's initialized once in onInit.
  final ThemeService _themeService = Get.find();
  
  // A reactive variable to know the current state for the UI switch
  late RxBool isDarkMode;

  @override
  void onInit() {
    super.onInit();
    
    // <<< 2. CORRECT THE INITIALIZATION >>>
    // First, get the boolean value from the comparison.
    bool isCurrentlyDark = (_themeService.theme == ThemeMode.dark);
    // Then, use that boolean value to initialize the RxBool.
    isDarkMode = isCurrentlyDark.obs;
  }

  // This method is called from the UI switch.
  void changeTheme(bool value) {
    // Tell the ThemeService to perform the switch.
    _themeService.switchTheme();
    // Update our own reactive variable to match the new state.
    isDarkMode.value = value;
  }
}