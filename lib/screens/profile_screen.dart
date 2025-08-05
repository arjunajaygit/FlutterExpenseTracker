// lib/screens/profile_screen.dart
import 'package:cached_network_image/cached_network_image.dart'; // <<< CORRECTED IMPORT
import 'package:expense_tracker/controllers/auth_controller.dart';
import 'package:expense_tracker/controllers/settings_controller.dart';
import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/screens/account_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showInfoSnackbar(String title, String message) {
    Get.snackbar(
      title, message, snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87, colorText: Colors.white,
      duration: const Duration(milliseconds: 1800),
      margin: const EdgeInsets.all(12), borderRadius: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final SettingsController settingsController = Get.put(SettingsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          children: [
            Obx(
              () => Row(
                children: [
                  GestureDetector(
                    onTap: () => authController.showImageSourceActionSheet(),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Theme.of(context).cardColor,
                          backgroundImage: authController.firestoreUser.value?['profilePictureUrl'] != null
                              ? CachedNetworkImageProvider(authController.firestoreUser.value!['profilePictureUrl'])
                              : null,
                          child: authController.firestoreUser.value?['profilePictureUrl'] == null
                              ? Icon(IconlyBold.profile, size: 30, color: Theme.of(context).colorScheme.secondary)
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2)
                          ),
                          child: Icon(IconlyBold.camera, size: 16, color: Theme.of(context).primaryColor),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authController.firestoreUser.value?['name'] ?? 'Loading...',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          authController.firestoreUser.value?['email'] ?? '',
                          style: TextStyle(
                              fontSize: 14, color: Theme.of(context).colorScheme.secondary),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildSettingsCard(
              context: context,
              children: [
                _buildSettingsTile(
                  context: context,
                  icon: IconlyLight.profile,
                  title: 'Account',
                  subtitle: 'Manage profile, password & more',
                  onTap: () {
                    Get.to(() => const AccountManagementScreen());
                  },
                ),
                _buildSettingsTile(
                  context: context,
                  icon: IconlyLight.notification,
                  title: 'Notifications',
                  subtitle: 'Customize notification settings',
                   onTap: () {
                     _showInfoSnackbar('Info', 'Notification settings coming soon!');
                  },
                ),
                Obx(
                  () => SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    secondary: Icon(IconlyLight.show, color: Theme.of(context).colorScheme.secondary),
                    title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(
                      settingsController.isDarkMode.value ? 'On' : 'Off',
                      style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 12),
                    ),
                    value: settingsController.isDarkMode.value,
                    onChanged: (value) => settingsController.changeTheme(value),
                    activeColor: AppColors.primaryGradient.colors.first,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
             _buildSettingsCard(
              context: context,
              children: [
                 _buildSettingsTile(
                  context: context,
                  icon: IconlyBold.infoSquare,
                  title: 'About',
                  subtitle: 'Learn more about the app',
                   onTap: () {
                     _showInfoSnackbar('Info', 'InEx v1.0.0');
                   },
                ),
                 _buildSettingsTile(
                  context: context,
                  icon: IconlyLight.logout,
                  color: Colors.red,
                  title: 'Logout',
                  subtitle: 'Sign out of your account',
                  onTap: () => authController.logout(),
                ),
              ]
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required BuildContext context, required List<Widget> children}){
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color ?? secondaryColor),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: color)),
      subtitle: Text(subtitle, style: TextStyle(color: secondaryColor, fontSize: 12)),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: color ?? secondaryColor,
      ),
    );
  }
}