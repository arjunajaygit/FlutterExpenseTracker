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
    // for the current screen size. It doesn't need any changes.
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => ExpenseListScreen(),
      tablet: (BuildContext context) => const DesktopTabletLayout(),
      desktop: (BuildContext context) => const DesktopTabletLayout(),
    );
  }
}

// This is the main layout for wide screens (tablets and desktops).
// This is the widget that needs the implementation you asked for.
class DesktopTabletLayout extends StatelessWidget {
  const DesktopTabletLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final NavigationController navController = Get.find();
    
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final userName = authController.firestoreUser.value?['name'];
          return Text('Welcome, ${userName ?? '...'}');
        }),
        actions: [
          // This PopupMenuButton provides a clean dropdown menu for user actions
          // on desktop, which is a better UX than multiple icon buttons.
          PopupMenuButton<int>(
            // The 'onSelected' callback is triggered when a user taps a menu item.
            // The 'item' variable is the 'value' we assigned to the PopupMenuItem.
            onSelected: (item) {
              switch (item) {
                case 0:
                  // Value 0 corresponds to "My Profile"
                  // We tell the NavigationController to switch to the second page (index 1).
                  navController.changePage(1);
                  break;
                case 1:
                  // Value 1 corresponds to "Settings"
                  // We use GetX's named routing to navigate to the settings screen.
                  Get.toNamed('/settings');
                  break;
                case 2:
                  // Value 2 corresponds to "Logout"
                  // We call the logout method from the AuthController.
                  // Note: We use the dialog here for a consistent user experience.
                  Get.defaultDialog(
                    title: "Logout Confirmation",
                    middleText: "Are you sure you want to logout?",
                    textConfirm: "Logout",
                    textCancel: "Cancel",
                    confirmTextColor: Colors.white,
                    buttonColor: Theme.of(context).primaryColor,
                    onConfirm: () => authController.logout(),
                  );
                  break;
              }
            },
            // The 'itemBuilder' builds the list of items to show in the dropdown.
            itemBuilder: (context) => [
              // --- Menu Item 1: Profile ---
              const PopupMenuItem<int>(
                value: 0,
                child: Row(
                  children: [
                    Icon(Icons.person_outline, color: Colors.black54),
                    SizedBox(width: 12),
                    Text('My Profile'),
                  ],
                ),
              ),
              // --- Menu Item 2: Settings ---
              const PopupMenuItem<int>(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, color: Colors.black54),
                    SizedBox(width: 12),
                    Text('Settings'),
                  ],
                ),
              ),
              // A visual separator line in the menu
              const PopupMenuDivider(),
              // --- Menu Item 3: Logout ---
              const PopupMenuItem<int>(
                value: 2,
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            // The icon that the user clicks to open the menu
            icon: const Icon(Icons.account_circle, size: 28),
            tooltip: "Account & Settings",
          ),
          const SizedBox(width: 12), // Some spacing on the right edge
        ],
      ),
      // The body of the layout is our master-detail view
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