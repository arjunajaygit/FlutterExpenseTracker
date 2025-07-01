// lib/screens/settings_screen.dart
import 'package:expense_tracker/controllers/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Put the controller here, as this might be the only screen that uses it.
    final SettingsController settingsController = Get.put(SettingsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Obx(
              () => SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: Text(settingsController.isDarkMode.value ? 'Enabled' : 'Disabled'),
                value: settingsController.isDarkMode.value,
                onChanged: (value) {
                  settingsController.changeTheme(value);
                },
                secondary: Icon(
                  settingsController.isDarkMode.value ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                  color: Colors.teal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}