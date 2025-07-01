// lib/services/theme_service.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  // Private method to save the theme choice
  _saveThemeToBox(bool isDarkMode) => _box.write(_key, isDarkMode);

  // Method to load the theme choice. Defaults to false (light mode) if nothing is saved.
  bool _loadThemeFromBox() => _box.read(_key) ?? false;

  // Getter to check the current theme mode
  ThemeMode get theme => _loadThemeFromBox() ? ThemeMode.dark : ThemeMode.light;

  // Method to switch the theme
  void switchTheme() {
    Get.changeThemeMode(_loadThemeFromBox() ? ThemeMode.light : ThemeMode.dark);
    _saveThemeToBox(!_loadThemeFromBox());
  }
}