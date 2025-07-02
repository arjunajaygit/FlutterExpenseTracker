// lib/screens/app_shell.dart
import 'package:expense_tracker/controllers/navigation_controller.dart';
import 'package:expense_tracker/screens/dashboard_screen.dart';
import 'package:expense_tracker/screens/profile_screen.dart';
import 'package:expense_tracker/screens/widgets/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navController = Get.find();

    // --- THIS IS THE UPDATED LIST OF SCREENS ---
    // The order here must match the order of the BottomNavigationBarItems.
    final List<Widget> screens = [
      const ResponsiveLayout(), // Index 0: For the Expense Log
      const DashboardScreen(),    // Index 1: The new Dashboard
      const ProfileScreen(),    // Index 2: The Profile Screen
    ];

    // ScreenTypeLayout decides whether to show the BottomNavigationBar.
    return ScreenTypeLayout.builder(
      // For mobile, we build a Scaffold that includes the BottomNavigationBar.
      mobile: (BuildContext context) {
        return Scaffold(
          // The body uses an IndexedStack wrapped in Obx.
          // This efficiently switches between screens without rebuilding them.
          body: Obx(() => IndexedStack(
            index: navController.selectedIndex.value,
            children: screens,
          )),
          
          // The BottomNavigationBar also listens to the controller.
          bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: navController.selectedIndex.value,
            onTap: (index) => navController.changePage(index),
            selectedItemColor: Colors.teal,
            unselectedItemColor: Colors.grey.shade600,
            type: BottomNavigationBarType.fixed, // Best for 3 items
            
            // --- THESE ARE THE UPDATED NAVIGATION ITEMS ---
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'Expenses',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          )),
        );
      },

      // For tablet and desktop, we don't show a bottom navigation bar.
      // We just show the currently selected screen. Navigation is handled
      // by the AppBar menu in the DesktopTabletLayout.
      desktop: (BuildContext context) {
        return Obx(() => IndexedStack(
          index: navController.selectedIndex.value,
          children: screens,
        ));
      },
      tablet: (BuildContext context) {
        return Obx(() => IndexedStack(
          index: navController.selectedIndex.value,
          children: screens,
        ));
      },
    );
  }
}