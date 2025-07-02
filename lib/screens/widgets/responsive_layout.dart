// lib/screens/responsive_layout.dart
import 'package:expense_tracker/controllers/auth_controller.dart';
import 'package:expense_tracker/controllers/navigation_controller.dart';
import 'package:expense_tracker/screens/add_edit_expense_screen.dart';
import 'package:expense_tracker/screens/expense_list_screen.dart';
import 'package:expense_tracker/screens/widgets/expense_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    // This widget's purpose is to choose the correct high-level layout
    // for the current screen size. This part doesn't need to change.
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => ExpenseListScreen(),
      tablet: (BuildContext context) => const DesktopTabletLayout(),
      desktop: (BuildContext context) => const DesktopTabletLayout(),
    );
  }
}

// This is the layout for wide screens (tablets and desktops).
class DesktopTabletLayout extends StatelessWidget {
  const DesktopTabletLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final NavigationController navController = Get.find();
    
    return Scaffold(
      appBar: AppBar(
        // This Obx ensures the title updates gracefully when user data loads.
        title: Obx(() {
          final userName = authController.firestoreUser.value?['name'];
          if (userName == null) {
            return const Row(
              children: [
                Text('Welcome'),
                SizedBox(width: 10),
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                ),
              ],
            );
          }
          return Text('Welcome, $userName!');
        }),

        actions: [
          // This PopupMenuButton provides a clean dropdown menu for user actions on desktop.
          PopupMenuButton<int>(
            // The onSelected callback is triggered when a user taps a menu item.
            onSelected: (item) {
              switch (item) {
                case 0: // Corresponds to "Dashboard"
                  navController.changePage(1);
                  break;
                case 1: // Corresponds to "My Profile"
                  navController.changePage(2);
                  break;
                case 2: // Corresponds to "Settings"
                  Get.toNamed('/settings');
                  break;
                case 3: // Corresponds to "Logout"
                  Get.defaultDialog(
                    title: "Logout Confirmation",
                    middleText: "Are you sure you want to logout?",
                    onConfirm: () {
                      Get.back(); // Close dialog first
                      authController.logout();
                    },
                    textConfirm: "Logout",
                    textCancel: "Cancel",
                    confirmTextColor: Colors.white,
                    buttonColor: Theme.of(context).primaryColor,
                  );
                  break;
              }
            },
            // The itemBuilder builds the list of items to show in the dropdown.
            itemBuilder: (context) => [
              const PopupMenuItem<int>(
                value: 0,
                child: Row(
                  children: [
                    Icon(Icons.dashboard_outlined, color: Colors.black54),
                    SizedBox(width: 12),
                    Text('Dashboard'),
                  ],
                ),
              ),
              const PopupMenuItem<int>(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.person_outline, color: Colors.black54),
                    SizedBox(width: 12),
                    Text('My Profile'),
                  ],
                ),
              ),
              const PopupMenuItem<int>(
                value: 2,
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, color: Colors.black54),
                    SizedBox(width: 12),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<int>(
                value: 3,
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.account_circle, size: 28),
            tooltip: "Account & Settings",
          ),
          const SizedBox(width: 12),
        ],
      ),
      // This is the main master-detail view for the expense log.
      // This part is only visible when the 'Home' tab (index 0) is selected.
      // The AppShell handles switching to the Dashboard or Profile screens.
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: ExpenseListWidget(),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            flex: 2,
            child: AddEditExpenseScreen(),
          ),
        ],
      ),
    );
  }
}