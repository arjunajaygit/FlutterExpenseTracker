// lib/screens/app_shell.dart
import 'package:expense_tracker/controllers/navigation_controller.dart';
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

    // List of the main screens accessible from the navigation
    final List<Widget> screens = [
      const ResponsiveLayout(), // Our existing home/dashboard layout
      const ProfileScreen(),    // Our new profile screen
    ];

    // ScreenTypeLayout will decide whether to show the BottomNavBar or not.
    return ScreenTypeLayout.builder(
      // For mobile, we show the Scaffold WITH the BottomNavigationBar.
      mobile: (BuildContext context) {
        return Scaffold(
          body: Obx(() => IndexedStack(
            index: navController.selectedIndex.value,
            children: screens,
          )),
          bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: navController.selectedIndex.value,
            onTap: (index) => navController.changePage(index),
            selectedItemColor: Colors.teal,
            unselectedItemColor: Colors.grey.shade600,
            type: BottomNavigationBarType.fixed, // Good for 2-3 items
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
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

      // For tablet and desktop, we just show the selected screen directly
      // WITHOUT a Scaffold or BottomNavigationBar.
      // The inner screens themselves handle their own layout and AppBars.
      desktop: (BuildContext context) {
        return Obx(() => IndexedStack(
          index: navController.selectedIndex.value,
          children: screens,
        ));
      },
      // You can define a separate tablet layout if needed, but for now, it's same as desktop
      tablet: (BuildContext context) {
        return Obx(() => IndexedStack(
          index: navController.selectedIndex.value,
          children: screens,
        ));
      },
    );
  }
}