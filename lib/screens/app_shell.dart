// lib/screens/app_shell.dart
import 'package:expense_tracker/controllers/navigation_controller.dart';
import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/screens/dashboard_screen.dart';
import 'package:expense_tracker/screens/expense_list_screen.dart';
import 'package:expense_tracker/screens/insights_screen.dart'; // <<< 1. IMPORT THE NEW SCREEN
import 'package:expense_tracker/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navController = Get.find();

    // <<< 2. ADD THE INSIGHTS SCREEN TO THE LIST
    final List<Widget> screens = [
      const DashboardScreen(),
      const ExpenseListScreen(),
      const InsightsScreen(), // The new Insights screen
      const ProfileScreen(),
    ];

    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) {
        return Scaffold(
          body: Obx(() => IndexedStack(
                index: navController.selectedIndex.value,
                children: screens,
              )),
          bottomNavigationBar: Obx(
            () => Container(
              margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: navController.selectedIndex.value,
                onTap: (index) => navController.changePage(index),
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: Colors.white,
                unselectedItemColor: AppColors.secondaryColor,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                type: BottomNavigationBarType.fixed,
                // <<< 3. ADD THE NEW NAVIGATION ITEM
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(IconlyLight.home),
                    activeIcon: Icon(IconlyBold.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(IconlyLight.document),
                    activeIcon: Icon(IconlyBold.document),
                    label: 'Transactions',
                  ),
                   BottomNavigationBarItem( // New Insights Item
                    icon: Icon(IconlyLight.graph),
                    activeIcon: Icon(IconlyBold.graph),
                    label: 'Insights',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(IconlyLight.setting),
                    activeIcon: Icon(IconlyBold.setting),
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          ),
        );
      },
      desktop: (BuildContext context) {
        return Obx(() => IndexedStack(
              index: navController.selectedIndex.value,
              children: screens,
            ));
      },
    );
  }
}