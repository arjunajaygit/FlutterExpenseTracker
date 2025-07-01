// lib/screens/profile_screen.dart
import 'package:expense_tracker/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // --- THIS IS THE NEW, BEAUTIFUL DIALOG ---
  void _showLogoutDialog(BuildContext context, AuthController authController) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: _buildDialogContent(context, authController),
      ),
    );
  }

  // --- WIDGET FOR THE DIALOG'S CONTENT ---
  Widget _buildDialogContent(BuildContext context, AuthController authController) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // To make the card compact
        children: <Widget>[
          // --- 1. The Icon ---
          Icon(
            Icons.logout,
            color: isDarkMode ? Colors.teal.shade200 : Colors.teal,
            size: 60,
          ),
          const SizedBox(height: 24.0),

          // --- 2. The Title ---
          const Text(
            'Oh no! You\'re leaving...',
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),

          // --- 3. The Subtitle ---
          Text(
            'Are you sure?',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28.0),

          // --- 4. The Buttons ---
          // Primary Button (to stay)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.back(); // Just close the dialog
              },
              style: ElevatedButton.styleFrom(
                // This button will use the global full-width theme
              ),
              child: const Text('Naah, Just Kidding'),
            ),
          ),
          const SizedBox(height: 12.0),
          
          // Secondary Button (to log out)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Get.back();
                authController.logout();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: isDarkMode ? Colors.red.shade300 : Colors.red,
                side: BorderSide(color: isDarkMode ? Colors.red.shade300 : Colors.red),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
              ),
              child: const Text('Yes, Log Me Out'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();

    // Helper function for info tiles
    Widget buildInfoTile(IconData icon, String title, String subtitle) {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      final subtitleColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
      final iconColor = isDarkMode ? Colors.teal.shade200 : Colors.teal;

      return ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 16, color: subtitleColor)),
      );
    }
    
    final profileBody = Center(
      // ... the rest of the profileBody is exactly the same as before ...
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Obx(() {
            final user = authController.firestoreUser.value;
            if (user == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final String name = user['name'] ?? 'N/A';
            final String email = user['email'] ?? 'N/A';
            final String phone = user['phone'] ?? 'N/A';
            final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.teal.shade400,
                  child: Text(initial, style: const TextStyle(fontSize: 50, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                
                Text(
                  name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                Card(
                  elevation: Theme.of(context).brightness == Brightness.dark ? 1 : 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      buildInfoTile(Icons.email_outlined, 'Email Address', email),
                      const Divider(),
                      buildInfoTile(Icons.phone_outlined, 'Phone Number', phone),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                ElevatedButton.icon(
                  onPressed: () => _showLogoutDialog(context, authController),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                ),
              ],
            );
          }),
        ),
      ),
    );

    // The responsive layout part remains the same
    return ScreenTypeLayout.builder(
      mobile: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () => Get.toNamed('/settings'),
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Settings',
            )
          ],
        ),
        body: profileBody,
      ),
      desktop: (context) => Material(color: Theme.of(context).scaffoldBackgroundColor, child: profileBody),
      tablet: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () => Get.toNamed('/settings'),
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Settings',
            )
          ],
        ),
        body: profileBody,
      ),
    );
  }
}