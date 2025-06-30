// lib/screens/responsive_layout.dart
import 'package:expense_tracker/controllers/auth_controller.dart';
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
    // This widget from responsive_builder automatically chooses the correct layout
    // based on the screen width.
    return ScreenTypeLayout.builder(
      // The layout for standard mobile phone sizes
      mobile: (BuildContext context) => ExpenseListScreen(),
      
      // The layout for tablets and desktops
      tablet: (BuildContext context) => const DesktopTabletLayout(),
      desktop: (BuildContext context) => const DesktopTabletLayout(),
    );
  }
}

// This is our new layout for wide screens, featuring a master-detail view.
class DesktopTabletLayout extends StatelessWidget {
  const DesktopTabletLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final userName = authController.firestoreUser.value?['name'];
          return Text('Welcome, ${userName ?? '...'}');
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => authController.logout(),
          )
        ],
      ),
      body: Row(
        children: [
          // Pane 1: The Expense List (Master View)
          Expanded(
            flex: 1, // Takes 1 part of the width
            child: ExpenseListWidget(), // Our reusable list widget
          ),
          const VerticalDivider(width: 1, thickness: 1),
          // Pane 2: The Form for Adding/Editing (Detail View)
          Expanded(
            flex: 2, // Takes 2 parts of the width, making it wider
            child: AddEditExpenseScreen(),
          ),
        ],
      ),
    );
  }
}